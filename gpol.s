* Get_prefix
* if prefix is empyy, get it with an online call
* with last drive used.
cout        equ $FDED
MLI         equ $bf00
getprefix   equ $c7
online      equ $c5
prntx       equ $F944
buffer      equ $300
buffer1     equ $5000
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
*
cr      MAC
        lda #$8D
        jsr cout
        EOM
***************************
*
        org $4000
        jsr  MLI
        dfb getprefix
        da c7_parms
        bcs error
        print gpOK
        ldx buffer
        beq empty       ; empty prefix ?
        print pfok      ; no : message 
        rts             ; and exit
        *
empty   nop
        print isempty
        lda devnum      ; yes : call online
        sta c5_parms+1  ; this is the trick  
        jsr    MLI
        dfb online
        da  c5_parms
        bcs error
        cr
        print olOK
        lda buffer1
        and #$0F
        tax
        inx             ; for "/"
        lda #$2f        ; = "/"
        sta buffer1     ; before prefix
        ldy #$00
prnpfx  lda buffer1,y   ; display /prefix
        ora #$80
        jsr cout
        iny
        dex 
        bne prnpfx
suite   rts
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
c7_parms
    hex 01
    da buffer

c5_parms
    hex 02
    hex 00
    da  buffer1

err asc "I/O Error : "

pfok    asc "PREFIX already set."
        hex 00

isempty asc "PREFIX is empty."
        hex 00

gpOK    asc "Get prefix MLI call : OK."
        hex 8D00
olOK    asc "Online MLI call : OK."
        hex 8D00