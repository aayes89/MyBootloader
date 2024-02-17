bits 16

boot:
    jmp init_boot
    TIMES 3-($-$$) DB 0x90   ; Support 2 or 3 byte encoded JMPs before BPB.
init_boot:
    ; In real hardware the BIOS puts the address of the booting drive on the dl register
    mov [bootdrv], dl

    ; Setting the stack
    mov ax, 07C0h
    add ax, 288
    mov ss, ax              ; ss = stack space
    mov sp, 4096            ; sp = stack pointer

    mov ax, 07C0h
    mov ds, ax              ; ds = data segment

    ;call init_graphic_mode   ; Initialize graphic mode
    ; In real hardware the BIOS puts the address of the booting drive on the dl register
    mov [bootdrv], dl
    ; Setting the stack
    mov ax, 07C0h
    add ax, 288
    mov ss, ax              ; ss = stack space
    mov sp, 4096            ; sp = stack pointer
    mov ax, 07C0h
    mov ds, ax              ; ds = data segment
    mov ah, 00d             ; Set video mode to graphical
    mov al, 13d             ; 13h - graphical mode, 40x25. 256 colors.;320x200 pixels. 1 page.
    int 10h                 ; Call

    ; Display Banners
    push 1
    push 3
    push 25
    push banner0
    call print_text

    push 1
    push 4
    push 25
    push banner1
    call print_text

    push 1
    push 5
    push 25
    push banner2
    call print_text

    push 1
    push 6
    push 25
    push banner3
    call print_text

    push 1
    push 7
    push 25
    push banner4
    call print_text

    push 1
    push 8
    push 25
    push banner5
    call print_text

    push 1
    push 21
    push 25
    push banner6
    call print_text
    call delayed

    mov dl, [bootdrv]
    
call_menu:
    mov ah, 0x02
    mov al, 1         ; Number of sectors to read
    mov ch, 0         ; Cylinder number
    mov dh, 0         ; Head number
    mov cl, 2         ; Starting sector number. 2 because 1 was already loaded.
    mov bx, start    ; Where the stage 2 code is

    int 0x13

    mov dl, 0x80
    jc call_menu ; If error loading, set dl to 0x80 and try again, this should make it work in qemu

    jmp start

print_text:
    push bp                ; Save old base pointer
    mov bp, sp             ; Use the current stack pointer as new base pointer
    pusha

    mov ax, 7c0h           ; Beginning of the code
    mov es, ax
    mov cx, [bp + 6]       ; Length of string
    mov dh, [bp + 8]       ; Row to put string
    mov dl, [bp + 10]      ; Column to put string
    mov bp, [bp + 4]       
    mov ah, 13h            ; Function 13 - write string
    mov al, 01h            ; Attrib in bl, move cursor
    mov bl, 0Fh            ; Color white
    int 10h
                           ; Restore the stack and return
    popa
    mov sp, bp
    pop bp
    ret 8

delayed:
    mov cx, 0xFFF  ; Establece un valor inicial grande para CX
    mov dx, 0xFFF  ; Establece un valor inicial grande para DX

    delaye_loop:
        dec cx          ; Decrementa CX
        jnz delaye_loop  ; Salta si CX no es cero
        dec dx          ; Decrementa DX
        jnz delaye_loop  ; Salta si DX no es cero
        jmp call_menu

; Variable to store boot drive
bootdrv db 0

    ; Data
banner0: db "   ______     ________   "
banner1: db "  / _   _ \  /   ___  \  "
banner2: db " | |_\ /_| ||   /___\__| "
banner3: db "  \   w   /  _\___    \  "
banner4: db "    wwwww   |  /__\    | "
banner5: db "    wwwww    \________/  "
banner6: db "          Hacked by @Slam", 0

times 510 - ($ - $$) db 0   ; Padding with 0 at the end
dw 0xAA55                   ; PC boot signature

start:
    ; In real hardware the BIOS puts the address of the booting drive on the dl register
    mov [bootdrv], dl

    ; Setting the stack
    mov ax, 07C0h
    add ax, 288
    mov ss, ax              ; ss = stack space
    mov sp, 4096            ; sp = stack pointer

    mov ax, 07C0h
    mov ds, ax              ; ds = data segment

    ;call init_graphic_mode   ; Initialize graphic mode
    ; In real hardware the BIOS puts the address of the booting drive on the dl register
    mov [bootdrv], dl
    ; Setting the stack
    mov ax, 07C0h
    add ax, 288
    mov ss, ax              ; ss = stack space
    mov sp, 4096            ; sp = stack pointer
    mov ax, 07C0h
    mov ds, ax              ; ds = data segment
    mov ah, 00d             ; Set video mode to graphical
    mov al, 13d             ; 13h - graphical mode, 40x25. 256 colors.;320x200 pixels. 1 page.
    int 10h                 ; Call

    ; Display menu
    push 1
    push 3
    push len
    push menu
    call print_text

