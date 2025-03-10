*-----------------------------------------------------------
* Title      : PRAREC23
* Written by : Antoni Navarro Moreno
*              Constantino PÃ©rez Palacios
*              Juan Francisco Riera FernÃ¡ndez
* Date       : 30/06/2023
* Description: Emulador de la SAL9000
*-----------------------------------------------------------
    ORG $1000
EMEM: DC.W $2882,$289B,$28B4,$281D,$C026,$0060,$C037,$0071,$1900
      DC.W $1910,$0816,$E046,$27FD,$4008,$77A8,$8000,$0001
      DC.W $0001,$0001,$0001,$0001,$0001,$0000,$0000,$0000
EIR:  DC.W 0 ;eregistro de instruccion
EPC:  DC.W 0 ;econtador de programa
ET0:  DC.W 0 ;eregistro T0
ET1:  DC.W 0 ;eregistro T1
EX2:  DC.W 0 ;eregistro X2
EX3:  DC.W 0 ;eregistro X3
EX4:  DC.W 0 ;eregistro X4
EX5:  DC.W 0 ;eregistro X5
EX6:  DC.W 0 ;eregistro X6
EX7:  DC.W 0 ;eregistro X7
ESR:  DC.W 0 ;eregistro de estado (00000000 00000ZCN)

START:
    CLR.W EPC

FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC,
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	
	        ; ESCRIBID VUESTRO CODIGO AQUI
            
            MOVE.W EPC,D3
            ADD.W D3,D3
            MOVEA.W D3,A0
            MOVE.W EMEM(A0),EIR         ;obtención de la siguiente instrucción
            ADDQ.W #1,EPC               ;incremento del contador de programa 
                                        ;para acceder a la siguiente instrucción
                                        ;más adelante
        
    ;--- FFETCH: FIN FETCH
    
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

    	    ; ESCRIBID VUESTRO CODIGO AQUI
    	    
            MOVE.W #0,-(SP)             ;dejamos un espacio en blanco para 
                                        ;devolver el id de la enstrucción
            MOVE.W EIR,-(SP)            ;paso de los parametros pertinenetes
            JSR DECOD
            ADDQ.W #2,SP                ;vaciado de la pila para obtener el
                                        ;parámetro de salida
            MOVE.W (SP)+,D1
        
    ;--- FBRDECOD: FIN SALTO A DECOD
    
    
    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
    MULU #6,D1
    MOVEA.L D1,A1
    JMP JMPLIST(A1)
JMPLIST:
    JMP ECOPY
    JMP EADD
    JMP ESUB
    JMP ELSH
    JMP EADQ
    JMP ESET
    JMP EOR
    JMP ENOT
    JMP EGOZ
    JMP EGOC
    JMP EGON
    JMP EGOI
    JMP EEXIT
    JMP ELOIP
    JMP ELOA
    JMP ESTIP
    JMP ESTO
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
ECOPY:
        JSR REGISTRO_B                  ;obtención de la posición de memoria del
                                        ;registro b
        MOVE.W (A2),D5
        JSR REGISTRO_C                  ;obtención de la posición de memoria del
                                        ;registro c
        MOVE.W D5,(A3)
        MOVE.W D5,D6
        MOVE.W ESR,D7
        JSR ZN_FLAG
        BRA FETCH
        
EADD:
        JSR REGISTRO_A                  ;obtención de la posición de memoria del
                                        ;registro a
        MOVE.W (A1),D4
        JSR REGISTRO_B                  ;obtención de la posición de memoria del
                                        ;registro b
        MOVE.W (A2),D5
        JSR REGISTRO_C                  ;obtención de la posición de memoria del
                                        ;registro c
        ADD.W D4,D5
        MOVE.W SR,D6
        MOVE.W ESR,D7
        MOVE.W D5,(A3)        
        JSR ACT_ESR_C                   ;actualización de los flags
        BRA FETCH
        
