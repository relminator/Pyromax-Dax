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

#include once "BossJoker.bi"


const as integer MAX_IDLE_COUNTER = 60 * 5
const as integer MAX_STUNNED_COUNTER = 60 * 5
const as integer MAX_INVINCIBLE_COUNTER = 60 * 1
const as integer MAX_TURN_COUNTER = 8

constructor BossJoker()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	Orientation = NORMAL
	State = STATE_FALLING
	IdleCounter = MAX_IDLE_COUNTER
	StunnedCounter = MAX_STUNNED_COUNTER
	InvincibleCounter = -1
	
	Rotation = 0
	WheelRotation = 0
			
	HP = 256
		
	Speed = 1	
	x = 0
	y = 0
	Dx = 0
	Dy = 1
	

	Frame = 0
	BaseFrame = 40
	NumFrames = 4
	
	Wid = 58
	Hei	= 58
	
	
End Constructor

destructor BossJoker()

End Destructor


property BossJoker.IsActive() as integer
	property = Active
End Property
		
property BossJoker.GetX() as single
	property = x
End Property

property BossJoker.GetY() as single
	property = y
End Property

property BossJoker.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property BossJoker.GetBox() as AABB
	property = BoxWheel
End Property

property BossJoker.GetHP() as integer
	property = HP
End Property

property BossJoker.GetOldHP() as integer
	property = OldHP
End Property

property BossJoker.GetMaxHP() as integer
	property = 256
End Property

''*****************************************************************************
''
''*****************************************************************************

function BossJoker.CollideOnMap( Map() as TileType ) as integer
	
	dim as integer TileX, TileY

	if( Dx > 0 ) then 
		if( CollideWalls( int(x + Dx + Wid), int(y), TileX, Map() ) ) then 
			x = TileX * TILE_SIZE - Wid - 1
			Speed = -Speed
			Dx = Speed							
		else
			x += Dx 													
		endif
	
	elseif( Dx < 0 ) then																					
		if( CollideWalls( int(x + Dx), int(y), TileX, Map() ) ) then			
			x = ( TileX + 1 ) * TILE_SIZE + 1
			Speed = -Speed
			Dx = Speed						
		else
			x += Dx 													
		endif
	endif
	
	

	if( Dy < 0 ) then   	'' moving Up
		
		if( CollideFloors( int(x), int(y + Dy), TileY, Map() ) ) then   		'' hit the roof
			y = ( TileY + 1 ) * TILE_SIZE + 1									'' Snap below the tile
			Dy = 0    															'' Arrest movement
		else
			y += Dy																'' No collision so move
			Dy += GRAVITY														'' with gravity
		endif
			
	else	'' Stationary or moving down
		
		if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	'' (y + Dy + hei) = Foot of player
			y = ( TileY ) * TILE_SIZE - Hei - 1								'' Snap above the tile
			Dy = 1															'' Set to 1 so that we always collide with floor next frame
			return TRUE
		else
			y += Dy															'' No collision so move
			Dy += GRAVITY
		EndIf
		
	EndIf
	
	return FALSE
	
end function


sub BossJoker.ActionFalling( Map() as TileType )
	
	Dx = 0
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - Hei - 1
		if( Interpolator >= 1 ) then
			State = STATE_IDLE
			Interpolator = 0
		endif
	else
		y += Dy												
		Dy += GRAVITY
	endif
	
	Interpolator += 0.01
	if( Interpolator <= 1 ) then
		ClownX = UTIL.LerpSmooth( ClownX, x, SMOOTH_STEP(Interpolator) )
		ClownY = UTIL.LerpSmooth( ClownY, y - Hei, SMOOTH_STEP(Interpolator) )
		Rotation = UTIL.LerpSmooth( Rotation, 0, SMOOTH_STEP(Interpolator) )	
	else
		ClownX = x
		ClownY = y - Hei
	endif
	
	Rotation = 0
		
end sub

