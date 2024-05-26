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
    MOVE.W EPC,A0
    ADDA A0,A0
    MOVE.W EMEM(A0),D0
    MOVE.W D0, EIR
    ADDQ.W #1,EPC

    ;--- FFETCH: FIN FETCH
    
    
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

            SUBQ.W #2, SP ;Reservamos emoria en la pila
            MOVE.W EIR, -(SP) ;Almacenamos el EIR en la pila

            JSR    DECOD ;Entramos en la subrutina de decode
            ADDQ.W #2, SP ;Eliminamos el EIR de la pila
            MOVE.W (SP)+, D1 ;Alamcenamos la respuesta de decode en D1
        
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
    MOVE.W D0,D2 ;Movemos la instruccion en el registro D2
    AND #$FF,D2 ;Aplicamos una mascara a la instruccion
    MOVE.W D2,A2 ;Almaceenamos la direccion en A2
    LEA EMEM,A3 ;Guardamos la direccion efectiva de EMEM en A3

    *Realizamos operaciones para saber a que registro apuntar.
    MULU.W #2,D2
    ADD A2,A3
    
    BTST #11,D0 ;Comprobamos el valor del parametro J
    BNE STO1 ;Si j es 1 saltamos a la etiqueta STO1

    MOVE ER0,A2 ;Movemos el contenido ER0 a la direccion de memoria asignada
    BRA FETCH ;volvemos al decode

STO1:
    MOVE ER1,A2 ;Movemos el contenido ER0 a la direccion de memoria asignada
    BRA FETCH

ELOA:
    MOVE.W D0,D2 ;Movemos la instruccion en el registro D2
    AND #$FF,D2 ;Aplicamos una mascara a la instruccion
    LEA EMEM,A3 ;Guardamos la direccion de EMEM en un registro auxiliar

    *Realizamos operaciones para saber a que registro apuntar.
    MULU.W #2,D2
    ADDA D2,A3 ;Sumamos las direcciones para ver donde guardamos

    BTST #11,D0 ;Comprovamos el valor del parametro J
    BNE LOA1
    MOVE (A3),ER0 ;Movemos el contenido de m a ER0

    *Ejecutamos el subrutina para actualizar los flags
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    ADDQ #2,SP
    BRA FETCH

LOA1:
    MOVE (A3),ER1 ;Movemos el contenido de m a ER1

    *Ejecutamos el subrutina para actualizar los flags
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    ADDQ #2,SP

    BRA FETCH

ECMP:
   
    MOVE D0,D3 ;Movemos la instruccion a D3
    LEA ER0,A2 ;Almacenamos la direccion efectiva de ER0 en A2

    *Realizamos los calculos para apuntar a la posicion de memoria corecta.
    AND #%110000,D3
    LSR.W #3,D3
    MOVE D3,A2

    BTST #6,D0 ;Comprovamos el valor del parametro J
    BNE CMP1 
    
    MOVE.W ER0,D4
    CMP (A2),D4 ;Realizamos un cmp en la maquina local
    
    *Ejecutamos la actualizacion de los flags
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP

    BRA FETCH
CMP1:
    MOVE.W ER0,D4
    CMP.W (A2),D4 ;hacemos cmp entre ER1 y el registro A2
    
    *Ejecutamos la actualizacion de los flags
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP

    BRA FETCH

EADD:
    MOVE D0,D3 ;Movemos la instruccion a D3
    LEA ER0,A2 ;Mvemos la direccion efectiva de ER0
    AND #%110000,D3 ;aplicamos una mascara  para obtener aa

    *Realizamos operaciones para saber la posicion de memoria a la que apuntar
    LSR.W #3,D3
    ADDA D3,A2

    BTST #6,D0  ;Comprovamos el valor del parametro J
    BNE ADD1
    
    MOVE.W (A2),D4 ;Realizamos la operacion de suma
    ADD D4,ER0
    
    *Actualizamos los flags
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP

    BRA FETCH
ADD1:
    MOVE.W (A2),D4 ;Realizamos la operacion de suma
    ADD.W D4,ER1

    *Actualizamos los flags
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP

    BRA FETCH

