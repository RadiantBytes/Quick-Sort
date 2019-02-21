# CS 270 Assignment 6

# This program prompts the user to enter in an int length. This int
# serves to be the length of an array. The user can now enter length
# number of ints into the array, and the program will sort them into
# ascending order
# Date: December 13, 2017
# Author: Thomas Lynaugh
			
		.data
		
 sorted:	.asciiz "Sorted:"
		.align 2

 space:		.asciiz " "
		.align 2
		
 arr:		.space 80

		.text
 main:		addi $v0, $zero, 5		# Prepare to read int
 		syscall
 	 	add  $s0, $v0, $zero		# Set $s0 = user input (len)
 		add  $s1, $zero, $zero 		# i = 0
 		la   $s3, arr			# $s3 = arr
 		
 Loop:  	slt  $t0, $s1, $s0 		# $t0 = (i < len) ? 1:0
 		beq  $t0, $zero, LoopEnd	# !(i < len) -> QckSrt
		addi $v0, $zero, 5		# Prepare to read int
 		syscall
 		add  $s2, $v0, $zero		# Set $s2 = user input (array int)
 		sll  $t0, $s1, 2		# $t0 = i * 4
 		add  $t0, $s3, $t0		# $t0 = arr + (i * 4)]
 		lw   $t2, 0($t0)
 		sw   $s2, 0($t0)		# arr[i] = $s2
 		addi $s1, $s1, 1		# i = i + 1
 		j    Loop			# Repeat Loop
 		
 LoopEnd:	add $a0, $s3, $zero		# $a0 = arr
 		add $a1, $s0, $zero		# $a1 = len
 		jal QckSrt
 
 		la   $a0, sorted		# Set $a0 = addr of sorted
 		addi $v0, $zero, 4		# Prepare to print "Sorted:"
 		syscall
 		
 		add $s1, $zero, $zero		# i = 0
 
 printLoop:	slt  $t0, $s1, $s0 		# $t0 = (i < len) ? 1:0
 		beq  $t0, $zero, printLoopEnd	# (i < len) -> printLoopEnd
 		
 printLoopCnt:	sll  $t0, $s1, 2		# $t0 = i * 4
 		add  $t0, $s3, $t0		# $t0 = arr + i * 4
 		lw   $t1, 0($t0)		# $t1 = arr[i]
 		la   $a0, space			# Set $a0 = addr of space
 		addi $v0, $zero, 4		# Prepare to print " "
 		syscall
 		
 		addi $v0, $zero, 1		# Prepare to print integer
 		add  $a0, $t1, $zero		# Set $a0 = arr[i] to print
 		syscall
 		
 		addi $s1, $s1, 1		# i = i + 1
 		j    printLoop			# Repeat printLoop
 		
 printLoopEnd:	li   $v0, 10
 		syscall
 #-------------------------------------------------------------------------------------
 QckSrt:	addi $sp, $sp, -4		# Space to save registers
 		sw   $ra, 0($sp)		# Save $ra 
 		addi $a2, $a1, -1		# $a2 = len - 1
 		add  $a1, $zero, $zero		# $a1 = 0      
 		jal  QckSrtHlper		# call quick_sort_helper(arr, 0, len - 1)
 		lw   $ra, 0($sp)		# Restore $ra
 		addi $sp, $sp, 4		# Pop stack
 		jr   $ra			# Return to caller
 #----------------------------------------------------------------------------------
 QckSrtHlper:	addi $sp, $sp, -20		# Space to save registers
 		sw   $a0, 16($sp)		# Save $a0 (arr)
 		sw   $a1, 12($sp)		# Save $a1 (left)
 		sw   $a2, 8($sp)		# Save $a2 (right)
 		sw   $s0, 4($sp)		# Save $s0 (index)
 		sw   $ra, 0($sp)		# Save $ra
		jal  Partition			# Jump to Partition
 		lw   $a0, 16($sp)		# Save $a0 (arr)
 		lw   $a1, 12($sp)		# Save $a1 (left)
 		lw   $a2, 8($sp)		# Save $a2 (right)
 		add  $s0, $v0, $zero	        # int index = partition(arr, left, right)
 		addi $t0, $s0, -1		# $t0 = index - 1
 		slt  $t1, $a1, $t0		# $t1 = (left < index - 1) ? 1:0
 		beq  $t1, $zero, Continue	# !(left < index - 1) -> Continue
 		add  $a2, $t0, $zero		# $a2 = index - 1
 		jal  QckSrtHlper		# call QckSrtHlper(arr, left, index - 1)
 		lw   $a0, 16($sp)		# Save $a0 (arr)
 		lw   $a1, 12($sp)		# Save $a1 (left)
 		lw   $a2, 8($sp)		# Save $a2 (right)

  Continue:	slt  $t1, $s0, $a2		# $t1 = (index < right) ? 1:0
 		beq  $t1, $zero, Continue2	# !(index < right) -> Continue2
 		add  $a1, $s0, $zero		# $a1 = index
 		jal  QckSrtHlper		# call QckSrtHlper(arr, index, right)

 Continue2:	lw   $s0, 4($sp)		# Save $s0 (index)
 		lw   $ra, 0($sp)		# Save $ra
 		addi $sp, $sp, 20		# Pop stack
 		jr   $ra			# Return to caller	
