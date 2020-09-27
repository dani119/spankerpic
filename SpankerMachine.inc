;**************************************************************
;* include device definitions
        #include <p16f628.inc>
;**************************************************************
;* Pin assignment
;*   PORTA:
;*     0: 
;*     1: 
;*     2: 
;*     3: 
;*     4: 
;*     5: MCLR/Reset
;*     6: Motor on/off
;*     7: 
;*   PORTB:
;*     0: LCDPinE
;*     1: LCDPinRW
;*     2: LCDPinRS
;*     3: 
;*     4: LCDPinD0
;*     5: LCDPinD1
;*     6: LCDPinD2
;*     7: LCDPinD3

;**************************************************************
; port definitions
; LCD
LCDControlPort	EQU	PORTB	; LCD control port
LCDControlTRIS	EQU	TRISB	; LCD control port control register
LCDPinE		EQU	0	; PIN LCD enable
LCDPinRW		EQU	1	; Pin for RW
LCDPinRS		EQU	2	; Pin for RS

LCDDataPort	EQU	PORTB	; LCD data port
LCDDataTRIS	EQU	TRISB	; LCD data port control register
LCDPinD0		EQU	4	; Pin for D0/D4
LCDPinD1		EQU	5	; Pin for D1/D5
LCDPinD2		EQU	6	; Pin for D2/D6
LCDPinD3		EQU	7	; Pin for D3/D7

; motor
MotorPort		EQU	PORTA
MotorTRIS		EQU	TRISA
MotorPin		EQU	6
