.data
.word    0

.text
.globl main
main: 
    jal     vbsme_master
    self: j self

.text
.globl  vbsme_master
vbsme_master:

    abuf $zero

    addi $v0, $zero, 0

    lbufa $t0, 0($zero)

    addi $t5, $zero, 0
    addi $t6, $zero, 30

    START:
    lbufa $t1, 0($t5)
    sub $t2, $t1, $t0
    bgez $t2, NOTMIN
        addi $t0, $t1, 0
        addi $v0, $t5, 0
    NOTMIN: 
    addi $t5, $t5, 1
    bne $t5, $t6, START

    lbufb $v1, 0($v0)
    sll $v0, $v0, 1

    srl $t9, $v1, 6
    add $v0, $v0, $t9
    sll $t9, $t9, 6
    sub $v1, $v1, $t9



    jr $ra


   
