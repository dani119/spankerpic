; wait routines: busy waiting for defined ms delay
;**************************************************************
;* Include global definitions
        #include "SpankerMachine.inc"
;**************************************************************
; imported subroutines
;	none
; exported subroutines
	GLOBAL	waitMilliSeconds
	GLOBAL	waitSeconds

;**************************************************************
; local data
			UDATA_OVR
waitSecondsValue	RES 1
waitMSeconds	RES 1
waitInner		RES 1

;**************************************************************
; code
wait_code		CODE

;*****************************************************************
; wait for some milli seconds
; calculated for 1 MHz internal clock (instructions per second)
; 1 ms is 1000 instructions
waitMilliSeconds			; call: we start with 2
	BANKSEL	waitMSeconds		; 4
	movwf	waitMSeconds		; 5
outerLoop
	movlw	D'109'			; 6
	movwf	waitInner		; 7
	nop                    		; 8
	nop				; 9
	nop				; 10
	nop				; 11
	nop				; 12
	nop				; 13
	nop                    		; 14
	nop				; 15
	nop				; 16
	nop				; 17
innerLoop
	nop                    		; 116
	nop				; 226
	nop				; 336
	nop				; 446
	nop				; 556
	nop				; 666
	decfsz	waitInner,F		; 776 inner loops complete?
	goto	innerLoop		; 996 no, go again
	decfsz	waitMSeconds,F		; 998 outer loops complete?
	goto	goOuterLoop		; 1000 no, go again
	return				; 1000 yes, return

goOuterLoop	; indirection of this jump inserts 4 cycles
	nop				; 1001
	nop				; 1002
	goto	outerLoop		; 1004

; wait for seconds
; calculated for 1 MHz internal clock (instructions per second)
; 1 s is 1000000 instructions, this one is some ppm to long
waitSeconds
	; no need for cycle counting this time.
	BANKSEL	waitSecondsValue
	movwf	waitSecondsValue
waitSecondsLoop
	movlw	D'250'
	call	waitMilliSeconds
	movlw	D'250'
	call	waitMilliSeconds
	movlw	D'250'	
	call	waitMilliSeconds
	movlw	D'250'
	call	waitMilliSeconds
	decfsz	waitSecondsValue,F	; enough?
	goto	waitSecondsLoop		; no, loop again
	return


	END
