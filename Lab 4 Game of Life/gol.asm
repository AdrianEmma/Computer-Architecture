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
    addi sp, zero, CUSTOM_VAR_END
    
    main_loop:
        call reset_game

        ; edgecapture
        call get_input
        addi s0, v0, 0
        
        ; done register
        addi s1, zero, 0

        inner_loop:
            addi a0, s0, 0
            call select_action
        
            addi a0, s0, 0
            call update_state
        
            call update_gsa
        
            call mask
        
            call draw_gsa
        
            call wait
        
            call decrement_step
            addi s1, v0, 0

            call get_input
            addi s0, v0, 0

            beq s1, zero, inner_loop

        jmpi main_loop

test_find:
	addi sp, zero, CUSTOM_VAR_END
	
	call reset_game
	
	addi a0, zero, 0
	addi a1, zero, 4
	call find_neighbours ; -> 1,0

	addi a0, zero, 11
	addi a1, zero, 2
	call find_neighbours ; -> 2,0
	
	addi a0, zero, 11
	addi a1, zero, 0
	call find_neighbours ; -> 3, 1

	addi a0, zero, 0
	addi a1, zero, 7
	call find_neighbours ; -> 2, 0

    addi a0, zero, 2
	addi a1, zero, 6
	call find_neighbours ; -> 3, 1

    addi a0, zero, 9
	addi a1, zero, 6
	call find_neighbours ; -> 0, 0

test_gsa:
	addi sp, zero, CUSTOM_VAR_END
	
	call reset_game
	
	call increment_seed
	
    call pause_game

	call update_gsa
	
	call draw_gsa

test_state:
	call get_input
	addi a0, v0, 0

    addi t0, zero, 3
    stw t0, SEED(zero)

    addi t0, zero, 0
	stw t0, CURR_STATE(zero)

	call update_state

test_seedstepfate:
	addi sp, zero, CUSTOM_VAR_END
	
	addi t0, zero, 1
	stw t0, RANDOM_NUM(zero)

    addi t0, zero, 4
    stw t0, SEED(zero)

    addi t0, zero, 0
    stw t0, CURR_STATE(zero)

    call increment_seed

    addi a0, zero, 4 ; neighbours
    addi a1, zero, 1 ; cell state
    call cell_fate

    addi t0, zero, 2 ;RUN
	stw t0, CURR_STATE(zero)
	addi t0, zero, 3 ; 3 steps left
	stw t0, CURR_STEP(zero)
	call pause_game ; game paused
	call decrement_step	

test_GSA:
    addi sp, zero, CUSTOM_VAR_END
    
    addi a0, zero, 0x00000007
    addi a1, zero, 7
    call set_gsa

    addi a0, zero, 0x00000004
    addi a1, zero, 6
    call set_gsa

    addi a0, zero, 0x00000002
    addi a1, zero, 5
    call set_gsa

    addi a0, zero, 0x000000E0
    addi a1, zero, 3
    call set_gsa

    addi a0, zero, 0x00000080
    addi a1, zero, 2
    call set_gsa

    addi a0, zero, 0x00000043
    addi a1, zero, 1
    call set_gsa

    addi a0, zero, 0x00000003
    addi a1, zero, 0
    call set_gsa

    addi a0, zero, 7
    call get_gsa
    call draw_gsa

test_actions:
    addi t0, zero, 5
    stw t0, SPEED(zero)
    addi a0, zero, 1
    call change_speed
    
    addi sp, zero, CUSTOM_VAR_END
    
    call pause_game
    call pause_game

    addi a0, zero, 1
    addi a1, zero, 0
    addi a2, zero, 1
    call change_steps

    addi a0, zero, 0
    addi a1, zero, 1
    addi a2, zero, 1
    call change_steps

    ldw t0, seed0+12(zero)
	addi t1, zero, seed1
	ldw t2, 8(t1)
	ldw t2, 24(t1)
	addi t2, zero, 5
	slli t2, t2, 2
	addi t2, t2, seed1
	ldw t3, 0(t2)
    
    call increment_seed
    call increment_seed

; BEGIN:clear_leds
clear_leds:
    stw zero, LEDS (zero) ; Store 0 word in LEDS
    addi t0, zero, 4 ; Move to next word-alligned address
    stw zero, LEDS (t0) ; Store 0 word in LEDS+4
    addi t0, t0, 4 ; Move to next word-alligned address
    stw zero, LEDS (t0) ; ; Store 0 word in LEDS+8
    ret
