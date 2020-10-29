	list p=16f628
;**************************************************************
;*  	Pinbelegung
;*	----------------------------------	
;*	PORTA: 	0 -
;*		1 -
;*		2 -
;*		3 -
;*		4 -
;*		5 -
;*		6 -
;*		7 -
;*
;*	PORTB:	0 LCD Display E
;*		1 			Keyboard 1 4 7 *
;*		2 LCD Display RS	Keyboard 2 5 8 0
;*		3 LCD Display R/W	Keyboard 3 6 9 #
;*		4 LCD Display D4 	---------I I I I
;*		5 LCD Display D5	-----------+ I I
;*		6 LCD Display D6	-------------+ I
;*		7 LCD Display D7	---------------+
;*	
;**************************************************************
;
;sprut (zero) Bredendiek 09/2002 (mod. 12/2002)
;
; Tastatur mit LCD-Display
;
; Prozessor 16F628 
;
; Prozessor-Takt 10 MHz
;
; LCD & Keyboard am PortB
;
;**********************************************************
; Includedatei für den 16F628 einbinden

	#include <P16f628.INC>

	ERRORLEVEL      -302    	;SUPPRESS BANK SELECTION MESSAGES


; Configuration festlegen:
; Power on Timer, kein Watchdog, HS-Oscillator, kein Brown out, kein LV-programming
	__CONFIG	_PWRTE_ON & _WDT_OFF & _HS_OSC & _BODEN_OFF & _LVP_OFF


; Variablen festlegen
loops		equ	0x20	; Wartezeit für WAIT in Millisekunden
loops2		equ	0x21	; interner timer für wait
LcdStatus	equ	0x22	; Puffer für aus dem LCD ausgelesenes Statusbyte
LcdDaten	equ	0x23	; Puffer für zum LCD zu schreibendes Byte
Taste		equ	0x24	; Tastaturpuffer


; Konstanten festlegen
; das demonstriert die Nutzung des define-Kommandos im Assembler
; für LCD-Pins
#define	LcdE	PORTB,0		; enable Lcd
#define	LcdRw	PORTB,3		; read Lcd
#define	LcdRs	PORTB,2		; Daten Lcd (nicht control)	
#define LcdPort PORTB		; Datenbus des LCD (obere 4 Bit)
; für Tastatur-Anschluß
#define	KRow1	PORTB,1		;Keyboard 1 4 7 *
#define	KRow2	PORTB,2		;Keyboard 2 5 8 0
#define	KRow3	PORTB,3		;Keyboard 3 6 9 #
#define	KLine1	PORTB,4		;Keyboard 1 2 3
#define	KLine2	PORTB,5		;Keyboard 4 5 6
#define	KLine3	PORTB,6		;Keyboard 7 8 9
#define	KLine4	PORTB,7		;Keyboard * 0 #

; Konstanten für OPTIN_REG and INTCON
; diese Werte werden im Programm wärend der Initialisierung verwendet
; sie hier abzulegen vereinfacht spätere Änderungen
Ini_con Equ	B'00000000'	; Interupt disable
Ini_opt	Equ	B'00000010'	; pull-up


;********************************************************
; Das Programm beginnt mit der Initialisierung

Init	bsf     STATUS, RP0	; Bank 1
	movlw   Ini_opt     	; pull-up Wiederstände ein
	movwf   OPTION_REG 
	movlw	B'00000000'	; PortB alle outputs 
	movwf	TRISB
	bcf     STATUS, RP0	; Bank 0
	clrf	PORTB		
	movlw   Ini_con     	; Interupt disable
	movwf   INTCON   

;Display initialisieren
	call	InitLcd

mainloop
	call	Tastfrei	; darauf warten, das keine Taste gedrückt ist	
;	call	WAIT		; entprellen nur bei schlechten Tasten nötig

drueck
	call	Tastatur	; wird nun eine Taste gedrückt?
	movfw	Taste		; Tastencode nach w; Taste=0 dann Z=1  
	btfsc	STATUS, Z	; skip wenn Taste<>0 
	goto	drueck		; Tastencode=0 d.h. keine Taste gedrückt, weiter warten

	call	OutLcdDaten	; Tastencode am LCD ausgeben
	goto	mainloop	; auf ein neues



;*****************************************************
;+++LCD-Routinen**************************************
;*****************************************************
;LCD initialisieren in 9 Schritten, Begrüßung ausgeben