ESUB:
    MOVE D0,D3 ;Almaceenamos en D3 la instruccion a realizar.
    LEA ER0,A2 ;Movemos la direccion efectiva de ER0
    
    AND #%110000,D3 ;Aplicamos una mascara para obtenemos aa
    LSR.W #3,D3
    ADDA D3,A2 ;Sumamos la direcciones para saber a donde apuntar
    
    BTST #6,D0 ;Comprovamos el valor de J
    BNE ADD1

    MOVE.W (A2),D4 ;Realizamos la operacion de resta
    SUB.W D4,ER0 

    *Actualizamos los flags
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP

    BRA FETCH
SUB1:
    MOVE.W (A2),D4;Realizamos la operacion de resta
    SUB.W D4,ER1

    *Actualizamos los flags
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP

    BRA FETCH


ENOR:
    MOVE D0,D3 ;Movemos la instruccion al registro D3
    LEA ER0,A2 ;movemos la direccion efectiva de ER0 a A2
    AND #%110000,D3 ;Aplicamos una mascara para leer aa
    LSR.W #3,D3

    MOVE D3,A3 ;movemos la direccion resultante a un registro auxiliar
    ADD A3,A2 ;sumamos la direcciones para saber a donde apuntar

    BTST #6,D0 ;Comprovamos el valor de J
    BNE NOR1

    MOVE.W ER0,D4 ;Realizamos la operacion encadednado un OR y un NOT
    OR.W D4,(A2)
    NOT D4 ;negamos el resultado

    *Actualizamos los flags
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    ADDQ #2,SP

    MOVE.W ER0,D4 ;Almaceenamos el resultado en ER0

    BRA FETCH
NOR1:
    MOVE.W D4,ER1 ;Realizamos la operacion encadednado un OR y un NOT
    OR.W D4,(A2)
    NOT D4

    *Actualizamos los flags
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    ADDQ #2,SP

    MOVE.W ER1,D4 ;Almaceenamos el resultado en ER1

    BRA FETCH


ESET:
    MOVE D0,D3 ;Movemos la instruccion al registro D3
    LEA ER0,A2
    AND #%11,D3 ;Aplicamos una mascara para obtener c

    *Realizamos operaciones para saber que posicion de memoria apuntar
    ADD D3,A2
    LSR #2,D3
    AND.W #$FF,D3
    MOVE.W D3,D4

    MOVE D5,(A2) ;movemos c al registro r
    EXT.W D4 ;extendemos el signo
    
    *Actualizamos los flags
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    ADDQ #2,SP

    MOVE.W D5,ER0
    BRA FETCH ;volvemos a decod

EADQ:
    MOVE D0,D3 ;Movemos la instruccion al registro D3
    LEA ER0,A2

    *Realizamos operaciones para obtener C
    AND #%11,D3
    MOVE D3,A3
    ADD A3,A2
    LSR #2,D3
    MOVE.B D3,D4 ;Almacenamos C en D4

    ADD D4,(A2) ;Realizamos la operacion de suma
    MOVE.W A2,D5
    EXT D5 ;Extendemos signo
    
    *Actrulizamos los flags
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    JSR AC
    ADDQ #2,SP

    BRA FETCH ;volvemos a decod

ETRA:
    MOVE D0,D3 ;movemos la instruccion a un registro auxiliar para operar
    AND #%11,D3 ;obtenemos b
    MULU.W #2,D3

    LEA ER0,A2 ;movemos la direccion de Er0 a un registro auxiliar
    ADDA D3,A2
    
    MOVE D0,D3
    LSR #3,D3 ;desplazamos 3 posiciones
    AND #%110,D3 ;obtenemos a
    
    LEA ER0,A3 ;movemos la direccion de Er0 a un registro auxiliar
    ADDA D3,A3

    MOVE (A3),(A2) ;movemos el contenido de Era a Erb
    
    *Actualizamos los flags
    MOVE.W SR,-(SP)
    JSR FLAGSZN
    ADDQ #2,SP

    BRA FETCH

EJMZ:
    LSR #4,D0 ;Desplazamos 4 bits para que el byte menos significativo sea m
    MOVE.W ESR,D2
    BTST #2,D2 ;comprobamos el flag Z
    BNE JMZ1

    BRA FETCH
JMZ1:
    AND.W #$FF,D0 ;Realizamos la operacion de cambio de PC
    MOVE.W  D0,EPC
    
    BRA FETCH


EJMN:
    LSR #4,D0 ;Desplazamos 4 bits para que el byte menos significativo sea m
    MOVE.W ESR,D2
    BTST #1,D2 ;comprobamos el flag N
    BNE JMN1

    BRA FETCH
