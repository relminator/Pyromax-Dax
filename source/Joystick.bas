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

#include once "Joystick.bi"


const as single R_MIN_CALIB =  0.30 
const as single R_MAX_CALIB =  1.00
const as single L_MIN_CALIB = -1.00
const as single L_MAX_CALIB = -0.40
const as single U_MIN_CALIB = -1.00 
const as single U_MAX_CALIB = -0.40
const as single D_MIN_CALIB =  0.35
const as single D_MAX_CALIB =  1.00


''*****************************************************************************
''
''
''
''*****************************************************************************
constructor Joystick()

	ID			= 0
	Button 		= 0
	ButtonOld 	= 0
	x			= 0
	y			= 0

	
end constructor


constructor Joystick(byval id as integer)

	ID			= 0
	Button 		= 0
	ButtonOld 	= 0
	x			= 0
	y			= 0

	
end constructor


destructor Joystick()


end destructor


''*****************************************************************************
''
''
''
''*****************************************************************************
property Joystick.SetID( byval index as integer )

	ID = index

end property

property Joystick.GetID() as integer

	property = ID
	
end property


property Joystick.Right() as integer

	property = (x > R_MIN_CALIB and x <= R_MAX_CALIB)
	
end property


property Joystick.Left() as integer

	property = (x >= L_MIN_CALIB and x < L_MAX_CALIB)
	
end property


property Joystick.Up() as integer

	property = (y >= U_MIN_CALIB and y < U_MAX_CALIB)

end property


property Joystick.Down() as integer

	property = (y > D_MIN_CALIB and y <= D_MAX_CALIB)
	
end property

property Joystick.RightPressed() as integer
	
	property = this.Right() and (not RightOld)
	
end property

property Joystick.LeftPressed() as integer
	
	property = this.Left() and (not LeftOld)
	
end property

property Joystick.UpPressed() as integer
	
	property = this.Up() and (not UpOld)
	
end property

property Joystick.DownPressed() as integer
	
	property = this.Down() and (not DownOld)
	
end property

property Joystick.AxisX() as single

	property = x

end property


property Joystick.AxisY() as single

	property = y

end property


property Joystick.KeyHeld( byval Key as JOY_KEYS ) as integer 
	
	property = Button and Key 

end property 


property Joystick.KeyPressed( byval Key as JOY_KEYS ) as integer

	property = (Button and (not ButtonOld)) and Key
	
end property

property Joystick.KeyUp( byval Key as JOY_KEYS ) as integer

	property = ( (Button xor ButtonOld) and (not Button) ) and Key
	
end property



''*****************************************************************************
''
''
''
''*****************************************************************************
function Joystick.ScanButtons() as integer
	
	ButtonOld = Button
	RightOld  = This.Right()
	LeftOld   = This.Left()
	UpOld     = This.Up()
	DownOld   = This.Down()
	
	GetJoystick(ID, Button, x, y)
	if Button = -1 then
		Button = 0
		ButtonOld = 0
		return FALSE
	else
		return TRUE
	endif
		
end function

sub Joystick.Reset()
	
	Button 		= 0
	ButtonOld	= 0
	x			= 0
	y			= 0
	
end sub


