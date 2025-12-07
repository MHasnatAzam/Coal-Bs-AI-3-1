.MODEL SMALL       
.STACK 100h        

.DATA
   
    title_msg       DB 'COAL Project: Mouse Pointer Controller - SapID: 65255', '$'
   
    coord_msg       DB 'Coordinates - X:    Y:    $'
   
    click_msg       DB 'Click Status: None$'
  
    left_click_msg  DB 'Click Status: LEFT CLICK$'
   
    right_click_msg DB 'Click Status: RIGHT CLICK$'
  
    instructions    DB 'Controls: Left Click=Draw | Right Click=Erase | ESC=Exit$'
  
    no_mouse_msg    DB 'Error: Mouse not detected!$'
  
    border_horizontal DB 205 DUP('$')
  
    border_vertical DB 186, '$'
  
    border_corner   DB 200, 188, 201, 187, '$'
   
    
    ; Drawing area labels
    drawing_area_msg DB 'DRAWING AREA$'
    status_area_msg  DB 'STATUS PANEL$'
    
    ; Mouse data
    mouse_x DW 0    ; Stores current X coordinate of mouse
    mouse_y DW 0    ; Stores current Y coordinate of mouse
    
    ; Drawing area boundaries (relative to screen)
    draw_start_x DW 3      ; Left edge of drawing area (screen column 3)
    draw_end_x   DW 76     ; Right edge of drawing area (screen column 76)
    draw_start_y DW 5      ; Top edge of drawing area (screen row 5)
    draw_end_y   DW 20     ; Bottom edge of drawing area (screen row 20)
    
    ; Drawing area dimensions (for relative coordinates 0,0 to max)
    draw_width  DW 74      ; 76 - 3 + 1 = 74 columns (0-73)
    draw_height DW 16      ; 20 - 5 + 1 = 16 rows (0-15)

.CODE
MAIN PROC
    MOV AX, @DATA   ; Load the address of the data segment into AX
    MOV DS, AX      ; Initialize DS (data segment) register with data segment address

    ; Set text video mode 80x25
    MOV AX, 0003h   ; AH=00h (set video mode), AL=03h (80x25 16-color text)
    INT 10h         ; Call BIOS video interrupt

    CALL draw_ui    ; Call procedure to draw the user interface

    ; Initialize mouse
    MOV AX, 0       ; Function 00h - Reset mouse and get status
    INT 33h         ; Call mouse interrupt
    CMP AX, 0       ; Compare return value with 0
    JE no_mouse     ; If AX=0, jump to no_mouse (mouse not available)

    ; Show mouse cursor
    MOV AX, 1       ; Function 01h - Show mouse cursor
    INT 33h         ; Call mouse interrupt

main_loop:
    CALL check_keyboard  ; Check if any key is pressed (especially ESC)
    CALL get_mouse       ; Get current mouse position and button status
    CALL update_display  ; Update the coordinate display
    JMP main_loop        ; Infinite loop to keep program running

no_mouse:
    MOV AH, 09h          ; Function 09h - Display string
    LEA DX, no_mouse_msg ; Load address of error message
    INT 21h              ; Call DOS interrupt
    JMP exit_program     ; Jump to exit procedure

MAIN ENDP                ; End of main procedure

draw_ui PROC
    ; Clear screen with blue background
    MOV AH, 06h     ; Function 06h - Scroll window up
    MOV AL, 0       ; AL=0 means clear entire window
    MOV BH, 1Fh     ; Attribute: Blue background (1), White text (F)
    MOV CX, 0       ; CH=0, CL=0 - Upper left corner (0,0)
    MOV DX, 184Fh   ; DH=24, DL=79 - Lower right corner (24,79)
    INT 10h         ; Call BIOS video interrupt

    ; Draw main border
    CALL draw_border     ; Call procedure to draw application border
    
    ; Draw title bar
    MOV AH, 02h     ; Function 02h - Set cursor position
    MOV DH, 1       ; Row 1
    MOV DL, 15      ; Column 15 (centered)
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV BL, 1Eh     ; Attribute: Blue background (1), Yellow text (E)
    MOV CX, 50      ; Repeat count for 50 characters
    INT 10h         ; Call BIOS video interrupt (prepare for colored output)
    LEA DX, title_msg    ; Load address of title message
    INT 21h         ; Call DOS interrupt to display string

    ; Draw status panel border
    CALL draw_status_panel    ; Call procedure to draw status panel
    
    ; Draw drawing area border and label
    CALL draw_drawing_area    ; Call procedure to draw drawing area
    
    ; Draw instructions
    MOV AH, 02h     ; Function 02h - Set cursor position
    MOV DH, 22      ; Row 22 (near bottom)
    MOV DL, 10      ; Column 10
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV BL, 1Fh     ; Attribute: Blue background (1), White text (F)
    LEA DX, instructions    ; Load address of instructions message
    INT 21h         ; Call DOS interrupt to display string

    RET             ; Return from procedure
