    PRESERVE8 
	THUMB
	AREA RESET, DATA, READONLY 
     	EXPORT __Vectors 
__Vectors DCD 0x20001000 ; stack pointer value when stack is empty 
          DCD Reset_Handler ; reset vector 
		  
				 
    AREA MYDATA, DATA, READONLY
STR1 DCB "BBaRaa RBBrRM",0
STR2 DCB "BAhmaRd MohammradBB",0

    AREA WRITEDATA,DATA,READWRITE
;you can change the values of space 30 if you want to do it in a larger string
TEXT1 space 30 ;the samll letter of STR1
Count1 DCB 0 ;count of converted letters from STR1
TEXT2 space 30 ;the samll letter of STR2
Count2 DCB 0;count of converted letters from STR2
ENCRYPT1 space 30
ENCRYPT2 space 30
COMMON DCB 0;count of common charcters between them 

   AREA MYCODE ,CODE,READONLY
    	ENTRY
	    EXPORT Reset_Handler
 				
Reset_Handler
 MOV R3, #0 ; initialize counter for converted letters ..
 LDR R0, =STR1 ; R4 points to the first input string
 LDR R1, =TEXT1; R5 points to the first output string
 LDR R4,=Count1;R2 points to the first string converted charcters counter
 BL ToLower
 MOV R3,#0 ;reinitialize the registers for the second string
 LDR R0, =STR2 ; R4 points to the second input string
 LDR R1, =TEXT2; R5 points to the second output string
 LDR R4,=Count2;R2 points to the second string converted charcters counter
 BL ToLower
 LDR R0, =STR1 ; R0 points to the input string
 LDR R1, =ENCRYPT1 ; R1 points to the output string
 BL Encrypt
 LDR R0, =STR2 ; R0 points to the input string
 LDR R1, =ENCRYPT2 ; R1 points to the output string
 BL Encrypt
 MOV R5,#0; the counter of equal characters in str2 from 1
 MOV R11,#0; counter for the repeated characters in the first string because it will counted more than one time
 LDR R0,=TEXT1 ;R0 points to the converted version of STR1
 LDR R2,=COMMON;0 R2 ponits to the common counter
 BL Common_Count
 BX LR
 B END_ALL
 
 ;int this converting process ,i initialized the registers then i will check every character
 ;if its >='A' && <='Z' , if yes it will increment 32 to it and then store the charcter
 ;else it will store it
ToLower PROC
convert_loop
 LDRB R2, [R0], #1 ; load a single character from the input string
 CMP R2, #0 ; compare the character with 0
 BEQ lowercase_end ;  the conversion is done
 CMP R2, #'A' ; compare the character with 'A'
 BLO store_char ;if its lower it will store it
 CMP R2,#'Z' ; if its higher it will store it
 BHI store_char
 ADD R2, R2,#32 ;else it will add 32 to it to convert to lower case
 ADD R3, R3,#1;counter of converted letters
store_char
 STRB R2, [R1], #1 ; store the converted character in the output string
 B convert_loop ; go to the next character
lowercase_end
 STRB R3,[R4] ; store the number of converted letters in the location pointed to by R2 
 BX LR
 ENDP
 
;encrypting every character in the string by invering all bits
Encrypt PROC
encrypt_loop
 LDRB R2, [R0], #1 ; load a single character from the input string
 CMP R2, #0 ; check if the end of the string has been reached
 BEQ END_ ; if 0,end
 MVN R2, R2 ; invert the bits of the character in R2 and store in R2
 STRB R2, [R1], #1 ; store the encrypted character in the output string
 B encrypt_loop
END_
  BX LR
  ENDP
	  
 ;in this converting proccess i used nested loops which will take a charcter 
 ;from the first string and compare it with all charcters in the second
 ;it will increment the counter and then it will check how many times the character that
 ;its equal has been found in the first string because each if there is similar charcters
 ;in the first string will be counted multiple times so we need to subtract
 ;the times its exist without the first one
 ;ex : STR1 : Baraa, SR2: Program , if i counted without checking how many times the charcters exist in 1
 ;the counter will be 4 not 2
 
 ;i used the string we converted to lower in counting ,but also you can call the ToLower procedure
 ;and convert the string to lower then start counting,if its not in lowercase
Common_Count PROC

common_count_loop1 
 LDRB R3,[R0],#1 ;R3 contains the first character in the first string
 CMP R3,#0 ;check if the end of the string is reached
 BEQ store_common ;if yes it will store the count
 LDR R1,=TEXT2; intialize the R1 in each loop for iterating through it

common_count_loop2
 LDRB R4,[R1],#1 ; load a single character from the second string
 CMP R4, #0; check if the end of the string has been reached
 BEQ common_count_loop1  ;if yes,go to the next character in the first string
 CMP R3,#' ' ;not counting the spaces
 BEQ common_count_loop1 
 CMP R3,R4 
 BEQ addition ;if they are equal increment the counter and check how many times the character in R4 exists in the first string
 B common_count_loop2 
addition
 ADD R5,R5,#1 ;increment thhe counter of the common charcters between them ;each repeated character in the first
 ;string will be counted more than one time
 MOV R6,R0
count_same_characters_loop
 LDRB R7, [R6], #1 ; load a single character from the location that R6 is currently pointing to
 CMP R7, #0 ; check if the end of the string has been reached
 BEQ common_count_loop1 ;if yes , return to the first loop
 CMP R7,R4
 BEQ add_count ;increment the counter of reapated charcters
 B count_same_characters_loop ;go to the next character
add_count
 ADD R11,R11, #1 ; add to the count
 B common_count_loop1 ;return to the first loop

store_common
 SUB R5,R5,R11; ;subtract the count of repated charcters from R5 
 STRB R5,[R2] ;store the count
 BX LR
 ENDP
END_ALL
 END