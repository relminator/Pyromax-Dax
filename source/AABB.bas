''*****************************************************************************
''
''
''	Pyromax Dax AABB Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "AABB.bi"


constructor AABB()

end constructor

destructor AABB()

end destructor
	

property AABB.GetAABB() as AABB
	property = this
end property
		
sub AABB.Init( byval x as single, byval y as single, byval wid as single, byval hei as single )

	x1 = x
	y1 = y
	x2 = ( x + wid ) - 1
	y2 = ( y + hei ) - 1
	
end sub

function AABB.Intersects( byref other as const AABB ) as integer

	if( x2 < other.x1 ) then return FALSE
	if( x1 > other.x2 ) then return FALSE
	if( y2 < other.y1 ) then return FALSE
	if( y1 > other.y2 ) then return FALSE
	
	return TRUE
	
end function


sub AABB.Resize( byval factor as single )
	
	dim as single w = ( (x2-x1) + 1 )/2
	dim as single h = ( (y2-y1) + 1 )/2
	
	dim as single wd = w * (1 - factor)
	dim as single hd = h * (1 - factor)
	
	x1 += wd
	y1 += hd 
	x2 -= wd
	y2 -= hd
		
end sub

sub AABB.Resize( byval xfactor as single, byval yfactor as single )
	
	dim as single w = ( (x2-x1) + 1 )/2
	dim as single h = ( (y2-y1) + 1 )/2
	
	dim as single wd = w * (1 - xfactor)
	dim as single hd = h * (1 - yfactor)
	
	x1 += wd
	y1 += hd 
	x2 -= wd
	y2 -= hd
		
end sub

sub AABB.Draw( byval z as integer, byval GL2Dcolor as GLuint )
	
	GL2D.Box3D( x1, y1, x2, y2, z, GL2Dcolor )

end sub