draw_ui ENDP        ; End of draw_ui procedure

draw_border PROC
    ; Top border
    MOV AH, 02h     ; Function 02h - Set cursor position
    MOV DH, 0       ; Row 0 (top row)
    MOV DL, 0       ; Column 0 (leftmost)
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV AL, 201     ; ASCII 201 - Top-left corner character
    MOV BL, 1Eh     ; Attribute: Blue background (1), Yellow text (E)
    MOV CX, 1       ; Write 1 character
    INT 10h         ; Call BIOS video interrupt
    
    MOV DL, 1       ; Set column to 1
    MOV AH, 02h     ; Function 02h - Set cursor position
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV AL, 205     ; ASCII 205 - Horizontal line character
    MOV CX, 78      ; Write 78 characters (full width minus corners)
    INT 10h         ; Call BIOS video interrupt
    
    MOV DL, 79      ; Set column to 79 (rightmost)
    MOV AH, 02h     ; Function 02h - Set cursor position
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV AL, 187     ; ASCII 187 - Top-right corner character
    MOV CX, 1       ; Write 1 character
    INT 10h         ; Call BIOS video interrupt

    ; Bottom border
    MOV AH, 02h     ; Function 02h - Set cursor position
    MOV DH, 24      ; Row 24 (bottom row)
    MOV DL, 0       ; Column 0 (leftmost)
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV AL, 200     ; ASCII 200 - Bottom-left corner character
    MOV CX, 1       ; Write 1 character
    INT 10h         ; Call BIOS video interrupt
    
    MOV DL, 1       ; Set column to 1
    MOV AH, 02h     ; Function 02h - Set cursor position
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV AL, 205     ; ASCII 205 - Horizontal line character
    MOV CX, 78      ; Write 78 characters
    INT 10h         ; Call BIOS video interrupt
    
    MOV DL, 79      ; Set column to 79 (rightmost)
    MOV AH, 02h     ; Function 02h - Set cursor position
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV AL, 188     ; ASCII 188 - Bottom-right corner character
    MOV CX, 1       ; Write 1 character
    INT 10h         ; Call BIOS video interrupt

    ; Left and right borders
    MOV CX, 23      ; Loop counter for 23 rows (from row 1 to 23)
    MOV DH, 1       ; Start at row 1
draw_vertical:
    MOV AH, 02h     ; Function 02h - Set cursor position
    MOV DL, 0       ; Column 0 (left border)
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV AL, 186     ; ASCII 186 - Vertical line character
    MOV CX, 1       ; Write 1 character
    INT 10h         ; Call BIOS video interrupt
    
    MOV AH, 02h     ; Function 02h - Set cursor position
    MOV DL, 79      ; Column 79 (right border)
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV AL, 186     ; ASCII 186 - Vertical line character
    MOV CX, 1       ; Write 1 character
    INT 10h         ; Call BIOS video interrupt
    
    INC DH          ; Move to next row
    LOOP draw_vertical    ; Decrement CX and loop if not zero
    
    RET             ; Return from procedure
draw_border ENDP    ; End of draw_border procedure

