module bmul(
    input clk,
    input rst,
    input start,
    input [31:0] multiplier,
    input [31:0] multiplicand,
    output reg [63:0] ans,
    output reg done
);
    reg [31:0] m_comp;
    reg q;
    reg [5:0] count;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            ans   <= 64'b0;
            m_comp<= 32'b0;
            q     <= 1'b0;
            count <= 6'd0;
            done  <= 1'b0;
        end
        else if(start) begin
            ans   <= {32'b0, multiplier};
            m_comp<= ~multiplicand + 1'b1;
            q     <= 1'b0;
            count <= 6'd32;
            done  <= 1'b0;
        end
        else if(count > 0) begin
            case ({ans[0], q})        
                2'b01: begin 
                    {ans, q} <= $signed({ans[63:32] + multiplicand, ans[31:0], q}) >>> 1;
                end
                2'b10: begin 
                    {ans, q} <= $signed({ans[63:32] + m_comp, ans[31:0], q}) >>> 1;
                end
                default: begin 
                    {ans, q} <= $signed({ans, q}) >>> 1;
                end
            endcase

            count <= count - 1'b1;
            if (count == 6'd1) begin
                done <= 1'b1;
            end
        end
    end
endmodule
