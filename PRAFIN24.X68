*-----------------------------------------------------------
* Title      : PRAFIN24
* Written by : Dimitry Comapny Cifre,Asier Zubillaga Llabres
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
	
	        ; ESCRIBID VUESTRO CODIGO AQUI
    LEA EIR,D6
BUCLEFETCH:
    ADDQ #1,D6;añadimos 1 a la posicion de memoria de d6
    MOVE.W EPC,D1
    MOVE.L EMEM(D1),A1;movemos la posicion a1 de EMEM a A1
    BRA DECOD
    *Final fetch
    ;--- FFETCH: FIN FETCH
    
    
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

    	    ; ESCRIBID VUESTRO CODIGO AQUI    	    
        
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
    
    MOVE.B D1,A2
    LEA EMEM,A3
    ADD A2,A3
    
    BTST #11,D1
    BNE STO1

    MOVE [ER0],A2
    BRA HLT
STO1:
    MOVE [ER1],A2
    BRA HLT


ELOA:
    MOVE.B D1,A2
    LEA EMEM,A3
    ADD A2,A3

    BTST #11,D1
    BNE LOA1

    MOVE [M],ER0
    BRA HLT
LOA1:
    MOVE [M],ER1
    BRA HLT


ECMP:
   
   MOVE D1,D2

   LEA ER0,A2
   **110000
    AND #%110000,D3
    LSR.W #3,D3
    MOVE D3,A3
    ADD A3,A2

    BTST #6,D1
    BNE CMP1
    CMP.W ER0,(A2)
    BRA HLT
CMP1:
    CMP.W ER1,(A2)
    BRA HLT


EADD:
    MOVE D1,D2

   LEA ER0,A2
   **110000
    AND #%110000,D3
    LSR.W #3,D3
    MOVE D3,A3
    ADD A3,A2

    BTST #6,D1
    BNE ADD1
    ADD.W ER0,(A2)
    BRA HLT
ADD1:
    ADD.W ER1,(A2)
    BRA HLT


ESUB:
    MOVE D1,D2

   LEA ER0,A2
   **110000
    AND #%110000,D3
    LSR.W #3,D3
    MOVE D3,A3
    ADD A3,A2

    BTST #6,D1
    BNE SUB1
    SUB.W ER0,(A2)
    BRA HLT
SUB1:
    SUB.W ER1,(A2)
    BRA HLT


ENOR:
    MOVE D1,D2

   LEA ER0,A2
   **110000
    AND #%110000,D3
    LSR.W #3,D3
    MOVE D3,A3
    ADD A3,A2

    BTST #6,D1
    BNE NOR1
    OR.W ER0,(A2)
    NOT ER0
    BRA HLT
NOR1:
    OR.W ER0,(A2)
    NOT ER0
    BRA HLT


ESET:
    MOVE D1,D2

    LEA ER0,A2
    AND #%11,D3
    MOVE D3,A3
    ADD.W A3,A2


EADQ:

ETRA:
    LEA ER0,A2
    LEA ER0,A4

    MOVE D1,D2

    AND #%110000,D3
    LSR.W #3,D3
    MOVE D3,A3
    ADD A3,A2

EJMZ:
    LSR #4,D1
    BTST #2,ESR
    BNE JMZ1
    BRA HLT
JMZ1:
    MOVE.B  D1,EPC
    BRA HLT


EJMN:
    LSR #4,D1
    BTST #1,ESR
    BNE JMN1
    BRA HLT
JMN1:
    MOVE.B  D1,EPC
    BRA HLT


EJMI:
    LSR #4,D1
    BTST #0,ESR
    BNE JMI1
    BRA HLT
JMI1:
    MOVE.B  D1,EPC

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
	        ; ESCRIBID VUESTRO CODIGO AQUI
    MOVE.W #15,D7 *Uso D7 como contador
DECODLOOP:
    BTST D7,A1
    BNE SWITCH;salta si el bit 15 es 1
    DBRA D7,DECODLOOP
SWITCH:
    CMP #15,D7
    BNE GM;salta si z=0
    CMP #14,D7
    BNE ALU
    CMP #13,D7
    BNE JUMP
GM:
    SUBQ #1,D7
    BTST D7,A1
    BNE HLT
    SUBQ #1,D7
    BTST D7,A1
    BNE LOA
    BRA STO

STO:
    MOVE.W #1,(D6)
LOA:
    MOVE.W #1,(D6)
HTL:
    MOVE.W #12,(D6)
    BRA 
ALU:
    *cOMPROVAMOS LAS INSTRUCCIONES DE ALU
    SUBQ #1,D7
    BTST D7,A1
    BNE HLT
JUMP:
    ;--- FDECOD: FIN DECOD
    END    START