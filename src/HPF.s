.section .data
    numprod: .int 0
    P: .int 0                  # indice per puntare a priorita 
    Psucc: .int 0              # indice per puntare a priorita successiva
    MAX: .int 0                
    i: .int 0                  # indice for esterno
    j: .int 0                  # indice for interno

.section .text
    .global HPF
    .type HPF, @function

HPF:
    popl %esi               # sposto indirizzo successivo alla call in ESI
    
    movb $4, %dl
    divb %dl
    movb %al, numprod

    #inizializzo indici
    movl numprod, %eax
    subl $1, %eax
    movl %eax, MAX

    #azzero indice
    movl $-1, i

for_esterno:                # ordinamento Bubble
    incl i
    movl i, %eax
    cmpl %eax, MAX
    je fine
    movl $0, P              # indice priorita' più in alto nella pila 
    movl $16, Psucc
    movl $0, j 
for_interno:
    
    movl j, %eax
    cmpl %eax, MAX
    je for_esterno

if:
    #confronta dato P con dato Psucc
    movl P, %eax
    movl Psucc, %ebx
    movl (%esp, %eax), %ecx
    movl (%esp, %ebx), %edx
    cmpl %ecx, %edx             # se P > Psucc 
    jl scambia
    
    cmpl %ecx, %edx             # se Psucc = P testo quale scade prima
    je testa_scadenza
    
    incl j
    addl $16, P                 # per puntare alla priorita prodotto successivo (piu in alto nello stack)
    addl $16, Psucc
    jmp for_interno

testa_scadenza:
    movl P, %eax
    addl $4, %eax
    movl Psucc, %ebx
    addl $4, %ebx
    movl (%esp, %eax), %ecx     # scadenza piu in alto nella pila
    movl (%esp, %ebx), %edx     # scadenza piu in basso nella pila

    cmpl %edx, %ecx
    jle scambia

    incl j
    addl $16, P
    addl $16, Psucc
    jmp for_interno


scambia:
    movl P, %eax
    movl Psucc, %ebx

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
