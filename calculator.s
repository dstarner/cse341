# Daniel Starner
# dcstarne

# TODO:
# So currently, the address for where to store the answer is stored in s6, and we have the location for
# EXPR[i] after "=", so I need to start going through the expression. After the expression is pushed
# to the stack in the correct order, it will all work

.globl main
.globl set_A_as_answer_reg
.globl set_B_as_answer_reg
.globl set_C_as_answer_reg
.globl set_D_as_answer_reg
.globl set_E_as_answer_reg
.globl finish_setting_answer
.globl begin_evalutation_expr
.globl increment_on_space
.globl iterate_expr_loop
.globl handle_first_operation_to_stack
.globl handle_modulus
.globl handle_mult
.globl handle_div
.globl wipe_operator
.globl cont_iterate_expr_loop
.globl get_left_of_oper
.globl left_A_oper
.globl left_B_oper
.globl left_C_oper
.globl left_D_oper
.globl left_E_oper
.globl left_X_oper
.globl left_num_oper
.globl cont_left_of_oper
.globl get_right_of_oper
.globl right_A_oper
.globl right_B_oper
.globl right_C_oper
.globl right_D_oper
.globl right_E_oper
.globl right_X_oper
.globl right_num_oper
.globl cont_right_of_oper
.globl reverse_begin_evalutation_expr
.globl decrement_on_space
.globl reverse_iterate_expr_loop
.globl handle_second_operation_to_stack
.globl handle_add
.globl handle_sub
.globl reverse_wipe_operator
.globl cont_reverse_iterate_expr_loop
.globl increment_on_space_search
.globl search_for_remaining
.globl search_A
.globl search_B
.globl search_C
.globl search_D
.globl search_E
.globl search_X
.globl operation_loop
.globl pushAToStack
.globl pushBToStack
.globl pushCToStack
.globl pushDToStack
.globl pushEToStack
.globl pushToStack
.globl popFromStack
.globl clear_w_space
.globl clear_w_x
.globl find_start_of_int
.globl find_start_loop
.globl exit_find_loop
.globl build_int
.globl build_int_loop
.globl exit_build_loop
.globl addition
.globl subtraction
.globl multiply
.globl mult_loop
.globl modulus
.globl division               # a0 / a1
.globl end_divis
.globl exit                   # Exit the system

.data
a: .half 10
b: .half 5
c: .half 4
d: .half 2
e: .half 10
exp: .asciiz "e := 3 * b"

# Project Outline:

.text
main:


  lui $s0, 4096                    # $s0 holds address to expression
  ori  $16, $s0, 10

  addi $s1, $0, 0               # i = 0 for s1  (EXPR[i])

###
# 1. Set up where to store answer, remove "x := " with spaces
###

  # Compute address of string[0]
  add $t1, $s0, $s1           # $t2 = address of EXPR[i]
  lb  $t2, 0($t1)             # Get the byte at EXPR[i]
  addi $0, $0, 0

  addi $1, $0, 97                   # The next 4 lines will pick what address to store the final answer into
  beq $1, $10, set_A_as_answer_reg
  addi $1, $0, 98
  beq $1, $10, set_B_as_answer_reg
  addi $1, $0, 99
  beq $1, $10, set_C_as_answer_reg
  addi $1, $0, 100
  beq $1, $10, set_D_as_answer_reg
  addi $1, $0, 101
  beq $1, $10, set_E_as_answer_reg
  addi $0, $0, 0

####
# All of the "set_*_as_answer_reg"s are complete and set s6 to the address of where to save answer
####

set_A_as_answer_reg:
  lui $1, 4096
  ori $22, $1, 0
  j finish_setting_answer
  addi $0, $0, 0

set_B_as_answer_reg:
  lui $1, 4096
  ori $22, $1, 2
  j finish_setting_answer
  addi $0, $0, 0

set_C_as_answer_reg:
  lui $1, 4096
  ori $22, $1, 4
  j finish_setting_answer
  addi $0, $0, 0

