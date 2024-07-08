# Il software dovrà essere eseguito mediante la seguente linea di comando:
# pianificatore <percorso del file degli ordini>
# più specificatamente: ./bin/pianificatore <Ordini/nomefile.txt>

.section .data
scegli_alg:
    .ascii "\nScegli il tipo di algoritmo: digita 1 per EDF o 2 per HPF.\nDigita q per terminare il programma\n"      
scegli_alg_len:
    .long .-scegli_alg

algEDF:
    .ascii "1"              # se l'utente sceglie l'algoritmo EDF
algHPF:                     # se l'utente sceglie l'algoritmo HPF
    .ascii "2"
quit:
    .ascii "q"              # se l'utente sceglie di uscire
frase_EDF:
    .ascii "Pianificazione EDF:"
frase_EDF_len:
    .long .-frase_EDF
frase_HPF:
    .ascii "Pianificazione HPF:"
frase_HPF_len:
    .long .-frase_HPF
duepunti:
    .ascii ":"
duepunti_len:
    .long .-duepunti
acapo:
    .ascii "\n"
acapo_len:
    .long .-acapo

filede:                     # variabile per salvare il file descriptor
    .int 0
argc:
    .int 0                  # per salvare il numero di argomenti
numelem:
    .int 0
numprod:                    
    .int 0                  # per salvare il numero di prodotti 

start:
    .int 0                  # per salvare e stampare l'unità di tempo in cui inizia la prod. di un prodotto
penalty:
    .int 0                  # per salvare la penalty
i:
    .int 0                  # indice per puntare a ID 
d:
    .int 0                  # indice per putnare alla durata
s:
    .int 0                  # indice per puntare a scadenza
p:
    .int 0                  # indice per puntare a penalita 

frase_conclusione:
    .ascii "Conclusione: "  # per stampare "conclusione" alla fine
frase_conclusione_len:
    .long .-frase_conclusione

frase_penalty:
    .ascii "Penalty: "      # per stampare "penalty" alla fine  
frase_penalty_len:
    .long .-frase_penalty

msg_error_open:
    .ascii "\nErrore: impossibile aprire il file.\n\n"
msg_error_open_len:
    .long .-msg_error_open

msg_error:
    .ascii "\nOops, qualcosa è andato storto\n\n"
msg_error_len:
    .long .-msg_error


.section .bss

algoritmo:
    .ascii ""               # utente inserisce "1" "2" o "q" 


.section .text
    .global _start

_start:                     
                            # num argomenti, parametro 1 (pianificatore) e parametro 2 (<Ordini/nomefile.txt>) sono inseriti nello stack dopo aver eseguito sul terminal il programma
                            #scartiamo i primi due argomenti per eseguire <Ordini/nomefile.txt> e poter leggere il file
    popl %esi               # salva il 1. parametro dello stack (num arg) in ESI (per poi scartarlo)
    
    #gestione degli errori
    movl %esi, argc
    cmpb $2, argc           # controlla se gli argomenti nello stack sono 2 
    jne Error                # se non sono 2 salta a Error

    popl %esi               # salva il 1. argomento il nome del programma (pianificatore) in ESI (per scartarlo)

    popl %esi               # salva il 2. argomento (1. parametro) (<Ordini/nomefile.txt>) in ESI
    testl %esi, %esi	    # controlla se ESI e' 0 (NULL)
	jz Error                 # se non e' stato fornito un parametro salta a Error


    #syscall open file
    movl $5, %eax           # syscall open 
    movl %esi, %ebx         # nome del file da aprire
    movl $0, %ecx           # modalità di apertura (O_RDONLY)
    int $0x80               # interruzione del kernel

    cmp $0, %eax
    jl ErrorOpen            # se %eax < 0, c'è stato un errore
    
    movl %eax, filede       # il file descriptor che è in EAX viene salvato in filede
    call read               # chiama la fzn Read per leggere il file
    movb %al, numelem       # copia il num. di singoli elementi salvato in EAX (in read) in numelementi    NON FUNZIONA; SALVA 1 in meno
    
    cmpl $105, %ebx         # flag per controllare se ci sono stati errori nella lettura del file 
    je CloseFile


SceltaAlg:

    #stampa messaggio di richesta scelta algoritmo
    movl $4, %eax                   # syscall write
    movl $1, %ebx                   # file descriptor (stdout)
    leal scegli_alg, %ecx           # messaggio di richesta scelta algoritmo
    movl scegli_alg_len, %edx       # lunghezza messaggio
    int $0x80                       # interruzione del kernel

    xorl %ecx, %ecx                 # azzero registro ECX per poter inserire l'input senza errori

    #legge la scelta dell'algoritmo
    movl $3, %eax                   # syscall read
    movl $0, %ebx                   # file descriptor (stdin)
    leal algoritmo, %ecx            # salvo in "algoritmo"
    movl $2, %edx                   # Lunghezza massima ($2 e non $1 per \n)
    int $0x80                       # interruzione del kernel

    movb algEDF, %al
    movb algHPF, %bl
    movb quit, %cl

    movb algoritmo, %dl  # solo per cotrollo debug

    #confronta l'input 
    cmpb %al, algoritmo
    je _algoritmo_EDF

    cmpb %bl, algoritmo
    je _algoritmo_HPF

    cmpb %cl, algoritmo
    je CloseFile

    jmp SceltaAlg                      # se non si e' digitato 1  2 o q esce con errore 