sub BossJoker.ActionMoveRightNormal( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideWalls( int(x + Dx + Wid), int(y), TileX, Map() ) ) then
		''x = TileX * TILE_SIZE - Wid
		Dx = 0
		Dy = Speed
		State = STATE_MOVE_DOWN
		TurnCounter = MAX_TURN_COUNTER							
	else
		x += Dx
		if( not CollideFloors( int(x), int(y - Speed), TileY, Map() ) ) then
			Dx = 0
			Dy = -Speed
			State = STATE_MOVE_UP
			FallDown()   '' if there is no adjacent tiles then fall
			TurnCounter = MAX_TURN_COUNTER
		endif
	endif

	ClownX = x
	ClownY = y
	
	WheelRotation -= 5
	Rotation -= 5
	
end sub

sub BossJoker.ActionMoveLeftNormal( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideWalls( int(x + Dx), int(y), TileX, Map() ) ) then
		''x = ( TileX + 1 ) * TILE_SIZE
		Dx = 0
		Dy = -Speed
		State = STATE_MOVE_UP
		TurnCounter = MAX_TURN_COUNTER
	else
		x += Dx
		if( not CollideFloors( int(x), (y + Speed + Hei), TileY, Map() ) ) then	
			Dx = 0
			Dy = Speed
			State = STATE_MOVE_DOWN
			TurnCounter = MAX_TURN_COUNTER
		endif 	
		
	endif
	
	ClownX = x
	ClownY = y
	
	WheelRotation -= 5
	Rotation -= 5
		
end sub

sub BossJoker.ActionMoveUpNormal( Map() as TileType )

	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy), TileY, Map() ) ) then
		''y = ( TileY + 1 ) * TILE_SIZE						
		Dy = 0
		Dx = Speed
		State = STATE_MOVE_RIGHT
		TurnCounter = MAX_TURN_COUNTER    												
	else
		y += Dy
		if( not CollideWalls( int(x - Speed), int(y), TileX, Map() ) ) then
			Dx = -Speed
			Dy = 0
			State = STATE_MOVE_LEFT
			TurnCounter = MAX_TURN_COUNTER
		endif													
	endif
	
	ClownX = x
	ClownY = y
		
	WheelRotation -= 5
	Rotation -= 5
	
end sub

sub BossJoker.ActionMoveDownNormal( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		''y = ( TileY ) * TILE_SIZE - Hei						
		Dy = 0
		Dx = -Speed
		State = STATE_MOVE_LEFT
		TurnCounter = MAX_TURN_COUNTER
	else
		y += Dy
		if( not CollideWalls( int(x + Speed + Wid), int(y), TileX, Map() ) ) then
			Dx = Speed
			Dy = 0
			State = STATE_MOVE_RIGHT
			TurnCounter = MAX_TURN_COUNTER
		endif												
	endif
	
	ClownX = x
	ClownY = y
	
	WheelRotation -= 5
	Rotation -= 5
	
end sub

''*****************************************************************************
''
''*****************************************************************************
sub BossJoker.ActionMoveRightReverse( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideWalls( int(x + Dx + Wid), int(y), TileX, Map() ) ) then
		''x = TileX * TILE_SIZE - Wid
		Dx = 0
		Dy = -Speed
		State = STATE_MOVE_UP
		TurnCounter = MAX_TURN_COUNTER							
	else
		x += Dx
		if( not CollideFloors( int(x), (y + Speed + Hei), TileY, Map() ) ) then
			Dx = 0
			Dy = Speed
			State = STATE_MOVE_DOWN
			FallDown()   '' if there is no adjacent tiles then fall
			'CheckDiagonalTiles( -TILE_SIZE\2, TILE_SIZE\2, Map() )   '' Check for adjacent tiles so we fall down when the tile is destroyed
			TurnCounter = MAX_TURN_COUNTER
		endif
	endif

	ClownX = x
	ClownY = y
	
	WheelRotation += 5
	Rotation += 5
	
end sub

sub BossJoker.ActionMoveLeftReverse( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideWalls( int(x + Dx), int(y), TileX, Map() ) ) then
		''x = ( TileX + 1 ) * TILE_SIZE
		Dx = 0
		Dy = Speed
		State = STATE_MOVE_DOWN
		TurnCounter = MAX_TURN_COUNTER
	else
		x += Dx
		if( not CollideFloors( int(x), int(y - Speed), TileY, Map() ) ) then	
			Dx = 0
			Dy = -Speed
			State = STATE_MOVE_UP
			TurnCounter = MAX_TURN_COUNTER
		endif 												
	endif
	
	ClownX = x
	ClownY = y
	
	WheelRotation += 5
	Rotation += 5
		
end sub

sub BossJoker.ActionMoveUpReverse( Map() as TileType )

	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy), TileY, Map() ) ) then
		''y = ( TileY + 1 ) * TILE_SIZE						
		Dy = 0
		Dx = -Speed
		State = STATE_MOVE_LEFT    												
		TurnCounter = MAX_TURN_COUNTER
	else
		y += Dy
		if( not CollideWalls( int(x + Speed + Wid), int(y), TileX, Map() ) ) then
			Dx = Speed
			Dy = 0
			State = STATE_MOVE_RIGHT
			TurnCounter = MAX_TURN_COUNTER
		endif													
	endif
	
	ClownX = x
	ClownY = y
	
	WheelRotation += 5
	Rotation += 5
	
