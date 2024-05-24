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
    
    MOVE.B D1,A2;movemos el Byte menos significativo (m) a un registro auxiliar
    LEA EMEM,A3;guardamos la direccion de EMEM en un registro auxiliar
    ADD A2,A3;sumamos las direcciones para ver donde guardamos
    
    BTST #11,D1;comprobamos la j
    BNE STO1;si j es 1 saltamos a la etiqueta STO1

    MOVE [ER0],A2 ;movemos el contenido de ER0 a la direccion de memoria asignada
    BRA DECODLOOP ;volvemos al decode
STO1:
    MOVE [ER1],A2;movemos el contenido de ER0 a la direccion de memoria asignada
    BRA DECODLOOP;volvemos al decode


ELOA:
    MOVE.B D1,A2;movemos el Byte menos significativo (m) a un registro auxiliar
    LEA EMEM,A3;guardamos la direccion de EMEM en un registro auxiliar
    ADD A2,A3;sumamos las direcciones para ver donde guardamos

    BTST #11,D1;comprobamos la j
    BNE LOA1;si j=1 saltamos a la etiqueta LOA1

    MOVE [M],ER0; movemos el contenido de m a ER0
    BRA DECODLOOP;volvemos a decode
LOA1:
    MOVE [M],ER1; movemos el contenido de m a ER1
    BRA DECODLOOP;volvemos a decode


ECMP:
   MOVE D1,D3;movemos la instruccion a un registro auxiliar para operar

   LEA ER0,A2;movemos la direccion de ER0 a un registro ya que las direcciones de los ER estan contiguas
   **110000
    AND #%110000,D3  ;mascara de bits para comprobar aa
    LSR.W #3,D3
    MOVE D3,A3;movemos la direccion resultante a otro registro
    ADD A3,A2;las sumamos para apuntar al ER pertinente

    BTST #6,D1;comprobamos la j
    BNE CMP1;si j=1 saltamos a la etiqueta CMP1
    CMP.W ER0,(A2);hacemos un cmp entre Er0 y el registro al que apunta la direccion
    BRA DECOD;volvemos a decod
CMP1:
    CMP.W ER1,(A2);hacemos cmp entre ER1 y el registro al que apunta la direccion
    BRA DECOD;volvemos a decod


EADD:
    MOVE D1,D3;movemos la instruccion a un registro auxiliar para operar

   LEA ER0,A2;movemos la direccion de ER0 a un registro ya que las direcciones de los ER estan contiguas
   **110000
    AND #%110000,D3;obtenemos aa
    LSR.W #3,D3
    MOVE D3,A3;movemos la direccion resultante a un registro auxiliar
    ADD A3,A2;sumamos la direcciones para saber a donde apuntar

    BTST #6,D1;comprobamos j
    BNE ADD1;j=1 saltamos a la etiqueta
    ADD.W ER0,(A2);sumamos el registro con el contenido de la direccion
    BRA DECOD;volvemos a decod
ADD1:
    ADD.W ER1,(A2);sumamos el registro con el contenido de la direccion
    BRA DECOD;volvemos a decod


ESUB:
    MOVE D1,D3;movemos la instruccion a un registro auxiliar para operar

   LEA ER0,A2;movemos la direccion de ER0 a un registro ya que las direcciones de los ER estan contiguas
   **110000
    AND #%110000,D3;obtenemos aa
    LSR.W #3,D3
    MOVE D3,A3;movemos la direccion resultante a un registro auxiliar
    ADD A3,A2;sumamos la direcciones para saber a donde apuntar

    BTST #6,D1;comprobamos j
    BNE SUB1;j=1 saltamos a la etiqueta
    SUB.W ER0,(A2);sumamos el registro con el contenido de la direccion
    BRA DECOD;volvemos a decod
SUB1:
    SUB.W ER1,(A2);sumamos el registro con el contenido de la direccion
    BRA DECOD;volvemos a decod


