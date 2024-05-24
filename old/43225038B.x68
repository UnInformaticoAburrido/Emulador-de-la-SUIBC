*------------------------------------------------
* Titulo : P1 (2023-2024) - Sieve of Eratosthenes
* Autores: Dimitry Comapny Cifre
*------------------------------------------------
	ORG $1000
N: EQU 10
P: DS.B N
    DS.W 0
C: DS.W 1
*------------------------------------------------
START:
	MOVE.B #N,D1
	SUBQ.B #1,D1
	LEA P,A0
	MOVE.B #1,D0
GL:
	MOVE.B D0, (A0)+
	ADDQ.B #1,D0
	DBRA D1,GL
	CLR.L D1 *Limpiamos el registro D1 para evitar problemas problemas durante la ejecucion
	ADDQ.B #3,D3
	MOVE.B #N,D4
	SUB.B D3,D4
	LEA P,A0
	LEA C,A3 *ALMACENAMOS C EN A3
	ADDQ #1,D2
BucleDivisor:
	ADDQ #1,A0
	MOVE.B (A0),D1
	TST.B D1 *Evitamos que el divisor pueda llegar a ser 0
	BEQ DESCARTE
	LEA P,A1
	MOVE.L #N,D5 *Uso un long para sobre escribir los bits residuales
BucleDividendo:
	ADDQ #1,A1
	MOVE.B (A1),D0
	TST.B D0 *Comprovamos que D0 no es igual a 0
	BEQ CERO
	CMP.W D0,D1 *Comaprovamos que el divisor y el dividendo no son iguales
	BEQ CERO
	DIVU.W D1,D0 *Dividimos los dos numeros
	LSR.L #8,D0 *Realizamos la operacion de LSR dos veces para moverlo 16 bits
	LSR.L #8,D0 *Lo realizo dos veces no me ha quedado muy claro si es por deficiencia de 68K o del simulador
	CMP.W #0,D0
	BGT CERO *En caso de que D0 sea superior  a 0 nos saltamos la siguiente instrucion
            MOVE.B #0,(A1)
CERO:
	DBRA D5,BucleDividendo
DESCARTE:
	DBRA D4,BucleDivisor
	*Vamos a contar todos los numeros diferentes a 0 (primos)
	CLR.L D2 *Limpiamos d2
	LEA P,A0
	    MOVE.B #N,D1
CONTAR:
	    MOVE.B (A0),D0
	    CMP.W #0,D0 *Comparamos si el componente interno de D0 es igual a 0
	    BEQ NOCONTAR *En caso de que D0 !=0 nos saltamos la sigueite instruccion
	    ADDQ #1,D2
NOCONTAR:
	    ADDQ #1,A0 *Movemos el puntero al sigueite elemento
	DBRA  D1,CONTAR
	MOVE.W D2,(A2) *Almacenamos el valor de nuestro contador a C
    SIMHALT

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
