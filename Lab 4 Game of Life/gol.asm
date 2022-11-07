    ;;    game state memory location
    .equ CURR_STATE, 0x1000              ; current game state
    .equ GSA_ID, 0x1004                  ; gsa currently in use for drawing
    .equ PAUSE, 0x1008                   ; is the game paused or running
    .equ SPEED, 0x100C                   ; game speed
    .equ CURR_STEP,  0x1010              ; game current step
    .equ SEED, 0x1014                    ; game seed
    .equ GSA0, 0x1018                    ; GSA0 starting address
    .equ GSA1, 0x1038                    ; GSA1 starting address
    .equ SEVEN_SEGS, 0x1198              ; 7-segment display addresses
    .equ CUSTOM_VAR_START, 0x1200        ; Free range of addresses for custom variable definition
    .equ CUSTOM_VAR_END, 0x1300
    .equ LEDS, 0x2000                    ; LED address
    .equ RANDOM_NUM, 0x2010              ; Random number generator address
    .equ BUTTONS, 0x2030                 ; Buttons addresses

    ;; states
    .equ INIT, 0
    .equ RAND, 1
    .equ RUN, 2

    ;; constants
    .equ N_SEEDS, 4                     ; number of available seeds
    .equ N_GSA_LINES, 8                 ; number of gsa lines
    .equ N_GSA_COLUMNS, 12              ; number of gsa columns
    .equ MAX_SPEED, 10                  ; maximum speed
    .equ MIN_SPEED, 1                   ; minimum speed
    .equ PAUSED, 0x00                   ; game paused value
    .equ RUNNING, 0x01                  ; game running value

main:
    ;; TODO


; BEGIN: clear_leds
clear_leds:
    stw zero, LEDS (zero) ; Store 0 word in LEDS
    addi t0, zero, 4 ; Move to next word-alligned address
    stw zero, LEDS (t0) ; Store 0 word in LEDS+4
    addi t0, t0, 4 ; Move to next word-alligned address
    stw zero, LEDS (t0) ; ; Store 0 word in LEDS+8
    ret
; END: clear_leds

; BEGIN: set_pixel
set_pixel:
    srli t0, a0, 2 ; t0 = a0 / 4 - Set the LED group number
    slli t0, t0, 2 ; Set the address in memory for the LED

    slli t1, a0, 30
    srli t1, t1, 30 ; t1 = a0 % 4 - Set the LED group column

    slli t2, t1, 3 ; t2 = t1 * 8
    add t2, t2, a1 ; t2 = t2 + a1 - Set the specific bit to turn on

    addi t3, zero, 1 ; t3 = 0x00000001 - Create the register to shift
    sll t3, t3, t2 ; t3 = t3 << t2 - Create the mask for the LED

    ldw t4, LEDS(t0) ; Load the value from the LED
    or t4, t4, t3 ; t4 = t4 or t3 - Apply the mask to the value of the LED

    stw t4, LEDS(t0) ; Turn on the pixel in the LED

    ret
; END: set_pixel

; BEGIN: wait
wait:
    addi t0, zero, 1 ;
    slli t0, t0, 19 ; Initialize counter 2^19

    ldw t1, SPEED(zero) ; Load the game speed value
    
    loop:
        sub t0, t0, t1 ; Decrement counter with game speed
        bge t0, zero, loop ; 

    ret

; END: wait

font_data:
    .word 0xFC ; 0
    .word 0x60 ; 1
    .word 0xDA ; 2
    .word 0xF2 ; 3
    .word 0x66 ; 4
    .word 0xB6 ; 5
    .word 0xBE ; 6
    .word 0xE0 ; 7
    .word 0xFE ; 8
    .word 0xF6 ; 9
    .word 0xEE ; A
    .word 0x3E ; B
    .word 0x9C ; C
    .word 0x7A ; D
    .word 0x9E ; E
    .word 0x8E ; F

seed0:
    .word 0xC00
    .word 0xC00
    .word 0x000
    .word 0x060
    .word 0x0A0
    .word 0x0C6
    .word 0x006
    .word 0x000

seed1:
    .word 0x000
    .word 0x000
    .word 0x05C
    .word 0x040
    .word 0x240
    .word 0x200
    .word 0x20E
    .word 0x000

seed2:
    .word 0x000
    .word 0x010
    .word 0x020
    .word 0x038
    .word 0x000
    .word 0x000
    .word 0x000
    .word 0x000

seed3:
    .word 0x000
    .word 0x000
    .word 0x090
    .word 0x008
    .word 0x088
    .word 0x078
    .word 0x000
    .word 0x000

    ;; Predefined seeds
SEEDS:
    .word seed0
    .word seed1
    .word seed2
    .word seed3

mask0:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF

mask1:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x1FF
	.word 0x1FF
	.word 0x1FF

mask2:
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF

mask3:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

mask4:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

MASKS:
    .word mask0
    .word mask1
    .word mask2
    .word mask3
    .word mask4
