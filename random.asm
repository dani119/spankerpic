; pseodo random generator as linear feedback shift register
        #include <p16f628.inc>
;**************************************************************
; imported subroutines
;		EXTERN
; imported variables
;		EXTERN
; exported subroutines
		GLOBAL initRandom
		GLOBAL nextBit
		GLOBAL next3Bit
; exported variables
;		GLOBAL
; local definitions
SEED	EQU	0xA5

;**************************************************************
; data section
random_udata	UDATA
registerL	RES	1
registerH	RES	1
; temporary
random_ovr_udata	UDATA_OVR
tmp

;**************************************************************
; code section
random_code	CODE
initRandom
	BANKSEL	registerL
	movlw		SEED
	movwf		registerL
	movwf		registerH
	return

; linear feedback shift register
; layout: registerL registerH
;         01234567 01234567
;                   1
;         01234567 90123456
; calculate next bit
; get bit 16
; xor with bit 14
; xor with bit 13
; xor with bit 11
; -> is the result
; calculate next value in register
; put result into carry
; shift register with carry left (C->0->1->...->7->C)
nextBit
	BANKSEL	registerL
	btfsc		registerH,7
	movlw		1
	btfsc		registerH,5
	xorlw		1
	btfsc		registerH,4
	xorlw		1
	btfsc		registerH,2
	xorlw		1
; result is now in W (and inverted in Z)
	bcf		STATUS, C
	btfss		STATUS, Z
	bsf		STATUS, C
	rlf		registerL, F
	rlf		registerH, F
	return

next3Bit
	BANKSEL	tmp
	clrf		tmp
	call		nextBit
	BANKSEL	tmp
	btfss		STATUS, Z
	bsf		tmp, 0
	call		nextBit
	BANKSEL	tmp
	btfss		STATUS, Z
	bsf		tmp, 1
	call		nextBit
	BANKSEL	tmp
	btfss		STATUS, Z
	bsf		tmp, 2
	movf		tmp, W
	return

END
