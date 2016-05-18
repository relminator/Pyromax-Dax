''*****************************************************************************
''
''
''	Pyromax Dax Keyboard Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "FBGFX.bi"

#ifndef false
	const as integer FALSE = 0
	const as integer TRUE = NOT FALSE
#endif

#define KEY_MAX_INDEX 127


type Keyboard
	
public:

	'' constructors and destructors
	declare constructor()
	
	declare destructor()	
	
	
	'' Use these when you want to only get a keypress
	'' as long as you are pressing a key. 
	declare property Held(byval idx as integer) as integer
	
	'' Use these when you want to only get a single keypress
	'' no matter how long you press a Key. 
	declare property Pressed(byval idx as integer) as integer

	

private:
	
	KeyOld( KEY_MAX_INDEX )	as integer			'' key prevous
	KeyNew( KEY_MAX_INDEX )	as integer			'' key current

end type

