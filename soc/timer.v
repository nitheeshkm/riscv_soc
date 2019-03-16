//-----------------------------------------------------------------
//                        RISC-V Test SoC
//                            V0.1
//                     Ultra-Embedded.com
//                     Copyright 2014-2019
//
//                   admin@ultra-embedded.com
//
//                       License: BSD
//-----------------------------------------------------------------
//
// Copyright (c) 2014-2019, Ultra-Embedded.com
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions 
// are met:
//   - Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//   - Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer 
//     in the documentation and/or other materials provided with the 
//     distribution.
//   - Neither the name of the author nor the names of its contributors 
//     may be used to endorse or promote products derived from this 
//     software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
// SUCH DAMAGE.
//-----------------------------------------------------------------

//-----------------------------------------------------------------
//                          Generated File
//-----------------------------------------------------------------

`include "timer_defs.v"

//-----------------------------------------------------------------
// Module:  System Tick Timer
//-----------------------------------------------------------------
module timer
(
    // Inputs
     input          clk_i
    ,input          rst_i
    ,input          cfg_awvalid_i
    ,input  [31:0]  cfg_awaddr_i
    ,input          cfg_wvalid_i
    ,input  [31:0]  cfg_wdata_i
    ,input  [3:0]   cfg_wstrb_i
    ,input          cfg_bready_i
    ,input          cfg_arvalid_i
    ,input  [31:0]  cfg_araddr_i
    ,input          cfg_rready_i

    // Outputs
    ,output         cfg_awready_o
    ,output         cfg_wready_o
    ,output         cfg_bvalid_o
    ,output [1:0]   cfg_bresp_o
    ,output         cfg_arready_o
    ,output         cfg_rvalid_o
    ,output [31:0]  cfg_rdata_o
    ,output [1:0]   cfg_rresp_o
    ,output         intr_o
);

//-----------------------------------------------------------------
// Retime write data
//-----------------------------------------------------------------
reg [31:0] wr_data_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    wr_data_q <= 32'b0;
else
    wr_data_q <= cfg_wdata_i;

//-----------------------------------------------------------------
// Request Logic
//-----------------------------------------------------------------
wire read_en_w  = cfg_arvalid_i & cfg_arready_o;
wire write_en_w = cfg_awvalid_i & cfg_awready_o;

//-----------------------------------------------------------------
// Accept Logic
//-----------------------------------------------------------------
assign cfg_arready_o = ~cfg_rvalid_o;
assign cfg_awready_o = ~cfg_bvalid_o && ~cfg_arvalid_i; 
assign cfg_wready_o  = cfg_awready_o;


//-----------------------------------------------------------------
// Register timer_ctrl
//-----------------------------------------------------------------
reg timer_ctrl_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    timer_ctrl_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `TIMER_CTRL))
    timer_ctrl_wr_q <= 1'b1;
else
    timer_ctrl_wr_q <= 1'b0;

// timer_ctrl_interrupt [internal]
reg        timer_ctrl_interrupt_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    timer_ctrl_interrupt_q <= 1'd`TIMER_CTRL_INTERRUPT_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `TIMER_CTRL))
    timer_ctrl_interrupt_q <= cfg_wdata_i[`TIMER_CTRL_INTERRUPT_R];

wire        timer_ctrl_interrupt_out_w = timer_ctrl_interrupt_q;


//-----------------------------------------------------------------
// Register timer_cmp
//-----------------------------------------------------------------
reg timer_cmp_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    timer_cmp_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `TIMER_CMP))
    timer_cmp_wr_q <= 1'b1;
else
    timer_cmp_wr_q <= 1'b0;

// timer_cmp_value [internal]
reg [31:0]  timer_cmp_value_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    timer_cmp_value_q <= 32'd`TIMER_CMP_VALUE_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `TIMER_CMP))
    timer_cmp_value_q <= cfg_wdata_i[`TIMER_CMP_VALUE_R];

wire [31:0]  timer_cmp_value_out_w = timer_cmp_value_q;


//-----------------------------------------------------------------
// Register timer_val
//-----------------------------------------------------------------
reg timer_val_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    timer_val_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `TIMER_VAL))
    timer_val_wr_q <= 1'b1;
else
    timer_val_wr_q <= 1'b0;


wire [31:0]  timer_val_current_in_w;


//-----------------------------------------------------------------
// Read mux
//-----------------------------------------------------------------
reg [31:0] data_r;

always @ *
begin
    data_r = 32'b0;

    case (cfg_araddr_i[7:0])

    `TIMER_CTRL:
    begin
        data_r[`TIMER_CTRL_INTERRUPT_R] = timer_ctrl_interrupt_q;
    end
    `TIMER_CMP:
    begin
        data_r[`TIMER_CMP_VALUE_R] = timer_cmp_value_q;
    end
    `TIMER_VAL:
    begin
        data_r[`TIMER_VAL_CURRENT_R] = timer_val_current_in_w;
    end
    default :
        data_r = 32'b0;
    endcase
end

//-----------------------------------------------------------------
// RVALID
//-----------------------------------------------------------------
reg rvalid_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    rvalid_q <= 1'b0;
else if (read_en_w)
    rvalid_q <= 1'b1;
else if (cfg_rready_i)
    rvalid_q <= 1'b0;

assign cfg_rvalid_o = rvalid_q;

//-----------------------------------------------------------------
// Retime read response
//-----------------------------------------------------------------
reg [31:0] rd_data_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    rd_data_q <= 32'b0;
else if (!cfg_rvalid_o || cfg_rready_i)
    rd_data_q <= data_r;

assign cfg_rdata_o = rd_data_q;
assign cfg_rresp_o = 2'b0;

//-----------------------------------------------------------------
// BVALID
//-----------------------------------------------------------------
reg bvalid_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    bvalid_q <= 1'b0;
else if (write_en_w)
    bvalid_q <= 1'b1;
else if (cfg_bready_i)
    bvalid_q <= 1'b0;

assign cfg_bvalid_o = bvalid_q;
assign cfg_bresp_o  = 2'b0;




//-----------------------------------------------------------------
// Timer
//-----------------------------------------------------------------
reg [31:0] timer_value_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    timer_value_q <= 32'b0;
else
    timer_value_q <= timer_value_q + 32'd1;

assign timer_val_current_in_w = timer_value_q;

//-----------------------------------------------------------------
// IRQ output
//-----------------------------------------------------------------
reg intr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    intr_q <= 1'b0;
else if (timer_val_current_in_w == timer_cmp_value_out_w && timer_ctrl_interrupt_out_w)
    intr_q <= 1'b1;
else
    intr_q <= 1'b0;

//-----------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------
assign intr_o = intr_q;



endmodule
