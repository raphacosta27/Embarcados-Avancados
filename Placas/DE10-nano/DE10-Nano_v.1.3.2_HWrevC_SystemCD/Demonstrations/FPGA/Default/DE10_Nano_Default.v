
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module DE10_Nano_Default(

	//////////// ADC //////////
	output		          		ADC_CONVST,
	output		          		ADC_SCK,
	output		          		ADC_SDI,
	input 		          		ADC_SDO,

	//////////// ARDUINO //////////
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,

	//////////// CLOCK //////////
	input 		          		FPGA_CLK1_50,
	input 		          		FPGA_CLK2_50,
	input 		          		FPGA_CLK3_50,

	//////////// HDMI //////////
	inout 		          		HDMI_I2C_SCL,
	inout 		          		HDMI_I2C_SDA,
	inout 		          		HDMI_I2S,
	inout 		          		HDMI_LRCLK,
	inout 		          		HDMI_MCLK,
	inout 		          		HDMI_SCLK,
	output		          		HDMI_TX_CLK,
	output		          		HDMI_TX_DE,
	output		    [23:0]		HDMI_TX_D,
	output		          		HDMI_TX_HS,
	input 		          		HDMI_TX_INT,
	output		          		HDMI_TX_VS,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [7:0]		LED,

	//////////// SW //////////
	input 		     [3:0]		SW
);




//=======================================================
//  REG/WIRE declarations
//=======================================================
reg  [31:0]	Cont;

//hdmi
wire [7:0] hdmi_b;
wire [7:0] hdmi_g;
wire [7:0] hdmi_r;
wire       disp_clk;
wire       disp_de;
wire       disp_hs;
wire       disp_vs;
wire       DLY_RST;

//=======================================================
//  Structural coding
//=======================================================
assign GPIO_0  		=	36'hzzzzzzzz;
assign GPIO_1  		=	36'hzzzzzzzz;

always@(posedge FPGA_CLK1_50 or negedge KEY[0])
    begin
        if(!KEY[0])
			 Cont	<=	0;
        else
			 Cont	<=	Cont+1;
    end
	 
assign	LED =	KEY[0]? {Cont[25:24],Cont[25:24],Cont[25:24],
                             Cont[25:24],Cont[25:24]}:10'h3ff;
									  
									  
//	Reset Delay Timer
Reset_Delay			r0	(	
							 .iCLK(FPGA_CLK1_50),
							 .oRESET(DLY_RST));									  

//=======================================================
//  Structural coding
//=======================================================

assign reset_n = 1'b1;
sys_pll u_sys_pll (
   .refclk(FPGA_CLK1_50),
	.rst(1'b0),
	.outclk_0(pll_1536k),
	.outclk_1(disp_clk)
	);
	
//HDMI I2C	
I2C_HDMI_Config u_I2C_HDMI_Config (
	.iCLK(FPGA_CLK1_50),
	.iRST_N(reset_n),
	.I2C_SCLK(HDMI_I2C_SCL),
	.I2C_SDAT(HDMI_I2C_SDA),
	.HDMI_TX_INT(HDMI_TX_INT)
	);


vga_controller hdmi_ins(.iRST_n(DLY_RST),
                      .iVGA_CLK(disp_clk),
                      .oBLANK_n(disp_de),
                      .oHS(disp_hs),
                      .oVS(disp_vs),
                      .b_data(hdmi_b),
                      .g_data(hdmi_g),
                      .r_data(hdmi_r));	
							 
							 
assign HDMI_TX_CLK	= disp_clk;
assign HDMI_TX_D		= {hdmi_r,hdmi_g,hdmi_b};
assign HDMI_TX_DE		= disp_de;
assign HDMI_TX_HS		= disp_hs;
assign HDMI_TX_VS		= disp_vs;
	
	
AUDIO_IF u_AVG(
	.clk(!KEY[0]&pll_1536k),
	.reset_n(reset_n),
	.sclk(HDMI_SCLK),
	.lrclk(HDMI_LRCLK),
	.i2s(HDMI_I2S)
);


endmodule