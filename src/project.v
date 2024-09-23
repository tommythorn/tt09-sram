/*
 * Copyright (c) 2024 Tommy Thorn
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`define USE_A22O 1
//`define USE_LATCH 1
//`define USE_MUX 1

module tt_um_tommythorn_tt09_sram
  #(parameter N = 7) (
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

   wire [N-1:0]	      ra = ui_in[N-1:0];
   wire [N-1:0]	      wa = uio_in[N-1:0];
   wire		      we = ui_in[7];
   wire		      wd = uio_in[7];
   wire		      rd;
   assign uo_out[0] = rd;

`ifdef USE_LATCH
   sram_latch #(.N(N)) sram_inst
`endif

`ifdef USE_MUX
   sram_mux #(.N(N)) sram_inst
`endif

`ifdef USE_A22O
   sram_a22o #(.N(N)) sram_inst
`endif
     (.wa(wa), .we(we), .wd(wd), .ra(ra), .rd(rd));

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};
endmodule

module sram_latch
  #(parameter N = 0)
  (input wire [N-1:0] wa,
   input wire	       we,
   input wire	       wd,
   input wire [N-1:0] ra,
   output wire	       rd);

   reg mem[(1 << N)-1:0];

`ifdef verilator
   always_latch @* if (we) mem[wa] = wd;
`else
   always @* if (we) mem[wa] = wd;
`endif
   assign rd = mem[ra];
endmodule

module sram_mux
  #(parameter N = 0)
  (input wire [N-1:0] wa,
   input wire  we,
   input wire  wd,
   input wire [N-1:0] ra,
   output wire rd);

   wire	       q[(1 << N)-1:0];
   genvar      i;
   generate
      for (i = 0; i < 1 << N; i = i + 1)
	sky130_fd_sc_hd__mux2_1 mux (.X(q[i]), .A0(q[i]), .A1(wd), .S(we && wa == i));
   endgenerate
   assign rd = q[ra];
endmodule

module sram_a22o
  #(parameter N = 0)
  (input wire [N-1:0] wa,
   input wire  we,
   input wire  wd,
   input wire [N-1:0] ra,
   output wire rd);

   wire	       q[(1 << N)-1:0];
   genvar      i;
   generate
      for (i = 0; i < 1 << N; i = i + 1)
	sky130_fd_sc_hd__a22o_1 bit_i( .X(q[i]), .A1(q[i]), .A2(we), .B1(wd), .B2(wa == i));
   endgenerate
   assign rd = q[ra];
endmodule