draw_status_panel PROC
    ; Status panel background
    MOV AH, 06h     ; Function 06h - Scroll window up
    MOV AL, 0       ; Clear entire specified area
    MOV BH, 70h     ; Attribute: Black background (7), Gray text (0)
    MOV CH, 2       ; Upper row: 2
    MOV CL, 2       ; Left column: 2
    MOV DH, 3       ; Lower row: 3
    MOV DL, 77      ; Right column: 77
    INT 10h         ; Call BIOS video interrupt

    ; Status panel label
    MOV AH, 02h     ; Function 02h - Set cursor position
    MOV DH, 2       ; Row 2
    MOV DL, 35      ; Column 35 (centered)
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV BL, 70h     ; Attribute: Black background (7), Gray text (0)
    LEA DX, status_area_msg    ; Load address of status area message
    INT 21h         ; Call DOS interrupt to display string

    ; Coordinates display
    MOV AH, 02h     ; Function 02h - Set cursor position
    MOV DH, 2       ; Row 2
    MOV DL, 5       ; Column 5
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV BL, 70h     ; Attribute: Black background (7), Gray text (0)
    LEA DX, coord_msg    ; Load address of coordinates message
    INT 21h         ; Call DOS interrupt to display string

    ; Click status display
    MOV AH, 02h     ; Function 02h - Set cursor position
    MOV DH, 2       ; Row 2
    MOV DL, 50      ; Column 50
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV BL, 70h     ; Attribute: Black background (7), Gray text (0)
    LEA DX, click_msg    ; Load address of click status message
    INT 21h         ; Call DOS interrupt to display string

    RET             ; Return from procedure
draw_status_panel ENDP    ; End of draw_status_panel procedure

draw_drawing_area PROC
    ; Drawing area background
    MOV AH, 06h     ; Function 06h - Scroll window up
    MOV AL, 0       ; Clear entire specified area
    MOV BH, 1Fh     ; Attribute: Blue background (1), White text (F)
    MOV CH, 5       ; Upper row: 5
    MOV CL, 3       ; Left column: 3
    MOV DH, 20      ; Lower row: 20
    MOV DL, 76      ; Right column: 76
    INT 10h         ; Call BIOS video interrupt

    ; Drawing area border
    MOV AH, 06h     ; Function 06h - Scroll window up
    MOV AL, 0       ; Clear entire specified area
    MOV BH, 4Eh     ; Attribute: Red background (4), Yellow text (E)
    MOV CH, 4       ; Upper row: 4
    MOV CL, 2       ; Left column: 2
    MOV DH, 21      ; Lower row: 21
    MOV DL, 77      ; Right column: 77
    INT 10h         ; Call BIOS video interrupt

    ; Drawing area label
    MOV AH, 02h     ; Function 02h - Set cursor position
    MOV DH, 4       ; Row 4
    MOV DL, 35      ; Column 35 (centered)
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV BL, 4Eh     ; Attribute: Red background (4), Yellow text (E)
    LEA DX, drawing_area_msg    ; Load address of drawing area message
    INT 21h         ; Call DOS interrupt to display string

    RET             ; Return from procedure
draw_drawing_area ENDP    ; End of draw_drawing_area procedure

check_keyboard PROC
    MOV AH, 01h     ; Function 01h - Check keyboard status
    INT 16h         ; Call BIOS keyboard interrupt
    JZ skip_key     ; If zero flag set (no key pressed), skip key processing
    MOV AH, 00h     ; Function 00h - Get keyboard input
    INT 16h         ; Call BIOS keyboard interrupt
    CMP AL, 27      ; Compare input character with ASCII 27 (ESC key)
    JE exit_program ; If ESC pressed, jump to exit program
skip_key:
    RET             ; Return from procedure
check_keyboard ENDP ; End of check_keyboard procedure

get_mouse PROC
    MOV AX, 3       ; Function 03h - Get mouse position and button status
    INT 33h         ; Call mouse interrupt
    MOV [mouse_x], CX    ; Store X coordinate in memory
    MOV [mouse_y], DX    ; Store Y coordinate in memory

    CMP BX, 1       ; Compare button status with 1 (left button pressed)
    JE left_click   ; If left button pressed, jump to left_click
    CMP BX, 2       ; Compare button status with 2 (right button pressed)
    JE right_click  ; If right button pressed, jump to right_click
    JMP no_click    ; If no button pressed, jump to no_click

