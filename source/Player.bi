''*****************************************************************************
''
''
''	Pyromax Dax Player Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "fbgfx.bi"
#include once "FBGL2D7.bi"     	'' We're gonna use Hardware acceleration
#include once "UTIL.bi"
#include once "Vector2D.bi"
#include once "AABB.bi"

#include once "Map.bi"

#include once "Keyboard.bi"
#include once "Joystick.bi"
#include once "Sound.bi"

#include once "Particles.bi"
#include once "Explosion.bi"
#include once "LeavesParticle.bi"


#include once "Bomb.bi"
#include once "Dynamite.bi"
#include once "Mine.bi"

#define MAX_SHADOWS 8
#define MAX_SHOTS 7
#define SHOT_DELAY 30
#define SHOT_SPEED 6

#define MAX_BOMBS 3
#define MAX_DYNAMITES 3
#define MAX_MINES 3
#define INCENDIARY_MAX_DELAY (60 * 1)
#define MAX_INVINCIBLE_COUNT ( 60 * 3)

#define SHOT_ATTACK_ENERGY 5
#define BOMB_ATTACK_ENERGY 7
#define DYNAMITE_ATTACK_ENERGY 7
#define MINE_ATTACK_ENERGY 7

Type Shadow
	as single x
	as single y
End Type

Type Shot
	
	as integer Active
	as integer Counter
	as integer Frame
	
	as single x
	as single y
	as single Dx
	
	as AABB BoxNormal
	
End Type
''*****************************************************************************
''
''	Player Class
''
''*****************************************************************************
Type Player

public:
	
	'' Player States for Finite State Machine
	Enum E_STATE
		IDLE = 0,
		WALKING,
		BREAKING,
		JUMPING,
		FALLING,
		BOUNCING,
		BORED,
		LIGHT_AEROSOL,
		PLANT_BOMB,
		PLANT_DYNAMITE,
		PLANT_MINE,
		GOT_HIT,
		DIE,
		DEAD
	End Enum
	
	'' Direction our player is facing for flipmode
	Enum E_DIRECTION
		DIR_RIGHT = 0,
		DIR_LEFT,
		DIR_UP,
		DIR_DOWN	
	End Enum
	
	'' Collision status returned when we collide with map
	Enum E_COLLISION
		COLLIDE_NONE = 0,
		COLLIDE_RIGHT,
		COLLIDE_LEFT,
		COLLIDE_CEILING,
		COLLIDE_FLOOR	
	End Enum
	
	Enum E_INCENDIARY
		INCENDIARY_BOMB = 0,
		INCENDIARY_DYNAMITE,
		INCENDIARY_MINE,
		INCENDIARY_SHOT,
		INCENDIARY_STOP
	End Enum
	'' length of time before the player gets "bored" standing up 
	Enum 
		BORED_WAIT_TIME = 60 * 3
	End Enum
	
	declare constructor()
	declare destructor()
	
	declare sub AddLives( byval v as integer )
	declare sub AddHp( byval v as integer )
	declare sub AddBombs( byval v as integer )
	declare sub AddDynamites( byval v as integer )
	declare sub AddMines( byval v as integer )
	declare sub AddToScore( byval v as integer )
	
	declare sub LoadControls( byref filename as string )
	declare sub SetState( byval s as E_STATE)
	declare sub Spawn( byval ix as integer, byval iy as integer, byval direct as integer = DIR_RIGHT )
	declare sub Initialize()
	declare sub Update( byref Key as Keyboard, byref Joy as Joystick, Map() as TileType )			'' This updates the player depending on its State
	declare sub Draw(SpriteSet() as GL2D.IMAGE ptr)				'' Draws the Player according to state
	declare sub DrawIncendiaryMenu( byval activ as integer, byval Angle as integer, byval Radius as integer, byval count as integer, SpriteSet() as GL2D.image ptr )
	declare sub DrawShots(SpriteSet() as GL2D.IMAGE ptr)
	declare sub DrawBombs(SpriteSet() as GL2D.IMAGE ptr)
	declare sub DrawDynamites(SpriteSet() as GL2D.IMAGE ptr)
	declare sub DrawMines(SpriteSet() as GL2D.IMAGE ptr)
	declare sub DrawDebug( byval ix as integer )
	declare sub DrawAABB()
	declare sub HitAnimation( byval ix as integer, byval HpValue as integer = 100 )
	declare sub Kill()
	declare sub ResetAll()
	declare sub ContinueGame()
	
	
	declare Sub CollideShotsPlatforms( byref Box as const AABB )	
	declare Sub CollideBombsPlatforms( byref Box as const AABB )
	declare Sub CollideDynamitesPlatforms( byref Box as const AABB )
	declare Sub CollideMinesPlatforms( byref Box as const AABB )
	
	declare function CollideShots( byref Box as const AABB ) as integer	
	declare function CollideBombs( byref Box as const AABB ) as integer
	declare function CollideDynamites( byref Box as const AABB ) as integer
	declare function CollideMines( byref Box as const AABB ) as integer
	
	declare property SetIncendiaryType( byval v as integer )
	declare property SetInvincible( byval v as integer )
	
	declare property SetScore( byval v as integer )
		
	declare property SetX( byval v as single )
	declare property SetY( byval v as single )
	declare property SetDX( byval v as single )
	declare property SetDY( byval v as single )
	declare property SetSpeed( byval v as single )
	
	declare property SetCanJump( byval v as integer ) 
	declare property SetOnPlatform( byval v as integer ) 
	declare property SetOnSideOfPlatform( byval v as integer ) 
	
	declare property IsActive() as integer
	declare property IsInvincible() as integer
	declare property IsDead() as integer
	declare property IsInWater() as integer
	
	declare property GetState() as integer
	declare property GetLives() as integer
	declare property GetEnergy() as integer
	declare property GetOldEnergy() as integer
	declare property GetBombs() as integer
	declare property GetDynamites() as integer
	declare property GetMines() as integer
	declare property GetScore() as integer
	
	declare property GetX() as Single
	declare property GetY() as Single
	declare property GetDX() as Single
	declare property GetDY() as Single
	declare property GetWid() as Single
	declare property GetHei() as Single

	declare property GetCameraX() as Single
	declare property GetCameraY() as Single

	declare property GetIncendiaryType() as integer
	declare property GetOnPlatform() as integer
	declare property GetBoxNormal() as AABB
	declare property GetBoxSmall() as AABB
	
	
