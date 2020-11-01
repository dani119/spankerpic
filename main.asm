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
	movlw		D'5'
	movwf		totalHits
	movlw		D'1'
	movwf		delaySeconds
	
	movlw		D'50'	; wait a bit
	call		waitMilliSeconds

mainLoop
	call		clearLCD
	movlw		'C'
	call		writeLcdData
	movlw		':'
	call		writeLcdData
	movlw		' '
	call		writeLcdData
					
	movlw		D'50'			; wait a bit
	call		waitMilliSeconds
	call		getKey			; next key press
	BANKSEL	command
	movwf		command
	call		writeLcdData		; and display it

	BANKSEL	command
	movlw		'*'
	subwf		command, W		; test for command '*'
	btfsc		STATUS, Z		; skip call, if not
	call		runPunishment	; execute command '*': start the punishment
	goto		mainLoop

runPunishment
	; display a 3 seconds count down
	call		clearLCD
	movlw		'3'
	call		writeLcdData
	movlw		D'1'
	call		waitSeconds
	call		clearLCD
	movlw		'2'
	call		writeLcdData
	movlw		D'1'
	call		waitSeconds
	call		clearLCD
	movlw		'1'
	call		writeLcdData
	movlw		D'1'
	call		waitSeconds
	BANKSEL	command
	movf		totalHits, W
	movwf		hitsToDo
nextHit
	call		clearLCD
	BANKSEL	command
	movf		hitsToDo, W
	addlw		'0'
	call		writeLcdData
	BANKSEL	command
	movf		delaySeconds, W
	call		waitSeconds
	call		oneHit
	BANKSEL	command
	decfsz		hitsToDo
	goto		nextHit
	return

	end