#----------------------------------------------------------------------------------------
 Partition:     addi $sp, $sp, -20		# Space to save registers
 		sw   $ra  16($sp)		# Save $ra
 		sw   $s0, 12($sp)		# Save $s0 (pivot)
 		sw   $s1, 8($sp)		# Save $s1 (i)
 		sw   $s2, 4($sp)		# Save $s2 (j)
 		sw   $s3,  0($sp)		# Save $s3 (tmp)
 		add  $s1, $zero, $a1		# $s1 = i i=left
 		add  $s2, $zero, $a2		# $s2 = j j=right
 		add  $t1, $s1, $s2		# $t1 = i + j
 		srl  $t2, $t1, 1		# $t2 = (i + j) / 2
 		sll  $t3, $t2, 2		# $t3 = ((i + j) / 2) * 4
 		add  $t3, $a0, $t3		# $t3 = arr + ((i + j) / 2) * 4
 		lw   $s3, 0($t3)		# pivot = arr[(i + j) / 2]
 		
 WhileOne:	slt $t2, $s2, $s1		# $t2 = (j < i) ? 1:0
 		bne $t2, $zero, WhileEnd	# (i <= j) -> WhileEnd
 		
 WhileTwo: 	sll $t2, $s1, 2			# $t2 = i * 4
 		add $t2, $a0, $t2		# $t2 = arr + (i * 4)
 		lw  $t3 0($t2)			# $t3 = arr[i]
 		slt $t0, $t3, $s3		# $t0 = (arr[i] < pivot) ? 1:0
 		beq $t0, $zero, WhileThree	# !(arr[i] < pivot) -> WhileThree
 		addi $s1, $s1, 1		# i++
 		j    WhileTwo			# Repeat WhileTwo loop
 		
 WhileThree:	sll $t4, $s2, 2			# $t4 = j * 4
 		add $t4, $a0, $t4		# $t4 = arr + (j * 4)
 		lw  $t5, 0($t4)			# $t5 = arr[j]
 		slt $t0, $s3, $t5		# $t0 = (pivot < arr[j]) ? 1:0
 		beq $t0, $zero, ifBlock		# !(pivot < arr[j]) -> ifBlock
 		addi $s2, $s2, -1		# j--
 		j    WhileThree			# Repeat WhileThree loop
 		
 ifBlock:	slt $t0, $s2, $s1		# $t2 = (j < i) ? 1:0
 		bne $t0, $zero, WhileOne	# (i <= j) -> WhileOne
 		add $s3, $zero, $t3		# tmp = arr[i]
 		sw  $t5, 0($t2)			# arr[j] = arr[i]
 		sw  $s3, 0($t4)			# arr[j] = tmp
 		addi $s1, $s1, 1		# i++
 		addi $s2, $s2, -1		# j-- 
 		j    WhileOne			# Jump to WhileOne
 
 WhileEnd:	add  $v0, $zero, $s1		# $v0 = i
 		lw   $s0, 12($sp)		# Save $a0 (arr)
 		lw   $s1, 8($sp)		# Save $a1 (left)
 		lw   $s2, 4($sp)		# Save $a2 (right)
 		lw   $s3, 0($sp)		# Save $s0 (tmp)
 		addi $sp, $sp, 20		# Pop stack
 		jr   $ra			# Return