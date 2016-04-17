.386
.model flat,stdcall
option casemap:none

include AsmFlappyBird.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke GetCommandLine
	mov		CommandLine,eax
	invoke InitCommonControls
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,IDM_MENU
	mov		wc.lpszClassName,offset ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_DIALOG,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp


PaintBoard proc uses ebx esi,hWin:HWND,hDC:HDC
	LOCAL	mDC:HDC
	LOCAL	hBmp:DWORD
	LOCAL	hOld:DWORD
	LOCAL	rect:RECT
	LOCAL	wRect:RECT
	LOCAL	xmax:DWORD
	LOCAL	buffer[32]:BYTE

	invoke CreateCompatibleDC,hDC
	mov		mDC,eax
	invoke CreateCompatibleBitmap,hDC,288,500
	invoke SelectObject,mDC,eax
	push	eax
	mov		rect.left,0
	mov		rect.top,0
	mov		rect.right,288
	mov		rect.bottom,500
	; Draw background
	invoke ImageList_Draw, bgIml, 0, mDC, 0, 0, ILD_TRANSPARENT
	
	; Draw words
	.if gStatus == 0
	    mov		wRect.left,0
	    mov		wRect.top,210
	    mov		wRect.right,288
	    mov		wRect.bottom,500
	    invoke SetBkMode,mDC,TRANSPARENT
	    invoke SetTextColor,mDC,0000000h
	    invoke wsprintfA,addr buffer,offset lastFmtStr,lPoint
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	    mov		wRect.top,235
	    invoke wsprintfA,addr buffer,offset maxFmtStr,maxPoint
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	    mov		wRect.top,260
	    invoke wsprintfA,addr buffer,offset startStr
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	.else
	    ; Draw tube here
	    push ebx
	    mov ebx, offset upTube
	    .if [ebx].OBJECT.x < 288 || [ebx].OBJECT.x <= -1
	        invoke ImageList_Draw, tubeIml, 0, mDC, [ebx].OBJECT.x, [ebx].OBJECT.y, ILD_TRANSPARENT
	    .endif
        add ebx, sizeof OBJECT
        .if [ebx].OBJECT.x < 288 || [ebx].OBJECT.x <= -1
	        invoke ImageList_Draw, tubeIml, 0, mDC, [ebx].OBJECT.x, [ebx].OBJECT.y, ILD_TRANSPARENT
	    .endif
 	    mov ebx, offset downTube
 	    
 	    .if [ebx].OBJECT.x < 288 || [ebx].OBJECT.x <= -1
	        invoke ImageList_Draw, tubeIml, 1, mDC, [ebx].OBJECT.x, [ebx].OBJECT.y, ILD_TRANSPARENT
	    .endif
        add ebx, sizeof OBJECT
        .if [ebx].OBJECT.x < 288 || [ebx].OBJECT.x <= -1
            invoke ImageList_Draw, tubeIml, 1, mDC, [ebx].OBJECT.x, [ebx].OBJECT.y, ILD_TRANSPARENT
        .endif
	    pop ebx
	
	    ; end draw tube
	    mov		wRect.left,0
	    mov		wRect.top,50
	    mov		wRect.right,288
	    mov		wRect.bottom,500
	    invoke SetBkMode,mDC,TRANSPARENT	    
	    invoke wsprintfA,addr buffer,offset fmtStr,cPoint
	    ;invoke wsprintfA,addr buffer,offset fmtStr,actionToPerform
	    invoke SetTextColor,mDC,0ffffffh
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	    invoke SetTextColor,mDC,0000000h
	    mov		wRect.top,49
	    mov		wRect.right,286
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER   
	    
	    .if isAuto
	        mov		wRect.top,30
	        mov		wRect.right,288
	        invoke wsprintfA,addr buffer,offset maxFmtStr,maxPoint
	        invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	        mov		wRect.top,10
	        invoke wsprintfA,addr buffer,offset lastFmtStr,lPoint
	        invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	    .endif
	    
	.endif
	
	; Draw bird
	.if cflap < 1 && cflapDir == 3
	    mov cflapDir, 0
	.elseif cflap > 1 && cflapDir == 3
	    mov cflapDir, 1
	.elseif cflap < 1 || cflap > 1
	    mov cflapDir, 3
	.endif
	
	.if cflapDir==0
	    inc cflap
	.elseif cflapDir==1
	    dec cflap
	.endif
	
	invoke ImageList_Draw, birdIml, cflap, mDC, birdX, birdY, ILD_TRANSPARENT
	
	; Draw bottom
	mov eax, speed
	sub bottomX, eax
	.if bottomX < -47
	    mov bottomX, 0
	.endif
	invoke ImageList_Draw, barIml, 0, mDC, bottomX, bottomY, ILD_TRANSPARENT
	
	invoke GetClientRect,hWin,addr rect
	invoke StretchBlt,hDC,0,0,rect.right,rect.bottom,mDC,0,0,288,500,SRCCOPY
	pop		eax
	invoke SelectObject,mDC,eax
	invoke DeleteObject,eax
	invoke DeleteDC,mDC
	ret