ESUB:
        JSR REGISTRO_A                  ;obtención de la posición de memoria del
                                        ;registro a
        MOVE.W (A1),D4
        JSR REGISTRO_B                  ;obtención de la posición de memoria del
                                        ;registro b
        MOVE.W (A2),D5
        JSR REGISTRO_C                  ;obtención de la posición de memoria del
                                        ;registro b
        NEG D5
        ADDQ.W #1,D5
        ADD.W D4,D5
        MOVE.W SR,D6
        MOVE.W ESR,D7
        MOVE.W D5,(A3)
        JSR ACT_ESR_C
        BRA FETCH

ELSH:
        CLR D5
        MOVE.W EIR,D5                   ;mover la instrucción a ejecutar
        MOVE.W #$0700,D2                ;mascara para obtener la p
        AND.W D5,D2
        LSR #8,D2                       ;desplazamiento a la izquierda del valor
                                        ;del registro b
        MOVE.B D2,D3
        EXT D3
        JSR REGISTRO_B                  ;obtención de la posición de memoria del
                                        ;registro b
        MOVE.W (A2),D4
        BTST #0,D5
        BNE RS
        LSL D3,D4                       ;desplazamiento a la izquierda del valor
                                        ;del registro b
        MOVE.W SR,D6
        MOVE.W D4,(A2)
        MOVE.W ESR,D7
        JSR ACT_ESR_C                   ;actualización de flags
        BRA FIN_ELSH        
RS:     
        LSR D3,D4
        MOVE.W SR,D6
        MOVE.W D4,(A2)
        MOVE.W ESR,D7
        JSR C_FLAG                      ;actualización de flags
FIN_ELSH:
        BRA FETCH
        
EADQ:
        JSR REGISTRO_C                  ;obtención de la posición de memoria del
                                        ;registro c
        JSR FETCH_K                     ;obtención de un número
        EXT.W D4
        ADD.W D4,(A3)
        MOVE.W SR,D6
        MOVE.W ESR,D7
        JSR ACT_ESR_C                   ;actualización de flags
        BRA FETCH
        
ESET:
        JSR REGISTRO_C                  ;obtención de la posición de memoria del
                                        ;registro c
        JSR FETCH_K
        EXT.W D4
        MOVE.W D4,(A3)
        MOVE.W (A3),D6
        MOVE.W ESR,D7
        JSR ZN_FLAG                     ;actualización de flags
        BRA FETCH
        
EOR:
        JSR REGISTRO_A                  ;obtención de la posición de memoria del
                                        ;registro a
        MOVE.W (A1),D4
        JSR REGISTRO_B                  ;obtención de la posición de memoria del
                                        ;registro b
        MOVE.W (A2),D5
        OR.W D4,D5
        MOVE.W SR,D6
        MOVE.W ESR,D7
        JSR REGISTRO_C                  ;obtención de la posición de memoria del
                                        ;registro c
        MOVE.W D5,(A3)
        JSR ACT_ESR_ZN                  ;actualización de flags
        BRA FETCH
        
ENOT:   
        JSR REGISTRO_C                  ;obtención de la posición de memoria del
                                        ;registro c
        MOVE.W (A3),D4
        NOT.W D4                        
        MOVE.W SR,D6
        MOVE.W ESR,D7
        MOVE.W D4,(A3)              
        JSR ACT_ESR_C                   ;actualización de flags
        BRA FETCH
EGOZ:
        MOVE.W ESR,D6
        BTST.L #2,D6                    ; comprobamos si el flag Z es 0
        BEQ FETCH                       ; si lo es, volvemos a la fase de fetch
        JSR FETCH_K
        EXT.W D4                        ; extendemos el signo de K
        ADD.W (EPC),D4
        MOVE.W D4,EPC
        BRA FETCH
    
EGOC:
        MOVE.W ESR,D6           
        BTST.L #1,D6                    ; comprobamos si el flag N es 0
        BEQ FETCH                       ; si lo es, volvemos a la fase de fetch
        JSR FETCH_K
        EXT.W D4                        ; extendemos el signo de K
        ADD.W (EPC),D4
        MOVE.W D4,EPC                   ; si es 1, se carga M en el PC
        BRA FETCH

