org 100h

.data
    namePrompt db "Please enter your name: $"
    nameResult db "Hello, $" 

.code
    mov ax, @data ; mengambil variabel-variabel dari .data
    mov ds, ax ; memasukkan ke ds (data segment) agar bisa terbaca     
    
    main proc
        mov ah, 09h
        mov dx, offset namePrompt
        int 21h        
        
        mov cx, 0 ; siapkan counter
        handleInput:
            mov ax, 0 ; kosongkan ax karena data disimpan di ax
            int 16h ; baca keyboard input
            
            cmp al, 0dh ; apakah user tekan enter?
            je finishInput
            
            push ax
            inc cx ; masukan ke stack dan hitung jumlah karakter
            
            mov dx, ax
            mov ah, 02h
            int 21h ; tampilkan key yang baru diinput
            
            jmp handleInput
        
        finishInput: 
            call newline
            
            mov ah, 09h
            mov dx, offset nameResult
            int 21h
                        
            mov bp, sp
            mov di, cx ; di meyimpan total jumlah karakter
            displayLoop:
                ; untuk mendapatkan huruf huruf yang tersimpan tidak terbalik, gunakan rumus
                ; SP + (cx-1)*2
                
                mov si, bp ; si menyimpan nilai sp
                mov bx, cx ; bx menyimpan nilai counter
                dec bx ; cx - 1
                
                mov ax, 2 ; agar angka pengali menjadi 2
                mul bx ; ax = (cx - 1) * 2
                
                mov bx, ax ; kembalikan lagi nilai ax ke bx
                add si, bx ; SP + (cx - 1) * 2
                
                mov dl, [si] ; masukkan nilai letter pertama ke dl dan output
                mov ah, 02h
                int 21h
                
                mov word ptr [si], 0 ; kosongkan alamat pada stack yang tadinya menyimpan huruf
                
                loop displayLoop ; loop hingga cx nilainya 0
                
            mov bx, di ; ambil jumlah total karakter
            mov ax, 2
            mul bx ; ax = jumlah total karakter * 2
            mov sp, ax ; kembalikan stack pointer ke tempat semula
            
            mov ah, 02h
            mov dl, '!'
            int 21h
        
    main endp
    
    newline proc
        mov ah, 02h
        
        mov dl, 0ah
        int 21h
        mov dl, 0dh
        int 21h
        
        ret
    newline endp

ret