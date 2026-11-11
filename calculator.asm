    org 100h
    
    .data
        ; MAIN MENU
        msg db "ULTRA CALCULATOR 3000",0dh,0ah, "1. Add", 0dh, 0ah, "2. Subtract", 0dh, 0ah, "3. Multiply", 0ah, 0dh, "4. Division$"     
        invalidMsg db "Invalid option selected$"                                                        
        
        ; ADDITION
        addWelcome db "Enter numbers to add:$", 0dh, 0ah
        addOperator db " + $"
        
        ; SUBTRACTION
        subWelcome db "Enter numbers to subtract:$", 0dh, 0ah
        subOperator db " - $"
        subIsNegative db " (negative)$"
                                                                                                            
        ; MULTIPLICATION
        multWelcome db "Enter numbers to multiply:$", 0dh, 0ah
        multOperator db " * $"
        
        ; DIVISION
        divWelcome db "Enter numbers to divide:$", 0dh, 0ah
        divOperator db " / $"
        divRemainder db "(remainder$"
        
        ; MISC
        inputCount dw 0
        
    .code   
        jmp main ; jumps right into main function
    
        newline proc
            mov ah, 02h ; 02h is the command to write something
            
            mov dl, 0dh ; 0dh puts the cursor to the back
            int 21h
            
            mov dl, 0ah ; 0ah creates a new line                                  
            int 21h 
            
            ret
        newline endp
        
        getinput proc
            mov ax, 0 ; empties ax
            int 16h ; reads input from user
            
            cmp al, 0x08
            je backspace
            
            cmp al, 0dh ; 0dh is enter key
            je inputfinish
            
            cmp al, 30h ; 30h is number 0
            jl getinput
            cmp al, 39h ; 39 is number 9
            jg getinput
            
            mov ah, 02h
            mov dl, al
            int 21h
            
            push dx     
            inc cx
            
            jmp getinput
            
            backspace:            
                ; Check if there are characters to delete
                cmp cx, 0
                je getinput
            
                ; Remove the last character from the stack
                pop dx
                dec cx
            
                ; Move cursor backward
                mov ah, 02h
                mov dl, 08h
                int 21h
            
                ; Replace character with a space
                mov dl, 20h
                int 21h
            
                ; Move cursor backward again
                mov dl, 08h
                int 21h
            
                jmp getinput
            
            inputfinish:            
                mov bp, sp ; memory address where last digit was saved
                mov inputCount, cx
                mov di, 0 ; empties di to be used for calculation
                
                convertLoop:
                    ;mov bx, cx
                    ;sub bx, 30h
                    ;mov ah, 02h
                    ;mov dx, bx
                    ;int 21h
                
                    cmp cx, 0
                    je endConvertLoop
                    
                    ; formula is SP + (count-1)*2
                    mov si, bp
                    mov bx, cx
                    dec bx
                    mov ax, 2
                    mul bx
                    mov bx, ax
                    add si, bx
                    
                    ; re-outputting number for debugging
                    ;mov ah, 02h
                    ;mov dl, [si]
                    ;int 21h
                    
                    ; formula is accumulation (di) * 10 + digit
                    mov bx, [si]
                    sub bx, 30h ; convert bx (last read digit) from ascii to number. bx is now digit
                    mov bh, 0                                                                       
                    push bx ; saves bx (digit) on stack
                    
                    mov ax, di
                    mov bx, 10
                    mul bx
                    mov di, ax ; di * 10
                    
                    pop bx ; restores digit to bx
                    add di, bx ; di * 10 + digit
                    
                    mov word ptr [si], 0 ; clears the stack storing the inputted digit
                    
                    dec cx
                    jmp convertLoop
                    
                 endConvertLoop:
                    mov bx, inputCount
                    shl bx, 1 ; multiplies bx by 2
                    add sp, bx ; moves the stack pointer back to where it last was, passing through all the saved digits
                    
                    ret
        getinput endp
        
        displaynum proc
            push ax
           
            ; writes a fancy equal sign
            mov ah, 02h
            mov dl, 20h ; 20h is space
            int 21h
            mov dl, 3dh ; 3dh is equal sign
            int 21h
            mov dl, 20h
            int 21h
            
            pop ax
            
            ; the formula is keep dividing by 10 and you get the digits from the last
            mov bx, 10                                                               
            mov cx, 0
            
            readDigit:
                mov dx, 0 ; empties dx
                div bx ; divides ax with bx, stores result in ax and remainder in dx
                
                push dx ; stores remainder in stack (the actual number digit)
                inc cx ; finds out how many digits the number is
                
                cmp ax, 0
                jg readDigit
                
            display:                                
                pop dx
                add dl, 30h ; convert digit to ascii by adding 30h
               
                mov ah, 02h
                int 21h ; displays digit
                
                loop display ; loops depending on how much the value of cx is
                
            ret
        displaynum endp
        
        ; operation functions
        addition proc
            mov ah, 09h
            mov dx, offset addWelcome
            int 21h       
            call newline 
            
            mov cx, 0 ; empties cx
            call getinput
            
            push di ; pushes the value of the first number into stack
            
            mov ah, 09h
            mov dx, offset addOperator
            int 21h
            
            mov cx, 0
            call getinput
            
            push di ; pushes the value of the second number into stack
            
            ; calculation
            pop bx ; second number
            pop ax ; first number
            add ax, bx ; addition result
            
            call displaynum
            
            call newline
            call newline
            
            ret
         addition endp
        
        subtraction proc
            mov ah, 09h
            mov dx, offset subWelcome
            int 21h       
            call newline 
            
            mov cx, 0 ; empties cx
            call getinput
            
            push di ; pushes the value of the first number into stack
            
            mov ah, 09h
            mov dx, offset subOperator
            int 21h
            
            mov cx, 0
            call getinput
            
            push di ; pushes the value of the second number into stack
            
            ; calculation
            pop bx ; second number
            pop ax ; first number
            
            cmp bx, ax
            jg subNegative
            
            sub ax, bx ; subtraction result
            
            call displaynum
            
            call newline
            call newline
            
            ret
            
            subNegative:
                sub bx, ax
                mov ax, bx
                call displaynum
                
                mov ah, 09h
                mov dx, offset subIsNegative
                int 21h
                
                call newline
                call newline
                ret
                
         subtraction endp
        
        multiplication proc
            mov ah, 09h
            mov dx, offset multWelcome
            int 21h       
            call newline 
            
            mov cx, 0 ; empties cx
            call getinput
            
            push di ; pushes the value of the first number into stack
            
            mov ah, 09h
            mov dx, offset multOperator
            int 21h
            
            mov cx, 0
            call getinput
            
            push di ; pushes the value of the second number into stack
            
            ; calculation
            pop bx ; second number
            pop ax ; first number
            mul bx ; multiplication result
            
            call displaynum
            
            call newline
            call newline
            
            ret
         multiplication endp
        
        division proc
            mov ah, 09h
            mov dx, offset divWelcome
            int 21h       
            call newline 
            
            mov cx, 0 ; empties cx
            call getinput
            
            push di ; pushes the value of the first number into stack
            
            mov ah, 09h
            mov dx, offset divOperator
            int 21h
            
            mov cx, 0
            call getinput
            
            push di ; pushes the value of the second number into stack
            
            ; calculation
            pop bx ; second number
            pop ax ; first number
    
            mov dx, 0
            div bx ; ax = quotient, dx = remainder
    
            mov bx, dx
            push bx
            call displaynum
            pop bx          
    
            ; display remainder
            cmp bx, 0
            jnz writeremainder
    
            call newline
            call newline
    
            ret
    
            writeremainder:
                call newline
                
                push bx
    
                mov ah, 09h
                mov dx, offset divRemainder
                int 21h
    
                pop bx
    
                mov ax, bx
                call displaynum
    
                mov dl, 29h
                int 21h
    
                call newline
                call newline
    
                ret
         division endp
        
        ; main function
        main:    
            mov ax, @data
            mov ds, ax
        
            ; writes menu
            mov ah, 09h  ; (09h is the command to write a whole string)
            mov dx, offset msg ; (offset takes the memory address of the variable)
            int 21h ; (21h performs the action command store in ah)             
            
            call newline
            
            ; asks for user input 
            mov ah, 0
            int 16h ; (16h is getting input, placed in al)
            
            cmp al, 31h ; compare input value (placed in al) with '31h' which is 1 in ascii code
            je additioncall ; move to the addition function if true (je = jump if equal)
            
            cmp al, 32h
            je subtractioncall
            
            cmp al, 33h
            je multiplicationcall
            
            cmp al, 34h
            je divisioncall 
            
            ; Invalid option message
            mov ah, 09h
            mov dx, offset invalidMsg 
            int 21h    
            
            call newline
            call main
            
            additioncall:
                call addition
                call main
            subtractioncall:
                call subtraction
                call main
            multiplicationcall:
                call multiplication
                call main
            divisioncall:
                call division
                call main
            
            call main
            
        mov ah, 4ch
        int 21h
        
        ret