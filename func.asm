
	;;;;;;;;;; ARKO -projekt Intel - Zbufor  ;;;;;;;;;;;;;;;;
	;;;;student: Mariusz Zakrzewski nr indeksu 269368 ;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section	.data
align	1
char_to_int: TIMES 12 db 0
char_to_int2: TIMES 12 db 0
temp_point:	TIMES 24 db 0
A:		TIMES 24 db 0
B:		TIMES 24 db 0
align	16
SavedFloats: TIMES 512 db 0

section	.text
global InitBuffers
global interpolate_X
global interpolate_Y
global DrawPixel
global DrawLine
global DrawTriangle
	
DrawTriangle:
	push	ebp
	mov	ebp,esp
	pusha
	; ebp+8 - image
	; ebp+12 - zbuf
	; ebp+16 - xsize
	; ebp+20 - ysize
	; ebp+24 - verticles
	; ebp+28 - rgb
	mov	ecx,[ebp+28] ; ecx = rgb
	mov	edx,[ebp+24] ; edx = verticles
	mov	eax,[edx+4] ; eax = verticles[1]
	mov	[A+4],eax
	mov	[B+4],eax
	mov	esi,[edx+16] ; esi = verticles[4]
	;esi = verticles[4] 
	;eax = A[1]
	;ecx = rgb
	;edx = verticles
	while_loop_1:
	cmp	eax,esi
	jge	end_while_loop_1
	inc	eax
	mov	[B+4],eax
	mov	[A+4],eax
	add	ecx,3 ; ecx = &rgb[3]
	push	ecx
	sub	ecx,3 ; ecx = rgb
	push	ecx
	add	edx,12 ; edx = &verticles[3]
	push	edx
	sub	edx,12 ; edx = verticles
	push	edx
	push	A 
	call 	interpolate_Y 
	add	esp,20
	add	ecx,6 ; ecx = &rgb[6]
	push	ecx
	sub	ecx,6 ; ecx = rgb
	push	ecx
	add	edx,24 ; edx = &verticles[6]
	push	edx
	sub	edx,24 ; edx = verticles
	push	edx
	push 	B
	call	interpolate_Y
	add	esp,20
	push	B
	push	A
	mov	ebx,[ebp+20] ; ebx = ysize
	push	ebx
	mov	ebx,[ebp+16] ; ebx = xsize
	push	ebx
	mov	ebx,[ebp+12] ; ebx = zbuf
	push	ebx
	mov	ebx,[ebp+8] ; ebx = image
	push	ebx
	call	DrawLine
	add	esp,24
	jmp	while_loop_1
	
	end_while_loop_1:
	mov	eax,[edx+28] ; eax =verticles[7]
	mov	[A+4],eax
	mov	[B+4],eax
	
	while_loop_2:
	dec	eax
	cmp	eax,esi
	jle	end_while_loop_2
	mov	[A+4],eax
	mov	[B+4],eax
	add	ecx,6 ; ecx = &rgb[6]
	push	ecx
	sub	ecx,3 ; ecx = &rgb[3]
	push	ecx
	add	edx,24 ; edx = &verticles[6]
	push	edx
	sub	edx,12 ; edx = &verticles[3]
	push	edx
	push	A
	call 	interpolate_Y
	add	esp,20
	add	ecx,3 ; ecx = &rgb[6] 
	push	ecx
	sub	ecx,6 ; ecx = rgb
	push	ecx
	add	edx,12 ; edx = &verticles[6]
	push	edx
	sub	edx,24 ; edx = verticles
	push	edx
	push	B
	call	interpolate_Y
	add	esp,20
	push	B
	push	A
	mov	ebx,[ebp+20] ; ysize
	push	ebx
	mov	ebx,[ebp+16] ; xsize
	push	ebx
	mov	ebx,[ebp+12] ; zbuf
	push	ebx
	mov	ebx,[ebp+8] ; image
	push	ebx
	call 	DrawLine
	add	esp,24
	jmp	while_loop_2
	
	end_while_loop_2:

	popa
	pop	ebp
	mov	eax,0
	ret

