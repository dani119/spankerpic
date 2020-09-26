; universal interrupt dispatcher routine
        #include <p16f628.inc>
;**************************************************************
; imported subroutines
	EXTERN	tasterInterruptRoutine	; taster.asm
; exported subroutines
	GLOBAL	Interrupt
;**************************************************************
; local data
interrupt_udata		UDATA_SHR	; is in all banks
save_W			RES 1	; copy of W register
save_STATUS		RES 1	; copy of STATUS
save_FSR		RES 1	; copy of FSR

;**************************************************************
; local code
interrupt_code		CODE

Interrupt
	movwf   save_W		; save W, available in all banks
	swapf   STATUS,W
	movwf   save_STATUS
	movf	FSR,W
	movwf	save_FSR
	;bsf	PORTA,6		; DEBUG

	; dispatch interrupt

;	; RS232 interrupt handling
;          BANKSEL PIE1
;          btfss   PIE1, TXIE              ; is tx enabled?
;          goto    noTxEnabled             ; no, dont dispatch to it
;          BANKSEL PIR1
;          btfsc   PIR1,TXIF               ; is it tx?
;          call    rs232InterruptService   ; yes: TX interrupt
;  noTxEnabled
;          BANKSEL PIR1
;          btfsc   PIR1,RCIF               ; is it RX?
;          call    rs232RecieveInterruptService    ; yes: RX interrupt
	BANKSEL	INTCON
	btfsc	INTCON,INTF
	call	tasterInterruptRoutine	; taster interrupt
	
	; interrupt is dispatched

	;bcf	PORTA,6		; DEBUG

	movf	save_FSR,W	; restore FSR
	movwf	FSR
	swapf   save_STATUS,W	; restore STATUS
	movwf   STATUS
	swapf   save_W,F	; restore W
	swapf   save_W,W
	retfie			; done

	END