set_D_as_answer_reg:
  lui $1, 4096
  ori $22, $1, 6
  j finish_setting_answer
  addi $0, $0, 0

set_E_as_answer_reg:
  lui $1, 4096
  ori $22, $1, 8
  j finish_setting_answer
  addi $0, $0, 0


finish_setting_answer:         # Once we have where to store the answer, we loop until 'i'
  add $t1, $s0, $s1            # is after the '='
  lb $t2, 0($t1)
  addi $0, $0, 0

  addi $a0, $t1, 0
  jal clear_w_space
  addi $0, $0, 0

  addi $s1, $s1, 1

  addi $1, $0, 61             # If t2 == 63
  bne $1, $10, finish_setting_answer

  addi $0, $0, 0
  j begin_evalutation_expr
  addi $0, $0, 0

###
# 2. Solve multiplication/division/modulus, store to right side value
###
# s0 --> Word address
# s1 --> Index we want
# t1 --> Address of index
# t2 --> byte value at index t1
# t3 --> value of (expr[i] * 2 + s5) -- to test what to do

begin_evalutation_expr:       # Set up variables for looping
  j iterate_expr_loop         # s5 = 1 --> Look for mult/division/modulus
  addi $0, $0, 0

increment_on_space:
  addi $s1, $s1, 1

iterate_expr_loop:
  # Compute address of string[i]
  add $t1, $s0, $s1
  lb  $t2, 0($t1)             # Get the byte at EXPR[i] and store to $t2
  addi $0, $0, 0

  addi $1, $0, 32             # If EXPR[i] is a space, just increment the index
  beq $1, $10, increment_on_space
  addi $0, $0, 0

  beq $t2, $0, reverse_begin_evalutation_expr     # test if for loop is done if EXPR[i] == 0
  addi $0, $0, 0

  # All my branches below
  addi $1, $0, 37             # first op to stack
  beq $1, $10, handle_first_operation_to_stack
  addi $0, $0, 0

  addi $1, $0, 42             # first op to stack
  beq $1, $10, handle_first_operation_to_stack
  addi $0, $0, 0

  addi $1, $0, 47             # first op to stack
  beq $1, $10, handle_first_operation_to_stack
  addi $0, $0, 0

  j cont_iterate_expr_loop
  addi $0, $0, 0


handle_first_operation_to_stack:
  addi $t4, $0, 0
  add $t4, $s0, $s1

  jal get_left_of_oper        # Get left of operator to a0
  addi $0, $0, 0

  addi $s7, $v0, 0

  addi $t4, $0, 0
  add $t4, $s0, $s1

  jal get_right_of_oper       # Get right of operatior to a1, store to the letter there
  addi $0, $0, 0

  addi $a1, $v0, 0
  addi $a0, $s7, 0

  addi $1, $0, 37             # modulus
  beq $1, $10, handle_modulus
  addi $1, $0, 42             # mult
  beq $1, $10, handle_mult
  addi $1, $0, 47             # div
  beq $1, $10, handle_div
  addi $0, $0, 0

  j cont_iterate_expr_loop
  addi $0, $0, 0

handle_modulus:
  addi $v0, $0, 0
  jal modulus
  addi $0, $0, 0
  j wipe_operator
  addi $0, $0, 0

handle_mult:
  addi $v0, $0, 0
  jal multiply
  addi $0, $0, 0
  j wipe_operator
  addi $0, $0, 0

handle_div:
  addi $v0, $0, 0
  jal division
  addi $0, $0, 0
  j wipe_operator
  addi $0, $0, 0

wipe_operator:
  addi $a0, $t1, 0             # Clear the operator and replace with X
  jal clear_w_x
  addi $0, $0, 0
  addi $a0, $v0, 0              # Push the result to the stack
  jal pushToStack
  addi $0, $0, 0

cont_iterate_expr_loop:

  addi $s1, $s1, 1             # i++
  j iterate_expr_loop
  addi $0, $0, 0