DrawLine:
	push	ebp
	mov	ebp,esp
	pusha	
	; ebp+8 - image
	; ebp+12 - zbuf
	; ebp+16 - xsize
	; ebp+20 - ysize
	; ebp+24 - A
	; ebp+28 - B
	mov	eax,[ebp+24] ;eax = A
	mov	ebx,[ebp+28] ; ebx = B
	mov	ecx,[eax] ; ecx = A.x
	mov	edx,[ebx] ; edx = B.x
	cmp	ecx,edx
	jb	no_swap
	push	eax
	push	ebx
	call 	swap_int_
	add	esp,8
	add	eax,12
	add	ebx,12
	push	eax
	push	ebx
	call	swap_int_
	add	esp,8
	no_swap:
	;;;;; copy A to temp_point
	mov	eax,[ebp+24] ; eax = A
	mov	ebx,[eax]
	mov	[temp_point],ebx
	mov	ebx,[eax+4]
	mov	[temp_point+4],ebx
	mov	ebx,[eax+8]
	mov	[temp_point+8],ebx
	mov	ebx,[eax+12]
	mov	[temp_point+12],ebx
	mov	ebx,[eax+16]
	mov	[temp_point+16],ebx
	mov	ebx,[eax+20]
	mov	[temp_point+20],ebx
	mov	eax,temp_point
	mov	ebx,[ebp+20]
	mov	ecx,[ebp+16] 
	mov	edx,[ebp+12]
	mov	edi,[ebp+8]
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	edi
	call	DrawPixel
	add	esp,20
	
	mov	ebx,[eax] ; ebx=temp[0]
	mov	ecx,[ebp+28]
	mov	edx,[ecx] ; edx=B.x

	loop:
	cmp	ebx,edx
	jg	done_drawing
	inc	ebx
	mov	[temp_point],ebx
	xor	eax,eax
	xor	ecx,ecx
	mov	eax,[ebp+24]
	mov	ecx,[ebp+28]
	push	ecx
	push	eax
	push	temp_point
	call	interpolate_X 
	add	esp,12
	push	temp_point
	mov	eax,[ebp+8]
	mov	ecx,[ebp+12]
	mov	esi,[ebp+16]
	mov	edi,[ebp+20]
	push	edi
	push	esi
	push	ecx
	push	eax
	call	DrawPixel
	add	esp,20
	jmp	loop

	done_drawing:
	popa
	pop	ebp
	ret

DrawPixel:
	push	ebp
	mov	ebp,esp
	pusha
	; ebp+8 - image
	; ebp+12 - zbuf
	; ebp+16 - xsize
	; ebp+20 - ysize
	; ebp+24 - temp
	mov	ebx,[ebp+24]
	mov	ecx,[ebx] ; ecx=temp[0]
	lea	ecx,[ecx+ecx*2] ; ecx=temp[0]*3
	mov	eax,[ebx+4] ; eax=temp[1]
	lea	eax,[eax+eax*2] ; eax=temp[1]*3
	mov	ebx,[ebp+16] ; ebx = xsize
	mul	ebx ; edx:eax = eax*ebx = xsize*temp[1]*3
	add	eax,ecx	; eax = xsize*temp[1]*3 + temp[0]*3
	mov	edx,eax
	mov	ebx,edx ; ebx =offset
	mov	eax,[ebp+12] ; eax=zbuf
	add	edx,eax ; edx = zbuf+xsize*temp[1]*3+temp[0]*3
	xor	eax,eax
	mov	al,byte[edx]
	;;;;;;;;;;; eax = Z component to compare
	mov	edx,[ebp+24] ; edx=temp
	mov	ecx,[edx+8] ; ecx = temp[2]
	shr	ecx,24 ; ecx = temp[2]>>24
	cmp	al,cl
	jb	dont_draw ; if Z < (temp[2]>>24) 
	; ebx = offset to the pixel to overwrite
	mov	eax,[ebp+12] ; eax = zbuf
	mov	edx,[ebp+24] ; edx = temp
	add	eax,ebx ; eax is the adress of the pixel to overwrite
	mov	[eax],cl
	mov	[eax+1],cl
	mov	[eax+2],cl
	mov	eax,[ebp+8]
	add	eax,ebx ; eax is the adress of the pixel to overwrite
	mov	ecx,[edx+12]
	mov	byte[eax+2],cl
	mov	ecx,[edx+16]
	mov	byte[eax+1],cl
	mov	ecx,[edx+20]
	mov	byte[eax],cl
	dont_draw:
	popa
	pop	ebp
	ret