_algoritmo_EDF:
    xorl %eax, %eax
    movb numelem, %al
    call EDF
    
    #stampa "\n"
    movl $4, %eax			# syscall WRITE 
	movl $1, %ebx			# terminale
	leal acapo, %ecx  		# carico l'indirizzo della stringa "acapo"
	movl acapo_len, %edx	# lunghezza della stringa
	int $0x80				# eseguo la syscall

    #stampa frase scelta edf
    movl $4, %eax			 
	movl $1, %ebx			
	leal frase_EDF, %ecx  		
	movl frase_EDF_len, %edx	
	int $0x80				
    
    jmp init_ciclo_stampa


_algoritmo_HPF:
    xorl %eax, %eax
    movb numelem, %al 
    call HPF
    
    #stampa "\n"
    movl $4, %eax			# syscall WRITE 
	movl $1, %ebx			# terminale
	leal acapo, %ecx  		# carico l'indirizzo della stringa "acapo"
	movl acapo_len, %edx	# lunghezza della stringa
	int $0x80				# eseguo la syscall

    #stampa frase scelta hpf
    movl $4, %eax			 
	movl $1, %ebx			
	leal frase_HPF, %ecx  		
	movl frase_HPF_len, %edx	
	int $0x80				
    
    jmp init_ciclo_stampa


init_ciclo_stampa:
    
    #resetto indici e variabili varie in caso di restart 
    movl $0, i
    movl $0, d
    movl $0, s
    movl $0, p
    movl $0, start
    movl $0, penalty
    
    #resetto il numero di prodotti al numero originale (numprod viene usato come contatore)
    movb numelem, %al
    movb $4, %dl
    divb %dl
    movb %al, numprod      # numero di prodotti: numelem /4       


    #inizializzo indici
    #calcola numero di celle
    movl numprod, %eax
    movl $16, %edx
    mull %edx               # moltiplico il numero di prodotti x 4  num elementi per prodotto x 4 byte per prodotto -> numprod*16
    
    subl $4, %eax
    movl %eax, i            # indice per ID

    subl $4, %eax           # prima durata : cella sopra primo ID
    movl %eax, d            # indice durata

    subl $4, %eax           # prima scadenza: cella sopra prima durata
    movl %eax, s            # salva in indice per scadenza s

    subl $4, %eax
    movl %eax, p            # indice priorita'

ciclo_stampa:
    
    #stampa "\n"
    movl $4, %eax			# syscall WRITE 
	movl $1, %ebx			# terminale
	leal acapo, %ecx  		# carico l'indirizzo della stringa "acapo"
	movl acapo_len, %edx	# lunghezza della stringa
	int $0x80				# eseguo la syscall

    #stampa ID
    movl i, %ebx            # sposto indice in EBX
    movl (%esp, %ebx), %eax # add EBX a ESP (indirizzo) per puntare a  i celle più in basso (ID) e salva contenuto in %eax
    subl $16, %ebx          # sottraggo 16 per puntare a ID successivo 
    movl %ebx, i            # salvo prossimo indice ID "i"
    subl $160, %esp         # sposta ESP in alto (spazio riservato nello stack per itoa per non trascrivere) numprod.max X numval.each X 4Byte 10x4x4
    call itoa               # chiama itoa per convertire in ascii e stampare cio' che c'e' in itoa
    addl $160, %esp         # ripristina ESP pre itoa
                 
    #stampa ":"
    xorl %eax, %eax
    xorl %ebx, %ebx
    movl $4, %eax			 
	movl $1, %ebx			
	leal duepunti, %ecx  		
	movl duepunti_len, %edx	
	int $0x80				

    #stampa Inizio produzione
    xorl %eax, %eax
    movl start, %eax        # salvo start in EAX    
    subl $160, %esp         # spazio riservato per itoa numprod.max X numval.each X 4Byte 10x4x4= 160
    call itoa
    addl $160, %esp         # ripristina ESP
        
    movl d, %ebx                # sposto indice durata in EBX 
    movl (%esp, %ebx), %eax     # add EBX a ESP (indirizzo) per puntare alla cella piu' in alto di ID (durata) e salva contenuto in %eax
    movl start, %ecx
    addl %eax, %ecx             
    movl %ecx, start            # salvo prossimo Inizio (aka durata di produzione del prodotto corrente) in "start"
    
    subl $16, %ebx              # sottrae 16 a EBX (4 celle piu' su)
    movl %ebx, d                # salvo prossimo indice in d per il prossimo ciclo

    #per confrontare scadenza e durata
    xorl %ecx, %ecx
    movl s, %ecx
    movl (%esp, %ecx), %ebx         # carica scadenza in EBX
    movl start, %eax                # carica durata in EAX
    cmpl %ebx, %eax                 # confronta EAX > EBX ?  cmp scadenza, durata 
    jg sum_penalty                  # se il tempo di prod. supera scadenza salta a sum_penalty per calcolo penlita' 

    #incrementa contatore scadenza
    xorl %ebx, %ebx
    movl s, %ebx
    subl $16, %ebx
    movl %ebx, s
    #incrementa contatore penalita'
    xorl %ebx, %ebx
    movl p, %ebx
    subl $16, %ebx
    movl %ebx, p

    decl numprod
    cmpl $0, numprod
    je fine_stampa
    jmp ciclo_stampa


