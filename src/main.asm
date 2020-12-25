;Project Title: Bank Managment System
;Author: Asaad Noman Abbasi // BCS 3-F // 1912297

.model small
.stack 100h
.data
    
    dmsg1 db ' -------------------------$'
    dmsg2 db ' | Bank Managment System |$ '
    dmsg3 db ' -------------------------$'
    
    opmsg1 db '1. Create new Account$'
    opmsg2 db '2. Print Account Details$'
    opmsg3 db '3. Withdraw Money $'
    opmsg4 db '4. Deposit Money $'
    opmsg5 db '5. Reset Account $'
    opmsg6 db '6. Modify Account Details$'
    
    opmsg8 db 'Press Enter To Return to Main Menu $'
    
    imsg db 'What Do You Want To Do ? : $'
    inputCode db ? 
    
    ;Account details  
    
    accountName db 100 dup('$')
    accountPIN db 100 dup('$')
    accountPINcount dw 0       ;This keeps track how many digit a pin is
    totalAmount dw 0
    inputAmountOption db ? 
                                  
    ;Option 1 (Create Account) Messages
    op1msg1 db '1. Enter Account Name: $'
    op1msg2 db '2. Enter Account Pin: $'    
    op1msg3 db 'Successfully Created New Account ! $'    
    
    ;Option 2 <Print details> Messages
    op2msg1 db 'Account Name: $' 
    op2msg2 db 'Currently Saved Account PIN: $'
    op2msg3 db 'No Accounts Currently Saved !$'   
    op2msg4 db 'Total Money Left: $'
    
    ;Option 4 <Money> Messages
    op4msg1 db '1. Rs 1000$'
    op4msg2 db '2. Rs 2000$'
    op4msg3 db '3. Rs 5000$'
    op4msg4 db '4. Rs 10000$'
    op4msg5 db 'Enter Code: $'  
    op4msg6 db 'You Are Withdrawing Too MUCH !$'
    
    ;Option 5 <Reset> Messages
    op5msg1 db 'Account Has been reset successfully$'
    
    ;Option 6 <Modify Account> Messages  
    op6msg0   db 'Account Details Successfully Changed !$'
    op6msg1_1 db '1. New Account Name ( old: $'
    op6msg1_2 db ' ) : $' 
    op6msg2_1 db '2. New Account Pin ( old: $'
    op6msg2_2 db ' ) : $'
    
    ;PIN Protection
    pinop_msg1 db 'Enter Pin: $' 
    pinop_msg2 db 'Account not created ... $'
        
.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;                                                                   ;
;                             U T I L S                             ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Enter to Continue
proc etc
   etcin:
      mov ah,1
      int 21h
      cmp al,13
      je mainloop
      jmp etcin
   ret 
etc endp

;This checks whether the account has been created or not using the pin Count
checkAccountCreated proc
  cmp accountPINcount,0
  je accountNotCreated
  ret
  
  accountNotCreated:
    call clearScreen
    printString pinop_msg2
    call etc
       
checkAccountCreated endp

;just mov number to ax and call this proc
printNumber PROC                  
    ;initilize count 
    mov cx,0 
    mov dx,0 
    label1: 
        ; if ax is zero 
        cmp ax,0 
        je print1       
          
        ;initilize bx to 10 
        mov bx,10         
          
        ; extract the last digit 
        div bx                   
          
        ;push it in the stack 
        push dx               
          
        ;increment the count 
        inc cx               
          
        ;set dx to 0  
        xor dx,dx 
        jmp label1
         
    print1: 
        ;check if count  
        ;is greater than zero 
        cmp cx,0 
        je exitprint
          
        ;pop the top of stack 
        pop dx 
          
        ;add 48 so that it  
        ;represents the ASCII 
        ;value of digits 
        add dx,48 
          
        ;interuppt to print a 
        ;character 
        mov ah,02h 
        int 21h 
          
        ;decrease the count 
        dec cx 
        jmp print1 
exitprint: 
ret 
printNumber ENDP

clearScreen proc near
    pusha
    mov ah,0x00
    mov al,0x03
    int 0x10
    popa
    ret    
clearScreen endp
                                     
newLine proc near   
    mov ah,2
    mov dl,10
    int 21h
    mov dl,13
    int 21h    
    ret
    
newLine endp

macro printString str   
  mov ah,9
  lea dx,str
  int 21h
endm

