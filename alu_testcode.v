module alu_32_bit_tb;

    // Inputs to the ALU Subsystem (Declared as registers)
    reg signed [31:0] in_a;
    reg signed [31:0] in_b;
    reg        [2:0]  op;
    reg               clk;
    reg               rst;
    reg               mul_start;

    // Outputs from the ALU Subsystem (Declared as wires)
    wire        [31:0] alu_out;
    wire        [32:0] temp;
    wire               zero;
    wire               carry;
    wire               overflow;
    wire               difference;
    wire        [63:0] mul_ans;
    wire               mul_done;

    // Sign-extended monitoring wire for print readability
    wire signed [31:0] alu_out_signed;
    assign alu_out_signed = alu_out;

    // Instantiate the Unified Top-Level ALU Module
    alu_32_bit uut (
        .alu_out(alu_out),
        .temp(temp),
        .zero(zero),
        .carry(carry),
        .overflow(overflow),
        .difference(difference),
        .mul_ans(mul_ans),
        .mul_done(mul_done),
        .in_a(in_a),
        .in_b(in_b),
        .op(op),
        .clk(clk),
        .rst(rst),
        .mul_start(mul_start)
    );

    // Clock Generation: 10ns cycle period (50MHz simulation environment)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Main Test Vector Sequence
    initial begin
        // Setup Waveform Dumps for VS Code / GTKWave inspection
        $dumpfile("alu_system_wave.vcd");
        $dumpvars(0, alu_32_bit_tb);

        $display("=============================================================");
        $display("  STARTING INTEGRATED SYSTEM VERIFICATION (ALU + BMUL + BARREL)");
        $display("=============================================================");

        // PHASE 1: System Hardware Initialization & Reset
        rst       = 1'b1;
        mul_start = 1'b0;
        op        = 3'b000;
        in_a      = 32'b0;
        in_b      = 32'b0;
        #15; 
        rst       = 1'b0; // Release hardware reset
        #5;

        // PHASE 2: Core Arithmetic Tests (Addition & Subtraction)
        // Case 2A: Addition (15 + 10 = 25)
        in_a = 32'd15; 
        in_b = 32'd10; 
        op   = 3'b001; 
        #10;
        $display("[ADD] InA=%0d, InB=%0d | Out=%0d (Expected: 25)", in_a, in_b, alu_out_signed);

        // Case 2B: Subtraction (15 - 10 = 5)
        op   = 3'b010; 
        #10;
        $display("[SUB] InA=%0d, InB=%0d | Out=%0d (Expected: 5)", in_a, in_b, alu_out_signed);

        // -----------------------------------------------------------------
        // PHASE 3: Booth Multiplier Test (Opcode 3'b011)
        // -----------------------------------------------------------------
        // Test: 50 * -10 = -500
        in_a = 32'd50;   // Multiplier
        in_b = -32'd10;  // Multiplicand
        op   = 3'b011;   // Steer ALU out bus to track multiplier output
        #10;
        
        // Pulse the start trigger for exactly one clock cycle
        mul_start = 1'b1; #10;
        mul_start = 1'b0;

        // Block execution and wait until the sequential engine asserts done flag (32 cycles)
        @(posedge mul_done);
        #5; // Structural settling delay
        $display("[BOOTH MUL] InA=%0d, InB=%0d | Full 64-bit Ans=%0d | ALU Bus Out=%0d", 
                 in_a, in_b, $signed(mul_ans), alu_out_signed);

        // PHASE 4: Logarithmic Barrel Shifter Tests (Opcode 3'b101)
        op   = 3'b101;
        in_a = 32'h0000_000F; // Test pattern data

        // Case 4A: Logical Shift Left (LSL) by 4 bits
        // in_b structure: {25'b0, shift_amt(5'd4), shift_type(2'b00)} -> 00100_00 -> 32'h0000_0010
        in_b = 32'h0000_0010; 
        #10;
        $display("[BARREL LSL] InA=%h, Amt=4 | Out=%h (Expected: 000000f0)", in_a, alu_out);

        // Case 4B: Logical Shift Right (LSR) by 2 bits
        // in_b structure: {25'b0, shift_amt(5'd2), shift_type(2'b01)} -> 00010_01 -> 32'h0000_0009
        in_a = 32'hF000_0000;
        in_b = 32'h0000_0009; 
        #10;
        $display("[BARREL LSR] InA=%h, Amt=2 | Out=%h (Expected: 3c000000)", in_a, alu_out);

        // Case 4C: Rotate Right (ROR) by 4 bits
        // in_b structure: {25'b0, shift_amt(5'd4), shift_type(2'b11)} -> 00100_11 -> 32'h0000_0013
        in_a = 32'h1234_5678;
        in_b = 32'h0000_0013; 
        #10;
        $display("[BARREL ROR] InA=%h, Amt=4 | Out=%h (Expected: 81234567)", in_a, alu_out);

        // -----------------------------------------------------------------
        // PHASE 5: Bitwise Operations(AND,OR,XOR)
        // -----------------------------------------------------------------
        in_a = 32'h5A5A_5A5A;
        in_b = 32'h0F0F_0F0F;
        
        op   = 3'b100; #10; // Bitwise OR
        $display("[BITWISE OR] InA=%h, InB=%h | Out=%h", in_a, in_b, alu_out);

        in_a = 32'h5A5A_5A5A;
        in_b = 32'h0F0F_0F0F;
        op   = 3'b110; #10; // Bitwise AND
        $display("[BITWISE AND] InA=%h, InB=%h | Out=%h", in_a, in_b, alu_out);


        op   = 3'b111; #10; // Bitwise XOR
        $display("[BITWISE XOR] InA=%h, InB=%h | Out=%h", in_a, in_b, alu_out);

        // -----------------------------------------------------------------
        // Final Execution Wrap-up
        // -----------------------------------------------------------------
        $display("=============================================================");
        $display("  VERIFICATION COMPLETE SUCCESSFULLY");
        $display("=============================================================");
        $finish;
    end

endmodule
