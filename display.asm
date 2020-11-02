; higher level routines for LCD
;**************************************************************
;* Include global definitions
        #include "SpankerMachine.inc"
;**************************************************************
; imported subroutines
	EXTERN	writeLcdData		; lcd.asm
	EXTERN	clearLCD		; lcd.asm
	EXTERN 	gotoPosition		; lcd.asm
	EXTERN	waitSeconds		; wait.asm

; exported subroutines
	GLOBAL	displayDecimalNumber
	GLOBAL	displayDecimalDigit
	GLOBAL	displayCountDown
	GLOBAL	displayPrompt

; local definitions
;myXXX		EQU	B'00000111'

;**************************************************************
; local data
display_udata	UDATA
displayNumber	RES	1
displayDigit		RES	1

;**************************************************************
; local code
display_code	CODE

;**********************************************************
; Write a decimal number at the current position, always
; uses three characters on the display, left padded with blanks.
; e.g. 16 is displayed as ' 16'.
displayDecimalNumber
	BANKSEL	displayNumber
	movwf		displayNumber
	clrf		displayDigit
	
	; check if below 100
	movlw		D'100'
	subwf		displayNumber,W
	btfsc		STATUS,C
	goto		hundreds
	; pad with blank
	movlw		' '
	call		writeLcdData
	BANKSEL	displayNumber
	; check below 10
	movlw		D'10'
	subwf		displayNumber,W
	btfsc		STATUS,C
	goto		tens
	; pad with blank
	movlw		' '
	call		writeLcdData
	BANKSEL	displayNumber
	goto		ones

hundreds
	movlw		D'100'
	subwf		displayNumber,F
	btfss		STATUS, C
	goto		doneHundreds
	incf		displayDigit, F
	goto		hundreds
	
doneHundreds
	; restore number (undo last substraction of 100)
	movlw		D'100'
	addwf		displayNumber,F
	movf		displayDigit,W
	call		displayDecimalDigit
	clrf		displayDigit

tens
	movlw		D'10'
	subwf		displayNumber,F
	btfss		STATUS, C
	goto		doneTens
	incf		displayDigit, F
	goto		tens

doneTens
	; restore number (undo last substraction of 10)
	movlw		D'10'
	addwf		displayNumber,F
	movf		displayDigit,W
	call		displayDecimalDigit
	clrf		displayDigit

ones
	movf		displayNumber,W

displayDecimalDigit
; write one decimal digit in W
	addlw		'0'
	call		writeLcdData
	BANKSEL	displayNumber
	return

displayCountDown
	; displays a count down on both lines of the display
	BANKSEL	displayNumber
	movwf		displayNumber
	call		clearLCD
nextDigit
	movlw		0x04
	call		gotoPosition
	BANKSEL	displayNumber
	movf		displayNumber, W
	call		displayDecimalDigit
	movlw		0x44
	call		gotoPosition
	BANKSEL	displayNumber
	movf		displayNumber, W
	call		displayDecimalDigit
	movlw		D'1'
	call		waitSeconds
	BANKSEL	displayNumber
	decfsz		displayNumber, F
	goto		nextDigit

	return

displayPrompt
	call		writeLcdData		; pass W through as prompt char
	movlw		':'
	call		writeLcdData
	movlw		' '
	call		writeLcdData
	return
	
; the end
	END
