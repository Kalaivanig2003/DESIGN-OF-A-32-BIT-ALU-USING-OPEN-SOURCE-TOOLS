module alu_32_bit(
    output reg signed [31:0] alu_out,
    output reg [32:0]        temp,
    output reg               zero,
    output reg               carry,
    output reg               overflow,
    output reg               difference,
    output wire [63:0]       mul_ans,    
    output wire              mul_done,   
    input signed [31:0]      in_a,
    input signed [31:0]      in_b,
    input [2:0]              op,
    input                    clk,
    input                    rst,        
    input                    mul_start 
);

  // Internal routing wires to intercept module outputs
  wire [63:0] booth_out;
  wire [31:0] barrel_out;
   
  assign mul_ans = booth_out;

  // Instantiation of Booth Multiplier module
  bmul booth_inst (
      .clk(clk),
      .rst(rst),
      .start(mul_start),
      .multiplier(in_a),
      .multiplicand(in_b),
      .ans(booth_out),
      .done(mul_done)
  );

  // Instantiation of Logarithmic Barrel Shifter module
  // in_b[6:2] extracts the 5-bit shift amount (0 to 31)
  // in_b[1:0] extracts the 2-bit shift type (LSL, LSR, ASR, ROR)
  barrel_shifter_32bit barrel_inst (
      .data_in(in_a),
      .shift_amt(in_b[6:2]),
      .shift_type(in_b[1:0]),
      .data_out(barrel_out)
  );

  
  // 2. BUS ROUTING AND ALU OPERATION SELECT

  always @(*) begin
    // Reset defaults to prevent hardware latches
    temp       = 33'b0;
    carry      = 1'b0;
    difference = 1'b0;
    overflow   = 1'b0;
    
    case(op)
      3'b000: alu_out = 32'b0;
      
      // Addition
      3'b001: begin
        temp    = in_a + in_b;
        alu_out = temp[31:0];
        carry   = temp[32];
        overflow = (in_a[31] == in_b[31]) && (alu_out[31] != in_a[31]);
      end
      
      // Subtraction
      3'b010: begin
        temp    = in_a - in_b;
        alu_out = temp[31:0];
        difference = temp[32];
        overflow = (in_a[31] != in_b[31]) && (alu_out[31] != in_a[31]);
      end
      
      // Booth Multiplier Sub-Module Connection
      3'b011: alu_out = booth_out[31:0]; 
      
      // Bitwise OR 
      3'b100: alu_out = in_a | in_b;   
      
      // Barrel Shifter Sub-Module Connection (Replaces old XOR)
      3'b101: alu_out = barrel_out;    
      
      // Fixed 1-bit shifts
      3'b110: alu_out = in_a&in_b;     // Bitwise AND
      3'b111: alu_out = in_a^in_b;     // Bitwise XOR
      default: alu_out = 32'b1;         
    endcase
    
    // Status flag generation
    zero = (alu_out == 32'b0);
  end
endmodule
