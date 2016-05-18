''*****************************************************************************
''
''
''	Pyromax Dax Bullet Class
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


#define MAX_BULLETS 255

type Bullet
	
	
	enum
		STATE_NORMAL = 0,
		STATE_BOUNCE,
		STATE_GRAVITY,
		STATE_GRAVITY_BOUNCE,
	end enum
	
	enum
		ID_DEFAULT = 0,
		ID_SAGO,
		ID_PLATE,
		ID_MINI_FRISBEE,
		ID_FRISBEE,
		ID_ARROW,
		ID_STONE,
		ID_VOLCANIC,
		ID_MISSILE,
		ID_BLADE,
	end enum
	
	declare constructor()
	declare destructor()
	
	declare property IsActive() as integer
	declare property GetX() as single
	declare property GetY() as single
	declare property GetDrawFrame() as integer
	declare property GetBox() as AABB
	
	declare sub Spawn( byval ix as integer, byval iy as integer,_
					   byval angle as integer, byval ispeed as single,_
					   byval iState as integer = STATE_NORMAL, byval iType as integer = ID_DEFAULT )
	declare sub Update( byref Snipe as Player, Map() as TileType )
	declare sub Explode()
	declare sub Kill()
	declare sub Draw( SpriteSet() as GL2D.IMAGE ptr )
	declare sub CollideWithPlayer( byref Snipe as Player )
	declare function CollideWithAABB( byref Box as const AABB ) as integer
	declare sub DrawAABB()
		
private:
	
	declare Sub ActionNormal( Map() as TileType )
	declare Sub ActionBounce( Map() as TileType )
	declare Sub ActionGravity( Map() as TileType )
	declare Sub ActionGravityBounce( Map() as TileType )
	declare sub ResolveAnimationParameters()

	as integer State
	as integer ID
	as integer Active
	as integer Counter
	as integer FlipMode
	as integer BounceCount	
	
	as single x
	as single y
	as single Dx
	as single Dy
	as integer Angle
	
	as integer Frame
	as integer BaseFrame
	as integer NumFrames

	as integer Wid
	as integer Hei	
	
	as AABB BoxNormal
	
	
End Type


type BulletFactory

public:

	declare constructor()
	declare destructor()
	
	declare property GetActiveEntities() as Integer
	declare property GetMaxEntities() as Integer
	
	declare sub UpdateEntities( byref Snipe as Player, Map() as TileType )
	declare sub DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	declare sub DrawCollisionBoxes()
	declare sub KillAllEntities()
	declare sub ExplodeAllEntities()
	declare sub HandleCollisions( byref Snipe as Player )
		
	declare sub Spawn( byval ix as integer, byval iy as integer,_
					   byval angle as integer, byval ispeed as single,_
					   byval iState as integer = Bullet.STATE_NORMAL, byval iType as integer = Bullet.ID_DEFAULT )
	declare function GetAABB( byval i as integer ) as AABB
	
private:

	as integer ActiveEntities
	as Bullet Bullets(MAX_BULLETS)
	
End Type
