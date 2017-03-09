section .rodata
new_Line: 
        DB 	"",10,0
print_hex: 
        DB 	"%x",0
print_int: 
        DB 	"%d",10,0
overflow_err:
        DB	"Error: Operand Stack Overflow", 10, 0
input_err:
        DB	"Error: Illegal Input", 10, 0
stack_err:
        DB	"Error: Insufficient Number of Arguments on Stack", 10, 0
enter_num:
        DB	"calc: ", 0, 0

section .data 
        num_of_operations:  DD 0
        my_counter:    DD 0
        num_of_numbers_in_stack: DD 0
        my_stack_pointer: DD my_stack
        stack_size EQU 5
        link_size EQU 5
        carry: DB 0

section .bss
        stackSize resd stack_size
        operand: resd 80
        string: resb 80 
        my_stack: resb 4*stack_size
        
section .text
    align 16 
    global main 
    extern printf 
    extern fprintf 
    extern malloc 
    extern fgets 
    extern stderr 
    extern stdin 
    extern stdout 
;----------------------------------------------------------------------------------------------------



%macro push_to_my_stack_func 1
push ecx
push ebx
cmp byte [num_of_numbers_in_stack],stack_size
jne %%ok_push
push overflow_err
call printf
pop ebx
jmp %%end_of_push
%%ok_push:
mov ecx,[my_stack_pointer]
add ecx,4
mov [my_stack_pointer],ecx
mov [ecx],%1
mov ecx,[num_of_numbers_in_stack]
add ecx,1
mov [num_of_numbers_in_stack],ecx
%%end_of_push:
    pop ebx
    pop ecx
%endmacro      

%macro pop_from_my_stack_func 0
push ecx
push eax
cmp byte [num_of_numbers_in_stack],0
jne %%ok_pop
push stack_err
call printf
pop eax
jmp %%end_of_pop 
%%ok_pop:
mov ecx,[my_stack_pointer];
sub ecx,4
mov[my_stack_pointer],ecx
mov ecx,[num_of_numbers_in_stack]
sub ecx,1
mov [num_of_numbers_in_stack],ecx
%%end_of_pop:
pop eax
pop ecx
%endmacro     


