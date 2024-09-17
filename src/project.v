/*
 * Copyright (c) 2024 Tommy Thorn
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_tommythorn_tt09_sram (
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

   // sram_latch sram_inst
   // sram_mux sram_inst
   sram_a22o7 sram_inst
     (.wa(ui_in[0]),
      .we(ui_in[1]),
      .wd(ui_in[2]),
      .ra(ui_in[3]),
      .rd(uo_out[0]));

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};
endmodule

module sram_latch12
  (input wire  wa,
   input wire  we,
   input wire  wd,
   input wire  ra,
   output wire rd);

   reg	       mem[1:0];

`ifdef verilator
   always_latch @* if (we) mem[wa] = wd;
`else
   always @* if (we) mem[wa] = wd;
`endif
   assign rd = mem[ra];
endmodule

module sram_mux9
  (input wire  wa,
   input wire  we,
   input wire  wd,
   input wire  ra,
   output wire rd);

   wire	       q0, q1;
   sky130_fd_sc_hd__mux2_1 mux0 (.X(q0), .A0(q0), .A1(wd), .S(we && wa == 0));
   sky130_fd_sc_hd__mux2_1 mux1 (.X(q1), .A0(q1), .A1(wd), .S(we && wa == 1));
   assign rd = ra == 0 ? q0 : q1;
endmodule

module sram_a22o7
  (input wire  wa,
   input wire  we,
   input wire  wd,
   input wire  ra,
   output wire rd);

   wire	       q0, q1;
   sky130_fd_sc_hd__a22o_1 bit0( .X(q0), .A1(q0), .A2(we), .B1(wd), .B2(wa == 0));
   sky130_fd_sc_hd__a22o_1 bit1( .X(q1), .A1(q1), .A2(we), .B1(wd), .B2(wa == 1));
   assign rd = ra == 0 ? q0 : q1;
endmodule

