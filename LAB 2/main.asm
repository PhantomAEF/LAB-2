//*****************************************************************
// Universidad del Valle de Guatemala
// IE2023: Programacion de microcontroladores
// Proyecto: Lab 2
// Created: 07/2/2024 14:56
// Author : alane
//*****************************************************************************
// Encabezado
//*****************************************************************************
.INCLUDE "M328PDEF.inc"
.CSEG //Inicio del código
.ORG 0x00 //Vector RESET, dirección incial
//*****************************************************************************
// Stack Pointer
//*****************************************************************************
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17
//*****************************************************************************
// Tabla de Valores
//*****************************************************************************
	TABLA7SEG: .DB 0x40, 0x79, 0x24, 0x30, 0x19, 0x12, 0x02, 0x78,  0x00, 0x10, 0x08, 0x03, 0x46, 0x21, 0x06, 0x0E
//*****************************************************************************
// Configuracion
//*****************************************************************************
Setup:

	LDI R20, 0
	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	LPM R20, Z
	LDI R21, 0x01

	LDI R17, 0b0000_1111 
	OUT DDRC, R17

	LDI R17, 0

	LDI R17, 0b0000_0000
	OUT DDRB, R17
	LDI R17, 0b0000_0011
	OUT PORTB, R17
	//CALL IdelayT0
	LDI R18, 0
	//*******************************************************
	//Apagar tx y rx
	//*******************************************************
	LDI R17, 0b1111_1111 
	OUT DDRD, R17        
	LDI R17, 0b0000_0000 
	OUT PORTD, R17
	LDI R19, 0x00
	STS UCSR0B, R19
	OUT PORTD, R19

	LDI R19, 0xFF
	OUT PORTD, R19
	//*******************************************************
loop:
	/*IN R16, TIFR0
	CPI R16, (1 << TOV0)
	BRNE loop
	
	LDI R16, 200
	OUT TCNT0, R16
	
	SBI TIFR0, TOV0

	INC R18
	CPI R18, 25
	BRNE loop
	CLR R18

	INC R17
	OUT PORTC, R17
	CPI R17, 16
	BRNE loop
	CLR R17 */

PrimerBoton: //Lectura del primer boton
    IN R16, PINB
	SBRS R16, PB0
	CALL Pres1
//******************************************
SegundoBoton: //Lectura del segundo boton
	IN R16, PINB
	SBRS R16, PB1
	CALL Pres2
Mostrarvalorinicial:
	LPM R18, Z
	OUT PORTD, R18
	RJMP loop
//*****************************************************************************
// Sub-rutinas
//*****************************************************************************
IdelayT0:

	LDI R16, (1 << CS02) | (1 << CS00)
	OUT TCCR0B, R16

	LDI R16, 100
	OUT TCNT0, R16

	RET

delay: //Funcion delay general
	LDI R16, 100

	delay1:
		DEC R16
		BRNE delay1
	ret

Pres1: //Funcion luego de detectar un boton presionado
	NOP
	CALL delay //Espera el delay para no sumar valores fantasmas
	SBIS PINB, PB0 //Sigue la funcion hasta que el usuario haya soltado el boton
	JMP Pres1 //Si aun no lo suelta regresa al incio del Delay
	RJMP incre //Si ya lo solto podemos sumar el valor ya que estamos seguros de que no es un valor fantasma

Pres2:
	NOP
	CALL delay
	SBIS PINB, PB1
	JMP Pres2
	RJMP decre

incre:
    INC R19 //Incrementa la cuenta de la primera fila de leds
    SBRC R19, 4 // Limitar el contador a 4 bits
    CALL OVERFLO
	ADD ZL, R21
	RJMP LEDS1
	RJMP loop

decre:
	DEC R19 //Decrementa la cuenta de la primera fila de leds
    SBRC R19, 7 // Limitar el contador a no tener numeros negativos
	CALL OVERFLO2
	SUB ZL, R21
	RJMP LEDS1
	RJMP loop

LEDS1:
	LPM R18, Z
	OUT PORTD, R18
	RJMP loop

OVERFLO:
	CLR R19
	LDI R22, 15
	SUB ZL, R22
	JMP LEDS1
OVERFLO2:
	LDI R19, 15
	LDI R22, 15
	ADD ZL, R22
	JMP LEDS1