menu_loop:
    call read_option        ; Read user option
    cmp al, '1'
    je option_1             ; Jump to option 1 if selected
    cmp al, '2'
    je option_2             ; Jump to option 2 if selected
    cmp al, '3'
    je option_3             ; Jump to option 3 if selected
    cmp al, '4'
    je option_4             ; Jump to option 4 if selected
    jmp menu_loop           ; Loop back if invalid option selected

option_1:
    call soon
    jmp menu_loop

option_2:
    call soon
    jmp menu_loop

option_3:
    call restart
    jmp end

option_4:
    call shutdown
    jmp end

print_txt:
    mov ah, 0Eh             ; BIOS teletype function
.loop:
    lodsb                   ; Load next character from SI
    cmp al, 0               ; Check for end of string
    je .done
    int 10h                 ; Print character
    jmp .loop
.done:
    ret

text_mode:
    mov ah, 0x06    ; Clear / scroll screen up function
    xor al, al      ; Number of lines by which to scroll up (00h = clear entire window)
    xor cx, cx      ; Row,column of window's upper left corner
    int 0x10        ; Issue BIOS video services interrupt with function 0x06
    ret

init_graphic_mode:
    ; In real hardware the BIOS puts the address of the booting drive on the dl register
    mov [bootdrv], dl
    ; Setting the stack
    mov ax, 07C0h
    add ax, 288
    mov ss, ax              ; ss = stack space
    mov sp, 4096            ; sp = stack pointer
    mov ax, 07C0h
    mov ds, ax              ; ds = data segment
    mov ah, 00d             ; Set video mode to graphical
    mov al, 13d             ; 13h - graphical mode, 40x25. 256 colors.;320x200 pixels. 1 page.
    int 10h                 ; Call
    ret

read_option:
    mov ah, 0               ; BIOS keyboard input function
    int 16h                 ; Wait for key press
    ret

soon:
    ; Example function to display a message in graphic mode
    ; In real hardware the BIOS puts the address of the booting drive on the dl register
    mov [bootdrv], dl
    ; Setting the stack
    mov ax, 07C0h
    add ax, 288
    mov ss, ax              ; ss = stack space
    mov sp, 4096            ; sp = stack pointer
    mov ax, 07C0h
    mov ds, ax              ; ds = data segment
    mov ah, 00d             ; Set video mode to graphical
    mov al, 13d             ; 13h - graphical mode, 40x25. 256 colors.;320x200 pixels. 1 page.
    int 10h                 ; Call
    push 10
    push 10
    push 17
    push msg_soon
    call print_text
    call delay
    ret

restart:
    mov ax, 0x0000  ; Load AX register with 0x0000
    int 0x19        ; Call interrupt 0x19 to restart the PC
    ret

shutdown:
    mov ax, 0x5307  ; Subcode to shut down the system
    mov bx, 0x0001  ; Shutdown mode: shutdown and do not restart
    int 0x15        ; Call BIOS interrupt 0x15
    ret

; Configura el contador de tiempo para un retraso de aproximadamente 2 segundos
delay:
    mov cx, 0xFFF  ; Establece un valor inicial grande para CX
    mov dx, 0xFFF  ; Establece un valor inicial grande para DX

    delay_loop:
        dec cx          ; Decrementa CX
        jnz delay_loop  ; Salta si CX no es cero
        dec dx          ; Decrementa DX
        jnz delay_loop  ; Salta si DX no es cero

; En este punto, ha transcurrido aproximadamente un retraso de 3 segundos
jmp start

end:
    hlt

; Data Section


menu db "                              ",13,10,"           MENU            ",13,10," ",13,10,"1. BIOS",13,10,"2. XBOX CPU-KEY ",13,10,"3. Reiniciar",13,10,"4. Apagar",13,10,"                      ",13,10,13,10,"            Bootloader by Allan Ayes", 0
len equ $-menu
msg_soon db "Disponible pronto!", 13,10,0
