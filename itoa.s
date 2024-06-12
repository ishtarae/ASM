.section .data
car: .byte 0                # Variabile per memorizzare il carattere corrente

.section .text
    .global itoa

.type itoa, @function       # Dichiarazione della funzione itoa

itoa:
movl $0, %ecx               # Azzera %ecx, usato come contatore

continua_a_dividere:
cmpl $10, %eax              # Confronta %eax con 10
jl fine_divisione           # Se %eax < 10, salta a fine_divisione

dividi:
movl $0, %edx               # Azzera %edx
movl $10, %ebx              # Carica 10 in %ebx
divl %ebx                   # Divide %eax per 10, il quoziente va in %eax e il resto in %edx
pushl %edx                  # Salva il resto (cifra corrente) nello stack
incl %ecx                   # Incrementa il contatore delle cifre
jmp continua_a_dividere     # Ripete il ciclo

fine_divisione:
pushl %eax                  # Salva l'ultima cifra (ora %eax < 10)
incl %ecx                   # Incrementa il contatore delle cifre
    movl %ecx, %ebx

stampa:
cmpl $0, %ebx               # Controlla se ci sono ancora caratteri da stampare
je fine_itoa                # Se %ecx è 0, fine della funzione
popl %eax                   # Preleva una cifra dallo stack
movb %al, car	            # Converte la cifra in carattere ASCII
addb $48, car               # Memorizza il carattere in car
decl %ebx                   # Decrementa il contatore delle cifre
pushw %bx                   # Salva %bx nello stack (non necessario ma per sicurezza)

movl $4, %eax               # Syscall number for sys_write
movl $1, %ebx               # File descriptor 1 (stdout)
leal car, %ecx              # Carica l'indirizzo di car in %ecx
movl $1, %edx               # Numero di byte da scrivere
int $0x80                   # Chiamata al sistema
popw %bx                    # Ripristina %bx

jmp stampa                  # Continua a stampare le cifre

fine_itoa:
ret                         # Ritorna dalla funzione
