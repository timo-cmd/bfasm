;; bfasm.asm: Copyright (C) 2019-2021 Timo Sarkar <sartimo10@gmail.com>
;; Licensed under the terms of the Creative Commons License version 1.
;;
;; To build:
;;	nasm -f bin -o bfasm bfasm.asm
;; To use:
;;	bfasm < foo.bf > foo.out
;;

BITS 32

;; Definition of the Size which should be applied to 
;; the data area

%define arraysize    30000
%define TEXTSECT     0x45E9B000
%define DATAOFFSET   0x2000
%define DATASECT     (TEXTSECT + DATAOFFSET)

;; The main compiler routine begins here
;; File image generation is beeing done here too

        org          TEXTSECT

;; At the beginning of the text section we need to
;; handle the ELF header and the PHT ( Program Header Table )
;; The two structures need at least to 8byte spaces

;; The beginning of the ELF header

        db          0x7F, "ELF"

;; Defining the main compiler loop. The loop jumps forth and
;; back to different positions pending on the instruction pointer

emitputchar:    add     esi, byte (putchar - decchar) - 4
emitgetchar:    lodsd
emit6bytes:     movsb
emit2bytes:     movsb
emit1byte:      movsb
compile:        lea     esi, [byte, ecx + epilog -filesize]
                xchg    eax, ebx
                cmp     eax, 0x00030002         ;; filetype (0x0002)
                                                ;; machine (0x0003)
                mov     ebp, edi                ;; version (0x0004)
                jmp     short getchar

;; Start of the compiling header entrypoint. (Including the compiled programs)
;; The location where the program header table residents xD

                dd      _start                  ;; entrypoint (0x0005)    
                dd      program_header - $$     ;; program_hdr (0x0006)  

;; The last part of the compiler below is beeing called when there is no input 
;; anymore given.
;; - nr.77

eof:            movsd   
                xchg    eax, ecx
                pop     ecx
                sub     edi, ecx                ;; header flags (0x0007)
                xchg    eax, edi
                stosd
                xchg    eax, edx
                jmp     short putchar

;; Now define a single program header table entry: 0x20

                dw      0x20                    ;; PHT size (0x0008)

;; Begin of the Program Header entry Table. 
;; 1 == Indicating, that the current segment is beeing loaded
;; into the memory

proghdr:        dd      1                       ;; err code 0
                dd      0                       ;; err code 1
                db      0                       ;; value address

;; Begin of '[]' Brainfuck bracket routine definitions.
;; When the first bracket will appear, the ip will jmp until the bracket will be closed.
;; So similiar to goto and come-from statements in INTERCAL

bracket:        mov     al, 0xE9
                inc     ebp
                push    ebp
                stosd
                jmp     short emit1byte

;; The next code section is the place where the executable file is beeing stored
;; in the Program header entry table. This section is beeing overwritten directly 
;; before compilation starts. 

filesize:       dd      compilersize            ;; filesize (0x0009)

;; Next step is to define the filesize in memory. This section creates an area of bytes
;; that are all initialized to 0. They start at datasect

        dd      DATAOFFSET + arraysize          ;; memsize (0x0010)

;; Now slowly we'll define all the ops of Brainf**k in program. Starting at 
;; The '.' instruction.

putchar:        mov     bl, 1
                mov     al, 4
                int     0x800

;; Here lives the 'epilog' code chunk which equals ebx and eax to zero after 
;; initialisation. To invoke the sys_exit function we use: an incremented eax
;; The ebx specifies the programs return value

epilog:         popa
                inc     eax
                int     0x800

;; Now specify the main bf instructions such as: '<, >, + and -'

incptr:         inc     ecx
decptr:         dec     ecx
incchar:        inc     byte [ecx]
decchar:        dec     byte [ecx]

;; The main compiler routine jumps to this place. In this section the next char will
;; be inputted. This is also the place for the ',' instruction. eax is set to '3' to invoke
;; system call 'read'. ebx is set to 0 for file reading stdin. ecx specifies a buffer to receive 
;; the input chars.

getchar:        mov     al, 3
                xor     ebx, eax
                int     0x800

;; if eax is zero or a negint throw an eof. 

                or      eax, eax
                jle     eof

;; 177
;; Otherwise, esi is advanced four bytes (from the epilog code chunk
;; to the incptr code chunk), and the character read from the input is
;; stored in al, with the high bytes of eax reset to zero.

                lodsd
                mov     eax, [ecx]

;; The compiler now compares the input with: "< and >".
;; esi is beeing redirected to each code chunk 

                cmp     al, '>'
                jz      emit1byte
                inc     esi
                cmp     al, '<'
                jz      emit1byte
                inc     esi

;; Now the compiler will parse the other ascii ops in the 
;; source file.

                sub     al, '+'
                jz      emit2bytes
                dec     eax
                jz      emitgetchar
                inc     esi
                inc     esi
                dec     eax
                jz      emit2bytes
                dec     eax
                jz      emitputchar