# Below -- $t4 gets the scoped index
#       -- $t2 gets number
#       -- $t5 holds return
# Find the next valid number, push to stack, replace number with space
get_left_of_oper:
  addi $t5, $ra, 0
  addi $t4, $t4, -1
  lb  $t6, 0($t4)             # Get the byte at EXPR[i] and store to $t2
  addi $0, $0, 0

  addi $1, $0, 32
  beq $1, $14, get_left_of_oper
  addi $1, $0, 97
  beq $1, $14, left_A_oper
  addi $1, $0, 98
  beq $1, $14, left_B_oper
  addi $1, $0, 99
  beq $1, $14, left_C_oper
  addi $1, $0, 100
  beq $1, $14, left_D_oper
  addi $1, $0, 101
  beq $1, $14, left_E_oper
  addi $1, $0, 88
  beq $1, $14, left_X_oper
  addi $0, $0, 0

  addi $s4, $0, 58            # Next few lines check if in digit range
  slt $t8, $t6, $s4
  addi $s4, $0, 47
  slt $t9, $s4, $t6
  and $t9, $t9, $t9
  addi $1, $0, 1
  beq $1, $25, left_num_oper

  addi $0, $0, 0


left_A_oper:
  lui $1, 4096
  lb $2, 0($1)
  addi $0, $0, 0
  j cont_left_of_oper
  addi $0, $0, 0

left_B_oper:
  lui $1, 4096
  lb $2, 2($1)
  addi $0, $0, 0
  j cont_left_of_oper
  addi $0, $0, 0

left_C_oper:
    lui $1, 4096
  lb $2, 4($1)
  addi $0, $0, 0
  j cont_left_of_oper
  addi $0, $0, 0

left_D_oper:
  lui $1, 4096
  lb $2, 6($1)
  addi $0, $0, 0
  j cont_left_of_oper
  addi $0, $0, 0

left_E_oper:
  lui $1, 4096
  lb $2, 8($1)
  addi $0, $0, 0
  j cont_left_of_oper
  addi $0, $0, 0

left_X_oper:
  jal popFromStack
  addi $0, $0, 0
  j cont_left_of_oper
  addi $0, $0, 0

left_num_oper:
  addi $a0, $t4, 0
  jal find_start_of_int
  addi $0, $0, 0
  addi $a0, $v0, 0
  jal build_int
  addi $0, $0, 0


cont_left_of_oper:
  addi $a0, $t4, 0
  jal clear_w_space
  addi $0, $0, 0
  jr $t5
  addi $0, $0, 0


get_right_of_oper:
  addi $t5, $ra, 0
  addi $t4, $t4, 1
  lb  $t6, 0($t4)             # Get the byte at EXPR[i] and store to $t2
  addi $0, $0, 0
  addi $1, $0, 32
  beq $1, $14, get_right_of_oper
  addi $1, $0, 97
  beq $1, $14, right_A_oper
  addi $1, $0, 98
  beq $1, $14, right_B_oper
  addi $1, $0, 99
  beq $1, $14, right_C_oper
  addi $1, $0, 100
  beq $1, $14, right_D_oper
  addi $1, $0, 101
  beq $1, $14, right_E_oper
  addi $1, $0, 88
  beq $1, $14, right_X_oper
  addi $0, $0, 0

  addi $s4, $0, 58            # Next few lines check if in digit range
  slt $t8, $t6, $s4
  addi $s4, $0, 47
  slt $t9, $s4, $t6
  and $t9, $t9, $t9
  addi $1, $0, 1
  beq $t9, $1, right_num_oper
  addi $0, $0, 0

right_A_oper:
  lui $1, 4096
  lb $2, 0($1)
  addi $0, $0, 0
  j cont_right_of_oper
  addi $0, $0, 0

right_B_oper:
  lui $1, 4096
  lb $2, 2($1)
  addi $0, $0, 0
  j cont_right_of_oper
  addi $0, $0, 0

