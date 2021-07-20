Assembly program using system calls that implements the following tasks:
1-	Defines and declares a structure Point that has x and y coordinates
2-	Defines an array of 5 structures of Point type
3-	Uses loop 1 to ask a user to input x and y values for the 5 structures using system calls
4-	Uses a loop 2 to print out the x and y values for the array of structure using the system calls

;Point structure
STRUC Point 
        .x: resb 4
        .y: resb 4
        .size:
ENDSTRUC

Section .data 
        msg1: db "Enter a coordinate value for x:",10,0
        msg1Len: equ $-msg1
        msg2: db "Enter a coordinate value for y:",10,0
        msg2Len: equ $-msg2
        msg3: db "Here are the coordinates you entered:",10,0
        msg3Len: equ $-msg3
        msg4: db ",",0
        msg4Len: equ $-msg4

section .bss
        pntArr: resb Point.size*5          ;reserve space for 5 Point structures within array
        arrCnt: equ ($-pntArr)/Point.size  ;store length of array for looping purposes later
        input: resb 4                      ;used to store user input before placing in structure

section .text
global _start 
_start:
        push ebp
        mov ebp, esp

        ;prepare registers for getting user input 
        mov esi, pntArr   ;reference to pntArr 
        mov ecx, arrCnt   ;length of arrCnt used for looping in getInput loop
getUserInput:
        push ecx          ;save arrCnt for later when calling loop instruction

        ;print out msg1
        mov ecx, msg1     ;put message asking for x coordinate    
        mov edx, msg1Len  ;put length of message 
        call printString  ;print message to terminal
        call getInput    ;call function that captures user input from terminal

        ;user input captured currently stored in eax
        mov DWORD[esi + Point.x], eax ;put input into appropriate structure location

        ;print out msg2
        mov ecx, msg2     ;put msg asking for y coordinate
        mov edx, msg2Len  ;put length of msg
        call printString  ;print msg to terminal
        call getInput    ;call function to capture user input from terminal

        ;user input captured currently stored in eax
        mov DWORD[esi + Point.y], eax  ;put  input into appropriate structure location

        pop ecx             ;bring back arrCnt val stored on stack earlier
        add esi, Point.size ;move to next Point structure in pntArr
        loop getUserInput       ;loop until all coordinates (structures) of pntArr are captured 

        ;print msg3 to terminal
        mov ecx, msg3
        mov edx, msg3Len
        call printString  

        ;prepare registers for printing out Points (coordinates) to terminal
        mov esi, pntArr   ;reference to pntArr 
        mov ecx, arrCnt   ;length of pntArr used for looping purposes

top:
        push ecx     ;store length of pntArr for later
        
        mov eax, [esi + Point.x]  ;place x val of current Point being referenced in loop
        call printDec             ;print val to terminal

        ;print msg4 to terminal
        mov ecx, msg4
        mov edx, msg4Len
        call printString

        mov eax, [esi + Point.y] ;place y val of current Point being referenced in loop
        call printDec            ;print val to terminal
        call println             ;print new line to terminal for formatting purposes

        add esi, Point.size ;move to next Point Struc in pntArr   
        pop ecx             ;bring back length of pntArr for looping (counter)
        loop top            ;loop until all Points/Coordinates printed to terminal

        ;exit program
        mov eax, 1
        mov ebx, 0
        int 80h

;;;;;;;;;END OF MAIN;;;;;;;;;

;function to capture user input from terminal 
;function returns captured input in decimal form in eax register
getInput:
        mov eax, 3              ;sys_read call
        mov ebx, 0              ;capture from stdin
        mov ecx, input          ;store user input into input variable
        mov edx, 4              ;read 4 bytes, can be modified to be more if needed
        int 80h                 ;call kernel (invoke sys_read)
        mov BYTE[ecx+eax], 0    ;append a null terminator to input (var where user input stored)
        call cnvrt              ;call function that takes user input and converts to decimal            
        ret

;function to take captured user input and convert to decimal
cnvrt:
        mov edx, input   ;reference input
        xor eax, eax     ;clear any previous vals in eax
top1:
        movzx ecx, byte[edx] ;get char to convert (use of movzx to get byte to properly go into 32 bit register /prevents invalid operand size error)
        cmp ecx, '0'         ;check if char between 0 and 9
        jb end               ;logic for seeing if char between 0 and 9
        cmp ecx, '9'         ;logic for seeing if char between 0 and 9
        ja end               ;logic for seeing if char between 0 and 9
        sub ecx, '0'         ;convert char to num
        imul eax, 10         ;conversion step used when going from char to num
        add eax, ecx         ;place converted num into result (eax)
        inc edx              ;mov to next char to convert
        jmp top1
end:
        ret

printString:
        pusha

        mov eax, 4
        mov ebx, 1 
        int 80h

        popa
        ret

println:
section .data
        nl db 10
section .text
        pusha 

        mov ecx, nl
        mov edx, 1
        call printString

        popa
        ret

printDec:
section .bss
        decstr resb 10 ; creating place to hold 10 digit numbers (32bits) 
        ct1      resd  1  ; used to tell current length of decstring/ keep track
section .text
        pusha   ; saves all the previous register values

        mov dword[ct1], 0  ; zeros out the variable used to keep track of length of decstring
        mov edi, decstr        ; storing the pointer for decstr in edi so it points to it
        add  edi, 9                ; add 9 to the memory address of decstr points/moves to last element
        xor edx, edx             ; clears the register preparing it for its division use later
WhileNotZero:
        mov ebx, 10          ; preparing for division by 10 
        div ebx                  ; perform the division 
        add edx, '0'           ; convert the product of previous division into an ASCII char
        mov byte[edi], dl   ;put the asci char into the string (decstr)
        dec edi                   ;decr 'pointer' to memory address of decstr moving to next element
        inc dword[ct1]       ;increment the counter that keeps track of the new string length
        xor edx, edx           ; clear edx for next iteration of loop/post loop operations
        cmp eax, 0              ; checking to see if division remainder is 0 (loop exit condition)
        jne WhileNotZero   ; jump to top of loop if exit condition not met (remainder != 0 )

        inc edi           ; bring edi with (point to beginning of string)
        mov ecx, edi ; put 'pointer' to the beginning of string in ecx (prep for printing to stdout)
        mov edx, [ct1] ; put the number (length) of chars in string in ecx
        mov eax, 4     ; placing value for sys_write(4) into proper register, prep for kernel call
        mov ebx, 1     ;placing value of stdout(1) into proper register so sys_write prints to screen
        int 0x80          ; call the kernel (registers prepped for printing to screen, sys_write)

        popa  ;restore registers to previous state saved at beginning of function
        ret      ; return