JMN1:
    AND.W #$FF,D0 ;Realizamos la operacion de cambio de PC
    MOVE.W  D0,EPC
    BRA FETCH

EJMI:
    LSR #4,D0 ;desplazamos 4 bits para que el byte menos significativo sea m
    
    AND.W #$FF,D0 ;Realizamos la operacion de cambio de PC
    MOVE.W  EPC,D0
    BRA FETCH

EHLT:
    SIMHALT ;fin
    ;--- FEXEC: FIN EJECUCION
    
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

FLAGSZN: *Esta subrutina para actualizar solo los flags z y n

    MOVE.L D0,-(SP) ;Almacenamos los datos de D0 en la pila
    MOVE.W 2(SP),D0 ;Obtenemos el SR y lo almaceenamos en D0
    
    BTST #2,D0 ;Comprobamos el bit Z
    BNE ZES1
    BRA ZNES1
ZES1:
    MOVE.W ESR,D0 ;Seteamos el valor Z a 1
    BSET #2,D1

ZNES1:
    BTST #1,D0
    BNE NES1

NES1:
    MOVE.W ESR,D1
    BSET #1,D1  ;Seteamos el valor N a 1

NNES1:
    MOVE.W D1,ESR ;Almaceenamos el nuevo valor de ESR
    MOVE.L D0,(SP)+  ;Volvemos a cargar los datos de SP en D0
    RTS

AC: *Esta subrutina se encargara de almacenar C
    MOVE.L D0,-(SP) ;Almacenamos los datos de D0 en la pila
    MOVE.W 4(SP),D0 ;Obtenemos el SR y lo almaceenamos en D0

    BTST #0,D0
    BNE CES1
    BRA CNES1

CES1:
    MOVE.W ESR,D1
    BSET #0,D1
    MOVE.W D1,ESR

CNES1:
    MOVE.L D0,(SP)+ ;Volvemos a cargar los datos de SP en D0
    RTS
    ;--- FSUBR: FIN SUBRUTINAS
    
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
    MOVE.L D0,-(SP)       ; Cargar el valor de D0 en stack
    MOVE.W 8(SP),D0
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
    
    * Devolver STO como predeterminado
    MOVE.W #0,10(SP) ;Devolvemos el indice 0
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
    MOVE.W #2,10(SP) ;Devolvemos el indice 2
    BRA FINDEC

JUMP:
    BTST #13,D0            ; Comprobar si el bit 7 de D0 es 1
    BNE JMI
    
    BTST #12,D0            ; Comprobar si el bit 6 de D0 es 1
    BNE JMN
    
    MOVE.W #9,10(SP) ;Devolvemos el indice 9
    BRA FINDEC

ADD:
    MOVE.W #3,10(SP) ;Devolvemos el indice 3
    BRA FINDEC

SUBNOR:
    BTST #9,D0            ; Comprobar si el bit 9 de D0 es 1
    BNE NOR
    
    *Devolver la orden SUB
    MOVE.W #4,10(SP) ;Devolvemos el indice 4
    BRA FINDEC

NOR:
    MOVE.W #5,10(SP) ;Devolvemos el indice 5
    BRA FINDEC

SET:
    MOVE.W #6,10(SP) ;Devolvemos el indice 6
    BRA FINDEC

ADQTRA:
    BTST #12,D0            ;Comprobar si el bit 12 de D0 es 1
    BNE TRA
    
    *Devolver ADQ
    MOVE.W #7,10(SP) ;Devolvemos el indice 7
    BRA FINDEC

TRA:
    MOVE.W #8,10(SP) ;Devolvemos el indice 8
    BRA FINDEC


JMI:
    MOVE.W #11,10(SP) ;Devolvemos el indice 11
    BRA FINDEC

JMN:
    MOVE.W #10,10(SP) ;Devolvemos el indice 10
    BRA FINDEC

LOA:
    MOVE.W #1,10(SP) ;Devolvemos el indice 1
    BRA FINDEC

HTL:
    MOVE.W #12, 10(SP) ;Devolvemos el indice 12
    BRA FINDEC

FINDEC:
    MOVE.L (SP)+,D0        ; Restaurar D0
    RTS                   ; Retornar
    ;--- FDECOD: FIN DECOD
    END    STAR