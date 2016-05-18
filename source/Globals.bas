''*****************************************************************************
''
''
''	Pyromax Dax Globals
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Globals.bi"

namespace Globals
	
dim as integer QuakeCounter = 0	

sub SetQuakeCounter( byval v as integer )
	QuakeCounter = v
end sub

function GetQuakeCounter() as integer
	return QuakeCounter
end function 

function Quake() as integer
	QuakeCounter -= 1
	if( QuakeCounter > 0 ) then
		return TRUE
	endif
	return FALSE
end function

end namespace
