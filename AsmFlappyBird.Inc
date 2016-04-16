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
OBJECT ends

.const

ClassName			db 'DLGCLASS',0
AppName				db 'Flappy Bird',0
AboutMsg			db 'Flppy Bird',13,10,'Copyright © YueDayu 2016',0
ExitAsk             db 'Are you sure ?',0
startStr            db 'HIT SPACE TO START', 0
fmtStr				db '%lu',0
lastFmtStr          db 'Last: %lu', 0
maxFmtStr           db 'Max: %lu', 0

.data?

hInstance			dd ?
CommandLine			dd ?
hWnd				dd ?

hBoard				dd ?
OldBoardProc		dd ?

bgIml				dd ?
birdIml             dd ?
tubeIml             dd ?
barIml              dd ?

gStatus             dd 0 ; 0-die 1-flying
speed               dd 3
cPoint              dd 0 ; current point
lPoint              dd 0 ; last point
maxPoint            dd 0 ; max point

rseed				dd ?

; Tube:
; switch when the first disappear
upTube              OBJECT 2 dup(<>)
downTube            OBJECT 2 dup(<>)

; Bottom (Ground)
bottomY             dd 387
bottomX             dd 0

; Bird: 
; in every loop, birdAc = min(birdAc + gravityAc, birdMaxAc);
; birdY = min(max(birdAC + birdAC, 0), birdBottom)
; If hit the buttom, birdAc = jumpAc
birdX               dd ?
birdY               dd ?
birdAc              dd 0
birdMaxAc           dd 8
birdBottom          dd 361
gravityAc           dd 1
jumpAc              dd -7
cflap               dd 1
cflapDir            dd 0

addedFlag           dd 0
