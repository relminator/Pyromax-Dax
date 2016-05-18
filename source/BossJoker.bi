''*****************************************************************************
''
''
''	Pyromax Dax Boss Joker Class
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


#define MAX_BOSSJOKERS 0

type BossJoker
	
	enum E_STATE
		STATE_FALLING = 0,
		STATE_MOVE_RIGHT,
		STATE_MOVE_LEFT,
		STATE_MOVE_UP,
		STATE_MOVE_DOWN,
		STATE_STUNNED,
		STATE_FIRE,
		STATE_IDLE,
		STATE_MORPH,
		STATE_BOUNCE,
		STATE_JUMPING,
	end enum
	
	enum
		NORMAL = 0,
		REVERSE = 1
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
	declare property GetHP() as integer
	declare property GetOldHP() as integer
	declare property GetMaxHP() as integer
	
	declare sub Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	declare sub Update( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	declare sub Explode()
	declare sub Kill()
	declare sub Draw( SpriteSet() as GL2D.IMAGE ptr )
	declare sub DrawStatus( SpriteSet() as GL2D.IMAGE ptr )
	declare sub CollideWithPlayer( byref Snipe as Player )
	declare function CollideWithAABB( byref Box as const AABB ) as integer
	declare sub DrawAABB()
	declare sub DrawStatus()
		
private:
	
	declare Sub ActionIdle( Map() as TileType )
	declare Sub ActionMorph( Map() as TileType )
	declare Sub ActionBounce( byval SnipeX as integer, Map() as TileType )
	declare Sub ActionFalling( Map() as TileType )
	declare Sub ActionMoveRightNormal( Map() as TileType )
	declare Sub ActionMoveLeftNormal( Map() as TileType )
	declare Sub ActionMoveUpNormal( Map() as TileType )
	declare Sub ActionMoveDownNormal( Map() as TileType )
	declare Sub ActionMoveRightReverse( Map() as TileType )
	declare Sub ActionMoveLeftReverse( Map() as TileType )
	declare Sub ActionMoveUpReverse( Map() as TileType )
	declare Sub ActionMoveDownReverse( Map() as TileType )
	declare function CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	declare function CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer	
	declare function CollideOnMap( Map() as TileType ) as integer
	declare sub FallDown()
	
	as integer Active
	as integer Counter
	as integer FlipMode
	as integer Orientation
	as integer Rotation
	as integer WheelRotation
	as integer TurnCounter 
	
	as integer State
	
	as integer IdleCounter
	as integer StunnedCounter
	as integer InvincibleCounter
	
	as integer HP
	as integer OldHP
	
	as single Speed
	as single x
	as single y
	as single ClownX
	as single ClownY
	as single Dx
	as single Dy
	as single ClownDx
	as single ClownDy
	as single Interpolator
	as integer BounceCount
	
	as integer Frame
	as integer BaseFrame
	as integer NumFrames

	as integer Wid
	as integer Hei	
	
	as AABB BoxWheel
	as AABB BoxClown
	as AABB BoxClownSmall
	
	
End Type


type BossJokerFactory

public:

	declare constructor()
	declare destructor()
	
	declare property GetActiveEntities() as Integer
	declare property GetMaxEntities() as Integer
	declare property GetPos( byval i as integer ) as Vector2D
	declare function UpdateEntities( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType ) as integer
	declare sub DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	declare sub DrawEntitiesStatus( SpriteSet() as GL2D.IMAGE ptr )
	declare sub DrawCollisionBoxes()
	declare sub KillAllEntities()
	declare sub HandleCollisions( byref Snipe as Player )
		
	declare sub Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	declare function GetAABB( byval i as integer ) as AABB
	
private:

	as integer ActiveEntities
	as BossJoker BossJokers(MAX_BOSSJOKERS)
	
End Type
