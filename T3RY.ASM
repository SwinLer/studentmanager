;================================================数据段
DATA SEGMENT

NUMLIMIT EQU 180
ID_LENGTH EQU 5
SCORE_LENGTH EQU 4
RANK_LENGTH EQU 4

;空间
STUDENT_LEN DW ?
TEMP_0 DB 50
       DB ? 
       DB 50 DUP (?)
TEMP_1 DB 50 DUP (?)
FID DW ?
FPATH DB 'c:\student.txt',0
FILEHI DW ?
FILELO DW ?

;界面信息
TIP_0 DB '         MAIN MENU',0AH,0DH,'$'
TIP_1 DB '         add student(a)',0AH,0DH,'$'
TIP_2 DB '         search student(s)',0AH,0DH,'$'
TIP_3 DB '         quit(q)',0AH,0DH,'$'
TIP_4 DB '         Please input your choice(a/s/q)!',0AH,0DH,'$'
TIP_5 DB '    Please input Enter to return, c to continue, q to quit.$'

ID DB '   ID(five-digit number): $'
SCORE DB 'SCORE(three-digit number): $'
RANK DB ' RANK(three-digit number): $'

LIST DB ' ID         SCORE         RANK$'

;错误提示
ERO DB ' Error!Enter again !$'
ERO_FULL DB ' Students are full !$'
ERO_NOSTU DB ' No this student !$'
ERO_ID DB ' The same ID,please enter again !$'

SC DB 0
RA DB 0
ENTER1 DB '       $'
ENTER2 DB '           $'
FLAG DW 0       ;空标记

DATA ENDS
;================================================数据段结束
;================================================宏
SET_POINTER1 MACRO      ;光标位置1
    MOV AH,2H
    MOV BH,0    ;页码
    MOV DH,2    ;行号
    MOV DL,3    ;列号
    INT 10H
ENDM

SET_POINTER2 MACRO      ;光标位置2
    MOV AH,2H
    MOV BH,0
    MOV DH,15
    MOV DL,44
    INT 10H
ENDM

TAB MACRO       ;换行
    MOV AH,2H
    MOV DL,0DH
    INT 21H
    MOV DL,0AH
    INT 21H
ENDM

CREATEFILE MACRO FILE_ID,FILE_PATH      ;创建文件
    MOV AH,3CH
    MOV CX,0
    LEA DX,FILE_PATH
    INT 21H
    MOV FILE_ID,AX
ENDM

OPENFILE MACRO FILE_ID,FILE_PATH      ;打开文件
    MOV AL,2
    MOV AH,3DH
    LEA DX,FILE_PATH
    INT 21H
    MOV FILE_ID,AX
ENDM

CLOSEFILE  MACRO FILE_ID			;关闭文件
	MOV BX,FILE_ID
	MOV AH,3EH
	INT 21H	
ENDM

READFILE MACRO FILE_ID,TEMP,SIZE      ;读文件
    MOV BX,FILE_ID
    LEA DX,TEMP
    MOV CX,SIZE
    MOV AH,3FH
    INT 21H
ENDM

WRITEFILE MACRO FILE_ID,TEMP,SIZE       ;写文件
    MOV BX,FILE_ID
    MOV CX,SIZE
    LEA DX,TEMP[2]
    MOV AH,40H
    INT 21H
ENDM

MOVEFILE MACRO FILE_ID,S,HIGH,LOW      ;文件指针
    MOV BX,FILE_ID
    MOV AH,42H
    MOV AL,S
    MOV CX,HIGH
    MOV DX,LOW
    INT 21H
ENDM

INPUT MACRO NAME,SIZE       ;输入
    MOV AH,10
    LEA DX,NAME
    INT 21H
    MOV SIZE,NAME[1]  
ENDM

OUTPUT MACRO NAME        ;输出
    MOV AH,9
    LEA DX,NAME
    INT 21H
ENDM

;================================================宏结束!
;================================================堆栈

STACK SEGMENT
DB 200 DUP (?)
STACK ENDS

;================================================堆栈结束!
;================================================代码段

CODE SEGMENT

ASSUME CS:CODE,DS:DATA

;=================================================子程序段

SPACE PROC NEAR        ;空格
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV CX,50
    MOV BX,1

RE: INC BX
    MOV TEMP_0[BX],' '
    LOOP RE

    POP DX
    POP CX
    POP BX
    POP AX

    RET
SPACE ENDP

CLEAR PROC NEAR        ;清屏
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV AL,0
    MOV CL,0
    MOV CH,0
    MOV DH,24
    MOV DL,79
    MOV BH,7
    MOV AH,6
    INT 10H
    SET_POINTER1
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CLEAR ENDP