;Ask for user pin here
getPinInput proc
  call clearScreen
 
  printString pinop_msg1
  
  mov si,offset accountPIN
  mov cx,accountPINcount     ;Search n amount of times the pin Count
  getinput:
    
    mov ah,7
    int 21h
    
    cmp al,[si]
    
    mov dl,'*'
    mov ah,2
    int 21h
    
    jne mainloop
    
    inc si    
  loop getinput
  
  ret        
getPinInput endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;                                                                   ;
;                        M E N U   SYSTEM                           ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DisplayMenu proc near   
    printString dmsg1
    call newLine
    printString dmsg2
    call newLine
    printString dmsg3
    call newLine
    call newLine 
    printString opmsg1
    call newLine
    printString opmsg2
    call newLine
    printString opmsg3
    call newLine
    printString opmsg4
    call newLine
    printString opmsg5
    call newLine
    printString opmsg6
    call newLine    
    ret        
DisplayMenu endp       

GetInputMenuSystem proc near 
    call newLine
    printString imsg
    mov ah,1
    int 21h
    mov inputCode,al
    ret        
GetInputMenuSystem endp 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;                                                                   ;
;               O P T I O N  1   => CREATE ACCOUNT                  ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

macro ISop11 str
    mov si,offset str
    input: 
        mov ah,1
        int 21h
        cmp al,13
        je labelop1_1
        mov [si],al
        inc si
        jmp input
        
    exitMac:
        ret
  
endm

macro ISop12 str
    mov si,offset str
    input2: 
        mov ah,1
        int 21h
        cmp al,13
        je labelop1_2
        inc accountPINcount
        mov [si],al
        inc si
        jmp input2
        
    exitMac2:
        ret
  
endm

proc etcop1
   etcop1in:
      mov ah,1
      int 21h
      cmp al,13
      je mainloop
      jmp etcop1in
   ret 
etcop1 endp

op1 proc
        
    call clearScreen
    printString op1msg1
    ISop11 accountName
    
    labelop1_1:
      call newLine 
      printString op1msg2
      ISop12 accountPIN
    
    labelop1_2:
        
        call newLine
        call newLine
        printString op1msg3
        call etcop1
        
     ;jmp mainloop    ;this basically returns the control back to the program
    
    ret
op1 endp                                                                 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;                                                                   ;
;               O P T I O N  1   => PRINT DETAILS                   ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;           

proc etcop2
   call newLine
   printString opmsg8
   etcop2in:
      mov ah,1
      int 21h
      cmp al,13
      je mainloop
      jmp etcop2in
   ret 
etcop2 endp 

op2 proc
  
  call checkAccountCreated  ;check whether the account has been created or not 
  call getPinInput  ;gets the pin input for verification
  call clearScreen
  
  printString op2msg1
  printString accountName  
  call newLine
  
  printString op2msg2
  printString accountPIN 
  call newLine   
  
  printString op2msg4
  mov ax,totalAmount
  call printNumber 
  call newLine
  
  call etcop2    
    
  ret             
  
op2 endp
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;                                                                   ;
;               O P T I O N  3   => WIDTHDRAW MONEY                 ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            
 
op3 proc
  
  call checkAccountCreated  ;check whether the account has been created or not
  call getPinInput  ;gets the pin input
  call clearScreen
  
  printString op4msg1
  call newLine
  printString op4msg2
  call newLine
  printString op4msg3
  call newLine
  printString op4msg4
  call newLine
  
  call inputAmountCode  
  
  cmp inputAmountOption,'1'
  je wcop1
  
  cmp inputAmountOption,'2'
  je wcop2 
  
  cmp inputAmountOption,'3'
  je wcop3
  
  cmp inputAmountOption,'4'
  je wcop4
  
  ;check if widraw amount <= totalAmount in acc  
  wcop1:
    mov bx,totalAmount
    cmp bx,1000
    jl nowaybro    
    sub totalAmount,1000
    jmp mainloop
  wcop2:        
    mov bx,totalAmount
    cmp bx,2000
    jl nowaybro    
    sub totalAmount,2000
    jmp mainloop
  wcop3:        
    mov bx,totalAmount
    cmp bx,5000
    jl nowaybro    
    sub totalAmount,5000
    jmp mainloop
  wcop4:        
    mov bx,totalAmount
    cmp bx,10000
    jl nowaybro    
    sub totalAmount,10000
    jmp mainloop
   
  ;error message for widthdrawing too much 
  nowaybro:
    
    call newLine
    call newLine
    printString op4msg6
    call etcop4
   
  ret  

op3 endp
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;                                                                   ;
;               O P T I O N  4   => DEPOSIT MONEY                   ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            

proc etcop4
   call newLine
   ;printString opmsg8
   etcop4in:
      mov ah,1
      int 21h
      cmp al,13
      je mainloop
      jmp etcop4in
   ret 
