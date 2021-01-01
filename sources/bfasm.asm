;; bfasm.asm: Copyright (C) 2020-2021 Timo Sarkar <sartimo10@gmail.com>
;; Licensed under the terms of the Creative Commons License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o bfasm bfasm.asm
;; To use:
;;	bfasm < foo.bf > foo.out

BITS 32

%define arraysize    30000
%define TEXTSECT     0x45E9B000
%define DATAOFFSET   0x2000
%define DATASECT     (TEXTSECT + DATAOFFSET)

        org          TEXTSECT
