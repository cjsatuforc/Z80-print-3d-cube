;=============================================================================================================
;Created by ihiroshi27@github
;May 20, 2018
;This project is part of the Microprocessors And Interfacing course at Computer Engineering
;With the purpose to study using serial communicate between Z80 ET-Board V4.0 and 3D Printer (Marlin Firmware)
;Khon Kaen University, Khon Kaen, Thailand
;=============================================================================================================
cpu "z80.tbl"
hof "INT8"

;System calls
syscall:      equ   10h
hbeep:        equ   4ch

;System calls for serial port.
serial_mode:  equ   59h             ;set serial port parameters
tx_byte:      equ   5ah             ;send a byte
txblock:      equ   5eh             ;send block of byte end with 0
rx_byte:      equ   5bh             ;receive a byte

org 2000h
main:         ld    c, 96h          ;9600 baud
              ld    hl, 0
              ld    a, serial_mode
              rst   syscall
set_variable: xor   a
              ld    (state), a
              ld    (ok), a
              ld    (lcount), a
              ld    b, 0h
              ld    c, 0h
              ld    (extrude), bc
send_g28:	    ld    hl, ghead
              ld    a, txblock
			        rst   syscall
loop:         ld    a, rx_byte
              rst   syscall
              ld    a, wr_lcd
              rst   syscall
              ld    a, d
              cp    "o"
              jr    z, is_o
              cp    "k"
              jr    z, is_k
not_ok:       xor   a
              ld    (ok), a
              jr    loop
is_o:         ld    a, (ok)
              or    0f0h
			        ld    (ok), a
              jr    loop
is_k: 		    ld    a, (ok)
              or    0fh
              cp    0ffh
              jr    nz, not_ok
              jp    send_gcode
              xor   a
              ld    (ok), a
return:       jr    loop
              halt
;=============================================================================================================
send_gcode:   ld 	  a,hbeep
              rst 	syscall
			        ld    a, (lcount)
              inc   a
              ld    (lcount), a
              ld    a, (state)
              cp    0h
              jr    z, state0
              cp    1h
              jr    z, state1
              cp    2h
              jr    z, state2
              jp    return
state0:       ld    a, (lcount)
              cp    0ah
              jr    z, complete_s0
              inc   hl
              ld    a, txblock
              rst   syscall
              jp    return
complete_s0:  ld    a, 0h
              ld    (lcount), a
              ld    a, 1h
              ld    (state), a
              ld    hl, gzlayer
              push	hl
state1:       ld    hl, gzcode1
              ld    a, txblock
              rst   syscall
              pop   hl
              inc   hl
              ld    a, (hl)
              cp    0ffh
              jr    z, complete
              ld    a, txblock
              rst   syscall
              push	hl
              ld    hl, gzcode2
              ld    a, txblock
              rst	  syscall
              ld    a, 0h
              ld    (lcount), a
              ld    a, 2h
              ld    (state), a
              ld    hl, glayer
              jp    return
state2:       ld    a, (lcount)
              cp    42
              jr    z, complete_s2
              inc   hl
              ld    a, txblock
              rst   syscall
              jp    return
complete_s2:  ld    a, 0h
              ld    (lcount), a
              ld    a, 1h
              ld    (state), a
              jp    state1
;=============================================================================================================
complete:     ld    hl, gzout
              ld    a, txblock
              rst   syscall
			        halt
;=============================================================================================================
state:        dfs   1
ok:       	  dfs   1
lcount:       dfs   1
extrude:      dfs   2
ghead:        dfb   "G28", 0ah, 0
			        dfb   "M83", 0ah, 0
              dfb   "M190 S50", 0ah, 0
              dfb   "M109 T0 S200", 0ah, 0
              dfb   "M106 S127", 0ah, 0
              dfb   "G0 X86.4 Y86.4 Z0.3 F1800", 0ah, 0
              dfb	  "G1 X113.6 Y86.4 E2.0 F1800", 0ah, 0
              dfb 	"G1 X113.6 Y113.6 E2.0 F1800", 0ah, 0
              dfb	  "G1 X86.4 Y113.6 E2.0 F1800", 0ah, 0
              dfb   "G1 X86.4 Y86.4 E2.0 F1800", 0ah, 0
gzcode1:      dfb   "G0 X90 Y90 Z", 0
gzlayer:      dfb   0, "0.3", 0, "0.6", 0, "0.9"
              dfb   0, "1.2", 0, "1.5", 0, "1.8"
              dfb   0, "2.1", 0, "2.4", 0, "2.7"
              dfb   0, "3.0", 0, "3.3", 0, "3.6"
              dfb   0, "3.9", 0, "4.2", 0, "4.5"
              dfb   0, "4.8", 0, "5.1", 0, "5.4"
              dfb   0, "5.7", 0, "6.0", 0, "6.3"
              dfb   0, "6.6", 0, "6.9", 0, "7.2"
              dfb   0, "7.5", 0, "7.8", 0, "8.1"
              dfb   0, "8.4", 0, "8.7", 0, "9.0"
              dfb   0, "9.3", 0, "9.6", 0, "9.9"
              dfb   0, "10.2", 0, "10.5", 0, "10.8"
              dfb   0, "11.1", 0, "11.4", 0, "11.7"
              dfb   0, "12.0", 0, "12.3", 0, "12.6"
              dfb   0, "12.9", 0, "13.2", 0, "13.5"
              dfb   0, "13.8", 0, "14.1", 0, "14.4"
              dfb   0, "14.7", 0, "15.0", 0, "15.3"
              dfb   0, "15.6", 0, "15.9", 0, "16.2"
              dfb   0, "16.5", 0, "16.8", 0, "17.1"
              dfb   0, "17.4", 0, "17.7", 0, "18.0"
              dfb   0, "18.3", 0, "18.6", 0, "18.9"
              dfb   0, "19.2", 0, "19.5", 0, "19.8"
              dfb   0, 00ffh
gzout:        dfb   "25 F1800", 0ah, 0
gzcode2:      dfb   " F1800", 0ah, 0
glayer:       dfb	  0, "G0 X90 Y90 E2.0 F1800", 0ah, 0
      			  dfb	 "G1 X109.8 Y90 E2.0 F1800", 0ah, 0
      			  dfb	 "G1 X109.8 Y109.8 E2.0 F1800", 0ah, 0
      			  dfb	 "G1 X90 Y109.8 E2.0 F1800", 0ah, 0
      			  dfb	 "G1 X90 Y90 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X90.74 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X90.74 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X91.82 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X91.82 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X92.9 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X92.9 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X93.98 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X93.98 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X95.06 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X95.06 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X96.14 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X96.14 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X97.22 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X97.22 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X98.3 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X98.3 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X99.38 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X99.38 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X100.46 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X100.46 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X101.54 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X101.54 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X102.62 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X102.62 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X103.7 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X103.7 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X104.78 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X104.78 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X105.86 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X105.86 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X106.94 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X106.94 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X108.02 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X108.02 Y109.26 E2.0 F1800", 0ah, 0
      			  dfb	 "G0 X109.1 Y90.2 F1800", 0ah, 0
      			  dfb	 "G1 X109.1 Y109.26 E2.0 F1800", 0ah, 0
end
