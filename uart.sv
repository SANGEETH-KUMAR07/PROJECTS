`timescale 1ns/1ps 

module uart #(
    parameter wordsize = 8
) (
    input [wordsize-1:0] tx_data,
    input load_xmtdata_reg, byte_ready, t_byte,
    input read_not_ready_in,
    input clk, sclk, reset, enablex,

    output [wordsize-1:0] rx_data,
    output serial_out,
    output error1, error2, read_not_ready_out
);

    wire serial_line;

    assign serial_out = serial_line; // output from UART

    uart_xmt transmitter (
        .serial_out(serial_line),
        .data_in(tx_data),
        .load_xmtdata_reg(load_xmtdata_reg),
        .byte_ready(byte_ready),
        .t_byte(t_byte),
        .clk(clk),
        .reset(reset),
        .enablex(enablex)
    );

    uart_rcv  receiver (
        .data_regr(rx_data),
        .error1(error1),
        .error2(error2),
        .read_not_ready_out(read_not_ready_out),
        .serial_in(serial_line),
        .read_not_ready_in(read_not_ready_in),
        .sclk(sclk),
        .reset(reset)
    );

endmodule