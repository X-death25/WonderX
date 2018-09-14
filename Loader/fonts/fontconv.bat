set path=D:\Programmation\Wonderswan\binutils

del *.gfx
del *.pal


rem Mono Font (color mode)

bmp2swan m_font1.bmp
bmp2swan m_font2.bmp
bmp2swan m_font3.bmp
bmp2swan m_font4.bmp
bmp2swan m_font5.bmp
bmp2swan m_font6.bmp
ren m_font*.gfx mcfont*.gfx
ren m_font1.pal m_font.tmp
del *.pal
ren m_font.tmp mcfont.pal



rem Mono Font (mono mode)

bmp2swan m_font1.bmp -4col
bmp2swan m_font2.bmp -4col
bmp2swan m_font3.bmp -4col
bmp2swan m_font4.bmp -4col
bmp2swan m_font5.bmp -4col
bmp2swan m_font6.bmp -4col



rem Color Font (color mode)

bmp2swan c_font1.bmp
bmp2swan c_font2.bmp
bmp2swan c_font3.bmp



rem Main Font (mono & color)

bmp2swan font0.bmp
ren font0.gfx c_font0.gfx
ren font0.pal c_font0.pal
bmp2swan font0.bmp -4col
ren font0.gfx m_font0.gfx