interpolate_Y:
	push	ebp
	mov	ebp,esp
	pusha
	fxsave [SavedFloats]
	; ebp+8 - temp
	; ebp+12 - first
	; ebp+16 - second
	; ebp+20 - rgb_first
	; ebp+24 - rgb_second
	mov	eax,[ebp+8]
	mov	ebx,[ebp+12]
	mov	ecx,[ebp+16]
	
	cvtsi2sd	xmm2,[eax+4] ; xmm2 = temp.y
	cvtsi2sd	xmm3,[ebx+4] ; xmm3 = first.y
	cvtsi2sd	xmm4,[ecx+4] ; xmm4 = second.y
	
	subsd		xmm4,xmm2 ; xmm4 = second.y - temp.y
	cvtsi2sd	xmm5,[ecx+4] ; xmm5 = second.y
	subsd		xmm5,xmm3 ; xmm5 = second.y - first.y
	divsd		xmm4,xmm5 ; xmm4 = (second.y - temp.y) / (second.y - first.y)
	movsd		xmm0,xmm4 ; xmm0 = coordinate (1)

	subsd		xmm2,xmm3 ; xmm2 = temp.y - first.y
	cvtsi2sd	xmm4,[ecx+4] ; xmm4 = second.y
	cvtsi2sd	xmm5,[ebx+4] ; xmm5 = first.y
	subsd		xmm4,xmm5 ; xmm4 = second.y - first.y
	divsd		xmm2,xmm4 ; xmm2 = (temp.y - first.y) / (second.y - first.y)
	movsd		xmm1,xmm2 ; xmm1 = coordinate (2)

	mov		eax,[ebp+8] ; eax = temp
	mov		ebx,[ebp+12] ; ebx = first
	mov		ecx,[ebp+16] ; ecx = second
	;;;;;;;; calc X component ;;;;;;;;;;;;;;;;;;;;;;
	cvtsi2sd	xmm2,[ebx]
	mulsd		xmm2,xmm0
	cvtsi2sd	xmm3,[ecx]
	mulsd		xmm3,xmm1
	addsd		xmm2,xmm3
	cvtsd2ss	xmm2,xmm2
	cvtss2si	edx,xmm2
	mov		[eax],edx
	;;;;;;;; calc Z component ;;;;;;;;;;;;;;;;;;;;;
	cvtsi2sd	xmm2,[ebx+8]
	mulsd		xmm2,xmm0
	cvtsi2sd	xmm3,[ecx+8]
	mulsd		xmm3,xmm1
	addsd		xmm2,xmm3
	cvtsd2ss	xmm2,xmm2
	cvtss2si	edx,xmm2
	mov		[eax+8],edx
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov		eax,char_to_int
	mov		ebx,[ebp+20] ; rgb_first
	xor		edx,edx
	mov		dl,byte[ebx]
	mov		[eax],edx
	xor		edx,edx
	mov		dl,byte[ebx+1]
	mov		[eax+4],edx
	xor		edx,edx
	mov		dl,byte[ebx+2]
	mov		[eax+8],edx
	;;;;;;;;;;;; char _to_int contains rgb_first ;;;;;;;
	mov		eax,char_to_int2
	mov		ebx,[ebp+24] ; rgb_second
	xor		edx,edx
	mov		dl,byte[ebx]
	mov		[eax],edx
	xor		edx,edx
	mov		dl,byte[ebx+1]
	mov		[eax+4],edx
	xor		edx,edx
	mov		dl,byte[ebx+2]
	mov		[eax+8],edx
	;;;;;;;;;;;;;;;;;;; char_to_int2 contatins rgb_second ;;;;;;;;;;
	mov		eax,[ebp+8]
	;;;;;;;;;;;;; calc R component ;;;;;;;;;;;;;;;;;;;;
	cvtsi2sd	xmm2,[char_to_int]
	mulsd		xmm2,xmm0
	cvtsi2sd	xmm3,[char_to_int2]
	mulsd		xmm3,xmm1
	addsd		xmm2,xmm3
	cvtsd2ss	xmm2,xmm2
	cvtss2si	edx,xmm2
	mov		[eax+12],edx;;;;;;;edx
	;;;;;;;;;;;; calc G component ;;;;;;;;;;;;;;;;;;
	cvtsi2sd	xmm2,[char_to_int+4]
	mulsd		xmm2,xmm0
	cvtsi2sd	xmm3,[char_to_int2+4]
	mulsd		xmm3,xmm1
	addsd		xmm2,xmm3
	cvtsd2ss	xmm2,xmm2
	cvtss2si	edx,xmm2
	mov		[eax+16],edx;;;;;;;;;;;edx
	;;;;;;;;; calc B component ;;;;;;;;;;;;;;;;;
	cvtsi2sd	xmm2,[char_to_int+8]
	mulsd		xmm2,xmm0
	cvtsi2sd	xmm3,[char_to_int2+8]
	mulsd		xmm3,xmm1
	addsd		xmm2,xmm3
	cvtsd2ss	xmm2,xmm2
	cvtss2si	edx,xmm2
	mov		[eax+20],edx;;;;;;;;;edx

	popa
	fxrstor	[SavedFloats]
	pop	ebp
	ret

