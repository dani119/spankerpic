; handle a keyboard matrix
;**************************************************************
;* Include global definitions
        #include "SpankerMachine.inc"
;**************************************************************
; exported subroutines
	GLOBAL	initKey
	GLOBAL	getKey

; dont touch other bits in TRIS
KeyTRISMask	EQU	~ ((1 << KeyRow1) | (1 << KeyRow2) | (1 << KeyRow3) | (1 << KeyRow4) | (1 << KeyCol1) | (1 << KeyCol2)| (1 << KeyCol3))

; set columns as inputs and rows as outputs
KeyTRISConfig	EQU	(1 << KeyCol1) | (1 << KeyCol2) | (1 << KeyCol3)

;**************************************************************
; local data
key_udata	UDATA

;**************************************************************
; local code
key_code	CODE

;**********************************************************
; Initialization
initKey
	; switch on weak pull-ups
	BANKSEL	OPTION_REG
	bcf		OPTION_REG, NOT_RBPU
	return

getKey
	; configure IN/OUT direction for columns/rows
	BANKSEL	KeyTRIS
	movlw		KeyTRISMask
	andwf		KeyTRIS,W
	iorlw		KeyTRISConfig
	movwf	KeyTRIS
	BANKSEL	KeyPort
	call		waitForNoKey
	call		waitForKey
	return

waitForKey
	call		getCurrentKey
	btfsc		STATUS, Z
	goto		waitForKey
	return

waitForNoKey
	call		getCurrentKey
	btfss		STATUS, Z
	goto		waitForNoKey
	return

enableRow	macro	bitNo
	bsf		KeyPort, KeyRow1
	bsf		KeyPort, KeyRow2
	bsf		KeyPort, KeyRow3
	bsf		KeyPort, KeyRow4
	bcf		KeyPort, KeyRow#v(bitNo)
	nop		; give stuff time to settle
	endm

checkColumns	macro	val1, val2, val3
	btfss		KeyPort, KeyCol1
	retlw		val1
	btfss		KeyPort, KeyCol2
	retlw		val2
	btfss		KeyPort, KeyCol3
	retlw		val3
	endm

getCurrentKey
	bcf		STATUS, Z

	enableRow 1
	checkColumns '1', '2', '3'
	enableRow 2
	checkColumns '4', '5', '6'
	enableRow 3
	checkColumns '7', '8', '9'
	enableRow 4
	checkColumns '*', '0', '#'
			
	bsf		STATUS, Z
	retlw		0

	END