right_C_oper:
  lui $1, 4096
  lb $2, 4($1)
  addi $0, $0, 0
  j cont_right_of_oper
  addi $0, $0, 0

right_D_oper:
  lui $1, 4096
  lb $2, 6($1)
  addi $0, $0, 0
  j cont_right_of_oper
  addi $0, $0, 0

right_E_oper:
  lui $1, 4096
  lb $2, 8($1)
  addi $0, $0, 0
  j cont_right_of_oper
  addi $0, $0, 0

right_X_oper:
  jal popFromStack
  addi $0, $0, 0
  j cont_right_of_oper
  addi $0, $0, 0

right_num_oper:
  addi $a0, $t4, 0
  jal find_start_of_int
  addi $0, $0, 0
  addi $a0, $v0, 0
  jal build_int
  addi $0, $0, 0

cont_right_of_oper:
  addi $a0, $t4, 0
  jal clear_w_space
  addi $0, $0, 0
  jr $t5
  addi $0, $0, 0

#
# 3. Go through reverse and do additions/subtractions
#

# s0 --> Word address
# s1 --> Index we want
# t1 --> Address of index
# t2 --> byte value at index t1
# t3 --> value of (expr[i] * 2 + s5) -- to test what to do

reverse_begin_evalutation_expr:       # Set up variables for looping
  j reverse_iterate_expr_loop         # s5 = 1 --> Look for mult/division/modulus
  addi $0, $0, 0

decrement_on_space:
  addi $s1, $s1, -1

reverse_iterate_expr_loop:
  # Compute address of string[i]
  add $t1, $s0, $s1
  lb  $t2, 0($t1)             # Get the byte at EXPR[i] and store to $t2
  addi $0, $0, 0

  beq $s1, $0, search_for_remaining   # test if for loop is done if i == 0
  addi $1, $0, 32
  beq $10, $1, decrement_on_space  # If EXPR[i] is a space, just increment the index

  # All my branches below
  addi $1, $0, 43
  beq $10, $1, handle_second_operation_to_stack
  addi $1, $0, 45
  beq $10, $1, handle_second_operation_to_stack
  addi $0, $0, 0
  j cont_reverse_iterate_expr_loop
  addi $0, $0, 0


handle_second_operation_to_stack:
  addi $t4, $0, 0
  add $t4, $s0, $s1
  jal get_left_of_oper        # Get left of operator to a0
  addi $0, $0, 0
  addi $s7, $v0, 0

  addi $t4, $0, 0
  add $t4, $s0, $s1
  jal get_right_of_oper       # Get right of operatior to a1, store to the letter there
  addi $0, $0, 0
  addi $a1, $v0, 0
  addi $a0, $s7, 0

  addi $1, $0, 43
  beq $10, $1, handle_add
  addi $1, $0, 45
  beq $10, $1, handle_sub
  addi $0, $0, 0

  j cont_reverse_iterate_expr_loop
  addi $0, $0, 0

handle_add:
  addi $v0, $0, 0
  jal addition
  addi $0, $0, 0
  j reverse_wipe_operator
  addi $0, $0, 0

handle_sub:
  addi $v0, $0, 0
  jal subtraction
  addi $0, $0, 0
  j reverse_wipe_operator
  addi $0, $0, 0

reverse_wipe_operator:
  addi $a0, $t1, 0             # Clear the operator and replace with X
  jal clear_w_x
  addi $0, $0, 0
  addi $a0, $v0, 0              # Push the result to the stack
  jal pushToStack
  addi $0, $0, 0

cont_reverse_iterate_expr_loop:

  addi $s1, $s1, -1             # i--
  j reverse_iterate_expr_loop
  addi $0, $0, 0

###
# 3. ONCE EVERYTHING IS ON THE STACK
###

increment_on_space_search:
  addi $s1, $s1, 1

