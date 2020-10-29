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

;**************************************************************
; main code segment
main_code		CODE

Init
	call		initKey
	call		initLCD
	call		initMotor
	
	movlw		D'50'	; wait a bit
	call		waitMilliSeconds
	
	call		clearLCD
	movlw		'O'
	call		writeLcdData
	movlw		'K'
	call		writeLcdData
	movlw		':'
	call		writeLcdData
	movlw		' '
	call		writeLcdData
					
mainLoop
	movlw		D'50'			; wait a bit
	call		waitMilliSeconds
	call		getKey			; next key press
	movwf		command
	call		writeLcdData		; and display it

	movlw		'*'
	subwf		command, W		; test for command '*'
	btfsc		STATUS, Z		; skip call, if not
	call		oneHit			; execute command '*': run motor once

	goto	mainLoop
	end