InitLcd
	movlw	D'255'		; 250 ms Pause nach dem Einschalten
	movwf	loops	
	call	WAIT		

	movlw	B'00110000'	; 1
	movwf	LcdPort
	bsf	LcdE
	nop	
	bcf	LcdE
	
	movlw	D'50'		; 50 ms Pause
	movwf	loops
	call	WAIT
	
	movlw	B'00110000'	; 2
	call	Control8Bit
	movlw	B'00110000'	; 3
	call 	Control8Bit
	movlw	B'00100000'	; 4
	call 	Control8Bit

	movlw	B'00000001'	; löschen und cusor home
	call	OutLcdControl	
	movlw	B'00101000'	; 5 function set, 4-bit  2-zeilig,  5x7
	call	OutLcdControl	
	movlw	B'00001000'	; 6 display off
	call	OutLcdControl
	movlw	B'00000110'	; 7 entry mode, increment, disable display-shift
	call	OutLcdControl
	movlw	B'00000011'	; 8 cursor home, cursor home
	call	OutLcdControl
	movlw	B'00001111'	; 9 display on
	call	OutLcdControl

	movlw	'O'		; 'OK:' ausgeben
	call	OutLcdDaten
	movlw	'K'
	call	OutLcdDaten
	movlw	':'
	call	OutLcdDaten
	return

;*****************************************************
; ein Steuerbyte aus W 8-bittig übertragen
Control8Bit
	movwf	LcdPort
	bsf	LcdE
	nop
	bcf	LcdE
	movlw	D'10'
	movwf	loops
	call 	WAIT
	return

;*****************************************************
; darauf warten, daß das Display bereit zur Datenannahme ist
; dazu wird das busy-Bit des LCD abgefragt
LcdBusy
        bsf     STATUS, RP0	; make Port B4..7 input
	movlw	B'11110000'
	iorwf   TRISB, f 
        bcf     STATUS, RP0
BusyLoop		
	bcf	LcdRs		; Steuerregister
	bsf	LcdRw		; Lesen
	bsf	LcdE
	nop
	movf	LcdPort, w	; 4 obere Bits lesen (D7..D4)
	movwf	LcdStatus	; und in LcdStatus speichern
	bcf	LcdE
	nop
	bsf	LcdE
	nop			; 4 untere Bits lesen (D3..D0) und ignorieren
	bcf	LcdE
	btfsc	LcdStatus, 7	; teste bit 7
	goto	BusyLoop
	bcf	LcdRw
        bsf     STATUS, RP0	; make Port B4..7 output
	movlw	B'00001111'
	andwf   TRISB, f    
        bcf     STATUS, RP0
	return	

;*****************************************************
; aus W ein Byte mit Steuerdaten zum Display übertragen
OutLcdControl
	movwf	LcdDaten	; Byte in LcdDaten zwischenspeichern
	call	LcdBusy		; warten bis Display bereit ist
	movf	LcdDaten, w	; Byte zurück nach W holen
	andlw	H'F0'		; low-Teil löschen
	movwf	LcdPort		; Hi-teil Daten schreiben
	bsf	LcdE
	nop
	bcf	LcdE		; Disable LcdBus
	swapf	LcdDaten, w	; Byte verdreht nach W holen
	andlw	H'F0'		; High Teil löschen
	movwf	LcdPort		; Low-teil Daten schreiben
	bsf	LcdE
	nop
	bcf	LcdE		; Disable LcdBus
	return

;*****************************************************
; aus W ein Datenbyte (zum Anzeigen) an's Display übertragen
OutLcdDaten
	movwf	LcdDaten	; Byte in LcdDaten zwischenspeichern
	call	LcdBusy		; warten bis Display bereit ist
	movf	LcdDaten, w	; Byte zurück nach W holen
	andlw	H'F0'		; low-Teil löschen
	movwf	LcdPort		; Hi-teil Daten schreiben
	bsf	LcdRs		; Daten
	bsf	LcdE		; Enable LcdBus
	nop
	bcf	LcdE		; Disable LcdBus	
	swapf	LcdDaten, w	; Byte verdreht nach W holen
	andlw	H'F0'		; High Teil löschen
	movwf	LcdPort		; Low-teil Daten schreiben
	bsf	LcdRs		; Daten
	bsf	LcdE
	nop
	bcf	LcdE		; Disable LcdBus	
	bcf	LcdRs		;
	return


;*****************************************************
;+++Tastatur-Routinen*********************************
;*****************************************************
; warten darauf, daß keine Taste mehr gedrückt ist

