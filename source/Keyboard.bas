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

#include once "Keyboard.bi"

''*****************************************************************************
''
''
''
''*****************************************************************************
constructor Keyboard()

	for i as integer = 0 to KEY_MAX_INDEX
		KeyOld(i) = FALSE
		KeyNew(i) = FALSE
	next i
		
end constructor



destructor Keyboard()


end destructor



property Keyboard.Held(byval idx as integer)as integer 
	
	property = multikey( idx and KEY_MAX_INDEX ) 

end property 


property Keyboard.Pressed(byval idx as integer) as integer

	idx = idx and KEY_MAX_INDEX 
	
	KeyOld(idx) = KeyNew(idx) 
    KeyNew(idx) = multikey(idx)
	property = KeyNew(idx) and (not KeyOld(idx))
	
end property


