org 100h

.data
    inputPrompt db "Please enter your age: $"
    isLegalString db "You are of legal age!$"
    notLegalString db "You are a miner$"

.code
     main proc
        mov ah, 09h
        mov dx, offset inputPrompt
        int 21h
        
        mov bx, 0
        getInput:
            mov ax, 0
            int 16h ; input disimpan di AL
            
            cmp al, 0dh ; 0dh = key enter
            je programFinish
            
            mov ah, 02h
            mov dl, al ; pindahin dari AL ke DL
            int 21h ; display key yang dipencet
            
            mov ax, bx
            mov bx, 10
            push dx
            mul bx ; dx:ax = ax * bx(10)
            pop dx
            sub dl, 30h ; 7 di ascii jadi 7 biasa
            add al, dl
            mov bx, ax
            
            jmp getInput
        
        programFinish:
            call newline
        
            ; angka disimpan di bx
            jge isLegal
            jmp isNotLegal
            
            isLegal:
                mov ah, 09h
                mov dx, offset isLegalString
                int 21h
                jmp closeProgram
            
            isNotLegal:
                mov ah, 09h
                mov dx, offset notLegalString
                int 21h
        
            closeProgram:
                mov ah, 4ch ; end program
                int 21h
     main endp     
     
     newline proc
        ; newline
         mov ah, 02h
         mov dl, 0dh
         int 21h
         mov dl, 0ah
         int 21h
         
         ret
     newline endp
ret




