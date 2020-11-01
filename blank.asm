; description XXX
;**************************************************************
;* Include global definitions
        #include "SpankerMachine.inc"
;**************************************************************
; imported subroutines
	EXTERN	waitMilliSeconds	; (wait.asm)

; exported subroutines
	GLOBAL	initXXX

; local definitions
myXXX		EQU	B'00000111'

;**************************************************************
; local data
XXX_udata	UDATA
XXXData		RES 1

;**************************************************************
; local code
XXX_code	CODE

;**********************************************************
; Initialization XXX
initXXX
	return

; the end
	END