EGON:
        MOVE.W ESR,D6           
        BTST.L #0,D6                    ; comprobamos si el flag N es 0
        BEQ FETCH                       ; si lo es, volvemos a la fase de fetch
        JSR FETCH_K
        EXT.W D4                        ; extendemos el signo de K
        ADD.W (EPC),D4
        MOVE.W D4,EPC                   ; si es 1, se carga M en el PC
        BRA FETCH
    
EGOI:
        JSR FETCH_K                     ;obtención del número
        EXT.W D4
        ADD.W (EPC),D4                  ; extendemos el signo de K
        MOVE.W D4,EPC                   ; cargamos M en el PC
        BRA FETCH

        
EEXIT:
        SIMHALT

ELOIP:
        JSR REGISTRO_B                  ;obtención de la posición de memoria del
                                        ;registro b
        MOVEA.L A2,A4
        JSR REGISTRO_C                  ;obtención de la posición de memoria del
                                        ;registro c
        MOVE.W (A4),A5
        ADDA.W A5,A5
        MOVE.W EMEM(A5),(A3)            ;mover el contenido de una posicción de
                                        ;memoria a la que apunta el contenido de
                                        ;un registro a un registro
        ADDQ.W #1,(A2)
        MOVE.W (A3),D6
        MOVE.W ESR,D7
        JSR ZN_FLAG                     ;actualización de flags
        BRA FETCH
        
ELOA:
        JSR REGISTRO_B                  ;obtención de la posición de memoria del
                                        ;registro b
        JSR FETCH_M                     ;obtención de la posición de memoria
        MULU.W #2,D2
        MOVE.W D2,A4
        MOVE.W EMEM(A4),(A2)            ;mover el valor de una posicón de 
                                        ;memoria a un registro
        MOVE.W (A3),D6
        MOVE.W ESR,D7
        JSR ZN_FLAG
        BRA FETCH

ESTIP:
        JSR REGISTRO_C                  ;obtención de la posición de memoria del
                                        ;registro c
        MOVEA.W (A3),A4
        JSR REGISTRO_B                  ;obtención de la posición de memoria del
                                        ;registro b
        MOVE.W (A2),D5
        MULS.W #2,D5
        LEA EMEM, A5
        ADD.W D5,A5
        MOVE.W A4,(A5)                  ;mover el valor de un registro a la 
                                        ;posición de memoria a la que apunta otro registro
        ADD.W #1,(A2)
        BRA FETCH

ESTO:  
        JSR FETCH_M                     ;obtención de la posición de memoria
        MULU.W #2,D2
        CLR.W (A4)
        MOVE.W D2,A4
        JSR REGISTRO_C                  ;obtención de la posición de memoria del
                                        ;registro c
        CLR.W D4
        MOVE.W (A3),D4
        MOVE.W D4,EMEM(A4)              ;mover el valor de un registro a una
                                        ;posición de memoria
        BRA FETCH
    ;--- FEXEC: FIN EJECUCION
    
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

	        ; ESCRIBID VUESTRO CODIGO AQUI
	        REGISTRO_A:                 ;obtención de la posición de memoria del
                                        ;registro a
            CLR D2
            MOVE.W EIR,D2     
            BTST #10,D2
            BNE RA4
            BTST #9,D2
            BNE RA2
            BTST #8,D2
            BNE RA1
            LEA.L ET0,A1                ;T0
            BRA FIN_A
RA1:        
            LEA.L ET1,A1                ;T1
            BRA FIN_A
RA2:
            BTST #8,D2
            BNE RA3
            LEA.L EX2,A1                ;X2
            BRA FIN_A
RA3:
            LEA.L EX3,A1                ;X3 
            BRA FIN_A      
RA4:
            BTST #9,D2
            BNE RA6
            BTST #8,D2
            BNE RA5
            LEA.L EX4,A1                ;X4
            BRA FIN_A
RA5:
            LEA.L EX5,A1                ;X5
            BRA FIN_A
RA6:
            BTST #8,D2
            BNE RA7
            LEA.L EX6,A1                ;X6
            BRA FIN_A
RA7:
            LEA.L EX7,A1                ;X7
            BRA FIN_A
FIN_A:
            RTS

