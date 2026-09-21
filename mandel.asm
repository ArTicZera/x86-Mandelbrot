; Coded by ArTic/JhoPro
;
; Mandelbrot Set in 256 colors VGA Mode 13h

[BITS    16]
[ORG 0x7C00]

%define WSCREEN 320
%define HSCREEN 200

BootMain:
        mov     ax, 13h
        int     10h

        push    0A000h
        pop     es

        xor     di, di
        xor     bp, bp

        ; InitY = -1.64
        ; Scale = 256
        ; curY  =  InitY * Scale
        ; curY  = -1.64 * 256 ≈ -420
        mov     dword [curY], -420

RenderY:
        ; InitX = -2.5
        ; curX = -2.5 * 256 = -640
        mov     dword [curX], -640

        mov     cx, WSCREEN

RenderX:
        ; Init Z complex number = 0
        xor     eax,  eax
        mov     [zx], eax
        mov     [zy], eax

        mov     byte [iterations], 50

Mandelbrot:
        ; zx squared -> x2
        mov     eax,      [zx]
        imul    eax,      eax
        sar     eax,      8
        mov     [x2],     eax

        ; zy squared -> y2
        mov     eax,      [zy]
        imul    eax,      eax
        sar     eax,      8
        mov     [y2],     eax

        ; 4 * scale = 1024
        ; mod(z) squared >= 4 ?
        mov     eax,      [x2]
        add     eax,      [y2]

        cmp     eax,      1024
        jae     PixelOK

        ; newX = x squared - y squared + curX
        mov     eax,      [x2]
        sub     eax,      [y2]
        add     eax,      [curX]
        mov     [newX],   eax

        ; newY = 2 * x * y + curY
        mov     eax,      [zx]
        imul    eax,      [zy]
        shl     eax,      1
        sar     eax,      8
        add     eax,      [curY]
        mov     [newY],   eax

        ; Update Z
        mov     eax,      [newX]
        mov     [zx],     eax

        mov     eax,      [newY]
        mov     [zy],     eax

        ; Next iteration
        dec     byte      [iterations]
        jnz     Mandelbrot

PixelOK:
        ; Select colors
        xor     eax,      eax
        mov     al,       [iterations]

        stosb

        ; new curX = 0.012 * 256 = 3
        add     dword     [curX], 3

        ;Go to upper pixel line
        dec     cx
        jnz     RenderX

        ; new curY = 0.0164 * 256 = 3
        add     dword     [curY],4

        ;Next pixel to draw
        inc     bp
        cmp     bp,       200
        jb      RenderY

        jmp $

curX       dd 0
curY       dd 0

zx         dd 0
zy         dd 0

x2         dd 0
y2         dd 0

newX       dd 0
newY       dd 0

iterations db 0

times 510 - ($ - $$) db 0
dw 0xAA55