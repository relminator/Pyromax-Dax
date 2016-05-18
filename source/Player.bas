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

#include once "Player.bi"

 
''*****************************************************************************
''
''*****************************************************************************
constructor Player()
	
	Counter = 0
	InvincibleCounter =  -1
	GotHitCounter = -1
	
	x = TILE_SIZE * 5 
	y = TILE_SIZE * 14
	 
	Speed = 1
	Wid = 24
	Hei = 26
	CanJump = FALSE
	
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
	
	PressedRight = FALSE
	PressedLeft = FALSE
	PressedUp = FALSE
	PressedDown = FALSE
	PressedJump = FALSE
	PressedAttack = FALSE
	PressedDie = FALSE
	
	KeyUp = FB.SC_UP
	KeyDown = FB.SC_DOWN
	KeyLeft = FB.SC_LEFT
	KeyRight = FB.SC_RIGHT
	KeyJump = FB.SC_SPACE
	KeyAttack = FB.SC_Z
	KeyDie = FB.SC_C
	KeyOk = FB.SC_ENTER
	KeyCancel = FB.SC_ESCAPE
	
	JoyJump = JOY_KEY_2
	JoyAttack = JOY_KEY_1
	JoyOk = JOY_KEY_3
	JoyCancel = JOY_KEY_4
	JoyDie = JOY_KEY_5

	IncendiaryType = INCENDIARY_SHOT
	IncendiaryDelay = INCENDIARY_MAX_DELAY
	
	Energy = 256
	OldEnergy = 256
	Lives = 5
	
	BombsLeft = 0
	DynamitesLeft = 0
	MinesLeft = 0
	
	Score = 0
	
	DrawSmoke = FALSE
	ResetShadows()
	ResetShots()
	
	BoxNormal.Init( x, y, Wid, Hei )
	BoxSmall.Init( x, y, Wid, Hei )
	
End Constructor


''*****************************************************************************
''
''*****************************************************************************
destructor Player()

end destructor

sub Player.AddLives( byval v as integer )
	Lives += v
	if( Lives > 99 ) then Lives = 99
end sub

sub Player.AddHp( byval v as integer )
	Energy += v
	if( Energy > 256 ) then Energy = 256
	OldEnergy = Energy
end sub

sub Player.AddBombs( byval v as integer )
	BombsLeft += v
	if( BombsLeft > 99 ) then BombsLeft = 99
end sub

sub Player.AddDynamites( byval v as integer )
	DynamitesLeft += v
	if( DynamitesLeft > 99 ) then DynamitesLeft = 99
end sub

sub Player.AddMines( byval v as integer )
	MinesLeft += v
	if( MinesLeft > 99 ) then MinesLeft = 99
end sub

sub Player.AddtoScore( byval v as integer )
	Score += v
	if( Score > 9999999 ) then Score = 9999999
end sub
	