; END:clear_leds

; BEGIN:set_pixel
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
; END:set_pixel

; BEGIN:wait
wait:
    addi t0, zero, 1 ;
    slli t0, t0, 22; Initialize counter 2^19 - for fast run

    ldw t1, SPEED(zero) ; Load the game speed value
    
    loop:
        sub t0, t0, t1 ; Decrement counter with game speed
        bge t0, zero, loop ; if t0 > 0 repeat loop

    ret
; END:wait

; PUSH commands
    ; addi sp, sp, -4
    ; stw s3, 0(sp)

; POP commands
    ; ldw s3, 0(sp)
    ; addi sp, sp, 4


; BEGIN:get_gsa
get_gsa:
    ; GSA0 is 0001 0000 0001 1000
    ; GSA1 is 0001 0000 0011 1000
    ; The 6th bit is alternating between addresses
    ldw t1, GSA_ID(zero) ; Load GSA_ID flag
    slli t1, t1, 5 ; Create mask for 6th bit as above
    ori t2, t1, GSA0 ; Compute the address of selected GSA
    slli a0, a0, 2  ; Word-allign the line coordinate y
    add t2, t2, a0  ; Compute address of correct line

    ldw v0, 0(t2) ; Load the memory line at GSA_line in register v0

    ret ; return to caller function
; END:get_gsa

; BEGIN:set_gsa
set_gsa:
    ; GSA0 is 0001 0000 0001 1000
    ; GSA1 is 0001 0000 0011 1000
    ; The 6th bit is alternating between addresses
    ldw t1, GSA_ID(zero) ; Load GSA_ID flag
    slli t1, t1, 5 ; Create mask for 6th bit as above
    ori t2, t1, GSA0 ; Compute the address of selected GSA
    slli a1, a1, 2  ; Word-allign the line coordinate y
    add t2, t2, a1  ; Compute address of correct line
    
    stw a0, 0(t2) ; Store the value in the memory at GSA_line

    ret
; END:set_gsa


; <-------------------- GSA LED FUNCTIONS ----------------->
; BEGIN:draw_gsa
draw_gsa:
    ; Save s registers - callee saved
    addi sp, sp, -4
    stw s1, 0(sp)
    ; _______________________________


    ; Clear the LEDs completely
    addi sp, sp, -4
    stw ra, 0(sp)
    call clear_leds
    ldw ra, 0(sp)
    addi sp, sp, 4

    addi s1, zero, N_GSA_LINES ; Number of the line to be set

    loop_lines:
        addi s1, s1, -1 ; Decrement line counter
        ; BLOCK: for obtaining the GSA line at coordinate t1
        add a0, zero, s1 ; Pass line as argument for get_gsa()
        
        addi sp, sp, -4
        stw ra, 0(sp) ; PUSH ra
        call get_gsa
        ldw ra, 0(sp) ; POP ra
        addi sp, sp, 4 
        ; GSA line is in register v0
        
        ; Division of line into 3 groups:
        addi t5, zero, 0 ; group counter
        loop_groups:
            ; addi t5, t5, -1 ; Decrement group counter
            ; BIT d:
            andi t3, v0, 0x00000001
            srli v0, v0, 1
            ; BIT c:
            andi t4, v0, 0x00000001
            srli v0, v0, 1
            slli t4, t4, 8
            add t3, t3, t4
            ; BIT b:
            andi t4, v0, 0x00000001
            srli v0, v0, 1
            slli t4, t4, 16
            add t3, t3, t4
            ; BIT a:
            andi t4, v0, 0x00000001
            srli v0, v0, 1
            slli t4, t4, 24
            add t3, t3, t4
            ; Reposition to match LED:
            sll t3, t3, s1

            ; Place word
            slli t6, t5, 2
            ldw t1, LEDS(t6)
            or t3, t3, t1
            stw t3, LEDS (t6)

            addi t5, t5, 1
            addi t7, zero, 3
            bne t5, t7, loop_groups

        bne s1, zero, loop_lines

    ; Restore s registers - callee saved
    ldw s1, 0(sp)
    addi sp, sp, 4
    ; __________________________________
    
    ret
; END:draw_gsa