left_click:
    ; Update click status to show left click
    MOV AH, 02h     ; Function 02h - Set cursor position
    MOV DH, 2       ; Row 2
    MOV DL, 50      ; Column 50
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV BL, 70h     ; Attribute: Black background (7), Gray text (0)
    LEA DX, left_click_msg    ; Load address of left click message
    INT 21h         ; Call DOS interrupt to display string
    CALL draw_pixel ; Call procedure to draw a pixel
    JMP done        ; Jump to done

right_click:
    ; Update click status to show right click
    MOV AH, 02h     ; Function 02h - Set cursor position
    MOV DH, 2       ; Row 2
    MOV DL, 50      ; Column 50
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV BL, 70h     ; Attribute: Black background (7), Gray text (0)
    LEA DX, right_click_msg    ; Load address of right click message
    INT 21h         ; Call DOS interrupt to display string
    CALL erase_pixel    ; Call procedure to erase a pixel
    JMP done        ; Jump to done

no_click:
    ; Reset click status to show no click
    MOV AH, 02h     ; Function 02h - Set cursor position
    MOV DH, 2       ; Row 2
    MOV DL, 50      ; Column 50
    INT 10h         ; Call BIOS video interrupt
    MOV AH, 09h     ; Function 09h - Write character and attribute
    MOV BL, 70h     ; Attribute: Black background (7), Gray text (0)
    LEA DX, click_msg    ; Load address of default click message
    INT 21h         ; Call DOS interrupt to display string

done:
    RET             ; Return from procedure
get_mouse ENDP      ; End of get_mouse procedure

draw_pixel PROC
    ; Convert mouse coordinates to text coordinates
    MOV CX, [mouse_x]    ; Load mouse X coordinate into CX
    MOV DX, [mouse_y]    ; Load mouse Y coordinate into DX
    SHR CX, 3            ; Shift right 3 bits (divide by 8) to get text column
    SHR DX, 3            ; Shift right 3 bits (divide by 8) to get text row
    
    ; Check if within drawing container boundaries
    CMP CX, [draw_start_x]  ; Compare with left edge
    JL skip_draw
    CMP CX, [draw_end_x]    ; Compare with right edge
    JG skip_draw
    CMP DX, [draw_start_y]  ; Compare with top edge
    JL skip_draw
    CMP DX, [draw_end_y]    ; Compare with bottom edge
    JG skip_draw
    
    ; Set cursor position for drawing
    MOV AH, 02h
    MOV BH, 0
    ; CORRECTED: Move row/column values properly
    PUSH DX
    MOV DH, DL      ; Row from converted Y (DL contains low byte)
    MOV DL, CL      ; Column from converted X (CL contains low byte)
    INT 10h
    POP DX
    
    ; Draw block character with color
    MOV AH, 09h
    MOV AL, 219     ; ASCII 219 - Solid block character
    MOV CX, 1       ; Write 1 character
    MOV BL, 4Eh     ; Attribute: Red background (4), Yellow text (E)
    INT 10h

skip_draw:
    RET             ; Return from procedure
draw_pixel ENDP     ; End of draw_pixel procedure

erase_pixel PROC
    ; Convert mouse coordinates to text coordinates
    MOV CX, [mouse_x]    ; Load mouse X coordinate into CX
    MOV DX, [mouse_y]    ; Load mouse Y coordinate into DX
    SHR CX, 3            ; Shift right 3 bits (divide by 8) to get text column
    SHR DX, 3            ; Shift right 3 bits (divide by 8) to get text row
    
    ; Check if within drawing container boundaries
    CMP CX, [draw_start_x]  ; Compare with left edge
    JL skip_erase
    CMP CX, [draw_end_x]    ; Compare with right edge
    JG skip_erase
    CMP DX, [draw_start_y]  ; Compare with top edge
    JL skip_erase
    CMP DX, [draw_end_y]    ; Compare with bottom edge
    JG skip_erase
    
    ; Set cursor position for erasing
    MOV AH, 02h
    MOV BH, 0
    ; CORRECTED: Move row/column values properly
    PUSH DX
    MOV DH, DL      ; Row from converted Y (DL contains low byte)
    MOV DL, CL      ; Column from converted X (CL contains low byte)
    INT 10h
    POP DX
    
    ; Erase with space character (replace pixel with background)
    MOV AH, 09h
    MOV AL, ' '     ; ASCII 32 - Space character (erases the pixel)
    MOV CX, 1       ; Write 1 character
    MOV BL, 1Fh     ; Attribute: Blue background (1), White text (F) - matches background
    INT 10h

