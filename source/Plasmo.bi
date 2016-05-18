''*****************************************************************************
''
''
''	Pyromax Dax Plasmo Class
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


#define MAX_PLASMOS 15

type Plasmo
	
	
	enum E_STATE
		STATE_FALLING = 0,
		STATE_MOVE_RIGHT,
		STATE_MOVE_LEFT,
		STATE_MOVE_UP,
		STATE_MOVE_DOWN,
	end enum
	
	enum
		NORMAL = 0,
		REVERSE = 1
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
	declare function CheckDiagonalTiles( byval xOffset as integer, byval yOffset as integer, Map() as TileType ) as integer  
	declare sub FallDown()
	
	as integer Active
	as integer Counter
	as integer FlipMode
	as integer Rotation
	as integer Orientation
	as integer TurnCounter 
	as integer State
	
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


type PlasmoFactory

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
	as Plasmo Plasmos(MAX_PLASMOS)
	
End Type