CONTINUE PROC NEAR        ;是否返回退出继续
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    TAB
    TAB
    OUTPUT TIP_5



CO_0: MOV AH,7
    INT 21H
    CMP AL,0DH         
    JZ CO_1
    CMP AL,'q'
    JZ QUIT
    CMP AL,'c'
    JNZ CO_0
    CALL ADDSTU

CO_1: POP DX
    POP CX
    POP BX
    POP AX
    RET

CONTINUE ENDP

QUIT PROC NEAR        ;退出程序
    MOV AX,4C00H
    INT 21H
QUIT ENDP

ADDSTU PROC NEAR        ;添加学生
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    TAB
    CALL CLEAR

    OPENFILE FID,FPATH

FILESUM: MOVEFILE FID,0,0,0         ;计算文件长度
    MOV FILEHI,DX
    MOV FILELO,AX
    MOVEFILE FID,2,0,0
    SUB DX,FILEHI
    MOV FILEHI,DX
    SUB AX,FILELO
    MOV FILELO,AX
    CMP FILELO,NUMLIMIT
    JAE FULLSTU_0

ADD_ID: OUTPUT ID
    INPUT TEMP_0,BL
    CMP BL,ID_LENGTH
    JZ ADDID_NUMJU
    JNZ ADDID_ERRID               

ADDID_ERRSAME: TAB
    TAB
    OUTPUT ERO_ID
    TAB
    TAB
    JMP ADD_ID

FULLSTU_0:JMP FULLSTU

ADDID_ERRID: TAB
    TAB
    OUTPUT ERO
    TAB
    TAB
    JMP ADD_ID

ADDID_NUMJU: MOV CX,ID_LENGTH
    LEA SI,TEMP_0+2
ADDID_NUMJU_1: MOV AL,BYTE PTR [SI]
    CMP AL,'0'
    JB ADDID_ERRID
    CMP AL,'9'
    JA ADDID_ERRID
    INC SI
    LOOP ADDID_NUMJU_1

    MOVEFILE FID,0,0,0        ;绝对移动

ADDID_A: MOVEFILE FID,1,0,5        ;相对移动

ADDID_B: READFILE FID,TEMP_1,STUDENT_LEN
    CMP AX,0
    JNZ ADDID_C
    JMP ADDID_E

ADDID_C: LEA SI,TEMP_1
    LEA DI,TEMP_0
    INC DI
    DEC SI
    MOV CX,ID_LENGTH

ADDID_D: INC SI
    INC DI
    MOV AL,BYTE PTR [DI]
    CMP AL,BYTE PTR [SI]
    JNZ ADDID_A
    LOOPZ ADDID_D
    JMP ADDID_ERRSAME

FULLSTU: TAB        ;人数超出提示
    TAB
    OUTPUT ERO_FULL
    JMP CLOSE
    
ADDID_E: MOVEFILE FID,2,0,5        ;文件尾绝对位移
    WRITEFILE FID,TEMP_0,ID_LENGTH
    TAB

ADD_SC: OUTPUT SCORE
    CALL SPACE
    INPUT TEMP_0,BL
    MOV SC,BL
    ADD BL,2
    MOV BH,0
    MOV SI,BX
    MOV TEMP_0[SI],' '
    SUB BL,2
    CMP BL,SCORE_LENGTH
    JB ADDSC_A

SCORE_ERR: TAB
    TAB
    OUTPUT ERO
    TAB
    TAB
    JMP ADD_SC
    
ADDSC_A: MOV CX,BX
    MOV BX,2
ADDSC_NUMJU: CMP TEMP_0[BX],'0'
    JB SCORE_ERR
    CMP TEMP_0[BX],'9'
    JA SCORE_ERR
    INC BX
    LOOP ADDSC_NUMJU

    WRITEFILE FID,TEMP_0,SCORE_LENGTH
    TAB

ADD_RANK: OUTPUT RANK
    CALL SPACE
    INPUT TEMP_0,BL
    MOV RA,BL
    ADD BL,2
    MOV BH,0
    MOV SI,BX
    SUB BL,2
    CMP BL,RANK_LENGTH
    JB ADDRA_A

ERR_RANK: TAB
    TAB
    OUTPUT ERO
    TAB
    TAB
    JMP ADD_RANK

ADDRA_A: MOV CX,BX
    MOV BX,2
