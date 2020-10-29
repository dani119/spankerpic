; run the motor
;**************************************************************
;* Include global definitions
        #include <SpankerMachine.inc>
;**************************************************************
; imported subroutines
	EXTERN	waitMilliSeconds; wait.asm
	EXTERN	waitSeconds	; wait.asm

; exported subroutines
	GLOBAL	initMotor
	GLOBAL	motorOn
	GLOBAL	motorOff
	GLOBAL	oneHit

;**************************************************************
; local definitions

;**************************************************************
; local data
motor_udata		UDATA

;**************************************************************
; local code
motor_code	CODE

;**********************************************************
; Initialization Motor
initMotor
	BANKSEL	MotorTRIS
	bcf		MotorTRIS, MotorPin
	; fall through intended

motorOff
; switch motor off
	BANKSEL	MotorPort
	bcf		MotorPort, MotorPin
	return

motorOn
	BANKSEL	MotorPort
	bsf		MotorPort, MotorPin
	return

oneHit
	call		motorOn
	movlw		D'1'
	call		waitSeconds
	movlw		D'250'
	call		waitMilliSeconds
	call		motorOff
	return

END