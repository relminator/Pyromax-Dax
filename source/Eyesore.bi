''*****************************************************************************
''
''
''	Pyromax Dax Eyesore Class
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
#include once "Bullet.bi"


#define MAX_EYESORES 15

type Eyesore
	
	
	enum E_STATE
		STATE_IDLE = 0,
		STATE_MOVING,
	end enum
	
	enum
		D_RIGHT = 0
		D_LEFT,
		D_UP,
		D_DOWN,
	end enum
	
	declare constructor()
	declare destructor()
	
	declare property IsActive() as integer
	declare property GetX() as single
	declare property GetY() as single
	declare property GetDrawFrame() as integer
	declare property GetBox() as AABB
	
	declare sub Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	declare sub Update( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	declare sub Explode()
	declare sub Kill()
	declare sub Draw( SpriteSet() as GL2D.IMAGE ptr )
	declare sub CollideWithPlayer( byref Snipe as Player )
	declare function CollideWithAABB( byref Box as const AABB ) as integer
	declare sub DrawAABB()
		
private:
	
	declare Sub ActionIdle( Map() as TileType, byref Bullets as BulletFactory )
	declare Sub ActionMoving( Map() as TileType )
	declare function CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	declare function CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer	
	declare function CollideOnMap( Map() as TileType ) as integer
	declare sub Animate()
	declare sub ResolveDirectionVectors()
	
	as integer Active
	as integer Counter
	as integer FlipMode
	as integer Direction
	as integer State
	as integer IdleCounter
	as integer MovingCounter
	as integer IsNearPlayer
	
	as integer BlinkCounter 
	as integer Hp
	
	as single Xspeed
	as single Yspeed
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


type EyesoreFactory

public:

	declare constructor()
	declare destructor()
	
	declare property GetActiveEntities() as Integer
	declare property GetMaxEntities() as Integer
	
	declare sub UpdateEntities( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	declare sub DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	declare sub DrawCollisionBoxes()
	declare sub KillAllEntities()
	declare sub HandleCollisions( byref Snipe as Player )
		
	declare sub Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	declare function GetAABB( byval i as integer ) as AABB
	
private:

	as integer ActiveEntities
	as Eyesore Eyesores(MAX_EYESORES)
	
End Type
