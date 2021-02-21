* Get_prefix
* if prefix is empyy, get it with an online call
* with last drive used.
cout        equ $FDED
MLI         equ $bf00
getprefix   equ $c7
online      equ $c5
setprefix   equ $c6
open        equ $c8
close       equ $cc
prntx       equ $F944
pfbuffer    equ $5000
fbuff       equ $5200
devnum      equ $BF30   ; last used device here, format : DSSS0000 
*
*
********** Macros **********
print   MAC            ; dispaly string with 0 at the end
        ldx #$00       
boucle  lda ]1,X
        beq endprnt
        ora #$80       ; normal
        jsr cout
        inx
        bra boucle
endprnt EOM 

print1  MAC
        cr
        lda #]1
        jsr cout
        cr
        EOM
*
cr      MAC
        lda #$8D
        jsr cout
        EOM

DoPrefix MAC
        jsr  MLI        ; GET PREFIX
        dfb getprefix
        da c7_parms
        bcs dpend      ; error  : exit
        print gpOK
        ldx pfbuffer    ; get length       
        bne dpend      ; prefix already set : rts
        print1 "E"
        lda devnum      ; prefix empty : call online
        sta c5_parms+1  ; with last used device 
        * 
        jsr MLI         ; ONLINE
        dfb online
        da  c5_parms
        bcs dpend      ; error  : exit
        print olOK
        *
        * adjust prefix for set prefix call
        lda pfbuffer    ; get length of prefix
        and #$0F        ; in lower nibble
        tax             ; in x      
        tay             ; saved in y
        inx             ; +1 for /
looppf  lda pfbuffer,y   ; shift string 1 char. right
        sta pfbuffer+1,y
        dey
        bne looppf
        lda #$2f        ; add  "/" 
        sta pfbuffer+1  ; before prefix 
        stx pfbuffer    ; length first 
        jsr MLI         ; SET PREFIX
        dfb setprefix
        da  c6_parms
        bcs dpend      ; error  : exit 
        print spOK       
dpend   nop
        EOM

DoClose MAC
        lda #]1
        sta cc_parms+1
        jsr MLI
        dfb close
        da  cc_parms
        EOM



***************************
*
        org $4000
        DoPrefix  
        bcc OK
        jmp error
OK      jsr doopen
        DoClose 0
        bcc endmain
        jmp error
endmain rts
*
doopen  nop
        jsr MLI         ; OPEN
        dfb open
        da  c8_parms
        bcs error
        print openOK
        rts
*
error   pha  
        cr
        print err
        pla
        tax
        jsr prntx 
        cr
        rts
*        
************** DATA **************
*
c5_parms                ; online
    hex 02
    hex 00
    da  pfbuffer

c6_parms                ; set_prefix
    hex 01
    da pfbuffer


c7_parms                ; get_prefix
    hex 01
    da pfbuffer

c8_parms                
    hex 03
pth da fname
    da fbuff
ref hex 00

cc_parms
    hex 01
    hex 00


err asc "I/O Error : "
    hex 00

fname   str "GPOL"
        hex 00

pfok    asc "PREFIX already set."
        hex 00

isempty asc "PREFIX is empty."
        hex 00

gpOK    asc "Get prefix MLI call : OK."
        hex 8D00
olOK    asc "Online MLI call : OK."
        hex 8D00
openOK  asc "Open file : OK."
        hex 00
spOK    asc "Set prefix OK."
        hex 00