PaintBoard endp


BoardProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT

	.if uMsg==WM_PAINT
		invoke BeginPaint,hWin,addr ps
		invoke PaintBoard,hWin,ps.hdc
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
		ret
	.endif 
	invoke CallWindowProc,OldBoardProc,hWin,uMsg,wParam,lParam
	ret

BoardProc endp


Random proc uses ecx edx,range:DWORD

    inc rseed
	mov eax, rseed
	mov ecx, 23
	mul ecx
	add eax, 7
	and eax, 0FFFFFFFFh
	ror eax, 1
	xor eax, rseed
	mov rseed, eax
	mov ecx, range
	xor edx, edx
	div ecx
	mov eax, edx
	ret

Random endp


SetupFly proc uses eax
    inc rseed
    ; set bird
    mov birdX, 63
    mov birdY, 200
    mov eax, jumpAc
    mov birdAc, eax
    ; set tube
    push ebx
    push edx
    mov ebx, offset upTube
    mov edx, offset downTube
    mov [ebx].OBJECT.x, 576
    mov [edx].OBJECT.x, 576
    invoke Random, 160
    add eax, 195
    mov [edx].OBJECT.y, eax
    sub eax, 450
    mov [ebx].OBJECT.y, eax
    add ebx, sizeof OBJECT
    add edx, sizeof OBJECT
    mov [ebx].OBJECT.x, 756
    mov [edx].OBJECT.x, 756
    invoke Random, 160
    add eax, 195
    mov [edx].OBJECT.y, eax
    sub eax, 450
    mov [ebx].OBJECT.y, eax
    pop edx
    pop ebx
    mov addedFlag, 0
    ret
SetupFly endp


SetupDie proc uses eax,hWin:DWORD

    mov eax, cPoint
    mov cPoint, 0
    mov lPoint, eax
    .if eax > maxPoint
        mov maxPoint, eax  
    .endif
    mov gStatus, 0
    
    mov birdX, 127
    mov birdY, 168
    
    .if isAuto
        mov gStatus, 1
	    invoke SetupFly
    .endif
    
    invoke InvalidateRect,hWin,NULL,TRUE
 
    ret
SetupDie endp


SetDist proc uses eax ebx
    
    mov ebx, offset downTube
    mov eax, [ebx].OBJECT.x
    add eax, 52
    .if eax < (birdX) || eax > 10000 ; behind the bird, use the second tube
        add ebx, sizeof OBJECT
    .endif
    mov eax, [ebx].OBJECT.x
    sub eax, birdX
    ;sub eax, 34
    .if eax > 179
        mov eax, 179
    .endif
    mov stateDashH, eax
    mov eax, [ebx].OBJECT.y
    mov ebx, birdY
    add ebx, 24
    sub eax, ebx
    add eax, 200
    mov stateDashV, eax 
    ret

SetDist endp


