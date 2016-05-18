''*****************************************************************************
''
''
''	Pyromax Dax Mouse Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "FBGFX.bi"

#ifndef FALSE
	#define FALSE 0
	#define TRUE -1
#endif

enum MOUSE_BUTTONS
	MOUSE_BUTTON_LEFT = 1 shl  0
	MOUSE_BUTTON_RIGHT = 1 shl  1
	MOUSE_BUTTON_MIDDLE = 1 shl  2
End Enum


type Mouse
	
public:
	'' constructors and destructors
	declare constructor()
	
	declare destructor()	
	
	declare Property GetX() as Integer
	declare Property GetY() as Integer
	declare Property GetWheel() as Integer
	
	declare property ButtonHeld( byval ButtonKey as MOUSE_BUTTONS ) as integer
	
	'' Use these when you want to only get a single keypress
	'' no matter how long you press a button. 
	declare property ButtonPressed( byval ButtonKey as MOUSE_BUTTONS ) as integer

	declare property ButtonUnPressed( byval ButtonKey as MOUSE_BUTTONS ) as integer

	declare Property SetX( byval v  as integer )
	declare Property SetY( byval v  as integer )
	declare Property SetClip( byval v  as integer )
	declare Property SetVisible( byval v  as integer )
	
	'' Methods
	
	declare function ScanButtons() as integer
	declare sub Reset()
	
	
private:
	Button 		as integer
	ButtonOld	as integer
	x			as integer
	y			as integer
	Wheel		as integer
	Clip		as Integer
	Visible		as integer
	
end type

