.section .data
    numprod: .int 0
    S: .int 0                  # indice per puntare a scadenza 
    Ssucc: .int 0              # indice per puntare a scadenza successiva
    MAX: .int 0                
    i: .int 0                  # indice for esterno
    j: .int 0                  # indice for interno

.section .text
    .global EDF
    .type EDF, @function

EDF:
    popl %esi               # sposto indirizzo successivo alla call in ESI
    
    movb $4, %dl
    divb %dl
    movb %al, numprod
   
    #inizializzo indici
    movl numprod, %eax
    subl $1, %eax
    movl %eax, MAX

    #resetto indice          
    movl $-1, i

for_esterno:                # ordinamento Bubble
    incl i
    movl i, %eax
    cmpl %eax, MAX
    je fine
    movl $4, S              # indice scadenza piu in alto nella pila
    movl $20, Ssucc
    movl $0, j 
for_interno:
    
    movl j, %eax
    cmpl %eax, MAX
    je for_esterno 

if:
    #confronta dato S con dato Ssucc
    movl S, %eax
    movl Ssucc, %ebx
    movl (%esp, %eax), %ecx
    movl (%esp, %ebx), %edx
    cmpl %ecx, %edx             # se S < Ssucc 
    jg scambia

    cmpl %ecx, %edx             # se Psucc = P testo quale scade prima
    je testa_priority

    incl j
    addl $16, S                 # per puntare alla priorita prodotto successivo (piu in alto nello stack)
    addl $16, Ssucc
    jmp for_interno

testa_priority:
    movl S, %eax
    subl $4, %eax
    movl Ssucc, %ebx
    subl $4, %ebx
    movl (%esp, %eax), %ecx     # priorita piu in alto nella pila
    movl (%esp, %ebx), %edx     # priorita piu in basso nella pila

    cmpl %edx, %ecx             # se P > Psucc swap
    jge scambia

    incl j
    addl $16, S
    addl $16, Ssucc
    jmp for_interno

scambia:
    # sottraggo prima di 4 S e Ssucc per poter puntare a Priorita e poi scalo
    movl S, %eax
    subl $4, %eax
    movl Ssucc, %ebx
    subl $4, %ebx

    # Scambia priorità
    movl (%esp, %eax), %ecx
    movl (%esp, %ebx), %edx
    movl %edx, (%esp, %eax)
    movl %ecx, (%esp, %ebx)

    # Scambia scadenza
    addl $4, %eax
    addl $4, %ebx
    movl (%esp, %eax), %ecx
    movl (%esp, %ebx), %edx
    movl %edx, (%esp, %eax)
    movl %ecx, (%esp, %ebx)

    # Scambia durata
    addl $4, %eax
    addl $4, %ebx
    movl (%esp, %eax), %ecx
    movl (%esp, %ebx), %edx
    movl %edx, (%esp, %eax)
    movl %ecx, (%esp, %ebx)

    # Scambia ID
    addl $4, %eax
    addl $4, %ebx
    movl (%esp, %eax), %ecx
    movl (%esp, %ebx), %edx
    movl %edx, (%esp, %eax)
    movl %ecx, (%esp, %ebx)
    
    jmp for_interno

fine:
    push %esi           # repusha indirizzo prox operazione nello stack
    ret
   