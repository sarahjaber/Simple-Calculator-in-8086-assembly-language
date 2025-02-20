

org 100h

; add your code here     
.model small
.data
.code

jmp start       ; jump over data declaration 
msg0:    db      ,0dh,0ah, " ___> SIMPLE CALCULATOR <___" ,0dh,0ah,'$' 
                                                                                                             
                                                                                                            
msg:     db      0dh,0ah, "1- ADDITION",0dh,0ah,"2-MULTIPLICATION",0dh,0ah,"3-SUBSTRACTION",0dh,0ah,"4-DIVISION", 0Dh,0Ah, '$' 
msg1:    db      0dh,0ah, "ENTER OPERATION (1-4):",0Dh,0Ah,'$'
msg2:    db      0dh,0ah,"ENTER FIRST NUMBER:  $"
msg3:    db      0dh,0ah,"ENTER SECOND NUMBER: $"
msg4:    db      0dh,0ah,"INVALID CHOICE, PLEASE CHOOSE IN (1-4) RANGE!" , 0Dh,0Ah," $" 
msg5:    db      0dh,0ah,"RESULT: $"                                   
msg6:    db      0dh,0ah ,'THANK YOU FOR USING OUR CALCULATOR!!', 0Dh,0Ah, '$' 
msg7:    db      0dh,0ah ,'Sorryyy! Cannot divide by zero! Try again', 0Dh,0Ah, '$'  


start:  ;program's main menu interaction
        mov ah,9                    ;Prepares DOS interrupt for displaying a string
        mov dx, offset msg0         ;Loads the memory address of msg0 into dx
        int 21h                     ;Calls the DOS interrupt to display the message
                                          
                                          
       ;Displays Calculator Options 
        mov ah,9
        mov dx, offset msg          
        int 21h
        
         mov ah,9                  
        mov dx, offset msg1          
        int 21h 
                                    ;Prepares the BIOS interrupt for reading a character from the keyboard
        mov ah,0                       
        int 16h                     ; Reads the pressed key and stores it in al 
        
        cmp al,31h                  ;Compares ASCII value in al with the ASCII values of 1(31h), 2(32h), 3(33h), and 4(34h)  
        
        je Addition                 ;jump to addition
        
        cmp al,32h                  ;jump to multiply
        je Multiply                                  
        
        cmp al,33h                  ;jump to subtract
        je Subtract       
        
        cmp al,34h                  ; jump to divide
        je Divide  
        
        mov ah,09h                  ;if invalid choice, display msg4
        mov dx, offset msg4
        int 21h  
        mov ah,0                    
        int 16h                     ;waits for user to press a key(like enter)
        jmp start                  
        
        
Addition:   mov ah,09h  
            mov dx, offset msg2  
            int 21h                 ;Displays the msg to the user 
            
            mov cx,0                ;initializes counter
            call InputNo             
            push dx                  
            
            mov ah,9
            mov dx, offset msg3     
            int 21h                
            mov cx,0                ;re-initializes counter
            call InputNo            
            
            pop bx                 
            add dx,bx               
            push dx                 ;pushes result for later dsiplay 
            
               ;Display "RESULT:":
            mov ah,9
            mov dx, offset msg5
            int 21h      
            
            mov cx,10000            ;Initializes cx with a large value to format digits results for display
            pop dx                 
            call View              
            jmp exit               
          
             
               ; inputs multi-digit numbers
InputNo:    mov ah,0                ;Prepares the DOS interrupt to wait for a key press
            int 16h                 ;Invokes the keyboard interrupt // The ASCII code of the pressed key is returned in the al register
            
            mov dx,0               
            mov bx,1               
            cmp al,0dh             
            je FormNo               
            
            sub ax,30h             ;Converts the ASCII character of the digit into numerical value
            call ViewNo            
            
            mov ah,0               
            push ax                
            inc cx                 
            jmp InputNo            
            
FormNo:     ;after Enter, it forms the Full Number
            pop ax            
            push dx                
            mul bx                
            pop dx                  
            add dx,ax              
            
            ;prepare for the Next Digit's Position
            mov ax,bx             
            mov bx,10             
            push dx
            mul bx
            pop dx
            mov bx,ax             
            
            dec cx                
            cmp cx,0              
            jne FormNo            
            ret                   


      
         ;;view and viewNo displays results 
View:  mov ax,dx
       mov dx,0
       div cx 
       call ViewNo
       mov bx,dx 
       mov dx,0
       mov ax,cx 
       mov cx,10
       div cx
       mov dx,bx 
       mov cx,ax
       cmp ax,0
       jne View
       ret


ViewNo:    push ax
           push dx 
           mov dx,ax 
           add dl,30h 
           mov ah,2
           int 21h
           pop dx  
           pop ax
           ret
      
   
exit:   mov dx,offset msg6
        mov ah, 09h
        int 21h  


        mov ah, 0
        int 16h

        ret
            
                       
Multiply:   mov ah,09h
            mov dx, offset msg2    ;loads msg2 
            int 21h                ;display to user
            
            mov cx,0
            call InputNo
            push dx
            mov ah,9      
            
            mov dx, offset msg3
            int 21h   
            
            mov cx,0
            call InputNo
            pop bx
            mov ax,dx              ;Moves the second number (dx) into ax to prepare for multiplication.
            mul bx 
            mov dx,ax              ;Moves the result (ax) into dx for displaying purposes.
            push dx 
            mov ah,9
            mov dx, offset msg5
            int 21h    
            
            mov cx,10000             ;Sets cx to 10000 to prepare for scaling in the View subroutine
            pop dx
            call View                ;to display the result.
            jmp exit 


Subtract:   mov ah,09h
            mov dx, offset msg2
            int 21h    
            
            mov cx,0
            call InputNo
            push dx
            mov ah,9
            mov dx, offset msg3
            int 21h   
            
            mov cx,0
            call InputNo
            pop bx
            sub bx,dx
            mov dx,bx               ;Moves the result (bx) into dx for displaying purposes.
            push dx 
            mov ah,9
            mov dx, offset msg5
            int 21h      
            
            mov cx,10000
            pop dx
            call View 
            jmp exit 
    
            
Divide:     
            mov ah, 09h
            mov dx, offset msg2    ; Prompt for first number
            int 21h    
            
            mov cx, 0
            call InputNo           ; Read the first number
            push dx
        
            mov ah, 9h
            mov dx, offset msg3    ; Prompt for second number
            int 21h    
            
            mov cx, 0
            call InputNo           ; Read the second number
            pop bx                 ; Retrieve the first number
            cmp dx, 0              ; Check if the second number is zero
            je DivByZeroError      ; If zero, jump to error handling
        
            mov ax, bx             ; Perform division
            mov cx, dx             ; Move second number to CX
            mov dx, 0
            div cx
            mov bx, dx             ; Store remainder
            mov dx, ax             ; Store quotient
            push bx
            push dx
        
            mov ah, 9h
            mov dx, offset msg5    ; Display "RESULT: "
            int 21h        
            
            mov cx, 10000
            pop dx
            call View              ; Display quotient
            pop bx
            jmp exit               ; Exit to main menu

DivByZeroError:
            mov ah, 09h
            mov dx, offset msg7    ; Display error message
            int 21h
            jmp start              ; Restart program  
            
            
            



ret






