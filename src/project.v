/*
 * Copyright (c) 2024 Tommy Thorn
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
//`define USE_LATCH 1
`define USE_MUX 1

module tt_um_tommythorn_tt09_sram
  #(parameter N = 4,
    parameter W = 1) (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
   assign uio_out = 0;
   assign uio_oe  = 0;

   wire	[W-1:0]	      rd_w;
   //assign uo_out = rd[7:0] ^ rd[15:8] ^ rd[23:16] ^ rd[31:24];
   assign uo_out = rd[0];

   reg  [N-1:0]	      ra;
   reg  [N-1:0]	      wa;
   reg 		      we;
   reg 	[W-1:0]	      wd;
   reg 	[W-1:0]	      rd;

   always @(posedge clk) begin
      ra <= ui_in[N-1:0];
      wa <= uio_in[N-1:0];
      we <= ui_in[7];
      wd <= {rd[W-9:0], uio_in ^ ui_in};
      rd <= rd_w;
   end



`ifdef USE_LATCH
   sram_latch
`endif

`ifdef USE_MUX
   sram_mux
`endif

`ifdef USE_A22O
   sram_a22o
`endif
     #(.N(N), .W(W)) sram_inst(.wa(wa), .we(we & !clk), .wd(wd), .ra(ra), .rd(rd_w));

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0, ui_in, uio_in};
endmodule

`ifdef USE_LATCH
module sram_latch
  #(parameter N = 0,
    parameter W = 1)
  (input wire  [N-1:0] wa,
   input wire	       we,
   input wire  [W-1:0] wd,
   input wire  [N-1:0] ra,
   output wire [W-1:0] rd);

   reg [W-1:0] mem[(1 << N)-1:0];

`ifdef verilator
   always_latch @* if (we) mem[wa] = wd;
`else
   always @* if (we) mem[wa] = wd;
`endif
   assign rd = mem[ra];
endmodule
`endif

`ifdef USE_MUX
module sram_mux
  #(parameter N = 0,
    parameter W = 1)
  (input wire  [N-1:0] wa,
   input wire	       we,
   input wire  [W-1:0] wd,
   input wire  [N-1:0] ra,
   output wire [W-1:0] rd);

   wire  [W-1:0] q[(1 << N)-1:0];
   genvar      i, j;
   generate
      for (i = 0; i < 1 << N; i = i + 1)
	for (j = 0; j < W; j = j + 1)
	  // Q = we && wa == i ? wd : Q
	  sky130_fd_sc_hd__mux2_1 mux (.X(q[i][j]), .A0(q[i][j]), .A1(wd[j]), .S(we && wa == i));
   endgenerate
   assign rd = q[ra];
endmodule
`endif