interpolate_X: 
	push	ebp
	mov	ebp,esp
	pusha

	fxsave [SavedFloats]
	; ebp+8 - temp
	; ebp+12 - A
	; ebp+16 - B
	mov	eax,[ebp+8]
	mov	ebx,[ebp+12]
	mov	ecx,[ebp+16]

	cvtsi2sd	xmm2,[eax] ; xmm2 = temp.x
	cvtsi2sd	xmm3,[ebx] ; xmm3 = A.x
	cvtsi2sd	xmm4,[ecx] ; xmm4 = B.x

	subsd		xmm4,xmm2 ; xmm4 = B.x - temp.x
	cvtsi2sd	xmm5,[ecx] ; xmm5=B.x
	subsd		xmm5,xmm3 ; xmm5=B.x-A.x
	divsd		xmm4,xmm5 ; xmm4 = b.x-temp.x) / (B.x-A.x)
	movsd		xmm0,xmm4 ; xmm0 - coordinate (1)
	
	subsd		xmm2,xmm3 ; xmm2 = temp.x-A.x
	cvtsi2sd	xmm4,[ecx] ; xmm4 =B.x
	cvtsi2sd	xmm5,[ebx] ;xmm5 =A.x
	subsd		xmm4,xmm5 ; xmm4 = B.x-A.x
	divsd		xmm2,xmm4 ; xmm2 = (temp.x-A.x)/(B.x-A.x)
	movsd		xmm1,xmm2 ; copy to xmm1

	mov	eax,[ebp+12] ; eax = A
	mov	ebx,[ebp+16] ; ebx = B
	cvtsi2sd	xmm2,[eax+8]
	mulsd	xmm2,xmm0

	cvtsi2sd	xmm3,[ebx+8]
	mulsd	xmm3,xmm1

	addsd	xmm2,xmm3
	cvtsd2ss	xmm2,xmm2
	cvtss2si	eax,xmm2

	mov	ebx,[ebp+8]
	mov	[ebx+8],eax
	
	mov	eax,[ebp+8]
	mov	ebx,[ebp+12]
	mov	ecx,[ebp+16]
	;;;;;;;; calc R component ;;;;;;;;;;;;;
	cvtsi2sd	xmm2,[ebx+12]
	mulsd		xmm2,xmm0
	
	cvtsi2sd	xmm3,[ecx+12]
	mulsd		xmm3,xmm1

	addsd		xmm2,xmm3
	cvtsd2ss	xmm2,xmm2
	cvtss2si	edx,xmm2
	mov		[eax+12],edx
	;;;;;;;; calc G component ;;;;;;;;;;;;;;;;;;;:
	cvtsi2sd	xmm2,[ebx+16]
	mulsd		xmm2,xmm0
	
	cvtsi2sd	xmm3,[ecx+16]
	mulsd		xmm3,xmm1

	addsd		xmm2,xmm3
	cvtsd2ss	xmm2,xmm2
	cvtss2si	edx,xmm2
	mov		[eax+16],edx
	;;;;;;;; calc B component ;;;;;;;;;;;;;;;;;
	cvtsi2sd	xmm2,[ebx+20]
	mulsd		xmm2,xmm0
	
	cvtsi2sd	xmm3,[ecx+20]
	mulsd		xmm3,xmm1

	addsd		xmm2,xmm3
	cvtsd2ss	xmm2,xmm2
	cvtss2si	edx,xmm2
	mov		[eax+20],edx
	;;;;;;; restore registers and ret ;;;;;;;;;
	fxrstor [SavedFloats]
	popa
	pop	ebp
	ret

