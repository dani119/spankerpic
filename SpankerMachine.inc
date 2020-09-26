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
;*     0: INT0 switch
;*     1: 
;*     2: 
;*     3: 
;*     4: 
;*     5: 
;*     6: 
;*     7: 

;**************************************************************
; port definitions
SwitchPort	EQU	PORTB
SwitchTRIS	EQU	TRISB
SwitchPin	EQU	0

MotorPort	EQU	PORTA
MotorTRIS	EQU	TRISA
MotorPin	EQU	6