UpdateQ proc uses eax ebx edx
    LOCAL V_s_dash_a_dash:REAL8
    LOCAL Q_s_a:REAL8
    LOCAL tempX:DWORD
    LOCAL tempY:DWORD
    
    finit
    
    mov edx, 0
    mov eax, stateDashV
    mov ebx, 10
    div ebx
    mov tempX, eax
    mov edx, 0
    mov eax, stateDashH
    mov ebx, 10
    div ebx
    mov tempY, eax
    mov eax, tempX
    mov ebx, 50
    mul ebx
    mov ebx, eax
    add ebx, tempY
    add ebx, tempY
    fld QMap[ebx * type QMap] ; load Q[tempX][tempY][0]
    inc ebx
    fcom QMap[ebx * type QMap] ; compare with Q[tempX][tempY][1]
    fnstsw ax
    sahf
    ja L1
    fstp V_s_dash_a_dash
    fld QMap[ebx * type QMap]
    L1:
    fstp V_s_dash_a_dash ; save the bigger number to V_s_dash_a_dash
    
    finit
    
    mov edx, 0
    mov eax, stateV
    mov ebx, 10
    div ebx
    mov tempX, eax
    mov edx, 0
    mov eax, stateH
    mov ebx, 10
    div ebx
    mov tempY, eax
    mov eax, tempX
    mov ebx, 50
    mul ebx
    add eax, tempY
    add eax, tempY
    add eax, actionToPerform
    mov ebx, eax
    fld QMap[ebx * type QMap]
    fstp Q_s_a ; get Q_s_a
    
    fld V_s_dash_a_dash
    fsub Q_s_a
    
    fild reward
    fadd
    
    fld alpha_QL
    fmul
    
    fld Q_s_a
    fadd
    
    fstp QMap[ebx * type QMap]
    
    mov eax, stateDashV
    mov stateV, eax
    
    mov eax, stateDashH
    mov stateH, eax

    ret

UpdateQ endp


PerformAction proc uses eax ebx
    LOCAL tempX:DWORD
    LOCAL tempY:DWORD
    
    finit
    
    mov edx, 0
    mov eax, stateV
    mov ebx, 10
    div ebx
    mov tempX, eax
    mov edx, 0
    mov eax, stateH
    mov ebx, 10
    div ebx
    mov tempY, eax
    mov eax, tempX
    mov ebx, 50
    mul ebx
    add eax, tempY
    add eax, tempY
    mov ebx, eax
    
    fld QMap[ebx * type QMap] ; load Q[tempX][tempY][0]
    inc ebx
    fcom QMap[ebx * type QMap] ; compare with Q[tempX][tempY][1]
    fnstsw ax
    sahf
    jb L3
    mov actionToPerform, 0 ; do nothing
    jmp L4
    L3:
    mov actionToPerform, 1
    mov eax, jumpAc
	mov birdAc, eax
    L4:

    ret

PerformAction endp


TimerProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

    .if gStatus == 1
        .if isAuto
            invoke PerformAction
        .endif
        mov eax, birdAc
        add eax, gravityAc
        mov reward, 1
        .if eax > birdMaxAc && eax < 10000
            mov eax, birdMaxAc
        .endif
        mov birdAc, eax
        add eax, birdY
        .if eax > 10000
            mov eax, 0
        .endif
        .if eax > birdBottom ; touch the ground, failed
            mov gStatus, 0
            mov reward, -1000
            invoke SetupDie, hBoard
        .else
            mov birdY, eax
        .endif
        push ebx
        push edx
        mov ebx, offset downTube
        mov eax, [ebx].OBJECT.x
        .if eax < birdX && addedFlag == 0
            mov reward, 2
            inc cPoint
            mov addedFlag, 1
        .endif
        .if eax > 16 && eax < 97
            mov eax, [ebx].OBJECT.y
            sub eax, birdY
            .if eax < 20 || eax > 135 
                mov gStatus, 0
                mov reward, -1000
                invoke SetupDie, hBoard
            .endif
        .endif
        
        mov ebx, offset upTube
        mov edx, offset downTube
        .if [ebx].OBJECT.x < -54 && [ebx].OBJECT.x > 10000
            mov eax, ebx
            add eax, sizeof OBJECT
            mov ecx, [eax].OBJECT.x
            mov [ebx].OBJECT.x, ecx
            mov ecx, [eax].OBJECT.y
            mov [ebx].OBJECT.y, ecx
            mov eax, edx
            add eax, sizeof OBJECT
            mov ecx, [eax].OBJECT.x
            mov [edx].OBJECT.x, ecx
            mov ecx, [eax].OBJECT.y
            mov [edx].OBJECT.y, ecx
            
            mov eax, [edx].OBJECT.x
            add eax, 180
            add ebx, sizeof OBJECT
            add edx, sizeof OBJECT
            mov [ebx].OBJECT.x, eax
            mov [edx].OBJECT.y, eax
            invoke Random, 160
            add eax, 195
            mov [edx].OBJECT.y, eax
            sub eax, 450
            mov [ebx].OBJECT.y, eax
            
            mov addedFlag, 0
        .endif
        mov ecx, 2
        mov ebx, offset upTube
        mov edx, offset downTube
        .while ecx
            mov eax, [ebx].OBJECT.x
            sub eax, speed
            mov [ebx].OBJECT.x, eax
            mov [edx].OBJECT.x, eax
            add ebx, sizeof OBJECT
            add edx, sizeof OBJECT
            dec ecx
        .endw
        pop edx
        pop ebx
        
        .if isAuto
            invoke SetDist
            invoke UpdateQ    
        .endif
        
    .endif
	invoke InvalidateRect,hBoard,NULL,TRUE
	ret

