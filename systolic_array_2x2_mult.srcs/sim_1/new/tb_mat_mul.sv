`timescale 1ns / 1ps
module tb_mat_mul;
parameter int N = 8;
logic clk;
logic rst_n;
logic [N-1:0] matA [1:0][1:0];
logic [N-1:0] matB [1:0][1:0];
logic [2*N-1:0] mat_out [1:0][1:0];

mat_mul #(.N(N)) dut(
.clk(clk),
.rst_n(rst_n),
.matA(matA),
.matB(matB),
.mat_out(mat_out)
);
always #5 clk = ~clk;
initial begin
    clk = 0;
    rst_n = 0;

    // test 1: from your waveform
    matA[0][0] = 8'd4;
    matA[0][1] = 8'd3;
    matA[1][0] = 8'd2;
    matA[1][1] = 8'd1;

    matB[0][0] = 8'd8;
    matB[0][1] = 8'd7;
    matB[1][0] = 8'd6;
    matB[1][1] = 8'd5;

    // expected: C[0][0]=50, C[0][1]=43, C[1][0]=22, C[1][1]=19

    repeat(2) @(posedge clk);
    rst_n = 1;
    repeat(7) @(posedge clk);

    // test 2: identity x identity
    rst_n = 0;
    matA[0][0] = 8'd1; matA[0][1] = 8'd0;
    matA[1][0] = 8'd0; matA[1][1] = 8'd1;

    matB[0][0] = 8'd1; matB[0][1] = 8'd0;
    matB[1][0] = 8'd0; matB[1][1] = 8'd1;

    // expected: C = identity

    repeat(2) @(posedge clk);
    rst_n = 1;
    repeat(7) @(posedge clk);

    // test 3: zero matrix
    rst_n = 0;
    matA[0][0] = 8'd0; matA[0][1] = 8'd0;
    matA[1][0] = 8'd0; matA[1][1] = 8'd0;

    matB[0][0] = 8'd9; matB[0][1] = 8'd3;
    matB[1][0] = 8'd2; matB[1][1] = 8'd7;

    // expected: C = all zeros

    repeat(2) @(posedge clk);
    rst_n = 1;
    repeat(7) @(posedge clk);

    // test 4: larger values
    rst_n = 0;
    matA[0][0] = 8'd15; matA[0][1] = 8'd10;
    matA[1][0] = 8'd12; matA[1][1] = 8'd8;

    matB[0][0] = 8'd20; matB[0][1] = 8'd15;
    matB[1][0] = 8'd5;  matB[1][1] = 8'd25;

    // expected: C[0][0]=350, C[0][1]=475, C[1][0]=280, C[1][1]=380

    repeat(2) @(posedge clk);
    rst_n = 1;
    repeat(7) @(posedge clk);

    $finish;
end
endmodule