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
;**************************************************************
; Program
resetvector	ORG 0x00
	goto Init		; jump to main routine

;**************************************************************
; local definitions

;**************************************************************
; local data
main_udata		UDATA

;**************************************************************
; main code segment
main_code		CODE

Init
	call		initLCD

	; switch motor off
	BANKSEL	MotorTRIS
	bcf		MotorTRIS, MotorPin
	BANKSEL	MotorPort
	bcf		MotorPort, MotorPin

	movlw		D'50'	; wait a bit
	call		waitMilliSeconds
	
mainLoop
	call		clearLCD
	BANKSEL	MotorPort
	bcf		MotorPort, MotorPin
		
	movlw		D'250'
	call		waitMilliSeconds
	movlw		D'250'
	call		waitMilliSeconds
	
	movlw		' '
	call		writeLcdData
	movlw		'O'
	call		writeLcdData
	movlw		'K'
	call		writeLcdData
	BANKSEL	MotorPort
	bsf		MotorPort, MotorPin
	
	movlw		D'250'
	call		waitMilliSeconds
	movlw		D'250'
	call		waitMilliSeconds
					
	goto	mainLoop
	end
