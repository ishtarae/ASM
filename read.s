.section .data

fd:
    .int 0                  # file descriptor se = 0 indica che il file Ordini è stdin

EOR:
    .int 1                  # flag per testare sono alla fine del file per pushare ultimo valore

linefeed:
    .byte 10                # è il valore ascii di "\n" a capo

comma:
    .byte 44                # è il valore ascii di ","

cr:
    .byte 13                # è il valore ascii "\r" carriage return (fine riga)

buffer: 
    .string ""              # Spazio per il buffer di input (salvo l'input temporaneamente)

numvalues:
    .int 0                  # contatore numero prodotti

value:
    .int 0                  # valore temporaneo dove salvare la cifra convertita in integer

value_section:
    .int 0                  # contatore per sapere quale numero della riga stiamo leggendo

msg_err:
    .ascii "Oops, qualcosa è andato storto durante la lettura del file"
msg_err_len:
    .long .-msg_err


.section .bss


.section .text
    .global read

.type read @function

read:

    popl %esi               # salvo l'indirizzo della prox istruzione in ESI

    movl %eax, fd           # Salva il file descriptor in fd (il file descriptor viene salvato di default in eax con la syscall open)
    cmpl $0, %eax
    je Error         

# Utilizziamo la syscall read per leggere dati dal file aperto (fd) nel buffer.

readLoop:
    movl $3, %eax           # syscall read
    movl fd, %ebx           # file descriptor
    movl $buffer, %ecx      # Buffer di input
    movl $1, %edx           # Lunghezza massima
    int $0x80               # interruzione del kernel

    cmpl $0, %eax           # controlla se EOF
    je pushLastValue        # Se EOF inserisce ultimo valore

    cmpl $0, %eax           #controlla se errore
    jl Endread

    # Controlla se ho una nuova linea
    movb buffer, %al        # copia il carattere dal buffer ad AL
    cmpb linefeed, %al      # confronta AL con il carattere "\n"  
    je generalCheck
    
    cmpb comma, %al         # confronta AL con il carattere "," 
    je generalCheck         # se è una "," salto per controllare se il valore in value rispetta i parametri richiesti

    cmpb cr, %al            # confronta AL con il carattere "\r"        in windows a fine di ogni riga /r/n, in Unix-like solo /n
    je readLoop             # se è a fine linea salto per incrementare il numero del prodotti

    movb %al, %bl           # trasferisci cifra ascii da AL in BL per poter usare imul
    xorl %eax, %eax         # azzera registro EAX
    movb value, %al         # copia il valore precedente

    subb $48, %bl           # converti la cifra ascii in intero                                     es "53"=>5          3
    movb $10, %dl           # metti 10 in DL per usare mul                                                                        
    mulb %dl                # moltiplica il contenuto di AL x 10  e salva in AX                     es 0*10 =0          5*10=50
    addb %al, %bl           # somma valore prec con la nuova cifra                                                      50+3=53                                                                                 
    movb %bl, value         # salva il nuovo valore in "value"
    xorl %eax, %eax         # azzera registro EAX

    jmp readLoop            # leggi nuovo char


#controlliamo i parametri dei singoli valori
generalCheck:
    cmp $0, value_section 
    je check_min

    cmp $1, value_section
    je check_min

    cmp $2, value_section
    je check_min
    
    cmp $3, value_section
    je check_min

    jmp Error

#devono essere tutti >=1
check_min:
    cmp $1, value
    jge check_max 

check_max:
    cmp $0, value_section
    je check_ID_max

    cmp $1, value_section
    je check_durata_max

    cmp $2, value_section
    je check_scadenza_max
    
    cmp $3, value_section
    je check_priorita_max


check_ID_max:
    incl value_section      # incrementa contatore della riga
    cmp $127, value
    jle PushValue
    jmp Error

check_durata_max:
    incl value_section
    cmp $10, value
    jle PushValue
    jmp Error

check_scadenza_max:
    incl value_section
    cmp $100, value
    jle PushValue
    jmp Error

check_priorita_max:
    movl $0, value_section  # azzera il contatore della riga
    cmp $5, value
    jle PushValue
    jmp Error

PushValue:
    xorl %eax, %eax         # azzera il registro EAX         
    movl value, %eax        # copia il valore convertito in eax              
    pushl %eax              # inserisci il valore nello stack               
    movl $0, value          # resetta il valore temporaneo                    
    incl numvalues          # incrementa il numero di elementi inseriti nello stack
    
    cmpl $0, EOR            # check se sono a fine file 
    je Endread

    jmp readLoop            # altrimenti ritorna al ciclo di lettura 

pushLastValue:
    movl $0, EOR            # fine file quindi abbassa il flag EOF 
    jmp generalCheck        # check ultimo valore

Error:
    movl $4, %eax                   # syscall write
    movl $2, %ebx                   # file descriptor (stderr)
    leal msg_err, %ecx              # messaggio di errore
    movl msg_err_len, %edx          # lunghezza messaggio
    int $0x80                       # interruzione del kernel
    
    movl $104, %ebx                 # flag di controllo
    jmp Endread

Endread:
    movb numvalues, %al
    pushl %esi              # ESP punta all'indirizzo della prox istruzione

    ret