;----------------------------------------------------------------------------------------------------



    main:
            push	ebp
            mov	ebp, esp
            pusha
    my_calc:
    push enter_num
    call printf
    pop eax
    push dword [stdin]
    push dword 80
    push dword string
    call fgets
    cmp byte [eax],'+'
    je addition_func
    cmp byte [eax],'&'
    je and_func
    cmp byte [eax],'q'
    je quit_func
    cmp byte [eax],'d'
    je duplicate_func;
    cmp byte [eax],'p'
    je pop_plus_print_func;
    
    ;----------------------------------------------------------------------------------------------------



    number_func:
    push link_size
    call malloc
    add esp,4

    push eax
    push_to_my_stack_func eax
    pop eax
    mov ecx,0
    
    go_to_end_of_string:
    cmp byte [string+ecx], 0
    je create_list
    inc ecx
    jmp go_to_end_of_string
    
    create_list:
    cmp byte cl,0
    je end_of_creating_list
    dec ecx

    convert_first_digit:  
    mov edx,0
    mov bl,[string+ecx-1]
    cmp byte bl, '0'
    jb bad_input
    cmp byte bl,'9'
    ja bad_input
    sub_zero:
    sub bl,'0'
    add byte dl,bl
    dec ecx
    cmp byte cl,0
    je add_link
    convert_second_digit:
    mov bl,[string+ecx-1] 
    cmp byte bl, '0'
    jb bad_input
    cmp byte bl,'9'
    ja bad_input
    sub_zero2:
    sub bl,'0'
    shl bl,4
    add byte dl,bl
    dec ecx
    
    add_link:
    mov ebx,0
    mov byte [eax], dl;
    inc eax
    mov ebx , eax;
    
    cmp byte cl,0
    je end_of_creating_list
        
    push ecx;
    push link_size 
    call malloc
    add esp,4
    pop ecx

    mov [ebx],eax
    
    jmp convert_first_digit

    end_of_creating_list:
    mov dword [eax],0	
    jmp my_calc

    ;----------------------------------------------------------------------------------------------------

    
    addition_func:
        mov ebx,[num_of_numbers_in_stack]
        cmp ebx,1
        jg ok_to_add
        push stack_err
        call printf
        add esp,4
        jmp my_calc
        
        ok_to_add:
            mov edx, [num_of_operations]		
        inc edx
        mov [num_of_operations], edx
        push link_size
        call malloc
        add esp,4
        mov ebx, [my_stack_pointer]
        mov ecx,[ebx]
        pop_from_my_stack_func
        mov ebx, [my_stack_pointer]
        mov edx,[ebx]
        pop_from_my_stack_func
        push_to_my_stack_func eax
        mov byte [carry],0
        two_links_to_add:
        mov ebx, 0						
            mov esi, 0
        push eax
        mov eax, 0						
            first_add:
        mov al, [ecx]
            and al, 15
        add  bx, ax
        mov al, [edx]
            and al, 15
        add  bx, ax
            mov al,[carry]
        add bx,ax
        mov ax, 0						
            cmp bx, 9
            jbe sec_add
            add bl, 6
            inc esi
        sec_add:
            mov al, [ecx]
            shr al, 4
            add esi, eax
        mov eax, 0						
            mov al, [edx]
            shr al, 4 
            add esi, eax
            cmp esi, 9
            mov al, 0
            jbe join_additions
            add esi, 6
            inc al
            join_additions:
            and ebx, 15
            and esi, 15
            shl esi, 4
            add ebx, esi
        add_carry:
            mov byte [carry],al
            pop eax
            mov byte [eax],bl

        after_carry:
        
        inc ecx
        mov ebx,0
        mov ebx,[ecx]
        mov ecx, ebx
        
        inc edx
        mov ebx,0
        mov ebx,[edx]
        mov edx, ebx
        
        cmp ecx,0
        JE second_link_to_add
        
        cmp edx,0
        JE first_link_to_add
        
        continue_add:
        inc eax
        mov ebx,eax
        push ebx
        push ecx
        push edx
        push link_size
        call malloc
        add esp,4
        pop edx
        pop ecx
        pop ebx
        mov [ebx],eax
        jmp two_links_to_add

        first_link_to_add:
        cmp ecx,0
        je end_of_addition
        
        inc eax
        mov ebx,eax
        push ebx
        push ecx
        push edx
        push link_size
        call malloc
        add esp,4
        pop edx
        pop ecx
        pop ebx
        mov [ebx],eax
        
        mov ebx, 0
        push eax
        mov eax, 0
        mov al, [ecx]
        add  bx, ax
        
        mov eax, 0
        mov al,[carry]
        add bx,ax
        
        pop eax
        
        mov byte [eax],bl
        mov byte [carry],bh
        
        inc ecx
        xor ebx,ebx
        mov ebx,[ecx]
        mov ecx, ebx
        
        jmp first_link_to_add
        
        second_link_to_add:
        cmp edx,0
        je end_of_addition
        
        inc eax
        mov ebx,eax
        push ebx
        push ecx
        push edx
        push link_size
        call malloc
        add esp,4
        pop edx
        pop ecx
        pop ebx
        mov [ebx],eax
        
        mov ebx, 0
        push eax
        mov eax, 0
        mov al, [edx]
        add  bx, ax
        
        mov eax, 0
        mov al,[carry]
        add bx,ax
        
        pop eax
        
        mov byte [eax],bl
        mov byte [carry],bh
        
        inc edx
        mov ebx,[edx]
        mov edx, ebx
        
        jmp second_link_to_add
        
        end_of_addition:
        mov ebx,[carry]
        cmp ebx,1
        jne endd
        inc eax
        mov ecx,eax
        push ecx
        push link_size
        call malloc
        add esp,4
        pop ecx
        mov [ecx],eax
        mov byte [eax],1
        endd:
        inc eax
        mov dword [eax],0
            jmp my_calc;

            
            ;----------------------------------------------------------------------------------------------------

            
            
            
    pop_plus_print_func:
        mov ebx,[num_of_numbers_in_stack]
        cmp ebx,0
        jne ok_to_print
        push stack_err
        call printf
        add esp,4
        jmp my_calc
        ok_to_print:
        mov edx, [num_of_operations]		
        inc edx
        mov [num_of_operations], edx
        mov edx, -1
        push edx
        mov ebx, [my_stack_pointer]
        mov eax,[ebx]

    push_node:
            mov ebx,0				
            mov bl,[eax]				
            push ebx				
            inc eax					
            mov ecx,0					
            mov ecx,[eax]				
            mov eax,ecx					
            cmp eax,0
            jne	push_node

    ;----------------------------------------------------------------------------------------------------

            
    printing_func:
            pop ebx
            cmp	ebx,-1					
            je	quit_printing			
            push ebx
            push print_hex			
            call printf						
            add esp,8						

            jmp		printing_func	
    quit_printing:
        pop_from_my_stack_func 
            push new_Line
            call printf

    jmp my_calc;


    ;----------------------------------------------------------------------------------------------------



    and_func:	
            mov ebx,[num_of_numbers_in_stack]
            cmp ebx,1
            jg ok_to_and
            push stack_err
            call printf
            add esp,4
            jmp my_calc;
            
            ok_to_and:
            mov edx,[num_of_operations]
            inc edx
            mov [num_of_operations], edx
            push link_size
            call malloc
            add esp,4
            mov ebx, [my_stack_pointer]
            mov ecx,[ebx]
            pop_from_my_stack_func
            mov ebx, [my_stack_pointer]
            mov edx,[ebx]
            pop_from_my_stack_func
            push_to_my_stack_func eax
            
            do_and:
            mov ebx,0
            mov esi,0
            push eax
            mov eax,0
            mov al, [ecx]
            mov bl, [edx]
            and bl, al
            pop eax
            mov byte [eax],bl
            
            inc ecx
        mov ebx,0						
        mov ebx,[ecx]
        mov ecx, ebx
            
        inc edx
        mov ebx,0						
        mov ebx,[edx]
        mov edx, ebx
            cmp ecx,0
        JE only_second_link_to_and
        cmp edx,0
        JE only_first_link_to_and
            
            continue_and:
            inc eax
        mov ebx,eax
        push ebx
        push ecx
        push edx
        push link_size
        call malloc
        add esp,4
        pop edx
        pop ecx
        pop ebx
        mov [ebx],eax
            jmp do_and
            
            only_first_link_to_and:
            cmp ecx,0
            je end_of_and
            inc eax
        mov ebx,eax
        push ebx
        push ecx
        push edx
        push link_size
        call malloc
        add esp,4
        pop edx
        pop ecx
        pop ebx
        mov [ebx],eax
            mov ebx, 0
        push eax
        mov eax, 0
        mov al, [ecx]
        and  bx, ax
            pop eax
            mov byte [eax],bl
            
            inc ecx
        mov ebx,0			
        mov ebx,[ecx]
        mov ecx, ebx
            jmp only_first_link_to_and
            
            only_second_link_to_and:
            cmp ecx,0
            je end_of_and
            inc eax
        mov ebx,eax
        push ebx
        push ecx
        push edx
        push link_size
        call malloc
        add esp,4
        pop edx
        pop ecx
        pop ebx
        mov [ebx],eax
            mov ebx, 0
        push eax
        mov eax, 0
        mov al, [ecx]
        and  bx, ax
            pop eax
            mov byte [eax],bl
            
            inc ecx
        mov ebx,0			
        mov ebx,[ecx]
        mov ecx, ebx
            jmp only_second_link_to_and
            
            end_of_and:
            inc eax
        mov dword [eax],0
            jmp my_calc;
    ;----------------------------------------------------------------------------------------------------



    duplicate_func:
        mov ebx,[num_of_numbers_in_stack]
        cmp ebx,0
        jne stack_not_empty
        push stack_err
        call printf
        add esp,4
        jmp my_calc
        stack_not_empty:
        cmp ebx,5
        jne ok_to_duplicate
        push overflow_err
        call printf
        add esp,4
        jmp my_calc
        ok_to_duplicate:
        mov edx, [num_of_operations]				
        inc edx
        mov [num_of_operations], edx
        mov ebx, [my_stack_pointer]
        mov edx,[ebx]
            push 	edx
            push link_size
            call malloc
            add esp,4
            pop edx

            push_to_my_stack_func eax
            

    iterate_links:

            mov ecx ,0
            mov byte cl,[edx]
            mov byte [eax],cl 
            inc edx
            inc eax
            
            mov ecx,0
            mov ecx,[edx]
            mov edx,ecx
            cmp 		edx,0
            je last_link
            
            mov ebx,eax 
            push	ebx		
            push 	edx
            push link_size
            call malloc
            add esp,4
            pop edx
            pop ebx
            mov dword [ebx],eax
            jmp iterate_links
            
    last_link:
            mov dword [eax],0	
            jmp my_calc;

    ;----------------------------------------------------------------------------------------------------

            
    bad_input:
                    push input_err
                    call printf
                    jmp my_calc
            
    quit_func:
            mov eax,dword [num_of_operations]
            push eax
            push print_int
            call printf
            pop eax
            mov eax,1
            mov ebx,0
            int 0x80

    end:
            pop eax
            popa	
            mov	esp, ebp
            pop	ebp
            ret
            
    ;----------------------------------------------------------------------------------------------------
    ;----------------------------------------------------------------------------------------------------
    ;----------------------------------------------------------------------------------------------------
            