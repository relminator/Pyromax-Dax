''*****************************************************************************
''
''
''	Pyromax Dax PlatformH Class
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
#include once "Vector3D.bi"
#include once "Globals.bi"
#include once "AABB.bi"
#include once "Map.bi"
#include once "Particles.bi"
#include once "Explosion.bi"
#include once "Sound.bi"
#include once "Player.bi"


#define MAX_PLATFORMHS 15

type PlatformH
	
	Enum E_COLLISION
		COLLIDE_NONE = 0,
		COLLIDE_RIGHT,
		COLLIDE_LEFT,
		COLLIDE_FLOOR	
	End Enum
	
	declare constructor()
	declare destructor()
	
	declare property IsActive() as integer
	declare property GetX() as single
	declare property GetY() as single
	declare property GetDrawFrame() as integer
	declare property GetBox() as AABB
	
	declare sub Spawn( byval ix as integer, byval iy as integer, byval direction as single, byval Distance as integer = 16 )
	declare sub Update( byval CameraX as integer, Map() as TileType )
	declare sub Kill()
	declare sub Draw( SpriteSet() as GL2D.IMAGE ptr )
	declare sub CollideWithPlayer( byref Snipe as Player )
	declare function CollideWithAABB( byref Box as const AABB ) as integer

	
private:

	declare function CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	declare function CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	declare function CollideOnMap( Map() as TileType ) as integer
	declare function ObjectCollideWalls( byref Snipe as Player ) as integer
	declare function ObjectCollideFloors( byref Snipe as Player ) as integer

	as integer Active
	as integer Counter
	as integer FlipMode
	as integer TravelDistance
	as integer SpawnX
	
	as single x
	as single y
	as single Dx
	as single Dy
	
	as integer Frame
	as integer BaseFrame
	as integer NumFrames

	as integer Wid
	as integer Hei	
	
	as AABB BoxNormal
	
	
End Type


type PlatformHFactory

public:

	declare constructor()
	declare destructor()
	
	declare property GetActiveEntities() as integer
	declare property GetMaxEntities() as integer
	
	declare sub UpdateEntities( byval CameraX as integer, Map() as TileType )
	declare sub DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	declare sub KillAllEntities()
	declare sub HandleCollisions( byref Snipe as Player )
		
	declare sub Spawn( byval ix as integer, byval iy as integer, byval direction as single, byval Distance as integer = 16 )
	declare function GetAABB( byval i as integer ) as AABB
	
private:

	as integer ActiveEntities
	as PlatformH PlatformHs(MAX_PLATFORMHS)
	
End Type
