# TITLE : PROJECT COMPUTER ARCHTECTCHRE 
# AUTHOR : MOHAMAD ALHAJJAH 1170580
# DISCRIPTION :         Implement the learning algorithm of single layer neural networks (Perceptron) with momentum and 
#               adaptive learning rates using MIPS assembly language. The program will ask the user to enter the name
#               of the training file and the initial values of the parameters (weights, momentum, learning rate,
#               thresholds, number of epochs…). The program must print the value of the error, weights, thresholds,
#               and learning rate after each iteration. 

# INPUT: weights, momentum, learning rate,thresholds, number of epochs
# OUTPUT: error, weights, thresholds and learning rate after each iteration
##############################    DATA SEGMANT    #############################
.data
x1 : .space 16
x2 : .space 16
y : .space 16
numStore: .space 4
file : .asciiz  "training.csv"
buffer: .space 1
epoch : .float 0
nstart : .float 1
nfinal : .float 4
constant : .float 1
constant0 : .float 0
str1: .asciiz "\ninsert the name of the training file:\n"
weight1 : .asciiz "insert the intial value of w1:\n"
weight2 : .asciiz "insert the intial value of w2:\n"
momentum : .asciiz "insert the intial value of the momentum:\n"
alpha : .asciiz "insert the intial vlaue of the learning rate(alpha):\n"
threshold : .asciiz "insert the intial vlue of the threshold:\n"
epochf : .asciiz "insert the number of epochs you want to do:\n "
newLine : .asciiz "\n"
space : .asciiz "\t\t"
space2 : .asciiz "\t"
newEpoch : .asciiz "\n--------------------------------------------------------------------------------\n"
title : .asciiz "y\t\terror\t\tw1\tw2\t\tthreshold\tlearning rate\n "
constant4: .byte 4

##############################    CODE SEGMANT    #############################
.text
.globl main
main:
##################### TAKE INTIAL INPUTS FROM THE USER #####################

#take the intial vlue of w1
    li $v0,4       # code 4 == print string
    la $a0,weight1  # $a0 == address of the string
    syscall             # Ask the operating system to 
    li $v0,6         #read float fromthe user
    syscall  
    mov.s $f6, $f0   #w1 in $f6
    
#take the intial vlue of w2      
    li $v0,4       # code 4 == print string
    la $a0,weight2  # $a0 == address of the string
    syscall             # Ask the operating system to 
    li $v0,6
    syscall  
    mov.s $f7, $f0  #w2 in $f7
    
#take the intial value of the momentum
    li $v0,4       # code 4 == print string
    la $a0,momentum  # $a0 == address of the string
    syscall             # Ask the operating system to 
    li $v0,6
    syscall  
    mov.s $f19, $f0
    
#take the intial vlue of the learning rate (alpha)
    li $v0,4       # code 4 == print string
    la $a0,alpha  # $a0 == address of the string
    syscall             # Ask the operating system to 
    li $v0,6
    syscall  
    mov.s $f9, $f0
    
#take the intial value of the threshold
    li $v0,4       # code 4 == print string
    la $a0,threshold  # $a0 == address of the string
    syscall             # Ask the operating system to 
    li $v0,6
    syscall  
    mov.s $f8, $f0

#take the number of epochs 
    li $v0,4       # code 4 == print string
    la $a0,epochf  # $a0 == address of the string
    syscall             # Ask the operating system to 
    li $v0,6
    syscall  
    mov.s $f4, $f0  
    
####################### OPEN AND READ DATA FROM FILE STORE IN IN THE BUFFERS IN DATA SEGMENT #########################    

# open file to read x1,x2,y
    li $v0 ,13     
    la $a0, file 
    li $a1, 0      # read flag
    li $a2,0      # ignore mode 
    syscall       # open file 
    move $s0,$v0  # save the file descriptor 

 #read table of number and save it in x1,x2,y
    li $s3 0 
    la $s1 buffer  
     
readInputs:
#convert int to float in x1
    jal readInteger
    la $s7, numStore
    lw $t0, ($s7)
    mtc1 $t0, $f0
    cvt.s.w $f0 $f0
    
#read data and store it in x1
    la $s7, x1
    s.s $f0,x1($t3)
    
#convert int to float in x2
    jal readInteger
    la $s7, numStore
    lw $t0, ($s7)
    mtc1 $t0, $f0
    cvt.s.w $f0 $f0
    
#read data and store it in x2
    la $s7, x2
    s.s $f0,x2($t3)
    

#convert data to float y
    jal readInteger
    la $s7, numStore
    lw $t0, ($s7)
    mtc1 $t0, $f0
    cvt.s.w $f0 $f0
    
#store data in y
    la $s7, y
    s.s $f0,y($t3)
    addi $t3,$t3,4
    addi $s3, $s3, 1
    
#check if t1 = 5 -> read is done
    li $t1,5
    beq $s5,$t1,CloseFile
    b readInputs
 
#close file after finish       
CloseFile:

    li $v0 16     
    move $a0 $s0  
    syscall       
     

#load some values from buffers    
    l.s $f22,epoch
    l.s $f1,constant0
    l.s $f2,nstart  
    l.s $f3,nfinal
    l.s $f5,constant    
    
    li $v0,4       # code 4 == print string
    la $a0,title  # the titles of our input
    syscall         # Ask the operating system to 
    
###################### THE ALGORETHIM IS WORKING HERE ##########################
loop1:
    c.eq.s  $f22,$f4
    bc1t exit
#define the index of our array t0 and to change the idex we use t1    
    addi $t0,$zero,0
    addi $t1,$zero,0
    l.s $f2,nstart
    add.s $f22,$f22,$f5
