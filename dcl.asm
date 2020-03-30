SYS_EXIT equ 60
SYS_WRITE equ 1
SYS_READ equ 0
STDIN equ 0
STDOUT equ 1
NL equ 10 ; newline

ALPHABET_SIZE equ 42
ASCII_SIZE equ 256

%define l_var bl
%define r_var cl

; DEBUG

%macro printVal 1
    mov rax, %1
%%printRAX:
    mov rcx, digitSpace
;   mov rbx, 10
;   mov [rcx], rbx
;   inc rcx
    mov [digitSpacePos], rcx
 
%%printRAXLoop:
    mov rdx, 0
    mov rbx, 10
    div rbx
    push rax
    add rdx, 48
 
    mov rcx, [digitSpacePos]
    mov [rcx], dl
    inc rcx
    mov [digitSpacePos], rcx
   
    pop rax
    cmp rax, 0
    jne %%printRAXLoop
 
%%printRAXLoop2:
    mov rcx, [digitSpacePos]
 
    mov rax, 1
    mov rdi, 1
    mov rsi, rcx
    mov rdx, 1
    syscall
 
    mov rcx, [digitSpacePos]
    dec rcx
    mov [digitSpacePos], rcx
 
    cmp rcx, digitSpace
    jge %%printRAXLoop2
 
%endmacro

; print a zero-terminated string, without knowing its length
%macro printStringZero 1 
    mov rax, %1
    add rax, 49 ; USUN POTEM
    mov [printSpace], rax
    mov rbx, 0
%%printLoop:
    mov cl, [rax]
    cmp cl, 0
    je %%endPrintLoop
    inc rbx
    inc rax
    jmp %%printLoop
%%endPrintLoop:
    mov rax, SYS_WRITE
    mov rdi, STDIN
    mov rsi, [printSpace]
    mov rdx, rbx
    syscall
%endmacro

; END DEBUG





%macro exit 1
	mov rax, SYS_EXIT
	mov rdi, %1 ; exit code
	syscall
%endmacro

%macro printString 2
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, %1 ; string to be printed
	mov rdx, %2 ; string length
	syscall
%endmacro

; %1 modulo %2
%macro modulo 2
	mov rax, %1
	xor rdx, rdx
	mov rcx, %2
	div rcx
	mov rax, rdx
%endmacro

; take the argument from stack and copy it to %1
%macro getArgFromStack 1
	; TODO: wczytaj troche wiecej zeby sprawdzic czy
	; argument nie jest postaci OKEJ + cos za duzo
	pop rsi
	mov rcx, ALPHABET_SIZE 
	mov rdi, %1
	cld
	rep movsb
%endmacro

%macro getArgs 0
	pop rax ; the top of the stack is argc
	mov [argc], rax 
	; printVal [argc]
 	; printStringZero newline
	
	; check if the number of arguments is correct
	mov rax, 5
	cmp [argc], rax 
	jne exit_failed
	
	pop rax ; get rid of the "path" argument
	getArgFromStack prmL
	getArgFromStack prmR
	getArgFromStack prmT
	
	; copy the first letter from stack to [l]
	pop rax
	mov l_var, byte [rax]
	mov r_var, byte [rax + 1]
%endmacro

%macro triplicate 1
	mov rax, 0
%%triplicate_loop:
	; copy the current element to positions ALPHABET_SIZE and
	; 2 * ALPHABET_SIZE further 
	mov bl, byte [%1 + rax]
	mov [%1 + rax + ALPHABET_SIZE], bl
	mov [%1 + rax + 2 * ALPHABET_SIZE], bl
	inc rax
	cmp rax, ALPHABET_SIZE
	jne %%triplicate_loop
%endmacro

; %1 - array, %2 - place for array^-1
%macro getInvAndValidate 2
	mov r8, %1 ; a pointer to the current element in the permutation (A)
	mov r9b, 0 ; index of the current element (idA)
%%getInvLoop:
	;validateChar [r8]
	
	; *A -= '1'
	mov rax, 49
	sub [r8], rax ; *A -= '1'
	
	; invA[*A] != 0 - a repeating character
	movzx rax, byte [r8]
	
	cmp byte [%2 + rax], 0
	jne exit_failed
	
	movzx rax, byte [r8]
	mov [%2 + rax], r9b ; invA[*A] = idA
	inc r9b ; ++idA
	
	inc r8 ; ++A
	cmp byte [r8], 0
	jne %%getInvLoop
	
	mov al, ALPHABET_SIZE
	cmp r9b, al; idA != ALPHABET_SIZE
	jne exit_failed

%endmacro

section .bss
	; DEBUG
	digitSpace resb 100
    digitSpacePos resb 8
    printSpace resb 8
    ; END DEBUG
	argc resb 8 ; number of arguments 
	; TODO: powieksz ich rozmiary do walidacji
	prmL resb 3 * ALPHABET_SIZE + 1 ; permutation L
	prmR resb 3 * ALPHABET_SIZE + 1; permutation R
	prmT resb 3 * ALPHABET_SIZE + 1; permutation T
	invL resb 3 * ALPHABET_SIZE + 1 ; L^-1
	invR resb 3 * ALPHABET_SIZE + 1; R^-1
	invT resb 3 * ALPHABET_SIZE + 1; T^-1
	tmpStr resb 2
	
    
    
section .data
	; DEBUG
	textArgument db "Argument #",0
	colon db ": ",0
	colonLen equ $ - colon
	newline db 10,0
	
	; END DEBUG

	
	
section .text
	global _start

_start:
	;printStringZero newline
	;printStringZero newline
	getArgs
	
	getInvAndValidate prmL, invL
	printStringZero prmL
	printStringZero newline
	printStringZero invL
	
papiez:
	
	;triplicate prmL
	;triplicate prmR
	;triplicate prmT
	
	;printStringZero prmL
	;printStringZero newline
	;printStringZero prmR
	;printStringZero newline
	;printStringZero prmT
	;printStringZero newline
	exit 0
	
exit_failed:
	exit 1

	
	
; jak testowac 
; movzx rax, bl
; sub rax, 49
; add [prmL + 1], rax
; printStringZero prmL


