//*****************************************************************************
// Universidad del Valle de Guatemala
// IE2023: Programación de microcontroladores
// Autor: Manuel Ovalle 
// Proyecto: Contador de 4 bits 
// Hardware: ATMEGA328P
// Creado: 30/01/2024
//*****************************************************************************
// Encabezado
//*****************************************************************************

.include "M328PDEF.inc"
.cseg //Indica inicio del código
.org 0x00 //Indica el RESET

//*****************************************************************************
// Formato Base
//*****************************************************************************
LDI R16, LOW(RAMEND) 
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17
//*****************************************************************************
// MCU
//*****************************************************************************
Setup:

	LDI R16, (1 << CLKPCE)
	STS CLKPR, R16 // Habilitamos el prescalar
	LDI R16, 0b0000_0100
	STS CLKPR, R16 // Frecuencia 1MGHz

	//Seteo de pullups

	LDI R16, 0b0000_0101
	OUT PORTC, R16

	LDI R16, 0b0001_0000
	OUT DDRC, R16	// Entradas y salidas PORTC 

	LDI R16, 0b1111_1111 
	OUT DDRD, R16	// Entradas y salidas PORTD 

	LDI R16, 0b0010_1111
	OUT DDRB, R16	// Entradas y salidas PORTB 

	//CLR de los registros a utilizar
	CLR R16
	CLR R17
	CLR R18
	CLR R19
	CLR R20
	CLR R21
	CLR R22
	CLR R23

//*****************************************************************************
	//					0		1	2		3	4		5	6		7	8	9		A	B		C	D		E	F	
	Tabla_Display: .DB 0x3F, 0x30, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x7, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71

	Inicio:								// Condiciones iniciales
	
	//Set rangos de la tabla
	LDI ZH, HIGH(Tabla_Display << 1)
	LDI ZL, LOW(Tabla_Display << 1)
	LPM R18, Z
	//Outputs display
	SBRS R18, 0
	CBI	PORTD, PD2
	SBRC R18, 0
	SBI PORTD, PD2
	SBRS R18, 1
	CBI	PORTD, PD3
	SBRC R18, 1
	SBI PORTD, PD3
	SBRS R18, 2
	CBI	PORTD, PD4
	SBRC R18, 2
	SBI PORTD, PD4
	SBRS R18, 3
	CBI	PORTD, PD5
	SBRC R18, 3
	SBI PORTD, PD5
	SBRS R18, 4
	CBI	PORTD, PD6
	SBRC R18, 4
	SBI PORTD, PD6
	SBRS R18, 5
	CBI	PORTD, PD7
	SBRC R18, 5
	SBI PORTD, PD7
	SBRS R18, 6
	CBI	PORTC, PC4
	SBRC R18, 6
	SBI PORTC, PC4
	//Contador para alarma 
	DEC R23

//*****************************************************************************	
CALL Timer_0		//Timer

Loop:

	IN R16, PINC

	CALL Delay //Antirrebote
	
	SBRS R16, PC0 //Botón 1
	RJMP Incrementar_Display 

	SBRS R16, PC2 //Botón 2
	RJMP Decrementar_Display 

	//Logica para el timer 
	IN R16, TIFR0
	SBRS R16, TOV0
	RJMP Loop

	LDI R16, 98
	OUT TCNT0, R16
	SBI TIFR0, TOV0

	CPI R16, 0x0F
	BRNE incrementar
	RJMP  reset

	SBRS R16, TOV0

	LDI R16, 98
	OUT TCNT0, R16
	SBI TIFR0, TOV0

	CPI R16, 0b0000_1111
	BRNE incrementar
	RJMP  reset	

	RJMP Loop


//*****************************************************************************
// SubRutinas
//*****************************************************************************
Timer_0:
	OUT TCCR0A, R16 //Modo normal

	LDI R16, (1 << CS02) | (1 << CS00)
	OUT TCCR0B, R16

	LDI R16, 98
	OUT TCNT0, R16
	RET
//*****************************************************************************

incrementar:  //Seteo de ciclos 
	CPI R22, 9
	BREQ incr
	INC R22
	RJMP Loop
incr:
	INC R17
	CLR R22
	RJMP leds

//*****************************************************************************

reset:
	CLR R17
	RJMP leds

//*****************************************************************************

leds: //Timer_0 salidas 
	SBRS R17, 0
	CBI	PORTB, PB0
	SBRC R17, 0
	SBI PORTB, PB0
	SBRS R17, 1
	CBI	PORTB, PB1
	SBRC R17, 1
	SBI PORTB, PB1
	SBRS R17, 2
	CBI	PORTB, PB2
	SBRC R17, 2
	SBI PORTB, PB2
	SBRS R17, 3
	CBI	PORTB, PB3
	SBRC R17, 3
	SBI PORTB, PB3

	Call Alarma  //EVALUAR R17
	RJMP Loop


//*****************************************************************************
//ANTIRREBOTE
Delay:
	LDI R19, 100
Compdelay:
	DEC R19
	BRNE Compdelay 
	RET

//*****************************************************************************

Display:	// Display de 7 segmentos 
	LPM R18, Z

	SBRS R18, 0
	CBI	PORTD, PD2
	SBRC R18, 0
	SBI PORTD, PD2
	SBRS R18, 1
	CBI	PORTD, PD3
	SBRC R18, 1
	SBI PORTD, PD3
	SBRS R18, 2
	CBI	PORTD, PD4
	SBRC R18, 2
	SBI PORTD, PD4
	SBRS R18, 3
	CBI	PORTD, PD5
	SBRC R18, 3
	SBI PORTD, PD5
	SBRS R18, 4
	CBI	PORTD, PD6
	SBRC R18, 4
	SBI PORTD, PD6
	SBRS R18, 5
	CBI	PORTD, PD7
	SBRC R18, 5
	SBI PORTD, PD7
	SBRS R18, 6
	CBI	PORTC, PC4
	SBRC R18, 6
	SBI PORTC, PC4

	CALL alarma //Evaluar R23

	RJMP Loop
//*****************************************************************************
Incrementar_Display: //Aumento del display

	CPI R18, 0x71		//Debug al estar en F
	BREQ Starting_F

	IN R16, PINC
	SBRC r16, PC0  //Seguro anti dejar presionado
	INC ZL
	SBRC r16, PC0  //Seguro anti dejar presionado
	INC R23
	SBRC r16, PC0  //Seguro anti dejar presionado
	RJMP Display 

	RJMP Incrementar_Display

Starting_F: //Debug al estar en F

LDI ZL, LOW(Tabla_Display << 1)
	DEC ZL
	LPM R18, Z
	CLR R23

RJMP Display
//*****************************************************************************

Decrementar_Display: //Decremento del display

	CPI R18, 0x3F
	BREQ Starting_Zero //Debug al estar en 0

	IN R16, PINC
	SBRC r16, PC2    //Seguro anti dejar presionado
	DEC ZL
	SBRC r16, PC2    //Seguro anti dejar presionado
	DEC R23
	SBRC r16, PC2    //Seguro anti dejar presionado
	RJMP Display

	RJMP Decrementar_Display

Starting_Zero:  //Debug al estar en 0

LDI R20, 0x10
	ADD ZL, R20
	ADD R23, R20
RJMP Display
//*****************************************************************************
//Comparacion para la alarma
alarma:
	CP R17, R23
	BREQ alarma2
	RET
alarma2:
	CLR R17
	SBIS PORTB, PB5
	RJMP activar
	RJMP desactivar
activar:  //Encender led 
	SBI PORTB, PB5
	RET
desactivar:  //Apagar led
	CBI PORTB, PB5
	RET	