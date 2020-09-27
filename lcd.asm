; handle a LCD
;**************************************************************
;* Include global definitions
        #include "SpankerMachine.inc"
;**************************************************************
; imported subroutines
	EXTERN	waitMilliSeconds	; (wait.asm)

; exported subroutines
	GLOBAL	initLCD
	GLOBAL	clearLCD
	GLOBAL	writeLcdData
	GLOBAL	gotoPosition

; local definitions
control8bit	EQU	B'00000011'
control4bit	EQU	B'00000010'

; dont touch other bits in TRIS
DataPortTRISMask	EQU	~ ((1 << LCDPinRW) | (1 << LCDPinRS) | (1 << LCDPinD0) | (1 << LCDPinD1) | (1 << LCDPinD2) | (1 << LCDPinD3))

; if we write to the lcd all our tris bits are cleared
DataPortTRISOut		EQU	0
; if we read, Dx pins are input (RW and RE is still output)
DataPortTRISIn		EQU	(1 << LCDPinD0) | (1 << LCDPinD1) | (1 << LCDPinD2) | (1 << LCDPinD3)

;**************************************************************
; local data
lcd_udata	UDATA
lcdData		RES 1
lcdStatus	RES 1

;**************************************************************
; local code
lcd_code	CODE

;**********************************************************
; Initialization LCD
initLCD
	; configure control pins
	BANKSEL	LCDControlTRIS
	bcf	LCDControlTRIS,LCDPinE
	; init values
	BANKSEL	LCDControlPort
	bcf	LCDControlPort,LCDPinE

	; configure data pins
	BANKSEL	LCDDataTRIS
	movlw	DataPortTRISMask
	andwf	LCDDataTRIS,W
	iorlw	DataPortTRISOut
	movwf	LCDDataTRIS
	BANKSEL	LCDDataPort
	movlw	D'50'			; wait for LCD internal reset
	call	waitMilliSeconds

; Init routine: set 8 bit control (twice, if the display is in 4 bit mode)
	BANKSEL	lcdData
	movlw	control8bit
	BANKSEL	lcdData
	movwf	lcdData
	BANKSEL	LCDDataPort
	bcf	LCDDataPort,LCDPinRW	; write: RW = 0
	bcf	LCDDataPort,LCDPinRS	; control: RS = 0
	call	portWriteLowNibble	; we cant use writeLCDcontrol yet
	call	latchLCDEnable		; first time set 8 bits
	movlw	D'10'			; 10 ms pause
	call	waitMilliSeconds
	call	latchLCDEnable		; second time set 8 bits
	movlw	D'5'			; 5 ms pause
	call	waitMilliSeconds
	call	latchLCDEnable		; third time set 8 bits
	movlw	D'5'			; 5 ms pause
	call	waitMilliSeconds

	; now set 4 bit protocol
	movlw	control4bit
	BANKSEL	lcdData
	movwf	lcdData
	call	portWriteLowNibble	; we still cant use writeLCDcontrol
	call	latchLCDEnable		; make this one valid

	movlw	B'00000001'	; clear and cusor home
	call	writeLcdControl
	movlw	B'00101000'	; set 4-bit, 2-line, 5x8
	call	writeLcdControl
	movlw	B'00001000'	; display off
	call	writeLcdControl
	movlw	B'00000110'	; entry mode, increment, disable display-shift
	call	writeLcdControl
	movlw	B'00000011'	; cursor home, cursor home
	call	writeLcdControl
	movlw	B'00001111'	; display on
	call	writeLcdControl
	return

clearLCD
	movlw	B'00000001'	; clear and cusor home
	call	writeLcdControl	; write control
	return

gotoPosition
	iorlw	0x80		; control dd ram adress set
	call	writeLcdControl	; write as control
	return

latchLCDEnable	; toggle LCDPinE to signal valid data to LCD
	BANKSEL	LCDControlPort
	bsf	LCDControlPort,LCDPinE
	nop
	nop
	nop
	bcf	LCDControlPort,LCDPinE
	return

; wait for clear of busy flag
waitLcdBusy
	BANKSEL	LCDDataTRIS		; switch LCD data port to input
	movlw	DataPortTRISMask	; dont touch other pins
	andwf	LCDDataTRIS,W
	iorlw	DataPortTRISIn
	movwf	LCDDataTRIS
	
	BANKSEL	LCDDataPort
waitBusyLoop
	bcf	LCDDataPort,LCDPinRS	; for busy flag read RS = 0
	bsf	LCDDataPort,LCDPinRW	; read: RW = 1
	bsf	LCDControlPort,LCDPinE	; tell the LCD
	nop
	nop				; stabilize
	movf	LCDDataPort,W		; get busy bit
	movwf	lcdStatus
	bcf	LCDControlPort,LCDPinE
	nop
	nop
	call	latchLCDEnable		; must fetch second nibble
	btfsc	lcdStatus,LCDPinD3	; test MSB
	goto	waitBusyLoop

	BANKSEL	LCDDataTRIS		; switch LCD data port back to output
	movlw	DataPortTRISMask
	andwf	LCDDataTRIS,W
	iorlw	DataPortTRISOut
	movwf	LCDDataTRIS

	return

; write one byte of data to LCD
writeLcdData
	BANKSEL	lcdData
	movwf	lcdData			; store value
	call		waitLcdBusy		; wait for the LCD
	BANKSEL	LCDDataPort
	bcf	LCDDataPort,LCDPinRW	; write: RW = 0
	bsf	LCDDataPort,LCDPinRS	; data: RS = 1
	goto	writeNibbles		; the rest is the same as for control,
					; continue there and return

; write one byte control data to LCD
writeLcdControl
	BANKSEL	lcdData
	movwf	lcdData			; store value
	call	waitLcdBusy		; wait for the LCD
	BANKSEL	LCDDataPort
	bcf	LCDDataPort,LCDPinRW	; write: RW = 0
	bcf	LCDDataPort,LCDPinRS	; control: RS = 0
writeNibbles
	call	portWriteHighNibble	; write high nibble first
	nop
	nop
	call	latchLCDEnable		; signal valid data
	call	portWriteLowNibble	; write low nibble
	nop
	nop
	call	latchLCDEnable		; signal valid data
	return

copyBit	macro	bitNo
	btfss	lcdData,bitNo
	if (bitNo < 4)
		bcf	LCDDataPort,LCDPinD#v(bitNo)
	else
		bcf	LCDDataPort,LCDPinD#v(bitNo-4)
	endif
	btfsc	lcdData,bitNo
	if (bitNo < 4)
		bsf	LCDDataPort,LCDPinD#v(bitNo)
	else
		bsf	LCDDataPort,LCDPinD#v(bitNo-4)
	endif
	endm

portWriteLowNibble			; we do it bitwise...
	BANKSEL	lcdData
	copyBit 0
	copyBit 1
	copyBit 2
	copyBit 3
	return

portWriteHighNibble			; we do it bitwise...
	BANKSEL	lcdData
	copyBit 4
	copyBit 5
	copyBit 6
	copyBit 7
	return
	END