loop2:
    c.eq.s $f3,$f2   
    
#bring each element of x1 , x2 and y and put it on a registers    
     addi $t0,$t1,0 #index of the array
    l.s $f10,x1($t0)
     addi $t0,$t1,0 #index of the array
    l.s $f11,x2($t0)
     addi $t0,$t1,0 #index of the array
    l.s $f13,y($t0)
    addi $t1,$t1,4
    
#equation of the y actual y act = step((w1*x1+w2*x2)-th)    
    mul.s $f14,$f10,$f6   #w1*x1
    mul.s $f15,$f11,$f7   #w2*x2
    add.s $f16,$f14,$f15  #w1*x1 + w2*x2
    sub.s $f17,$f16,$f8   #(w1*x1+w2*x2)-th
#for unit step function when zero and when  1( step((w1*x1+w2*x2)-th) )
    c.le.s $f17,$f1 
    bc1t step0 
#make y actual 1 if the y is more than 0 
    mul.s $f17,$f17,$f1
    add.s $f17,$f17,$f5
    c.eq.s $f1,$f1
#continue our loop after make the y actual comlpetly    
step1 :   
#error = y desired ($f13)- y actual ($f17)
    sub.s  $f18,$f13,$f17  #f18 the error
    c.eq.s $f18,$f1
    bc1f changeWeight
continue:

    li $v0,4       # code 4 == print string
    la $a0,newLine  # $a0 == address of the string
    syscall             # Ask the operating system to 
# print the output yact in each iteration    
    c.eq.s $f3,$f2
    mov.s $f12,$f17
    li $v0 ,2
    syscall
    
    li $v0,4       # code 4 == print string
    la $a0,space  # $a0 == address of the string
    syscall             # Ask the operating system to 
    
# print the output error in each iteration    
    mov.s $f12,$f18
    li $v0 ,2
    syscall
    
    li $v0,4       # code 4 == print string
    la $a0,space  # $a0 == address of the string
    syscall             # Ask the operating system to 
    
# print the output w1 in each iteration        
    mov.s $f12,$f6
    li $v0 ,2
    syscall
    
    li $v0,4       # code 4 == print string
    la $a0,space2  # $a0 == address of the string
    syscall             # Ask the operating system to 
    
# print the output w2 in each iteration 
    mov.s $f12,$f7
    li $v0 ,2
    syscall
    
    li $v0,4       # code 4 == print string
    la $a0,space  # $a0 == address of the string
    syscall             # Ask the operating system to 
    
# print the output threshold in each iteration     
    mov.s $f12,$f8
    li $v0 ,2
    syscall
    
    li $v0,4       # code 4 == print string
    la $a0,space  # $a0 == address of the string
    syscall             # Ask the operating system to 
    
# print the output learning rate in each iteration    
    mov.s $f12,$f9
    li $v0 ,2
    syscall
        
    add.s $f2,$f2,$f5
    bc1f loop2
    
#print lie to declare the new epoch    
    li $v0,4       # code 4 == print string
    la $a0,newEpoch  # $a0 == address of the string
    syscall             # Ask the operating system to  
    
    bc1t loop1
    
####################### FUNCTIONS USED IN THE PROJECT ########################
#read char from file 
readChar:
    li $v0,14    
    move $a0,$s0  
    move $a1,$s1  
    li $a2,1      
    syscall       
    jr $ra
#store integer in numStore    
readInteger:
    sw $ra, 0($sp) #stack pointer
    la $s7, numStore
    li $t0, 0
    sw $t0,($s7)
#to consider number and take the numeric number that not end of line or start or comma    
ConsiderNumber:
    jal readChar
    blez $v0,EOF #when system end reading return number <=0"   
    lb $t0,($s1) #char buffer
# to consider the end of the line we have an hidden 10
    li $t1,10 
    beq $t0,$t1,endOneNumber
    
# to consider the start of the line we have an hidden 13   
    li $t1,13 
    beq $t0,$t1,ConsiderNumber
# to consider the comma that siparate the input   
    li $t1,44 
    beq $t0 $t1 endOneNumber
# convert our input from char to integer    
    addi $t0, $t0, -48 
    la $s7, numStore
    lw $t1,($s7)
    li $t2,10
    mult $t1,$t2
    mflo $t1
    add $t0, $t0, $t1
    sw $t0,($s7)  
    b ConsiderNumber
    
EOF:
    li $s5 5  
    b  endPointers
    
endOneNumber:
    li $s5 0  
    
endPointers:      
    lw $ra, 0($sp)
    jr $ra

#put y actual as zero    
step0 : 
    c.lt.s $f1,$f17
    mul.s $f17,$f17,$f1
    bc1f step1
    
#Wnew=Wold * momentoum + alpha * erorr * xi
changeWeight :
   mul.s $f20,$f18,$f10   #erorr*x1
   mul.s $f20,$f20,$f9    #alpha * erorr * x1
   mul.s $f6,$f6,$f19     #W1old * momentoum
   add.s $f6,$f6,$f20     #W1new=W1old * momentoum + alpha * erorr * x1
   mul.s $f21,$f18,$f11   #erorr*x2
   mul.s $f21,$f21,$f9    #alpha * erorr * x2 
   mul.s $f7,$f7,$f19     #W2old * momentoum
   add.s $f7,$f7,$f21     #W2new=W2old * momentoum + alpha * erorr * x2
   bc1f continue
    
            
#to exit from program     
exit:  
   li $v0,10
   syscall
   
   
   
