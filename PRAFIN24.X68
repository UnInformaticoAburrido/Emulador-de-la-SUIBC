*-----------------------------------------------------------
* Title      : PRAFIN24
* Written by : Dimitry Comapny Cifre,Asier Zubillaga Llabres
* Date       : 26/05/2024
* Description: Emulador de la SUIBC
*-----------------------------------------------------------
    ORG $1000
EMEM:   DC.W $A807,$7012,$2050,$4860,$C000,$4460,$C000,$0001
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
        ;*** almacenando el resultado de la decodificacion en D1

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
    MOVE.B D1,A2 ;movemos el Byte menos significativo a un registro auxiliar
    LEA EMEM,A3 ;guardamos la direccion de EMEM en un registro auxiliar
    ADD A2,A3 ;sumamos las direcciones para ver donde guardamos
    
    BTST #11,D1 ;comprobamos la j
    BNE STO1 ;si j es 1 saltamos a la etiqueta STO1

    MOVE [ER0],A2 ;movemos el contenido ER0 a la direccion de memoria asignada
    BRA FETCH ;volvemos al decode
STO1:
    MOVE [ER1],A2 ;movemos el contenido ER0 a la direccion de memoria asignada
    BRA FETCH ;volvemos al decode


ELOA:
    MOVE.B D1,A2 ;movemos el Byte menos significativo a un registro auxiliar
    LEA EMEM,A3 ;guardamos la direccion de EMEM en un registro auxiliar
    ADDA A2,A2 
    ADDA A2,A3 ;sumamos las direcciones para ver donde guardamos
    BTST #11,D1 ;comprobamos la j
    BNE LOA1 ;si j=1 saltamos a la etiqueta LOA1
    MOVE (A3),ER0 ;movemos el contenido de m a ER0
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    ADDQ #2,SP
    BRA FETCH ;volvemos a decode
LOA1:
    MOVE (A3),ER1 ;movemos el contenido de m a ER1
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    ADDQ #2,SP
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP
    BRA FETCH ;volvemos a decode


ECMP:
   MOVE D1,D3 ;movemos la instruccion a un registro auxiliar para operar
*movemos de ER0 a memoria aprovechando que las direcciones de ER son contiguas
   LEA ER0,A2
   **110000
    AND #%110000,D3  ;mascara de bits para comprobar aa
    LSR.W #3,D3
    MOVE D3,A3 ;movemos la direccion resultante a otro registro
    ADDA A3,A2 ;las sumamos para apuntar al ER pertinente
    BTST #6,D1 ;comprobamos la j
    BNE CMP1 ;si j=1 saltamos a la etiqueta CMP1
    CMP.W ER0,(A2) ;hacemos un cmp entre Er0 y el registro A2
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP
    BRA FETCH ;volvemos a decod
CMP1:
    CMP.W ER1,(A2) ;hacemos cmp entre ER1 y el registro A2
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP
    BRA FETCH ;volvemos a decod

EADD:
    MOVE D1,D3 ;movemos la instruccion a un registro auxiliar para operar
    LEA ER0,A2 ;movemos la direccion de ER0
   **110000
    AND #%110000,D3 ;obtenemos aa
    LSR.W #3,D3
    MOVE D3,A3 ;movemos la direccion resultante a un registro auxiliar
    ADD A3,A2 ;sumamos la direcciones para saber a donde apuntar
    BTST #6,D1 ;comprobamos j
    BNE ADD1 ;j=1 saltamos a la etiqueta
    ADD.W ER0,(A2) ;sumamos el registro con el contenido de la direccion
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP
    BRA FETCH ;volvemos a decod
ADD1:
    ADD.W ER1,(A2) ;sumamos el registro con el contenido de la direccion
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP
    BRA FETCH ;volvemos a decod

ESUB:
    MOVE D1,D3 ;movemos la instruccion a un registro auxiliar para operar

    LEA ER0,A2 ;movemos la direccion de ER0 a un registro
   **110000
    AND #%110000,D3 ;obtenemos aa
    LSR.W #3,D3
    MOVE D3,A3 ;movemos la direccion resultante a un registro auxiliar
    ADD A3,A2 ;sumamos la direcciones para saber a donde apuntar
    BTST #6,D1 ;comprobamos j
    BNE SUB1 ;j=1 saltamos a la etiqueta
    SUB.W ER0,(A2) ;sumamos el registro con el contenido de la direccion
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP
    BRA FETCH ;volvemos a decod
SUB1:
    SUB.W ER1,(A2) ;sumamos el registro con el contenido de la direccion
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP
    BRA FETCH ;volvemos a decod


ENOR:
    MOVE D1,D3 ;movemos la instruccion a un registro auxiliar para operar
    LEA ER0,A2 ;movemos la direccion de ER0 a un registro
   **110000
    AND #%110000,D3 ;obtenemos aa
    LSR.W #3,D3
    MOVE D3,A3 ;movemos la direccion resultante a un registro auxiliar
    ADD A3,A2 ;sumamos la direcciones para saber a donde apuntar

    BTST #6,D1 ;comprobamos j
    BNE NOR1 ;j=1 saltamos a la etiqueta
    OR.W ER0,(A2) ;hacemos un or
    NOT ER0 ;negamos el resultado
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    ADDQ #2,SP    
    BRA FETCH ;volvemos a decod
NOR1:
    OR.W ER0,(A2) ;hacemos un or
    NOT ER0 ;negamos el resultado
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    ADDQ #2,SP
    BRA FETCH ;volvemos a decod