; BEGIN:random_gsa
random_gsa:
    addi t0, zero, N_GSA_LINES # Initialize row counter

    loop_GSA_rows:
        addi t0, t0, -1 # Decrement row counter

        addi t3, zero, N_GSA_COLUMNS # Initialize column counter

        loop_GSA_columns:
            addi t3, t3, -1 # Decrement column counter

            ldw t4, RANDOM_NUM(zero)
            andi t4, t4, 0x1
            sll t4, t4, t3
            add t5, zero, t4

            bne t3, zero, loop_GSA_columns
        
        # Pass arguments a0, a1 to set_gsa()
        add a0, zero, t5
        add a1, zero, t0

        addi sp, sp, -4
        stw ra, 0(sp) ; PUSH ra
        call set_gsa
        ldw ra, 0(sp) ; POP ra
        addi sp, sp, 4 
        ; New GSA line stored in memory
        
        bne t0, zero, loop_GSA_rows
    ret
; END:random_gsa

; <----------------------- ACTION FUNCTIONS --------------------->
; BEGIN:change_speed
change_speed:
    ldw t0, SPEED(zero) ; load the value of speed
    cmpeq t1, a0, zero ; t1 = a0=0?
    beq t1, zero, decrement ; go to decrement if t1 = 0 

    cmpeqi t2, t0, MAX_SPEED ; t2 = t0=10?
    bne t2, zero, finish ; go to finish if t2 != 0

    addi t0, t0, MIN_SPEED ; increment speed value
    jmpi finish ; go to finish 
    decrement: 
        cmpeqi t3, t0, 1 ; t3 = t0=1?
        bne t3, zero, finish ; go to finish if t3 != 0

        addi t0, t0, -1 ; decrement speed value
    finish:
        stw t0, SPEED(zero) ; store the updated value
        ret
; END:change_speed

; BEGIN:pause_game
pause_game:
    ldw t0, PAUSE(zero)
    xori t0, t0, 0x1
    stw t0, PAUSE(zero)
    ret
; END:pause_game

; BEGIN:change_steps
change_steps:
    ldw t1, CURR_STEP(zero)
    add t0, zero, a2
    slli t0, t0, 4
    add t0, t0, a1
    slli t0, t0, 4
    add t0, t0, a0
    add t1, t1, t0
    stw t1, CURR_STEP(zero)
    ret
; END:change_steps

; BEGIN:increment_seed
increment_seed:
    ldw t0, CURR_STATE(zero) # Load the current state in t0
    ldw t2, SEED(zero)
    cmpeqi t1, t0, INIT # If case t1 = t0=INIT?
    beq t1, zero, random
    
    # IF state INIT and SEED >= N_SEEDS-1
    cmpgei t1, t2, N_SEEDS-1 ; t1 = SEED >= N_SEEDS-1?
    bne t1, zero, random

    # IF state INIT
    addi t2, t2, 1 # Increment game seed
    stw t2, SEED(zero) # Store updated game seed
    
    # Select correct SEED index
    slli t5, t2, 2
    ldw t5, SEEDS(t5)
    
    # Update GSA with new SEED
    addi t3, zero, N_GSA_LINES    
    loop_seed:
        addi t3, t3, -1 # Decrement row counter

        slli t6, t3, 2 # Word-allign row number
        add t6, t6, t5 # Compute SEED address
        ldw t7, 0(t6) # Load the SEED line

        # Pass arguments a0, a1 to set_gsa()
        add a0, zero, t7
        add a1, zero, t3

        addi sp, sp, -4
        stw ra, 0(sp) ; PUSH ra
        call set_gsa
        ldw ra, 0(sp) ; POP ra
        addi sp, sp, 4 
        ; New GSA line stored in memory
        
        bne t3, zero, loop_seed
        
    jmpi endseed # Go to endif

    random:
        addi t2, zero, N_SEEDS
        stw t2, SEED(zero)
        
        # ELSEIF block
        addi sp, sp, -4
        stw ra, 0(sp) ; PUSH ra
        call random_gsa
        ldw ra, 0(sp) ; POP ra
        addi sp, sp, 4

    endseed: 
        ret
; END:increment_seed

