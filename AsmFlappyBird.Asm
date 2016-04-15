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
	;mov		wc.lpszMenuName,IDM_MENU
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
	invoke ImageList_Draw, birdIml, 0, mDC, 0, 0, ILD_TRANSPARENT
	invoke ImageList_Draw, tubeIml, 0, mDC, 50, 0, ILD_TRANSPARENT
	invoke ImageList_Draw, tubeIml, 1, mDC, 150, 0, ILD_TRANSPARENT
	invoke ImageList_Draw, barIml, 0, mDC, 0, 387, ILD_TRANSPARENT
	
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


WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
    LOCAL	hBmp:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
		; Load background image
		invoke ImageList_Create,288,500,ILC_COLOR16 or ILC_MASK,1,1
		mov		bgIml,eax
		invoke LoadBitmap,hInstance,IDB_BG
		mov		hBmp,eax
		invoke ImageList_AddMasked,bgIml,hBmp,0
		invoke DeleteObject,hBmp
		; Load tube image
		invoke ImageList_Create,52,270,ILC_COLOR16 or ILC_MASK,2,2
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
		invoke ImageList_Create,307,14,ILC_COLOR16 or ILC_MASK,1,1
		mov		barIml,eax
		invoke LoadBitmap,hInstance,IDB_BAR
		mov		hBmp,eax
		invoke ImageList_AddMasked,barIml,hBmp,0
		invoke DeleteObject,hBmp
		
		invoke GetDlgItem,hWin,IDC_BOARD
		mov		hBoard,eax
		invoke SetWindowLong,hBoard,GWL_WNDPROC,offset BoardProc
		mov		OldBoardProc,eax
		;invoke SetupGame,hBoard
		;invoke SetTimer,hWin,200,MTIMER,offset TimerProc
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDM_HELP_ABOUT
			invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
		.endif
;	.elseif eax==WM_SIZE
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
