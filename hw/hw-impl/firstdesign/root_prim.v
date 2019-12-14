// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.11.1.441.0
// Netlist written on Fri Dec 13 17:39:03 2019
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
    
    wire GND_net, leds_c_7, leds_c_6, leds_c_5, leds_c_4, leds_c_3, 
        leds_c_2, leds_c_1, leds_c_0, extrst_c, uart0_rxd_c, uart0_txd_c;
    wire [7:0]uart_send_char;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(60[9:23])
    
    wire uart_receive_done;
    wire [7:0]leds_7__N_9;
    
    wire VCC_net, n1618;
    
    VHI i1313 (.Z(VCC_net));
    FD1P3AX leds_i0_i1 (.D(leds_7__N_9[0]), .SP(extrst_c), .CK(extclk_c), 
            .Q(leds_c_0));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(97[4] 99[11])
    defparam leds_i0_i1.GSR = "DISABLED";
    OB leds_pad_7 (.I(leds_c_7), .O(leds[7]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    LUT4 inv_7_i2_1_lut (.A(uart_send_char[1]), .Z(leds_7__N_9[1])) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(98[17:49])
    defparam inv_7_i2_1_lut.init = 16'h5555;
    OB leds_pad_6 (.I(leds_c_6), .O(leds[6]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    LUT4 inv_7_i1_1_lut (.A(uart_send_char[0]), .Z(leds_7__N_9[0])) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(98[17:49])
    defparam inv_7_i1_1_lut.init = 16'h5555;
    FD1P3AX leds_i0_i8 (.D(leds_7__N_9[7]), .SP(extrst_c), .CK(extclk_c), 
            .Q(leds_c_7));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(97[4] 99[11])
    defparam leds_i0_i8.GSR = "DISABLED";
    \UART_Sender(12000000,19200)  UART_Sender0 (.GND_net(GND_net), .uart_receive_done(uart_receive_done), 
            .extclk_c(extclk_c), .uart_send_char({uart_send_char}), .extrst_c(extrst_c), 
            .uart0_txd_c(uart0_txd_c));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(63[16:27])
    FD1P3AX leds_i0_i7 (.D(leds_7__N_9[6]), .SP(extrst_c), .CK(extclk_c), 
            .Q(leds_c_6));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(97[4] 99[11])
    defparam leds_i0_i7.GSR = "DISABLED";
    FD1P3AX leds_i0_i6 (.D(leds_7__N_9[5]), .SP(extrst_c), .CK(extclk_c), 
            .Q(leds_c_5));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(97[4] 99[11])
    defparam leds_i0_i6.GSR = "DISABLED";
    FD1P3AX leds_i0_i5 (.D(leds_7__N_9[4]), .SP(extrst_c), .CK(extclk_c), 
            .Q(leds_c_4));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(97[4] 99[11])
    defparam leds_i0_i5.GSR = "DISABLED";
    FD1P3AX leds_i0_i4 (.D(leds_7__N_9[3]), .SP(extrst_c), .CK(extclk_c), 
            .Q(leds_c_3));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(97[4] 99[11])
    defparam leds_i0_i4.GSR = "DISABLED";
    FD1P3AX leds_i0_i3 (.D(leds_7__N_9[2]), .SP(extrst_c), .CK(extclk_c), 
            .Q(leds_c_2));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(97[4] 99[11])
    defparam leds_i0_i3.GSR = "DISABLED";
    FD1P3AX leds_i0_i2 (.D(leds_7__N_9[1]), .SP(extrst_c), .CK(extclk_c), 
            .Q(leds_c_1));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(97[4] 99[11])
    defparam leds_i0_i2.GSR = "DISABLED";
    OB leds_pad_5 (.I(leds_c_5), .O(leds[5]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    OB leds_pad_4 (.I(leds_c_4), .O(leds[4]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    OB leds_pad_3 (.I(leds_c_3), .O(leds[3]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    OB leds_pad_2 (.I(leds_c_2), .O(leds[2]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    OB leds_pad_1 (.I(leds_c_1), .O(leds[1]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    OB leds_pad_0 (.I(leds_c_0), .O(leds[0]));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(13[3:7])
    OB uart0_txd_pad (.I(uart0_txd_c), .O(uart0_txd));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(18[3:12])
    IB extclk_pad (.I(extclk), .O(extclk_c));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(15[3:9])
    IB extrst_pad (.I(extrst), .O(extrst_c));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(16[3:9])
    IB uart0_rxd_pad (.I(uart0_rxd), .O(uart0_rxd_c));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(17[3:12])
    LUT4 inv_7_i8_1_lut (.A(uart_send_char[7]), .Z(leds_7__N_9[7])) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(98[17:49])
    defparam inv_7_i8_1_lut.init = 16'h5555;
    LUT4 inv_7_i7_1_lut (.A(uart_send_char[6]), .Z(leds_7__N_9[6])) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(98[17:49])
    defparam inv_7_i7_1_lut.init = 16'h5555;
    LUT4 inv_7_i6_1_lut (.A(uart_send_char[5]), .Z(leds_7__N_9[5])) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(98[17:49])
    defparam inv_7_i6_1_lut.init = 16'h5555;
    LUT4 inv_7_i5_1_lut (.A(uart_send_char[4]), .Z(leds_7__N_9[4])) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(98[17:49])
    defparam inv_7_i5_1_lut.init = 16'h5555;
    LUT4 inv_7_i4_1_lut (.A(uart_send_char[3]), .Z(leds_7__N_9[3])) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(98[17:49])
    defparam inv_7_i4_1_lut.init = 16'h5555;
    LUT4 inv_7_i3_1_lut (.A(uart_send_char[2]), .Z(leds_7__N_9[2])) /* synthesis lut_function=(!(A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(98[17:49])
    defparam inv_7_i3_1_lut.init = 16'h5555;
    VLO i1 (.Z(GND_net));
    TSALL TSALL_INST (.TSALL(GND_net));
    GSR GSR_INST (.GSR(extrst_c));
    LUT4 m1_lut (.Z(n1618)) /* synthesis lut_function=1, syn_instantiated=1 */ ;
    defparam m1_lut.init = 16'hffff;
    PUR PUR_INST (.PUR(VCC_net));
    defparam PUR_INST.RST_PULSE = 1;
    \UART_Receiver(12000000,19200)  UART_Receiver0 (.extclk_c(extclk_c), .uart_receive_done(uart_receive_done), 
            .n1618(n1618), .uart0_rxd_c(uart0_rxd_c), .extrst_c(extrst_c), 
            .GND_net(GND_net), .uart_send_char({uart_send_char}));   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(77[18:31])
    
endmodule
//
// Verilog Description of module \UART_Sender(12000000,19200) 
//

module \UART_Sender(12000000,19200)  (GND_net, uart_receive_done, extclk_c, 
            uart_send_char, extrst_c, uart0_txd_c);
    input GND_net;
    input uart_receive_done;
    input extclk_c;
    input [7:0]uart_send_char;
    input extrst_c;
    output uart0_txd_c;
    
    wire extclk_c /* synthesis SET_AS_NETWORK=extclk_c, is_clock=1 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(15[3:9])
    
    wire n1494, n1490;
    wire [3:0]state;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(38[9:14])
    
    wire txd_N_117;
    wire [31:0]clkdiv;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(37[9:15])
    
    wire n24, n29, n50;
    wire [7:0]data_buffer;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(39[9:20])
    
    wire n1455, n1115;
    wire [31:0]n133;
    
    wire n1116, n1113, n1114, n1112, n593, n1509, extclk_c_enable_32, 
        extclk_c_enable_18, n1513, n1507, n1281, n1111, n1110, n1109, 
        n1108, n1503, n1107, n2;
    wire [31:0]n167;
    
    wire n1492, n1491, n1493, n1229, extclk_c_enable_30, n1521, 
        n61, n59, n1360, n56, n33, n58, n50_adj_240, n34, n1122, 
        n41, n54, n52, n38, txd_N_115, n1520, n1121, n1519, 
        n1120, n1512;
    wire [3:0]n1;
    
    wire n1119, n1368, n64, n1354, n1364, n1118, n1324, n1117;
    
    PFUMX i1284 (.BLUT(n1494), .ALUT(n1490), .C0(state[3]), .Z(txd_N_117));
    LUT4 i17_4_lut (.A(clkdiv[3]), .B(n24), .C(clkdiv[0]), .D(n29), 
         .Z(n50)) /* synthesis lut_function=(!(A+(B (C)+!B (C+!(D))))) */ ;
    defparam i17_4_lut.init = 16'h0504;
    LUT4 n2_bdd_4_lut (.A(data_buffer[6]), .B(state[1]), .C(state[0]), 
         .D(data_buffer[7]), .Z(n1490)) /* synthesis lut_function=(A (B+((D)+!C))+!A (B+(C (D)))) */ ;
    defparam n2_bdd_4_lut.init = 16'hfece;
    LUT4 state_1__bdd_4_lut_1286 (.A(state[1]), .B(state[3]), .C(state[2]), 
         .D(state[0]), .Z(n1455)) /* synthesis lut_function=(!(A (B (C+(D))+!B (D))+!A (B (C+(D))+!B ((D)+!C)))) */ ;
    defparam state_1__bdd_4_lut_1286.init = 16'h003e;
    CCU2D clkdiv_303_add_4_19 (.A0(clkdiv[17]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[18]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1115), .COUT(n1116), .S0(n133[17]), .S1(n133[18]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_19.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_19.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_19.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_19.INJECT1_1 = "NO";
    CCU2D clkdiv_303_add_4_15 (.A0(clkdiv[13]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[14]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1113), .COUT(n1114), .S0(n133[13]), .S1(n133[14]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_15.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_15.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_15.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_15.INJECT1_1 = "NO";
    CCU2D clkdiv_303_add_4_13 (.A0(clkdiv[11]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[12]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1112), .COUT(n1113), .S0(n133[11]), .S1(n133[12]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_13.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_13.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_13.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_13.INJECT1_1 = "NO";
    LUT4 i275_3_lut (.A(n593), .B(uart_receive_done), .C(n1509), .Z(extclk_c_enable_32)) /* synthesis lut_function=(!(A ((C)+!B)+!A !(B+(C)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(50[5] 92[12])
    defparam i275_3_lut.init = 16'h5c5c;
    FD1P3AX data_buffer_i0_i0 (.D(uart_send_char[0]), .SP(extclk_c_enable_18), 
            .CK(extclk_c), .Q(data_buffer[0])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=63, LSE_RLINE=63 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(49[4] 93[11])
    defparam data_buffer_i0_i0.GSR = "DISABLED";
    LUT4 i1_4_lut (.A(state[3]), .B(n1513), .C(n1507), .D(state[2]), 
         .Z(n1281)) /* synthesis lut_function=(!(A+(B (C+(D))+!B (C+!(D))))) */ ;
    defparam i1_4_lut.init = 16'h0104;
    CCU2D clkdiv_303_add_4_11 (.A0(clkdiv[9]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[10]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1111), .COUT(n1112), .S0(n133[9]), .S1(n133[10]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_11.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_11.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_11.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_11.INJECT1_1 = "NO";
    CCU2D clkdiv_303_add_4_9 (.A0(clkdiv[7]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[8]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1110), .COUT(n1111), .S0(n133[7]), .S1(n133[8]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_9.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_9.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_9.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_9.INJECT1_1 = "NO";
    CCU2D clkdiv_303_add_4_7 (.A0(clkdiv[5]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[6]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1109), .COUT(n1110), .S0(n133[5]), .S1(n133[6]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_7.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_7.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_7.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_7.INJECT1_1 = "NO";
    CCU2D clkdiv_303_add_4_5 (.A0(clkdiv[3]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[4]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1108), .COUT(n1109), .S0(n133[3]), .S1(n133[4]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_5.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_5.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_5.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_5.INJECT1_1 = "NO";
    FD1S3IX clkdiv_303__i0 (.D(n133[0]), .CK(extclk_c), .CD(n1503), .Q(clkdiv[0])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i0.GSR = "ENABLED";
    CCU2D clkdiv_303_add_4_3 (.A0(clkdiv[1]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[2]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1107), .COUT(n1108), .S0(n133[1]), .S1(n133[2]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_3.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_3.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_3.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_3.INJECT1_1 = "NO";
    CCU2D clkdiv_303_add_4_1 (.A0(GND_net), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[0]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .COUT(n1107), .S1(n133[0]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_1.INIT0 = 16'hF000;
    defparam clkdiv_303_add_4_1.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_1.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_1.INJECT1_1 = "NO";
    LUT4 state_3__I_0_i2_3_lut (.A(data_buffer[0]), .B(data_buffer[1]), 
         .C(state[0]), .Z(n2)) /* synthesis lut_function=(A (B+!(C))+!A (B (C))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(71[7] 87[16])
    defparam state_3__I_0_i2_3_lut.init = 16'hcaca;
    LUT4 i951_2_lut_3_lut_3_lut (.A(n1509), .B(n133[5]), .C(n593), .Z(n167[5])) /* synthesis lut_function=((B+!(C))+!A) */ ;
    defparam i951_2_lut_3_lut_3_lut.init = 16'hdfdf;
    PFUMX i1282 (.BLUT(n1492), .ALUT(n1491), .C0(state[1]), .Z(n1493));
    LUT4 i950_2_lut_3_lut_3_lut (.A(n1509), .B(n133[4]), .C(n593), .Z(n167[4])) /* synthesis lut_function=((B+!(C))+!A) */ ;
    defparam i950_2_lut_3_lut_3_lut.init = 16'hdfdf;
    CCU2D clkdiv_303_add_4_17 (.A0(clkdiv[15]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[16]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1114), .COUT(n1115), .S0(n133[15]), .S1(n133[16]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_17.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_17.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_17.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_17.INJECT1_1 = "NO";
    LUT4 i953_2_lut_3_lut_3_lut (.A(n1509), .B(n133[9]), .C(n593), .Z(n167[9])) /* synthesis lut_function=((B+!(C))+!A) */ ;
    defparam i953_2_lut_3_lut_3_lut.init = 16'hdfdf;
    LUT4 i952_2_lut_3_lut_3_lut (.A(n1509), .B(n133[6]), .C(n593), .Z(n167[6])) /* synthesis lut_function=((B+!(C))+!A) */ ;
    defparam i952_2_lut_3_lut_3_lut.init = 16'hdfdf;
    LUT4 i1255_3_lut_4_lut_4_lut (.A(n1509), .B(extrst_c), .C(n1229), 
         .D(n593), .Z(extclk_c_enable_30)) /* synthesis lut_function=(!(A ((C+(D))+!B)+!A ((C)+!B))) */ ;
    defparam i1255_3_lut_4_lut_4_lut.init = 16'h040c;
    LUT4 i217_2_lut_3_lut (.A(uart_receive_done), .B(n1509), .C(extrst_c), 
         .Z(extclk_c_enable_18)) /* synthesis lut_function=(!((B+!(C))+!A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(50[5] 92[12])
    defparam i217_2_lut_3_lut.init = 16'h2020;
    LUT4 i1_2_lut (.A(state[2]), .B(state[3]), .Z(n24)) /* synthesis lut_function=(A (B)) */ ;
    defparam i1_2_lut.init = 16'h8888;
    FD1P3AX state_i0_i2 (.D(n1281), .SP(extclk_c_enable_32), .CK(extclk_c), 
            .Q(state[2])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=63, LSE_RLINE=63 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(49[4] 93[11])
    defparam state_i0_i2.GSR = "ENABLED";
    FD1P3AX state_i0_i1 (.D(n1521), .SP(extclk_c_enable_32), .CK(extclk_c), 
            .Q(state[1])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=63, LSE_RLINE=63 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(49[4] 93[11])
    defparam state_i0_i1.GSR = "ENABLED";
    LUT4 data_buffer_2__bdd_3_lut_1291 (.A(data_buffer[2]), .B(data_buffer[3]), 
         .C(state[0]), .Z(n1492)) /* synthesis lut_function=(A (B+!(C))+!A (B (C))) */ ;
    defparam data_buffer_2__bdd_3_lut_1291.init = 16'hcaca;
    LUT4 i31_4_lut (.A(n61), .B(n59), .C(n1360), .D(n56), .Z(n593)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(68[9:19])
    defparam i31_4_lut.init = 16'hfffe;
    LUT4 i29_4_lut (.A(n33), .B(n58), .C(n50_adj_240), .D(n34), .Z(n61)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(68[9:19])
    defparam i29_4_lut.init = 16'hfffe;
    CCU2D clkdiv_303_add_4_33 (.A0(clkdiv[31]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(GND_net), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1122), .S0(n133[31]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_33.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_33.INIT1 = 16'h0000;
    defparam clkdiv_303_add_4_33.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_33.INJECT1_1 = "NO";
    LUT4 i27_4_lut (.A(n41), .B(n54), .C(clkdiv[3]), .D(clkdiv[21]), 
         .Z(n59)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(68[9:19])
    defparam i27_4_lut.init = 16'hfffe;
    FD1P3AX data_buffer_i0_i1 (.D(uart_send_char[1]), .SP(extclk_c_enable_18), 
            .CK(extclk_c), .Q(data_buffer[1])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=63, LSE_RLINE=63 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(49[4] 93[11])
    defparam data_buffer_i0_i1.GSR = "DISABLED";
    LUT4 i24_4_lut (.A(clkdiv[31]), .B(clkdiv[7]), .C(clkdiv[30]), .D(clkdiv[29]), 
         .Z(n56)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(68[9:19])
    defparam i24_4_lut.init = 16'hfffe;
    LUT4 i1_2_lut_adj_18 (.A(clkdiv[0]), .B(clkdiv[28]), .Z(n33)) /* synthesis lut_function=(A+(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(68[9:19])
    defparam i1_2_lut_adj_18.init = 16'heeee;
    LUT4 i26_4_lut (.A(clkdiv[10]), .B(n52), .C(n38), .D(clkdiv[2]), 
         .Z(n58)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(68[9:19])
    defparam i26_4_lut.init = 16'hfffe;
    FD1P3AX data_buffer_i0_i2 (.D(uart_send_char[2]), .SP(extclk_c_enable_18), 
            .CK(extclk_c), .Q(data_buffer[2])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=63, LSE_RLINE=63 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(49[4] 93[11])
    defparam data_buffer_i0_i2.GSR = "DISABLED";
    FD1P3AX data_buffer_i0_i3 (.D(uart_send_char[3]), .SP(extclk_c_enable_18), 
            .CK(extclk_c), .Q(data_buffer[3])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=63, LSE_RLINE=63 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(49[4] 93[11])
    defparam data_buffer_i0_i3.GSR = "DISABLED";
    FD1P3AX data_buffer_i0_i4 (.D(uart_send_char[4]), .SP(extclk_c_enable_18), 
            .CK(extclk_c), .Q(data_buffer[4])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=63, LSE_RLINE=63 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(49[4] 93[11])
    defparam data_buffer_i0_i4.GSR = "DISABLED";
    FD1P3AX data_buffer_i0_i5 (.D(uart_send_char[5]), .SP(extclk_c_enable_18), 
            .CK(extclk_c), .Q(data_buffer[5])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=63, LSE_RLINE=63 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(49[4] 93[11])
    defparam data_buffer_i0_i5.GSR = "DISABLED";
    FD1P3AX data_buffer_i0_i6 (.D(uart_send_char[6]), .SP(extclk_c_enable_18), 
            .CK(extclk_c), .Q(data_buffer[6])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=63, LSE_RLINE=63 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(49[4] 93[11])
    defparam data_buffer_i0_i6.GSR = "DISABLED";
    FD1P3AX data_buffer_i0_i7 (.D(uart_send_char[7]), .SP(extclk_c_enable_18), 
            .CK(extclk_c), .Q(data_buffer[7])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=63, LSE_RLINE=63 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(49[4] 93[11])
    defparam data_buffer_i0_i7.GSR = "DISABLED";
    FD1S3IX clkdiv_303__i1 (.D(n133[1]), .CK(extclk_c), .CD(n1503), .Q(clkdiv[1])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i1.GSR = "ENABLED";
    LUT4 i1_4_lut_adj_19 (.A(state[0]), .B(state[2]), .C(state[3]), .D(state[1]), 
         .Z(n29)) /* synthesis lut_function=(A (B (C (D))+!B (C (D)+!C !(D)))) */ ;
    defparam i1_4_lut_adj_19.init = 16'ha002;
    LUT4 data_buffer_2__bdd_3_lut_1281 (.A(data_buffer[4]), .B(state[0]), 
         .C(data_buffer[5]), .Z(n1491)) /* synthesis lut_function=(A ((C)+!B)+!A (B (C))) */ ;
    defparam data_buffer_2__bdd_3_lut_1281.init = 16'he2e2;
    LUT4 txd_I_2_4_lut (.A(txd_N_117), .B(uart_receive_done), .C(n1509), 
         .D(n593), .Z(txd_N_115)) /* synthesis lut_function=(!(A (B ((D)+!C)+!B (C (D)))+!A (B+(C)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(50[5] 92[12])
    defparam txd_I_2_4_lut.init = 16'h03a3;
    LUT4 n1496_bdd_2_lut_3_lut_then_4_lut (.A(state[3]), .B(state[1]), .C(state[0]), 
         .D(state[2]), .Z(n1520)) /* synthesis lut_function=(!(A (B (C+(D))+!B ((D)+!C))+!A (B (C)+!B !(C (D)+!C !(D))))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(50[5] 92[12])
    defparam n1496_bdd_2_lut_3_lut_then_4_lut.init = 16'h142d;
    CCU2D clkdiv_303_add_4_31 (.A0(clkdiv[29]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[30]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1121), .COUT(n1122), .S0(n133[29]), .S1(n133[30]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_31.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_31.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_31.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_31.INJECT1_1 = "NO";
    LUT4 n1496_bdd_2_lut_3_lut_else_4_lut (.A(state[3]), .B(state[1]), .C(state[0]), 
         .D(state[2]), .Z(n1519)) /* synthesis lut_function=(!(A (B (C+(D))+!B ((D)+!C))+!A (B (C)+!B !(C (D))))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(50[5] 92[12])
    defparam n1496_bdd_2_lut_3_lut_else_4_lut.init = 16'h142c;
    LUT4 i18_4_lut (.A(clkdiv[9]), .B(clkdiv[12]), .C(clkdiv[27]), .D(clkdiv[17]), 
         .Z(n50_adj_240)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(68[9:19])
    defparam i18_4_lut.init = 16'hfffe;
    LUT4 i20_4_lut (.A(clkdiv[24]), .B(clkdiv[4]), .C(clkdiv[1]), .D(clkdiv[20]), 
         .Z(n52)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(68[9:19])
    defparam i20_4_lut.init = 16'hfffe;
    LUT4 i6_2_lut (.A(clkdiv[8]), .B(clkdiv[16]), .Z(n38)) /* synthesis lut_function=(A+(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(68[9:19])
    defparam i6_2_lut.init = 16'heeee;
    LUT4 i9_2_lut (.A(clkdiv[5]), .B(clkdiv[6]), .Z(n41)) /* synthesis lut_function=(A+(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(68[9:19])
    defparam i9_2_lut.init = 16'heeee;
    LUT4 i22_4_lut (.A(clkdiv[25]), .B(clkdiv[14]), .C(clkdiv[26]), .D(clkdiv[19]), 
         .Z(n54)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(68[9:19])
    defparam i22_4_lut.init = 16'hfffe;
    LUT4 i1228_4_lut (.A(clkdiv[22]), .B(clkdiv[15]), .C(clkdiv[13]), 
         .D(clkdiv[23]), .Z(n1360)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;
    defparam i1228_4_lut.init = 16'hfffe;
    CCU2D clkdiv_303_add_4_29 (.A0(clkdiv[27]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[28]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1120), .COUT(n1121), .S0(n133[27]), .S1(n133[28]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_29.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_29.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_29.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_29.INJECT1_1 = "NO";
    LUT4 i1266_2_lut_rep_30_2_lut_4_lut (.A(n1512), .B(state[0]), .C(state[2]), 
         .D(n593), .Z(n1503)) /* synthesis lut_function=(!(A (D)+!A (B (D)+!B (C (D))))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(50[8:26])
    defparam i1266_2_lut_rep_30_2_lut_4_lut.init = 16'h01ff;
    FD1P3IX state_i0_i3 (.D(n1[3]), .SP(extclk_c_enable_32), .CD(n1507), 
            .CK(extclk_c), .Q(state[3])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=63, LSE_RLINE=63 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(49[4] 93[11])
    defparam state_i0_i3.GSR = "ENABLED";
    LUT4 i208_2_lut_rep_34_4_lut (.A(n1512), .B(state[0]), .C(state[2]), 
         .D(uart_receive_done), .Z(n1507)) /* synthesis lut_function=(!(A+(B+(C+!(D))))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(50[8:26])
    defparam i208_2_lut_rep_34_4_lut.init = 16'h0100;
    LUT4 i2_2_lut (.A(clkdiv[18]), .B(clkdiv[11]), .Z(n34)) /* synthesis lut_function=(A+(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(68[9:19])
    defparam i2_2_lut.init = 16'heeee;
    LUT4 i1_2_lut_rep_39 (.A(state[1]), .B(state[3]), .Z(n1512)) /* synthesis lut_function=(A+(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(50[8:26])
    defparam i1_2_lut_rep_39.init = 16'heeee;
    CCU2D clkdiv_303_add_4_27 (.A0(clkdiv[25]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[26]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1119), .COUT(n1120), .S0(n133[25]), .S1(n133[26]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_27.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_27.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_27.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_27.INJECT1_1 = "NO";
    LUT4 i31_4_lut_adj_20 (.A(n1368), .B(n52), .C(n41), .D(n50), .Z(n64)) /* synthesis lut_function=(!(A+(B+(C+!(D))))) */ ;
    defparam i31_4_lut_adj_20.init = 16'h0100;
    LUT4 i2_3_lut_rep_36_4_lut (.A(state[1]), .B(state[3]), .C(state[2]), 
         .D(state[0]), .Z(n1509)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(50[8:26])
    defparam i2_3_lut_rep_36_4_lut.init = 16'hfffe;
    LUT4 i32_4_lut (.A(n1354), .B(n64), .C(n1364), .D(n54), .Z(n1229)) /* synthesis lut_function=(!(A+((C+(D))+!B))) */ ;
    defparam i32_4_lut.init = 16'h0004;
    LUT4 i898_2_lut_rep_40 (.A(state[0]), .B(state[1]), .Z(n1513)) /* synthesis lut_function=(A (B)) */ ;
    defparam i898_2_lut_rep_40.init = 16'h8888;
    LUT4 mux_13_Mux_3_i15_4_lut_3_lut_4_lut (.A(state[0]), .B(state[1]), 
         .C(state[3]), .D(state[2]), .Z(n1[3])) /* synthesis lut_function=(!(A (B (C+!(D))+!B ((D)+!C))+!A ((D)+!C))) */ ;
    defparam mux_13_Mux_3_i15_4_lut_3_lut_4_lut.init = 16'h0870;
    LUT4 i1232_4_lut (.A(clkdiv[28]), .B(clkdiv[27]), .C(clkdiv[9]), .D(clkdiv[21]), 
         .Z(n1364)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;
    defparam i1232_4_lut.init = 16'hfffe;
    CCU2D clkdiv_303_add_4_25 (.A0(clkdiv[23]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[24]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1118), .COUT(n1119), .S0(n133[23]), .S1(n133[24]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_25.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_25.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_25.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_25.INJECT1_1 = "NO";
    LUT4 i1192_4_lut (.A(clkdiv[29]), .B(clkdiv[17]), .C(clkdiv[12]), 
         .D(clkdiv[10]), .Z(n1324)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;
    defparam i1192_4_lut.init = 16'hfffe;
    CCU2D clkdiv_303_add_4_23 (.A0(clkdiv[21]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[22]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1117), .COUT(n1118), .S0(n133[21]), .S1(n133[22]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_23.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_23.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_23.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_23.INJECT1_1 = "NO";
    LUT4 n2_bdd_3_lut (.A(n2), .B(n1493), .C(state[2]), .Z(n1494)) /* synthesis lut_function=(A (B+!(C))+!A (B (C))) */ ;
    defparam n2_bdd_3_lut.init = 16'hcaca;
    FD1P3AX txd_33 (.D(txd_N_115), .SP(extclk_c_enable_30), .CK(extclk_c), 
            .Q(uart0_txd_c)) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=63, LSE_RLINE=63 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(49[4] 93[11])
    defparam txd_33.GSR = "DISABLED";
    FD1P3AX state_i0_i0 (.D(n1455), .SP(extclk_c_enable_32), .CK(extclk_c), 
            .Q(state[0])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=16, LSE_RCOL=27, LSE_LLINE=63, LSE_RLINE=63 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_sender.vhd(49[4] 93[11])
    defparam state_i0_i0.GSR = "ENABLED";
    LUT4 i1236_4_lut (.A(n1360), .B(clkdiv[31]), .C(n38), .D(clkdiv[2]), 
         .Z(n1368)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;
    defparam i1236_4_lut.init = 16'hfffe;
    LUT4 i1222_4_lut (.A(n34), .B(n1324), .C(clkdiv[30]), .D(clkdiv[7]), 
         .Z(n1354)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;
    defparam i1222_4_lut.init = 16'hfffe;
    PFUMX i1289 (.BLUT(n1519), .ALUT(n1520), .C0(uart_receive_done), .Z(n1521));
    CCU2D clkdiv_303_add_4_21 (.A0(clkdiv[19]), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(clkdiv[20]), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n1116), .COUT(n1117), .S0(n133[19]), .S1(n133[20]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303_add_4_21.INIT0 = 16'h0555;
    defparam clkdiv_303_add_4_21.INIT1 = 16'h0555;
    defparam clkdiv_303_add_4_21.INJECT1_0 = "NO";
    defparam clkdiv_303_add_4_21.INJECT1_1 = "NO";
    FD1S3IX clkdiv_303__i2 (.D(n133[2]), .CK(extclk_c), .CD(n1503), .Q(clkdiv[2])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i2.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i3 (.D(n133[3]), .CK(extclk_c), .CD(n1503), .Q(clkdiv[3])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i3.GSR = "ENABLED";
    FD1S3AX clkdiv_303__i4 (.D(n167[4]), .CK(extclk_c), .Q(clkdiv[4])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i4.GSR = "ENABLED";
    FD1S3AX clkdiv_303__i5 (.D(n167[5]), .CK(extclk_c), .Q(clkdiv[5])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i5.GSR = "ENABLED";
    FD1S3AX clkdiv_303__i6 (.D(n167[6]), .CK(extclk_c), .Q(clkdiv[6])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i6.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i7 (.D(n133[7]), .CK(extclk_c), .CD(n1503), .Q(clkdiv[7])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i7.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i8 (.D(n133[8]), .CK(extclk_c), .CD(n1503), .Q(clkdiv[8])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i8.GSR = "ENABLED";
    FD1S3AX clkdiv_303__i9 (.D(n167[9]), .CK(extclk_c), .Q(clkdiv[9])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i9.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i10 (.D(n133[10]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[10])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i10.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i11 (.D(n133[11]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[11])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i11.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i12 (.D(n133[12]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[12])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i12.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i13 (.D(n133[13]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[13])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i13.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i14 (.D(n133[14]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[14])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i14.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i15 (.D(n133[15]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[15])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i15.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i16 (.D(n133[16]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[16])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i16.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i17 (.D(n133[17]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[17])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i17.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i18 (.D(n133[18]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[18])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i18.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i19 (.D(n133[19]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[19])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i19.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i20 (.D(n133[20]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[20])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i20.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i21 (.D(n133[21]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[21])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i21.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i22 (.D(n133[22]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[22])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i22.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i23 (.D(n133[23]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[23])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i23.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i24 (.D(n133[24]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[24])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i24.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i25 (.D(n133[25]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[25])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i25.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i26 (.D(n133[26]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[26])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i26.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i27 (.D(n133[27]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[27])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i27.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i28 (.D(n133[28]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[28])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i28.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i29 (.D(n133[29]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[29])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i29.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i30 (.D(n133[30]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[30])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i30.GSR = "ENABLED";
    FD1S3IX clkdiv_303__i31 (.D(n133[31]), .CK(extclk_c), .CD(n1503), 
            .Q(clkdiv[31])) /* synthesis syn_use_carry_chain=1 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam clkdiv_303__i31.GSR = "ENABLED";
    
endmodule
//
// Verilog Description of module TSALL
// module not written out since it is a black-box. 
//

//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

//
// Verilog Description of module \UART_Receiver(12000000,19200) 
//

module \UART_Receiver(12000000,19200)  (extclk_c, uart_receive_done, n1618, 
            uart0_rxd_c, extrst_c, GND_net, uart_send_char);
    input extclk_c;
    output uart_receive_done;
    input n1618;
    input uart0_rxd_c;
    input extrst_c;
    input GND_net;
    output [7:0]uart_send_char;
    
    wire extclk_c /* synthesis SET_AS_NETWORK=extclk_c, is_clock=1 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/root.vhd(15[3:9])
    wire [3:0]state;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(26[9:14])
    
    wire n1313;
    wire [7:0]data_buffer;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(27[9:20])
    
    wire extclk_c_enable_1;
    wire [7:0]n25;
    wire [31:0]clkdiv;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(25[9:15])
    
    wire n1500;
    wire [31:0]n331;
    
    wire n1508, n1505;
    wire [31:0]clkdiv_31__N_130;
    
    wire extclk_c_enable_2;
    wire [31:0]clkdiv_31__N_176;
    
    wire n1502, n555, extclk_c_enable_5, extclk_c_enable_9, n1488, 
        n1106, n1290, n1105, n1504, extclk_c_enable_28, n1510, extclk_c_enable_19, 
        n1104, n1103, n1102, n1487, n1101, n1499, n1506, n1517, 
        extclk_c_enable_4, n14, extclk_c_enable_6, extclk_c_enable_7, 
        extclk_c_enable_8, n1501, n1514, n1511, n319, n1516, n1291, 
        n1100, n1099, n1295, n1098, n1515, n1097, n1096, n1294, 
        n1095, n1489, n1306, n56, n46, n60, extclk_c_enable_34, 
        n1292, n1094, n1093, extclk_c_enable_22, n1518, n1293, n1303, 
        n49, n41, n54, n42, n62, n52, n38, n58, n50, extclk_c_enable_24, 
        n1296, n9, n1092, n1297, n1091;
    
    LUT4 i1_2_lut (.A(state[0]), .B(state[1]), .Z(n1313)) /* synthesis lut_function=(A+!(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(58[7] 83[16])
    defparam i1_2_lut.init = 16'hbbbb;
    FD1P3AX data_buffer_i0_i0 (.D(n25[0]), .SP(extclk_c_enable_1), .CK(extclk_c), 
            .Q(data_buffer[0])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_buffer_i0_i0.GSR = "DISABLED";
    FD1S3IX clkdiv_i30 (.D(n331[30]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[30])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i30.GSR = "ENABLED";
    FD1S3IX clkdiv_i29 (.D(n331[29]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[29])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i29.GSR = "ENABLED";
    FD1S3IX clkdiv_i28 (.D(n331[28]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[28])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i28.GSR = "ENABLED";
    FD1S3IX clkdiv_i27 (.D(n331[27]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[27])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i27.GSR = "ENABLED";
    FD1S3IX clkdiv_i26 (.D(n331[26]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[26])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i26.GSR = "ENABLED";
    LUT4 i891_3_lut (.A(n331[8]), .B(n1508), .C(n1505), .Z(clkdiv_31__N_130[8])) /* synthesis lut_function=(A (B+(C))+!A (B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(39[5] 88[12])
    defparam i891_3_lut.init = 16'hecec;
    FD1S3IX clkdiv_i0 (.D(n331[0]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[0])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i0.GSR = "ENABLED";
    FD1S3IX clkdiv_i25 (.D(n331[25]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[25])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i25.GSR = "ENABLED";
    FD1S3IX clkdiv_i24 (.D(n331[24]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[24])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i24.GSR = "ENABLED";
    FD1S3IX clkdiv_i23 (.D(n331[23]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[23])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i23.GSR = "ENABLED";
    FD1S3IX clkdiv_i22 (.D(n331[22]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[22])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i22.GSR = "ENABLED";
    FD1S3IX clkdiv_i21 (.D(n331[21]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[21])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i21.GSR = "ENABLED";
    FD1S3IX clkdiv_i20 (.D(n331[20]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[20])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i20.GSR = "ENABLED";
    FD1S3IX clkdiv_i19 (.D(n331[19]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[19])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i19.GSR = "ENABLED";
    FD1S3IX clkdiv_i18 (.D(n331[18]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[18])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i18.GSR = "ENABLED";
    FD1S3IX clkdiv_i17 (.D(n331[17]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[17])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i17.GSR = "ENABLED";
    FD1S3IX clkdiv_i16 (.D(n331[16]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[16])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i16.GSR = "ENABLED";
    FD1S3IX clkdiv_i15 (.D(n331[15]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[15])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i15.GSR = "ENABLED";
    FD1S3IX clkdiv_i14 (.D(n331[14]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[14])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i14.GSR = "ENABLED";
    FD1S3IX clkdiv_i13 (.D(n331[13]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[13])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i13.GSR = "ENABLED";
    FD1S3IX clkdiv_i12 (.D(n331[12]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[12])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i12.GSR = "ENABLED";
    FD1S3IX clkdiv_i11 (.D(n331[11]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[11])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i11.GSR = "ENABLED";
    FD1S3IX clkdiv_i10 (.D(n331[10]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[10])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i10.GSR = "ENABLED";
    FD1P3IX recv_40 (.D(n1618), .SP(extclk_c_enable_2), .CD(n1508), .CK(extclk_c), 
            .Q(uart_receive_done)) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam recv_40.GSR = "ENABLED";
    FD1S3IX clkdiv_i9 (.D(clkdiv_31__N_176[9]), .CK(extclk_c), .CD(n1508), 
            .Q(clkdiv[9])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i9.GSR = "ENABLED";
    FD1S3AX clkdiv_i8 (.D(clkdiv_31__N_130[8]), .CK(extclk_c), .Q(clkdiv[8])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i8.GSR = "ENABLED";
    FD1S3IX clkdiv_i7 (.D(n331[7]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[7])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i7.GSR = "ENABLED";
    FD1S3IX clkdiv_i6 (.D(clkdiv_31__N_176[6]), .CK(extclk_c), .CD(n1508), 
            .Q(clkdiv[6])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i6.GSR = "ENABLED";
    FD1S3AX clkdiv_i5 (.D(clkdiv_31__N_130[5]), .CK(extclk_c), .Q(clkdiv[5])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i5.GSR = "ENABLED";
    FD1S3AX clkdiv_i4 (.D(clkdiv_31__N_130[4]), .CK(extclk_c), .Q(clkdiv[4])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i4.GSR = "ENABLED";
    FD1S3AX clkdiv_i3 (.D(clkdiv_31__N_130[3]), .CK(extclk_c), .Q(clkdiv[3])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i3.GSR = "ENABLED";
    FD1S3IX clkdiv_i2 (.D(n331[2]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[2])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i2.GSR = "ENABLED";
    FD1S3IX clkdiv_i1 (.D(n331[1]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[1])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i1.GSR = "ENABLED";
    LUT4 i902_2_lut (.A(n331[6]), .B(n1505), .Z(clkdiv_31__N_176[6])) /* synthesis lut_function=(A+!(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[6] 87[13])
    defparam i902_2_lut.init = 16'hbbbb;
    LUT4 i1_4_lut_4_lut (.A(n1502), .B(state[2]), .C(n555), .D(state[3]), 
         .Z(extclk_c_enable_5)) /* synthesis lut_function=(A (B (C+(D))+!B (C (D)))) */ ;
    defparam i1_4_lut_4_lut.init = 16'ha880;
    LUT4 i1_4_lut_4_lut_adj_4 (.A(n1502), .B(state[2]), .C(n555), .D(state[3]), 
         .Z(extclk_c_enable_9)) /* synthesis lut_function=(A (B (D)+!B (C))) */ ;
    defparam i1_4_lut_4_lut_adj_4.init = 16'ha820;
    LUT4 state_3__bdd_4_lut (.A(state[3]), .B(state[0]), .C(uart0_rxd_c), 
         .D(state[2]), .Z(n1488)) /* synthesis lut_function=(!(A ((D)+!B)+!A !(B ((D)+!C)))) */ ;
    defparam state_3__bdd_4_lut.init = 16'h448c;
    LUT4 i897_3_lut (.A(n331[3]), .B(n1508), .C(n1505), .Z(clkdiv_31__N_130[3])) /* synthesis lut_function=(A (B+(C))+!A (B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(39[5] 88[12])
    defparam i897_3_lut.init = 16'hecec;
    LUT4 i2_3_lut_rep_29 (.A(extrst_c), .B(n1508), .C(n1505), .Z(n1502)) /* synthesis lut_function=(!((B+(C))+!A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(32[4] 90[10])
    defparam i2_3_lut_rep_29.init = 16'h0202;
    CCU2D add_49_33 (.A0(clkdiv[31]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(GND_net), .B1(GND_net), .C1(GND_net), .D1(GND_net), .CIN(n1106), 
          .S0(n331[31]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_33.INIT0 = 16'h5555;
    defparam add_49_33.INIT1 = 16'h0000;
    defparam add_49_33.INJECT1_0 = "NO";
    defparam add_49_33.INJECT1_1 = "NO";
    LUT4 i1_2_lut_3_lut (.A(state[0]), .B(state[2]), .C(data_buffer[2]), 
         .Z(n1290)) /* synthesis lut_function=(!(A+(B+!(C)))) */ ;
    defparam i1_2_lut_3_lut.init = 16'h1010;
    CCU2D add_49_31 (.A0(clkdiv[29]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[30]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1105), .COUT(n1106), .S0(n331[29]), .S1(n331[30]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_31.INIT0 = 16'h5555;
    defparam add_49_31.INIT1 = 16'h5555;
    defparam add_49_31.INJECT1_0 = "NO";
    defparam add_49_31.INJECT1_1 = "NO";
    LUT4 i1275_4_lut (.A(n1504), .B(extclk_c_enable_28), .C(state[1]), 
         .D(n1510), .Z(extclk_c_enable_19)) /* synthesis lut_function=(A (B (C+(D)))+!A (B)) */ ;
    defparam i1275_4_lut.init = 16'hccc4;
    CCU2D add_49_29 (.A0(clkdiv[27]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[28]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1104), .COUT(n1105), .S0(n331[27]), .S1(n331[28]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_29.INIT0 = 16'h5555;
    defparam add_49_29.INIT1 = 16'h5555;
    defparam add_49_29.INJECT1_0 = "NO";
    defparam add_49_29.INJECT1_1 = "NO";
    CCU2D add_49_27 (.A0(clkdiv[25]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[26]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1103), .COUT(n1104), .S0(n331[25]), .S1(n331[26]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_27.INIT0 = 16'h5555;
    defparam add_49_27.INIT1 = 16'h5555;
    defparam add_49_27.INJECT1_0 = "NO";
    defparam add_49_27.INJECT1_1 = "NO";
    CCU2D add_49_25 (.A0(clkdiv[23]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[24]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1102), .COUT(n1103), .S0(n331[23]), .S1(n331[24]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_25.INIT0 = 16'h5555;
    defparam add_49_25.INIT1 = 16'h5555;
    defparam add_49_25.INJECT1_0 = "NO";
    defparam add_49_25.INJECT1_1 = "NO";
    LUT4 state_3__bdd_2_lut (.A(state[3]), .B(state[0]), .Z(n1487)) /* synthesis lut_function=(!(A+(B))) */ ;
    defparam state_3__bdd_2_lut.init = 16'h1111;
    CCU2D add_49_23 (.A0(clkdiv[21]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[22]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1101), .COUT(n1102), .S0(n331[21]), .S1(n331[22]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_23.INIT0 = 16'h5555;
    defparam add_49_23.INIT1 = 16'h5555;
    defparam add_49_23.INJECT1_0 = "NO";
    defparam add_49_23.INJECT1_1 = "NO";
    LUT4 i915_2_lut (.A(state[0]), .B(state[1]), .Z(n555)) /* synthesis lut_function=(A (B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(58[7] 83[16])
    defparam i915_2_lut.init = 16'h8888;
    LUT4 i405_2_lut_rep_26_4_lut (.A(extrst_c), .B(n1508), .C(n1505), 
         .D(state[3]), .Z(n1499)) /* synthesis lut_function=(!((B+(C+!(D)))+!A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(32[4] 90[10])
    defparam i405_2_lut_rep_26_4_lut.init = 16'h0200;
    LUT4 i913_4_lut_then_4_lut (.A(n1506), .B(state[3]), .C(state[0]), 
         .D(state[1]), .Z(n1517)) /* synthesis lut_function=(!((B+!(C (D)))+!A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(39[5] 88[12])
    defparam i913_4_lut_then_4_lut.init = 16'h2000;
    FD1P3AX data_buffer_i0_i6 (.D(n14), .SP(extclk_c_enable_4), .CK(extclk_c), 
            .Q(data_buffer[6])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_buffer_i0_i6.GSR = "DISABLED";
    FD1P3AX data_buffer_i0_i5 (.D(n25[0]), .SP(extclk_c_enable_5), .CK(extclk_c), 
            .Q(data_buffer[5])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_buffer_i0_i5.GSR = "DISABLED";
    FD1P3AX data_buffer_i0_i4 (.D(n25[0]), .SP(extclk_c_enable_6), .CK(extclk_c), 
            .Q(data_buffer[4])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_buffer_i0_i4.GSR = "DISABLED";
    FD1P3AX data_buffer_i0_i3 (.D(n25[0]), .SP(extclk_c_enable_7), .CK(extclk_c), 
            .Q(data_buffer[3])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_buffer_i0_i3.GSR = "DISABLED";
    FD1P3AX data_buffer_i0_i2 (.D(n25[0]), .SP(extclk_c_enable_8), .CK(extclk_c), 
            .Q(data_buffer[2])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_buffer_i0_i2.GSR = "DISABLED";
    FD1P3AX data_buffer_i0_i1 (.D(n25[0]), .SP(extclk_c_enable_9), .CK(extclk_c), 
            .Q(data_buffer[1])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_buffer_i0_i1.GSR = "DISABLED";
    LUT4 i1_4_lut (.A(state[2]), .B(n1501), .C(state[3]), .D(n1313), 
         .Z(extclk_c_enable_1)) /* synthesis lut_function=(A (B (C))+!A (B (C+!(D)))) */ ;
    defparam i1_4_lut.init = 16'hc0c4;
    LUT4 i1252_2_lut_rep_27_2_lut_4_lut (.A(state[2]), .B(n1514), .C(state[3]), 
         .D(n1505), .Z(n1500)) /* synthesis lut_function=(!(A (D)+!A (B (D)+!B (C (D))))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(39[8:20])
    defparam i1252_2_lut_rep_27_2_lut_4_lut.init = 16'h01ff;
    LUT4 i885_4_lut (.A(state[0]), .B(n1506), .C(n1511), .D(state[3]), 
         .Z(n319)) /* synthesis lut_function=(!(A (B)+!A (B (C (D)+!C !(D))))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(39[5] 88[12])
    defparam i885_4_lut.init = 16'h3773;
    LUT4 i913_4_lut_else_4_lut (.A(n1506), .B(state[3]), .C(state[1]), 
         .Z(n1516)) /* synthesis lut_function=(!(((C)+!B)+!A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(39[5] 88[12])
    defparam i913_4_lut_else_4_lut.init = 16'h0808;
    LUT4 i886_2_lut_rep_33_4_lut (.A(state[2]), .B(n1514), .C(state[3]), 
         .D(uart0_rxd_c), .Z(n1506)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(39[8:20])
    defparam i886_2_lut_rep_33_4_lut.init = 16'hfffe;
    LUT4 i1_2_lut_3_lut_adj_5 (.A(state[0]), .B(state[2]), .C(data_buffer[3]), 
         .Z(n1291)) /* synthesis lut_function=(!(A+(B+!(C)))) */ ;
    defparam i1_2_lut_3_lut_adj_5.init = 16'h1010;
    CCU2D add_49_21 (.A0(clkdiv[19]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[20]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1100), .COUT(n1101), .S0(n331[19]), .S1(n331[20]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_21.INIT0 = 16'h5555;
    defparam add_49_21.INIT1 = 16'h5555;
    defparam add_49_21.INJECT1_0 = "NO";
    defparam add_49_21.INJECT1_1 = "NO";
    CCU2D add_49_19 (.A0(clkdiv[17]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[18]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1099), .COUT(n1100), .S0(n331[17]), .S1(n331[18]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_19.INIT0 = 16'h5555;
    defparam add_49_19.INIT1 = 16'h5555;
    defparam add_49_19.INJECT1_0 = "NO";
    defparam add_49_19.INJECT1_1 = "NO";
    LUT4 i916_2_lut (.A(uart0_rxd_c), .B(state[3]), .Z(n25[0])) /* synthesis lut_function=(!((B)+!A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(58[7] 83[16])
    defparam i916_2_lut.init = 16'h2222;
    LUT4 i1_2_lut_3_lut_adj_6 (.A(state[0]), .B(state[2]), .C(data_buffer[4]), 
         .Z(n1295)) /* synthesis lut_function=(!(A+(B+!(C)))) */ ;
    defparam i1_2_lut_3_lut_adj_6.init = 16'h1010;
    CCU2D add_49_17 (.A0(clkdiv[15]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[16]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1098), .COUT(n1099), .S0(n331[15]), .S1(n331[16]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_17.INIT0 = 16'h5555;
    defparam add_49_17.INIT1 = 16'h5555;
    defparam add_49_17.INJECT1_0 = "NO";
    defparam add_49_17.INJECT1_1 = "NO";
    LUT4 i1_4_lut_adj_7 (.A(state[2]), .B(n1501), .C(state[3]), .D(n1313), 
         .Z(extclk_c_enable_6)) /* synthesis lut_function=(A (B (C+!(D)))+!A (B (C))) */ ;
    defparam i1_4_lut_adj_7.init = 16'hc0c8;
    LUT4 i1_4_lut_adj_8 (.A(state[1]), .B(n1501), .C(state[3]), .D(n1515), 
         .Z(extclk_c_enable_7)) /* synthesis lut_function=(A (B (C))+!A (B (C+(D)))) */ ;
    defparam i1_4_lut_adj_8.init = 16'hc4c0;
    CCU2D add_49_15 (.A0(clkdiv[13]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[14]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1097), .COUT(n1098), .S0(n331[13]), .S1(n331[14]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_15.INIT0 = 16'h5555;
    defparam add_49_15.INIT1 = 16'h5555;
    defparam add_49_15.INJECT1_0 = "NO";
    defparam add_49_15.INJECT1_1 = "NO";
    LUT4 i24_3_lut (.A(n1505), .B(uart0_rxd_c), .C(n1508), .Z(extclk_c_enable_28)) /* synthesis lut_function=(!(A (B+!(C))+!A (B (C)))) */ ;
    defparam i24_3_lut.init = 16'h3535;
    CCU2D add_49_13 (.A0(clkdiv[11]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[12]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1096), .COUT(n1097), .S0(n331[11]), .S1(n331[12]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_13.INIT0 = 16'h5555;
    defparam add_49_13.INIT1 = 16'h5555;
    defparam add_49_13.INJECT1_0 = "NO";
    defparam add_49_13.INJECT1_1 = "NO";
    LUT4 i1_2_lut_rep_31_3_lut_4_lut (.A(state[2]), .B(n1514), .C(state[3]), 
         .D(uart0_rxd_c), .Z(n1504)) /* synthesis lut_function=(!(A (C)+!A (B (C)+!B (C+!(D))))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(39[8:20])
    defparam i1_2_lut_rep_31_3_lut_4_lut.init = 16'h0f0e;
    LUT4 i1_2_lut_3_lut_adj_9 (.A(state[0]), .B(state[2]), .C(data_buffer[5]), 
         .Z(n1294)) /* synthesis lut_function=(!(A+(B+!(C)))) */ ;
    defparam i1_2_lut_3_lut_adj_9.init = 16'h1010;
    LUT4 i2_3_lut_4_lut_4_lut (.A(n1505), .B(state[3]), .C(state[1]), 
         .D(n1508), .Z(extclk_c_enable_2)) /* synthesis lut_function=(A (B (C (D)))+!A (B (C))) */ ;
    defparam i2_3_lut_4_lut_4_lut.init = 16'hc040;
    CCU2D add_49_11 (.A0(clkdiv[9]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[10]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1095), .COUT(n1096), .S0(n331[9]), .S1(n331[10]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_11.INIT0 = 16'h5555;
    defparam add_49_11.INIT1 = 16'h5555;
    defparam add_49_11.INJECT1_0 = "NO";
    defparam add_49_11.INJECT1_1 = "NO";
    FD1P3AX state_i0_i1 (.D(n1489), .SP(extclk_c_enable_19), .CK(extclk_c), 
            .Q(state[1])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam state_i0_i1.GSR = "ENABLED";
    FD1P3AX state_i0_i2 (.D(n1306), .SP(extclk_c_enable_28), .CK(extclk_c), 
            .Q(state[2])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam state_i0_i2.GSR = "ENABLED";
    LUT4 i28_4_lut (.A(clkdiv[10]), .B(n56), .C(n46), .D(clkdiv[20]), 
         .Z(n60)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[9:19])
    defparam i28_4_lut.init = 16'hfffe;
    FD1P3AX data_i0_i7 (.D(n1292), .SP(extclk_c_enable_34), .CK(extclk_c), 
            .Q(uart_send_char[7])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_i0_i7.GSR = "DISABLED";
    CCU2D add_49_9 (.A0(clkdiv[7]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[8]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1094), .COUT(n1095), .S0(n331[7]), .S1(n331[8]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_9.INIT0 = 16'h5555;
    defparam add_49_9.INIT1 = 16'h5555;
    defparam add_49_9.INJECT1_0 = "NO";
    defparam add_49_9.INJECT1_1 = "NO";
    LUT4 i1_4_lut_adj_10 (.A(state[2]), .B(n1501), .C(state[3]), .D(n1514), 
         .Z(extclk_c_enable_8)) /* synthesis lut_function=(A (B (C+!(D)))+!A (B (C))) */ ;
    defparam i1_4_lut_adj_10.init = 16'hc0c8;
    CCU2D add_49_7 (.A0(clkdiv[5]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[6]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1093), .COUT(n1094), .S0(n331[5]), .S1(n331[6]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_7.INIT0 = 16'h5555;
    defparam add_49_7.INIT1 = 16'h5555;
    defparam add_49_7.INJECT1_0 = "NO";
    defparam add_49_7.INJECT1_1 = "NO";
    FD1P3AX state_i0_i3 (.D(n1518), .SP(extclk_c_enable_22), .CK(extclk_c), 
            .Q(state[3])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam state_i0_i3.GSR = "ENABLED";
    LUT4 i1_2_lut_3_lut_adj_11 (.A(state[0]), .B(state[2]), .C(data_buffer[6]), 
         .Z(n1293)) /* synthesis lut_function=(!(A+(B+!(C)))) */ ;
    defparam i1_2_lut_3_lut_adj_11.init = 16'h1010;
    LUT4 i1_2_lut_rep_38 (.A(state[1]), .B(state[2]), .Z(n1511)) /* synthesis lut_function=(A+(B)) */ ;
    defparam i1_2_lut_rep_38.init = 16'heeee;
    LUT4 i1_2_lut_3_lut_4_lut (.A(state[1]), .B(state[2]), .C(n1502), 
         .D(state[3]), .Z(extclk_c_enable_34)) /* synthesis lut_function=(A (C (D))+!A (B (C (D)))) */ ;
    defparam i1_2_lut_3_lut_4_lut.init = 16'he000;
    LUT4 i1_4_lut_rep_28 (.A(n1502), .B(state[2]), .C(n555), .D(state[3]), 
         .Z(n1501)) /* synthesis lut_function=(A (B+(C+!(D)))) */ ;
    defparam i1_4_lut_rep_28.init = 16'ha8aa;
    LUT4 i11_3_lut (.A(uart0_rxd_c), .B(n1505), .C(n1508), .Z(extclk_c_enable_22)) /* synthesis lut_function=(!(A (B+(C))+!A !((C)+!B))) */ ;
    defparam i11_3_lut.init = 16'h5353;
    LUT4 i1_2_lut_3_lut_adj_12 (.A(state[1]), .B(state[2]), .C(uart0_rxd_c), 
         .Z(n1303)) /* synthesis lut_function=(!(A+(B+!(C)))) */ ;
    defparam i1_2_lut_3_lut_adj_12.init = 16'h1010;
    LUT4 i17_4_lut (.A(clkdiv[0]), .B(clkdiv[18]), .C(clkdiv[28]), .D(clkdiv[2]), 
         .Z(n49)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[9:19])
    defparam i17_4_lut.init = 16'hfffe;
    LUT4 i1_3_lut_4_lut (.A(state[3]), .B(n1506), .C(state[2]), .D(n555), 
         .Z(n1306)) /* synthesis lut_function=(!(A+((C (D)+!C !(D))+!B))) */ ;
    defparam i1_3_lut_4_lut.init = 16'h0440;
    LUT4 i945_2_lut_3_lut_3_lut (.A(n1505), .B(n331[5]), .C(n1508), .Z(clkdiv_31__N_130[5])) /* synthesis lut_function=((B+(C))+!A) */ ;
    defparam i945_2_lut_3_lut_3_lut.init = 16'hfdfd;
    LUT4 i30_4_lut (.A(n41), .B(n60), .C(n54), .D(n42), .Z(n62)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[9:19])
    defparam i30_4_lut.init = 16'hfffe;
    LUT4 i26_4_lut (.A(clkdiv[25]), .B(n52), .C(n38), .D(clkdiv[26]), 
         .Z(n58)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[9:19])
    defparam i26_4_lut.init = 16'hfffe;
    LUT4 i1_2_lut_rep_37 (.A(state[0]), .B(state[2]), .Z(n1510)) /* synthesis lut_function=(A+(B)) */ ;
    defparam i1_2_lut_rep_37.init = 16'heeee;
    LUT4 i31_4_lut_rep_32 (.A(n49), .B(n62), .C(n58), .D(n50), .Z(n1505)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[9:19])
    defparam i31_4_lut_rep_32.init = 16'hfffe;
    LUT4 i1_2_lut_3_lut_adj_13 (.A(state[0]), .B(state[2]), .C(data_buffer[7]), 
         .Z(n1292)) /* synthesis lut_function=(!(A+(B+!(C)))) */ ;
    defparam i1_2_lut_3_lut_adj_13.init = 16'h1010;
    LUT4 i22_4_lut (.A(clkdiv[19]), .B(clkdiv[5]), .C(clkdiv[22]), .D(clkdiv[6]), 
         .Z(n54)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[9:19])
    defparam i22_4_lut.init = 16'hfffe;
    FD1P3AX data_buffer_i0_i7 (.D(n1303), .SP(extclk_c_enable_24), .CK(extclk_c), 
            .Q(data_buffer[7])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_buffer_i0_i7.GSR = "DISABLED";
    LUT4 i1_4_lut_adj_14 (.A(state[1]), .B(n1499), .C(state[2]), .D(state[0]), 
         .Z(extclk_c_enable_4)) /* synthesis lut_function=(A (B)+!A (B (C+!(D)))) */ ;
    defparam i1_4_lut_adj_14.init = 16'hc8cc;
    LUT4 i10_2_lut (.A(clkdiv[7]), .B(clkdiv[14]), .Z(n42)) /* synthesis lut_function=(A+(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[9:19])
    defparam i10_2_lut.init = 16'heeee;
    LUT4 i429_2_lut_rep_41 (.A(state[0]), .B(state[1]), .Z(n1514)) /* synthesis lut_function=(A+(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(58[7] 83[16])
    defparam i429_2_lut_rep_41.init = 16'heeee;
    LUT4 i24_4_lut (.A(clkdiv[29]), .B(clkdiv[3]), .C(clkdiv[13]), .D(clkdiv[31]), 
         .Z(n56)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[9:19])
    defparam i24_4_lut.init = 16'hfffe;
    FD1P3AX data_i0_i1 (.D(n1296), .SP(extclk_c_enable_34), .CK(extclk_c), 
            .Q(uart_send_char[1])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_i0_i1.GSR = "DISABLED";
    LUT4 i14_2_lut (.A(clkdiv[15]), .B(clkdiv[23]), .Z(n46)) /* synthesis lut_function=(A+(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[9:19])
    defparam i14_2_lut.init = 16'heeee;
    LUT4 i20_4_lut (.A(clkdiv[17]), .B(clkdiv[1]), .C(clkdiv[24]), .D(clkdiv[4]), 
         .Z(n52)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[9:19])
    defparam i20_4_lut.init = 16'hfffe;
    LUT4 i6_2_lut (.A(clkdiv[9]), .B(clkdiv[12]), .Z(n38)) /* synthesis lut_function=(A+(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[9:19])
    defparam i6_2_lut.init = 16'heeee;
    LUT4 i1262_3_lut_rep_35_4_lut (.A(state[0]), .B(state[1]), .C(state[3]), 
         .D(state[2]), .Z(n1508)) /* synthesis lut_function=(!(A+(B+(C+(D))))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(58[7] 83[16])
    defparam i1262_3_lut_rep_35_4_lut.init = 16'h0001;
    LUT4 i943_4_lut (.A(uart0_rxd_c), .B(state[2]), .C(n9), .D(state[1]), 
         .Z(n14)) /* synthesis lut_function=(!(A (B+!(C+!(D)))+!A (B+!(C (D))))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(58[7] 83[16])
    defparam i943_4_lut.init = 16'h3022;
    CCU2D add_49_5 (.A0(clkdiv[3]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[4]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1092), .COUT(n1093), .S0(n331[3]), .S1(n331[4]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_5.INIT0 = 16'h5555;
    defparam add_49_5.INIT1 = 16'h5555;
    defparam add_49_5.INJECT1_0 = "NO";
    defparam add_49_5.INJECT1_1 = "NO";
    LUT4 i1_2_lut_3_lut_adj_15 (.A(state[0]), .B(state[2]), .C(data_buffer[0]), 
         .Z(n1297)) /* synthesis lut_function=(!(A+(B+!(C)))) */ ;
    defparam i1_2_lut_3_lut_adj_15.init = 16'h1010;
    FD1P3AX data_i0_i2 (.D(n1290), .SP(extclk_c_enable_34), .CK(extclk_c), 
            .Q(uart_send_char[2])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_i0_i2.GSR = "DISABLED";
    LUT4 i1_2_lut_rep_42 (.A(state[2]), .B(state[0]), .Z(n1515)) /* synthesis lut_function=(A (B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(58[7] 83[16])
    defparam i1_2_lut_rep_42.init = 16'h8888;
    FD1P3AX data_i0_i0 (.D(n1297), .SP(extclk_c_enable_34), .CK(extclk_c), 
            .Q(uart_send_char[0])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_i0_i0.GSR = "DISABLED";
    FD1P3AX state_i0_i0 (.D(n319), .SP(extclk_c_enable_28), .CK(extclk_c), 
            .Q(state[0])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam state_i0_i0.GSR = "ENABLED";
    LUT4 i900_2_lut (.A(n331[9]), .B(n1505), .Z(clkdiv_31__N_176[9])) /* synthesis lut_function=(A+!(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[6] 87[13])
    defparam i900_2_lut.init = 16'hbbbb;
    LUT4 i1_2_lut_3_lut_adj_16 (.A(state[0]), .B(state[2]), .C(data_buffer[1]), 
         .Z(n1296)) /* synthesis lut_function=(!(A+(B+!(C)))) */ ;
    defparam i1_2_lut_3_lut_adj_16.init = 16'h1010;
    FD1P3AX data_i0_i3 (.D(n1291), .SP(extclk_c_enable_34), .CK(extclk_c), 
            .Q(uart_send_char[3])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_i0_i3.GSR = "DISABLED";
    LUT4 i9_2_lut (.A(clkdiv[27]), .B(clkdiv[30]), .Z(n41)) /* synthesis lut_function=(A+(B)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[9:19])
    defparam i9_2_lut.init = 16'heeee;
    LUT4 i18_4_lut (.A(clkdiv[8]), .B(clkdiv[11]), .C(clkdiv[16]), .D(clkdiv[21]), 
         .Z(n50)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(55[9:19])
    defparam i18_4_lut.init = 16'hfffe;
    FD1S3IX clkdiv_i31 (.D(n331[31]), .CK(extclk_c), .CD(n1500), .Q(clkdiv[31])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam clkdiv_i31.GSR = "ENABLED";
    LUT4 i1_2_lut_3_lut_4_lut_adj_17 (.A(state[0]), .B(state[2]), .C(n1502), 
         .D(state[3]), .Z(extclk_c_enable_24)) /* synthesis lut_function=(A (C (D))+!A (B (C (D)))) */ ;
    defparam i1_2_lut_3_lut_4_lut_adj_17.init = 16'he000;
    LUT4 i944_2_lut_3_lut_3_lut (.A(n1505), .B(n331[4]), .C(n1508), .Z(clkdiv_31__N_130[4])) /* synthesis lut_function=((B+(C))+!A) */ ;
    defparam i944_2_lut_3_lut_3_lut.init = 16'hfdfd;
    FD1P3AX data_i0_i4 (.D(n1295), .SP(extclk_c_enable_34), .CK(extclk_c), 
            .Q(uart_send_char[4])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_i0_i4.GSR = "DISABLED";
    CCU2D add_49_3 (.A0(clkdiv[1]), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[2]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .CIN(n1091), .COUT(n1092), .S0(n331[1]), .S1(n331[2]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_3.INIT0 = 16'h5555;
    defparam add_49_3.INIT1 = 16'h5555;
    defparam add_49_3.INJECT1_0 = "NO";
    defparam add_49_3.INJECT1_1 = "NO";
    CCU2D add_49_1 (.A0(GND_net), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(clkdiv[0]), .B1(GND_net), .C1(GND_net), .D1(GND_net), 
          .COUT(n1091), .S1(n331[0]));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/numeric_std.vhd(1308[12:13])
    defparam add_49_1.INIT0 = 16'hF000;
    defparam add_49_1.INIT1 = 16'h5555;
    defparam add_49_1.INJECT1_0 = "NO";
    defparam add_49_1.INJECT1_1 = "NO";
    PFUMX i1279 (.BLUT(n1488), .ALUT(n1487), .C0(state[1]), .Z(n1489));
    FD1P3AX data_i0_i5 (.D(n1294), .SP(extclk_c_enable_34), .CK(extclk_c), 
            .Q(uart_send_char[5])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_i0_i5.GSR = "DISABLED";
    FD1P3AX data_i0_i6 (.D(n1293), .SP(extclk_c_enable_34), .CK(extclk_c), 
            .Q(uart_send_char[6])) /* synthesis LSE_LINE_FILE_ID=20, LSE_LCOL=18, LSE_RCOL=31, LSE_LLINE=77, LSE_RLINE=77 */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(38[4] 89[11])
    defparam data_i0_i6.GSR = "DISABLED";
    PFUMX i1287 (.BLUT(n1516), .ALUT(n1517), .C0(state[2]), .Z(n1518));
    LUT4 i940_2_lut (.A(data_buffer[6]), .B(state[0]), .Z(n9)) /* synthesis lut_function=(!((B)+!A)) */ ;   // /home/felix/projects/lowlevel/spu-mark-2/hw/hw-impl/uart_receiver.vhd(58[7] 83[16])
    defparam i940_2_lut.init = 16'h2222;
    
endmodule
