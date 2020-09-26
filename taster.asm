; simple input from one switch
        #include "SpankerMachine.inc"
;**************************************************************
; imported subroutines
;		EXTERN
; imported variables
;		EXTERN
; exported subroutines
		GLOBAL	initTaster
		GLOBAL	tasterInterruptRoutine
		GLOBAL	getTasterState

; exported variables
;		GLOBAL
; local definitions
MAX_TASTER		EQU	2	; states of taster

;**************************************************************
; data section
taster_udata	UDATA
tasterState		RES	1	; current state (0/1)
tasterChanged	RES	1	; bit0: changed?

;**************************************************************
; code section
taster_code	CODE

initTaster
	BANKSEL	SwitchTRIS
	bsf	SwitchTRIS,SwitchPin
	BANKSEL	OPTION_REG
	bcf	OPTION_REG,INTEDG ; trigger interrupt with falling edge 1-0
	BANKSEL	INTCON
	bcf	INTCON,INTF	; clear interrupt flag
	bsf	INTCON,INTE	; enable interrupts
	BANKSEL	tasterState
	clrf	tasterState	; default is zero
	clrf	tasterChanged	; not yet changed
	return

getTasterState
	BANKSEL	tasterState
	movf	tasterState,W	; current value in W
	bcf	STATUS,Z	; Z bit clear: value changed
	btfss	tasterChanged,0	; did it?
	bsf	STATUS,Z	; no, set Z: it didnt change
	bcf	tasterChanged,0	; reset flag
	return

tasterInterruptRoutine	; toggles tasterState bit 0
	BANKSEL	tasterState
	btfsc	tasterChanged,0	; changed?
	goto	finish		; yes, dont change again
	incf	tasterState,F	; increment
	movf	tasterState,W	; compare it
	sublw	MAX_TASTER	; test for max value: w = MAX - w
	btfsc	STATUS,Z	; Z set?
	clrf	tasterState	; yes: W==max, back to zero
	bsf	tasterChanged,0	; set changed flag
finish
	BANKSEL	INTCON
	bcf	INTCON,INTF	; clear interrupt flag
	return

	END
