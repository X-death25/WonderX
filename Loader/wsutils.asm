;-----------------------------------------------------
;- Wonderswan Linker - by Orion_ & Zerosquare [2008] -
;-----------------------------------------------------
;
; Utils
;

;***************************************************
;Print a text in Specified TileMap with X and Y Pos
;***************************************************

TextPrint:	; si = text, di = swan map, ax = X,Y tile pos
	xor	bh,bh	; Y
	mov	bl,al
	shl	bx,5	; *32
	mov	al,ah	; X
	xor	ah,ah
	add	bx,ax	; +X
	add	bx,bx	; word
	add	di,bx	; +map

.loop:	
	xor	ah,ah
	lodsb		; get char
	or	al,al
	jz	.endo	; null terminated string
	sub	al,' '
	stosw		; store char tile
	jmp	.loop

.endo:	popa
	ret
	

;******************************************
;Copy Specified Font number to RAM area
;******************************************

CopyFont:	; al = Font Number, ah = Palette Number, dx = Destination Address in Ram

	pusha
	push	ds
	push	es

	push	MYSEGMENT
	pop	ds

	push	ax
	mov	si,p_font	; font pointer table
	xor	ah,ah
	shl	ax,3		; point to the correct font info
	add	si,ax
	pop	ax

	mov	bx,[ds:si+4]	; get font palette
	or	bx,bx
	jz	.nopalette

	push	si
	mov	si,bx		; palette pointer

	push	ax		; Color font
	mov	al,ah
	xor	ah,ah
	shl	ax,5
	mov	di,WSC_PALETTES
	add	di,ax		; Palette to Copy to
	pop	ax

	xor	bx,bx		; Copy in Ram
	mov	es,bx

	mov	cx,16
	rep	movsw		; Copy Palette

	pop	si

.nopalette:

	mov	cx,[ds:si+2]	; get font size
	shr	cx,1		; word copy
	mov	si,[ds:si]	; get font pointer
	mov	di,dx		; ram destination
	rep	movsw

	pop	es
	pop	ds
	popa
	ret


;******************************************

;-------
; Datas
;-------

	align	2

p_font:		; gfx ptr, size, pal ptr, dummy padding align

	dw	m_font0, m_font1 - m_font0, 0, 0

	dw	m_font1, m_font2 - m_font1, 0, 0
	dw	m_font2, m_font3 - m_font2, 0, 0
	dw	m_font3, m_font4 - m_font3, 0, 0
	dw	m_font4, m_font5 - m_font4, 0, 0
	dw	m_font5, m_font6 - m_font5, 0, 0
	dw	m_font6, mcfont1 - m_font6, 0, 0

	dw	mcfont1, mcfont2 - mcfont1, mc_font_pal, 0
	dw	mcfont2, mcfont3 - mcfont2, mc_font_pal, 0
	dw	mcfont3, mcfont4 - mcfont3, mc_font_pal, 0
	dw	mcfont4, mcfont5 - mcfont4, mc_font_pal, 0
	dw	mcfont5, mcfont6 - mcfont5, mc_font_pal, 0
	dw	mcfont6, c_font0 - mcfont6, mc_font_pal, 0

	dw	c_font0, c_font1 - c_font0, c_font0_pal, 0

	dw	c_font1, c_font2 - c_font1, c_font1_pal, 0
	dw	c_font2, c_font3 - c_font2, c_font2_pal, 0
	dw	c_font3, c_font4 - c_font3, c_font3_pal, 0


m_font0:	incbin	"fonts\m_font0.gfx"

m_font1:	incbin	"fonts\m_font1.gfx"
m_font2:	incbin	"fonts\m_font2.gfx"
m_font3:	incbin	"fonts\m_font3.gfx"
m_font4:	incbin	"fonts\m_font4.gfx"
m_font5:	incbin	"fonts\m_font5.gfx"
m_font6:	incbin	"fonts\m_font6.gfx"

mcfont1:	incbin	"fonts\mcfont1.gfx"
mcfont2:	incbin	"fonts\mcfont2.gfx"
mcfont3:	incbin	"fonts\mcfont3.gfx"
mcfont4:	incbin	"fonts\mcfont4.gfx"
mcfont5:	incbin	"fonts\mcfont5.gfx"
mcfont6:	incbin	"fonts\mcfont6.gfx"

c_font0:	incbin	"fonts\c_font0.gfx"

c_font1:	incbin	"fonts\c_font1.gfx"
c_font2:	incbin	"fonts\c_font2.gfx"
c_font3:	incbin	"fonts\c_font3.gfx"
c_font4:

mc_font_pal:	incbin	"fonts\mcfont.pal"
c_font0_pal:	incbin	"fonts\c_font0.pal"
c_font1_pal:	incbin	"fonts\c_font1.pal"
c_font2_pal:	incbin	"fonts\c_font2.pal"
c_font3_pal:	incbin	"fonts\c_font3.pal"
