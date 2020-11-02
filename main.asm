;**************************************************************
;* Include global definitions
        #include <SpankerMachine.inc>
;**************************************************************
; Configuration
; Oscillator source: Internal oscillator @ 4 MHz
; Poweron delay, watchdog off, external clock, lowpower prog off
	__CONFIG _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _LVP_OFF
;**************************************************************
; exported symbol
	GLOBAL	Init
; imported subroutines
	EXTERN	waitMilliSeconds; wait.asm
	EXTERN	waitTenthSeconds	; wait.asm
	EXTERN	initLCD		; lcd.asm
	EXTERN	clearLCD	; lcd.asm
	EXTERN	writeLcdData	; lcd.asm
	EXTERN	gotoPosition	; lcd.asm
	EXTERN	initKey		; key.asm
	EXTERN	getKey		; key.asm
	EXTERN	initMotor	; motor.asm
	EXTERN	oneHit		; motor.asm
	EXTERN	displayDecimalNumber	; display.asm
	EXTERN	displayDecimalDigit		; display.asm
	EXTERN	displayCountDown		; display.asm
	EXTERN	displayPrompt			; display.asm

;**************************************************************
; Program
resetvector	ORG 0x00
	goto Init		; jump to main routine

;**************************************************************
; local definitions

;**************************************************************
; local data
main_udata		UDATA
command		RES	1
totalHits		RES	1
delayTenths		RES	1
hitsToDo		RES	1
tmpchar		RES	1

;**************************************************************
; main code segment
main_code		CODE

Init
	call		initKey
	call		initLCD
	call		initMotor
	BANKSEL	command
	movlw		DefaultHits
	movwf		totalHits
	movlw		DefaultDelay
	movwf		delayTenths
	
	movlw		D'50'	; wait a bit
	call		waitMilliSeconds

dispatchCommand	macro		key,	routine
	movlw		key
	subwf		command, W
	btfsc		STATUS, Z
	call		routine
	endm

; multiplies cell with 10
cellTimes10		macro		cell
	bcf		STATUS, C		; clear carry
	rlf		cell, F		; numeric value*2
	movf		cell, W		; copy to W
	rlf		cell, F		; numeric value*4
	rlf		cell, F		; numeric value*8
	addwf		cell, F		; now the cell holds value times 10
	endm

mainLoop
	call		clearLCD
	movlw		'C'
	call		displayPrompt
					
	movlw		D'50'			; wait a bit
	call		waitMilliSeconds
	call		getKey			; next key press
	BANKSEL	command
	movwf		command
	call		writeLcdData		; and display it

	BANKSEL	command
	dispatchCommand	'*', runPunishment
	dispatchCommand	'1', showValues
	dispatchCommand	'4', setTotalHits
	dispatchCommand	'5', setDelayTenths
	goto		mainLoop

; command '*': start punishment
runPunishment
	movlw		D'3'
	call		displayCountDown
	BANKSEL	command
	movf		totalHits, W
	movwf		hitsToDo
nextHit
	call		clearLCD
	BANKSEL	command
	movf		hitsToDo, W
	call		displayDecimalNumber
	BANKSEL	command
	movf		delayTenths, W
	call		waitTenthSeconds
	call		oneHit
	BANKSEL	command
	decfsz		hitsToDo
	goto		nextHit
	return

; command '1': show current settings
showValues
	call		clearLCD
	movlw		'H'
	call		displayPrompt
	BANKSEL	command
	movf		totalHits, W
	call		displayDecimalNumber
	movlw		0x40
	call		gotoPosition
	movlw		'D'
	call		displayPrompt
	BANKSEL	command
	movf		delayTenths, W
	call		displayDecimalNumber
	call		getKey			; wait for any key
	return

; command '4': set number of hits
setTotalHits
	call		clearLCD
	movlw		'H'
	call		displayPrompt
	BANKSEL	command
	movf		totalHits, W
	call		displayDecimalNumber
	movlw		0x03
	call		gotoPosition
	BANKSEL	command
	clrf		totalHits
	call		getKey			; first digit
	BANKSEL	command
	movwf		tmpchar
	call		writeLcdData		; display first digit
	BANKSEL	command
	movlw		'0'
	subwf		tmpchar, W		; to numeric value
	movwf		totalHits
	cellTimes10	totalHits
	call		getKey			; second digit
	BANKSEL	command
	movwf		tmpchar
	call		writeLcdData		; display second digit
	BANKSEL	command
	movlw		'0'
	subwf		tmpchar, W		; to numeric value
	addwf		totalHits, F
	cellTimes10	totalHits
	call		getKey			; third digit
	BANKSEL	command
	movwf		tmpchar
	movlw		'0'
	subwf		tmpchar, W		; to numeric value
	addwf		totalHits, F
	goto		showValues		; continue with showing current values

setDelayTenths
	call		clearLCD
	movlw		'D'
	call		displayPrompt
	BANKSEL	command
	movf		delayTenths, W
	call		displayDecimalNumber
	movlw		0x03
	call		gotoPosition
	BANKSEL	command
	clrf		delayTenths
	call		getKey			; first digit
	BANKSEL	command
	movwf		tmpchar
	call		writeLcdData		; display first digit
	BANKSEL	command
	movlw		'0'
	subwf		tmpchar, W		; to numeric value
	movwf		delayTenths
	cellTimes10	delayTenths
	call		getKey			; second digit
	BANKSEL	command
	movwf		tmpchar
	call		writeLcdData		; display second digit
	BANKSEL	command
	movlw		'0'
	subwf		tmpchar, W		; to numeric value
	addwf		delayTenths, F
	cellTimes10	delayTenths
	call		getKey			; third digit
	BANKSEL	command
	movwf		tmpchar
	movlw		'0'
	subwf		tmpchar, W		; to numeric value
	addwf		delayTenths, F
	goto		showValues		; continue with showing current values

END
