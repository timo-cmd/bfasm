BITS 32

%define arraysize    30000
%define TEXTSECT     0x45E9B000
%define DATAOFFSET   0x2000
%define DATASECT     (TEXTSECT + DATAOFFSET)

        org          TEXTSECT
