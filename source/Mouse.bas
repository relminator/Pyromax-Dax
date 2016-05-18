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

#include once "Mouse.bi"

''*****************************************************************************
''
''
''
''*****************************************************************************
constructor Mouse()

	Button 		= 0
	ButtonOld 	= 0
	x			= 0
	y			= 0
	Wheel		= 0
	Clip		= 0
	Visible		= 0
	
	
end constructor



destructor Mouse()


end destructor



property Mouse.GetX() as integer

	property = x

end property


property Mouse.GetY() as integer

	property = y

end property

property Mouse.GetWheel() as integer

	property = Wheel

end property

property Mouse.ButtonHeld( byval ButtonKey as MOUSE_BUTTONS ) as integer 
	
	property = Button and ButtonKey 

end property 


property Mouse.ButtonPressed( byval ButtonKey as MOUSE_BUTTONS ) as integer

	property = (Button and (not ButtonOld)) and ButtonKey
	
end property

property Mouse.ButtonUnPressed( byval ButtonKey as MOUSE_BUTTONS ) as integer

	property = ( (Button xor ButtonOld) and (not Button) ) and ButtonKey
	
end property


Property Mouse.SetX( byval v  as integer )
	x = v
	SetMouse x
End Property

Property Mouse.SetY( byval v  as integer )
	y = v
	SetMouse  x,y
End Property


Property Mouse.SetClip( byval v  as integer )
	Clip = v and 1
	SetMouse x, y, Wheel, Clip 
End Property

Property Mouse.SetVisible( byval v  as integer )
	Visible = v and 1
	SetMouse , , Visible 

End Property
	

''*****************************************************************************
''
''
''
''*****************************************************************************
function Mouse.ScanButtons() as integer
	
	ButtonOld = Button
	GetMouse( x, y, wheel, Button )
	if Button = -1 then
		Button = 0
		ButtonOld = 0
		return FALSE
	else
		return TRUE
	endif
		
end function

sub Mouse.Reset()
	
	Button 		= 0
	ButtonOld 	= 0
	x			= 0
	y			= 0
	Wheel		= 0
	Clip		= 0
	Visible		= 0
	
end sub