; BEGIN:update_state
update_state:
    cmpeq t0, a0, zero ; t0=a0=00000?
    bne t0, zero, endupd ; If a0 = 0 go to endupd
    ldw t1, CURR_STATE(zero) ; store value of current state in t1
    ldw t5, SEED(zero)

    cmpeqi t2, t1, INIT
    bne t2, zero, init_state

    cmpeqi t2, t1, RAND
    bne t2, zero, rand_state

    cmpeqi t2, t1, RUN
    bne t2, zero, run_state

    init_state:
        andi t3, a0, 1 ; obtain value of button 0
        ; ============================================================
        cmpgei t5, t5, N_SEEDS-1 ; b0 been pressed more than N_SEEDS-1 times (3)
        ; ============================================================
        and t3, t3, t5 ; combine conditions
        bne t3, zero, change_state_rand

        andi t3, a0, 2 ; t3 = a0 and t3 -> save the value of button 1 in t3
        bne t3, zero, change_state_run ; go to run if t3 = 1, button 1 is pressed

        # Keep INIT state if transition not needed
        jmpi endupd

    rand_state:
        addi t3, zero, 2 ; create the mask for button 1 value
        and t3, a0, t3 ; t3 = a0 and t3 -> save the value of button 1 in t3
        bne t3, zero, change_state_run ; go to run if t3 = 1, button 1 is pressed
    
        # Keep RAND state otherwise
        jmpi endupd

    run_state:
        addi t3, zero, 8 ; create the mask for button 3 value
        and t3, a0, t3 ; t3 = a0 and t3 -> save the value of button 3 in t3
        bne t3, zero, change_state_init ; go to init if t3 = 1, button 3 is pressed
    
        # Keep RUN state otherwise
        jmpi endupd

    change_state_init:
        addi t4, zero, INIT
        stw t4, CURR_STATE(zero)
        addi sp, sp, -4
        stw ra, 0(sp) ; PUSH ra
        call reset_game
        ldw ra, 0(sp) ; POP ra
        addi sp, sp, 4
        jmpi endupd
        
    change_state_run:
        ; Enable Game RUNNING
        addi t3, zero, RUNNING
        stw t3, PAUSE(zero)

        ; Change current state to 1
        addi t4, zero, RUN
        stw t4, CURR_STATE(zero)
        
        jmpi endupd

    change_state_rand:
        addi t4, zero, RAND
        stw t4, CURR_STATE(zero)
        jmpi endupd

    endupd:
        ret
; END:update_state

; BEGIN:select_action
select_action:
    cmpeq t0, a0, zero ; t0=a0=00000?
    bne t0, zero, endsel ; If a0 = 0 go to endif
    ldw t0, CURR_STATE(zero) ; store value of current state in t1
    
    cmpeqi t1, t0, RUN
    bne t1, zero, run_select

    ### Execute INIT RAND actions
    add t0, zero, a0 # copy value of edgecapture
    andi t1, a0, 0x1 # value of button 0
    srli t0, t0, 2
    bne t1, zero, seed_action

    jmpi step_action # Go to change_steps action

    run_select: ; Select RUN actions
        andi t1, a0, 0x1 # value of button 0
        srli a0, a0, 1
        bne t1, zero, pause_action

        andi t1, a0, 0x1 # value of button 1
        srli a0, a0, 1
        bne t1, zero, inc_action

        andi t1, a0, 0x1 # value of button 2
        srli a0, a0, 2
        bne t1, zero, dec_action

        andi t1, a0, 0x1 # value of button 4
        srli a0, a0, 1
        bne t1, zero, random_action

    seed_action:
        addi sp, sp, -4
        stw ra, 0(sp) ; PUSH ra
        call increment_seed
        ldw ra, 0(sp) ; POP ra
        addi sp, sp, 4  
    jmpi endsel

    step_action:
        # t0 = b4.b3.b2
        # Passing arguments a0, a1, a2
        andi a2, t0, 0x1
        srli t0, t0, 1
        andi a1, t0, 0x1
        srli t0, t0, 1
        andi a0, t0, 0x1

        addi sp, sp, -4
        stw ra, 0(sp) ; PUSH ra
        call change_steps
        ldw ra, 0(sp) ; POP ra
        addi sp, sp, 4 

    jmpi endsel

    pause_action:
        addi sp, sp, -4
        stw ra, 0(sp) ; PUSH ra
        call pause_game
        ldw ra, 0(sp) ; POP ra
        addi sp, sp, 4 
    jmpi endsel

    inc_action:
        addi a0, zero, 0
        addi sp, sp, -4
        stw ra, 0(sp) ; PUSH ra
        call change_speed
        ldw ra, 0(sp) ; POP ra
        addi sp, sp, 4 
    jmpi endsel

    dec_action:
        addi a0, zero, 1
        addi sp, sp, -4
        stw ra, 0(sp) ; PUSH ra
        call change_speed
        ldw ra, 0(sp) ; POP ra
        addi sp, sp, 4 
    jmpi endsel

    random_action:
        addi sp, sp, -4
        stw ra, 0(sp) ; PUSH ra
        call random_gsa
        ldw ra, 0(sp) ; POP ra
        addi sp, sp, 4 
    jmpi endsel

    endsel:
        ret