sum_penalty:
    subl %ebx, %eax                     # sottrae durata (in EAX) da scadenza (in EBX) e salva in EAX
    movl p, %ecx                        
    movl (%esp, %ecx), %edx             # carica penalita in EDX
    imull %edx                          # moltiplica risultato prec x priorita 
    movl penalty, %ebx
    addl %eax, %ebx
    movl %ebx, penalty

    #incrementa contatore scadenza
    xorl %ebx, %ebx
    movl s, %ebx
    subl $16, %ebx
    movl %ebx, s
    #incrementa contatore penalita'
    xorl %ebx, %ebx
    movl p, %ebx
    subl $16, %ebx
    movl %ebx, p

    decl numprod
    cmpl $0, numprod
    je fine_stampa
    jmp ciclo_stampa


            
# STAMPA DI DURATA E PENALTY (ultime due righe)
fine_stampa:

    #stampa "\n"
    movl $4, %eax			# syscall WRITE 
	movl $1, %ebx			# terminale
	leal acapo, %ecx  		# carico l'indirizzo della stringa "acapo"
	movl acapo_len, %edx	# lunghezza della stringa
	int $0x80				# eseguo la syscall

    #stampa frase "Conclusione: "
    movl $4, %eax			 
	movl $1, %ebx			
	leal frase_conclusione, %ecx  		
	movl frase_conclusione_len, %edx	
	int $0x80				

    #stampa la cifra conclusione
    movl start, %eax
    subl $160, %esp         
    call itoa
    addl $160, %esp         # ripristina ESP

    #stampa "\n"
    movl $4, %eax			# syscall WRITE 
	movl $1, %ebx			# terminale
	leal acapo, %ecx  		# carico l'indirizzo della stringa "acapo"
	movl acapo_len, %edx	# lunghezza della stringa
	int $0x80				# eseguo la syscall

    #stampa frase "Penalty: "
    movl $4, %eax			 
	movl $1, %ebx			
	leal frase_penalty, %ecx  		
	movl frase_penalty_len, %edx	
	int $0x80		

    # stampa cifra penalty
    movl penalty, %eax
    subl $160, %esp         
    call itoa
    addl $160, %esp         # ripristina ESP

    #stampa "\n"
    movl $4, %eax			# syscall WRITE 
	movl $1, %ebx			# terminale
	leal acapo, %ecx  		# carico l'indirizzo della stringa "acapo"
	movl acapo_len, %edx	# lunghezza della stringa
	int $0x80				# eseguo la syscall
    
    jmp SceltaAlg

CloseFile:
# Syscall per chiudere il file
    mov $6, %eax            # syscall close
    mov filede, %ecx        # File descriptor
    int $0x80               # Interruzione del kernel
    
    jmp pre_scarica_pila


# MESSAGGI DI ERRORE VARI
ErrorOpen:
#stampa il messaggio di errore apertura file e arresta il programma
    movl $4, %eax                   # syscall write
    movl $2, %ebx                   # file descriptor (stderr)
    leal msg_error_open, %ecx       # messaggio di errore
    movl msg_error_open_len, %edx   # lunghezza messaggio
    int $0x80                       # interruzione del kernel
    
    jmp pre_scarica_pila

Error:
#stampa il messaggio di errore
    movl $4, %eax                   # syscall write
    movl $2, %ebx                   # file descriptor (stderr)
    leal msg_error, %ecx            # messaggio di errore
    movl msg_error_len, %edx        # lunghezza messaggio
    int $0x80                       # interruzione del kernel

    jmp pre_scarica_pila

ErrorOpenedFile:                    # in caso di errore quando il file e' gia' aperto
#stampa il messaggio di errore
    movl $4, %eax                   # syscall write
    movl $2, %ebx                   # file descriptor (stderr)
    leal msg_error, %ecx            # messaggio di errore
    movl msg_error_len, %edx        # lunghezza messaggio
    int $0x80                       # interruzione del kernel

    jmp CloseFile


pre_scarica_pila:
    movl numelem, %eax              #inserisco il numero di elementi in eax
scarica_pila:    
    cmpl $0, %eax
    je Exit
    popl %ebx
    decl %eax
    jmp scarica_pila 


Exit:
# Terminiamo il programma
    movl $1, %eax                   # syscall exit
    xorl %ebx, %ebx                 # exit code 0
    int $0x80                       # interruzione del kernel
