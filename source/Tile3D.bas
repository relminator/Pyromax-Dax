''*****************************************************************************
''
''	Platformer tutorial 101
''
''	Chapter 03-B
''
''  Tiled Map Collision Scrolling
''
''	Relminator (Richard Eric M. Lope)
''	http://rel.phatcode.net
''
''
''  I'm using EASY GL2D for rendering.
'' 	So try to read these tutorials for Easy GL2D..
'' 	http://back2basic.phatcode.net/?Issue_%232:Basic_2D_Rendering_in_OpenGL_using_Easy_GL2D%3A_Part_1
'' 	http://back2basic.phatcode.net/?Issue_%232:Basic_2D_Rendering_in_OpenGL_using_Easy_GL2D%3A_Part_2
''
''*****************************************************************************

#include once "fbgfx.bi"
#include once "FBGL2D7.bi"     	'' We're gonna use Hardware acceleration
#include once "FBGL2D7.bas"		'' So we'll be using my LIB



''*****************************************************************************
const as integer SCREEN_WIDTH = 640
const as integer SCREEN_HEIGHT = 480

const as integer TILE_SIZE = 32

const as integer FALSE = 0
const as integer TRUE = not FALSE

const as single GRAVITY = 0.40
const as single JUMPHEIGHT = 7


''*****************************************************************************
''
''	Our Map
''
''*****************************************************************************

Enum E_TILE_TYPE
	TILE_NONE = 0,
	TILE_SOLID,
	TILE_SLOPE,
	TILE_SLOPE_RIGHT,
	TILE_SLOPE_LEFT,
	TILE_SLOPE_RIGHT_HALF_TOP,
	TILE_SLOPE_RIGHT_HALF_BOT,
	TILE_SLOPE_LEFT_HALF_TOP,
	TILE_SLOPE_LEFT_HALF_BOT,
End Enum

Type TileType
	Index as Integer					'' Used to draw
	Collision as integer				'' Used to collide
End Type

declare sub DrawMap( byval PlayerX as single, byval PlayerY as single, Map() as TileType, spriteset() as GL2D.IMAGE ptr )
declare sub ConvertMap( Map() as TileType, StrMap() as string )



''*****************************************************************************
''
''	Our Player Class
''
''*****************************************************************************
Type Player

public:
	
	'' Player States for Finite State Machine
	Enum E_STATE
		IDLE = 0,
		WALKING,
		JUMPING,
		FALLING,
		BORED,
		PLANT_BOMB,
		LIGHT_DYNAMITE,
		DIED
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
	
	'' length of time before the player gets "bored" standing up 
	Enum 
		BORED_WAIT_TIME = 60 * 3
	End Enum
	
	declare constructor()
	declare destructor()
	
	declare Sub Update( Map() as TileType )			'' This updates the player depending on its State
	declare sub Draw(SpriteSet() as GL2D.IMAGE ptr)				'' Draws the Player according to state
	
	declare property GetX() as Single
	declare property GetY() as Single

	declare property GetCameraX() as Single
	declare property GetCameraY() as Single

private:
	
	declare Sub ActionIdle( Map() as TileType )			''\ 
	declare Sub ActionWalking( Map() as TileType )		'' |  
	declare Sub ActionJumping( Map() as TileType )		'' | 
	declare Sub ActionBored( Map() as TileType)			''  \ These are the functions to be called by Action
	declare Sub ActionFalling( Map() as TileType )		''  / Depending on the Player.State
	declare Sub ActionLightDynamite( Map() as TileType )'' |
	declare Sub ActionPlantBomb( Map() as TileType )	'' |
	declare Sub ActionDied( Map() as TileType )			''/
	
	declare sub ResolveAnimationParameters()	'' Sets up animation params depending on State
	declare sub Animate()						'' Animates the player
	
	declare function CollideOnLine( byval ix as integer, Byval iy as integer, Map() as TileType ) as integer
	declare function CollideWalls(byval ix as integer, byval iy as integer, byref TileX as integer, Map() as TileType ) as integer
	declare function CollideFloors(byval ix as integer, byval iy as integer, byref TileY as integer, Map() as TileType ) as integer
	declare function CollideOnMap( Map() as TileType ) as integer

	x		as single				'' Position
	y		as single
	Dx		as single				'' Direction
	Dy		as Single
	Speed	as single				'' Horizontal Speed
	Wid		as integer				'' Width of the player
	Hei		as integer				
	CanJump as integer				'' If the player can Jump
	
	Counter 	as Integer
	Frame		as Integer
	BaseFrame 	as Integer
	MaxFrame	as Integer	
	FlipMode	as Integer
	
	Direction 		as Integer
	StandingCounter as Integer
	
	State 			as E_STATE				'' State of the player
	
	CameraX	as Integer
	CameraY	as Integer
	