REGISTRO_B:                             ;obtención de la posición de memoria del
                                        ;registro b
            CLR D2
            MOVE.W EIR,D2
            BTST #6,D2
            BNE RB4
            BTST #5,D2
            BNE RB2
            BTST #4,D2
            BNE RB1
            LEA.L ET0,A2                ;T0
            BRA FIN_B
RB1:        
            LEA.L ET1,A2                ;T1
            BRA FIN_B
RB2:
            BTST #4,D2
            BNE RB3
            LEA.L EX2,A2                ;X2
            BRA FIN_B
RB3:
            LEA.L EX3,A2                ;X3 
            BRA FIN_B      
RB4:
            BTST #5,D2
            BNE RB6
            BTST #4,D2
            BNE RB5
            LEA.L EX4,A2                ;X4
            BRA FIN_B
RB5:
            LEA.L EX5,A2                ;X5
            BRA FIN_B
RB6:
            BTST #4,D2
            BNE RB7
            LEA.L EX6,A2                ;X6
            BRA FIN_B
RB7:
            LEA.L EX7,A2                ;X7
            BRA FIN_B
FIN_B:
            RTS

REGISTRO_C:                             ;obtención de la posición de memoria del
                                        ;registro c
            CLR D2
            MOVE.W EIR,D2      
            BTST #2,D2                  
            BNE RC4
            BTST #1,D2                  
            BNE RC2
            BTST #0,D2                  
            BNE RC1
            LEA.L ET0,A3                ;T0
            BRA FIN_C
RC1:        
            LEA.L ET1,A3                ;T1
            BRA FIN_C
RC2:
            BTST #0,D2                  
            BNE RC3
            LEA.L EX2,A3                ;X2
            BRA FIN_C
RC3:
            LEA.L EX3,A3                ;X3 
            BRA FIN_C      
RC4:
            BTST #1,D2
            BNE RC6
            BTST #0,D2
            BNE RC5
            LEA.L EX4,A3                ;X4
            BRA FIN_C
RC5:
            LEA.L EX5,A3                ;X5
            BRA FIN_C
RC6:
            BTST #0,D2
            BNE RC7
            LEA.L EX6,A3                ;X6
            BRA FIN_C
RC7:
            LEA.L EX7,A3                ;X7
            BRA FIN_C
FIN_C:
            RTS
        
FETCH_M:                                ;obteción de la posición de memoria
            CLR.L D2
            MOVE.W EIR,D2               ;mover la instrucción para sacar el
                                        ;valor de m
            AND.W #$07F8,D2             ;mascara para obtener el valor de m
            LSR.W #3,D2                 ;desplazamiento para poner el valor de m
                                        ;en el extremo
            RTS

FETCH_K:                                ;obtención del número
            CLR.L D2
            MOVE.W EIR,D2               ;mover la instrucción para sacar el 
                                        ;valor de k
            AND.W #$07F8,D2             ;mascara para obtener el valor de k
            LSR.W #3,D2                 ;desplazamiento para poner el valor de k
                                        ;en el extremo
            MOVE.B D2,D4
            RTS        
;ACTUALIZACIÓN DE FLAGS
C_FLAG:                                 ;actualización flags según registro
            BTST #1,D6
            BNE C_SET1
            BCLR #1,D7
            BRA FIN_FLAGC
C_SET1:
            BSET #1,D7
FIN_FLAGC:
            JSR ZN_FLAG
            RTS
ZN_FLAG:
            BTST #15,D6
            BNE NEGATIVO
            BTST #14,D6
            BNE POSITIVO
            BTST #13,D6
            BNE POSITIVO
            BTST #12,D6
            BNE POSITIVO
            BTST #11,D6
            BNE POSITIVO
            BTST #10,D6
            BNE POSITIVO
            BTST #9,D6
            BNE POSITIVO
            BTST #8,D6
            BNE POSITIVO
            BTST #7,D6
            BNE POSITIVO
            BTST #6,D6
            BNE POSITIVO
            BTST #5,D6
            BNE POSITIVO
            BTST #4,D6
            BNE POSITIVO
            BTST #3,D6
            BNE POSITIVO
            BTST #2,D6
            BNE POSITIVO
            BTST #1,D6
            BNE POSITIVO
            BTST #0,D6
            BNE POSITIVO
            BSET #2,D7
            BRA FIN_ZN_FLAG
