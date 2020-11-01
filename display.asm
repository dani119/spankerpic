; higher level routines for LCD
;**************************************************************
;* Include global definitions
        #include "SpankerMachine.inc"
;**************************************************************
; imported subroutines
	EXTERN	writeLcdData		; lcd.asm
	
; exported subroutines
	GLOBAL	writeDecimalNumber
	GLOBAL	writeDecimalDigit

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
writeDecimalNumber
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
	call		writeDecimalDigit
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
	call		writeDecimalDigit
	clrf		displayDigit

ones
	movf		displayNumber,W

writeDecimalDigit
; write one decimal digit in W
	addlw		'0'
	call		writeLcdData
	BANKSEL	displayNumber
	return

; the end
	END
