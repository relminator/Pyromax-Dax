''*****************************************************************************
''
''
''	Pyromax Dax Camera Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Camera.bi"

''*************************************
'' Constructor
''*************************************
constructor Camera()

	EyeDistanceFromScreen = TILE_SIZE * 18   '' Distance of player's eye from screen
	
	Position.x = 0
	Position.y = 0
	Position.z = EyeDistanceFromScreen       '' Yep we are drawing at z = 0 so pos should be positive
	
	Target.x = 0
	Target.y = 0
	Target.z = 0
	
	Up.x = 0
	Up.y = 1
	Up.z = 0
	
	
end constructor	


''*************************************
''	Looks at( x, y, 0) from your "eye" 
''*************************************
sub Camera.Follow( x as single, y as single, Map() as TileType )

	'' map dimensions
	dim as integer MAP_WID = Ubound(Map,1)-2
	dim as integer MAP_HEI = Ubound(Map,2)-2
	
	'' Calculate limits
	dim as single MinX = SCREEN_WIDTH/2 + 64
	dim as single MinY = SCREEN_HEIGHT/2 + 64
	dim as single MaxX = (MAP_WID * TILE_SIZE) - (SCREEN_WIDTH/2)
	dim as single MaxY = (MAP_HEI * TILE_SIZE) - (SCREEN_HEIGHT/2)
	
	'' limit
	if( x < MinX ) then x = MinX
	if( y < MinY ) then y = MinY
	if( x > MaxX ) then x = MaxX
	if( y > MaxY ) then y = MaxY
	
	'' Camera position is always behind the screen
	'' Think of this a the "lens" of your eye
	Position.x = x
	Position.y = y
	Position.z = EyeDistanceFromScreen      '' move zpos n units from screen to eye
	
	'' Target is usually the player sprite on z = 0
	'' But can be anywhere you like (See other examples)
	Target.x = x
	Target.y = y
	Target.z = 0
	
	'' Up vector is always (0,1,0)
	'' Unless you want to do something like a top view space shooter( like I did )
	Up.x = 0
	Up.y = 1
	Up.z = 0
	
end sub

''*************************************
''	Looks at( x, y, 0) from your "eye" 
''*************************************
sub Camera.FollowFull( x as single, y as single, Map() as TileType )

	'' map dimensions
	dim as integer MAP_WID = Ubound(Map,1)
	dim as integer MAP_HEI = Ubound(Map,2)
	
	'' Calculate limits
	dim as single MinX = SCREEN_WIDTH/2
	dim as single MinY = SCREEN_HEIGHT/2
	dim as single MaxX = (MAP_WID * TILE_SIZE) - (SCREEN_WIDTH/2)
	dim as single MaxY = (MAP_HEI * TILE_SIZE) - (SCREEN_HEIGHT/2)
	
	'' limit
	if( x < MinX ) then x = MinX
	if( y < MinY ) then y = MinY
	if( x > MaxX ) then x = MaxX
	if( y > MaxY ) then y = MaxY
	
	'' Camera position is always behind the screen
	'' Think of this a the "lens" of your eye
	Position.x = x
	Position.y = y
	Position.z = EyeDistanceFromScreen      '' move zpos n units from screen to eye
	
	'' Target is usually the player sprite on z = 0
	'' But can be anywhere you like (See other examples)
	Target.x = x
	Target.y = y
	Target.z = 0
	
	'' Up vector is always (0,1,0)
	'' Unless you want to do something like a top view space shooter( like I did )
	Up.x = 0
	Up.y = 1
	Up.z = 0
	
end sub


''*************************************
''	Looks at( x, y, 0) from your "eye" 
''*************************************
sub Camera.FollowFixed( x as single, y as single, Map() as TileType )

	'' map dimensions
	dim as integer MAP_WID = Ubound(Map,1)
	dim as integer MAP_HEI = Ubound(Map,2)
	
	'' Calculate limits
	dim as single MinX = SCREEN_WIDTH/2
	dim as single MaxX = (MAP_WID * TILE_SIZE) - (SCREEN_WIDTH/2)
	
	dim as single Ypos = ((MAP_HEI+1) * TILE_SIZE)/2
	'' limit
	if( x < MinX ) then x = MinX
	if( x > MaxX ) then x = MaxX
	
	'' Camera position is always behind the screen
	'' Think of this a the "lens" of your eye
	Position.x = x
	Position.y = Ypos
	Position.z = EyeDistanceFromScreen      '' move zpos n units from screen to eye
	
	'' Target is usually the player sprite on z = 0
	'' But can be anywhere you like (See other examples)
	Target.x = x
	Target.y = Ypos
	Target.z = 0
	
	'' Up vector is always (0,1,0)
	'' Unless you want to do something like a top view space shooter( like I did )
	Up.x = 0
	Up.y = 1
	Up.z = 0
	
end sub


''*************************************
'' Does the world transformation using our orthogonal basis vectors
''*************************************
sub Camera.Look()

	
	gluLookAt( Position.x, Position.y, Position.z,_    	'' camera pos
			   Target.x, Target.y, Target.z,_     	   	'' camera target
               Up.x, Up.y, Up.z)						'' Up

end sub


''*************************************
'' Zooms/Pans in and out of the playing field
''*************************************
sub Camera.Zoom( value as single )

	'' Just mess around with your eye position to zoom
	EyeDistanceFromScreen +=value

end sub
