`timescale 1ns / 1ns

module uart#(parameter N = 8)(
    input              sys_clk,
    input              sys_rst,
    input              xmith,
    input  [N-1:0]     xmit_datah,
    input              uart_rec_datah,
    output             uart_xmit_datah,
    output             xmit_doneh,
    output             rec_readyh,
    output [N-1:0]     rec_datah,
    output             rec_busy,
    output             xmit_active
);
    wire baud_clk;

    baud#(
        .BAUD(9600),
        .FACTOR(16),
        .XTAL(100_000_000)
    ) u_baud (
        .sys_clk (sys_clk),
        .rst(sys_rst),
        .baud_clk(baud_clk)
    );

    uart_tx#(.N(N)) u_tx (
        .sys_clk(sys_clk),
        .rst(sys_rst),
        .baud_clk(baud_clk),
        .xmith (xmith),
        .xmit_datah (xmit_datah),
        .xmit_doneh (xmit_doneh),
        .xmit_active(xmit_active),
        .uart_xmit_dataH(uart_xmit_datah)
    );

    uart_rx#(.N(N)) u_rx (
        .sys_clk(sys_clk),
        .rst(sys_rst),
        .baud_clk (baud_clk),
        .xmith(xmith),
        .uart_rec_datah(uart_rec_datah),
        .rec_dataH(rec_datah),
        .rec_readyH(rec_readyh),
        .rec_busy(rec_busy)
    );
endmodule