etcop4 endp

proc inputAmountCode
  call newLine
  printString op4msg5
  mov ah,1
  int 21h
  mov inputAmountOption,al
  ret  
inputAmountCode endp

op4 proc
  
  call checkAccountCreated  ;check whether the account has been created or not
  call getPinInput  ;gets the pin input
  call clearScreen
  
  printString op4msg1
  call newLine
  printString op4msg2
  call newLine
  printString op4msg3
  call newLine
  printString op4msg4
  call newLine
  
  call inputAmountCode  
  
  cmp inputAmountOption,'1'
  je dcop1
  
  cmp inputAmountOption,'2'
  je dcop2 
  
  cmp inputAmountOption,'3'
  je dcop3
  
  cmp inputAmountOption,'4'
  je dcop4
   
  dcop1:    
    add totalAmount,1000
    jmp mainloop
  dcop2:
    add totalAmount,2000   
    jmp mainloop
  dcop3:
    add totalAmount,5000
    jmp mainloop
  dcop4:
    add totalAmount,10000
    jmp mainloop
   
  ret  

op4 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;                                                                   ;
;               O P T I O N  5   => RESET ACCOUNT                   ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

proc etcop5
   call newLine
   ;printString opmsg8
   etcop5in:
      mov ah,1
      int 21h
      cmp al,13
      je mainloop
      jmp etcop5in
   ret 
etcop5 endp

op5 proc
  
  call checkAccountCreated  ;check whether the account has been created or not
  call getPinInput  ;gets the pin input   
    
  ;Do the rest of the work .. display the data
  call clearScreen
  
  mov si,offset accountName
  mov cx,30
  l1:
    mov [si],' '
    inc si
  loop l1
  
  mov cx,30
  mov si,offset accountPIN
  l2:
    mov [si],' '
    inc si
  loop l2  
  
  mov totalAmount,0
  mov accountPINcount,0 ;reset pin count
      
  printString op5msg1
  call etcop5   
  ret  
op5 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;                                                                   ;
;               O P T I O N  6   => MODIFY ACCOUNT DETAILS          ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

proc etcop6
   call newLine
   ;printString opmsg8
   etcop6in:
      mov ah,1
      int 21h
      cmp al,13
      je mainloop
      jmp etcop6in
   ret 
etcop6 endp

macro ISop6 str
 mov si,offset str
    ISop6input: 
        mov ah,1
        int 21h
        cmp al,13
        je labelop6_1
        mov [si],al
        inc si
        jmp ISop6input   
endm

macro ISop6_2 str
 mov si,offset str
 mov accountPINcount,0 ;reset pin count
    ISop6_2input: 
        mov ah,1
        int 21h
        cmp al,13
        je labelop6_2
        inc accountPINcount ;increment pin account again
        mov [si],al
        inc si
        jmp ISop6_2input   
endm

op6 proc
  
  call checkAccountCreated  ;check whether the account has been created or not    
  call getPinInput  ;gets the pin  
  call clearScreen
  
  ;;account name
  printString op6msg1_1
  printString accountName
  printString op6msg1_2
  
  ISop6 accountName ;input accountName
  
  labelop6_1:
    
    call newLine
    printString op6msg2_1
    printString accountPIN
    printString op6msg2_2
    ISop6_2 accountPIN
  
  labelop6_2:
    
    ;Finished MSG
    call newLine
    call newLine
    printString op6msg0
    call etcop6
  
  
  ret  
op6 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;                                                                   ;
;                     E N T R Y    P O I N T                        ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;1.  Create Account
;2.  Deposit Money
;3.  Widthdraw Money
;4.  Print Account Details
;5.  Modify Account
;6.  Reset Account

;7.  Dynamic Pin Range
;8.  Pin Verification
;9.  Checks if account is created before performing functions
;10. When withdrawing, checks whether if u have enough money in account
            
Main proc
    
    mov ax,@data
    mov ds,ax
    
    mainloop:
    
        call clearScreen
        call DisplayMenu
        call GetInputMenuSystem
                                              
        cmp inputCode,'0'
        je exit
        
        cmp inputCode,'2'
        je op2
        
        cmp inputCode,'4'
        je op4  
        
        cmp inputCode,'3'
        je op3
        
        cmp inputCode,'6'
        je op6
        
        cmp inputCode,'1'
        je op1  
        
        cmp inputCode,'5'   
        je op5
        
        jmp mainloop
                       
    exit:
      
      mov ah,4ch
      int 21h
    
    main endp
end main