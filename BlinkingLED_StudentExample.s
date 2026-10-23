@ File: BlinkingLED3.s

@ Author: R. Kevin Preston

@ Purpose: Provide enough assembly to allow students to complete an assignment. 

@          This code turns the four LEDs on then off several times. The LEDs are

@          connected to the GPIO on the Raspberry Pi. The details on the 

@          hardware and GPIO interface are in another document. 

@

@ Use these commands to assemble, link and run the program

@

@  as -o BlinkingLED3.o BlinkingLED3.s

@  gcc -o BlinkingLED3 BlinkingLED3.o -lwiringPi

@  sudo ./BlinkingLED3

@ 

@ gdb --args ./BlinkingLED3 !! Cannot use the debugger with sudo. 

@

@ Define the constants for this code. 


OUTPUT = 1 @ Used to set the selected GPIO pins to output only. 



.text

.balign 4

.global main


main:


@ Use the C library to print the hello strings.
 
    LDR  r0, =string1   @ Put address of string in r0

     BL   printf         @ Make the call to printf


     LDR  r0, =string1a
 
    BL   printf         @ Make the call to printf



@ check the setup of the GPIO to make sure it is working right. 

@ To use the wiringPiSetup function just call it. On return:

@    r0 - contains the pass/fail code
 

       bl      wiringPiSetup

        mov     r1,#-1

        cmp     r0, r1

        bne     init  @ Everything is OK so continue with code.

        ldr     r0, =ErrMsg

        bl      printf

        b       errorout  @ There is a problem with the GPIO exit code.

@
@ Set four of the GPIO pins to output
@


@ set the pin2 mode to output

init:


        ldr     r0, =pin2

        ldr     r0, [r0]

        mov     r1, #OUTPUT

        bl      pinMode


@ set the pin3 mode to output


        ldr     r0, =pin3

        ldr     r0, [r0]

        mov     r1, #OUTPUT

        bl      pinMode


@ set the pin4 mode to output


        ldr     r0, =pin4
        ldr     r0, [r0]

        mov     r1, #OUTPUT

        bl      pinMode


@ set the pin5 mode to output


        ldr     r0, =pin5

        ldr     r0, [r0]

        mov     r1, #OUTPUT

        bl      pinMode
 

@
@ The pins are now set-up for output. 
@
@ Start a for loop to turn the lights on/off 11 times. i goes from 0 to 10. 
@
 

       ldr     r4, =i

        ldr     r4, [r4]

        mov     r5, #10


@@@@@@@@ Loop start
forLoop:

        cmp     r4, r5

        bgt     done
@ To use the digitalWrite function:

@    r0 - must contain the pin number for the GPIO per the header file info

@    r1 - set to 1 to turn the output on or to 0 to turn the output off.

@

@ Turn all four LEDs on. 

@

@ Write a logic one to turn pin2 to on.


        ldr     r0, =pin2

        ldr     r0, [r0]
        mov     r1, #1

        bl      digitalWrite


@ Write a logic one to turn pin3 to on.


        ldr     r0, =pin3

        ldr     r0, [r0]

        mov     r1, #1

        bl      digitalWrite


@ Write a logic one to turn pin4 to on.


        ldr     r0, =pin4

        ldr     r0, [r0]

        mov     r1, #1

        bl      digitalWrite


@ Write a logic one to turn pin5 to on.


        ldr     r0, =pin5

        ldr     r0, [r0]

        mov     r1, #1

        bl      digitalWrite


@ Run the delay otherwise it blinks so fast you never see it!

@ To use the delay function:

@    r0 - must contains the number of miliseconds to delay.
 

       ldr     r0, =delayMs

        ldr     r0, [r0]

        bl      delay

@

@ Turn all four LEDs off

@

@ Write a logic 0 to turn pin2 off.
 
       ldr     r0, =pin2

        ldr     r0, [r0]

        mov     r1, #0

        bl      digitalWrite


@ Write a logic 0 to turn pin3 off.
 
       ldr     r0, =pin3

        ldr     r0, [r0]

        mov     r1, #0

        bl      digitalWrite
@ Write a logic 0 to turn pin4 off.
 
       ldr     r0, =pin4

        ldr     r0, [r0]

        mov     r1, #0

        bl      digitalWrite


@ Write a logic 0 to turn pin5 off.
 
       ldr     r0, =pin5

        ldr     r0, [r0]

        mov     r1, #0

        bl      digitalWrite


@ Run the delay otherwise it blinks so fast you never see it!

        ldr     r0, =delayMs

        ldr     r0, [r0]

        bl      delay


@ Do this 11 times.
 
       add     r4, #1

        b       forLoop



@@@@@@@@@ End of for loop
done:



@ Use the C library to print the goodbye string.
 
   LDR  r0, =string2 @ Put address of string in r0

    BL   printf       @ Make the call to printf



@ Force the exit of this program and return command to OS

errorout:  @ Label only need if there is an error on board init.
    

mov  r0, r8
    MOV  r7, #0X01

    SVC  0



@ Define all the data elements 

.data

.balign 4


@ Define the values for the pins


pin2: .word 2 

pin3: .word 3

pin4: .word 4

pin5: .word 5


i:    .word 0    @ counter for for loop. 



delayMs: .word 1000  @ Set delay for one second. 

.balign 4

string1: .asciz "Raspberry Pi Blinking Light with Assembly. \n"


.balign 4

string1a: .asciz "This blinks the LEDs on the Board.  \n" 


.balign 4

string2: .asciz "The four LEDs should have blinked. \n"


.balign 4

ErrMsg: .asciz "Setup didn't work... Aborting...\n"




.global printf


@

@  The following are defined in wiringPi.h

@
.extern wiringPiSetup 

.extern delay

.extern digitalWrite

.extern pinMode


@end of code and end of file. Leave a blank line after this


