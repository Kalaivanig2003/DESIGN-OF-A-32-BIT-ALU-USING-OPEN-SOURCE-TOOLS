module barrel_shifter_32bit (
    input  wire [31:0] data_in,   // 32-bit Input Data
    input  wire [4:0]  shift_amt, // 5-bit Shift Amount (0 to 31)
    input  wire [1:0]  shift_type,// 00: LSL, 01: LSR, 10: ASR, 11: ROR
    output reg  [31:0] data_out   // 32-bit Shifted Output Data
);

    reg [31:0] stage0, stage1, stage2, stage3;
    wire fill_bit;

    // Determine the sign-extension bit for Arithmetic Right Shift (ASR)
    assign fill_bit = (shift_type == 2'b10) ? data_in[31] : 1'b0;

    always @(*) begin
        // STAGE 0: Shift/Rotate by 1 bit (Controlled by shift_amt[0])
        if (shift_amt[0]) begin
            case (shift_type)
                2'b00:   stage0 = {data_in[30:0], 1'b0};               // Logical Left Shift
                2'b01:   stage0 = {1'b0, data_in[31:1]};               // Logical Right Shift
                2'b10:   stage0 = {fill_bit, data_in[31:1]};           // Arithmetic Right Shift
                2'b11:   stage0 = {data_in[0], data_in[31:1]};         // Rotate Right
                default: stage0 = data_in;
            endcase
        end else begin
            stage0 = data_in;
        end

        // STAGE 1: Shift/Rotate by 2 bits (Controlled by shift_amt[1])
        if (shift_amt[1]) begin
            case (shift_type)
                2'b00:   stage1 = {stage0[29:0], 2'b0};
                2'b01:   stage1 = {2'b0, stage0[31:2]};
                2'b10:   stage1 = {{2{fill_bit}}, stage0[31:2]};
                2'b11:   stage1 = {stage0[1:0], stage0[31:2]};
                default: stage1 = stage0;
            endcase
        end else begin
            stage1 = stage0;
        end

        // STAGE 2: Shift/Rotate by 4 bits (Controlled by shift_amt[2])
        if (shift_amt[2]) begin
            case (shift_type)
                2'b00:   stage2 = {stage1[27:0], 4'b0};
                2'b01:   stage2 = {4'b0, stage1[31:4]};
                2'b10:   stage2 = {{4{fill_bit}}, stage1[31:4]};
                2'b11:   stage2 = {stage1[3:0], stage1[31:4]};
                default: stage2 = stage1;
            endcase
        end else begin
            stage2 = stage1;
        end

        // STAGE 3: Shift/Rotate by 8 bits (Controlled by shift_amt[3])
        if (shift_amt[3]) begin
            case (shift_type)
                2'b00:   stage3 = {stage2[23:0], 8'b0};
                2'b01:   stage3 = {8'b0, stage2[31:8]};
                2'b10:   stage3 = {{8{fill_bit}}, stage2[31:8]};
                2'b11:   stage3 = {stage2[7:0], stage2[31:8]};
                default: stage3 = stage2;
            endcase
        end else begin
            stage3 = stage2;
        end

        // STAGE 4: Shift/Rotate by 16 bits (Controlled by shift_amt[4])
        if (shift_amt[4]) begin
            case (shift_type)
                2'b00:   data_out = {stage3[15:0], 16'b0};
                2'b01:   data_out = {16'b0, stage3[31:16]};
                2'b10:   data_out = {{16{fill_bit}}, stage3[31:16]};
                2'b11:   data_out = {stage3[15:0], stage3[31:16]};
                default: data_out = stage3;
            endcase
        end else begin
            data_out = stage3;
        end
    end
endmodule