ENOR:
    MOVE D1,D3;movemos la instruccion a un registro auxiliar para operar

   LEA ER0,A2;movemos la direccion de ER0 a un registro ya que las direcciones de los ER estan contiguas
   **110000
    AND #%110000,D3;obtenemos aa
    LSR.W #3,D3
    MOVE D3,A3;movemos la direccion resultante a un registro auxiliar
    ADD A3,A2;sumamos la direcciones para saber a donde apuntar

    BTST #6,D1;comprobamos j
    BNE NOR1;j=1 saltamos a la etiqueta
    OR.W ER0,(A2);hacemos un or
    NOT ER0;negamos el resultado
    BRA DECOD;volvemos a decod
NOR1:
    OR.W ER0,(A2);hacemos un or
    NOT ER0;negamos el resultado
    BRA DECOD;volvemos a decod


ESET:
    MOVE D1,D3;movemos la instruccion a un registro auxiliar para operar

    LEA ER0,A2;movemos la direccion de ER0 a un registro ya que las direcciones de los ER estan contiguas
    AND #%11,D3;obtenemos c
    MOVE D3,A3;movemos la direccion resultante a un registro auxiliar
    ADD A3,A2;sumamos la direcciones para saber a donde apuntar

    LSR #2,D3
    MOVE.B D3,D4

    MOVE D4,(A2);movemos c al registro r
    EXT (A2);extendemos el signo

    BRA DECOD;volvemos a decod


EADQ:

    MOVE D1,D3;movemos la instruccion a un registro auxiliar para operar

    LEA ER0,A2;movemos la instruccion a un registro auxiliar para operar
    AND #%11,D3;obtenemos b
    MOVE D3,A3;movemos a un registro auxiliar
    ADD A3,A2;sumamos las direcciones

    LSR #2,D3;desplazamos 2 para que el byte sea c
    MOVE.B D3,D4;movemos c a otro registro

    ADD D4,(A2)sumamos c mas el contenido de la direccion de a que es el Er pertinente
    EXT (A2);extendemos signo

    BRA DECOD;volvemos a decod

ETRA:
    MOVE D1,D3;movemos la instruccion a un registro auxiliar para operar

    LEA ER0,A2;movemos la direccion de Er0 a un registro auxiliar
    AND #%11,D3;obtenemos b
    MOVE D3,A3;movemos a registro auxiliar

    LEA ER0,A4;movemos la direccion de Er0 a un registro auxiliar
    LSR #4,D3;desplazamos 4 posiciones para poner a en los 2 bits menos significativos
    AND #%11,D3;obtenemos a
    MOVE D3,A4;movemos a registro auxiliar

    MOVE ((A4)),A3 movemos el contenido a a a b

    BRA DECOD;volvemos a decod

EJMZ:
    LSR #4,D1;desplazamos 4 bits para que el byte menos significativo sea m
    BTST #2,ESR;comprobamos el flag pertinente
    BNE JMZ1;saltamos a la etiqueta pertinente
    BRA DECOD;volvemos a decod
JMZ1:
    MOVE.B  D1,EPC;movemos 
    BRA DECOD;volvemos a decod


EJMN:
    LSR #4,D1;desplazamos 4 bits para que el byte menos significativo sea m
    BTST #1,ESR;comprobamos el flag pertinente
    BNE JMN1;saltamos a la etiqueta pertinente
    BRA DECOD;volvemos a decod
JMN1:
    MOVE.B  D1,EPC
    BRA DECOD;volvemos a decod


EJMI:
    LSR #4,D1;desplazamos 4 bits para que el byte menos significativo sea m
    BTST #0,ESR;comprobamos el flag pertinente
    BNE JMI1;saltamos a la etiqueta pertinente
    BRA DECOD;volvemos a decod
JMI1:
    MOVE.B  D1,EPC
    BRA DECOD;volvemos a decod

EHLT:
    SIMHALT;fin
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