skip_erase:
    RET             ; Return from procedure
erase_pixel ENDP    ; End of erase_pixel procedure

update_display PROC
    ; Calculate and display relative X coordinate (0 at left edge)
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 2       ; Row 2 (status panel)
    MOV DL, 18      ; Column 18 (position for X coordinate)
    INT 10h
    
    ; Calculate relative X = (mouse_x/8) - draw_start_x
    MOV AX, [mouse_x]
    SHR AX, 3           ; Convert to text column
    SUB AX, [draw_start_x]  ; Subtract starting offset
    CMP AX, 0           ; Ensure non-negative
    JGE x_not_negative
    MOV AX, 0
x_not_negative:
    CMP AX, [draw_width] ; Check if beyond max
    JLE x_ok
    MOV AX, [draw_width]
x_ok:
    CALL print_num      ; Display relative X coordinate

    ; Calculate and display relative Y coordinate (0 at top edge)
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 2           ; Row 2 (status panel)
    MOV DL, 25          ; Column 25 (position for Y coordinate)
    INT 10h
    
    ; Calculate relative Y = (mouse_y/8) - draw_start_y
    MOV AX, [mouse_y]
    SHR AX, 3           ; Convert to text row
    SUB AX, [draw_start_y]  ; Subtract starting offset
    CMP AX, 0           ; Ensure non-negative
    JGE y_not_negative
    MOV AX, 0
y_not_negative:
    CMP AX, [draw_height] ; Check if beyond max
    JLE y_ok
    MOV AX, [draw_height]
y_ok:
    CALL print_num      ; Display relative Y coordinate
    
    RET             ; Return from procedure
update_display ENDP ; End of update_display procedure

print_num PROC
    PUSH AX         ; Save AX register on stack
    MOV CX, 0       ; Initialize digit counter to 0
    MOV BX, 10      ; Set divisor to 10 (for decimal conversion)
    
convert:
    XOR DX, DX      ; Clear DX (upper word for division)
    DIV BX          ; Divide AX by 10, quotient in AX, remainder in DX
    PUSH DX         ; Push remainder (digit) onto stack
    INC CX          ; Increment digit counter
    CMP AX, 0       ; Check if quotient is zero
    JNE convert     ; If not zero, continue conversion
    
    ; Set color for numbers in status panel
    MOV AH, 09h
    MOV BL, 70h     ; Attribute: Black background (7), Gray text (0)
    
display:
    POP DX          ; Pop digit from stack
    ADD DL, '0'     ; Convert digit to ASCII by adding '0' (48)
    MOV AH, 02h     ; Function 02h - Display character
    INT 21h         ; Call DOS interrupt to display digit
    LOOP display    ; Decrement CX and loop until all digits displayed
    
    ; Pad with spaces for consistent 3-digit display
    CMP CX, 3       ; Check if we displayed 3 digits
    JGE pad_done    ; If 3 or more, padding done
    
    ; Calculate padding needed
    MOV BX, 3
    SUB BX, CX      ; BX = spaces needed
    MOV CX, BX
pad_spaces:
    MOV AH, 02h
    MOV DL, ' '     ; Space character
    INT 21h
    LOOP pad_spaces
    
pad_done:
    POP AX          ; Restore AX register from stack
    RET             ; Return from procedure
print_num ENDP      ; End of print_num procedure

exit_program PROC
    ; Hide mouse cursor before exiting
    MOV AX, 2       ; Function 02h - Hide mouse cursor
    INT 33h         ; Call mouse interrupt
    
    ; Clear screen for clean exit
    MOV AX, 0003h   ; Function 00h - Set video mode, AL=03h (80x25 text)
    INT 10h         ; Call BIOS video interrupt
    
    ; Exit to DOS
    MOV AH, 4Ch     ; Function 4Ch - Terminate program
    INT 21h         ; Call DOS interrupt
exit_program ENDP   ; End of exit_program procedure

END MAIN           ; End of program, specify MAIN as entry point