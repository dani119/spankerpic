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
	EXTERN	Interrupt	; interrupt.asm
	EXTERN	initTaster	; taster.asm
	EXTERN	waitMilliSeconds; wait.asm
	EXTERN	waitSeconds	; wait.asm
	EXTERN	getTasterState	; taster.asm
;**************************************************************
; Program
resetvector	ORG 0x00
	goto Init		; jump to main routine
interruptvector	ORG 0x04
	goto Interrupt		; dispatch interrupt routine

;**************************************************************
; local definitions

;**************************************************************
; local data
main_udata		UDATA

;**************************************************************
; main code segment
main_code		CODE

Init
	call	initTaster

	; switch motor off
	BANKSEL	MotorTRIS
	bcf		MotorTRIS, MotorPin
	BANKSEL	MotorPort
	bcf		MotorPort, MotorPin

	movlw		D'50'	; wait a bit
	call		waitMilliSeconds
	
; init done, start interrupts
	bsf     INTCON, GIE     ; allow interrupts

mainLoop
	movlw		D'250'
	call	waitMilliSeconds
	call	getTasterState	; current state
	btfsc	STATUS,Z	; changed?
	goto	mainLoop	; Z set: no change, nothing to do
				; Z clear: state changed
	BANKSEL	MotorPort
	bsf	MotorPort, MotorPin

	movlw		D'1'
	call	waitSeconds
	movlw		D'250'
	call		waitMilliSeconds
	
	BANKSEL	MotorPort
	bcf	MotorPort, MotorPin
	goto	mainLoop	; done
	end
