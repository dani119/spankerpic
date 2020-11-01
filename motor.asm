; run the motor
;**************************************************************
;* Include global definitions
        #include <SpankerMachine.inc>
;**************************************************************
; imported subroutines
	EXTERN	waitTenthSeconds; wait.asm

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

; let the motor run for just one hit
; one revolution takes about 1.25 s, so we let it run for 1.3 s
;    (Running a bit longer doesn't matter, the spring will push it back
;     to its starting position. Running too short will not deliver a hit,
;     therefore it is better to let it run a bit too long.)
oneHit
	call		motorOn
	movlw		D'13'
	call		waitTenthSeconds
	call		motorOff
	return

END