; END:select_action

; <----------------- UPDATE GSA ------------>
; BEGIN:cell_fate
cell_fate:
    ; Start with same state (overwrite if needed)
    add v0, zero, a1

    ; Check the examined cell state
    cmpeqi t0, a1, 1 ; t0 = a1=1? #Examined cell state
    beq t0, zero, dead_cell # IF cell is dead

    ; IF cell is alive
    cmpltui t0, a0, 2 ; has <2 neighbours
    bne t0, zero, cell_dies

    cmpgeui t0, a0, 4 ; has >=4 neighbours
    bne t0, zero, cell_dies

    jmpi end_fate

    dead_cell:
        cmpeqi t0, a0, 3 ; t0 = a0=3? (neighbours=3?)
        beq t0, zero, end_fate ; Remain dead if not 3 neighbours
        addi v0, zero, 1 ; Make alive if 3 neighbours 
        jmpi end_fate

    cell_dies:
        addi v0, zero, 0

    end_fate:
        ret
; END:cell_fate

; BEGIN:find_neighbours
find_neighbours:
    addi sp, sp, -8
    stw a0, 4(sp) ; keep a copy of x-coordinate on stack
    stw a1, 0(sp) ; keep a copy of y-coordinate on stack

    ; Extract 3 GSA lines needed to operate on
    ; line y-1 -> t0;  line y -> t1; line y+1 -> t2; 
    
    ; Obtain line above current location |> (y-1) mod 8
    addi t0, a1, -1
    andi a0, t0, N_GSA_LINES-1 ; y-1 mod 8 (and 7) as parameter
    
    addi sp, sp, -4
    stw ra, 0(sp) ; PUSH ra
    call get_gsa
    ldw ra, 0(sp) ; POP ra
    addi sp, sp, 4 
    add t0, v0, zero ; Store line y-1 in t0

    ; Obtain line in current location |> y - stored on stack at sp+0
    ldw a0, 0(sp) 
    addi sp, sp, -8
    stw t0, 4(sp); PUSH t0 - ensure line is memorized
    stw ra, 0(sp) ; PUSH ra
    call get_gsa
    ldw ra, 0(sp) ; POP ra
    ldw t0, 4(sp) ; POP t0
    addi sp, sp, 8 
    add t1, v0, zero ; Store line y in t1
    

    ; Obtain line below current location |> (y+1) mod 8 
    ldw a0, 0(sp)
    addi a0, a0, 1
    andi a0, a0, N_GSA_LINES-1 ; y+1 mod 8 (and 7)
    
    addi sp, sp, -12
    stw t1, 8(sp) ; PUSH t1
    stw t0, 4(sp) ; PUSH t0
    stw ra, 0(sp) ; PUSH ra
    call get_gsa
    ldw ra, 0(sp) ; POP ra
    ldw t0, 4(sp) ; POP t0
    ldw t1, 8(sp) ; POP t1
    addi sp, sp, 12 
    add t2, v0, zero ; Store line y+1 in t2

    ; Compute index left and right of current cell
    ldw a0, 4(sp)
    addi t4, a0, 1
    cmpgei t5, t4, N_GSA_COLUMNS
    beq t5, zero, rightbounded
    addi t4, t4, -12 

    rightbounded:
        addi t3, a0, -1
        cmplti t5, t3, 0
        bne t5, zero, addition

    jmpi compute

    addition:
        addi t3, t3, 12
        jmpi compute

    compute:

        ; Initialize living neighbors counter
        addi t7, zero, 0

        ; check({x,y-1})
        srl t5, t0, a0
        andi t5, t5, 0x1
        add t7, t7, t5

        ; compute examined cell state - {x,y}
        srl t5, t1, a0
        andi t5, t5, 0x1
        add v1, zero, t5

        ; check({x,y+1})
        srl t5, t2, a0
        andi t5, t5, 0x1
        add t7, t7, t5

        ; check({x-1,y-1})
        srl t5, t0, t3
        andi t5, t5, 0x1
        add t7, t7, t5
        
        ; check({x-1,y})
        srl t5, t1, t3
        andi t5, t5, 0x1
        add t7, t7, t5

        ; check({x-1,y+1})
        srl t5, t2, t3
        andi t5, t5, 0x1
        add t7, t7, t5

        ; check({x+1,y-1})
        srl t5, t0, t4
        andi t5, t5, 0x1
        add t7, t7, t5
        
        ; check({x+1,y})
        srl t5, t1, t4
        andi t5, t5, 0x1
        add t7, t7, t5

        ; check({x+1,y+1})
        srl t5, t2, t4
        andi t5, t5, 0x1
        add t7, t7, t5

    ; Return result in v0
    addi v0, t7, 0
    addi sp, sp, 8 ; restore stack pointer
    ret
