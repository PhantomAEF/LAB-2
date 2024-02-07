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
// Configuracion
//*****************************************************************************
Setup:
	LDI R17, 0b0000_1111 //definir el PORTB como salidas (para filas de LEDS)
	OUT DDRC, R17

	LDI R17, 0

	CALL IdelayT0
	LDI R18, 0

	LDI R17, 0b1111_1111
	OUT DDRD, R17
	LDI R17, 0b0000_0000
	OUT PORTD, R19
	LDI R19, 0x00
	STS UCSR0B, R19
	OUT PORTD, R19

loop:
	IN R16, TIFR0
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
	CLR R17

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