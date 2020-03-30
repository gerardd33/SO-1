%define l_var bl
%define r_var cl

SYS_EXIT equ 60
SYS_WRITE equ 1
SYS_READ equ 0
STDIN equ 0
STDOUT equ 1
NL equ 10 ; newline

ALPHABET_SIZE equ 42
ASCII_SIZE equ 256
BUFF_SIZE equ 4096

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

; %1 modulo %2, the result in rax
%macro modulo 2
	mov rax, %1
	xor rdx, rdx
	mov rcx, %2
	div rcx
	mov rax, rdx
%endmacro

; ??? CZY TO W OGOLE DZIALA
; %1 modulo %2, the result in rax
%macro moduloByte 2
	mov al, %1
	xor dl, dl
	mov cl, %2
	div cl
	mov al, dl
%endmacro

%macro validateChar 1
	; if (c < '1' || c > 'Z') exit(1)
	mov al, %1
	cmp al, 49 
	jb exit_failed
	
	cmp al, 90 
	ja exit_failed
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
	validateChar byte [r8]
	
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

%macro validateKey 0
	validateChar l_var
	validateChar r_var
	sub l_var, 49
	sub r_var, 49
%endmacro

%macro validateT 0
	; check if T == T^-1
	;mov r8, 0 ; index in the array(s)
	; ...
	; TODO
	
	
	mov r8, 0
%%loopT2:
	cmp [prmT + r8], r8
	je exit_failed
	inc r8
	jmp %%loopT2
	
%endmacro
	
%macro moveRotors 0
	inc r_var
	moduloByte r_var, ALPHABET_SIZE
	mov r_var, al
	
	; TODO: JAK TO ZROBIC ?????
	; ...
	
	;cmp r_var 76 - 49 ; 'L' - '1'
	;je ; ...
	;cmp r_var 82 - 49 ; 'R' - '1'
	;cmp r_var 84 - 49 ; 'T' - '1'
	
	
	; ...
	
	
	
%endmacro

%macro readBlocToBuffer 0
	mov rax, SYS_READ
	mov rdi, STDIN
	mov rsi, buff 
	mov rdx, BUFF_SIZE 
	syscall
%endmacro

%macro writeBlocFromBuffer 0
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, buff 
	mov rdx, [bytesRead]
	syscall
%endmacro


%macro processInput 0
%%blocLoop:
	readBlocToBuffer
	; check how many bytes have been read 
	; - if we should continue reading
	mov [bytesRead], rax
	cmp rax, 0 
	je %%allProcessed
	
%%elementLoop:
	; a pointer at the currently processed element 
	; (to be enciphered) - cur
	mov r8, buff
	cmp byte [r8], 0
	je %%endElementLoop
	
	validateChar byte [r8]
	mov al, 49
	sub [r8], al ; *cur -= '1'
	
	moveRotors
	
	; encipherment of the element
	add [r8], r_var ; *cur += r, Qr
	mov r10, [r8]
	mov al, byte [prmR + r10]
	mov [r8], al ; * cur = L[*cur], L
	sub [r8], r_var ; * cur -= l, Ql^-1
	
	add [r8], l_var ; *cur += r, Qr
	mov r10, [r8]
	mov al, byte [prmL + r10]
	mov [r8], al ; * cur = L[*cur], L
	sub [r8], l_var ; * cur -= l, Ql^-1
	
	mov r10, [r8]
	mov al, byte [prmT + r10]
	mov [r8], al ; * cur = T[*cur], T
	
	add [r8], l_var ; *cur += l, Ql
	mov r10, [r8]
	mov al, byte [invL + r10]
	mov [r8], al ; * cur = L^-1[*cur], L^-1
	sub [r8], l_var ; * cur -= l, Ql^-1
	
	add [r8], r_var ; *cur += r, Qr
	mov r10, [r8]
	mov al, byte [invR + r10]
	mov [r8], al; * cur = R^-1[*cur], R^-1
	sub [r8], r_var ; * cur -= r, Qr^-1
	
	moduloByte [r8], ALPHABET_SIZE
	mov [r8], al; JAKOS INACZEJ ? ZA DUZO BAJTOW
	; CZY NA PEWNO SIE ZMIENIA W BUFF
	mov al, 49
	add [r8], al; convert to ascii again to write the element
	inc r8
	jmp %%elementLoop
	
%%endElementLoop:
	writeBlocFromBuffer
	jmp %%blocLoop
	
%%allProcessed:
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
	buff resb BUFF_SIZE
	bytesRead resb 8 ; to the buffer
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
	getArgs
	getInvAndValidate prmL, invL
	getInvAndValidate prmR, invR
	getInvAndValidate prmT, invT
	
	;validateT
	validateKey
	
	triplicate prmL
	triplicate prmR
	triplicate prmT
	triplicate invL
	triplicate invR
	triplicate invT
	
	processInput

	papiez:
	
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