End Type

''*****************************************************************************
''
''*****************************************************************************
constructor Player()
	
	Counter = 0
	x = 32 * 2 
	y = 32 * 6 
	Speed = 2.5
	Wid = 24
	Hei = 30
	CanJump = false
	
	Frame = 0
	BaseFrame = 0
	MaxFrame = 8	
	FlipMode = GL2D.FLIP_NONE
	
	Direction = DIR_RIGHT
	
	CameraX	= 0
	CameraY	= 0
	
	State = FALLING
	StandingCounter = 0
	ResolveAnimationParameters()
	
	
End Constructor

''*****************************************************************************
''
''*****************************************************************************
destructor Player()

End Destructor


''*****************************************************************************
'' Collides the player box with the tiles on the x-axis
''*****************************************************************************
function Player.CollideWalls(byval ix as integer, byval iy as integer, byref TileX as integer, Map() as TileType ) as integer
	
	dim as integer TileYpixels = iy - (iy mod TILE_SIZE)   '' Pixel of the player's head snapped to map grid
	dim as integer TestEnd = (iy + hei)\TILE_SIZE		   '' Foot of the player
	
	TileX = ix\TILE_SIZE								   '' Current X map coord the player is on + x-velocity(+ width when moving right)
	
	dim as integer TileY = TileYpixels\TILE_SIZE		   '' Current Y map coord of the player's head
	
	'' Scan downwards from head to foot if we collided with a tile on the right or left
	while( TileY <= TestEnd )
		if( Map(TileX, TileY).Collision = TILE_SOLID )	then return true	   '' Found a tile
		TileY += 1										   '' Next tile downward
	Wend
	
	return false
	
End Function


''*****************************************************************************
'' Collides the player box with the tiles on the y-axis
''*****************************************************************************
function Player.CollideFloors(byval ix as integer, byval iy as integer, byref TileY as integer, Map() as TileType ) as integer
	
	dim as integer TileXpixels = ix - (ix mod TILE_SIZE)
	dim as integer TestEnd = (ix + wid)\TILE_SIZE
	
	TileY = iy\TILE_SIZE
	
	dim as integer TileX = TileXpixels\TILE_SIZE
	
	while (TileX <= TestEnd)
		if (Map(TileX, TileY).Collision = TILE_SOLID )	then return true	
		TileX += 1
	Wend
	
	return false
	
End Function

''*************************************
'' Checks player collisions on the map
''*************************************
function Player.CollideOnMap( Map() as TileType ) as integer
	
	dim as Integer TileX, TileY
	dim as integer CollisionType = COLLIDE_NONE    '' Return value. Assume no collision
	
	if( Dx > 0 ) then 		'' Right movement
		
		if( CollideWalls( x + Dx + Wid, y, TileX, Map() ) ) then    '' (x + Dx + wid) = Right side of player
			x = TileX * TILE_SIZE - Wid - 1							'' Snap left when there's a collision
			CollisionType = COLLIDE_RIGHT
		else
			x += Dx													'' No collision, so move
		EndIf
	
	elseif( Dx < 0 ) then 	'' Left movement																					
		
		if( CollideWalls( x + Dx, y, TileX, Map() ) ) then			'' (x + Dx) = Left side of player
			x = ( TileX + 1 ) * TILE_SIZE + 1						'' Snap to right of tile
			CollisionType = COLLIDE_LEFT
		else
			x += Dx													'' No collision, so move
		EndIf
		
	EndIf
	
	
	if( Dy < 0 ) then   	'' moving Up
		
		if( CollideFloors( x, y + Dy, TileY, Map() ) ) then   		'' hit the roof
			y = ( TileY + 1 ) * TILE_SIZE + 1						'' Snap below the tile
			Dy = 0    												'' Arrest movement
			CollisionType = COLLIDE_CEILING
		else
			y += Dy													'' No collision so move
			Dy += GRAVITY											'' with gravity
		EndIf
			
	else	'' Stationary or moving down
		
		if( CollideFloors( x, y + Dy + Hei, TileY, Map() ) ) then	'' (y + Dy + hei) = Foot of player
			y = ( TileY ) * TILE_SIZE - Hei - 1						'' Snap above the tile
			Dy = 1													'' Set to 1 so that we always collide with floor next frame
			CollisionType = COLLIDE_FLOOR
		else
			y += Dy													'' No collision so move
			Dy += GRAVITY
		EndIf
		
	EndIf
	
	return CollisionType
	