ADDRA_NUMJU: CMP TEMP_0[BX],'0'
    JB ERR_RANK
    CMP TEMP_0[BX],'9'
    JA ERR_RANK
    INC BX
    LOOP ADDRA_NUMJU

    WRITEFILE FID,TEMP_0,RANK_LENGTH
    TAB
    JMP CLOSE

CLOSE: CLOSEFILE FID
    CALL CONTINUE
    POP DX
    POP CX
    POP BX
    POP AX

    RET
             
ADDSTU ENDP

SEARCHSTU PROC NEAR        ;查询学生
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    CALL CLEAR
    OPENFILE FID,FPATH

SE_ID0: OUTPUT ID
    INPUT TEMP_0,BL
    CMP BL,ID_LENGTH
    JZ SE_0

ERR_ID: TAB
    TAB
    OUTPUT ERO
    TAB
    TAB
    JMP SE_ID0

SE_1: MOVEFILE FID,1,0,5

SE_2: READFILE FID,TEMP_1,STUDENT_LEN
    CMP AX,0
    JNZ SE_0

SE_3: TAB
    TAB 
    OUTPUT ERO_NOSTU
    JMP SE_5

QUIT_0: JMP QUIT

SE_0: LEA SI,TEMP_1
    LEA DI,TEMP_0
    INC DI
    DEC SI
    MOV CX,ID_LENGTH

SE_4: INC SI
    INC DI
    MOV AL,BYTE PTR [DI]
    CMP AL,BYTE PTR [SI]
    JNZ SE_1
    LOOPZ SE_4

    TAB
    TAB
    CALL OUTPUT_STU
    JMP SE_5

SE_5: CLOSEFILE FID
    TAB
    TAB
    OUTPUT TIP_5

SE_6: MOV AH,7
    INT 21H
    CMP AL,0DH
    JZ SE_7
    CMP AL,'q'
    JZ QUIT_0
    CMP AL,'c'
    JNZ SE_6
    CALL SEARCHSTU

SE_7: POP DX
    POP CX
    POP BX
    POP AX
    RET

SEARCHSTU ENDP          



OUTPUT_STU PROC NEAR        ;显示学生
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    OUTPUT LIST
    TAB

    MOV CX,ID_LENGTH
    MOV BX,-1

OUT_ID: INC BX
    MOV DL,TEMP_1[BX]
    MOV AH,2
    INT 21H
    LOOP OUT_ID

    OUTPUT ENTER1
    
    MOV CX,SCORE_LENGTH
    MOV BX,ID_LENGTH
    DEC BX

OUT_SCORE: INC BX
    MOV DL,TEMP_1[BX]
    MOV AH,2
    INT 21H
    LOOP OUT_SCORE

    OUTPUT ENTER2

    MOV CX,RANK_LENGTH
    MOV BX,ID_LENGTH
    ADD BX,SCORE_LENGTH
    DEC BX

OUT_RANK: INC BX
    MOV DL,TEMP_1[BX]
    MOV AH,2
    INT 21H
    LOOP OUT_RANK

    POP DX
    POP CX
    POP BX
    POP AX
    RET


OUTPUT_STU ENDP            

;=================================================子程序段结束
;=================================================主程序

MAIN: MOV AX,DATA
      MOV DS,AX

      ;80*25文本
      MOV AH,0
      MOV AL,3
      INT 10H
      
      ;屏幕初始化
      MOV AL,0
      MOV CL,0
      MOV CH,0
      MOV DH,24
      MOV DL,79
      MOV BH,0FH        ;卷入行属性
      MOV AH,6
      INT 10H

      TAB
      TAB
      TAB
      
      ;选项栏界面
      OUTPUT TIP_0
      OUTPUT TIP_1
      OUTPUT TIP_2
      OUTPUT TIP_3
      OUTPUT TIP_4
      SET_POINTER2

      ;学生信息长度
      MOV AX,ID_LENGTH
      ADD AX,SCORE_LENGTH
      ADD AX,RANK_LENGTH
      MOV STUDENT_LEN,AX
      
      ;文件是否存在
      OPENFILE FID,FPATH
      CMP AX,2
      JZ CREATEF
      CLOSEFILE FID
      JMP START

CREATEF: CREATEFILE FID,FPATH

;输入命令
START: MOV AH,7
       INT 21H
       CMP AL,'a'
       JNZ NE1
       CALL ADDSTU

RETURN: JMP MAIN

NE1: CMP AL,'s'
     JNZ NE2
     CALL SEARCHSTU
     JMP MAIN

NE2: CMP AL,'q'
     JNZ RETURN
     CALL QUIT
     JMP MAIN
      
;=================================================主程序结束
CODE ENDS

;================================================代码段结束
END MAIN