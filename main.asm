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
	EXTERN	waitSeconds	; wait.asm
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
delaySeconds		RES	1
hitsToDo		RES	1

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
	movwf		delaySeconds
	
	movlw		D'50'	; wait a bit
	call		waitMilliSeconds

dispatchCommand	macro		key,	routine
	movlw		key
	subwf		command, W
	btfsc		STATUS, Z
	call		routine
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
	goto		mainLoop

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
	movf		delaySeconds, W
	call		waitSeconds
	call		oneHit
	BANKSEL	command
	decfsz		hitsToDo
	goto		nextHit
	return

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
	movf		delaySeconds, W
	call		displayDecimalNumber
	call		getKey			; wait for any key
	return

END