swap_int_:
	push	ebp
	mov	ebp,esp
	pusha
	;pointer at first - 3 element buffor				ebp+8
	;pointer at second - 3 element buffor				ebp+12
	mov	ebx,[ebp+8]
	mov	ecx,[ebp+12]

	mov	eax,dword[ebx]
	mov	edx,dword[ecx]
	mov	dword[ebx],edx
	mov	dword[ecx],eax

	mov	eax,dword[ebx+4]
	mov	edx,dword[ecx+4]
	mov	dword[ebx+4],edx
	mov	dword[ecx+4],eax

	mov	eax,dword[ebx+8]
	mov	edx,dword[ecx+8]
	mov	dword [ebx+8],edx
	mov	dword[ecx+8],eax

	popa
	pop	ebp
	ret

swap_char_: 
	push	ebp
	mov	ebp,esp
	pusha
	;pointer at first - 3 elementy buffor of chars			ebp+8
	;pointer at second - 3 element buffor of chars			ebp+12
	mov	ebx,[ebp+8]
	mov	ecx,[ebp+12]
	
	mov	ah,[ebx]
	mov	dh,[ecx]
	mov	[ebx],dh
	mov	[ecx],ah:

	mov	ah,[ebx+1]
	mov	dh,[ecx+1]
	mov	[ebx+1],dh
	mov	[ecx+1],ah
	
	mov	ah,[ebx+2]
	mov	dh,[ecx+2]
	mov	[ebx+2],dh
	mov	[ecx+2],ah
	popa
	pop	ebp
	ret

InitBuffers:
	push	ebp
	mov	ebp,esp
	;pointer at image bufor						ebp+8
	;pointer at zbuf bufor						ebp+12
	;value of xsize							ebp+16
	;value of ysize							ebp+20
	;pointer at rgb's component's of background			ebp+24
	mov	eax,[ebp+16] ;eax = xsize
	mov	ebx,[ebp+20] ;ebx = ysize
	mul	ebx; edx:eax = eax*ebx
	mov	ecx,eax ; ecx = xsize*ysize ; if xsize*ysize > 2^32 error
	mov	eax,[ebp+8] ; eax = addres of image bufor
	mov	ebx,[ebp+12] ; ebx = addres of zbuf bufor
	mov	edx,[ebp+24] ; edx = adress of rgb's components
	push	ebp
	push	edi
	xor	ebp,ebp ; ebp = offset
	xor	edi,edi ; edi = temp value of rgb's component
	loop_start:
	mov	edi,[edx+2]
	mov	[eax+ebp],edi
	mov	edi,[edx+1]
	mov	[eax+ebp+1],edi
	mov	edi,[edx]
	mov	[eax+ebp+2],edi
	mov	byte [ebx+ebp],255
	mov	byte [ebx+ebp+1],255
	mov	byte [ebx+ebp+2],255
	add	ebp,3
	loop loop_start ; <=> dec ecx and branch to loop_start if zero continue
	mov	eax,0
	pop	edi
	pop	ebp
	pop	ebp
	ret

;============================================
; STOS
;============================================
;
; wieksze adresy
; 
;  |                             |
;  | ...                         |
;  -------------------------------
;  | parametr funkcji - char *a  | EBP+8
;  -------------------------------
;  | adres powrotu               | EBP+4
;  -------------------------------
;  | zachowane ebp               | EBP, ESP
;  -------------------------------
;  | ... tu ew. zmienne lokalne  | EBP-x
;  |                             |
;
; \/                         \/
; \/ w ta strone rosnie stos \/
; \/                         \/
;
; mniejsze adresy
;
;
;============================================
