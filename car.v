`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:13:47 11/28/2016 
// Design Name: 
// Module Name:    car 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
module car(
	input						clk,
	input						rst_n,
	input						on_off,
	//input						type,
	//input						move,
	input						pause,
	input						spe,
	input						left,
	input						right,
	input						ena,
	
	output	reg	[7:0]	sco_data,
	output	reg	[3:0]	sel,
	output	reg	[7:0]	lled,
	output	reg			beep,
	output	reg			c_oe,
	output	reg			c_clk,
	output	reg 			c_st,
	output	reg 			c_data,
	output	reg	[3:0]	c_addr
	);
//reg	enable=0;
//reg	lled;
reg	[1:0]		state;
reg	[5:0]		count;
reg	[24:0]	row_count;
reg	[15:0]	t_data;//=16'b1010_1111_0011_1111;	

parameter	route=2192'h8001_0000_8001_0000_8001_0000_8001_0000_8001_0000_A005_1008_8811_0810_8001_0000_8001_0000_8001_7C00_8001_0000_8001_0000_8001_03FC_8001_0000_8081_0040_8021_0000_8001_0000_8001_0000_F801_0400_8201_000E_8011_0020_8001_0000_8001_383E_8001_0000_8001_0000_FE01_0000_8001_0000_E01F_0020_8041_0080_8101_0000_8001_0000_8001_0000_F801_0400_8201_0100_800F_0000_8001_0000_FC01_001E_8001_0000_8001_0000_E07F_0000_8001_0000_8001_0000_FF07_2400_9801_1800_FE01_2400_8001_0000_F001_0800_8C01_0600_8301_0180_8001_0000_8007_000C_8001_0000_81FF_0040_8041_0040_8151_00A0_8041_0000_8001_0000_8001_0400_8A01_1500_8401_0400_FF01_0000_8001_0000_8001_0000_8001_0000_F0FF_2082_A045_2028_A011_0000_8001_0000_8001_0000;
reg	[2191:0]	ROM_DATA=route;
reg	[2191:0]	ROM_TEM;
reg	[255:0]	rom_data=~256'd0;
reg	[30:0]	rom_cnt=31'd0;
reg	[30:0]	MAX_CNT;
reg	[30:0]	cur_cnt;
//reg	[3:0]		rom_mov;
reg	[3:0]		mov_state;
reg	[3:0]		meu_state;
reg	[1:0]		voc_state;
reg	[1:0]		set_state;
reg				crash;
reg	[30:0]	cra_cnt;
reg	[4:0]		cra_num=5'd0;
reg	[511:0]	cra_data;

reg	[15:0]	wei_data;	//数码管每一位的大小
reg	[31:0]	shu_data;	//数码管数据,4位编码
reg				cnt_en;		//得分信号
reg	[24:0]	sel_cnt;		//数码管扫描
reg	[1:0]		sel_state;
reg				shu_rst;
//assign c_clk=clk;

always@(posedge clk or posedge rst_n)
begin
	if(rst_n)
	begin
		count=6'd0;
		t_data=rom_data[255:240];//16'b1111_1111_1111_1111;
		state=2'b00;
		c_clk=0;
		c_st=0;
		row_count=25'd0;
	end
	else
	begin
	case(state)
	2'b00:begin
			c_data=t_data[15];
			c_clk=1;
			state=2'b01;
			end
	2'b01:begin
			c_clk=0;
			t_data=t_data<<1;
			count=count+6'd1;
			if(count==6'd17)
			begin
				c_st=1;
				state=2'b10;
			end
			else
				state=2'b00;
			end
	2'b10:begin
	if(row_count<25'd24_999)
		row_count=row_count+25'd1;
	else
	begin
	case(c_addr)
	4'b0000:		begin
					t_data=rom_data[239:224];//16'b1111_1111_1111_1111;
					c_addr=4'b0001;
					end
	4'b0001:		begin
					t_data=rom_data[223:208];//16'b1111_1111_1111_1111;
					c_addr=4'b0010;
					end
	4'b0010:		begin
					t_data=rom_data[207:192];//16'b1110_0011_1100_0111;
					c_addr=4'b0011;
					end
	4'b0011:		begin
					t_data=rom_data[191:176];//16'b1100_0011_1100_0011;
					c_addr=4'b0100;
					end
	4'b0100:		begin
					t_data=rom_data[175:160];//16'b1000_0000_0000_0001;
					c_addr=4'b0101;
					end
	4'b0101:		begin
					t_data=rom_data[159:144];//16'b1000_0000_0000_0001;
					c_addr=4'b0110;
					end
	4'b0110:		begin
					t_data=rom_data[143:128];//16'b1000_0000_0000_0001;
					c_addr=4'b0111;
					end
	4'b0111:		begin
					t_data=rom_data[127:112];//16'b1100_0000_0000_0011;
					c_addr=4'b1000;
					end
	4'b1000:		begin
					t_data=rom_data[111:96];//16'b1110_0000_0000_0111;
					c_addr=4'b1001;
					end
	4'b1001:		begin
					t_data=rom_data[95:80];//16'b1111_0000_0000_1111;
					c_addr=4'b1010;
					end
	4'b1010:		begin
					t_data=rom_data[79:64];//16'b1111_1000_0001_1111;
					c_addr=4'b1011;
					end
	4'b1011:		begin
					t_data=rom_data[63:48];//16'b1111_1100_0011_1111;
					c_addr=4'b1100;
					end
	4'b1100:		begin
					t_data=rom_data[47:32];//16'b1111_1110_0111_1111;
					c_addr=4'b1101;
					end
	4'b1101:		begin
					t_data=rom_data[31:16];//16'b1111_1111_1111_1111;
					c_addr=4'b1110;
					end
	4'b1110:		begin
					t_data=rom_data[15:0];//16'b1111_1111_1111_1111;
					c_addr=4'b1111;
					end
	4'b1111:		begin
					t_data=rom_data[255:240];//16'b1111_1111_1111_1111;
					c_addr=4'b0000;
					end
	default:		begin
					t_data=16'b1111_1111_1111_1111;
					c_addr=4'b000;
					end
	endcase
					c_st=0;
					state=2'b00;
					c_clk=0;
					count=6'd0;
					row_count=25'd0;
	end
	end
	default:;
	endcase
	end
end

//去抖动模块

reg	op1;
reg	op2;
reg	op3;
reg [21:0]cnt1=0;//计数10000时经过10ms
reg [21:0]cnt2=0;//计数10000时经过10ms
reg [21:0]cnt3=0;//计数10000时经过10ms
always@(posedge clk or posedge rst_n)
begin 
	if(rst_n)
		cnt1<=0;
	else if(right==1)
		if(cnt1==22'd1_600_000)
		cnt1<=cnt1;
		else
		cnt1<=cnt1+13'd1;
	else
		cnt1<=0;
end

always@(posedge clk or posedge rst_n)
begin 
	if(rst_n)
		cnt2<=0;
	else if(left==1)
		if(cnt2==22'd1_600_000)
		cnt2<=cnt2;
		else
		cnt2<=cnt2+13'd1;
	else
		cnt2<=0;
end

always@(posedge clk or posedge rst_n)
begin 
	if(rst_n)
		cnt3<=0;
	else if(ena==1)
		if(cnt3==22'd1_600_000)
		cnt3<=cnt3;
		else
		cnt3<=cnt3+13'd1;
	else
		cnt3<=0;
end

always@(posedge clk or posedge rst_n)
begin
	if(rst_n)
		op2<=0;
	else
		if(cnt2==22'd1_000_000)
		op2<=1;
		else
		op2<=0;
end


always@(posedge clk or posedge rst_n)
begin
	if(rst_n)
		op1<=0;
	else
		if(cnt1==22'd1_000_000)
		op1<=1;
		else
		op1<=0;
end

always@(posedge clk or posedge rst_n)
begin
	if(rst_n)
		op3<=0;
	else
		if(cnt3==22'd1_000_000)
		op3<=1;
		else
		op3<=0;
end
	
//刷新屏幕,显示界面中心 
always@(posedge clk or posedge rst_n)
begin
	if(rst_n)
		begin
		crash=0;
		ROM_DATA=route;
		rom_data=~ROM_DATA[2191:1936];//256'hFFFF_0000_0000_0000_0000_000F_0000_0000_0000_000F_0000_0000_0000_0000_0000_FFFF;
		cra_data[255:0]=256'h223E_1202_0A02_1E3E_2202_2202_1E3E_0000_081C_1422_2222_2222_2222_2222_221C_0000;
		MAX_CNT=31'd20_000_000;
		rom_cnt=31'd0;
		cra_cnt=31'd0;
		cra_num=5'd0;
		cnt_en=0;
		end
	else
	case(meu_state)
	4'b0000:	rom_data=~256'h0000_0000_0180_03C0_07E0_0FF0_1FF8_3FFC_7FFE_7FFE_7FFE_3C3C_1C38_0000_0000_0000;	//心形，0待机
	4'b0001:	rom_data=~256'h0000_07E0_0810_581A_BFFD_BFFD_581A_1818_1818_581A_BFFD_BFFD_581A_0810_07E0_0000;	//车形，1开始
	4'b0010:	rom_data=~256'h0000_0100_0380_07C0_0FE0_1C70_1930_0380_07C0_0FE0_1C70_3838_3018_0000_0000_0000;	//设置，2设置
	4'b0011:	rom_data=~256'h0000_0100_0180_01C0_09E0_11FE_25FF_49FF_49FF_49FF_25FF_11FE_09E0_01C0_0180_0100;	//音量，3设置音量			
	4'b0100:	begin
		if(~pause)
		begin
		if(spe)
		cur_cnt=MAX_CNT/2;
		else
		cur_cnt=MAX_CNT;
		if(rom_cnt>cur_cnt)//MAX_CNT
			begin
				ROM_TEM=ROM_DATA>>1936;
				ROM_DATA=ROM_DATA<<16;
				ROM_DATA=ROM_DATA|ROM_TEM;
				cnt_en=1;
				//rom_data=~ROM_DATA[511:256];
				rom_cnt=31'd0;
			end
		else
		begin
		cnt_en=0;
		rom_cnt=rom_cnt+31'd1;
		end
		end
		rom_data=~ROM_DATA[2191:1936];
		
		case(mov_state)
		4'b0001:begin
				  if(rom_data[195:193]<3'd7)
					crash=1;
				  rom_data[243:241]=3'b010;
				  rom_data[227:225]=3'b101;
				  rom_data[211:209]=3'b101;
				  rom_data[195:193]=3'b010;
				  end
		4'b0010:begin
				  if(rom_data[196:194]<3'd7)
					crash=1;
				  rom_data[244:242]=3'b010;
				  rom_data[228:226]=3'b101;
				  rom_data[212:210]=3'b101;
				  rom_data[196:194]=3'b010;
				  end
		4'b0011:begin
				  if(rom_data[197:195]<3'd7)
					crash=1;
				  rom_data[245:243]=3'b010;
				  rom_data[229:227]=3'b101;
				  rom_data[213:211]=3'b101;
				  rom_data[197:195]=3'b010;
				  end
		4'b0100:begin
				  if(rom_data[198:196]<3'd7)
					crash=1;
				  rom_data[246:244]=3'b010;
				  rom_data[230:228]=3'b101;
				  rom_data[214:212]=3'b101;
				  rom_data[198:196]=3'b010;
				  end
		4'b0101:begin
				  if(rom_data[199:197]<3'd7)
				  crash=1;
				  rom_data[247:245]=3'b010;
				  rom_data[231:229]=3'b101;
				  rom_data[215:213]=3'b101;
				  rom_data[199:197]=3'b010;
				  end
		4'b0110:begin
				  if(rom_data[200:198]<3'd7)
				  crash=1;
				  rom_data[248:246]=3'b010;
				  rom_data[232:230]=3'b101;
				  rom_data[216:214]=3'b101;
				  rom_data[200:198]=3'b010;
				  end
		4'b0111:begin
				  if(rom_data[201:199]<3'd7)
				  crash=1;
				  rom_data[249:247]=3'b010;
				  rom_data[233:231]=3'b101;
				  rom_data[217:215]=3'b101;
				  rom_data[201:199]=3'b010;
				  end
		4'b1000:begin
				  if(rom_data[202:200]<3'd7)
				  crash=1;
				  rom_data[250:248]=3'b010;
				  rom_data[234:232]=3'b101;
				  rom_data[218:216]=3'b101;
				  rom_data[202:200]=3'b010;
				  end
		4'b1001:begin
				  if(rom_data[203:201]<3'd7)
				  crash=1;
				  rom_data[251:249]=3'b010;
				  rom_data[235:233]=3'b101;
				  rom_data[219:217]=3'b101;
				  rom_data[203:201]=3'b010;
				  end
		4'b1010:begin
				  if(rom_data[204:202]<3'd7)
				  crash=1;
				  rom_data[252:250]=3'b010;
				  rom_data[236:234]=3'b101;
				  rom_data[220:218]=3'b101;
				  rom_data[204:202]=3'b010;
				  end
		4'b1011:begin
				  if(rom_data[205:203]<3'd7)
				  crash=1;
				  rom_data[253:251]=3'b010;
				  rom_data[237:235]=3'b101;
				  rom_data[221:219]=3'b101;
				  rom_data[205:203]=3'b010;
				  end
		4'b1100:begin
				  if(rom_data[206:204]<3'd7)
				  crash=1;
				  rom_data[254:252]=3'b010;
				  rom_data[238:236]=3'b101;
				  rom_data[222:220]=3'b101;
				  rom_data[206:204]=3'b010;
				  end
		default:;
		endcase	
		cra_data[511:256]=~rom_data;
		end
		
		4'b0101:
			case(set_state)
			2'b00:begin
					MAX_CNT=31'd37_500_000;
					rom_data=~256'h0000_0000_0028_0020_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;	//速度慢
					end
			2'b01:begin
					MAX_CNT=31'd20_000_000;
					rom_data=~256'h0000_0000_02A8_02A0_02A0_0280_0280_0200_0200_0000_0000_0000_0000_0000_0000_0000;	//速度中
					end
			2'b10:begin
					MAX_CNT=31'd12_500_000;
					rom_data=~256'h0000_0000_2AA8_2AA0_2AA0_2A80_2A80_2A00_2A00_2800_2800_2000_2000_0000_0000_0000;	//速度快
					end
			default:	;
			endcase
		4'b0110:
			case(voc_state)
			2'b00:	rom_data=~256'h0000_0000_0028_0020_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;	//音量低
			2'b01:	rom_data=~256'h0000_0000_02A8_02A0_02A0_0280_0280_0200_0200_0000_0000_0000_0000_0000_0000_0000;	//音量中
			2'b10:	rom_data=~256'h0000_0000_2AA8_2AA0_2AA0_2A80_2A80_2A00_2A00_2800_2800_2000_2000_0000_0000_0000;	//音量高
			default:	;
			endcase
		4'b0111:begin
				  if(cra_num==5'd0)
				  begin
					if(cra_cnt<31'd37_500_000)
					cra_cnt=cra_cnt+31'd1;
					else	begin
					cra_num=5'd1;
					cra_cnt=31'd0;
					end
				  end
				  else
				  begin
				  if(cra_cnt==31'd12_500_000)
						begin
						if(cra_num<5'd17)
						begin
						cra_data=cra_data<<16;
						cra_num=cra_num+5'd1;
						end
						cra_cnt=31'd0;
						end
				  else
						cra_cnt=cra_cnt+31'd1;
				  end
				  rom_data=~cra_data[511:256];
				  
				  if(op3)
				  begin
				  crash=0;				///正常运行
				  cra_num=5'd0;
				  cra_data[255:0]=256'h223E_1202_0A02_1E3E_2202_2202_1E3E_0000_081C_1422_2222_2222_2222_2222_221C_0000;
				  ROM_DATA=route;
				  end
				  end
		default:;
		endcase				  						  
end		

//状态机，left，right，ena控制

always@(posedge clk or posedge rst_n)
begin
	if(rst_n)
	begin
		meu_state=4'b0000;
		voc_state=2'b01;
		set_state=2'b01;
		mov_state=4'd1;
		shu_rst=0;
	end
	else
	begin
		case(meu_state)
		4'b0000:begin
				  if(op1)	meu_state=4'b0011;
				  if(op2)	meu_state=4'b0001;
				  end
		4'b0001:begin
				  shu_rst=0;
				  if(op1)	meu_state=4'b0000;
				  if(op2)	meu_state=4'b0010;
				  if(op3)	meu_state=4'b0100;
				  end
		4'b0010:begin
				  if(op1)	meu_state=4'b0001;
				  if(op2)	meu_state=4'b0011;
				  if(op3)	meu_state=4'b0101;
				  end
		4'b0011:begin
				  if(op1)	meu_state=4'b0010;
				  if(op2)	meu_state=4'b0000;
				  if(op3)	meu_state=4'b0110;
				  end
		4'b0100:begin
				  if(op1)
				  if(mov_state<4'd12)
						mov_state=mov_state+4'd1;
				  if(op2)
				  if(mov_state>4'd1)
						mov_state=mov_state-4'd1;
				  if(op3)	
						meu_state=4'b0001;
				  if(crash)
						meu_state=4'b0111;
				  end
		
		4'b0101:begin
				  case(set_state)
				  2'b00:begin
						  if(op1)	set_state=2'b00;
						  if(op2)	set_state=2'b01;
						  end
					2'b01:begin
						  if(op1)	set_state=2'b00;
						  if(op2)	set_state=2'b10;
						  end
					2'b10:begin
						  if(op1)	set_state=2'b01;
						  if(op2)	set_state=2'b10;
						  end
					default:;
					endcase
					if(op3)			meu_state=4'b010;
					end
		4'b0110:begin
				  case(voc_state)
				  2'b00:begin
						  if(op1)	voc_state=2'b00;
						  if(op2)	voc_state=2'b01;
						  end
					2'b01:begin
						  if(op1)	voc_state=2'b00;
						  if(op2)	voc_state=2'b10;
						  end
					2'b10:begin
						  if(op1)	voc_state=2'b01;
						  if(op2)	voc_state=2'b10;
						  end
					default:;
					endcase
					if(op3)			meu_state=4'b011;
					end
		4'b0111:
				  if(op3)
				  begin
					shu_rst=1;
					meu_state=4'b0001;		  
				  end
		default:;
		endcase
		end
end

//蜂鸣器模块
parameter	clk_divider1=95567;//47774;//
parameter	clk_divider2=85120;//42568;//
parameter	clk_divider3=75849;//37922;//
parameter	clk_divider4=71592;//35794;//
parameter	clk_divider5=63775;//31888;//
parameter	clk_divider6=56818;//28409;//
parameter	clk_divider7=50617;
reg	[24:0]	div_cnt;
reg	[16:0]	delay_cnt;
reg	[16:0]	delay_half;
reg	[16:0]	delay_end;
reg	[1:0]		beep_state;
reg	[3:0]		ring_state=4'b0000;
reg				beep_ring;



always@(posedge clk or posedge rst_n)
begin
	if(rst_n)
		div_cnt=25'd0;
	else
		if(div_cnt==25'd12_500_000)
			div_cnt=25'd0;
		else
		div_cnt=div_cnt+1'b1;
end


always@(posedge clk or posedge rst_n)
begin
	if(rst_n)
		beep_state=2'b00;
	else
	begin
		if(left||right)
			beep_state=2'b01;
		else if(ena)
			beep_state=2'b10;
		else if(crash)
			beep_state=2'b11;
		else	
			beep_state=2'b00;			
	end
end

always@(posedge clk)
begin
	case(beep_state)
	2'b00:begin
			beep_ring=0;
			end
	2'b01:begin
			delay_end=clk_divider1;
			beep_ring=1;
			end
	2'b10:begin
			delay_end=clk_divider7;
			beep_ring=1;
			end
	2'b11:begin
			if(div_cnt==25'd12_500_000)
			case(ring_state)
			4'b0000:begin
						delay_end=clk_divider5;
						ring_state=4'b0001;
						end
			4'b0001:begin
						delay_end=clk_divider4;
						ring_state=4'b0010;
						end
			4'b0010:begin
						delay_end=56818;//clk_divider6;
						ring_state=4'b0011;
						end
			4'b0011:begin
						delay_end=50617;//clk_divider7;
						ring_state=4'b0100;
						end
			4'b0100:begin
						delay_end=clk_divider3;
						ring_state=4'b0101;
						end
			4'b0101:begin
						delay_end=clk_divider2;
						ring_state=4'b0110;
						end
			4'b0110:begin
						delay_end=71592;//clk_divider4;
						ring_state=4'b0111;
						end
			4'b0111:begin
						delay_end=63775;//clk_divider5;
						ring_state=4'b1000;
						end
			4'b1000:begin
						delay_end=clk_divider2;
						ring_state=4'b1001;
						end
			4'b1001:begin
						delay_end=clk_divider1;
						ring_state=4'b1010;
						end
			4'b1010:begin
						delay_end=75849;//clk_divider3;
						ring_state=4'b1011;
						end
			4'b1011:begin
						delay_end=63775;//clk_divider5;
						ring_state=4'b1100;
						end
			4'b1100:begin
						delay_end=clk_divider1;
						ring_state=4'b1101;
						end
			default:ring_state=4'b0000;
			endcase
			beep_ring=1;
			end
	default:;
	endcase
end
		
always@(posedge clk or posedge rst_n)
begin
	if(rst_n)
		delay_cnt=17'd0;
	else 
	begin
	   if(delay_cnt==delay_end)
			delay_cnt=17'd0;
	   else 
			delay_cnt=delay_cnt+1'b1;	
	end
end



always@(posedge  clk or posedge rst_n)
begin
	if(rst_n)
		beep<=1'b0;
	else if(beep_ring)
	begin
		delay_half=delay_end/2;
		if(~voc_state[1])
		begin
			delay_half=delay_half/2;
			delay_half=delay_half/2;
			delay_half=delay_half/2;
			delay_half=delay_half/2;
			delay_half=delay_half/2;
			delay_half=delay_half/2;
			if(~voc_state[0])
			begin
				delay_half=delay_half/2;
				delay_half=delay_half/2;
				delay_half=delay_half/2;
			end
		end
		if(delay_cnt<delay_half)
			beep<=1'b1;
		else
			beep<=1'b0;
	end
end 



//数码管模块
always@(posedge clk or posedge rst_n)
begin
	if(shu_rst)
	wei_data=16'd0;
   if(rst_n)
	wei_data=16'd0;
	else if(cnt_en)
	begin
	    if(wei_data==16'h9999)
			wei_data=16'd0;
		 else 
		 begin
				if(wei_data[3:0]==4'd9)
					begin
						wei_data[3:0]=4'd0;	
						if(wei_data[7:4]==4'd9)
						begin
							wei_data[7:4]=4'd0;
							if(wei_data[11:8]==4'd9)
								begin
									wei_data[15:12]=wei_data[15:12]+4'd1;
									wei_data[11:8]=4'd0;
								end
							else
								wei_data[11:8]=wei_data[11:8]+4'd1;
						end
						else				
							wei_data[7:4]=wei_data[7:4]+4'd1;
					end
				else
					wei_data[3:0]=wei_data[3:0]+4'h1;
		end
	end
end

always@(*)
begin
	case(wei_data[3:0])
		4'h0:   shu_data[7:0] = 8'b0000_0011;
		4'h1:   shu_data[7:0] = 8'b1001_1111;
		4'h2:   shu_data[7:0] = 8'b0010_0101;
		4'h3:   shu_data[7:0] = 8'b0000_1101;
		4'h4:   shu_data[7:0] = 8'b1001_1001;
		4'h5:   shu_data[7:0] = 8'b0100_1001;
		4'h6:   shu_data[7:0] = 8'b0100_0001;
		4'h7:   shu_data[7:0] = 8'b0001_1111;
		4'h8:   shu_data[7:0] = 8'b0000_0001;
		4'h9:   shu_data[7:0] = 8'b0000_1001;
		default:shu_data[7:0] = 8'b1111_1111;
	endcase
	case(wei_data[7:4])
		4'h0:   shu_data[15:8] = 8'b0000_0011;
		4'h1:   shu_data[15:8] = 8'b1001_1111;
		4'h2:   shu_data[15:8] = 8'b0010_0101;
		4'h3:   shu_data[15:8] = 8'b0000_1101;
		4'h4:   shu_data[15:8] = 8'b1001_1001;
		4'h5:   shu_data[15:8] = 8'b0100_1001;
		4'h6:   shu_data[15:8] = 8'b0100_0001;
		4'h7:   shu_data[15:8] = 8'b0001_1111;
		4'h8:   shu_data[15:8] = 8'b0000_0001;
		4'h9:   shu_data[15:8] = 8'b0000_1001;
		default:shu_data[15:8] = 8'b1111_1111;
	endcase
	case(wei_data[11:8])
		4'h0:   shu_data[23:16] = 8'b0000_0011;
		4'h1:   shu_data[23:16] = 8'b1001_1111;
		4'h2:   shu_data[23:16] = 8'b0010_0101;
		4'h3:   shu_data[23:16] = 8'b0000_1101;
		4'h4:   shu_data[23:16] = 8'b1001_1001;
		4'h5:   shu_data[23:16] = 8'b0100_1001;
		4'h6:   shu_data[23:16] = 8'b0100_0001;
		4'h7:   shu_data[23:16] = 8'b0001_1111;
		4'h8:   shu_data[23:16] = 8'b0000_0001;
		4'h9:   shu_data[23:16] = 8'b0000_1001;
		default:shu_data[23:16] = 8'b1111_1111;
	endcase
	case(wei_data[15:12])
		4'h0:   shu_data[31:24] = 8'b0000_0011;
		4'h1:   shu_data[31:24] = 8'b1001_1111;
		4'h2:   shu_data[31:24] = 8'b0010_0101;
		4'h3:   shu_data[31:24] = 8'b0000_1101;
		4'h4:   shu_data[31:24] = 8'b1001_1001;
		4'h5:   shu_data[31:24] = 8'b0100_1001;
		4'h6:   shu_data[31:24] = 8'b0100_0001;
		4'h7:   shu_data[31:24] = 8'b0001_1111;
		4'h8:   shu_data[31:24] = 8'b0000_0001;
		4'h9:   shu_data[31:24] = 8'b0000_1001;
		default:shu_data[31:24] = 8'b1111_1111;
	endcase
end

always@(posedge clk or posedge rst_n)
begin
	if(rst_n)
	sel_state=2'b00;
	else
	begin
		if(sel_cnt==25'd49_999)
		begin
			case(sel_state)
			2'b00:begin
					sel=4'b1110;
					sco_data=shu_data[7:0];
					sel_state=2'b01;
					end
			2'b01:begin
					sel=4'b1101;
					sco_data=shu_data[15:8];
					sel_state=2'b10;
					end
			2'b10:begin
					sel=4'b1011;
					sco_data=shu_data[23:16];
					sel_state=2'b11;
					end
			2'b11:begin
					sel=4'b0111;
					sco_data=shu_data[31:24];
					sel_state=2'b00;
					end
			default:;
			endcase
			sel_cnt=25'h0;
		end
		else
			sel_cnt=sel_cnt+25'd1;
	end	
end

//开关显示控制模块
always@(*)
begin
	if(~on_off)
	begin
		c_oe=1;
		lled[7:4]=4'b0000;
		lled[3:0]=meu_state;
	end
	else begin
		c_oe=0;
		lled[7:4]=4'b0000;
		lled[3:0]=meu_state;
	end
end
		
endmodule 