End function

''*****************************************************************************
'' Updates the player according to states
''*****************************************************************************
sub Player.Update( Map() as TileType )

	Counter += 1
	Animate()
	
	'' Check to see the Player State and
	'' Update accordingly
	
	'' In my DS game I used function pointers 
	'' But I have no idea how to get and call
	'' function pointers of class methods in FB
	'' so I used select case which is not too bad.
	Select Case State
		case IDLE:
			ActionIdle( Map() )
		case WALKING:
			StandingCounter = 0    '' Set bored counter to zero since we don't want to get bored while walking
			ActionWalking( Map() )
		case JUMPING:
			StandingCounter = 0
			ActionJumping( Map() )
		case FALLING:
			StandingCounter = 0
			ActionFalling( Map() )
		case BORED:
			StandingCounter = 0
			ActionBored( Map() )
		case LIGHT_DYNAMITE:
			StandingCounter = 0
			ActionLightDynamite( Map() )
		case PLANT_BOMB:
			StandingCounter = 0
			ActionPlantBomb( Map() )
		case DIED:
			StandingCounter = 0
			ActionDied( Map() )
	End Select
    
    const as integer SCREEN_MID_X = SCREEN_WIDTH \ 2
	const as integer SCREEN_MID_Y = SCREEN_HEIGHT \ 2
	
	'' map dimensions
	dim as integer MAP_WIDTH = Ubound(Map,1)
	dim as integer MAP_HEIGHT = Ubound(Map,2)
	
	dim as integer MAP_MAX_X = MAP_WIDTH * TILE_SIZE - SCREEN_WIDTH	
	dim as integer MAP_MAX_Y = MAP_HEIGHT * TILE_SIZE - SCREEN_HEIGHT	
	
	
	CameraX = x - SCREEN_MID_X
	CameraY = y - SCREEN_MID_Y
	
	if( CameraX < 0 ) then CameraX = 0
	if( CameraY < 0 ) then CameraY = 0
	
	if( CameraX > MAP_MAX_X ) then CameraX = MAP_MAX_X
	if( CameraY > MAP_MAX_Y ) then CameraY = MAP_MAX_Y
	
End Sub