POSITIVO:            
            BCLR #0,D7
            BCLR #2,D7
            BRA FIN_ZN_FLAG            
NEGATIVO:
            BCLR #2,D7
            BSET #0,D7 
FIN_ZN_FLAG:
            MOVE.W D7,ESR
            RTS

ACT_ESR_C:                              ;actulización flags según operación
    BTST #0,D6
    BNE C_1
    BCLR #1,D7
    BRA FIN_ESR_C
C_1:
    BSET #1,D7 
FIN_ESR_C:
    BRA ACT_ESR_ZN
    RTS
       
ACT_ESR_ZN:
    BTST #2,D6
    BNE Z_1
    BCLR #2,D7
    BRA FN
Z_1:
    BSET #2,D7
FN:
    BTST #3,D6
    BNE N_1
    BCLR #0,D7
    BRA FIN_ESR_ZN
N_1:
    BSET #0,D7
FIN_ESR_ZN:
    MOVE.W D7,ESR
    RTS        
    ;--- FSUBR: FIN SUBRUTINAS

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
            MOVE.W D0,-(SP)
            MOVE.W 6(SP),D0
            BTST #15,D0             ;X     
            BNE ETQ12           
            BTST #14,D0             ;0X
            BNE ETQ8
            BTST #13,D0             ;00X
            BNE ETQ4
            BTST #12,D0             ;000X
            BNE ETQ2
            BTST #11,D0             ;0000X
            BNE ETQ1
            MOVE.W #0,8(SP)
            BRA FINAL                   ;00000
ETQ1:       MOVE.W #1,8(SP)         
            BRA FINAL                   ;00001
ETQ2:       BTST #11,D0             ;0001X
            BNE ETQ3
            MOVE.W #2,8(SP)
            BRA FINAL                   ;00010
ETQ3:       MOVE.W #3,8(SP)
            BRA FINAL                   ;00011     
ETQ4:       BTST #12,D0             ;001X
            BNE ETQ6
            BTST #11,D0             ;0010X
            BNE ETQ5
            MOVE.W #4,8(SP)
            BRA FINAL                   ;00100  
ETQ5:       MOVE.W #5,8(SP)  
            BRA FINAL                   ;00101                    
ETQ6:       BTST #11,D0             ;0011X
            BNE ETQ7
            MOVE.W #6,8(SP)
            BRA FINAL                   ;00110
ETQ7:       MOVE.W #7,8(SP)
            BRA FINAL                   ;00111
ETQ8:       BTST #13,D0             ;01X
            BNE ETQ10
            BTST #12,D0             ;010X
            BNE ETQ9
            MOVE.W #8,8(SP)
            BRA FINAL                   ;0100       
ETQ9:       MOVE.W #9,8(SP)
            BRA FINAL                   ;0101
ETQ10:      BTST #12,D0             ;011X
            BNE ETQ11
            MOVE.W #10,8(SP)
            BRA FINAL                   ;0110
ETQ11:      MOVE.W #11,8(SP)
            BRA FINAL                   ;0111     
ETQ12:      BTST #14,D0             ;1X
            BNE ETQ13
            MOVE.W #12,8(SP)
            BRA FINAL               ;10   
ETQ13:      BTST #13,D0             ;11X
            BNE ETQ15
            BTST #12,D0             ;110X
            BNE ETQ14
            MOVE.W #13,8(SP)
            BRA FINAL                   ;1100                         
ETQ14:      MOVE.W #14,8(SP)
            BRA FINAL                   ;1101           
ETQ15:      BTST #12,D0             ;111X
            BNE ETQ16
            MOVE.W #15,8(SP)
            BRA FINAL                   ;1110                  
ETQ16:      MOVE.W #16,8(SP)
            BRA FINAL                   ;1111            
FINAL:      MOVE.W (SP)+,D0
            RTS

    ;--- FDECOD: FIN DECOD
    END    START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
