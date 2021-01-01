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

proghdr:        dd      1
