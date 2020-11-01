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
;*     1: LCDPinRW	KeyRow1
;*     2: LCDPinRS	KeyRow2
;*     3: 		KeyRow3
;*     4: LCDPinD0	KeyRow4
;*     5: LCDPinD1	KeyCol1
;*     6: LCDPinD2	KeyCol2
;*     7: LCDPinD3	KeyCol3

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

; keyboard
KeyPort		EQU	PORTB	; Keyboard control port
KeyTRIS		EQU	TRISB	; Keyboard control port control register
KeyRow1		EQU	1	; Pin for keyboard row 1
KeyRow2		EQU	2	; Pin for keyboard row 2
KeyRow3		EQU	3	; Pin for keyboard row 3
KeyRow4		EQU	4	; Pin for keyboard row 4
KeyCol1		EQU	5	; Pin for keyboard column 1
KeyCol2		EQU	6	; Pin for keyboard column 2
KeyCol3		EQU	7	; Pin for keyboard column 3

; motor
MotorPort		EQU	PORTA
MotorTRIS		EQU	TRISA
MotorPin		EQU	6

; global settings
; main
DefaultHits		EQU	D'12'
DefaultDelay		EQU	D'3'
