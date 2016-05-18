''*****************************************************************************
''
''
''	Pyromax Dax Joystick Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#pragma once

#include once "FBGFX.bi"

#ifndef FALSE
	#define FALSE 0
	#define TRUE -1
#endif

enum JOY_KEYS
	JOY_KEY_1 = 1 shl  0
	JOY_KEY_2 = 1 shl  1
	JOY_KEY_3 = 1 shl  2
	JOY_KEY_4 = 1 shl  3
	JOY_KEY_5 = 1 shl  4
	JOY_KEY_6 = 1 shl  5
	JOY_KEY_7 = 1 shl  6
	JOY_KEY_8 = 1 shl  7
	JOY_KEY_9 = 1 shl  8
	JOY_KEY_10 = 1 shl  9
	JOY_KEY_11 = 1 shl  10
	JOY_KEY_12 = 1 shl  11
	JOY_KEY_13 = 1 shl  12
	JOY_KEY_14 = 1 shl  13
	JOY_KEY_15 = 1 shl  14
	JOY_KEY_16 = 1 shl  15
End Enum



type Joystick
	
public:
	'' constructors and destructors
	declare constructor()
	declare constructor(byval ID as integer)
	
	declare destructor()	
	
	'' properties
	''setters
	declare property SetID(byval id as integer)

	''getters
	declare property GetID() as integer
	
	declare property Right() as integer
	declare property Left() as integer
	declare property Up() as integer
	declare property Down() as integer
	
	declare property RightPressed() as integer
	declare property LeftPressed() as integer
	declare property UpPressed() as integer
	declare property DownPressed() as integer
	
	declare property AxisX() as single
	declare property AxisY() as single
		
	declare property KeyHeld( byval Key as JOY_KEYS ) as integer
	
	'' Use these when you want to only get a single keypress
	'' no matter how long you press a button. 
	declare property KeyPressed( byval Key as JOY_KEYS ) as integer

	declare property KeyUp( byval Key as JOY_KEYS ) as integer


	'' Methods	
	declare function ScanButtons() as integer
	declare sub Reset()
	
	
private:
	ID			as integer
	Button 		as integer
	ButtonOld	as integer
	x			as single
	y			as single
	
	RightOld    as integer
	LeftOld     as integer
	UpOld       as integer
	DownOld     as integer
	
end type