; END:find_neighbours

; BEGIN:update_gsa
update_gsa:
    ; Callee saved registers on stack
    addi sp, sp, -8
    stw s0, 4(sp)
    stw s1, 0(sp)
    ; PUSH

    ldw t0, PAUSE(zero) ; t0=PAUSE
    beq t0, zero, endgsa ; IF PAUSE=0 (game is paused) end
    
    
    ; y-coordinate iterator
    addi s0, zero, N_GSA_LINES

    loop_y:
        ; decrement y-coord
        addi s0, s0, -1

        addi t7, zero, 0
        
        ; x-coordinate iterator
        addi s1, zero, N_GSA_COLUMNS
        loop_x:
            addi s1, s1, -1
            ; cells evaluated one by one
            ; Pass arguments (x,y) to find_neighbours
            addi a0, s1, 0
            addi a1, s0, 0

            ; Call find_neighbours procedure on (x,y)
            addi sp, sp, -8
            stw t7, 4(sp) ; PUSH t7
            stw ra, 0(sp) ; PUSH ra
            call find_neighbours
            ldw ra, 0(sp) ; POP ra
            ldw t7, 4(sp) ; POP t7
            addi sp, sp, 8
            ; Return (living neighbors, state of cell) in (v0,v1)

            ; Pass arguments (living, state) to cell_fate
            addi a0, v0, 0
            addi a1, v1, 0

            ; Call cell_fate procedure for (x,y)
            addi sp, sp, -4
            stw ra, 0(sp) ; PUSH ra
            call cell_fate
            ldw ra, 0(sp) ; POP ra
            addi sp, sp, 4 
            ; Return new cell fate in v0
                
            ; Concatenate new cell fate
            slli t7, t7, 1
            add t7, t7, v0

            bne s1, zero, loop_x

        ; Select the other GSA (flip ID)
        ldw t0, GSA_ID(zero)
        xori t0, t0, 0x1    
        stw t0, GSA_ID(zero)

        ; Pass new line to set_gsa
        addi a0, t7, 0
        addi a1, s0, 0

        ; Call set_gsa
        addi sp, sp, -4
        stw ra, 0(sp) ; PUSH ra
        call set_gsa
        ldw ra, 0(sp) ; POP ra
        addi sp, sp, 4 

        ; Select previous GSA (flip ID back)
        ldw t0, GSA_ID(zero)
        xori t0, t0, 0x1    
        stw t0, GSA_ID(zero)

        bne s0, zero, loop_y

        ; Finally flip the GSA to the new
        ldw t0, GSA_ID(zero)
        xori t0, t0, 0x1    
        stw t0, GSA_ID(zero)

    endgsa:
        ; Callee saved registers on stack
        ldw s1, 0(sp)
        ldw s0, 4(sp)
        addi sp, sp, 8
        ; PUSH
        ret
; END:update_gsa

; BEGIN:mask
mask:
    ldw t0, SEED(zero)
    slli t0, t0, 2
    ldw t4, MASKS(t0)
    
    ; Line iterator
    addi t3, zero, N_GSA_LINES

    loop_mask:
        addi t3, t3, -1

        ; Pass argument to get_gsa
        addi a0, t3, 0

        ; Call get_gsa with line in v0
        addi sp, sp, -4
        stw ra, 0(sp)
        call get_gsa
        ldw ra, 0(sp)
        addi sp, sp, 4
        
        ; Line in found mask
        slli t0, t3, 2
        add t0, t4, t0
        ; Obtain line in mask
        ldw t1, 0(t0)
        ; Pass masked line to set_gsa
        and a0, t1, v0
        ; Pass coordinate to set_gsa
        addi a1, t3, 0
        
        ; Call set_gsa 
        addi sp, sp, -4
        stw ra, 0(sp)
        call set_gsa
        ldw ra, 0(sp)
        addi sp, sp, 4

        bne t3, zero, loop_mask
    ret