Tastfrei			; Warten auf freie Tastatur
	call	Tastatur	; Tastencode nach Taste & W
	movfw	Taste		; wenn code=0 dann Z=1
	btfss	STATUS, Z	; wenn Z=1 dann skip
	goto	Tastfrei	; weiter warten
	return			; Tastatur ist frei

;*****************************************************
; ist eine Taste gedrückt? und welche?
; der Tastencode wird in W und Taste gespeichert (ASCII)
; wenn keine Taste gedrückt wurde, wird 0 zurückgegeben
;
; zur Erinnerung liste ich noch mal die weiter oben aufgeführten 
; Definitionen auf
; mit denen ist festgelegt, an welche Pins des PortB die einzelnen 
; Spalten und Zeilen der Tastatur abgeschlossen sind

;#define	KRow1	PORTB,1		;Keyboard 1 4 7 *
;#define	KRow2	PORTB,2		;Keyboard 2 5 8 0
;#define	KRow3	PORTB,3		;Keyboard 3 6 9 #
;#define	KLine1	PORTB,4		;Keyboard 1 2 3
;#define	KLine2	PORTB,5		;Keyboard 4 5 6
;#define	KLine3	PORTB,6		;Keyboard 7 8 9
;#define	KLine4	PORTB,7		;Keyboard * 0 #

Tastatur
	; zuerst müssen die Tastaturzeilen-Pins auf Eingang gestellt werden
	bsf     STATUS, RP0	; Bank 1
	movlw   Ini_opt     	; pull-up Widerstände ein
	movwf   OPTION_REG 
	movlw	B'11110000'	; RB0 .. RB3 output, RB4 .. RB7 input
	movwf	TRISB
	bcf     STATUS, RP0	; Bank 0

	; das Enable-Pin des Displays muß auf Low stehen, damit das Display 
	; abgeschaltet ist solange wir die Tastatur abfragen
	clrf	PORTB		; Display inaktiv am Bus

	; w wird auf 0 gesetzt, dieser Wert wird durch ein ASSCI-Zeichen
	; überschrieben, falls eine Taste gedrückt ist
	; falls keine Taste gedrückt ist, bleibt 0 erhalten
	movlw	0		; W=0

	bcf	KRow1		; 1. spalte aktivieren
	bsf	KRow3
	bsf	KRow2

	call	key1		; 1. Spalte abfragen

	bcf	KRow2		; 2.Spalte aktivieren
	bsf	KRow1		; 1.Spalte ausschalten

	call	key2		; 2. Spalte

	bcf	KRow3		; 3. Spalte aktivieren
	bsf	KRow2		; 2. spalte ausschalten

	call	key3		; 3. Spalte
	
	bsf	KRow3		; 3. Spalte ausschalten
	movwf	Taste

	; PortB wieder komplett zu Output machen
	bsf     STATUS, RP0	; Bank 1
	movlw	B'00000000'	; RB1 .. RB7 output
	movwf	TRISB
	bcf     STATUS, RP0	; Bank 0
	return

key1
	btfss	KLine1
	retlw	'1'
	btfss	KLine2
	retlw	'4'
	btfss	KLine3
	retlw	'7'
	btfss	KLine4
	retlw	'*'
	return
key2
	btfss	KLine1
	retlw	'2'
	btfss	KLine2
	retlw	'5'
	btfss	KLine3
	retlw	'8'
	btfss	KLine4
	retlw	'0'
	return
key3
	btfss	KLine1
	retlw	'3'
	btfss	KLine2
	retlw	'6'
	btfss	KLine3
	retlw	'9'
	btfss	KLine4
	retlw	'#'
	return


;*****************************************************************	
;Zeitverzögerung um loops * 1 ms *********************************
;*****************************************************************
; universelle Warteschleife, sowas braucht man öfter
; z.B. für die LCD-Initialisierung
; in loops wird die Wartezeit in Millisekunden übergeben
;
; 10 MHz externer Takt bedeutet 2,5 MHz interner Takt
; also dauert 1 ms genau 2500 Befehle
; 250 Schleifen a 10 Befehle sind 2500 Befehle = 1 ms

WAIT
top     movlw   .250           ; timing adjustment variable (1ms)
        movwf   loops2
top2    nop                    ; warten und nichts tun
        nop
        nop
        nop
	nop
        nop
        nop
        decfsz  loops2, F      ; innere Schleife fertig?
        goto    top2           ; nein, noch mal rum
                               ;
        decfsz  loops, F       ; äußere Schleife fertig?
        goto    top            ; nein, noch mal rum
        retlw   0              ; FERTIG und return


	end		