search_for_remaining:
  # Compute address of string[i]
  add $t1, $s0, $s1
  lb  $t2, 0($t1)             # Get the byte at EXPR[i] and store to $t2
  addi $0, $0, 0

  beq $t2, $0, operation_loop   # test if for loop is done if i == 0
  addi $1, $0, 32
  beq $10, $1, increment_on_space_search  # If EXPR[i] is a space, just increment the index

  addi $1, $0, 97
  beq $10, $1, search_A
  addi $1, $0, 98
  beq $10, $1, search_B
  addi $1, $0, 99
  beq $10, $1, search_C
  addi $1, $0, 100
  beq $10, $1, search_D
  addi $1, $0, 101
  beq $10, $1, search_E
  addi $1, $0, 88
  beq $10, $1, search_X
  addi $0, $0, 0

  addi $a0, $t1, 0
  jal build_int
  addi $0, $0, 0

  j operation_loop



search_A:
  lui $1, 4096
  lb $2, 0($1)
  addi $0, $0, 0
  j operation_loop
  addi $0, $0, 0

search_B:
  lui $1, 4096
  lb $2, 2($1)
  addi $0, $0, 0
  j operation_loop
  addi $0, $0, 0

search_C:
  lui $1, 4096
  lb $2, 4($1)
  addi $0, $0, 0
  j operation_loop
  addi $0, $0, 0

search_D:
  lui $1, 4096
  lb $2, 6($1)
  addi $0, $0, 0
  j operation_loop
  addi $0, $0, 0

search_E:
  lui $1, 4096
  lb $2, 8($1)
  addi $0, $0, 0
  j operation_loop
  addi $0, $0, 0

search_X:
  jal popFromStack
  addi $0, $0, 0
  j operation_loop
  addi $0, $0, 0



operation_loop:
  sh $v0, 0($s6)                # Store the final value in the stack to the mem address in s6
                                # Which is the address of the .data we want
  addi $s1, $v0, 0

  j exit		  # Exit at the end of the program
  addi $0, $0, 0

# END OF PROGRAM













###
### EVERYTHING BELOW HERE IS CALLED, NOT HIT NATURALLY
###
pushAToStack:
  lui $1, 4096
  lb $4, 0($1)
  addi $sp, $sp, -4       # Decrement stack pointer by 4
  sh   $a0, 0($sp)        # Save $a0 to stack
  jr $ra

pushBToStack:
  lui $1, 4096
  lb $4, 2($1)
  addi $sp, $sp, -4       # Decrement stack pointer by 4
  sh   $a0, 0($sp)        # Save $a0 to stack
  jr $ra

pushCToStack:
  lui $1, 4096
  lb $4, 4($1)
  addi $sp, $sp, -4       # Decrement stack pointer by 4
  sh   $a0, 0($sp)        # Save $a0 to stack
  jr $ra

pushDToStack:
  lui $1, 4096
  lb $4, 6($1)
  addi $sp, $sp, -4       # Decrement stack pointer by 4
  sh   $a0, 0($sp)        # Save $a0 to stack
  jr $ra

pushEToStack:
  lui $1, 4096
  lb $4, 8($1)
  addi $sp, $sp, -4       # Decrement stack pointer by 4
  sh   $a0, 0($sp)        # Save $a0 to stack
  jr $ra

pushToStack:              # Push $a0 to stack as a word
  addi $sp, $sp, -4       # Decrement stack pointer by 4
  sh   $a0, 0($sp)        # Save $a0 to stack
  jr $ra

popFromStack:             # Get top of stack and save to v0
  lw   $v0, 0($sp)        # Copy from stack to $v0
  addi $sp, $sp, 4        # Increment stack pointer by 4
  jr $ra

clear_w_space:                 # Replace whatever is 0(t1) and change to space
  addi $a1, $0, 32             # Dummy register to hold 32 (space char)
  sb $a1, 0($a0)               # Set to space
  jr $ra

clear_w_x:                 # Replace whatever is 0(t1) and change to space
  addi $a1, $0, 88             # Dummy register to hold 32 (space char)
  sb $a1, 0($a0)               # Set to space
  jr $ra
  addi $0, $0, 0