private:
	
	declare property GetCenterFloorTile( Map() as TileType ) as integer	
	declare property GetCenterTile( Map() as TileType ) as integer	
	
	declare Sub ActionIdle( Map() as TileType )			''\ 
	declare Sub ActionWalking( Map() as TileType )		'' |  
	declare Sub ActionBreaking( Map() as TileType )		'' |  
	declare Sub ActionJumping( Map() as TileType )		'' | 
	declare Sub ActionBored( Map() as TileType)			''  \ These are the functions to be called by Action
	declare Sub ActionFalling( Map() as TileType )		''  / Depending on the Player.State
	declare Sub ActionBouncing( Map() as TileType )		'' | 
	declare Sub ActionLightAerosol( Map() as TileType ) '' |
	declare Sub ActionPlantBomb( Map() as TileType )	'' |
	declare Sub ActionPlantDynamite( Map() as TileType )'' |
	declare Sub ActionPlantmine( Map() as TileType )	'' |
	declare Sub ActionGotHit( Map() as TileType )		'' |
	declare Sub ActionDie ( Map() as TileType )			'' |
	declare Sub ActionDead( Map() as TileType )			''/
	
	declare sub ResolveAnimationParameters()				'' Sets up animation params depending on State
	declare sub ResolveTileLocation( Map() as TileType ) 	'' Sets "On" Tile variables
	declare sub Animate()									'' Animates the player
	
	declare function CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	declare function CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	declare function CollideOnMap( Map() as TileType, byref WallCollision as integer = COLLIDE_NONE ) as integer
	declare function CollideOnMapStatic( Map() as TileType ) as integer
	declare function CollideOnMapWind( Map() as TileType ) as integer

	declare sub GetInput( byref Key as Keyboard, byref Joy as Joystick )
	declare sub LimitPosition( Map() as TileType )
	declare sub SelectIncendiaryAction()
	
	declare sub ResetShadows()
	declare sub UpdateShadows()
	declare sub DrawShadows(SpriteSet() as GL2D.IMAGE ptr)
	declare sub SpawnShot()
	declare sub UpdateShots()
	declare sub ResetShots()
	declare Sub CollideShots( Map() as TileType )	
	declare Sub SpawnBomb()
	declare Sub UpdateBombs( Map() as TileType )
	declare Sub SpawnDynamite()
	declare Sub UpdateDynamites( Map() as TileType )
	declare Sub SpawnMine()
	declare Sub UpdateMines( Map() as TileType )
	
	Active	as integer
	
	x		as single				'' Position
	y		as single
	Dx		as single				'' Direction
	Dy		as Single
	Speed	as single				'' Horizontal Speed
	Wid		as integer				'' Width of the player
	Hei		as integer				
	
	CanJump 	as integer				'' If the player can Jump
	
	OnIce as integer
	OnSemiIce as integer
	OnSpike as integer
	OnRubber as integer
	OnRubberWall as integer
	OnMud as integer
	InWater as integer
	InTrigger as integer
	OnPlatform as integer
	OnSideOfPlatform as integer
	
	Counter 	as Integer
	Frame		as Integer
	BaseFrame 	as Integer
	MaxFrame	as Integer	
	FlipMode	as Integer
	
	Direction 		as Integer
	DrawSmoke		as integer
	State 			as E_STATE				'' State of the player
	IncendiaryType  as integer
	IncendiaryDelay as integer
	Energy			as integer
	OldEnergy		as integer
	Lives			as integer
	Score			as integer
	
	IsBouncing		as integer
	Invincible		as integer
	
	StandingCounter 	as Integer
	InvincibleCounter 	as integer
	GotHitCounter  		as integer
	
	BombsLeft  			as integer
	DynamitesLeft	    as integer
	MinesLeft		  	as integer
	
	
	CameraX	as single
	CameraY	as single

	PressedRight as integer
	PressedLeft as integer
	PressedUp as integer
	PressedDown as integer
	PressedJump as integer
	PressedAttack as integer
	PressedDie as integer
	
	KeyUp as integer
	KeyDown as integer
	KeyLeft as integer
	KeyRight as integer
	KeyJump as integer
	KeyAttack as integer
	KeyDie as integer
	KeyOk as integer
	KeyCancel as integer
	
	JoyJump as integer
	JoyAttack as integer
	JoyDie as integer
	JoyOk as integer
	JoyCancel as integer
	
	as AABB BoxNormal
	as AABB BoxSmall
	
	as Shadow Shadows(MAX_SHADOWS)	
	as Shot Shots(MAX_SHOTS)
	as Bomb Bombs(MAX_BOMBS)
	as Dynamite Dynamites(MAX_DYNAMITES)
	as Mine Mines(MAX_DYNAMITES)
	
	
End Type

