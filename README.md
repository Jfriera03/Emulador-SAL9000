# SAL9000 Emulator (Sequentially Programmed Algorithmic Computer)

## Introducción

Este proyecto consiste en implementar un emulador en ensamblador para la máquina elemental SAL9000 (Sequentially Programmed Algorithmic Computer), un modelo simplificado inspirado en arquitecturas básicas de computación.

## Descripción General

La SAL9000 es una máquina elemental con registros específicos y un conjunto de instrucciones sencillo diseñado para realizar operaciones básicas de manera eficiente. La máquina cuenta con los siguientes registros:

- **T0 y T1**: utilizados principalmente para operaciones con la memoria.
- **X2, X3, X4, X5, X6 y X7**: registros generales utilizados principalmente para operaciones aritméticas y lógicas (ALU).

## Conjunto de Instrucciones

La SAL9000 cuenta con un conjunto limitado y específico de instrucciones:

| Mnemonico | Acción                               | Flags actualizados  |
|-----------|--------------------------------------|---------------------|
| COPY      | Copia un registro en otro            | Z, N                |
| ADD       | Suma dos registros                   | C, Z, N             |
| SUB       | Resta dos registros                  | Z, N, C             |
| LSH       | Desplazamiento lógico                | C, Z, N             |
| ADQ       | Añade una constante                  | C, Z, N             |
| SET       | Establece un valor inmediato         | Z, N                |
| OR        | Operación OR lógica                  | Z, N                |
| NOT       | Complemento lógico                   | Z, N                |
| GOZ       | Salto relativo si flag Z está activo | Ninguno             |
| GOC       | Salto relativo si C está activo      | Ninguno             |
| GON       | Salto relativo si N activo           | N/A                 |
| GOI       | Salto relativo incondicional         | Ninguno             |
| EXIT      | Termina la ejecución                 | Ninguno             |
| LOIP      | Carga indirecta con post-incremento  | Z, N                |
| LOA       | Carga directa desde memoria          | Z, N                |
| STIP      | Guarda indirecta con post-incremento | Ninguno             |
| STO       | Guarda directa en memoria            | Ninguno             |

> **Nota**: Las operaciones de resta (`SUB`) se realizan mediante complemento a dos: `A - B = A + (NOT B + 1)`.

## Registros Disponibles

La SAL9000 cuenta con los siguientes registros:

- **Interfaz y ALU**: `T0`, `T1`
- **Propósito General**: `X2`, `X3`, `X4`, `X5`, `X6`, `X7`
- **Registro de Estado** (`ESR`): Almacena flags tras operaciones (`Z`, `C`, `N`).

## Arquitectura del Emulador

El emulador debe seguir la siguiente estructura en ensamblador (68K):

- **FETCH**:
  - Obtiene la siguiente instrucción desde memoria.
  - Incrementa el contador de programa (`EPC`).

- **DECODIFICACIÓN**:
  - Analiza la instrucción cargada (`EIR`).
  - Determina el tipo de instrucción y devuelve un identificador numérico.

- **EJECUCIÓN**:
  - Ejecuta la instrucción específica.
  - Actualiza los registros y flags según la instrucción ejecutada.
  - Retorna al FETCH para continuar con la siguiente instrucción.

## Aspectos Técnicos Clave

- **Uso del stack (pila)**: 
  - Para gestionar llamadas y parámetros en subrutinas (fetch, decode, execute).
  - Respeta la convención de guardar y restaurar registros utilizados en subrutinas.

- **Codificación de Instrucciones**:
  - Emplea direcciones absolutas y constantes numéricas en hexadecimal.
  - Las constantes inmediatas deben ser extendidas correctamente de 8 a 16 bits (complemento a 2).

- **Gestión de Saltos**:
  - Saltos relativos al registro `EPC` (contador de programa).
  - Instrucciones específicas para control de flujo condicional (`GOZ`, `GOC`, etc.).

- **Operaciones Aritméticas**:
  - Las operaciones aritméticas básicas incluyen ADD, SUB (usando complemento), LSH (shift lógico), y OR/NOT para operaciones lógicas.

## Ejemplo de Programa SAL9000
```assembly
; Ejemplo de programa ensamblador para SAL9000
0: LOA 7,X3
1: COPY X3,X2
2: ADD X2,X3,X2
3: EXIT
7: DC.W 1
```

## Estructura del Programa del Emulador
```assembly
ORG $1000
EMEM: DC.W <instrucciones y datos del programa SAL9000>

; Registros emulados
EIR: DC.W 0     ; Registro de instrucción
EPC: DC.W 0     ; Contador de programa
ET0: DC.W 0     ; Registro T0
ET1: DC.W 0     ; Registro T1
EX2: DC.W 0     ; Registro X2
EX3: DC.W 0     ; Registro X3
EX4: DC.W 0     ; Registro X4
EX5: DC.W 0     ; Registro X5
EX6: DC.W 0     ; Registro X6
EX7: DC.W 0     ; Registro X7
ESR: DC.W 0     ; Registro de estado (ZCN)

; Estructura básica del emulador
START:
    CLR.W EPC
FETCH:
    ; Carga y decodifica instrucción
    ; Ejecuta instrucción emulada
    ; Actualiza registros y ESR
```

## Implementación Técnica Adicional
- **Tabla de Saltos Dinámica**: Utiliza una tabla de saltos con registros del 68K para optimizar la selección de ejecución tras la decodificación.
- **Pila del 68K**:
  - Utiliza la pila del procesador para pasar parámetros entre el programa principal y las subrutinas.

## Herramientas y Lenguajes
- Ensamblador para Motorola 68000 (68K)
- Emulador del procesador 68K para ejecutar y verificar programas ensamblados.

---

Este proyecto es una aplicación práctica del manejo y comprensión profunda de ensambladores y arquitectura de computadores elementales.
