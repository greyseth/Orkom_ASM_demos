org 100h

.data
    inputPrompt db "Please enter a number: $" 

.code
    mov ax, @data ; mengambil variabel-variabel dari .data
    mov ds, ax ; memasukkan ke ds (data segment) agar bisa terbaca     
    
    main proc
        mov ah, 09h
        mov dx, offset inputPrompt
        int 21h
        
        call getinput
        push ax
        call newline
        pop ax
        call displaynum        
        
    main endp
    
    newline proc
        mov ah, 02h
        
        mov dl, 0ah
        int 21h
        mov dl, 0dh
        int 21h
        
        ret
    newline endp
    
    getinput proc
        mov cx, 0 ; siapkan counter
        mov bx, 0 ; bx akan menyimpan akumulasi untuk konversi
        handleInput:
            mov ax, 0 ; kosongkan ax karena data disimpan di ax
            int 16h ; baca keyboard input
            
            cmp al, 0dh ; apakah user tekan enter?
            je finishInput
            
            cmp al, 30h
            jl handleInput ; jika inputtan lebih kecil dari ascii 0, maka ulang
            cmp al, 39h
            jg handleInput ; jika inputtan lebih besar dari ascii 9, maka ulang

            inc cx ; masukan ke stack dan hitung jumlah karakter
            
            mov dx, ax
            ;sub dl, 30h
            mov ah, 02h
            int 21h ; tampilkan key yang baru diinput
            
            ; Rumus konversi adalah akumulasi (bx) * 10 + digit angka (dx)
            push dx

            mov ax, bx ; ax = akumulasi
            mov cx, 10
            mul cx ; ax * 10
            mov bx, ax
            
            pop dx
            sub dl, 30h ; konversi inputan ascii menjadi angka real
            mov dh, 0
            add bx, dx ; bx = bx * 10 + angka
            
            jmp handleInput
        
        finishInput:
            ; angka inputtan sudah tersimpan di bx, pindahkah ke ax                                           
            mov ax, bx                      
            ret
    getinput endp
    
    ; mengasumsikan bahwa angka yang mau didisplay disimpan di ax
    displaynum proc
        ;mov ah, 0        
        mov cx, 0 ; reset counter
        
        convertLoop:           
            ; rumus untuk konversi adalah untuk terus membagi 10 dan mengambil nilai remaindernya
            mov bx, 10
            mov dx, 0
            div bx ; hasil pembagian disimpan di ax, dan remainder di dx
            
            mov bx, dx
            push bx ; menyimpan hasil remainder di stack
            
            inc cx
            
            cmp ax, 0
            jg convertLoop
            
        mov ah, 02h
        displayLoop:
            pop dx
            add dl, 30h ; konversikan dari angka biasa menjadi ascii
            int 21h
            
            loop displayLoop
    displaynum endp

ret