; END:mask

; <----------------- INPUT & STEP HANDLERS --------->
; BEGIN:get_input
get_input:
    ldw v0, BUTTONS+4(zero)
    stw zero, BUTTONS+4(zero)
    ret
; END:get_input

; BEGIN:decrement_step
decrement_step:
    ldw t0, CURR_STATE(zero) ; store value of current state in t0
    ldw t1, PAUSE(zero); 1 if game is runnning
    ldw t2, CURR_STEP(zero) ; store  value of steps
    
    cmpeqi t4, t0, RUN ; t4= STATE=RUN?
    and t4, t4, t1 ; STATE=RUN and GAME RUNNING
    bne t4, zero, run_step; IF STATE=RUN and GAME RUNNING

    display: ; Display number of steps on 7SEG
        ; Display unit digit
        andi t4, t2, 0xF
        srli t2, t2, 4
        slli t4, t4, 2
        ldw t5, font_data(t4)
        stw t5, SEVEN_SEGS+12(zero)

        ; Display tens digit
        andi t4, t2, 0xF
        srli t2, t2, 4
        slli t4, t4, 2
        ldw t5, font_data(t4)
        stw t5, SEVEN_SEGS+8(zero)

        ; Display hundreds digit
        andi t4, t2, 0xF
        slli t4, t4, 2
        ldw t5, font_data(t4)
        stw t5, SEVEN_SEGS+4(zero)

        # Return value 0
        addi v0, zero, 0

        jmpi endstep

    run_step:
        cmpeqi t3, t2, 0 ; t3= STEPS=0?
        bne t3, zero, done

        addi t2, t2, -1
        stw t2, CURR_STEP(zero)
        jmpi display

    done: ; No steps left to execute
        addi v0, zero, 1
        jmpi endstep
    
    endstep:
        ret

    
; END:decrement_step


; <--------------- RESET --------->
; BEGIN:reset_game
reset_game:
    ; Initialize current step to 1
    addi t0, zero, 1
    stw t0, CURR_STEP(zero)
    
    ; Initialize step display
    ldw t1, font_data(zero) ; font of digit 0
    ldw t2, font_data+4(zero) ; font of digit 1
    stw t1, SEVEN_SEGS+4(zero)
    stw t1, SEVEN_SEGS+8(zero)
    stw t2, SEVEN_SEGS+12(zero)
    
    ; Initialize seed with value 0
    stw zero, SEED(zero)
    
    ; Initialize GSA_ID to 0 to store SEED0
    stw zero, GSA_ID(zero)
    
    ; Initialize GSA with SEED0
    # Update GSA with new SEED
    addi t3, zero, N_GSA_LINES    
    loop_seed0:
        addi t3, t3, -1 # Decrement row counter
        slli t6, t3, 2 # Word-allign row number
        addi t6, t6, seed0 # Compute SEED address
        ldw t7, 0(t6) # Load the SEED line

        # Pass arguments a0, a1 to set_gsa()
        add a0, zero, t7
        add a1, zero, t3

        addi sp, sp, -4
        stw ra, 0(sp) ; PUSH ra
        call set_gsa
        ldw ra, 0(sp) ; POP ra
        addi sp, sp, 4 
        ; New GSA line stored in memory
        
        bne t3, zero, loop_seed0

    ; Draw Seed0 on LEDS
    addi sp, sp, -4
    stw ra, 0(sp) ; PUSH ra
    call draw_gsa
    ldw ra, 0(sp) ; POP ra
    addi sp, sp, 4

    ; Initialize STATE and PAUSE with 0
    stw zero, CURR_STATE(zero) ; Initial state is INIT = 0
    stw zero, PAUSE(zero) ; PAUSED=0 stored in RAM

    ; Initialize SPEED with 1
    addi t0, zero, MIN_SPEED ; MIN_SPEED=1
    stw t0, SPEED(zero)
    ret
; END:reset_game

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