ESET:
    MOVE D1,D3 ;movemos la instruccion a un registro auxiliar para operar
    LEA ER0,A2 ;movemos la direccion de ER0 a un registro
    AND #%11,D3 ;obtenemos c
    MOVE D3,A3 ;movemos la direccion resultante a un registro auxiliar
    ADD A3,A2 ;sumamos la direcciones para saber a donde apuntar
    LSR #2,D3
    MOVE.B D3,D4
    MOVE D4,(A2) ;movemos c al registro r
    EXT (A2) ;extendemos el signo
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    ADDQ #2,SP
    BRA FETCH ;volvemos a decod

EADQ:
    MOVE D1,D3 ;movemos la instruccion a otro registro para operar
    LEA ER0,A2 ;movemos la instruccion a un registro auxiliar para operar
    AND #%11,D3 ;obtenemos b
    MOVE D3,A3 ;movemos a un registro auxiliar
    ADD A3,A2 ;sumamos las direcciones
    LSR #2,D3 ;desplazamos 2 para que el byte sea c
    MOVE.B D3,D4 ;movemos c a otro registro
    ADD D4,(A2) ;sumamos c mas el contenido de A2
    EXT (A2) ;extendemos signo
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP
    BRA FETCH ;volvemos a decod

ETRA:
    MOVE D1,D3 ;movemos la instruccion a un registro auxiliar para operar
    LEA ER0,A2 ;movemos la direccion de Er0 a un registro auxiliar
    AND #%11,D3 ;obtenemos b
    MOVE D3,A3 ;movemos a registro auxiliar
    LEA ER0,A4 ;movemos la direccion de Er0 a un registro auxiliar
    LSR #4,D3 ;desplazamos 4 posiciones
    AND #%11,D3 ;obtenemos a
    MOVE D3,A4 ;movemos a registro auxiliar
    MOVE (A4),A3 ;movemos el contenido a a a b
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    ADDQ #2,SP
    BRA FETCH ;volvemos a decod

EJMZ:
    LSR #4,D1 ;desplazamos 4 bits para que el byte menos significativo sea m
    BTST #2,ESR ;comprobamos el flag pertinente
    BNE JMZ1 ;saltamos a la etiqueta pertinente
        BRA FETCH ;volvemos a decod
JMZ1:
    MOVE.B  D1,EPC ;movemos 
    BRA FETCH ;volvemos a decod


EJMN:
    LSR #4,D1 ;desplazamos 4 bits para que el byte menos significativo sea m
    BTST #1,ESR ;comprobamos el flag pertinente
    BNE JMN1 ;saltamos a la etiqueta pertinente
    BRA FETCH ;volvemos a decod
JMN1:
    MOVE.B  D1,EPC
    BRA FETCH ;volvemos a decod

EJMI:
    LSR #4,D1 ;desplazamos 4 bits para que el byte menos significativo sea m
    BTST #0,ESR ;comprobamos el flag pertinente
    BNE JMI1 ;saltamos a la etiqueta pertinente
    BRA FETCH ;volvemos a decod
JMI1:
    MOVE.B  D1,EPC
    BRA FETCH ;volvemos a decod

EHLT:
    SIMHALT ;fin
    ;--- FEXEC: FIN EJECUCION
    
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

FLAGSZN: *Esta subrutina para actualizar solo los flags z y n
    MOVE.L D0,-(SP)
    MOVE.W 2(SP),D0
    BTST #15,D0
    BNE ZES1
    BRA ZNES1
ZES1:
    MOVE.W ESR,D1
    BSET #2,D1
    MOVE.W D1,ESR
ZNES1:
    BTST #1,D0
    BNE NES1
    BRA NNES1
NES1:
    MOVE.W ESR,D1
    BSET #1,D1
    MOVE.W D1,ESR
NNES1:
    MOVE.L D0,(SP)+
    RTS

AC:
    MOVE.L D0,-(SP)
    MOVE.W 4(SP),D0
    BTST #0,D0
    BNE CES1
    BRA CNES1
CES1:
    MOVE.W ESR,D1
    BSET #0,D1
    MOVE.W D1,ESR
CNES1:
    MOVE.L D0,(SP)+
    RTS
    ;--- FSUBR: FIN SUBRUTINAS
    
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
    MOVE.L D0,-(SP)       ; Cargar el valor de D0 en stack
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
    MOVE.W #0,10(SP)
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
    MOVE.W #2,10(SP)
    BRA FINDEC

JUMP:
    BTST #13,D0            ; Comprobar si el bit 7 de D0 es 1
    BNE JMI
    BTST #12,D0            ; Comprobar si el bit 6 de D0 es 1
    BNE JMN
    *Devolver el JMZ
    MOVE.W #9,10(SP)
    BRA FINDEC

ADD:
    MOVE.W #3,10(SP)
    BRA FINDEC

SUBNOR:
    BTST #9,D0            ; Comprobar si el bit 9 de D0 es 1
    BNE NOR
    *Devolver la orden SUB
    MOVE.W #4,10(SP)
    BRA FINDEC

NOR:
    MOVE.W #5,10(SP)
    BRA FINDEC

SET:
    MOVE.W #6,10(SP)
    BRA FINDEC

ADQTRA:
    BTST #12,D0            ; Comprobar si el bit 8 de D0 es 1
    BNE TRA
    ; Devolver ADQ
    MOVE.W #7,10(SP)
    BRA FINDEC

TRA:
    MOVE.W #8,10(SP)
    BRA FINDEC


JMI:
    MOVE.W #11,10(SP)
    BRA FINDEC

JMN:
    MOVE.W #10,10(SP)
    BRA FINDEC

LOA:
    MOVE.W #1,10(SP)
    BRA FINDEC

HTL:
    MOVE.W #12, 10(SP)
    BRA FINDEC

FINDEC:
    MOVE.L (SP)+,D0        ; Restaurar D0
    RTS                   ; Retornar

    ;--- FDECOD: FIN DECOD
    END    START
