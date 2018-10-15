// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
`timescale 1ns/1ps

/*
*  A helper module which can be used to connect two software controlled
*  source register output(s) into a destination register(s) input.
*  This can be used to create a multiple producer to single consumer scenario.
*  Note: Clock (clk) should be connected to the system clock (AXI Memory Mapped
*  interface clock).
*
*  Constraints: the first input has an exclusive priority over the second one.
*/

module util_dwrite #(

  parameter DATA_WIDTH = 16) (

  input                         clk,
  input                         reset,
  input       [DATA_WIDTH-1:0]  din_a,
  input       [DATA_WIDTH-1:0]  din_b,
  output  reg [DATA_WIDTH-1:0]  dout
);

  reg   [DATA_WIDTH-1:0]  din_a_d = 'd0;
  reg   [DATA_WIDTH-1:0]  din_b_d = 'd0;

  reg   [DATA_WIDTH-1:0]  din_a_xor = 'd0;
  reg   [DATA_WIDTH-1:0]  din_b_xor = 'd0;

  wire  din_a_changed;
  wire  din_b_changed;

  /*
  *  Generate a one clock cycle pulse if one of the input bus was changed
  */

  always @(posedge clk) begin
    din_a_d <= din_a;
    din_b_d <= din_b;
  end

  genvar i;
  generate for (i=0; i<DATA_WIDTH; i=i+1) begin
    always @(posedge clk) begin
      din_a_xor[i]  <= din_a[i] ^ din_a_d[i];
      din_b_xor[i]  <= din_b[i] ^ din_b_d[i];
    end
  end
  endgenerate

  assign  din_a_changed = |din_a_xor;
  assign  din_b_changed = |din_b_xor;

  /*
  *  An intentional latch to always register the bus which changed the
  *  last time. NOTE that the first input has a priority.
  */
  always @(posedge clk) begin
    if (reset) begin
      dout <= {DATA_WIDTH{1'b0}};
    end else begin
      if (din_a_changed)
        dout <= din_a;
      else if (din_b_changed)
        dout <= din_b;
    end
  end

endmodule
