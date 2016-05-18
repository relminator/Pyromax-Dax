''*****************************************************************************
''
''
''	Pyromax Dax Jumpbot Class
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


#define MAX_JUMPBOTS 15

type Jumpbot
	
	
	enum E_STATE
		STATE_FALLING = 0,
		STATE_JUMPING,
		STATE_IDLE
	end enum
	
	enum
		ORIENTATION_LEFT = 0,
		ORIENTATION_RIGHT
	end enum
	
	declare constructor()
	declare destructor()
	
	declare property IsActive() as integer
	declare property GetX() as single
	declare property GetY() as single
	declare property GetDrawFrame() as integer
	declare property GetBox() as AABB
	
	declare sub Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	declare sub Update( byref Snipe as Player, Map() as TileType )
	declare sub Explode()
	declare sub Kill()
	declare sub Draw( SpriteSet() as GL2D.IMAGE ptr )
	declare sub CollideWithPlayer( byref Snipe as Player )
	declare function CollideWithAABB( byref Box as const AABB ) as integer
	declare sub DrawAABB()
		
private:
	
	declare Sub ActionFalling( Map() as TileType )
	declare Sub ActionJumping( Map() as TileType )
	declare Sub ActionIdle( byref Snipe as Player, Map() as TileType )
	declare function CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	declare function CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer	
	declare function CollideOnMap( Map() as TileType ) as integer
	
	as integer Active
	as integer Counter
	as integer FlipMode
	as integer Orientation
	as integer State
	as integer IdleCounter
	
	as integer BlinkCounter 
	as integer Hp
	
	as single Speed
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


type JumpbotFactory

public:

	declare constructor()
	declare destructor()
	
	declare property GetActiveEntities() as Integer
	declare property GetMaxEntities() as Integer
	
	declare sub UpdateEntities( byref Snipe as Player, Map() as TileType )
	declare sub DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	declare sub DrawCollisionBoxes()
	declare sub KillAllEntities()
	declare sub HandleCollisions( byref Snipe as Player )
		
	declare sub Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	declare function GetAABB( byval i as integer ) as AABB
	
private:

	as integer ActiveEntities
	as Jumpbot Jumpbots(MAX_JUMPBOTS)
	
End Type
