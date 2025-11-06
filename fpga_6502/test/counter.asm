.6502

.org 0xF800
start:
  cld
  lda #0x00 
  sta $10 ; initialize counter to 0
loop:
  lda $A001 ; read UART status register
  and #0x02  ; check if TX ready
  beq loop    ; if not ready, txready bit is 0, wait until the bit is set

  lda $10   ; load counter value
  sta $A000 ; send to UART TX data register
  sta $C000 ; send to leds
  inc $10  ; increment counter

  lda #0x20 ; load delay value
  ldy #0x00 
  ldx #0x00
delay:
  dex
  bne delay
  dey
  bne delay
  dec
  bne delay ; simple delay loop, nr of cycles is calculated as: 3 * 256 * delay_value + 3 * 256 + 4????
  nop
  jmp loop
  
  .org $fffc
  dw start
  dw $0000  
