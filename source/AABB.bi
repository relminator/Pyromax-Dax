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

#include once "FBGFX.bi"
#include once "FBGL2D7.bi"     	'' We're gonna use Hardware acceleration
#include once "UTIL.bi"
#include once "Vector2D.bi"


type AABB
	
public:
	declare constructor()
	declare destructor()
	
	declare property GetAABB() as AABB
	
	declare sub Init( byval x as single, byval y as single, byval wid as single, byval hei as single )
	declare function Intersects( byref other as const AABB ) as integer
	declare sub Resize( byval factor as single )
	declare sub Resize( byval xfactor as single, byval yfactor as single )
	declare sub Draw( byval z as integer, byval GL2Dcolor as GLuint )
	
	as single x1
	as single y1
	as single x2
	as single y2
	
end type
