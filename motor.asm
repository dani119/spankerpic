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
;	the time it takes for one revolution depends on the power
;	setting of the spanker machine. I've measured from 1.2 to 1.5 seconds.
;	But running a bit longer doesn't matter, the spring will push it back
;	to its starting position. Running too short will not deliver a hit,
;	therefore it is better to let it run a bit too long.
;	In power settings below 4 this doesn't work any more, as it
;	will from time to time deliver two hits instead of one.
MotorRevolutionTime	EQU	D'15'

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
oneHit
	call		motorOn
	movlw		MotorRevolutionTime
	call		waitTenthSeconds
	call		motorOff
	return

END