# a0 is end of int
# v0 will be the address of start
find_start_of_int:
  add $v0, $a0, 0
  add $v1, $0, 0

  find_start_loop:
    addi $v0, $v0, -1
    lb $v1, ($v0)
    addi $0, $0, 0
    slti $1, $3, 58
    beq $1, $0, exit_find_loop     # Not a number

    addi $1, $3, -1                # Not a number
    slti $1, $1, 47
    bne $1, $0, exit_find_loop

    addi $0, $0, 0

    j find_start_loop

  exit_find_loop:
    addi $v0, $v0, 1
    addi $v1, $0, 0
    jr $ra
    addi $0, $0, 0




# $a0 is start of int
# v0 will be the integer
build_int:
  addi $s2, $ra, 0    # ra goes into t5
  addi $a3, $a0, 0     # a3 will hold the address
  addi $t7, $0, 0      # t7 will hold running number

  build_int_loop:
    lb $a1, ($a3)
    addi $0, $0, 0

    slti $1, $5, 58
    beq $1, $0, exit_build_loop     # Not a number

    addi $1, $5, -1                # Not a number
    slti $1, $1, 47
    bne $1, $0, exit_build_loop

    addi $0, $0, 0

    addi $t9, $a1, 0
    addi $a1, $0, 10

    # So we have a running sum in t7, and current digit in t9
    addi $a0, $t7, 0
    jal multiply         # Running sum by 10.
    addi $0, $0, 0
    addi $t7, $v0, 0     # Put back into t7
    addi $t9, $t9, -48   # Subtract '0' from ascii value
    add $t7, $t7, $t9   # Add current digit to t7

    addi $a0, $a3, 0
    jal clear_w_space

    addi $a3, $a3, 1
    addi $0, $0, 0
    j build_int_loop
    addi $0, $0, 0


  exit_build_loop:
    addi $v0, $t7, 0
    addi $a3, $0, 0
    addi $t7, $0, 0
    addi $a1, $0, 0
    addi $a0, $0, 0
    jr $s2
    addi $0, $0, 0


###### HELPER ROUTINES ######

## Addition ##
addition:                 # Add $a0 and $a1, store it into v0
  add $v0, $a0, $a1
  jr $ra                  # Jump back to spot in program
## End Addition ##


## Subtraction ##
subtraction: 		  # Subtract $a1 from $a0 and store into $v0
  sub $v0, $a0, $a1
  jr $ra
## End subtraction ##


## Multiplication ##
multiply:                 # Multiply $a0 by $a1 and store into $v0
  addi $a2, $0, 1	  # a2 = counter
  addi $v0, $0, 0	  # v0 = running sum (product)
mult_loop:
  add $v0, $v0, $a0	  # Add $a0 to $v0
  addi $a2, $a2, 1	  # Increment Count

  # Loop till complete
  slt $1, $5, $6
  beq $1, $0, mult_loop
  jr $ra
## End Multiplication ##

## Division/Modulus ##
modulus:
  addi $t7, $ra, 0        # Let's not lose ra when we do jal division
  jal division            # Call division
  addi $v0, $v1, 0        # Set the remainder to v0
  addi $ra, $a2, 0        # Set ra and a2 back to normal
  addi $a2, $0, 0
  jr $t7

division:                    # a0 / a1
  slt $7, $4, $5             # checks if $a0 > $a1
  ori $1, $0, 1
  subu $7, $1, $7

  beq $a3, $zero, end_divis  # if first number < second number, break

  sub $a0, $a0, $a1          # subtract $a1 from $a0
  addi $v0, $v0, 1           # add one to counter
  j division                 # loop

end_divis:
  add $v1, $0, $a0           # Remainder in v1, Quotient in v0
  jr $ra
## End Modulus


exit:                   # Exit the system
  addiu $2, $0, 10
  syscall		# call operating sys
