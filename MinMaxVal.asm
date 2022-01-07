Assembly program using system calls that implements the following tasks:
1 -	Prints the array's elements
2 -	Prints the maximum value in the array
3 -	Prints the minimum value in the array

section .data
        msg1 db "Array Values",10,0
        msg1Len equ $-msg1
        msg2 db "Max Value",10, 0
        msg2Len equ $-msg2
        msg3 db "Min Value",10,0
        msg3Len equ $-msg3

        arr1 dd 12,16,6,18,10,40,30   
        arr1N equ ($-arr1)/4        ;arr1 length

section .bss
        maxval resd 1 ;var used for comparison to find maxval of array
        minval resd 1 ;var used for comparison to find minval of array

section .text
global _start
_start:
        push ebp
        mov ebp, esp

        ;print msg1 to terminal
        mov ecx, msg1
        mov edx, msg1Len
        call printString

        ;print array vals to screen
        mov ebx, arr1
        mov ecx, arr1N
        call PrintArray

        ;print msg2 to terminal
        mov ecx, msg2
        mov edx, msg2Len
        call printString

        ;find max val of arr1
        mov ebx, arr1     ;place reference to arr1
        mov ecx, arr1N    ;length of arr1 for looping purposes (counter)
        mov edx, [ebx]    ;move first element of array into edx for prepping maxval
        mov [maxval], edx ;move first array element (edx) into maxval initializing it for comparison
        call arrMaxVal    ;call func to find max val of arr1 

        ;print maxval to terminal
        mov eax, [maxval] 
        call printDec
        call println

        ;print msg3 to terminal
        mov ecx, msg3
        mov edx, msg3Len
        call printString

        ;find min val of arr1
        mov ebx, arr1      ;place reference to arr1
        mov ecx, arr1N     ;length of arr1 for looping purposes (counter)
        mov edx, [ebx]     ;move first element of arr1 into edx
        mov [minval], edx  ;move first element of arr1(edx) into minval initializing it for comparison
        call arrMinVal     ;call func to find min val of arr1

        ;print min val to terminal
        mov eax, [minval]
        call printDec
        call println


        ;exit
        mov eax, 1
        mov ebx, 0
        int 80h

;;;;END OF MAIN;;;;

;function for finding maximum value in array
arrMaxVal:
;prepare for function call by moving first val of array into maxval for comparisons
;and placing reference to array into ebx, and its length into ecx for loop counting. 
section .text
        push ebp
        mov ebp, esp

top1:
        mov eax, [ebx]     ;place first val from array into eax for comparison
        cmp eax, [maxval]  ;compare val in ebx to 'current' max val of array
        jnbe grtrthan      ;jump to grtrthan if val in eax greater than current val in maxval
        add ebx, 4         ;move to next element in array
        loop top1          ;loop to compare next val in array
        jmp end            ;exit condition after iterating all elements of array
grtrthan:
        mov [maxval], eax  ;place val from array(eax) into maxval since it is greater than previous maxval
        add ebx, 4         ;move to next element in array
        loop top1          ;loop to compare next val in array
        jmp end            ;exit condition after iterating all elements of array

end:
        mov esp, ebp
        pop ebp 
        ret

;function for finding the minimum value of an array
arrMinVal:
;prepare for function call by moving first val of array into maxval for comparisons
;and placing reference to array into ebx, and its length into ecx for loop counter
section .text
        push ebp
        mov ebp, esp

top2:
        mov eax, [ebx]    ;place first val from array into eax for comparison
        cmp eax, [minval] ;compare val in ebx to 'current' min val of array
        jnae lessthan     ;jump to lessthan if val in eax less than current val in minval
        add ebx, 4        ;move to next element in array
        loop top2         ;loop to compare next val in array
        jmp end1          ;exit condition after iterating all elements of array
lessthan:
        mov [minval], eax ;place val from array(ebx) into minval since it is lessthan previous minval
        add ebx, 4        ;move to next element in array
        loop top2         ;loop to compare next val in array
        jmp end1          ;exit condition after iterating all elements of array

end1:
        mov esp, ebp
        pop ebp 
        ret

printString:
        pusha

        mov eax, 4
        mov ebx, 1 
        int 80h

        popa
        ret

PrintArray:
section .text
        push ebp
        mov ebp, esp

top:
        mov eax, [ebx]
        call printDec
        call println
        add ebx, 4
        loop top  

        mov esp, ebp
        pop ebp
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