TimerProc endp


InitParam proc
    
    mov speed, 4
    mov bottomY, 387
    mov birdMaxAc, 11
    mov birdBottom, 369
    mov gravityAc, 2
    mov jumpAc, -14
    mov cflap, 1
    mov stateV, 179
    mov stateH, 0
    mov isAuto, 0
    ret

InitParam endp


SaveFile proc uses eax ebx
    LOCAL writtenByte:DWORD
    
	invoke CreateFile,offset szFile,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov ebx, eax
	invoke WriteFile, ebx, offset QMap, MapSize, addr writtenByte, 0
	invoke CloseHandle, ebx
    ret

SaveFile endp

ReadModelFile proc
    LOCAL readByte

    invoke CreateFile,offset szFile,GENERIC_READ,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
    .if eax
	    mov ebx, eax
	    invoke ReadFile, ebx, offset QMap, MapSize, addr readByte, 0
	.endif
	invoke CloseHandle, ebx
    ret

ReadModelFile endp


WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
    LOCAL	hBmp:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
		; Load background image
		invoke ImageList_Create,288,500,ILC_COLOR16,1,0
		mov		bgIml,eax
		invoke LoadBitmap,hInstance,IDB_BG
		mov		hBmp,eax
		invoke ImageList_AddMasked,bgIml,hBmp,0
		invoke DeleteObject,hBmp
		; Load tube image
		invoke ImageList_Create,52,320,ILC_COLOR16 or ILC_MASK,2,2
		mov		tubeIml,eax
		invoke LoadBitmap,hInstance,IDB_TUBE
		mov		hBmp,eax
		invoke ImageList_AddMasked,tubeIml,hBmp,0
		invoke DeleteObject,hBmp
		; Load bird image
		invoke ImageList_Create,34,24,ILC_COLOR16 or ILC_MASK,3,3
		mov		birdIml,eax
		invoke LoadBitmap,hInstance,IDB_BIRD
		mov		hBmp,eax
		invoke ImageList_AddMasked,birdIml,hBmp,0
		invoke DeleteObject,hBmp
		; Load bar image
		invoke ImageList_Create,336,112,ILC_COLOR16,1,0
		mov		barIml,eax
		invoke LoadBitmap,hInstance,IDB_BAR
		mov		hBmp,eax
		invoke ImageList_AddMasked,barIml,hBmp,0
		invoke DeleteObject,hBmp

		invoke GetDlgItem,hWin,IDC_BOARD
		mov		hBoard,eax
		invoke SetWindowLong,hBoard,GWL_WNDPROC,offset BoardProc
		mov		OldBoardProc,eax
		invoke InitParam
		invoke SetupDie, hBoard
		invoke SetTimer,hWin,200,MTIMER,offset TimerProc
	.elseif eax==WM_KEYDOWN
		mov		eax,wParam
		.if eax==VK_SPACE
			.if gStatus == 0
			    mov gStatus, 1
			    invoke SetupFly
			.else
			    mov eax, jumpAc
			    mov birdAc, eax
			.endif
		.elseif eax==VK_A
		    .if isAuto
		        mov isAuto, 0
		    .else
		        mov isAuto, 1
		    .endif
		.endif
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDM_MODE
		    .if isAuto
		        mov isAuto, 0
		    .else
		        mov isAuto, 1
		    .endif
		.elseif eax==IDM_SAVE
		    invoke SaveFile
		.elseif eax==IDM_OPEN
		    invoke ReadModelFile
		.endif
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.elseif uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

WndProc endp

end start
