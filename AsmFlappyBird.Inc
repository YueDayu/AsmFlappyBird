include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include comctl32.inc
include gdi32.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib comctl32.lib
includelib gdi32.lib

WinMain				PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc				PROTO :DWORD,:DWORD,:DWORD,:DWORD

IDB_BG              equ 100
IDB_TUBE            equ 101
IDB_BIRD			equ 102
IDB_BAR             equ 103

IDD_DIALOG			equ 1000
IDC_BOARD           equ 1001

IDM_MENU			equ 10000
IDM_FILE_EXIT		equ 10001
IDM_HELP_ABOUT		equ 10101

MTIMER				equ 30

OBJECT	struct
	x		dd ?
	y		dd ?
	state	dd ?
OBJECT ends

.const

ClassName			db 'DLGCLASS',0
AppName				db 'Flappy Bird',0
AboutMsg			db 'Flppy Bird',13,10,'Copyright © YueDayu 2016',0
ExitAsk             db 'Are you sure ?',0
fmtStr				db '%lu',0

.data?

hInstance			dd ?
CommandLine			dd ?
hWnd				dd ?

hBoard				dd ?
OldBoardProc		dd ?

bgIml				dd ?
birdIml             dd ?
tubeIml           dd ?
barIml              dd ?

