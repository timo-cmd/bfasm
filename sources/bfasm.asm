;; bfasm.asm: Copyright (C) 2019-2021 Timo Sarkar <sartimo10@gmail.com>
;; Licensed under the terms of the Creative Commons License version 1.
;;
;; To build:
;;	nasm -f bin -o bfasm bfasm.asm
;; To use:
;;	bfasm < foo.bf > foo.out
;; To run:
;;      chmod +x ./foo.out && ./foo.out
;;

BITS 32

%define arraysize    30000
%define TEXTSECT     0x45E9B000
%define DATAOFFSET   0x2000
%define DATASECT     (TEXTSECT + DATAOFFSET)

;; The main compiler routine begins here
;; File image generation is beeing done here too

        org          TEXTSECT
