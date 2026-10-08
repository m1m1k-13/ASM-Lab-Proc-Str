; Лабораторная работа 7
; Аникин А. 24ВП2
; Ввести две строки. Проверить, содержится ли полностью строка 2 в строке 1. Если да, с какой позиции.

.586
.MODEL flat, stdcall
OPTION CASEMAP:NONE

Include kernel32.inc
Include masm32.inc

IncludeLib kernel32.lib
IncludeLib masm32.lib

.CONST
MsgLab DB "Lab 7 Anikin A. 24VP2",13,10,10,0
NextLn DB 13,10,0
MaxStr EQU 100
FirstStr DB "Input first string: ",13,10,0
SecondStr DB "Input second string: ",13,10,0
ResMsg DB "Second string was found in position: ",0
DelRes DB 13,10,"New string: ",0
NotResMsg DB "Second string wasn't found in first string",13,10,0
MsgExit DB 13,10,"Press Enter to Exit",0

.DATA
ResStr DB 16 DUP(' '),0

.DATA?
Str1 DB MaxStr DUP (?)
Str2 DB MaxStr DUP (?)
InBuf DB 100 DUP (?)

.CODE
get_len PROC
; Вычисляет и возвращает длину строки.
; Receives: ESI = адрес строки,
;           ECX = максимальная длина строки.
; Returns:  EAX = длина строки без завершающего нулевого символа.

    push edi
    push ecx
    push edx

    ; Подготовка регистров
    xor eax, eax ; Образец поиска
    mov edx, ecx ; Сохранение максимальной длины строки
    mov edi, esi ; Запись адреса строки

    ; Проход по строке до /0
    repne scasb

    ; Вычисление длины: MaxStr - ECX - 1
    sub edx, ecx 
    dec edx
    mov eax, edx

    pop edx
    pop ecx
    pop edi

    ret

get_len ENDP

cmp_str PROC
; Сравнивает две строки.
; Receives: EDI = адрес первой строки,
;           ESI = адрес второй строки,
;           EBX = количество символов для сравнения.
; Returns:  ZF = флаг нулевого результата:
;           0, если строки не равны,
;           1, если строки равны.

    push edi
    push esi
    push ecx

    ; Поиск расхождения
    mov ecx, ebx
    repe cmpsb 

    pop ecx
    pop esi
    pop edi

    ret

cmp_str ENDP

search_substr PROC
; Выполняет поиск подстроки в строке.
; Receives: EDI = адрес первой строки,
;           ESI = адрес второй строки,
;           ECX = максимальная длина строки.
; Returns:  EAX = позиция начала второй строки в первой строке,
;           -1, если строка не найдена,
;           EDI = адрес первого элемента подстроки,
;           EBX = длина подстроки,
;           ECX = длина строки от подстроки.
    
    push edx
    push esi

    ; Получаем длину второй строки
    call get_len 
    mov ebx, eax 

    ; Проверка на пустую подстроку
    test ebx, ebx
    je empty_string

    ; Подготовка регистров к поиску
    mov edx, ecx ; Сохранение максимальной длины строки
    mov al, [esi] ; Образец поиска - первый элемент подстроки

search_next:
    ; Поиск первого элемента подстроки в строке
    repne scasb
    jne not_found

    ; Возврат к первому элементу подстроки
    dec edi

    ; Поиск расхождения с подстрокой
    call cmp_str

    je found

    inc edi

    ; Найдено расхождение
    jmp search_next 

found:
    ; Вычисление позиции
    mov eax, edx
    sub eax, ecx
    dec eax

    jmp search_end

empty_string:
    ; 0 позиция, если подстрока пустая
    xor eax, eax
    mov ecx, 1
    jmp search_end

not_found:
    ; Поиск неудачен
    mov eax, -1

search_end:
    pop esi
    pop edx

    ret

search_substr ENDP

del_substr PROC
; Удаляет подстроку из строки.
; Receives: EDI = адрес первого элемента подстроки,
;           EAX = позиция найденной подстроки,
;           EBX = длина подстроки,
;           ECX = длина строки от начала подстроки.
; Returns:  EDI = адрес отформатированной строки.

    push edi
    push eax
    push ecx

    ; Адрес элемента после подстроки
    lea esi, [edi + ebx]

delete:
    ; Перезапись до конца строки
    lodsb
    stosb

    loop delete

    pop ecx
    pop eax
    pop edi

    ; Получение адреса первого элемента
    sub edi, eax

    ret

del_substr ENDP

main PROC

    Invoke StdOut, ADDR MsgLab

    Invoke StdOut, ADDR FirstStr
    Invoke StdIn, ADDR Str1, LengthOf Str1
    Invoke StripLF, ADDR Str1
    Invoke StdOut, ADDR NextLn

    Invoke StdOut, ADDR SecondStr
    Invoke StdIn, ADDR Str2, LengthOf Str2
    Invoke StripLF, ADDR Str2
    Invoke StdOut, ADDR NextLn

    mov ecx, MaxStr

    lea edi, Str1
    lea esi, Str2

    call search_substr

    cmp eax, 0
    jl not_found_main

    call del_substr

    Invoke dwtoa, eax, ADDR ResStr
    Invoke StdOut, ADDR ResMsg
    Invoke StdOut, ADDR ResStr
    Invoke StdOut, ADDR NextLn

    Invoke StdOut, ADDR DelRes
    Invoke StdOut, edi
    Invoke StdOut, ADDR NextLn

    jmp finish

not_found_main:
    Invoke StdOut, ADDR NotResMsg

finish:
    Invoke StdOut, ADDR MsgExit
    Invoke StdIn, ADDR InBuf, LengthOf InBuf

    Invoke ExitProcess, 0
    
main ENDP

END main