''*****************************************************************************
'' Called when player is not moving and standing on the ground
''*****************************************************************************
Sub Player.ActionIdle( Map() as TileType )
	
	Dx = 0  '' Set speed to 0
	
	'' Did we dilly-dally too long?
	'' If so get "bored"
	StandingCounter += 1
	if( StandingCounter > BORED_WAIT_TIME ) then
		State = BORED
		ResolveAnimationParameters()
	EndIf
	
	'' If we pressed left then we walk negatively
	'' and we set the State to WALKING since we moved
	if multikey(FB.SC_LEFT) then 
		Dx = -speed
		State = WALKING
		Direction = DIR_LEFT
		ResolveAnimationParameters()
	EndIf
	
	'' See comments above
    if multikey(FB.SC_RIGHT) then 
    	Dx = speed
    	State = WALKING
    	Direction = DIR_RIGHT
		ResolveAnimationParameters()
    EndIf
    
    '' We can Light a dynamite while standing
    if multikey(FB.SC_Z) then 
    	State = LIGHT_DYNAMITE
		ResolveAnimationParameters()
    EndIf
    
    '' We can plant bombs while standing
    if multikey(FB.SC_X) then 
    	State = PLANT_BOMB
		ResolveAnimationParameters()
    EndIf
    
    '' We can die while standing
    if multikey(FB.SC_C) then 
    	State = DIED
    	Dy = -JUMPHEIGHT	'' Mario Style death		
		ResolveAnimationParameters()
    EndIf
   
    '' We can jump while not moving so jump when we press space
    '' Then set the state to JUMPING
    if multikey(FB.SC_SPACE) then 
	    if( CanJump ) then
	    	State = JUMPING 		
	    	Dy = -JUMPHEIGHT		'' This makes us jump
	    	CanJump = false			'' We can't jump again while in the middle of Jumping
	    	ResolveAnimationParameters()
	    end if
    EndIf
    
	
	'' If there is a collision handle it	
	dim as Integer Collision = CollideOnMap( Map() )
	if( Collision ) then
		select case Collision
			case COLLIDE_FLOOR:		'' Floor so we can jump again
				if( not multikey(FB.SC_SPACE) )  then CanJump = true '' We hit floor so we can jump again
			case else
		End Select
	else											'' No collision so we are on air
		CanJump = false								'' We can't jump since we are..
		if( Dy > GRAVITY * 6 ) then State = FALLING	'' Falling ( Only fall when we after a certain threshold
    	ResolveAnimationParameters()
	EndIf
	
	
End Sub

''*****************************************************************************
'' Called when player is walking on the ground
''*****************************************************************************
Sub Player.ActionWalking( Map() as TileType )
	
	'' Assume we are not moving so set
	'' State to be idle
	State = IDLE
	
	Dx = 0  '' Set speed to 0
	
	'' If we pressed left then we walk negatively
	'' and we set the State to WALKING since we moved
	if multikey(FB.SC_LEFT) then 
		Dx = -speed
		State = WALKING
		Direction = DIR_LEFT
	EndIf
	
	'' See comments above
    if multikey(FB.SC_RIGHT) then 
    	Dx = speed
    	State = WALKING
    	Direction = DIR_RIGHT
    EndIf
    
    '' We can Light a dynamite while walking
    if multikey(FB.SC_Z) then 
    	State = LIGHT_DYNAMITE
		ResolveAnimationParameters()
    EndIf
    
    '' We can plant bombs while walking
    if multikey(FB.SC_X) then 
    	State = PLANT_BOMB
		ResolveAnimationParameters()
    EndIf
    
    '' We can die while walking
    if multikey(FB.SC_C) then 
    	State = DIED
    	Dy = -JUMPHEIGHT	'' Mario Style death		
		ResolveAnimationParameters()
    EndIf
   
    
    '' We can jump while not moving so jump when we press space
    '' Then set the state to JUMPING
    if multikey(FB.SC_SPACE) then 
	    if( CanJump ) then
	    	State = JUMPING 		
	    	Dy = -JUMPHEIGHT		'' This makes us jump
	    	CanJump = false			'' We can't jump while Jumping
	    	ResolveAnimationParameters()
	    end if
    EndIf
    
	'' If there is a collision handle it	
	dim as Integer Collision = CollideOnMap( Map() )
	if( Collision ) then
		select case Collision
			case COLLIDE_FLOOR:		'' Floor so we can jump again
				if( not multikey(FB.SC_SPACE) )  then CanJump = true '' We hit floor so we can jump again
			case else
		End Select
	else											'' No collision so we are on air
		CanJump = false								'' We can't jump since we are..
		if( Dy > GRAVITY * 6 ) then State = FALLING	'' Falling ( Only fall when we after a certain threshold
    	ResolveAnimationParameters()
	EndIf
	
		
	if( State = IDLE ) then ResolveAnimationParameters()
	
End Sub

''*****************************************************************************
'' Called when player is jumping
''*****************************************************************************
Sub Player.ActionJumping( Map() as TileType )
	
	'' You will notice that there is no way to plant bombs or dynamite within this sub
	'' This is the beauty of FSM. You can limit behaviors depending on your needs.
	'' I didn't want the player to plant bombs or dynamites while jumping or falling so
	'' I just didn't include a check here.
	
	dim as integer Walked = FALSE    '' a way to check if we moved left or right
									 '' Since Dx is single and EPSILON would not look
									 '' good in a tutorial
	
	Dx = 0  '' Set speed to 0
	'' We can move left or right when jumping so...
	
	'' If we pressed left then we walk negatively
	'' and we set the State to WALKING since we moved
	if multikey(FB.SC_LEFT) then 
		Dx = -speed
		Walked = TRUE  			''Set walked to true for checking later 
		Direction = DIR_LEFT
	EndIf
	
	'' See comments above
    if multikey(FB.SC_RIGHT) then 
    	Dx = speed
    	Walked = TRUE
    	Direction = DIR_RIGHT
    EndIf
    
    '' Stop jumping when player stops pressing jump key
    if( not multikey(FB.SC_SPACE) ) then
    	if( Dy < 0 ) then 
    		Dy = 0
    	EndIf
    EndIf
	
    '' We can die while jumping
    if multikey(FB.SC_C) then 
    	State = DIED
    	Dy = -JUMPHEIGHT	'' Mario Style death		
		ResolveAnimationParameters()
    EndIf
   
    
	
	'' If there is a collision handle it	
	dim as Integer Collision = CollideOnMap( Map() )
	if( Collision = COLLIDE_FLOOR ) then
		
		CanJump = FALSE	'' Set this to FALSE since we cannot jump while jumping	
	
		'' Check if we walked or not when we collided with the floor
		if( Walked ) then
			State = WALKING	'' Set the State to WALKING when we hit the floor
			ResolveAnimationParameters()
		else
			State = IDLE	'' Ditto
			ResolveAnimationParameters()
		End If
		
	End If
	
	
End Sub

''*****************************************************************************
'' Called when player is falling
''*****************************************************************************
Sub Player.ActionFalling( Map() as TileType )
	
	'' You will notice that there is no way to plant bombs or dynamite within this sub
	'' This is the beauty of FSM. You can limit behaviors depending on your needs.
	'' I didn't want the player to plant bombs or dynamites while jumping or falling so
	'' I just didn't include a check here.
	
	dim as integer Walked = FALSE    '' a way to check if we moved left or right
									 '' Since Dx is single and EPSILON would not look
									 '' good in a tutorial
	
	Dx = 0  '' Set speed to 0
	'' We can move left or right when falling so...
	
	'' If we pressed left then we walk negatively
	'' and we set the State to WALKING since we moved
	if multikey(FB.SC_LEFT) then 
		Dx = -speed
		Walked = TRUE  			''Set walked to true for checking later 
		Direction = DIR_LEFT
	EndIf
	
	'' See comments above
    if multikey(FB.SC_RIGHT) then 
    	Dx = speed
    	Walked = TRUE
    	Direction = DIR_RIGHT
    EndIf
    
    '' We can die while falling
    if multikey(FB.SC_C) then 
    	State = DIED
    	Dy = -JUMPHEIGHT	'' Mario Style death		
		ResolveAnimationParameters()
    EndIf
   
   
		'' If there is a collision handle it	
	dim as Integer Collision = CollideOnMap( Map() )
	if( Collision = COLLIDE_FLOOR ) then
		
		CanJump = FALSE	'' Set this to FALSE since we cannot jump while jumping	
	
		'' Check if we walked or not
		if( Walked ) then
			State = WALKING	'' Set the State to WALKING when we hit the floor
			ResolveAnimationParameters()
		else
			State = IDLE	'' Ditto
			ResolveAnimationParameters()
		End If
	                
	End If
	
	
End Sub

''*****************************************************************************
'' Called when Player gets bored standing up for a while
''*****************************************************************************
Sub Player.ActionBored( Map() as TileType )
	
	Dx = 0  '' Set speed to 0
	
	'' If we pressed left then we walk negatively
	'' and we set the State to WALKING since we moved
	if multikey(FB.SC_LEFT) then 
		Dx = -speed
		State = WALKING
		Direction = DIR_LEFT
		ResolveAnimationParameters()
	EndIf
	
	'' See comments above
    if multikey(FB.SC_RIGHT) then 
    	Dx = speed
    	State = WALKING
    	Direction = DIR_RIGHT
		ResolveAnimationParameters()
    EndIf
    
    '' We can Light a dynamite while bored
    if multikey(FB.SC_Z) then 
    	State = LIGHT_DYNAMITE
		ResolveAnimationParameters()
    EndIf
    
    '' We can plant bombs while bored
    if multikey(FB.SC_X) then 
    	State = PLANT_BOMB
		ResolveAnimationParameters()
    EndIf
    
    '' We can die while being bored
    if multikey(FB.SC_C) then 
    	State = DIED
    	Dy = -JUMPHEIGHT	'' Mario Style death		
		ResolveAnimationParameters()
    EndIf
   
    '' We can jump while not moving so jump when we press space
    '' Then set the state to JUMPING
    if multikey(FB.SC_SPACE) then 
	    if( CanJump ) then
	    	State = JUMPING 		
	    	Dy = -JUMPHEIGHT		'' This makes us jump
	    	CanJump = false			'' We can't jump while Jumping
	    	ResolveAnimationParameters()
	    end if
    EndIf
    

	dim as Integer Collision = CollideOnMap( Map() )
	if( Collision = COLLIDE_FLOOR ) then
		CanJump = true		'' We hit floor so we can jump again	
	EndIf
	
End Sub


''*****************************************************************************
'' Called when Player lights up a dynamite
''*****************************************************************************
Sub Player.ActionLightDynamite( Map() as TileType )
	
	
	'' We can die while lighting a dynamite
    if multikey(FB.SC_C) then 
    	State = DIED
    	Dy = -JUMPHEIGHT	'' Mario Style death		
		ResolveAnimationParameters()
    EndIf
   
	'' We don't move while lighting up a dynamite
	'' We can only light a dynamite if we are either
	'' STANDING, WALKING, BORED
	'' We can't light a Dynamite while Jumping
	Dx = 0  '' Set speed to 0
	Dy = 0	
	if( Frame = (MaxFrame-1) ) then
		State = IDLE
		ResolveAnimationParameters()
	EndIf
	
End Sub

''*****************************************************************************
'' Called when Player lights up a dynamite
''*****************************************************************************
Sub Player.ActionPlantBomb( Map() as TileType )
	
	'' We can die while planting bombs
    if multikey(FB.SC_C) then 
    	State = DIED
    	Dy = -JUMPHEIGHT	'' Mario Style death		
		ResolveAnimationParameters()
    EndIf
   
   '' We don't move while Planting Bombs
	'' We can only Plant bombs if we are either
	'' STANDING, WALKING, BORED
	'' We can't Plant bombs while Jumping
	Dx = 0  '' Set speed to 0
	Dy = 0	
	if( Frame = (MaxFrame-1) ) then
		State = IDLE
		ResolveAnimationParameters()
	EndIf
	
End Sub


''*****************************************************************************
'' Called when player is dead
''*****************************************************************************
Sub Player.ActionDied( Map() as TileType )

	'' We can't do anything except fall down when dying so no checks for
	'' walking, jumping, dynamite, bombs, etc.
	Dx = 0
	dim as Integer Collision = CollideOnMap( Map() )
	if( Collision = COLLIDE_FLOOR ) then
		State = IDLE
		ResolveAnimationParameters()	
	EndIf
	
	
End Sub


''*****************************************************************************
'' Draws the player according to state
''*****************************************************************************
sub Player.Draw(SpriteSet() as GL2D.IMAGE ptr)

	
    '' Calculate the offset of the sprite in regard to TILE_SIZE
	'' since Wid = 24 and TILE_SIZE = 32
	'' Same with Y
	dim as integer xoff = ( TILE_SIZE - Wid ) / 2		
	dim as integer yoff = ( TILE_SIZE - Hei ) / 2	
	GL2D.Sprite3D( x - xoff, y - yoff, 0, Flipmode, SpriteSet(BaseFrame + Frame))
	
	
end sub

''*****************************************************************************
'' Animates the player
''*****************************************************************************
Sub Player.Animate()
	
	If( (Counter and 3) = 0 ) Then
		Frame = ( Frame + 1 ) mod MaxFrame
	EndIf
	
	if( Direction = DIR_RIGHT ) then
		FlipMode = GL2D.FLIP_NONE
	else
		FlipMode = GL2D.FLIP_H
	EndIf
	
End Sub


''*****************************************************************************
'' Sets up animation frames depending on current state
''*****************************************************************************
sub Player.ResolveAnimationParameters()
	
	Select Case State
		case IDLE:
			Frame = 0
			BaseFrame = 16
			MaxFrame = 1	
		case WALKING:
			Frame = 0
			BaseFrame = 0
			MaxFrame = 8
		case JUMPING:
			Frame = 0
			BaseFrame = 17
			MaxFrame = 1
		case FALLING:
			Frame = 0
			BaseFrame = 17
			MaxFrame = 1
		case BORED:
			Frame = 0
			BaseFrame = 9
			MaxFrame = 7
		case LIGHT_DYNAMITE:
			Frame = 0
			BaseFrame = 18
			MaxFrame = 7   '' offset by 1 so that all the frames get drawn
						   '' for we will change states after animation is done
		case PLANT_BOMB:
			Frame = 0
			BaseFrame = 24
			MaxFrame = 5   '' offset by 1 so that all the frames get drawn
						   '' for we will change states after animation is done
		case DIED:
			Frame = 0
			BaseFrame = 28
			MaxFrame = 4   
		End Select
    
End Sub


property Player.GetX() as Single
	Property = x
End Property

property Player.GetY() as Single
	Property = y
End Property


property Player.GetCameraX() as Single
	Property = CameraX
End Property

property Player.GetCameraY() as Single
	Property = CameraY
End Property


''*****************************************************************************
''
''	Vector3D class needed by the camera class
''
''*****************************************************************************
Type Vector3D

	x as Single
	y as Single
	z as single
	
end type


''*****************************************************************************
''
''	Simple camera class that just follows the player position
''
''*****************************************************************************
Type Camera
	
	
	declare Constructor()
	declare sub Follow( x as single, y as single, Map() as TileType )
	declare sub Look()
	declare sub Look( value as single )
	declare sub Zoom( value as single )

	
	'' Variables for gluLookAt() transform
	Position as Vector3D 
	Target as Vector3D 
	Up as Vector3D 
	
	EyeDistanceFromScreen as integer	'' The distance of your eye from screen

end type


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
	

''*****************************************************************************
'' Our main sub
''*****************************************************************************
sub main()

	
	'' Our map for drawing and collision
	'' On a real tilebased engine, it is better to use another
	'' map for collision aka "collision maps"
	dim as TileType Map()
	
	'' Temporary string array for easy map making
	'' See ConvertMap() and "Tiles.BMP" for more details
	'' @ = Tile 1 
	'' # = Tile 2
	'' () = Tile 3 and 4 
	dim as String TempMap(30) =>_
	{	"++++++++++++++++++++++++++++++++++++++++",_  		'' 0
		"+                                      +",_		'' 1
		"+                                      +",_		'' 2
		"+           #######           #######  +",_		'' 3
		"+         #                 #          +",_		'' 4
		"+#######           #######             +",_		'' 5
		"+       #     ## ##       #     ## ##  +",_		'' 6
		"+                                      +",_		'' 7
		"+       ####              ####         +",_		'' 8
		"+             #                 #      +",_		'' 9
		"+     ##                ##             +",_		'' 0
		"+          #####           # #####     +",_		'' 1
		"+ +      ##     ##  ###    ##     ##   +",_		'' 2
		"+                                      +",_		'' 3
		"+#######           +++++++             +",_		'' 5
		"+       #     ++ ++       #     ## ##  +",_		'' 6
		"+         +                  #         +",_		'' 7
		"+                                      +",_		'' 8
		"+           +##                        +",_		'' 9
		"+         #                            +",_		'' 0
		"+########                              +",_		'' 1
		"+       ##  +++++++++++++++++++++++++  +",_		'' 2
		"+                                      +",_		'' 3
		"+       ####              ####         +",_		'' 4
		"+             #   ++++          #      +",_		'' 5
		"+           +          +               +",_		'' 6
		"+                  ++++++++++++        +",_		'' 7
		"+     ++++++++++                       +",_		'' 8
		"+                                      +",_		'' 9
		"+######################################+"	}		'' 0   
	    '01234567890123456789

	'' Convert the Ascii map to a 2D integer map
	ConvertMap( Map(), TempMap() )

	
	redim as GL2D.IMAGE ptr GripeImages(0)
	redim as GL2D.IMAGE ptr TileSImages(0)
	
	
	dim as Player Gripe
	dim as Camera Cam
	 
	GL2D.ScreenInit( SCREEN_WIDTH, SCREEN_HEIGHT )   ''Set up GL screen
	GL2D.VsyncON()
	
	GL2D.InitSprites( GripeImages(), 32,32, "gripe.bmp", GL_NEAREST )
	GL2D.InitSprites( TilesImages(), 32,32, "tiles.bmp", GL_NEAREST )
	
	const as double FIXED_TIME_STEP = 1/60.0		'' set it up so that logic runs at 60 fps
	dim as integer Frame = 0
	dim as double dt = 0 
	dim as double accumulator = 0
	dim as double FPS = 60
	
	do
		
		dim as double dt = GL2D.GetDeltaTime( FPS, timer )
		if( multikey(FB.SC_1) ) then dt /= 2.0      '' slowdown
		if( multikey(FB.SC_2) ) then dt *= 2.0		'' speedup
		if( multikey(FB.SC_3) ) then dt = 0.0		'' pause
		
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			Gripe.Update( Map() )     '' Do player movements
    		accumulator -= FIXED_TIME_STEP
			
		wend
		
		
    	'' Zoom if you want
		if( multikey(FB.SC_F2) ) then Cam.Zoom(10)
		if( multikey(FB.SC_F3) ) then Cam.Zoom(-10)  
		
		
		'' Set up some opengl crap (some are not needed)
		glMatrixMode( GL_MODELVIEW )
		glLoadIdentity() 
		glPolygonMode( GL_FRONT, GL_FILL )
		glPolygonMode( GL_BACK, GL_FILL )
		glEnable( GL_DEPTH_TEST )
		glDepthFunc( GL_LEQUAL )
		
		glEnable( GL_TEXTURE_2D )
		glEnable( GL_ALPHA_TEST )
		glAlphaFunc(GL_GREATER, 0)

		GL2D.ClearScreen()
		
		glColor4ub( 255, 255, 255, 255 )

		'' Move cam according to player's pos
		Cam.Follow( Gripe.GetX, Gripe.GetY, Map() )
		
		'' reverse y direction for oldskool coords(FBGFX friendly)
		glScalef( 1, -1, 1 )
		
		'' Look
		Cam.Look()
		
		
		'' Draw 3D stuff
		glPushMatrix()   
		
				
			'' Use Tiles texture
			DrawMap( Gripe.GetX, Gripe.GetY, Map(), TilesImages() )
			
			'' Disable depth testing for sprites
			'' Draw Player
			Gripe.Draw( GripeImages() )
		
			
		glPopMatrix()    
		
		
		GL2D.Begin2D()
			
			
			
			GL2D.PrintScale(0,  0, 1, "3D game with 2D collisions")    
			GL2D.PrintScale(0,  10, 1, "Code by Relminator")    
			GL2D.PrintScale(0,  20, 1, "Sprites made by Marc Russell (SpicyPixel.Net)")    
			
			
			'GL2D.PrintScale(0,  170, 1, str(ubound(map,1)) )    
		
		GL2D.End2D()
		
		
		
		sleep 1,1
		flip
		
	Loop until multikey(FB.SC_ESCAPE)

	GL2D.DestroySprites( GripeImages() )
	GL2D.DestroySprites( TilesImages() )

	GL2D.ShutDown()
	
End Sub


''*************************************
'' Converts an Ascii map to integer map 
''*************************************
sub ConvertMap( Map() as TileType, StrMap() as string )
	
	'' Resize array according to size of ascii map
	redim Map(len(Strmap(0)), ubound(StrMap) )
	
	'' @ = Tile 1 
	'' # = Tile 2
	'' Only used 4 tiles
	 
	for y as integer = 0 to ubound(StrMap)	
		for x as integer = 1 to Len(StrMap(y))
			dim as string a = Mid(StrMap(y), x, 1)
			select case a
				case "#"
					Map(x-1,y).Index = 1
					Map(x-1,y).Collision = TILE_SOLID
				case "+"
					Map(x-1,y).Index = 2
					Map(x-1,y).Collision = TILE_SOLID
				case "X"
					Map(x-1,y).Index = 3
					Map(x-1,y).Collision = TILE_SOLID
				case else	
					Map(x-1,y).Index = 0
					Map(x-1,y).Collision = 0
			End Select
		Next
	Next

	
End Sub



''*****************************************************************************
''
''  Routines for this engine
''
''*****************************************************************************

''*************************************
'' Draws the map in 3D
'' Only draws what can be seen so this
'' is fast
''*************************************
sub DrawMap( byval PlayerX as single, byval PlayerY as single, Map() as TileType, spriteset() as GL2D.IMAGE ptr )
	
	'' Need this for some extra tiles to draw
	'' outside the screen dimensions since when you zoom out
	'' the number of tiles needed to draw increases
	const as integer SCROLL_OFFSET = TILE_SIZE * 4	
	
	'' Recalculate new "virtual" screen dimensions		
	const as integer SCREEN_W = SCREEN_WIDTH + SCROLL_OFFSET
	const as integer SCREEN_H = SCREEN_HEIGHT + SCROLL_OFFSET
	
	'' map dimensions
	dim as integer MAP_WID = Ubound(Map,1) + 1
	dim as integer MAP_HEI = Ubound(Map,2) + 1
	
	'' Number of Tiles we draw at one time ( Just a screenfull of it)
	const as integer ScreenTilesX = (SCREEN_W \ TILE_SIZE)
	const as integer ScreenTilesY = (SCREEN_H \ TILE_SIZE)
	
	'' Starting tiles = (Player - Halfscreen) \ TileSize
	dim as integer TileX = ( PlayerX - SCREEN_W \ 2 ) \ TILE_SIZE
	dim as integer TileY = ( PlayerY - SCREEN_H \ 2 ) \ TILE_SIZE
	
	'' Limit left-top
	if( TileX < 0 ) then TileX = 0
	if( TileY < 0 ) then TileY = 0
	
	'' Limit right = (Player - Halfscreen) \ TileSize
	dim as integer MaxX = MAP_WID - ScreenTilesX 
	if( TileX > MaxX ) then TileX = MaxX
	
	'' Limit bottom
	dim as integer MaxY = MAP_HEI - ScreenTilesY 
	if( TileY > MaxY ) then TileY = MaxY
	
	glPushMatrix()					'' Just to be safe since we are scaling below
	
	'' Read Tile values on the 2D array
	'' Then draw if not empty(0)
	for y as integer = TileY to  (TileY + (ScreenTilesY - 1))
		for x as integer = TileX to (TileX + (ScreenTilesX - 1))
			dim as TileType Tile = Map(x,y)
			if( Tile.Index > 0 ) then
				'' Could have done DrawCube(.....,Spriteset(Tile-1)) 
				'' but this is supposed to teach algo not speed
				glPushMatrix()
					glScalef( 1.0 , 1.0,2.0 )
					GL2D.DrawCube( x * TILE_SIZE, y * TILE_SIZE, 0, TILE_SIZE, Spriteset(Tile.Index-1) )
				glPopMatrix()
			end if
		next x	
	next y
	

	
	glPopMatrix()
	
end sub




''*****************************************************************************
''
''
''
''*****************************************************************************


main()


end