end sub

sub BossJoker.ActionMoveDownReverse( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		''y = ( TileY ) * TILE_SIZE - Hei						
		Dy = 0
		Dx = Speed
		State = STATE_MOVE_RIGHT
		TurnCounter = MAX_TURN_COUNTER
	else
		y += Dy
		if( not CollideWalls( int(x - Speed), int(y), TileX, Map() ) ) then
			Dx = -Speed
			Dy = 0
			State = STATE_MOVE_LEFT
			TurnCounter = MAX_TURN_COUNTER
		endif												
	endif
	
	ClownX = x
	ClownY = y
	
	WheelRotation += 5
	Rotation += 5
	
end sub


sub BossJoker.ActionIdle( Map() as TileType )
	
	Dx = 0	
	dim as integer TileX, TileY		
	if( CollideFloors( int(x), int(y + Dy + Hei ), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - (Hei) - 1
	else
		y += Dy												
		Dy += GRAVITY
	endif
	
	if( (ClownY + ClownDy + Hei) >=  y ) then
		ClownY = y - Hei - 1
		ClownDy = -JUMPHEIGHT
	else
		ClownY += ClownDy												
		ClownDy += GRAVITY
	endif
	
	Rotation = 0
	
	IdleCounter -= 1
	if( IdleCounter <= 0 ) then
		Interpolator = 0
		IdleCounter = MAX_IDLE_COUNTER
		dim as single a = rnd * (2 * PI)
		ClownDx = cos(a) * 8 + rnd * 3
		ClownDy = sin(a) * 8 + rnd * 3
		BounceCount = 0
		if( rnd < 5 ) then
			Dx = -6
		else
			Dx = 6
		endif
		State = STATE_BOUNCE
	endif

	
end sub



sub BossJoker.ActionMorph( Map() as TileType )
	
	Interpolator +=  0.01
	
	ClownDy = 0
	
	ClownX = UTIL.LerpSmooth( ClownX, x, SMOOTH_STEP(Interpolator) )
	ClownY = UTIL.LerpSmooth( ClownY, y, SMOOTH_STEP(Interpolator) )
	Rotation = UTIL.LerpSmooth( Rotation, 0, SMOOTH_STEP(Interpolator) )
	 
	if( Interpolator > 1 ) then
		if( Orientation = NORMAL ) then						
			Dy = 0
			Dx = -Speed
			State = STATE_MOVE_LEFT
			TurnCounter = MAX_TURN_COUNTER
		else
			Dy = 0
			Dx = Speed
			State = STATE_MOVE_RIGHT
			TurnCounter = MAX_TURN_COUNTER
		endif
		IdleCounter = MAX_IDLE_COUNTER
		Interpolator = 0
	endif

	
end sub

sub BossJoker.ActionBounce( byval SnipeX as integer, Map() as TileType )
	
	dim as integer TileX, TileY		
	
	if( Dx < 0 ) then
		if( CollideWalls( x + Dx, y, TileX, Map() ) ) then
			x = ( TileX + 1 ) * TILE_SIZE
			Dx = -Dx
			Sound.PlaySFX( Sound.SFX_METAL_HIT )
			Globals.SetQuakeCounter(30)
		else
			x += Dx
			WheelRotation -= 5
		endif	
	else
		if( CollideWalls( x + Wid + Dx, y, TileX, Map() ) ) then
			x = ( TileX ) * TILE_SIZE - Wid - 1
			Dx = -Dx
			Sound.PlaySFX( Sound.SFX_METAL_HIT )
			Globals.SetQuakeCounter(30)
		else
			x += Dx
			WheelRotation += 5
		endif	
	endif
		
	if( CollideFloors( int(x), int(y + Dy + Hei ), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - (Hei) - 1
	else
		y += Dy												
		Dy += GRAVITY
	endif
	
	
	if( ClownDx < 0 ) then
		if( MapUtil.GetTile( ClownX + Dx, ClownY + Hei\2, Map() ) >= TILE_SOLID ) then
			ClownDx = -ClownDx
			BounceCount += 1
		else
			Clownx += ClownDx
		endif
	else
		if( MapUtil.GetTile( ClownX + Wid + Dx, ClownY + Hei\2 + ClownDy, Map() ) >= TILE_SOLID ) then
			ClownDx = -ClownDx
			BounceCount += 1
		else
			Clownx += ClownDx
		endif
	endif	
	
	if( ClownDy < 0 ) then	
		if( MapUtil.GetTile( ClownX + Wid\2, ClownY + Dy, Map() ) >= TILE_SOLID ) then
			ClownDy = -ClownDy
			BounceCount += 1
		else
			Clowny += ClownDy
		endif
	else
		if( MapUtil.GetTile( ClownX + Wid\2, ClownY + Hei + Dy, Map() ) >= TILE_SOLID ) then
			ClownDy = -ClownDy
			BounceCount += 1
		else
			Clowny += ClownDy
		endif
	endif
	
	Rotation = WheelRotation
	
	if( BounceCount > 20 ) then
		Interpolator = 0
		IdleCounter = MAX_IDLE_COUNTER
		State = STATE_MORPH
		BounceCount = 0
		if( x > SnipeX) then
			Orientation = NORMAL
		else
			Orientation = REVERSE
		endif
		Rotation = UTIL.Wrap( Rotation, 0, 639 )
	endif

	
	
end sub
	
sub BossJoker.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	State = STATE_FALLING
	FlipMode = GL2D.FLIP_NONE
	IdleCounter = MAX_IDLE_COUNTER
	StunnedCounter = MAX_STUNNED_COUNTER
	InvincibleCounter = -1
	
	Rotation = 0
	WheelRotation = 0
	
	TurnCounter = MAX_TURN_COUNTER
	Orientation = iOrientation
	State = STATE_FALLING
	if( Orientation = NORMAL ) then
		FlipMode = GL2D.FLIP_NONE
	else
		FlipMode = GL2D.FLIP_H
	EndIf
		
	HP = 256
	OldHP = HP
		
	Speed = 5.0
	
	x = ix
	y = iy
	
	Dx = 0
	Dy = 1
	
	ClownX = x
	ClownY = y - Hei
	
	BaseFrame = 39
	NumFrames = 5
	
	Wid = 58
	Hei	= 58

	BoxWheel.Init( x, y, wid, Hei)
	BoxWheel.Resize(0.7)
	BoxClown.Init( ClownX, ClownY, wid, Hei)
	BoxClown.Resize(0.7)
	BoxClownSmall.Init( ClownX, ClownY, wid, Hei)
	BoxClownSmall.Resize(0.4)
	
end sub


sub BossJoker.Update( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	
	Counter += 1
	TurnCounter -= 1
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	if( OldHP > HP ) then OldHP -= 1

	if( Orientation = NORMAL ) then
		select case State
			case STATE_FALLING:
				ActionFalling( Map() )
			case STATE_MOVE_RIGHT:
				Frame = 4
				ActionMoveRightNormal( Map() )
				if( (Counter and 3) = 0 ) then
					Bullets.Spawn( x + Wid\2, y + Hei\2, 90, 7, Bullet.STATE_NORMAL, Bullet.ID_ARROW )
				endif
			case STATE_MOVE_LEFT:
				Frame = 4
				ActionMoveLeftNormal( Map() )
			case STATE_MOVE_UP:
				Frame = 4
				ActionMoveUpNormal( Map() )
				if( (Counter and 3) = 0 ) then
					Bullets.Spawn( x + Wid\2, y + Hei\2, 90, 7, Bullet.STATE_NORMAL, Bullet.ID_ARROW )
				endif
			case STATE_MOVE_DOWN:
				Frame = 4
				ActionMoveDownNormal( Map() )
				if( (Counter and 3) = 0 ) then
					Bullets.Spawn( x + Wid\2, y + Hei\2, 90, 7, Bullet.STATE_NORMAL, Bullet.ID_ARROW )
				endif
			case STATE_IDLE:
				ActionIdle( Map() )
				if( (Counter and 7) = 0 ) then
					Bullets.Spawn( ClownX + Wid\2, ClownY + Hei\2, Counter, 7, Bullet.STATE_NORMAL, Bullet.ID_MISSILE )
					Bullets.Spawn( ClownX + Wid\2, ClownY + Hei\2, Counter + 90, 7, Bullet.STATE_NORMAL, Bullet.ID_MISSILE )
					Bullets.Spawn( ClownX + Wid\2, ClownY + Hei\2, Counter + 180, 7, Bullet.STATE_NORMAL, Bullet.ID_MISSILE )
					Bullets.Spawn( ClownX + Wid\2, ClownY + Hei\2, Counter + 270, 7, Bullet.STATE_NORMAL, Bullet.ID_MISSILE )
				endif
			case STATE_MORPH:
				Frame = 4
				ActionMorph( Map() )
			case STATE_BOUNCE:
				Frame = 4
				ActionBounce( Snipe.GetX, Map() )
			case else
		end select	
		
	else
		select case State
			case STATE_FALLING:
				ActionFalling( Map() )
			case STATE_MOVE_RIGHT:
				Frame = 4
				ActionMoveRightReverse( Map() )
			case STATE_MOVE_LEFT:
				ActionMoveLeftReverse( Map() )
				if( (Counter and 3) = 0 ) then
					Bullets.Spawn( x + Wid\2, y + Hei\2, 90, 7, Bullet.STATE_NORMAL, Bullet.ID_ARROW )
				endif
			case STATE_MOVE_UP:
				Frame = 4
				ActionMoveUpReverse( Map() )
				if( (Counter and 3) = 0 ) then
					Bullets.Spawn( x + Wid\2, y + Hei\2, 90, 7, Bullet.STATE_NORMAL, Bullet.ID_ARROW )
				endif
			case STATE_MOVE_DOWN:
				Frame = 4
				ActionMoveDownReverse( Map() )
				if( (Counter and 3) = 0 ) then
					Bullets.Spawn( x + Wid\2, y + Hei\2, 90, 7, Bullet.STATE_NORMAL, Bullet.ID_ARROW )
				endif
			case STATE_IDLE:
				ActionIdle( Map() )
				if( (Counter and 7) = 0 ) then
					Bullets.Spawn( ClownX + Wid\2, ClownY + Hei\2, Counter, 7, Bullet.STATE_NORMAL, Bullet.ID_MISSILE )
					Bullets.Spawn( ClownX + Wid\2, ClownY + Hei\2, Counter + 90, 7, Bullet.STATE_NORMAL, Bullet.ID_MISSILE )
					Bullets.Spawn( ClownX + Wid\2, ClownY + Hei\2, Counter + 180, 7, Bullet.STATE_NORMAL, Bullet.ID_MISSILE )
					Bullets.Spawn( ClownX + Wid\2, ClownY + Hei\2, Counter + 270, 7, Bullet.STATE_NORMAL, Bullet.ID_MISSILE )
				endif
			case STATE_MORPH:
				Frame = 4
				ActionMorph( Map() )
			case STATE_BOUNCE:
				Frame = 4
				ActionBounce( Snipe.GetX, Map() )
			case else
		end select	
	
	endif
	

	BoxWheel.Init( x, y, wid, Hei)
	BoxWheel.Resize(0.8)
	BoxClown.Init( ClownX, ClownY, wid, Hei)
	BoxClown.Resize(0.6)
	BoxClownSmall.Init( ClownX, ClownY, wid, Hei)
	BoxClownSmall.Resize(0.5)
	
	if( InvincibleCounter >= 0  ) then
		InvincibleCounter -= 1
	endif
	
End Sub


sub BossJoker.Explode()
	
	Explosion.SpawnMulti( Vector3D(ClownX + Wid\2, ClownY + Hei\2, 2), 4, rnd * 360, Explosion.BIG_YELLOW, Explosion.MEDIUM_BLUE_02, 16 )
	Explosion.Spawn( Vector3D(x + Wid\2, y + Hei\2, 2), 50 )
	
	Kill()
	
End Sub

sub BossJoker.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxWheel.Init( -10000, -1000, wid, Hei)
	
End Sub

sub BossJoker.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
		
	GL2D.SpriteRotateScaleXY3D( x + Wid/2,_
							    y + Hei/2,_
							    -4,_
							    WheelRotation,_
							    1,_
							    1,_
							    FlipMode,_
							    SpriteSet( BaseFrame + 5 ) )
	
	if( (InvincibleCounter > 0) and ((InvincibleCounter and 3) = 0 ) ) then	
	
		GL2D.EnableSpriteStencil( TRUE, GL2D_RGBA(255,255,255,255), GL2D_RGBA(255,255,255,255) )
		GL2D.SpriteRotateScaleXY3D( ClownX + Wid/2,_
								    Clowny + Hei/2,_
								    -4,_
								    Rotation,_
								    1,_
								    1,_
								    FlipMode,_
								    SpriteSet( BaseFrame + Frame ) )
		GL2D.EnableSpriteStencil( FALSE )
		
	else
		if( State = STATE_STUNNED ) then
			glColor4f(rnd,rnd,rnd,1)
		endif		

		GL2D.SpriteRotateScaleXY3D( ClownX + Wid/2,_
								    Clowny + Hei/2,_
								    -4,_
								    Rotation,_
								    1,_
								    1,_
								    FlipMode,_
		 						    SpriteSet( BaseFrame + Frame ) )		
		glColor4f(1,1,1,1)		
			
	endif
	
End Sub

sub BossJoker.DrawAABB()
	
	BoxWheel.Draw( 0, GL2D_RGB( 255, 0, 255 ) )
	BoxClown.Draw( 0, GL2D_RGB( 255, 255, 0 ) )
	BoxClownSmall.Draw( 0, GL2D_RGB( 0, 255, 255 ) )
	
end sub

sub BossJoker.DrawStatus( SpriteSet() as GL2D.IMAGE ptr )

	glColor4f(1,1,1,1)
	GL2D.SpriteStretch( 600, 16, 32, 128, SpriteSet(1) )
	
	GL2D.SetblendMode( GL2D.BLEND_GLOW )
	
	dim as integer hOld = UTIL.Lerp( 0, 106, UTIL.Clamp(OldHp/256, 0.0, 1.0) )    
	dim as integer h = UTIL.Lerp( 0, 106, UTIL.Clamp(Hp/256, 0.0, 1.0) )    
	
	GL2D.LineGlow( 600+16, 134, 600+16, 134 - hOld, 32,GL2D_RGB(255,255,0) )
	GL2D.LineGlow( 600+16, 134, 600+16, 134 - h, 28,GL2D_RGB(0,255,255) )
	
	
	GL2D.SetblendMode( GL2D.BLEND_TRANS )
	glColor4f(1,1,1,1)
	
end sub


sub BossJoker.CollideWithPlayer( byref Snipe as Player )
	
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxWheel.Intersects(Box) ) then
			Snipe.HitAnimation( x, 75 )
		endif
		if( BoxClownSmall.Intersects(Box) ) then
			Snipe.HitAnimation( x, 75 )
		endif
	endif
	
	dim as integer AttackEnergy = 0
	
	AttackEnergy = Snipe.CollideShots( BoxClown )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 30
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 50000 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxClown )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 30
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 50000 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxClown )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		State = STATE_FALLING
		Interpolator = 0
		Dy = 1
		Hp -= 51
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 50000 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideMines( BoxClown )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 30
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 50000 )
		endif
	endif
	
	
	AttackEnergy = Snipe.CollideShots( BoxWheel )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 5
		'Hp -= 300
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 50000 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideMines( BoxWheel )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 5
		if( State =  STATE_BOUNCE ) then
			Interpolator = 0
			State = STATE_MORPH	
		endif
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 50000 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxWheel )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		if( (State = STATE_MOVE_RIGHT) or (State = STATE_MOVE_LEFT ) or (State = STATE_MOVE_UP)  or (State = STATE_MOVE_DOWN) ) then	
			Hp -= 51
			Interpolator = 0
			Dy = 1
			State = STATE_FALLING
		else
			Hp -= 5
		endif
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 50000 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxWheel )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 5
		if( State =  STATE_BOUNCE ) then
			Interpolator = 0
			State = STATE_MORPH	
		endif
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 50000 )
		endif
	endif
		
end sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function BossJoker.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
	dim as integer TileYpixels = iy - (iy mod TILE_SIZE)   '' Pixel of the player's head snapped to map grid
	dim as integer TestEnd = (iy + hei)\TILE_SIZE		   '' Foot of the player
	
	iTileX = ix\TILE_SIZE								   '' Current X map coord the player is on + x-velocity(+ width when moving right)
	
	dim as integer iTileY = TileYpixels\TILE_SIZE		   '' Current Y map coord of the player's head
	
	'' Scan downwards from head to foot if we collided with a tile on the right or left
	while( iTileY <= TestEnd )
		if( Map(iTileX, iTileY).Collision >= TILE_SOLID )	then return TRUE	   '' Found a tile
		iTileY += 1										   '' Next tile downward
	Wend
	
	return FALSE
	
End Function

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function BossJoker.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
	dim as integer TileXpixels = ix - (ix mod TILE_SIZE)
	dim as integer TestEnd = (ix + wid)\TILE_SIZE
	
	iTileY = iy\TILE_SIZE
	
	dim as integer iTileX = TileXpixels\TILE_SIZE
	
	while( iTileX <= TestEnd )
		if( Map(iTileX, iTileY).Collision >= TILE_SOLID )	then return TRUE	
		iTileX += 1
	Wend
	
	return FALSE
	
