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

#include once "gl/gl.bi" 
#include once "gl/glu.bi"   
#include once "gl/glext.bi"   

#include once "Vector3D.bi"

#include once "Globals.bi"
#include once "Map.bi"


''*****************************************************************************
''
''	Simple camera class that just follows the player position
''
''*****************************************************************************
Type Camera
	
	
	declare Constructor()
	declare sub Follow( x as single, y as single, Map() as TileType )
	declare sub FollowFull( x as single, y as single, Map() as TileType )
	declare sub FollowFixed( x as single, y as single, Map() as TileType )
	declare sub Look()
	declare sub Zoom( value as single )

	
	'' Variables for gluLookAt() transform
	Position as Vector3D 
	Target as Vector3D 
	Up as Vector3D 
	
	EyeDistanceFromScreen as integer	'' The distance of your eye from screen

end type

