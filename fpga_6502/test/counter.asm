.6502

.org 0x8000
start:
  cld
  lda #0x00
loop:
  adc #0x01
  sta $6000
  ldy #0xFF
delay_loop2:
  ldx #0xFF
delay_loop:
  dex
  bne delay_loop
  dey
  bne delay_loop2
  JMP loop

  