sub Player.LoadControls( byref filename as string )
	
	dim as integer f = FreeFile
	if( open( filename for binary as #f ) = 0 ) then
		
		get #f,, KeyUp
		get #f,, KeyDown 
		get #f,, KeyLeft 
		get #f,, KeyRight 
		get #f,, KeyJump 
		get #f,, KeyAttack 
		get #f,, KeyOk 
		get #f,, KeyCancel
		get #f,, KeyDie 
		get #f,, JoyJump 
		get #f,, JoyAttack 
		get #f,, JoyOk 
		get #f,, JoyCancel 
		get #f,, JoyDie 
		
		close #f
	 
	endif

	
end sub


sub Player.SetState( byval s as E_STATE )
	State = s
	ResolveAnimationParameters()
End Sub

''*****************************************************************************
''
''*****************************************************************************
sub Player.Spawn( byval ix as integer, byval iy as integer, byval direct as integer = DIR_RIGHT )
	
	Counter = 0
	InvincibleCounter = MAX_INVINCIBLE_COUNT
	Invincible = TRUE
	
	x = ix 
	y = iy 
	Dx = 0
	Dy = 1
	 
	Speed = 1
	Wid = 24
	Hei = 26
	CanJump = FALSE
	
	Frame = 0
	BaseFrame = 0
	MaxFrame = 8	
	
	Direction = Direct
	
	if( Direction = DIR_RIGHT ) then
		FlipMode = GL2D.FLIP_NONE
	else
		FlipMode = GL2D.FLIP_H
	endif
	
	CameraX	= 0
	CameraY	= 0
	
	State = FALLING
	StandingCounter = 0
	
	ResolveAnimationParameters()
	
	PressedRight = FALSE
	PressedLeft = FALSE
	PressedUp = FALSE
	PressedDown = FALSE
	PressedJump = FALSE
	PressedAttack = FALSE
	PressedDie = FALSE
	
	'IncendiaryType = INCENDIARY_SHOT
	'IncendiaryDelay = INCENDIARY_MAX_DELAY
	
	Energy = 256
	OldEnergy = 256
	
	BombsLeft  = 2
	DynamitesLeft = 2
	MinesLeft = 2
		
	DrawSmoke = FALSE
	ResetShadows()
	'ResetShots()
	
	BoxNormal.Init( x, y, Wid, Hei )
	BoxSmall.Init( x, y, Wid, Hei )
	
end sub

sub Player.Initialize()
	
	Counter = 0
	InvincibleCounter =  -1
	GotHitCounter = -1
	
	x = TILE_SIZE * 5 
	y = TILE_SIZE * 14
	
	Dx = 0
	Dy = 0 
	 
	Speed = 1
	Wid = 24
	Hei = 26
	CanJump = FALSE
	
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
	
	PressedRight = FALSE
	PressedLeft = FALSE
	PressedUp = FALSE
	PressedDown = FALSE
	PressedJump = FALSE
	PressedAttack = FALSE
	PressedDie = FALSE
	
	'IncendiaryType = INCENDIARY_SHOT
	'IncendiaryDelay = INCENDIARY_MAX_DELAY
	
	Energy = 256
	OldEnergy = 256
	Lives = 5
	
	BombsLeft = 2
	DynamitesLeft = 2
	MinesLeft = 2
	
	DrawSmoke = FALSE
	ResetShadows()
	ResetShots()
	
	BoxNormal.Init( x, y, Wid, Hei )
	BoxSmall.Init( x, y, Wid, Hei )

end sub	

''*****************************************************************************
'' Collides the player box with the tiles on the x-axis
''*****************************************************************************
function Player.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
	dim as integer TileYpixels = iy - (iy mod TILE_SIZE)   '' Pixel of the player's head snapped to map grid
	dim as integer TestEnd = (iy + hei)\TILE_SIZE		   '' Foot of the player
	
	iTileX = ix\TILE_SIZE								   '' Current X map coord the player is on + x-velocity(+ width when moving right)
	
	dim as integer iTileY = TileYpixels\TILE_SIZE		   '' Current Y map coord of the player's head
	
	'' Scan downwards from head to foot if we collided with a tile on the right or left
	while( iTileY <= TestEnd )
		if( Map(iTileX, iTileY).Collision >= TILE_SOLID ) then
			OnRubberWall =  Map(iTileX, iTileY).Collision = TILE_RUBBER
			return TRUE	   '' Found a tile
		EndIf
		iTileY += 1										   '' Next tile downward
	Wend
	
	return FALSE
	
End Function


''*****************************************************************************
'' Collides the player box with the tiles on the y-axis
''*****************************************************************************
function Player.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
	dim as integer TileXpixels = ix - (ix mod TILE_SIZE)
	dim as integer TestEnd = (ix + wid)\TILE_SIZE
	
	iTileY = iy\TILE_SIZE
	
	dim as integer iTileX = TileXpixels\TILE_SIZE
	
	while(iTileX <= TestEnd)
		if (Map(iTileX, iTileY).Collision >= TILE_SOLID )	then return TRUE	
		iTileX += 1
	Wend
	
	return FALSE
	
End Function

''*************************************
'' Checks player collisions on the map
''*************************************
function Player.CollideOnMap( Map() as TileType, byref WallCollision as integer = COLLIDE_NONE ) as integer
	
	dim as Integer TileX, TileY
	dim as integer CollisionType = COLLIDE_NONE    '' Return value. Assume no collision
	
	'' Handle water physics
	if( InWater ) then 
		if( Speed > 2 ) then Speed = 2 
		Dx *= 0.5
		if( State <> BREAKING ) then
			if( abs(Dx) < 1 ) then   '' Fix stutter when in water and hitting walls
				Dx = 1.1 * sgn(Dx)
			endif
		endif
		if( Dy > 1 ) then
			Dy *= 0.5
		EndIf
	EndIf
	
	if( Dx > 0 ) then 		'' Right movement
		
		if( CollideWalls( int(x + Dx + Wid), int(y), TileX, Map() ) ) then    '' (x + Dx + wid) = Right side of player
			x = TileX * TILE_SIZE - Wid - 1							'' Snap left when there's a collision
			CollisionType = COLLIDE_RIGHT
			WallCollision = CollisionType
		else
			if( OnSideOfPlatform ) then
				CollisionType = COLLIDE_LEFT
				WallCollision = CollisionType
			else	
				x += Dx 													'' No collision, so move
			EndIf
		EndIf
	
	elseif( Dx < 0 ) then 	'' Left movement																					
		'' FB alert!!! Nega stuff needs an int
		if( CollideWalls( int(x + Dx), int(y), TileX, Map() ) ) then			'' (x + Dx) = Left side of player
			x = ( TileX + 1 ) * TILE_SIZE + 1						'' Snap to right of tile
			CollisionType = COLLIDE_LEFT
			WallCollision = CollisionType
		else
			if( OnSideOfPlatform ) then
				CollisionType = COLLIDE_LEFT
				WallCollision = CollisionType
			else	
				x += Dx 													'' No collision, so move
			EndIf
		EndIf
		
	EndIf
	
	
	if( Dy < 0 ) then   	'' moving Up
		
		if( CollideFloors( int(x), int(y + Dy), TileY, Map() ) ) then   		'' hit the roof
			y = ( TileY + 1 ) * TILE_SIZE + 1						'' Snap below the tile
			Dy = 0    												'' Arrest movement
			CollisionType = COLLIDE_CEILING
		else
			y += Dy													'' No collision so move
			Dy += GRAVITY											'' with gravity
		EndIf
			
	else	'' Stationary or moving down
		
		if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	'' (y + Dy + hei) = Foot of player
			y = ( TileY ) * TILE_SIZE - Hei - 1						'' Snap above the tile
			Dy = 1													'' Set to 1 so that we always collide with floor next frame
			CollisionType = COLLIDE_FLOOR
		else
			if( OnPlatform ) then									'' We are standing on a moving platform
				Dy = 1
				CollisionType = COLLIDE_FLOOR
			else	
				y += Dy												'' No collision so move
				Dy += GRAVITY
			endif
		EndIf
		
	EndIf
	
	return CollisionType
	
End function

''*************************************
'' Checks player collisions on the map
'' Only use when on top pf platofrms 
'' and enemies
''*************************************
function Player.CollideOnMapStatic( Map() as TileType ) as integer
	
	dim as Integer TileX, TileY
	
	if( Dx > 0 ) then 		'' Right movement
		
		if( CollideWalls( int(x + Dx + Wid), int(y), TileX, Map() ) ) then    '' (x + Dx + wid) = Right side of player
			x = TileX * TILE_SIZE - Wid - 1							'' Snap left when there's a collision
			return TRUE
		EndIf
	
	elseif( Dx < 0 ) then 	'' Left movement																					
		'' FB alert!!! Nega stuff needs an int
		if( CollideWalls( int(x + Dx), int(y), TileX, Map() ) ) then			'' (x + Dx) = Left side of player
			x = ( TileX + 1 ) * TILE_SIZE + 1						'' Snap to right of tile
			return TRUE
		EndIf
		
	EndIf

	if( Dy < 0 ) then   	'' moving Up
		
		if( CollideFloors( int(x), int(y + Dy), TileY, Map() ) ) then   		'' hit the roof
			y = ( TileY + 1 ) * TILE_SIZE + 1						'' Snap below the tile
			return TRUE
		EndIf
			
	else	'' Stationary or moving down
		
		if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	'' (y + Dy + hei) = Foot of player
			y = ( TileY ) * TILE_SIZE - Hei - 1						'' Snap above the tile
			return TRUE
		EndIf
		
	EndIf
	
	return FALSE
		
end function

''*************************************
'' Checks player collisions on the map
'' Only use when on top pf platofrms 
'' and enemies
''*************************************
function Player.CollideOnMapWind( Map() as TileType ) as integer
	
	dim as Integer TileX, TileY
	dim as single Wx = LeavesParticle.GetWindFactor
	if( Wx > 0 ) then 		'' Right movement
		
		if( CollideWalls( int(x + Wx + Wid), int(y), TileX, Map() ) ) then    '' (x + Dx + wid) = Right side of player
			x = TileX * TILE_SIZE - Wid - 1							'' Snap left when there's a collision
			return TRUE
		else
			x += Wx
		EndIf
	
	elseif( Wx < 0 ) then 	'' Left movement																					
		'' FB alert!!! Nega stuff needs an int
		if( CollideWalls( int(x + Wx), int(y), TileX, Map() ) ) then			'' (x + Dx) = Left side of player
			x = ( TileX + 1 ) * TILE_SIZE + 1						'' Snap to right of tile
			return TRUE
		else
			x += Wx
		EndIf
		
	endif

	
	return FALSE
		
end function

sub Player.GetInput( byref Key as Keyboard, byref Joy as Joystick )

	PressedRight = Key.Held(KeyRight) or Joy.Right 
	PressedLeft = Key.Held(KeyLeft) or Joy.Left 
	PressedUp = Key.Held(KeyUp) or Joy.Up 
	PressedDown = Key.Held(KeyDown) or Joy.Down 
	PressedJump = Key.Held(KeyJump) or Joy.KeyHeld(JoyJump) 
	PressedAttack = Key.Held(KeyAttack) or Joy.KeyHeld(JoyAttack) 
	PressedDie = FALSE 'Key.Pressed(KeyDie) or Joy.KeyPressed(JoyDie) 
	
End Sub

sub Player.LimitPosition( Map() as TileType )
	
	dim as integer MinX = 2 * TILE_SIZE
	dim as integer MaxX = ( Ubound(Map,1) - 3 ) * TILE_SIZE
	
	
	if( x < MinX ) then 
		x = MinX
		Speed = 0
		Dx = 0
	EndIf
	if( x > MaxX ) then 
		x = MaxX
		Speed = 0
		Dx = 0
	EndIf

	
	
End Sub

sub Player.SelectIncendiaryAction()
	
	
	if( IncendiaryType <> INCENDIARY_SHOT ) then
	
		if( IncendiaryDelay < 0 ) then
			select case as const IncendiaryType
				case INCENDIARY_BOMB:
					if( BombsLeft > 0 ) then
						State = PLANT_BOMB
						IncendiaryDelay = INCENDIARY_MAX_DELAY
						ResolveAnimationParameters()
					endif
				case INCENDIARY_DYNAMITE:
					if( DynamitesLeft > 0 ) then
						State = PLANT_DYNAMITE
						IncendiaryDelay = INCENDIARY_MAX_DELAY
						ResolveAnimationParameters()
					endif
				case INCENDIARY_MINE:
					if( MinesLeft > 0 ) then	
						State = PLANT_MINE
						IncendiaryDelay = INCENDIARY_MAX_DELAY
						ResolveAnimationParameters()
					endif
			End Select
		endif
		
	else
		
		SpawnShot()
		State = LIGHT_AEROSOL
		ResolveAnimationParameters()
	
	endif
	
	
End Sub
		
''*****************************************************************************
'' Updates the player according to states
''*****************************************************************************
sub Player.Update( byref Key as Keyboard, byref Joy as Joystick, Map() as TileType )

	Counter += 1
	
	
	IncendiaryDelay -= 1
	InvincibleCounter -= 1
	if( InvincibleCounter < 0 ) then
		Invincible = FALSE
	EndIf
	
	'' Used for animating the life energy ala megaman x4 
	if( OldEnergy > Energy ) then
		OldEnergy -= 1
	endif
	
	'' Check if all of the player sprite is on a spiked tile
	if( (not IsDead) and (not Invincible) ) then	
		if( OnSpike ) then HitAnimation( x + Dx * 5 )
	endif
	
	'' Check for collisions while riding on horizontal platforms and enemies you can ride
	if( OnPlatform ) then
		CollideOnMapStatic( Map() )
	endif
	
	if( (InWater) and (not Invincible) and (State <> DIE) and (State <> DEAD) ) then
		if( (Counter and 3) = 0 ) then 
			Energy -= 1
			Sound.PlaySFX( Sound.SFX_ATTACK )
			if( Energy < 0 ) then 
				Kill()
			endif
		endif
	endif
	
	LimitPosition( Map() )
	GetInput( Key, Joy )
	Animate()
	UpdateShadows()
	
	if( not IsDead ) then
		UpdateShots()
		CollideShots( Map() )	
		UpdateBombs( Map() )
		UpdateDynamites( Map() )
		UpdateMines( Map() )
	endif
	
	ResolveTileLocation( Map() )
	
	BoxNormal.Init( x, y, Wid, Hei + 2 )
	BoxSmall = BoxNormal.GetAABB
	BoxSmall.Resize( 0.3 )
	
	
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
		case BREAKING:
			StandingCounter = 0    '' Set bored counter to zero since we don't want to get bored while walking
			ActionBreaking( Map() )
		case JUMPING:
			StandingCounter = 0
			ActionJumping( Map() )
		case FALLING:
			StandingCounter = 0
			ActionFalling( Map() )
		case BOUNCING:
			StandingCounter = 0
			ActionBouncing( Map() )
		case BORED:
			StandingCounter = 0
			ActionBored( Map() )
		case LIGHT_AEROSOL:
			StandingCounter = 0
			ActionLightAerosol( Map() )
		case PLANT_BOMB:
			StandingCounter = 0
			ActionPlantBomb( Map() )
		case PLANT_DYNAMITE:
			StandingCounter = 0
			ActionPlantDynamite( Map() )
		case PLANT_MINE:
			StandingCounter = 0
			ActionPlantMine( Map() )
		case GOT_HIT:
			StandingCounter = 0
			ActionGotHit( Map() )
		case DIE:
			StandingCounter = 0
			ActionDie( Map() )
		case DEAD:
			StandingCounter = 0
			ActionDead( Map() )
	End Select
    
    '' Do the wind factor
    if( not InWater ) then
 		CollideOnMapWind( Map() )
    endif 
    
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
	Speed = 1
	'' Did we dilly-dally too long?
	'' If so get "bored"
	StandingCounter += 1
	if( StandingCounter > BORED_WAIT_TIME ) then
		State = BORED
		ResolveAnimationParameters()
	EndIf
	
	'' If we pressed left then we walk negatively
	'' and we set the State to WALKING since we moved
	if PressedLeft then 
		State = WALKING
		Direction = DIR_LEFT
		ResolveAnimationParameters()
	EndIf
	
	'' See comments above
    if PressedRight then 
    	State = WALKING
    	Direction = DIR_RIGHT
		ResolveAnimationParameters()
    EndIf
    
    '' We can plant bombs while standing
    if PressedAttack then 
    	SelectIncendiaryAction()
    EndIf
    
    '' We can die while standing
    if PressedDie then
		Kill()
    EndIf
   
    '' We can jump while not moving so jump when we press space
    '' Then set the state to JUMPING
    if PressedJump then 
	    if( CanJump ) then
	    	Sound.PlaySFX( Sound.SFX_JUMP )
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
				if( not OnRubber ) then
					if( PressedJump = FALSE )  then CanJump = TRUE '' We hit floor so we can jump again
					'' Check if we walked or not when we collided with the floor
				else
					CanJump = FALSE	'' Set this to FALSE since we cannot jump while jumping	
					'' bounce
			    	Sound.PlaySFX( Sound.SFX_BOUNCE )
			    	State = BOUNCING
			    	Dy = -JUMPHEIGHT * 0.6	'' This makes us jump
			    	CanJump = FALSE			'' We can't jump while Bouncing
			    	ResolveAnimationParameters()
				EndIf
	
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
	
	if( abs(Dx) > 3 ) then
		if( not InWater ) then Particle.Spawn( Vector3D(x + Wid\2, y + Hei, -2), Vector3D(0, 0, 0), 0, Particle.TINY )
	EndIf	
	
	'' If we pressed left then we walk negatively
	'' and we set the State to WALKING since we moved
	if PressedLeft then 
		if( Dx <= 0 ) then
			Speed += Accel
			Speed -= (Speed * FRICTION)  		
			Dx = -Speed
			State = WALKING
			Direction = DIR_LEFT
		else
	    	State = BREAKING
	    	if( abs(Dx) > 3 ) then DrawSmoke = TRUE
			ResolveAnimationParameters()
		endif
	end if
	
	'' See comments above
	if PressedRight then 
    	if( Dx >= 0 ) then
			Speed += Accel
			Speed -= (Speed * FRICTION)  		
			Dx = Speed
			State = WALKING
			Direction = DIR_RIGHT
    	else
	    	State = BREAKING
	    	if( abs(Dx) > 3 ) then DrawSmoke = TRUE
			ResolveAnimationParameters()
    	endif
	EndIf 
    
    '' Break if we stopped pressing 
    if( not PressedRight ) and ( not PressedLeft )  then
    	State = BREAKING
    	if( abs(Dx) > 3 ) then DrawSmoke = TRUE
    	ResolveAnimationParameters()
    EndIf
    
    if PressedAttack then 
    	if( IncendiaryType = INCENDIARY_SHOT ) then
    		SelectIncendiaryAction()
    	endif
    EndIf
    
    '' We can die while walking
    if PressedDie then 
    	Kill()
    EndIf
   
    
    '' We can jump while not moving so jump when we press space
    '' Then set the state to JUMPING
    if PressedJump then 
	    if( CanJump ) then
	    	Sound.PlaySFX( Sound.SFX_JUMP )
	    	State = JUMPING 		
	    	Dy = -JUMPHEIGHT		'' This makes us jump
	    	CanJump = false			'' We can't jump while Jumping
	    	ResolveAnimationParameters()
	    end if
    EndIf
    
    	'' If there is a collision handle it	
	dim as integer WallCollision = COLLIDE_NONE
	dim as Integer Collision = CollideOnMap( Map(), WallCollision )
	'' Reset speed if collided on wall
	if( WallCollision ) then
		if( OnRubberWall ) then
			Dx = -sgn(Dx) * 3
			Sound.PlaySFX( Sound.SFX_BOUNCE )
		else
			Speed = 1
			Dx = 0
		EndIf
	EndIf

	
	if( Collision ) then
		select case Collision
			case COLLIDE_FLOOR:		'' Floor so we can jump again
				if( not OnRubber ) then
					if( PressedJump = FALSE )  then CanJump = true '' We hit floor so we can jump again
					'' Check if we walked or not when we collided with the floor
				else
					CanJump = FALSE	'' Set this to FALSE since we cannot jump while jumping	
					'' bounce
			    	Sound.PlaySFX( Sound.SFX_BOUNCE )
			    	State = BOUNCING
			    	Dy = -JUMPHEIGHT * 0.6	'' This makes us jump
			    	CanJump = FALSE			'' We can't jump while Bouncing
			    	ResolveAnimationParameters()
				EndIf
	
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
Sub Player.ActionBreaking( Map() as TileType )
	
	'' Assume we are not moving so set
	'' State to be idle
	if( not InWater ) then Particle.Spawn( Vector3D(x + Wid\2, y + Hei, -2), Vector3D(1, 0, 0), 0, Particle.TINY )
	
	'' Slowdown and stop if we get to minimum speed threshold
	if( not OnIce ) then
	
		if( not OnSemiIce ) then
			Dx -= (Dx * DAMPER)
		else
			Dx -= (Dx * ICE_DAMPER)
		endif	
		if( ((Counter and 3) = 0) and DrawSmoke ) then Explosion.Spawn( Vector3D(x + Wid \2, y + Hei - 4, 2), Vector3D(0, 0, 0), Explosion.SMOKE_01 )
	else
		if( abs(Dx) < 2 ) then
			if( Direction = DIR_LEFT) then
				Dx = -2
			else
				Dx = 2
			EndIf
		endif
	EndIf
	
	if( abs(Dx) < MINIMUM_SPEED_THRESHOLD ) then
		DrawSmoke = FALSE
		Speed = 0
		Dx = 0
		State = IDLE
		ResolveAnimationParameters()
	EndIf
	
    '' We can jump while not moving so jump when we press space
    '' Then set the state to JUMPING
    if PressedJump then 
	    if( CanJump ) then
	    	Sound.PlaySFX( Sound.SFX_JUMP )
	    	DrawSmoke = FALSE
	    	State = JUMPING 		
	    	Dy = -JUMPHEIGHT		'' This makes us jump
	    	CanJump = false			'' We can't jump while Jumping
	    	ResolveAnimationParameters()
	    end if
    EndIf
    
    if PressedAttack then 
    	if( IncendiaryType = INCENDIARY_SHOT ) then
    		SelectIncendiaryAction()
    	endif
    EndIf
    
    if PressedDie then 
    	Kill()
    EndIf
   
	'' If there is a collision handle it	
	dim as integer WallCollision = COLLIDE_NONE
	dim as Integer Collision = CollideOnMap( Map(), WallCollision )
	if( WallCollision ) then
		if( OnRubberWall ) then
			Dx = -sgn(Dx) * 3
			Sound.PlaySFX( Sound.SFX_BOUNCE )
		else
			Speed = 0
			Dx = 0
			State = IDLE
			ResolveAnimationParameters()
		endif
	EndIf
	
	if( Collision ) then
		select case Collision
			case COLLIDE_FLOOR:		'' Floor so we can jump again
				
				if( not OnRubber ) then
					if( PressedJump = FALSE )  then CanJump = TRUE '' We hit floor so we can jump again
					'' Check if we walked or not when we collided with the floor
				else
					CanJump = FALSE	'' Set this to FALSE since we cannot jump while jumping	
					'' bounce
			    	Sound.PlaySFX( Sound.SFX_BOUNCE )
			    	State = BOUNCING
			    	Dy = -JUMPHEIGHT * 0.6	'' This makes us jump
			    	CanJump = FALSE			'' We can't jump while Bouncing
			    	ResolveAnimationParameters()
				EndIf
	
			case else
		End Select
	else											'' No collision so we are on air
		CanJump = false								'' We can't jump since we are..
		if( Dy > GRAVITY * 6 ) then State = FALLING	'' Falling ( Only fall when we after a certain threshold
    	ResolveAnimationParameters()
	EndIf
	
		
	
End Sub

''*****************************************************************************
'' Called when player is jumping
''*****************************************************************************
Sub Player.ActionJumping( Map() as TileType )
	
	if( not InWater ) then Particle.Spawn( Vector3D(x + Wid\2, y + Hei, -2), Vector3D(-Dx, -Dy, 0), 0, Particle.TINY )
	
	'' You will notice that there is no way to plant bombs or dynamite within this sub
	'' This is the beauty of FSM. You can limit behaviors depending on your needs.
	'' I didn't want the player to plant bombs or dynamites while jumping or falling so
	'' I just didn't include a check here.
	
	dim as integer Walked = FALSE    '' a way to check if we moved left or right
									 '' Since Dx is single and EPSILON would not look
									 '' good in a tutorial
	
	'' We can move left or right when jumping so...
	
	'' If we pressed left then we walk negatively
	'' and we set the State to WALKING since we moved
	if PressedLeft then 
		if( Dx <= 0 ) then
			Speed += Accel
			Speed -= (Speed * FRICTION)  		
			Dx = -Speed
			Walked = TRUE
			Direction = DIR_LEFT
		else	'' slowdown and change direction
			Speed -= (Speed * DAMPER)  		
			Dx = Speed
			Direction = DIR_LEFT
		endif
	EndIf
	
	'' See comments above
    if PressedRight then
    	if( Dx >= 0 ) then
			Speed += Accel
			Speed -= (Speed * FRICTION)  		
			Dx = Speed
			Walked = TRUE
    		Direction = DIR_RIGHT
    	else
    		Speed -= (Speed * DAMPER)  		
			Dx = -Speed
			Direction = DIR_RIGHT
    	endif
    EndIf
    
    '' Stop jumping when player stops pressing jump key
    if( PressedJump = FALSE ) then
	   	if( Dy < 0 ) then 
	   		Dy = 0
	    EndIf
    EndIf
	
	
	if PressedAttack then 
    	if( IncendiaryType = INCENDIARY_SHOT ) then
    		SelectIncendiaryAction()
    	endif
    EndIf
    
    '' We can die while jumping
   	if PressedDie then 
    	Kill()
    EndIf
   
    
	
	'' If there is a collision handle it	
		'' If there is a collision handle it	
	dim as integer WallCollision = COLLIDE_NONE
	dim as Integer Collision = CollideOnMap( Map(), WallCollision )
	'' Reset speed if collided on wall
	if( WallCollision ) then
		if( OnRubberWall ) then
			Dx = -sgn(Dx) * 3
			Sound.PlaySFX( Sound.SFX_BOUNCE )
		else
			Speed = 1
			Dx = 0
		EndIf
	EndIf

	if( Collision = COLLIDE_FLOOR ) then
		
		CanJump = FALSE	'' Set this to FALSE since we cannot jump while jumping	
	
		if( not OnRubber ) then
			'' Check if we walked or not when we collided with the floor
			if( Walked ) then
				State = WALKING	'' Set the State to WALKING when we hit the floor
				ResolveAnimationParameters()
			else
				State = BREAKING	'' Ditto
				ResolveAnimationParameters()
			End If
		else
			'' bounce
	    	Sound.PlaySFX( Sound.SFX_BOUNCE )
	    	State = BOUNCING
	    	Dy = -JUMPHEIGHT * 0.6		'' This makes us jump
	    	CanJump = FALSE			'' We can't jump while Bouncing
	    	ResolveAnimationParameters()
		EndIf

	End If
	
	
End Sub

''*****************************************************************************
'' Called when player is falling
''*****************************************************************************
Sub Player.ActionFalling( Map() as TileType )
	
	if( not InWater ) then Particle.Spawn( Vector3D(x + Wid\2, y + Hei, -2), Vector3D(-Dx, -Dy, 0), 0, Particle.TINY )
	
	'' You will notice that there is no way to plant bombs or dynamite within this sub
	'' This is the beauty of FSM. You can limit behaviors depending on your needs.
	'' I didn't want the player to plant bombs or dynamites while jumping or falling so
	'' I just didn't include a check here.
	
	dim as integer Walked = FALSE    '' a way to check if we moved left or right
									 '' Since Dx is single and EPSILON would not look
									 '' good in a tutorial
	
	'' We can move left or right when falling so...
	
	'' If we pressed left then we walk negatively
	'' and we set the State to WALKING since we moved
	if PressedLeft then 
		if( Dx <= 0 ) then
			Speed += Accel
			Speed -= (Speed * FRICTION)  		
			Dx = -Speed
			Walked = TRUE
			Direction = DIR_LEFT
		else
			Speed -= (Speed * DAMPER)  		
			Dx = Speed
			Direction = DIR_LEFT
		endif
	EndIf
	
	'' See comments above
    if PressedRight then
    	if( Dx >= 0 ) then
			Speed += Accel
			Speed -= (Speed * FRICTION)  		
			Dx = Speed
			Walked = TRUE
    		Direction = DIR_RIGHT
    	else
    		Speed -= (Speed * DAMPER)  		
			Dx = -Speed
			Direction = DIR_RIGHT
    	endif
    endif
   
   	if PressedAttack then 
    	if( IncendiaryType = INCENDIARY_SHOT ) then
    		SelectIncendiaryAction()
    	endif
    EndIf
    
    '' We can die while falling
    if PressedDie then 
    	Kill()
    EndIf
   
   
		'' If there is a collision handle it	
	dim as integer WallCollision = COLLIDE_NONE
	dim as Integer Collision = CollideOnMap( Map(), WallCollision )
	'' Reset speed if collided on wall
	if( WallCollision ) then
		if( OnRubberWall ) then
			Dx = -sgn(Dx) * 3
			Sound.PlaySFX( Sound.SFX_BOUNCE )
		else
			Speed = 1
			Dx = 0
		EndIf
	EndIf

	if( Collision = COLLIDE_FLOOR ) then
		
		CanJump = FALSE	'' Set this to FALSE since we cannot jump while jumping	
	
		if( not OnRubber ) then
			'' Check if we walked or not when we collided with the floor
			if( Walked ) then
				State = WALKING	'' Set the State to WALKING when we hit the floor
				ResolveAnimationParameters()
			else
				State = BREAKING	'' Ditto
				ResolveAnimationParameters()
			End If
		else
			'' bounce
	    	Sound.PlaySFX( Sound.SFX_BOUNCE )
	    	State = BOUNCING
	    	Dy = -JUMPHEIGHT * 0.6	'' This makes us jump
	    	CanJump = FALSE			'' We can't jump while Bouncing
	    	ResolveAnimationParameters()
		EndIf

	End If
	
	
End Sub

''*****************************************************************************
'' Called when player is bouncing
''*****************************************************************************
Sub Player.ActionBouncing( Map() as TileType )
	
	if( not InWater ) then Particle.Spawn( Vector3D(x + Wid\2, y + Hei, -2), Vector3D(-Dx, -Dy, 0), 0, Particle.TINY )
	
	'' You will notice that there is no way to plant bombs or dynamite within this sub
	'' This is the beauty of FSM. You can limit behaviors depending on your needs.
	'' I didn't want the player to plant bombs or dynamites while jumping or falling so
	'' I just didn't include a check here.
	
	dim as integer Walked = FALSE    '' a way to check if we moved left or right
									 '' Since Dx is single and EPSILON would not look
									 '' good in a tutorial
	
	'' We can move left or right when jumping so...
	
	'' If we pressed left then we walk negatively
	'' and we set the State to WALKING since we moved
	if PressedLeft then 
		if( Dx <= 0 ) then
			Speed += Accel
			Speed -= (Speed * FRICTION)  		
			Dx = -Speed
			Walked = TRUE
			Direction = DIR_LEFT
		else	'' slowdown and change direction
			Speed -= (Speed * DAMPER)  		
			Dx = Speed
			Direction = DIR_LEFT
		endif
	EndIf
	
	'' See comments above
    if PressedRight then
    	if( Dx >= 0 ) then
			Speed += Accel
			Speed -= (Speed * FRICTION)  		
			Dx = Speed
			Walked = TRUE
    		Direction = DIR_RIGHT
    	else
    		Speed -= (Speed * DAMPER)  		
			Dx = -Speed
			Direction = DIR_RIGHT
    	endif
    EndIf
    
	if PressedAttack then 
    	if( IncendiaryType = INCENDIARY_SHOT ) then
    		SelectIncendiaryAction()
    	endif
    EndIf
    
    '' We can die while jumping
   	if PressedDie then 
    	Kill()
    EndIf
   
    	
	'' If there is a collision handle it	
	dim as integer WallCollision = COLLIDE_NONE
	dim as Integer Collision = CollideOnMap( Map(), WallCollision )
	'' Reset speed if collided on wall
	if( WallCollision ) then
		if( OnRubberWall ) then
			Dx = -sgn(Dx) * 3
			Sound.PlaySFX( Sound.SFX_BOUNCE )
		else
			Speed = 1
			Dx = 0
		EndIf
	EndIf
	
	if( Collision = COLLIDE_FLOOR ) then
		
		CanJump = FALSE	'' Set this to FALSE since we cannot jump while jumping	
	
		if( not OnRubber ) then
			'' Check if we walked or not when we collided with the floor
			if( Walked ) then
				State = WALKING	'' Set the State to WALKING when we hit the floor
				ResolveAnimationParameters()
			else
				State = BREAKING	'' Ditto
				ResolveAnimationParameters()
			End If
		else
			'' bounce
	    	Sound.PlaySFX( Sound.SFX_BOUNCE )
	    	State = BOUNCING
	    	'if PressedJump then 
	    	'	Dy = -JUMPHEIGHT*2		'' This makes us jump
	    	'else
	    		Dy = -JUMPHEIGHT * 0.6
	    	'EndIf
	    	CanJump = FALSE			'' We can't jump while Bouncing
	    	ResolveAnimationParameters()
		EndIf
		
	End If
	
	
End Sub

''*****************************************************************************
'' Called when player gets hit
''*****************************************************************************
Sub Player.ActionGotHit( Map() as TileType )
	
	
	if( GotHitCounter >= 0 ) then
		GotHitCounter -= 1
	EndIf
	
	Speed *= 0.90
	if( Direction = DIR_LEFT ) then 
		Dx = -Speed
	else
		Dx = Speed
	endif
	

	'' If there is a collision handle it	
	dim as integer WallCollision = COLLIDE_NONE
	dim as Integer Collision = CollideOnMap( Map(), WallCollision )
	
	'' Reset speed if collided on wall
	if( WallCollision ) then
		if( OnRubberWall ) then
			Dx = -sgn(Dx) * 3
			Sound.PlaySFX( Sound.SFX_BOUNCE )
		else
			Speed = 1
			Dx = 0
		EndIf
	EndIf

	if( GotHitCounter <= 0 ) then
		if( Collision = COLLIDE_FLOOR ) then
			
			CanJump = FALSE	'' Set this to FALSE since we cannot jump while jumping	
		
			if( not OnRubber ) then
				State = BREAKING	'' Ditto
				ResolveAnimationParameters()
			else
				'' bounce
		    	Sound.PlaySFX( Sound.SFX_BOUNCE )
		    	State = BOUNCING
		    	Dy = -JUMPHEIGHT * 0.6		'' This makes us jump
		    	CanJump = FALSE			'' We can't jump while Bouncing
		    	ResolveAnimationParameters()
			EndIf
		else
			State = FALLING
			ResolveAnimationParameters()	
		End If
		
	endif
	
End Sub


''*****************************************************************************
'' Called when Player gets bored standing up for a while
''*****************************************************************************
Sub Player.ActionBored( Map() as TileType )
	
	Dx = 0  '' Set speed to 0
	
	'' If we pressed left then we walk negatively
	'' and we set the State to WALKING since we moved
	if PressedLeft then 
		State = WALKING
		Direction = DIR_LEFT
		ResolveAnimationParameters()
	EndIf
	
	'' See comments above
    if PressedRight then 
    	State = WALKING
    	Direction = DIR_RIGHT
		ResolveAnimationParameters()
    EndIf
    
    
    '' We can plant bombs while bored
    if PressedAttack then 
    	SelectIncendiaryAction()
    EndIf
    
    '' We can die while being bored
    if PressedDie then 
    	Kill()
    EndIf
   
    '' We can jump while not moving so jump when we press space
    '' Then set the state to JUMPING
    if PressedJump then 
	    if( CanJump ) then
	    	Sound.PlaySFX( Sound.SFX_JUMP )
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
Sub Player.ActionLightAerosol( Map() as TileType )
	
	dim as integer a = DEG2RAD(-20 + rnd * 40)
	dim as Vector2D v = Vector2D( cos(a), sin(a) )
	
	
	'' We can die while lighting aerosols
    if PressedDie then 
    	Kill()
    EndIf
   
	OnIce = (GetCenterFloorTile( Map() ) = TILE_ICE)

	'' Slowdown and stop if we get to minimum speed threshold
	if( not OnIce ) then 
		Dx -= (Dx * DAMPER)
	else
		Dx -= (Dx * ICE_DAMPER)
	EndIf
	
	'' Don't move sideways when on top of platform
	if( OnPlatform ) then
		Dx = 0
		Speed = 1
	endif
	
	dim as Integer Collision = CollideOnMap( Map() )
	if( Collision ) then
		select case Collision
			case COLLIDE_FLOOR:		'' Floor so we can jump again
				if( PressedJump = FALSE )  then CanJump = TRUE '' We hit floor so we can jump again
			case else
		end select
		if( Frame = (MaxFrame-1) ) then
			State = IDLE
			ResolveAnimationParameters()
		endif
	else											'' No collision so we are on air
		CanJump = FALSE 							'' We can't jump since we are..
	    if( Frame = (MaxFrame-1) ) then
			State = FALLING
			ResolveAnimationParameters()
		endif
	endif
	
		
	
End Sub

''*****************************************************************************
'' Called when Player Plants a Bomb
''*****************************************************************************
Sub Player.ActionPlantBomb( Map() as TileType )
	
	'' We can die while planting bombs
    if PressedDie then 
    	Kill()
    EndIf
   
   '' We don't move while Planting Bombs
	'' We can only Plant bombs if we are either
	'' STANDING, WALKING, BORED
	'' We can't Plant bombs while Jumping
	Dx = 0  '' Set speed to 0
	'Dy = 0	
	if( Frame = (MaxFrame-1) ) then
		SpawnBomb()
		State = IDLE
		ResolveAnimationParameters()
	EndIf
	
End Sub

''*****************************************************************************
'' Called when Player Plants a Dynamite
''*****************************************************************************
Sub Player.ActionPlantDynamite( Map() as TileType )
	
	 '' We can die while planting a dynamites
    if PressedDie then 
    	Kill()
    EndIf
   
   '' We don't move while Planting Bombs
	'' We can only Plant bombs if we are either
	'' STANDING, WALKING, BORED
	'' We can't Plant bombs while Jumping
	Dx = 0  '' Set speed to 0
	'Dy = 0	
	if( Frame = (MaxFrame-1) ) then
		SpawnDynamite()
		State = IDLE
		ResolveAnimationParameters()
	EndIf
	
End Sub

''*****************************************************************************
'' Called when Player Plants a mine
''*****************************************************************************
Sub Player.ActionPlantMine( Map() as TileType )
	
	 '' We can die while planting a dynamites
    if PressedDie then 
    	Kill()
    EndIf
   
   '' We don't move while Planting Bombs
	'' We can only Plant bombs if we are either
	'' STANDING, WALKING, BORED
	'' We can't Plant bombs while Jumping
	Dx = 0  '' Set speed to 0
	'Dy = 0	
	if( Frame = (MaxFrame-1) ) then
		SpawnMine()
		State = IDLE
		ResolveAnimationParameters()
	EndIf
	
End Sub

''*****************************************************************************
'' Called when player dies
''*****************************************************************************
Sub Player.ActionDie( Map() as TileType )

	'' We can't do anything except fall down when dying so no checks for
	'' walking, jumping, dynamite, bombs, etc.
	Dx = 0
	dim as Integer Collision = CollideOnMap( Map() )
	if( (Collision = COLLIDE_FLOOR) or ( Dy >= JUMPHEIGHT) ) then
		State = DEAD
		ResolveAnimationParameters()	
	EndIf
	
	
End Sub

''*****************************************************************************
'' Called when player is dead
''*****************************************************************************
sub Player.ActionDead( Map() as TileType )

	Dx = 0
	Dy = 0
	Energy = 255
	OldEnergy = 256
	InWater = FALSE
		
end sub

''*****************************************************************************
'' Draws the player according to state
''*****************************************************************************
sub Player.Draw(SpriteSet() as GL2D.IMAGE ptr)

	
	GL2D.SetBlendMode( GL2D.BLEND_ALPHA )
	DrawShadows( SpriteSet() )

    '' Calculate the offset of the sprite in regard to TILE_SIZE
	'' since Wid = 24 and TILE_SIZE = 32
	'' Same with Y
	dim as integer xoff = ( TILE_SIZE - Wid ) / 2		
	dim as integer yoff = ( TILE_SIZE - Hei ) / 2	
	GL2D.SetBlendMode( GL2D.BLEND_TRANS )
	
	if( Invincible ) then
		dim as single c = abs(sin( Counter * 0.75))
		glColor4f( 1 - c, c, c, 1 )
		GL2D.Sprite3D( x - xoff, y - yoff, 0, Flipmode, SpriteSet(BaseFrame + Frame))
	else
		GL2D.Sprite3D( x - xoff, y - yoff, 0, Flipmode, SpriteSet(BaseFrame + Frame))
	endif
	glColor4f( 1, 1, 1, 1 )
	
	GL2D.SetBlendMode( GL2D.BLEND_TRANS )
		
end sub

sub Player.DrawIncendiaryMenu( byval activ as integer, byval Angle as integer, byval Radius as integer, byval count as integer, SpriteSet() as GL2D.image ptr )
	
	const as integer CHOICES = 4
	const as integer DEGREE_STEPS = 360/CHOICES
	
	dim as integer sBaseFrame =0
	dim as integer sFrame = (Count \ 8) and 3
	dim as integer CurrentAngle = Angle 
	dim as single sScale = 1 
	
	dim as single idx = 0
	 
	for i as integer = CurrentAngle to (359+CurrentAngle) step DEGREE_STEPS
		
		dim as integer mx = cos(i * PI/ 180) * Radius
		dim as integer my = sin(i * PI/ 180) * Radius
		
		'if( Direction = DIR_LEFT ) then
		'	mx = -mx
		'	my = -my
		'EndIf
		
		if( idx = activ ) then
			sScale = 1 + abs(sin(Count / 8)) * 2
		else
			sScale = 1
		EndIf
		
		GL2D.SpriteRotateScaleXY3D( x + mx + Wid\2,_
									y + my + Hei\2,_
									FOREGROUND_PLANE,_
									0,_
									sScale,_
									sScale,_
									GL2D.FLIP_NONE,_
									SpriteSet(sFrame + sBaseFrame) )
		
		sBaseFrame = (sBaseFrame + 4) and 15
		idx += 1
		
	next i

		
End Sub
	

sub Player.DrawDebug( byval ix as integer )
	
	GL2D.PrintScale(ix, 0, 0.5, "STATE = " & str(State) )
	GL2D.PrintScale(ix, 10, 0.5, "DX = " & str(Dx) )
	GL2D.PrintScale(ix, 20, 0.5, "DY = " & str(Dy) )
	GL2D.PrintScale(ix, 30, 0.5, "SPEED = " & str(Speed) )
	GL2D.PrintScale(ix, 40, 0.5, "TILEX = " & str(x \ TILE_SIZE) )
	GL2D.PrintScale(ix, 50, 0.5, "TILEY = " & str(y \ TILE_SIZE) )
	GL2D.PrintScale(ix, 60, 0.5, "INCENDIARYTYPE = " & str(IncendiaryType) )
	GL2D.PrintScale(ix, 70, 0.5, "CANJUMP = " & str(CanJump) )
	GL2D.PrintScale(ix, 80, 0.5, "ONPLATFORM = " & str(OnPlatform) )
	GL2D.PrintScale(ix, 90, 0.5, "ISDEAD = " & str(IsDead) )
	GL2D.PrintScale(ix, 100, 0.5, "ENERGY LEFT = " & str(Energy) )
	GL2D.PrintScale(ix, 110, 0.5, "LIVES LEFT = " & str(Lives) )
	
End Sub

sub Player.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 0,255,255 ) )
	BoxSmall.Draw( 4, GL2D_RGB( 0,255,255 ) )

	for i as integer = 0 to MAX_SHOTS
		if( Shots(i).Active ) then 
			Shots(i).BoxNormal.Draw( 4, GL2D_RGB(255,0,255) )
		EndIf
	next
	
	for i as integer = 0 to MAX_BOMBS
		if( Bombs(i).IsActive ) then Bombs(i).DrawAABB()
	Next
	
	for i as integer = 0 to MAX_DYNAMITES
		if( Dynamites(i).IsActive ) then Dynamites(i).DrawAABB()
	Next
	
	for i as integer = 0 to MAX_MINES
		if( Mines(i).IsActive ) then Mines(i).DrawAABB()
	Next
	
	
	
end sub

sub Player.HitAnimation( byval ix as integer, byval HpValue as integer = 100 )
	
	OldEnergy = Energy
	Energy -= HpValue
	
	if( Energy > 0 )then
		
		if( Direction = DIR_LEFT ) then
			Speed = 4
			Dx = Speed
		else
			Speed = 4
			Dx = -Speed
		endif 
		
		Dy = -JUMPHEIGHT * 0.67
		GotHitCounter = 30
		InvincibleCounter = MAX_INVINCIBLE_COUNT
		Invincible = TRUE
		
		Sound.PlaySFX( Sound.SFX_HURT )
		    	
		State = GOT_HIT
		ResolveAnimationParameters()
	
	else
	
		Sound.PlaySFX( Sound.SFX_HURT )
		Kill()
	
	endif
	
End Sub

sub Player.Kill()
	
	Sound.PlaySFX( Sound.SFX_HURT )
		
	Dy = -JUMPHEIGHT
	State = Player.DIE
	ResolveAnimationParameters()
	
	Lives -= 1
	OldEnergy = 0
	
	FlipMode = GL2D.FLIP_NONE
	
	Direction = DIR_RIGHT
	
	IncendiaryType = INCENDIARY_SHOT
	IncendiaryDelay = INCENDIARY_MAX_DELAY
	
end sub

''*****************************************************************************
'' Animates the player
''*****************************************************************************
Sub Player.Animate()
	
	If( (Counter and 3) = 0 ) Then
		Frame = ( Frame + 1 ) mod MaxFrame
	EndIf
	
	if( Direction = DIR_RIGHT ) then
		if( State <> GOT_HIT ) then 
			FlipMode = GL2D.FLIP_NONE
		else
			FlipMode = GL2D.FLIP_H
		endif
	else
		if( State <> GOT_HIT ) then 
			FlipMode = GL2D.FLIP_H
		else
			FlipMode = GL2D.FLIP_NONE
		endif
	EndIf
	
End Sub


''*****************************************************************************
'' Sets up animation frames depending on current state
''*****************************************************************************
sub Player.ResolveAnimationParameters()
	
	Select Case State
		case IDLE:
			Frame = 0
			BaseFrame = 8
			MaxFrame = 1	
		case WALKING:
			Frame = 0
			BaseFrame = 0
			MaxFrame = 8
		case BREAKING:
			Frame = 0
			BaseFrame = 16
			MaxFrame = 4
		case JUMPING:
			Frame = 0
			BaseFrame = 49
			MaxFrame = 1
		case FALLING:
			Frame = 0
			BaseFrame = 49
			MaxFrame = 1
		case BOUNCING:
			Frame = 0
			BaseFrame = 49
			MaxFrame = 1
		case BORED:
			Frame = 0
			BaseFrame = 9
			MaxFrame = 7
		case LIGHT_AEROSOL:
			Frame = 0
			BaseFrame = 32
			MaxFrame = 8   '' offset by 1 so that all the frames get drawn
						   '' for we will change states after animation is done
		case PLANT_BOMB:
			Frame = 0
			BaseFrame = 28
			MaxFrame = 5   '' offset by 1 so that all the frames get drawn
						   '' for we will change states after animation is done
		case PLANT_DYNAMITE:
			Frame = 0
			BaseFrame = 40
			MaxFrame = 5   '' offset by 1 so that all the frames get drawn
						   '' for we will change states after animation is done
		case PLANT_MINE:
			Frame = 0
			BaseFrame = 44
			MaxFrame = 5   '' offset by 1 so that all the frames get drawn
						   '' for we will change states after animation is done
		case GOT_HIT:
			Frame = 0
			BaseFrame = 49
			MaxFrame = 1
		case DIE:
			Frame = 0
			BaseFrame = 20
			MaxFrame = 4   
		case DEAD:
			Frame = 0
			BaseFrame = 20
			MaxFrame = 4   
	End Select
    
End Sub

sub Player.ResolveTileLocation( Map() as TileType )
	
	OnRubberWall = FALSE
	OnIce = GetCenterFloorTile( Map() ) = TILE_ICE
	OnSemiIce = GetCenterFloorTile( Map() ) = TILE_SEMI_ICE
	OnSpike  = (GetCenterFloorTile( Map() ) = TILE_SPIKE_FLOOR )_
			   and (MapUtil.GetTile( x, y + Hei + 1, Map() ) = TILE_SPIKE_FLOOR )_
			   and (MapUtil.GetTile( x + Wid, y + Hei + 1, Map() ) = TILE_SPIKE_FLOOR )_ 
			   or (MapUtil.GetTile( x + Wid\2, y - 2, Map() ) = TILE_SPIKE_CEILING )_
			   and (MapUtil.GetTile( x, y - 2, Map() ) = TILE_SPIKE_CEILING )_
			   and (MapUtil.GetTile( x + Wid, y - 2, Map() ) = TILE_SPIKE_CEILING ) 
			   
	OnRubber = GetCenterFloorTile( Map() ) = TILE_RUBBER
	OnMud = GetCenterTile( Map() ) = TILE_MUD
	InWater = (GetCenterTile( Map() ) = TILE_WATER) or (GetCenterTile( Map() ) = TILE_TOP_WATER)_
			   or (GetCenterTile( Map() ) = TILE_LEFT_WATER) or (GetCenterTile( Map() ) = TILE_RIGHT_WATER)_
			   or (GetCenterTile( Map() ) = TILE_LEFT_RIGHT_WATER)
			     
	InTrigger = GetCenterTile( Map() ) = TILE_TRIGGER
	
End Sub


sub Player.ResetShadows()
	
	for i as integer = 0 to MAX_SHADOWS
		Shadows(i).x = x
		Shadows(i).y = y
	Next
	
End Sub

sub Player.UpdateShadows()
	
	Shadows(0).x = x
	Shadows(0).y = y
	'' Reverse copy
    for i as integer = ( MAX_SHADOWS ) to 1 step -1
        Shadows(i) = Shadows(i-1)
    next i
	
End Sub
	

sub Player.DrawShadows(SpriteSet() as GL2D.IMAGE ptr)
	
	dim as integer xoff = ( TILE_SIZE - Wid ) / 2		
	dim as integer yoff = ( TILE_SIZE - Hei ) / 2
	for i as integer = MAX_SHADOWS to 1 step -1
		dim as single a = 1 - ((i mod MAX_SHADOWS) / MAX_SHADOWS)
		glColor4f( a, a, 1-a, 0.5 - (i / (MAX_SHADOWS*2)) )
		GL2D.Sprite3D( Shadows(i).x - xoff, Shadows(i).y - yoff, -2, Flipmode, SpriteSet(BaseFrame + Frame))
	Next
	
	glColor4f( 1, 1, 1, 1 )
		
End Sub

sub Player.DrawShots(SpriteSet() as GL2D.IMAGE ptr)
	
	for i as integer = 0 to MAX_SHOTS
		if( Shots(i).Active ) then 
			GL2D.Sprite3D( Shots(i).x - 8, Shots(i).y - 8, 2, Flipmode, SpriteSet( 12 + Shots(i).Frame))
		EndIf
	Next

End Sub



sub Player.SpawnShot()

	for i as integer = 0 to MAX_SHOTS
		if( not Shots(i).Active ) then
			Sound.PlaySFX( Sound.SFX_ATTACK )
			Shots(i).Active = TRUE
			Shots(i).x = x + Wid\2
			Shots(i).y = y + Hei\2
			Shots(i).Frame = 0
			Shots(i).Counter = 0
			Shots(i).BoxNormal.Init( Shots(i).x-4, Shots(i).y-4, 8, 8 )
			if( Direction = DIR_LEFT ) then
				Shots(i).Dx = -SHOT_SPEED
			else
				Shots(i).Dx = SHOT_SPEED
			endif
			if( Direction = DIR_RIGHT ) then
				Explosion.Spawn( Vector3D(x + Wid + 10, y + Hei\2, 2), Vector3D(Dx, 0, 0), Explosion.SHOT_BURST_BIG )
			else
				Explosion.Spawn( Vector3D(x - 10, y + Hei\2, 2), Vector3D(Dx, 0, 0), Explosion.SHOT_BURST_BIG, GL2D.FLIP_H )
			endif
			exit for
		endIf
	next
	
End Sub
		
sub Player.UpdateShots()

	for i as integer = 0 to MAX_SHOTS
		if( Shots(i).Active ) then
			Shots(i).x += Shots(i).Dx
			Shots(i).Counter += 1
			Shots(i).BoxNormal.Init( Shots(i).x-4, Shots(i).y-4, 8, 8 )
			if( Shots(i).Counter > 2*60 ) then 
				Shots(i).Active = FALSE
				Shots(i).BoxNormal.Init( -1000, -1000, 8, 8 )
			EndIf
			if( (Shots(i).Counter and 3) = 0 ) then
				Shots(i).Frame = (Shots(i).Frame + 1) and 3 
			EndIf
		EndIf
	Next
	
End Sub

''*****************************************************************************
''
''*****************************************************************************
sub Player.ResetShots()

	for i as integer = 0 to MAX_SHOTS
		Shots(i).Active = FALSE
		Shots(i).Counter = 0
		Shots(i).Frame = 0
		Shots(i).x = -10000
		Shots(i).y = -10000
		Shots(i).BoxNormal.Init( Shots(i).x-4, Shots(i).y-4, 8, 8 )
	Next

end sub

Sub Player.CollideShots( Map() as TileType )	
	
	for i as integer = 0 to MAX_SHOTS
		if( Shots(i).Active ) then
			dim as integer Tx = Shots(i).x \ TILE_SIZE
			dim as integer Ty = Shots(i).y \ TILE_SIZE
			if( Map(Tx,Ty).Collision >= TILE_SOLID ) then
				Particle.Spawn( Vector3D( Shots(i).x, Shots(i).y, 31 ), 8 )
				Shots(i).Active = FALSE
				Shots(i).Counter = 0
				Shots(i).Frame = 0
				Shots(i).x = -10000
				Shots(i).y = -10000
				Sound.PlaySFX( Sound.SFX_EXPLODE )
			EndIf
		EndIf
	Next
	
End Sub

Sub Player.CollideShotsPlatforms( byref Box as const AABB )	
	
	for i as integer = 0 to MAX_SHOTS
		if( Shots(i).Active ) then
			if( Shots(i).BoxNormal.Intersects( Box ) ) then
				Particle.Spawn( Vector3D( Shots(i).x, Shots(i).y, 31 ), 8 )
				Shots(i).Active = FALSE
				Shots(i).Counter = 0
				Shots(i).Frame = 0
				Shots(i).x = -10000
				Shots(i).y = -10000
				Sound.PlaySFX( Sound.SFX_EXPLODE )
			endif
		EndIf
	Next
	
End Sub

function Player.CollideShots( byref Box as const AABB ) as integer	
	
	for i as integer = 0 to MAX_SHOTS
		if( Shots(i).Active ) then
			if( Shots(i).BoxNormal.Intersects( Box ) ) then
				Particle.Spawn( Vector3D( Shots(i).x, Shots(i).y, 31 ), 8 )
				Shots(i).Active = FALSE
				Shots(i).Counter = 0
				Shots(i).Frame = 0
				Shots(i).x = -10000
				Shots(i).y = -10000
				Sound.PlaySFX( Sound.SFX_EXPLODE )
				return SHOT_ATTACK_ENERGY
			endif
		EndIf
	Next
	
end function

''*****************************************************************************
''
''*****************************************************************************
sub Player.DrawBombs(SpriteSet() as GL2D.IMAGE ptr)

	for i as integer = 0 to MAX_BOMBS
		if( Bombs(i).IsActive ) then Bombs(i).Draw(SpriteSet())
	Next
	
End Sub

sub Player.SpawnBomb()
	
	if( BombsLeft > 0 ) then
		for i as integer = 0 to MAX_BOMBS
			if( not Bombs(i).IsActive ) then
				dim as integer offset = -4
				if( Direction = DIR_LEFT ) then
					offset = -12
				EndIf
				Bombs(i).Spawn( x + Wid\2 + offset, y + 8, Direction )
				BombsLeft -= 1
				exit for
			EndIf
		Next
	endif
End Sub
	
sub Player.UpdateBombs( Map() as TileType )

	for i as integer = 0 to MAX_BOMBS
		if( Bombs(i).IsActive ) then
			Bombs(i).Update( Map() )
		EndIf
	Next
	
End Sub

sub Player.CollideBombsPlatforms( byref Box as const AABB  )

	for i as integer = 0 to MAX_BOMBS
		if( Bombs(i).IsActive ) then
			if(Bombs(i).CollideWithAABB( Box ) ) then
				if( Bombs(i).GetY + Bombs(i).GetDy + Bombs(i).GetHei >= Box.y1 ) then
					Bombs(i).SetY = (Box.y1 - Bombs(i).GetHei) + 1
					Bombs(i).SetDy = 1
				endif
			endif
		EndIf
	Next
	
End Sub

function Player.CollideBombs( byref Box as const AABB  ) as integer

	for i as integer = 0 to MAX_BOMBS
		if( Bombs(i).IsActive ) then
			if( Bombs(i).CollideWithAABB( Box ) ) then
				Bombs(i).Explode()
				return BOMB_ATTACK_ENERGY
			endif
		EndIf
	Next
	
	return 0
	
end function

''*****************************************************************************
''
''*****************************************************************************
sub Player.DrawDynamites(SpriteSet() as GL2D.IMAGE ptr)

	for i as integer = 0 to MAX_DYNAMITES
		if( Dynamites(i).IsActive ) then Dynamites(i).Draw(SpriteSet())
	Next
	
End Sub

sub Player.SpawnDynamite()

	if( DynamitesLeft > 0 ) then
		for i as integer = 0 to MAX_DYNAMITES
			if( not Dynamites(i).IsActive ) then
				dim as integer offset = -4
				if( Direction = DIR_LEFT ) then
					offset = -12
				EndIf
				Dynamites(i).Spawn( x + Wid\2 + offset, y + 8, Direction )
				DynamitesLeft -= 1
				exit for
			EndIf
		Next
	endif
	
End Sub
	
sub Player.UpdateDynamites( Map() as TileType )

	for i as integer = 0 to MAX_DYNAMITES
		if( Dynamites(i).IsActive ) then
			Dynamites(i).Update( Map() )
		EndIf
	Next
	
End Sub

sub Player.CollideDynamitesPlatforms( byref Box as const AABB  )

	for i as integer = 0 to MAX_DYNAMITES
		if( Dynamites(i).IsActive ) then
			if(Dynamites(i).CollideWithAABB( Box ) ) then
				if( Dynamites(i).GetY > Box.y1 + 16 ) then
					Dynamites(i).Explode()
				endif
			endif
		EndIf
	Next
	
End Sub

function Player.CollideDynamites( byref Box as const AABB  ) as integer

	for i as integer = 0 to MAX_DYNAMITES
		if( Dynamites(i).IsActive ) then
			if( Dynamites(i).CollideWithAABB( Box ) ) then
				Dynamites(i).Explode()
				return DYNAMITE_ATTACK_ENERGY
			endif
		EndIf
	Next
	
	return 0
	
end function
	
''*****************************************************************************
''
''*****************************************************************************
sub Player.DrawMines(SpriteSet() as GL2D.IMAGE ptr)

	for i as integer = 0 to MAX_MINES
		if( Mines(i).IsActive ) then Mines(i).Draw(SpriteSet())
	Next
	
End Sub

sub Player.SpawnMine()

	if( MinesLeft > 0 ) then
		for i as integer = 0 to MAX_MINES
			if( not Mines(i).IsActive ) then
				dim as integer offset = -4
				if( Direction = DIR_LEFT ) then
					offset = -12
				EndIf
				Mines(i).Spawn( x + Wid\2 + offset, y + 8, Direction )
				MinesLeft -= 1
				exit for
			EndIf
		Next
	endif
End Sub
	
sub Player.UpdateMines( Map() as TileType )

	for i as integer = 0 to MAX_MINES
		if( Mines(i).IsActive ) then
			if( (Counter and 7) = 0 ) then Sound.PlaySFX( Sound.SFX_MINE_ACTIVE )
			Mines(i).Update( Map() )
		EndIf
	Next
	
End Sub

sub Player.CollideMinesPlatforms( byref Box as const AABB  )

	for i as integer = 0 to MAX_MINES
		if( Mines(i).IsActive ) then
			if( Mines(i).CollideWithAABB( Box ) ) then
				dim as integer y1 = Mines(i).GetY + Mines(i).GetDy + Mines(i).GetHei
				if( (y1 >= Box.y1) and (y1 < Box.y1 + 16) ) then
					Mines(i).SetY = (Box.y1 - Mines(i).GetHei) + 1
					Mines(i).SetDy = 1
				else
					Mines(i).SetDx = -Mines(i).GetDx
				endif
			endif
		EndIf
	Next
	
End Sub

function Player.CollideMines( byref Box as const AABB  ) as integer

	for i as integer = 0 to MAX_MINES
		if( Mines(i).IsActive ) then
			if( Mines(i).CollideWithAABB( Box ) ) then
				Mines(i).Explode()
				return MINE_ATTACK_ENERGY
			endif
		EndIf
	Next
	
	return 0
	
end function

sub Player.ResetAll()
	
	ResetShadows()
	ResetShots()
	
	for i as integer = 0 to MAX_BOMBS
		if( Bombs(i).IsActive ) then
			Bombs(i).Kill()
		endif
	next
	
	for i as integer = 0 to MAX_DYNAMITES
		if( Dynamites(i).IsActive ) then
			Dynamites(i).Kill()
		endif
	next
	
	for i as integer = 0 to MAX_MINES
		if( Mines(i).IsActive ) then
			Mines(i).Kill()
		endif
	next
	
	
end sub

sub Player.ContinueGame()
	
	ResetAll()
	Energy = 256
	OldEnergy = Energy
	Lives = 5
	Score = 0
	
	BombsLeft = 2
	DynamitesLeft = 2
	MinesLeft = 2
	
end sub

''*****************************************************************************
''
''*****************************************************************************
property Player.SetScore( byval v as integer )
	Score = v
End Property

property Player.SetIncendiaryType( byval v as integer )
	IncendiaryType = v
End Property

property Player.SetInvincible( byval v as integer )
	Invincible = v
End Property

property Player.SetX( byval v as single )
	x = v
End Property

property Player.SetY( byval v as single )
	y = v
End Property

property Player.SetDX( byval v as single )
	Dx = v
End Property

property Player.SetDY( byval v as single )
	Dy = v
End Property

property Player.SetSpeed( byval v as single )
	Speed = v
End Property

property Player.SetCanJump( byval v as integer ) 
	CanJump = v
End Property

property Player.SetOnPlatform( byval v as integer ) 
	OnPlatform = v
End Property

property Player.SetOnSideOfPlatform( byval v as integer ) 
	OnSideOfPlatform = v
End Property

property Player.IsActive() as integer
	Property = Active
End Property

property Player.IsInvincible() as integer
	Property = Invincible
end property

property Player.IsDead() as integer
	Property = (State = DIE) or (State = DEAD) 
end property

property Player.GetState() as integer
	Property = State
End Property

property Player.IsInWater() as integer
	Property = InWater
end property

property Player.GetLives() as integer
	Property = Lives
End Property

property Player.GetScore() as integer
	Property = Score
End Property

property Player.GetEnergy() as integer
	Property = Energy
End Property

property Player.GetOldEnergy() as integer
	Property = OldEnergy
End Property

property Player.GetBombs() as integer
	Property = BombsLeft
End Property

property Player.GetDynamites() as integer
	Property = DynamitesLeft
End Property

property Player.GetMines() as integer
	Property = MinesLeft
End Property

property Player.GetX() as Single
	Property = x
End Property 

property Player.GetY() as Single
	Property = y
End Property

property Player.GetDX() as Single
	Property = Dx
End Property 

property Player.GetDY() as Single
	Property = Dy
End Property

property Player.GetWid() as Single
	Property = Wid
End Property 

property Player.GetHei() as Single
	Property = Hei
End Property

property Player.GetCameraX() as Single
	Property = CameraX
End Property

property Player.GetCameraY() as Single
	Property = CameraY
End Property

property Player.GetIncendiaryType() as integer
	Property = IncendiaryType
End Property

property Player.GetOnPlatform() as integer
	Property = OnPlatform
End Property

property Player.GetBoxNormal() as AABB
	property = BoxNormal
End Property

property Player.GetBoxSmall() as AABB
	property = BoxSmall
End Property

property Player.GetCenterFloorTile( Map() as TileType ) as integer	
	property =  Map( (x + Wid /2) \ TILE_SIZE, (y + Hei + 1) \ TILE_SIZE ).Collision
End Property

property Player.GetCenterTile( Map() as TileType ) as integer	
	property =  Map( (x + Wid/2) \ TILE_SIZE, (y + Hei/2) \ TILE_SIZE ).Collision
End Property
		