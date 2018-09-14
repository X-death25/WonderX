;-------------------------------------------------------------------------------------------------------------
;
;  WonderX Loader
;  by X-death, 2018
;  This piece of code can communicate with PC for Flashing Homebrew into the Cartridge NOR Flash Memory
;  https://github.com/X-death25/WonderX/tree/master/Loader
;  Based on Orion_ WSExample http://onorisoft.free.fr/ and also use some WSLinker Function by Zerosquare
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
; Common Video Init
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
	
	FONT_MONO	equ	0x0
	FONT_COLOR	equ	0xD
	
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
	
	; Set Bank to MYSEGMENT before made any copy
	mov	ax,MYSEGMENT
	mov	ds,ax
	xor	ax,ax
	mov	es,ax
	
;-----------------------------------------------------------------------------
; Copy WonderSwan Color Font to Tile Bank 1
;-----------------------------------------------------------------------------
		
	xor	ah,ah
	mov	al,FONT_COLOR
	mov	dx,WSC_TILE_BANK1
	call	CopyFont

;-----------------------------------------------------------------------------
; Try to display some text
;-----------------------------------------------------------------------------	
	
	mov	ax,0x0430
	mov	si,txt_hello ; The Text
	mov	di,FG_MAP(fgmap) ; The TileMap
	call   TextPrint

;-----------------------------------------------------------------------------
; Init Completed we can now turn ON Display and call main game loop
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


	iret

;-----------------------------------------------------------------------------
;
; BEGIN main code
;
;-----------------------------------------------------------------------------

main_loop:

jz main_loop

;-----------------------------------------------------------------------------
;
; END main code
;
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Include Extra routines based on WSLinker
;-----------------------------------------------------------------------------

%include "wsutils.asm"		; Utility routines

;-----------------------------------------------------------------------------
; constants area
;-----------------------------------------------------------------------------

	align 2
	
	txt_hello:	db	"Hello",0
	author: db "X-death, 2018"	
	ROM_HEADER	initialize, MYSEGMENT, 0x42, RH_WS_COLOR, RH_ROM_8MBITS, RH_NO_SRAM, RH_HORIZONTAL
	
	SECTION .bss start=0x0100 ; Keep space for Int Vectors
VBLcnt:		resb	0	; Our datas in RAM
