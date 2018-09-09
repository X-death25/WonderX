;-------------------------------------------------------------------------------------------------------------
;
;  WonderX Loader
;  by X-death, 2018
;  This piece of code can communicate with PC for Flashing Homebrew into the Flash Memory
;  https://github.com/X-death25/WonderX/tree/master/Loader
;  Based on Orion_ WSExample http://onorisoft.free.fr/ and use some WSLinker Function writted by Zerosquare
;
;
;------------------------------------------------------------------------------------------------------------

	ORG 0x0000
	CPU 186
	BITS 16
	
SECTION .data
	%include "WonderSwan.inc"

	MYSEGMENT	equ	0xF000
	fgmap		equ	WSC_TILE_BANK1-MAP_SIZE
	bgmap		equ	fgmap-MAP_SIZE
	sprtable	equ	bgmap-SPR_TABLE_SIZE

	
SECTION .text
	;PADDING 15
	
initialize:  ; First we need to correctly initialize console with help of WonderSwan.inc
	cli
	cld
	
;-----------------------------------------------------------------------------
; if it's not the Color version of the console, lock the CPU
;-----------------------------------------------------------------------------

	in al, IO_HARDWARE_TYPE
	test al, WS_COLOR
lock_cpu:
	jz lock_cpu
		
;-----------------------------------------------------------------------------
; Initialize registers and RAM
;-----------------------------------------------------------------------------

	mov ax, MYSEGMENT
	mov ds, ax
	xor ax, ax
	mov es, ax

	; setup stack
	mov bp, ax
	mov ss, ax
	mov sp, WSC_STACK

	; clear Ram
	mov di, 0x0100
	mov cx, 0x7E80
	rep stosw

	out IO_SRAM_BANK,al
	
;-----------------------------------------------------------------------------
; Initialize video
;-----------------------------------------------------------------------------

	in	al,IO_VIDEO_MODE
	or	al,VMODE_16C_CHK | VMODE_CLEANINIT
	out	IO_VIDEO_MODE,al

	xor	ax,ax
	out	IO_BG_X,al
	out	IO_BG_Y,al
	out	IO_FG_X,al
	out	IO_FG_Y,al

	mov	al,BG_MAP(bgmap) | FG_MAP(fgmap)
	out	IO_FGBG_MAP,al

	mov	al,SPR_TABLE(sprtable)
	out	IO_SPR_TABLE,al

	in	al,IO_LCD_CTRL
	or	al,LCD_ON
	out	IO_LCD_CTRL,al

	xor	al,al
	out	IO_LCD_ICONS,al
	
;-----------------------------------------------------------------------------
; Put Loader variables here
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Register Vblank interrupt handler
;-----------------------------------------------------------------------------

	mov	ax,INT_BASE
	out	IO_INT_BASE,al

	mov di, INTVEC_VBLANK_START
	add di, ax
	shl di, 2
	mov word [es:di], vblankInterruptHandler
	mov word [es:di + 2], MYSEGMENT

	; clear HBL & Timer
	xor	ax,ax			
	out	IOw_HBLANK_FREQ,ax
	out	IO_TIMER_CTRL,al

	; acknowledge all interrupts
	dec	al			
	out	IO_INT_ACK,al

	; enable VBL interrupt
	mov	al,INT_VBLANK_START	
	out	IO_INT_ENABLE,al
	
	; we have finished initializing, interrupts can now fire again
	sti	
	
;-----------------------------------------------------------------------------
; copy background and foreground tile data
; into WS's tile and palette areas
;-----------------------------------------------------------------------------
	
;-----------------------------------------------------------------------------
; Init Completed we can now start Display and main game loop
;-----------------------------------------------------------------------------
	
	; Enable Display 
	mov	al,BG_ON | FG_ON
	out	IO_DISPLAY_CTRL,al
	
	; Start main game loop
	jmp main_loop	
	
;-----------------------------------------------------------------------------
; vblank interupt handler
; it is called automatically whenever the vblank interrupt occurs, 
; that is, every time the screen is fully drawn
;-----------------------------------------------------------------------------

vblankInterruptHandler:

;-----------------------------------------------------------------------------
;
; BEGIN main code
;
;-----------------------------------------------------------------------------

main_loop:

jmp main_loop

;-----------------------------------------------------------------------------
;
; END main code
;
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
; constants area
;-----------------------------------------------------------------------------
	align 2
	
	author: db "X-death, 2018"	
	ROM_HEADER	initialize, MYSEGMENT, 0x42, RH_WS_COLOR, RH_ROM_8MBITS, RH_NO_SRAM, RH_HORIZONTAL
	
	SECTION .bss start=0x0100 ; Keep space for Int Vectors
VBLcnt:		resb	0	; Our datas in RAM
