`timescale 1ns / 1ps


module mat_mul #(parameter N = 8)(
    input logic clk,
    input logic rst_n,
    input logic [N-1:0] matA[1:0][1:0],
    input logic [N-1:0] matB[1:0][1:0],
    output logic [2*N-1:0] mat_out[1:0][1:0]
    );
    logic[2*N-1:0] PE_00;
    logic[2*N-1:0] PE_01;
    logic[2*N-1:0] PE_10;
    logic[2*N-1:0] PE_11;
    logic [$clog2(N) - 1:0] cyc;
    //[[PE_00, PE_01]
    // [PE_10, PE_11]]
    always_ff @(posedge clk)begin
    if(!rst_n)begin
    mat_out[0][0] <= '0;
    mat_out[0][1] <= '0;
    mat_out[1][0] <= '0;
    mat_out[1][1] <= '0;
    PE_00 <= '0;
    PE_01 <= '0;
    PE_10 <= '0;
    PE_11 <= '0;
    cyc <= '0;
    
    end else if(cyc == 0) begin
    //CY-1
    PE_00 <= matA[0][0]*matB[0][0];
    cyc <= cyc + 1'b1;
    end
    //CY-2
    else if(cyc == 1) begin
    PE_00 <= PE_00 + (matA[0][1]*matB[1][0]);
    PE_01 <= matA[0][0]*matB[0][1];
    PE_10 <= matA[1][0]*matB[0][0];
    cyc <= cyc + 1'b1;
    end
    //CY-3
    else if(cyc == 2) begin
    PE_01 <= PE_01 + (matA[0][1]*matB[1][1]);
    PE_10 <= PE_10 + (matA[1][1]*matB[1][0]);
    PE_11 <= matA[1][0]*matB[0][1];
    cyc <= cyc + 1'b1;
    end
    //CY-4
    else if(cyc == 3) begin
    PE_11<= PE_11 + (matA[1][1]*matB[1][1]);
    cyc <= cyc + 1'b1;
    end else begin
    mat_out[0][0] <= PE_00;
    mat_out[0][1] <= PE_01;
    mat_out[1][0] <= PE_10;
    mat_out[1][1] <= PE_11;
    end

    end
    
endmodule
