*-----------------------------------------------------------
* Title      : PRAFIN24
* Written by : Dimitry Comapny Cifre
* Date       : 26/05/2024
* Description: Emulador de la SUIBC
*-----------------------------------------------------------
    ORG $1000
EMEM:   DC.W $A00C,$00A0,$7002,$5000,$A80D,$00A0,$4420,$63FD
        DC.W $00A0,$2060,$800E,$C000,$0003,$0004,$0000
EIR:    DC.W 0 ;eregistro de instruccion
EPC:    DC.W 0 ;econtador de programa
ER0:    DC.W 0 ;eregistro R0
ER1:    DC.W 0 ;eregistro R1
ER2:    DC.W 0 ;eregistro R2
ER3:    DC.W 0 ;eregistro R3
ESR:    DC.W 0 ;eregistro de estado (00000000 00000ZNC)

START:
    CLR.W EPC

FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC,
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	    ADDQ.W #1, A4
    MOVE.W EPC,A0
    MOVE.W EMEM(A0), D0
    MOVE.W D0, EIR
    ADDQ.W #2,EPC


    ;--- FFETCH: FIN FETCH
    
    
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1al grupo corespondiente

            ;Preparamos stack
            SUBQ.W #2, SP
            MOVE.W EIR, -(SP)
    	    ;Llamamos a decod de libreria
            JSR    DECOD
            ADDQ.W #2, SP
            MOVE.W (SP)+, D1
            ;Recogemos resultados del stack

        
    ;--- FBRDECOD: FIN SALTO A DECOD
    
    
    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
    MULU #6,D1
    MOVEA.L D1,A1
    JMP JMPLIST(A1)
JMPLIST:
    JMP ESTO
    JMP ELOA
    JMP ECMP
    JMP EADD
    JMP ESUB
    JMP ENOR
    JMP ESET
    JMP EADQ
    JMP ETRA
    JMP EJMZ
    JMP EJMN
    JMP EJMI
    JMP EHLT
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
ESTO:
    MOVE.W #1,A6
    BRA FETCH
ELOA:
    MOVE.W #2,A6
    BRA FETCH
ECMP:
    MOVE.W #3,A6
    BRA FETCH
EADD:
    MOVE.W #4,A6
    BRA FETCH
ESUB:
    MOVE.W #5,A6
    BRA FETCH
ENOR:
    MOVE.W #6,A6
    BRA FETCH
ESET:
    MOVE.W #6,A6
    BRA FETCH
EADQ:
    MOVE.W #7,A6
    BRA FETCH
ETRA:
    MOVE.W #8,A6
    BRA FETCH
EJMZ:
    MOVE.W #9,A6
    BRA FETCH
EJMN:
    MOVE.W #10,A6
    BRA FETCH
EJMI:
    MOVE.W #11,A6
    BRA FETCH
EHLT:
    SIMHALT
    ;--- FEXEC: FIN EJECUCION
    
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

	        ; ESCRIBID VUESTRO CODIGO AQUI
        
    ;--- FSUBR: FIN SUBRUTINAS
    
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
    MOVE.L D0,-(SP)       ; Cargar el valor de D0 en stack
    MOVE.L D7,-(SP)      ; Cargar el valor de D7 en stack
    MOVE.W 12(SP),D0
    BTST #15,D0           ; Comprobar si el bit 15 de D0 es 1
    BNE GM                ; Saltar a GM si Z=1 (bit 15 es 0)
    
    ; Comprobar las funciones de ALU y JUMP
    ; Comprobar el primer uno localizado
    BTST #14,D0           ; Comprobar si el bit 14 de D0 es 1
    BNE ALU
    BRA JUMP

GM:
    BTST #14,D0            ; Comprobar si el bit 5 de D0 es 1
    BNE HTL
    BTST #13,D0            ; Comprobar si el bit 4 de D0 es 1
    BNE LOA
    ; Devolver STO como predeterminado
    MOVE.W #0,14(SP)
    BRA FINDEC

ALU:
    BTST #13,D0           ; Comprobar si el bit 13 de D0 es 1
    BNE ADQTRA
    BTST #12,D0           ; Comprobar si el bit 12 de D0 es 1
    BNE SET
    BTST #11,D0           ; Comprobar si el bit 11 de D0 es 1
    BNE SUBNOR
    BTST #10,D0           ; Comprobar si el bit 10 de D0 es 1
    BNE ADD
    *Devolver la orden CMP
    MOVE.W #2,14(SP)
    BRA FINDEC

JUMP:
    BTST #12,D0            ; Comprobar si el bit 7 de D0 es 1
    BNE JMI
    BTST #11,D0            ; Comprobar si el bit 6 de D0 es 1
    BNE JMN
    *Devolver el JMZ
    MOVE.W #9,14(SP)
    BRA FINDEC

ADD:
    MOVE.W #3,14(SP)
    BRA FINDEC

SUBNOR:
    BTST #9,D0            ; Comprobar si el bit 9 de D0 es 1
    BNE NOR
    *Devolver la orden SUB
    MOVE.W #4,14(SP)
    BRA FINDEC

NOR:
    MOVE.W #5,14(SP)
    BRA FINDEC

SET:
    MOVE.W #6,14(SP)
    BRA FINDEC

ADQTRA:
    BTST #8,D0            ; Comprobar si el bit 8 de D0 es 1
    BNE TRA
    ; Devolver ADQ
    MOVE.W #7,14(SP)
    BRA FINDEC

TRA:
    MOVE.W #8,14(SP)
    BRA FINDEC


JMI:
    MOVE.W #11,14(SP)
    BRA FINDEC

JMN:
    MOVE.W #10,14(SP)
    BRA FINDEC

LOA:
    MOVE.W #1,14(SP)
    BRA FINDEC

HTL:
    MOVE.W #12, 14(SP)
    BRA FINDEC

FINDEC:
    MOVE.L (SP)+,D7      ; Restaurar D7
    MOVE.L (SP)+,D0        ; Restaurar D0
    RTS                   ; Retornar

    ;--- FDECOD: FIN DECOD
    END    START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
