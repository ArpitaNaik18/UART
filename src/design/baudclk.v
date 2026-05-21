module baud #(
    parameter BAUD=9600,
    parameter FACTOR=16,
    parameter XTAL=100_000_000
)(
    input sys_clk,
    input rst,         
    output reg baud_clk
);
   
    localparam integer CLK_DIV=XTAL / (FACTOR*BAUD*2);
    localparam integer CW=$clog2(CLK_DIV);
    reg [CW-1:0] count;
    always @(posedge sys_clk or negedge rst) begin
        if (!rst) begin
            baud_clk <= 1'b0;
            count<= 0;
        end
        else begin
            if (count == CLK_DIV - 1) begin
                count<=0;
                baud_clk<=~baud_clk;
            end
            else
                count<=count + 1;
        end
    end
endmodule
