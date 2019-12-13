// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.11.1.441.0
// Netlist written on Fri Dec 13 13:30:16 2019
//
// Verilog Description of module root
//

module root (leds, switches, extclk, extrst, uart0_rxd, uart0_txd);   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(11[8:12])
    output [7:0]leds;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    input [3:0]switches;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(14[3:11])
    input extclk;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(15[3:9])
    input extrst;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(16[3:9])
    input uart0_rxd;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(17[3:12])
    output uart0_txd;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(18[3:12])
    
    wire extclk_c /* synthesis SET_AS_NETWORK=extclk_c, is_clock=1 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(15[3:9])
    
    wire GND_net, VCC_net, leds_c_7, leds_c_6, leds_c_5, leds_c_4, 
        leds_c_3, leds_c_2, leds_c_1, leds_c_0, switches_c_0, extrst_c, 
        uart0_txd_c;
    wire [7:0]cnt;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(40[9:12])
    wire [31:0]clkdiv;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(41[9:15])
    wire [7:0]uart_send_char;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(43[9:23])
    
    wire uart_send_char_7__N_100_c_3, uart_send_char_7__N_100_c_2, uart_send_char_7__N_100_c_1, 
        n27, n855, n41, n42, n43, n44, n45, n46, n47, n48, 
        n853, n846, n26, n25, n28, extclk_c_enable_18, n845, n909, 
        n907, n899, n844, n843, n852, n851, n842, n841, n24, 
        n840, n839, n838, n134, n135, n136, n137, n138, n139, 
        n140, n141, n142, n143, n144, n145, n146, n147, n148, 
        n149, n150, n151, n152, n153, n154, n155, n156, n157, 
        n158, n159, n160, n161, n162, n163, n164, n165, n19, 
        n913, n857, n856, n850, n849, n848, n847, n38, n39, 
        n40, n41_adj_220, n42_adj_221, n43_adj_222, n44_adj_223, n45_adj_224, 
        extclk_c_enable_11;
    
    VHI i583 (.Z(VCC_net));
    LUT4 i10_3_lut (.A(n19), .B(clkdiv[6]), .C(clkdiv[18]), .Z(n28)) /* synthesis lut_function=(A+!(B (C))) */ ;
    defparam i10_3_lut.init = 16'hbfbf;
    \UART_Sender(12000000,19200)  UART_Sender0 (.extclk_c(extclk_c), .\uart_send_char[0] (uart_send_char[0]), 
            .uart0_txd_c(uart0_txd_c), .GND_net(GND_net), .extrst_c(extrst_c), 
            .\uart_send_char[3] (uart_send_char[3]), .\uart_send_char[2] (uart_send_char[2]), 
            .\uart_send_char[1] (uart_send_char[1]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(45[16:27])
    FD1P3AX leds_i0_i1 (.D(n48), .SP(extclk_c_enable_18), .CK(extclk_c), 
            .Q(leds_c_0));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(65[4] 74[11])
    defparam leds_i0_i1.GSR = "DISABLED";
    TSALL TSALL_INST (.TSALL(GND_net));
    CCU2D cnt_172_add_4_6 (.A0(cnt[4]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(cnt[5]), .B1(GND_net), .C1(GND_net), .D1(GND_net), .CIN(n856), 
          .COUT(n857), .S0(n41_adj_220), .S1(n40));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(69[13:16])
    defparam cnt_172_add_4_6.INIT0 = 16'hfaaa;
    defparam cnt_172_add_4_6.INIT1 = 16'hfaaa;
    defparam cnt_172_add_4_6.INJECT1_0 = "NO";
    defparam cnt_172_add_4_6.INJECT1_1 = "NO";
    OB leds_pad_5 (.I(leds_c_5), .O(leds[5]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    LUT4 inv_10_i3_1_lut (.A(cnt[2]), .Z(n46)) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(70[18:39])
    defparam inv_10_i3_1_lut.init = 16'h5555;
    VLO i1 (.Z(GND_net));
    CCU2D cnt_172_add_4_4 (.A0(uart_send_char_7__N_100_c_2), .B0(cnt[2]), 
          .C0(GND_net), .D0(GND_net), .A1(uart_send_char_7__N_100_c_3), 
          .B1(cnt[3]), .C1(GND_net), .D1(GND_net), .CIN(n855), .COUT(n856), 
          .S0(n43_adj_222), .S1(n42_adj_221));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(69[13:16])
    defparam cnt_172_add_4_4.INIT0 = 16'h5666;
    defparam cnt_172_add_4_4.INIT1 = 16'h5666;
    defparam cnt_172_add_4_4.INJECT1_0 = "NO";
    defparam cnt_172_add_4_4.INJECT1_1 = "NO";
    FD1P3AX uart_send_char__i1 (.D(switches_c_0), .SP(extrst_c), .CK(extclk_c), 
            .Q(uart_send_char[0]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(65[4] 74[11])
    defparam uart_send_char__i1.GSR = "DISABLED";
    CCU2D clkdiv_173_add_4_15 (.A0(clkdiv[13]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[14]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n844), .COUT(n845), .S0(n152), .S1(n151));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_15.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_15.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_15.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_15.INJECT1_1 = "NO";
    CCU2D clkdiv_173_add_4_31 (.A0(clkdiv[29]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[30]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n852), .COUT(n853), .S0(n136), .S1(n135));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_31.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_31.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_31.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_31.INJECT1_1 = "NO";
    CCU2D clkdiv_173_add_4_13 (.A0(clkdiv[11]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[12]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n843), .COUT(n844), .S0(n154), .S1(n153));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_13.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_13.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_13.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_13.INJECT1_1 = "NO";
    LUT4 i505_2_lut (.A(switches_c_0), .B(cnt[0]), .Z(n45_adj_224)) /* synthesis lut_function=(!(A (B)+!A !(B))) */ ;
    defparam i505_2_lut.init = 16'h6666;
    OB leds_pad_6 (.I(leds_c_6), .O(leds[6]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    LUT4 inv_10_i2_1_lut (.A(cnt[1]), .Z(n47)) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(70[18:39])
    defparam inv_10_i2_1_lut.init = 16'h5555;
    OB leds_pad_7 (.I(leds_c_7), .O(leds[7]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    LUT4 inv_10_i5_1_lut (.A(cnt[4]), .Z(n44)) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(70[18:39])
    defparam inv_10_i5_1_lut.init = 16'h5555;
    LUT4 inv_10_i6_1_lut (.A(cnt[5]), .Z(n43)) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(70[18:39])
    defparam inv_10_i6_1_lut.init = 16'h5555;
    LUT4 inv_10_i7_1_lut (.A(cnt[6]), .Z(n42)) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(70[18:39])
    defparam inv_10_i7_1_lut.init = 16'h5555;
    LUT4 i563_3_lut_rep_1 (.A(n909), .B(n913), .C(n899), .Z(extclk_c_enable_11)) /* synthesis lut_function=(A (B (C))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(67[8:27])
    defparam i563_3_lut_rep_1.init = 16'h8080;
    LUT4 inv_10_i1_1_lut (.A(cnt[0]), .Z(n48)) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(70[18:39])
    defparam inv_10_i1_1_lut.init = 16'h5555;
    CCU2D clkdiv_173_add_4_29 (.A0(clkdiv[27]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[28]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n851), .COUT(n852), .S0(n138), .S1(n137));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_29.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_29.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_29.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_29.INJECT1_1 = "NO";
    LUT4 inv_10_i8_1_lut (.A(cnt[7]), .Z(n41)) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(70[18:39])
    defparam inv_10_i8_1_lut.init = 16'h5555;
    FD1S3IX clkdiv_173__i0 (.D(n165), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[0])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i0.GSR = "ENABLED";
    FD1P3AX cnt_172__i0 (.D(n45_adj_224), .SP(extclk_c_enable_11), .CK(extclk_c), 
            .Q(cnt[0])) /* synthesis syn_use_carry_chain=1 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(69[13:16])
    defparam cnt_172__i0.GSR = "ENABLED";
    OB leds_pad_4 (.I(leds_c_4), .O(leds[4]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    FD1P3AX cnt_172__i7 (.D(n38), .SP(extclk_c_enable_11), .CK(extclk_c), 
            .Q(cnt[7])) /* synthesis syn_use_carry_chain=1 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(69[13:16])
    defparam cnt_172__i7.GSR = "ENABLED";
    GSR GSR_INST (.GSR(extrst_c));
    CCU2D clkdiv_173_add_4_27 (.A0(clkdiv[25]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[26]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n850), .COUT(n851), .S0(n140), .S1(n139));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_27.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_27.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_27.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_27.INJECT1_1 = "NO";
    CCU2D clkdiv_173_add_4_11 (.A0(clkdiv[9]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[10]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n842), .COUT(n843), .S0(n156), .S1(n155));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_11.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_11.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_11.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_11.INJECT1_1 = "NO";
    LUT4 i557_4_lut (.A(clkdiv[1]), .B(clkdiv[11]), .C(clkdiv[2]), .D(clkdiv[3]), 
         .Z(n909)) /* synthesis lut_function=(A (B (C (D)))) */ ;
    defparam i557_4_lut.init = 16'h8000;
    FD1P3AX cnt_172__i6 (.D(n39), .SP(extclk_c_enable_11), .CK(extclk_c), 
            .Q(cnt[6])) /* synthesis syn_use_carry_chain=1 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(69[13:16])
    defparam cnt_172__i6.GSR = "ENABLED";
    FD1P3AX cnt_172__i5 (.D(n40), .SP(extclk_c_enable_11), .CK(extclk_c), 
            .Q(cnt[5])) /* synthesis syn_use_carry_chain=1 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(69[13:16])
    defparam cnt_172__i5.GSR = "ENABLED";
    FD1P3AX cnt_172__i4 (.D(n41_adj_220), .SP(extclk_c_enable_11), .CK(extclk_c), 
            .Q(cnt[4])) /* synthesis syn_use_carry_chain=1 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(69[13:16])
    defparam cnt_172__i4.GSR = "ENABLED";
    FD1P3AX cnt_172__i3 (.D(n42_adj_221), .SP(extclk_c_enable_11), .CK(extclk_c), 
            .Q(cnt[3])) /* synthesis syn_use_carry_chain=1 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(69[13:16])
    defparam cnt_172__i3.GSR = "ENABLED";
    FD1P3AX cnt_172__i2 (.D(n43_adj_222), .SP(extclk_c_enable_11), .CK(extclk_c), 
            .Q(cnt[2])) /* synthesis syn_use_carry_chain=1 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(69[13:16])
    defparam cnt_172__i2.GSR = "ENABLED";
    FD1P3AX cnt_172__i1 (.D(n44_adj_223), .SP(extclk_c_enable_11), .CK(extclk_c), 
            .Q(cnt[1])) /* synthesis syn_use_carry_chain=1 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(69[13:16])
    defparam cnt_172__i1.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i31 (.D(n134), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[31])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i31.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i30 (.D(n135), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[30])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i30.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i29 (.D(n136), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[29])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i29.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i28 (.D(n137), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[28])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i28.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i27 (.D(n138), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[27])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i27.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i26 (.D(n139), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[26])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i26.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i25 (.D(n140), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[25])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i25.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i24 (.D(n141), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[24])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i24.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i23 (.D(n142), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[23])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i23.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i22 (.D(n143), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[22])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i22.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i21 (.D(n144), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[21])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i21.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i20 (.D(n145), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[20])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i20.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i19 (.D(n146), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[19])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i19.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i18 (.D(n147), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[18])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i18.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i17 (.D(n148), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[17])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i17.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i16 (.D(n149), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[16])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i16.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i15 (.D(n150), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[15])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i15.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i14 (.D(n151), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[14])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i14.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i13 (.D(n152), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[13])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i13.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i12 (.D(n153), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[12])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i12.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i11 (.D(n154), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[11])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i11.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i10 (.D(n155), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[10])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i10.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i9 (.D(n156), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[9])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i9.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i8 (.D(n157), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[8])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i8.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i7 (.D(n158), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[7])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i7.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i6 (.D(n159), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[6])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i6.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i5 (.D(n160), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[5])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i5.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i4 (.D(n161), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[4])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i4.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i3 (.D(n162), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[3])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i3.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i2 (.D(n163), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[2])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i2.GSR = "ENABLED";
    FD1S3IX clkdiv_173__i1 (.D(n164), .CK(extclk_c), .CD(extclk_c_enable_11), 
            .Q(clkdiv[1])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173__i1.GSR = "ENABLED";
    LUT4 i562_4_lut (.A(n907), .B(clkdiv[0]), .C(n28), .D(clkdiv[16]), 
         .Z(n913)) /* synthesis lut_function=(!(((C+!(D))+!B)+!A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(67[8:27])
    defparam i562_4_lut.init = 16'h0800;
    LUT4 i88_2_lut_4_lut (.A(n909), .B(n913), .C(n899), .D(extrst_c), 
         .Z(extclk_c_enable_18)) /* synthesis lut_function=(A (B (C (D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(67[8:27])
    defparam i88_2_lut_4_lut.init = 16'h8000;
    LUT4 i547_4_lut (.A(clkdiv[5]), .B(clkdiv[17]), .C(clkdiv[12]), .D(clkdiv[20]), 
         .Z(n899)) /* synthesis lut_function=(A (B (C (D)))) */ ;
    defparam i547_4_lut.init = 16'h8000;
    LUT4 i1_4_lut (.A(n27), .B(clkdiv[4]), .C(n25), .D(n26), .Z(n19)) /* synthesis lut_function=(A+((C+(D))+!B)) */ ;
    defparam i1_4_lut.init = 16'hfffb;
    CCU2D clkdiv_173_add_4_9 (.A0(clkdiv[7]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[8]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n841), .COUT(n842), .S0(n158), .S1(n157));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_9.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_9.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_9.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_9.INJECT1_1 = "NO";
    CCU2D cnt_172_add_4_2 (.A0(switches_c_0), .B0(cnt[0]), .C0(GND_net), 
          .D0(GND_net), .A1(uart_send_char_7__N_100_c_1), .B1(cnt[1]), 
          .C1(GND_net), .D1(GND_net), .COUT(n855), .S1(n44_adj_223));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(69[13:16])
    defparam cnt_172_add_4_2.INIT0 = 16'h7000;
    defparam cnt_172_add_4_2.INIT1 = 16'h5666;
    defparam cnt_172_add_4_2.INJECT1_0 = "NO";
    defparam cnt_172_add_4_2.INJECT1_1 = "NO";
    CCU2D clkdiv_173_add_4_25 (.A0(clkdiv[23]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[24]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n849), .COUT(n850), .S0(n142), .S1(n141));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_25.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_25.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_25.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_25.INJECT1_1 = "NO";
    CCU2D clkdiv_173_add_4_7 (.A0(clkdiv[5]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[6]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n840), .COUT(n841), .S0(n160), .S1(n159));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_7.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_7.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_7.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_7.INJECT1_1 = "NO";
    CCU2D clkdiv_173_add_4_5 (.A0(clkdiv[3]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[4]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n839), .COUT(n840), .S0(n162), .S1(n161));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_5.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_5.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_5.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_5.INJECT1_1 = "NO";
    FD1P3AX uart_send_char__i4 (.D(uart_send_char_7__N_100_c_3), .SP(extrst_c), 
            .CK(extclk_c), .Q(uart_send_char[3]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(65[4] 74[11])
    defparam uart_send_char__i4.GSR = "DISABLED";
    LUT4 i12_4_lut (.A(clkdiv[19]), .B(n24), .C(clkdiv[8]), .D(clkdiv[14]), 
         .Z(n27)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(67[8:27])
    defparam i12_4_lut.init = 16'hfffe;
    LUT4 i10_4_lut (.A(clkdiv[30]), .B(clkdiv[22]), .C(clkdiv[13]), .D(clkdiv[25]), 
         .Z(n25)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(67[8:27])
    defparam i10_4_lut.init = 16'hfffe;
    LUT4 i11_4_lut (.A(clkdiv[28]), .B(clkdiv[15]), .C(clkdiv[31]), .D(clkdiv[29]), 
         .Z(n26)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(67[8:27])
    defparam i11_4_lut.init = 16'hfffe;
    LUT4 i9_4_lut (.A(clkdiv[26]), .B(clkdiv[24]), .C(clkdiv[10]), .D(clkdiv[27]), 
         .Z(n24)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(67[8:27])
    defparam i9_4_lut.init = 16'hfffe;
    CCU2D clkdiv_173_add_4_3 (.A0(clkdiv[1]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[2]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n838), .COUT(n839), .S0(n164), .S1(n163));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_3.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_3.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_3.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_3.INJECT1_1 = "NO";
    CCU2D clkdiv_173_add_4_1 (.A0(GND_net), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[0]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .COUT(n838), .S1(n165));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_1.INIT0 = 16'hF000;
    defparam clkdiv_173_add_4_1.INIT1 = 16'h0555;
    defparam clkdiv_173_add_4_1.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_1.INJECT1_1 = "NO";
    FD1P3AX uart_send_char__i3 (.D(uart_send_char_7__N_100_c_2), .SP(extrst_c), 
            .CK(extclk_c), .Q(uart_send_char[2]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(65[4] 74[11])
    defparam uart_send_char__i3.GSR = "DISABLED";
    FD1P3AX uart_send_char__i2 (.D(uart_send_char_7__N_100_c_1), .SP(extrst_c), 
            .CK(extclk_c), .Q(uart_send_char[1]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(65[4] 74[11])
    defparam uart_send_char__i2.GSR = "DISABLED";
    FD1P3AX leds_i0_i8 (.D(n41), .SP(extclk_c_enable_18), .CK(extclk_c), 
            .Q(leds_c_7));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(65[4] 74[11])
    defparam leds_i0_i8.GSR = "DISABLED";
    PUR PUR_INST (.PUR(VCC_net));
    defparam PUR_INST.RST_PULSE = 1;
    CCU2D clkdiv_173_add_4_23 (.A0(clkdiv[21]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[22]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n848), .COUT(n849), .S0(n144), .S1(n143));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_23.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_23.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_23.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_23.INJECT1_1 = "NO";
    CCU2D clkdiv_173_add_4_33 (.A0(clkdiv[31]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(GND_net), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n853), .S0(n134));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_33.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_33.INIT1 = 16'h0000;
    defparam clkdiv_173_add_4_33.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_33.INJECT1_1 = "NO";
    CCU2D cnt_172_add_4_8 (.A0(cnt[6]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(cnt[7]), .B1(GND_net), .C1(GND_net), .D1(GND_net), .CIN(n857), 
          .S0(n39), .S1(n38));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(69[13:16])
    defparam cnt_172_add_4_8.INIT0 = 16'hfaaa;
    defparam cnt_172_add_4_8.INIT1 = 16'hfaaa;
    defparam cnt_172_add_4_8.INJECT1_0 = "NO";
    defparam cnt_172_add_4_8.INJECT1_1 = "NO";
    LUT4 i555_4_lut (.A(clkdiv[23]), .B(clkdiv[21]), .C(clkdiv[7]), .D(clkdiv[9]), 
         .Z(n907)) /* synthesis lut_function=(A (B (C (D)))) */ ;
    defparam i555_4_lut.init = 16'h8000;
    CCU2D clkdiv_173_add_4_21 (.A0(clkdiv[19]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[20]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n847), .COUT(n848), .S0(n146), .S1(n145));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_21.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_21.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_21.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_21.INJECT1_1 = "NO";
    CCU2D clkdiv_173_add_4_19 (.A0(clkdiv[17]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[18]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n846), .COUT(n847), .S0(n148), .S1(n147));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_19.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_19.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_19.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_19.INJECT1_1 = "NO";
    FD1P3AX leds_i0_i7 (.D(n42), .SP(extclk_c_enable_18), .CK(extclk_c), 
            .Q(leds_c_6));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(65[4] 74[11])
    defparam leds_i0_i7.GSR = "DISABLED";
    FD1P3AX leds_i0_i6 (.D(n43), .SP(extclk_c_enable_18), .CK(extclk_c), 
            .Q(leds_c_5));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(65[4] 74[11])
    defparam leds_i0_i6.GSR = "DISABLED";
    FD1P3AX leds_i0_i5 (.D(n44), .SP(extclk_c_enable_18), .CK(extclk_c), 
            .Q(leds_c_4));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(65[4] 74[11])
    defparam leds_i0_i5.GSR = "DISABLED";
    FD1P3AX leds_i0_i4 (.D(n45), .SP(extclk_c_enable_18), .CK(extclk_c), 
            .Q(leds_c_3));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(65[4] 74[11])
    defparam leds_i0_i4.GSR = "DISABLED";
    FD1P3AX leds_i0_i3 (.D(n46), .SP(extclk_c_enable_18), .CK(extclk_c), 
            .Q(leds_c_2));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(65[4] 74[11])
    defparam leds_i0_i3.GSR = "DISABLED";
    FD1P3AX leds_i0_i2 (.D(n47), .SP(extclk_c_enable_18), .CK(extclk_c), 
            .Q(leds_c_1));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(65[4] 74[11])
    defparam leds_i0_i2.GSR = "DISABLED";
    LUT4 inv_10_i4_1_lut (.A(cnt[3]), .Z(n45)) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(70[18:39])
    defparam inv_10_i4_1_lut.init = 16'h5555;
    CCU2D clkdiv_173_add_4_17 (.A0(clkdiv[15]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[16]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n845), .COUT(n846), .S0(n150), .S1(n149));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1241[12:13])
    defparam clkdiv_173_add_4_17.INIT0 = 16'hfaaa;
    defparam clkdiv_173_add_4_17.INIT1 = 16'hfaaa;
    defparam clkdiv_173_add_4_17.INJECT1_0 = "NO";
    defparam clkdiv_173_add_4_17.INJECT1_1 = "NO";
    OB leds_pad_3 (.I(leds_c_3), .O(leds[3]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    OB leds_pad_2 (.I(leds_c_2), .O(leds[2]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    OB leds_pad_1 (.I(leds_c_1), .O(leds[1]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    OB leds_pad_0 (.I(leds_c_0), .O(leds[0]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    OB uart0_txd_pad (.I(uart0_txd_c), .O(uart0_txd));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(18[3:12])
    IB uart_send_char_7__N_100_pad_3 (.I(switches[3]), .O(uart_send_char_7__N_100_c_3));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(14[3:11])
    IB uart_send_char_7__N_100_pad_2 (.I(switches[2]), .O(uart_send_char_7__N_100_c_2));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(14[3:11])
    IB uart_send_char_7__N_100_pad_1 (.I(switches[1]), .O(uart_send_char_7__N_100_c_1));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(14[3:11])
    IB switches_pad_0 (.I(switches[0]), .O(switches_c_0));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(14[3:11])
    IB extclk_pad (.I(extclk), .O(extclk_c));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(15[3:9])
    IB extrst_pad (.I(extrst), .O(extrst_c));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(16[3:9])
    
endmodule
//
// Verilog Description of module \UART_Sender(12000000,19200) 
//

module \UART_Sender(12000000,19200)  (extclk_c, \uart_send_char[0] , uart0_txd_c, 
            GND_net, extrst_c, \uart_send_char[3] , \uart_send_char[2] , 
            \uart_send_char[1] );
    input extclk_c;
    input \uart_send_char[0] ;
    output uart0_txd_c;
    input GND_net;
    input extrst_c;
    input \uart_send_char[3] ;
    input \uart_send_char[2] ;
    input \uart_send_char[1] ;
    
    wire extclk_c /* synthesis SET_AS_NETWORK=extclk_c, is_clock=1 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(15[3:9])
    wire [7:0]data_buffer;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(45[9:20])
    
    wire extclk_c_enable_21, extclk_c_enable_3, txd_N_214, n825;
    wire [31:0]clkdiv;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(43[9:15])
    wire [31:0]n133;
    
    wire n826, n824, n977, n822, n823, n834, n835, n38, n49, 
        clkdiv_31__N_194, txd_N_215;
    wire [15:0]n298;
    
    wire n553, n861, n41, n60, n54, n42, n922;
    wire [31:0]n167;
    
    wire n52, n58, n50, n833, n46, n56, n837, n836, n832, 
        n831, n63, n888, n4;
    wire [0:0]n424;
    
    wire n830, n829, n828, n827;
    
    FD1P3AX data_buffer__i1 (.D(\uart_send_char[0] ), .SP(extclk_c_enable_21), 
            .CK(extclk_c), .Q(data_buffer[0])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=45, LSE_RLINE=45 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(54[4] 92[11])
    defparam data_buffer__i1.GSR = "DISABLED";
    FD1P3IX txd_34 (.D(txd_N_214), .SP(extclk_c_enable_3), .CD(extclk_c_enable_21), 
            .CK(extclk_c), .Q(uart0_txd_c)) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=45, LSE_RLINE=45 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(54[4] 92[11])
    defparam txd_34.GSR = "DISABLED";
    CCU2D clkdiv_174_add_4_9 (.A0(clkdiv[7]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[8]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n825), .COUT(n826), .S0(n133[7]), .S1(n133[8]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_9.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_9.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_9.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_9.INJECT1_1 = "NO";
    CCU2D clkdiv_174_add_4_7 (.A0(clkdiv[5]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[6]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n824), .COUT(n825), .S0(n133[5]), .S1(n133[6]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_7.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_7.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_7.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_7.INJECT1_1 = "NO";
    FD1S3IX clkdiv_174__i0 (.D(n133[0]), .CK(extclk_c), .CD(n977), .Q(clkdiv[0])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i0.GSR = "ENABLED";
    CCU2D clkdiv_174_add_4_3 (.A0(clkdiv[1]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[2]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n822), .COUT(n823), .S0(n133[1]), .S1(n133[2]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_3.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_3.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_3.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_3.INJECT1_1 = "NO";
    CCU2D clkdiv_174_add_4_5 (.A0(clkdiv[3]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[4]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n823), .COUT(n824), .S0(n133[3]), .S1(n133[4]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_5.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_5.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_5.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_5.INJECT1_1 = "NO";
    CCU2D clkdiv_174_add_4_27 (.A0(clkdiv[25]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[26]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n834), .COUT(n835), .S0(n133[25]), .S1(n133[26]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_27.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_27.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_27.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_27.INJECT1_1 = "NO";
    LUT4 i6_2_lut (.A(clkdiv[2]), .B(clkdiv[8]), .Z(n38)) /* synthesis lut_function=(A+(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i6_2_lut.init = 16'heeee;
    LUT4 i17_4_lut (.A(clkdiv[15]), .B(clkdiv[23]), .C(clkdiv[30]), .D(clkdiv[31]), 
         .Z(n49)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i17_4_lut.init = 16'hfffe;
    LUT4 i1_2_lut_rep_2 (.A(clkdiv_31__N_194), .B(txd_N_215), .Z(n977)) /* synthesis lut_function=(A+(B)) */ ;
    defparam i1_2_lut_rep_2.init = 16'heeee;
    LUT4 i1_3_lut (.A(clkdiv_31__N_194), .B(n298[2]), .C(txd_N_215), .Z(n553)) /* synthesis lut_function=(A+!((C)+!B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i1_3_lut.init = 16'haeae;
    LUT4 i566_3_lut (.A(txd_N_215), .B(n298[11]), .C(clkdiv_31__N_194), 
         .Z(n861)) /* synthesis lut_function=(!(((C)+!B)+!A)) */ ;
    defparam i566_3_lut.init = 16'h0808;
    LUT4 i571_4_lut (.A(n41), .B(n60), .C(n54), .D(n42), .Z(n922)) /* synthesis lut_function=(!(A+(B+(C+(D))))) */ ;
    defparam i571_4_lut.init = 16'h0001;
    LUT4 i373_2_lut_3_lut (.A(clkdiv_31__N_194), .B(txd_N_215), .C(n133[4]), 
         .Z(n167[4])) /* synthesis lut_function=(A+(B+(C))) */ ;
    defparam i373_2_lut_3_lut.init = 16'hfefe;
    LUT4 i20_4_lut (.A(clkdiv[16]), .B(clkdiv[21]), .C(clkdiv[7]), .D(clkdiv[25]), 
         .Z(n52)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i20_4_lut.init = 16'hfffe;
    LUT4 i26_4_lut (.A(clkdiv[28]), .B(n52), .C(n38), .D(clkdiv[18]), 
         .Z(n58)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i26_4_lut.init = 16'hfffe;
    LUT4 i370_2_lut_3_lut (.A(clkdiv_31__N_194), .B(txd_N_215), .C(n133[9]), 
         .Z(n167[9])) /* synthesis lut_function=(A+(B+(C))) */ ;
    defparam i370_2_lut_3_lut.init = 16'hfefe;
    LUT4 i93_2_lut (.A(clkdiv_31__N_194), .B(extrst_c), .Z(extclk_c_enable_21)) /* synthesis lut_function=(A (B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(50[4] 93[10])
    defparam i93_2_lut.init = 16'h8888;
    LUT4 i18_4_lut (.A(clkdiv[0]), .B(clkdiv[29]), .C(clkdiv[11]), .D(clkdiv[27]), 
         .Z(n50)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i18_4_lut.init = 16'hfffe;
    CCU2D clkdiv_174_add_4_25 (.A0(clkdiv[23]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[24]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n833), .COUT(n834), .S0(n133[23]), .S1(n133[24]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_25.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_25.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_25.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_25.INJECT1_1 = "NO";
    FD1S3IX clkdiv_174__i31 (.D(n133[31]), .CK(extclk_c), .CD(n977), .Q(clkdiv[31])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i31.GSR = "ENABLED";
    LUT4 i372_2_lut_3_lut (.A(clkdiv_31__N_194), .B(txd_N_215), .C(n133[5]), 
         .Z(n167[5])) /* synthesis lut_function=(A+(B+(C))) */ ;
    defparam i372_2_lut_3_lut.init = 16'hfefe;
    LUT4 i371_2_lut_3_lut (.A(clkdiv_31__N_194), .B(txd_N_215), .C(n133[6]), 
         .Z(n167[6])) /* synthesis lut_function=(A+(B+(C))) */ ;
    defparam i371_2_lut_3_lut.init = 16'hfefe;
    CCU2D clkdiv_174_add_4_1 (.A0(GND_net), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[0]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .COUT(n822), .S1(n133[0]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_1.INIT0 = 16'hF000;
    defparam clkdiv_174_add_4_1.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_1.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_1.INJECT1_1 = "NO";
    LUT4 i9_2_lut (.A(clkdiv[26]), .B(clkdiv[9]), .Z(n41)) /* synthesis lut_function=(A+(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i9_2_lut.init = 16'heeee;
    FD1S3IX clkdiv_174__i30 (.D(n133[30]), .CK(extclk_c), .CD(n977), .Q(clkdiv[30])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i30.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i29 (.D(n133[29]), .CK(extclk_c), .CD(n977), .Q(clkdiv[29])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i29.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i28 (.D(n133[28]), .CK(extclk_c), .CD(n977), .Q(clkdiv[28])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i28.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i27 (.D(n133[27]), .CK(extclk_c), .CD(n977), .Q(clkdiv[27])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i27.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i26 (.D(n133[26]), .CK(extclk_c), .CD(n977), .Q(clkdiv[26])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i26.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i25 (.D(n133[25]), .CK(extclk_c), .CD(n977), .Q(clkdiv[25])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i25.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i24 (.D(n133[24]), .CK(extclk_c), .CD(n977), .Q(clkdiv[24])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i24.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i23 (.D(n133[23]), .CK(extclk_c), .CD(n977), .Q(clkdiv[23])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i23.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i22 (.D(n133[22]), .CK(extclk_c), .CD(n977), .Q(clkdiv[22])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i22.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i21 (.D(n133[21]), .CK(extclk_c), .CD(n977), .Q(clkdiv[21])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i21.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i20 (.D(n133[20]), .CK(extclk_c), .CD(n977), .Q(clkdiv[20])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i20.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i19 (.D(n133[19]), .CK(extclk_c), .CD(n977), .Q(clkdiv[19])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i19.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i18 (.D(n133[18]), .CK(extclk_c), .CD(n977), .Q(clkdiv[18])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i18.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i17 (.D(n133[17]), .CK(extclk_c), .CD(n977), .Q(clkdiv[17])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i17.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i16 (.D(n133[16]), .CK(extclk_c), .CD(n977), .Q(clkdiv[16])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i16.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i15 (.D(n133[15]), .CK(extclk_c), .CD(n977), .Q(clkdiv[15])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i15.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i14 (.D(n133[14]), .CK(extclk_c), .CD(n977), .Q(clkdiv[14])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i14.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i13 (.D(n133[13]), .CK(extclk_c), .CD(n977), .Q(clkdiv[13])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i13.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i12 (.D(n133[12]), .CK(extclk_c), .CD(n977), .Q(clkdiv[12])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i12.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i11 (.D(n133[11]), .CK(extclk_c), .CD(n977), .Q(clkdiv[11])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i11.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i10 (.D(n133[10]), .CK(extclk_c), .CD(n977), .Q(clkdiv[10])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i10.GSR = "ENABLED";
    FD1S3AX clkdiv_174__i9 (.D(n167[9]), .CK(extclk_c), .Q(clkdiv[9])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i9.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i8 (.D(n133[8]), .CK(extclk_c), .CD(n977), .Q(clkdiv[8])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i8.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i7 (.D(n133[7]), .CK(extclk_c), .CD(n977), .Q(clkdiv[7])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i7.GSR = "ENABLED";
    FD1S3AX clkdiv_174__i6 (.D(n167[6]), .CK(extclk_c), .Q(clkdiv[6])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i6.GSR = "ENABLED";
    FD1S3AX clkdiv_174__i5 (.D(n167[5]), .CK(extclk_c), .Q(clkdiv[5])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i5.GSR = "ENABLED";
    FD1S3AX clkdiv_174__i4 (.D(n167[4]), .CK(extclk_c), .Q(clkdiv[4])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i4.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i3 (.D(n133[3]), .CK(extclk_c), .CD(n977), .Q(clkdiv[3])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i3.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i2 (.D(n133[2]), .CK(extclk_c), .CD(n977), .Q(clkdiv[2])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i2.GSR = "ENABLED";
    FD1S3IX clkdiv_174__i1 (.D(n133[1]), .CK(extclk_c), .CD(n977), .Q(clkdiv[1])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174__i1.GSR = "ENABLED";
    LUT4 i14_2_lut (.A(clkdiv[5]), .B(clkdiv[6]), .Z(n46)) /* synthesis lut_function=(A+(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i14_2_lut.init = 16'heeee;
    LUT4 i28_4_lut (.A(clkdiv[19]), .B(n56), .C(n46), .D(clkdiv[22]), 
         .Z(n60)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i28_4_lut.init = 16'hfffe;
    LUT4 i22_4_lut (.A(clkdiv[24]), .B(clkdiv[4]), .C(clkdiv[1]), .D(clkdiv[14]), 
         .Z(n54)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i22_4_lut.init = 16'hfffe;
    CCU2D clkdiv_174_add_4_33 (.A0(clkdiv[31]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(GND_net), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n837), .S0(n133[31]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_33.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_33.INIT1 = 16'h0000;
    defparam clkdiv_174_add_4_33.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_33.INJECT1_1 = "NO";
    CCU2D clkdiv_174_add_4_31 (.A0(clkdiv[29]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[30]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n836), .COUT(n837), .S0(n133[29]), .S1(n133[30]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_31.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_31.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_31.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_31.INJECT1_1 = "NO";
    CCU2D clkdiv_174_add_4_23 (.A0(clkdiv[21]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[22]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n832), .COUT(n833), .S0(n133[21]), .S1(n133[22]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_23.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_23.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_23.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_23.INJECT1_1 = "NO";
    CCU2D clkdiv_174_add_4_21 (.A0(clkdiv[19]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[20]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n831), .COUT(n832), .S0(n133[19]), .S1(n133[20]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_21.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_21.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_21.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_21.INJECT1_1 = "NO";
    LUT4 i24_4_lut (.A(clkdiv[10]), .B(clkdiv[13]), .C(clkdiv[20]), .D(clkdiv[3]), 
         .Z(n56)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i24_4_lut.init = 16'hfffe;
    LUT4 i1_4_lut (.A(extrst_c), .B(n63), .C(n298[2]), .D(clkdiv_31__N_194), 
         .Z(extclk_c_enable_3)) /* synthesis lut_function=(A (B (C (D))+!B (C+!(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(43[9:15])
    defparam i1_4_lut.init = 16'ha022;
    LUT4 i1_3_lut_adj_3 (.A(n298[2]), .B(txd_N_215), .C(n298[11]), .Z(n63)) /* synthesis lut_function=(!(A (B)+!A !((C)+!B))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i1_3_lut_adj_3.init = 16'h7373;
    LUT4 i10_2_lut (.A(clkdiv[12]), .B(clkdiv[17]), .Z(n42)) /* synthesis lut_function=(A+(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i10_2_lut.init = 16'heeee;
    LUT4 i286_4_lut (.A(n888), .B(data_buffer[0]), .C(n298[2]), .D(n298[10]), 
         .Z(txd_N_214)) /* synthesis lut_function=(A (B+!(C))+!A (B (C+(D))+!B !(C+!(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i286_4_lut.init = 16'hcfca;
    LUT4 i2_4_lut (.A(n298[8]), .B(n298[6]), .C(n298[9]), .D(n4), .Z(n888)) /* synthesis lut_function=(!(A+(B (C)+!B (C+!(D))))) */ ;
    defparam i2_4_lut.init = 16'h0504;
    LUT4 i1_4_lut_adj_4 (.A(n424[0]), .B(n298[7]), .C(data_buffer[3]), 
         .D(n298[5]), .Z(n4)) /* synthesis lut_function=(A (B+(C+!(D)))+!A (B+(C (D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam i1_4_lut_adj_4.init = 16'hfcee;
    LUT4 mux_116_i1_3_lut (.A(data_buffer[1]), .B(data_buffer[2]), .C(n298[4]), 
         .Z(n424[0])) /* synthesis lut_function=(A (B+!(C))+!A (B (C))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam mux_116_i1_3_lut.init = 16'hcaca;
    CCU2D clkdiv_174_add_4_19 (.A0(clkdiv[17]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[18]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n830), .COUT(n831), .S0(n133[17]), .S1(n133[18]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_19.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_19.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_19.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_19.INJECT1_1 = "NO";
    CCU2D clkdiv_174_add_4_17 (.A0(clkdiv[15]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[16]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n829), .COUT(n830), .S0(n133[15]), .S1(n133[16]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_17.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_17.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_17.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_17.INJECT1_1 = "NO";
    CCU2D clkdiv_174_add_4_15 (.A0(clkdiv[13]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[14]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n828), .COUT(n829), .S0(n133[13]), .S1(n133[14]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_15.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_15.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_15.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_15.INJECT1_1 = "NO";
    LUT4 i572_4_lut (.A(n49), .B(n922), .C(n58), .D(n50), .Z(txd_N_215)) /* synthesis lut_function=(!(A+((C+(D))+!B))) */ ;
    defparam i572_4_lut.init = 16'h0004;
    FD1S3AY state_FSM_i1 (.D(n861), .CK(extclk_c), .Q(clkdiv_31__N_194));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam state_FSM_i1.GSR = "ENABLED";
    CCU2D clkdiv_174_add_4_13 (.A0(clkdiv[11]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[12]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n827), .COUT(n828), .S0(n133[11]), .S1(n133[12]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_13.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_13.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_13.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_13.INJECT1_1 = "NO";
    CCU2D clkdiv_174_add_4_11 (.A0(clkdiv[9]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[10]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n826), .COUT(n827), .S0(n133[9]), .S1(n133[10]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_11.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_11.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_11.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_11.INJECT1_1 = "NO";
    CCU2D clkdiv_174_add_4_29 (.A0(clkdiv[27]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[28]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n835), .COUT(n836), .S0(n133[27]), .S1(n133[28]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_174_add_4_29.INIT0 = 16'h0555;
    defparam clkdiv_174_add_4_29.INIT1 = 16'h0555;
    defparam clkdiv_174_add_4_29.INJECT1_0 = "NO";
    defparam clkdiv_174_add_4_29.INJECT1_1 = "NO";
    FD1P3AX data_buffer__i4 (.D(\uart_send_char[3] ), .SP(extclk_c_enable_21), 
            .CK(extclk_c), .Q(data_buffer[3])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=45, LSE_RLINE=45 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(54[4] 92[11])
    defparam data_buffer__i4.GSR = "DISABLED";
    FD1P3AX data_buffer__i3 (.D(\uart_send_char[2] ), .SP(extclk_c_enable_21), 
            .CK(extclk_c), .Q(data_buffer[2])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=45, LSE_RLINE=45 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(54[4] 92[11])
    defparam data_buffer__i3.GSR = "DISABLED";
    FD1P3AX data_buffer__i2 (.D(\uart_send_char[1] ), .SP(extclk_c_enable_21), 
            .CK(extclk_c), .Q(data_buffer[1])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=45, LSE_RLINE=45 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(54[4] 92[11])
    defparam data_buffer__i2.GSR = "DISABLED";
    FD1P3IX state_FSM_i12 (.D(n298[10]), .SP(txd_N_215), .CD(clkdiv_31__N_194), 
            .CK(extclk_c), .Q(n298[11]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam state_FSM_i12.GSR = "ENABLED";
    FD1P3IX state_FSM_i11 (.D(n298[9]), .SP(txd_N_215), .CD(clkdiv_31__N_194), 
            .CK(extclk_c), .Q(n298[10]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam state_FSM_i11.GSR = "ENABLED";
    FD1P3IX state_FSM_i10 (.D(n298[8]), .SP(txd_N_215), .CD(clkdiv_31__N_194), 
            .CK(extclk_c), .Q(n298[9]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam state_FSM_i10.GSR = "ENABLED";
    FD1P3IX state_FSM_i9 (.D(n298[7]), .SP(txd_N_215), .CD(clkdiv_31__N_194), 
            .CK(extclk_c), .Q(n298[8]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam state_FSM_i9.GSR = "ENABLED";
    FD1P3IX state_FSM_i8 (.D(n298[6]), .SP(txd_N_215), .CD(clkdiv_31__N_194), 
            .CK(extclk_c), .Q(n298[7]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam state_FSM_i8.GSR = "ENABLED";
    FD1P3IX state_FSM_i7 (.D(n298[5]), .SP(txd_N_215), .CD(clkdiv_31__N_194), 
            .CK(extclk_c), .Q(n298[6]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam state_FSM_i7.GSR = "ENABLED";
    FD1P3IX state_FSM_i6 (.D(n298[4]), .SP(txd_N_215), .CD(clkdiv_31__N_194), 
            .CK(extclk_c), .Q(n298[5]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam state_FSM_i6.GSR = "ENABLED";
    FD1P3IX state_FSM_i5 (.D(n298[3]), .SP(txd_N_215), .CD(clkdiv_31__N_194), 
            .CK(extclk_c), .Q(n298[4]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam state_FSM_i5.GSR = "ENABLED";
    FD1P3IX state_FSM_i4 (.D(n298[2]), .SP(txd_N_215), .CD(clkdiv_31__N_194), 
            .CK(extclk_c), .Q(n298[3]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam state_FSM_i4.GSR = "ENABLED";
    FD1S3AX state_FSM_i3 (.D(n553), .CK(extclk_c), .Q(n298[2]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(73[7] 86[16])
    defparam state_FSM_i3.GSR = "ENABLED";
    
endmodule
//
// Verilog Description of module TSALL
// module not written out since it is a black-box. 
//

//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