End Function



function BossJoker.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxWheel.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function


sub BossJoker.FallDown( )

	if( TurnCounter >= 0 ) then
		Dx = 0
		Dy = 1
		State = STATE_FALLING	
	endif	

end sub


''*****************************************************************************
''
'' BossJokerFactory
''
''*****************************************************************************

constructor BossJokerFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(BossJokers)
		BossJokers(i).Kill()
	Next
	
End Constructor

destructor BossJokerFactory()

End Destructor

property BossJokerFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property BossJokerFactory.GetMaxEntities() as integer
	property = ubound(BossJokers)
end property 

property BossJokerFactory.GetPos( byval i as integer ) as Vector2D
	property = type<Vector2D>(BossJokers(i).GetX, BossJokers(i).GetY) 
end property
	
function BossJokerFactory.UpdateEntities( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType ) as integer
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(BossJokers)
		if( BossJokers(i).IsActive ) then
			BossJokers(i).Update( Snipe, Bullets, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
	if( ActiveEntities > 0 ) then return TRUE
	
	return FALSE
		
end function

sub BossJokerFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(BossJokers)
		if( BossJokers(i).IsActive ) then
			BossJokers(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub BossJokerFactory.DrawEntitiesStatus( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(BossJokers)
		if( BossJokers(i).IsActive ) then
			BossJokers(i).DrawStatus( SpriteSet() )
		EndIf
	Next
	
end sub

sub BossJokerFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(BossJokers)
		if( BossJokers(i).IsActive ) then
			BossJokers(i).DrawAABB()
		EndIf
	Next
	
end sub

sub BossJokerFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(BossJokers)
		if( BossJokers(i).IsActive ) then
			BossJokers(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub BossJokerFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(BossJokers)
		
		if( BossJokers(i).IsActive ) then
			BossJokers(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub BossJokerFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(BossJokers)
		if( BossJokers(i).IsActive = FALSE ) then
			BossJokers(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function BossJokerFactory.GetAABB( byval i as integer ) as AABB
	
	return BossJokers(i).GetBox
	
End Function
	