''*****************************************************************************
''
''
''	Pyromax Dax Boss Gyrobot Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "BossGyrobot.bi"


const as integer MAX_IDLE_COUNTER = 60
const as integer MAX_STUNNED_COUNTER = 60 * 5
const as integer MAX_FIRE_COUNTER = 60 * 1
const as integer MAX_INVINCIBLE_COUNTER = 60 * 1
const as integer MAX_JUMP_COUNTER = 3

constructor BossGyrobot()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	Orientation = ORIENTATION_LEFT
	State = STATE_FALLING
	IdleCounter = MAX_IDLE_COUNTER
	StunnedCounter = MAX_STUNNED_COUNTER
	InvincibleCounter = -1
	FireCounter = MAX_FIRE_COUNTER
	JumpCounter = MAX_JUMP_COUNTER
		
	HP = 256
		
	Speed = 1	
	x = 0
	y = 0
	Dx = 0
	Dy = 1
	YFlyPos = y

	Frame = 0
	BaseFrame = 60
	NumFrames = 6
	
	Wid = 64
	Hei	= 64
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor BossGyrobot()

End Destructor


property BossGyrobot.IsActive() as integer
	property = Active
End Property
		
property BossGyrobot.GetX() as single
	property = x
End Property

property BossGyrobot.GetY() as single
	property = y
End Property

property BossGyrobot.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property BossGyrobot.GetBox() as AABB
	property = BoxNormal
End Property

property BossGyrobot.GetHP() as integer
	property = HP
End Property

property BossGyrobot.GetOldHP() as integer
	property = OldHP
End Property

property BossGyrobot.GetMaxHP() as integer
	property = 256
End Property

''*****************************************************************************
''
''*****************************************************************************

function BossGyrobot.CollideOnMap( Map() as TileType ) as integer
	
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

sub BossGyrobot.ActionFalling( byval SnipeX as integer, Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - Hei - 1
		Sound.PlaySFX( Sound.SFX_METAL_HIT )
		Globals.SetQuakeCounter(30)
		if( SnipeX < x ) then
			Orientation = ORIENTATION_LEFT
		else
			Orientation = ORIENTATION_RIGHT
		endif
		
		if( Orientation = ORIENTATION_LEFT ) then						
			Dy = 1
			Speed = -Speed
			Dx = Speed
			State = STATE_IDLE
			IdleCounter = MAX_IDLE_COUNTER
		else
			Dy = 1
			Dx = Speed
			State = STATE_IDLE
			IdleCounter = MAX_IDLE_COUNTER
		endif
	else
		y += Dy												
		Dy += GRAVITY
	endif
	
		
end sub

sub BossGyrobot.ActionJumping( Map() as TileType )
	
	if( CollideOnMap( Map() ) ) then
		Sound.PlaySFX( Sound.SFX_METAL_HIT )
		Globals.SetQuakeCounter(30)
		JumpCounter -= 1
		if( JumpCounter < 0 ) then
			State = STATE_IDLE
		else
			State = STATE_FIRE
		endif
	endif
	
end sub

sub BossGyrobot.ActionIdle( Map() as TileType )
	
	Dx = 0
	Dy = 1
	IdleCounter -= 1
	if( IdleCounter <= 0 ) then
		if( JumpCounter < 0 ) then
			YFlyPos = y
			Magnitude = 0
			State = STATE_FLY
			JumpCounter = MAX_JUMP_COUNTER
			IdleCounter = MAX_IDLE_COUNTER
			Speed = (1) * sgn(Speed)
			Dx = Speed
		else
			State = STATE_JUMPING
			IdleCounter = MAX_IDLE_COUNTER
			Speed = (1 + rnd * 4) * sgn(Speed)
			Dx = Speed
			Dy = -((JUMPHEIGHT * 1.5) + rnd * (JUMPHEIGHT) )   
		endif
	endif
	CollideOnMap( Map() )
	
end sub


sub BossGyrobot.ActionStunned( Map() as TileType )
	
	Dx = 0
	StunnedCounter -= 1
	if( StunnedCounter <= 0 ) then
		YFlyPos = y
		Magnitude = 0
		State = STATE_FLY
		JumpCounter = MAX_JUMP_COUNTER
		IdleCounter = MAX_IDLE_COUNTER
		StunnedCounter = MAX_STUNNED_COUNTER
		Speed = (1) * sgn(Speed)
		Dx = Speed
	endif
	CollideOnMap( Map() )
	
end sub

sub BossGyrobot.ActionFire( byref Bullets as BulletFactory, Map() as TileType )
	
	Dx = 0
	if( (FireCounter and 31) = 0 ) then
		Sound.PlaySFX( Sound.SFX_ENEMY_SHOT_01 )
		if( Flipmode = GL2D.FLIP_NONE ) then
			Bullets.Spawn( x + Wid\2 - 28, y + Hei - 16, 180, 6.5, Bullet.STATE_NORMAL, Bullet.ID_FRISBEE )
		else
			Bullets.Spawn( x + Wid\2 + 28, y + Hei - 16, 0  , 6.5, Bullet.STATE_NORMAL, Bullet.ID_FRISBEE )
		endif
	endif

	FireCounter -= 1
	if( FireCounter <= 0 ) then
		State = STATE_IDLE
		FireCounter = MAX_FIRE_COUNTER
	endif
	CollideOnMap( Map() )
	
end sub

sub BossGyrobot.ActionFly( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	
	dim as integer TileX, TileY		
	
	if( (Counter and 63) = 0 ) then
		Sound.PlaySFX( Sound.SFX_ENEMY_SHOT_02 )
		Bullets.Spawn( x + Wid\2, y + Hei - 16, 180 + 80, 7.5, Bullet.STATE_GRAVITY, Bullet.ID_STONE )
		Bullets.Spawn( x + Wid\2, y + Hei - 16, 360 - 80, 7.5, Bullet.STATE_GRAVITY, Bullet.ID_STONE )
	endif
		
	if( Dx < 0 ) then
		if( CollideWalls( x + Dx, y, TileX, Map() ) ) then
			x = ( TileX + 1 ) * TILE_SIZE
			Dx = -Dx
		else
			x += Dx
		endif	
	else
		if( CollideWalls( x + Wid + Dx, y, TileX, Map() ) ) then
			x = ( TileX ) * TILE_SIZE - Wid - 1
			Dx = -Dx
		else
			x += Dx
		endif	
	endif
	
	if( YFlyPos > 160 ) then
		YFlyPos -= 0.5
	else
		dim as single ix = x + Wid\2
		dim as single px = Snipe.GetX + Snipe.GetWid\2
		if( abs(ix - px) <= 5 ) then
			State = STATE_FALLING
		endif
	endif
	
	if( Magnitude < 16 ) then
		Magnitude += 0.5
	endif
	
	y = YFlyPos + sin( Counter * 0.15 ) * Magnitude 
	
	
end sub
	
sub BossGyrobot.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Orientation = iOrientation
	State = STATE_FALLING
	FlipMode = GL2D.FLIP_NONE
	IdleCounter = MAX_IDLE_COUNTER
	StunnedCounter = MAX_STUNNED_COUNTER
	InvincibleCounter = -1
	FireCounter = MAX_FIRE_COUNTER
	JumpCounter = MAX_JUMP_COUNTER
		
	HP = 256
	OldHP = HP
		
	Speed = 0.75
	
	x = ix
	y = iy
	YFlyPos = y
	
	Dx = 0
	Dy = 1
	
	BaseFrame = 60
	NumFrames = 6
	Frame = 0
	
	Wid = 64
	Hei	= 64

	BoxNormal.Init( x, y, wid, Hei )
	BoxNormal.Resize( 0.8, 1 )
	BoxSmall = BoxNormal.GetAABB
	BoxSmall.Resize(0.7)
	if( Flipmode = GL2D.FLIP_NONE ) then
 		BoxEye.Init( x + Wid\2 - 16, y + 2, 16, 24)
 	else
 		BoxEye.Init( x + Wid\2, y + 2, 16, 24)
 	endif
	
end sub


sub BossGyrobot.Update( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	
	Counter += 1
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	if( OldHP > HP ) then OldHP -= 1
	
	select case State
		case STATE_FALLING:
			Frame = 0
			ActionFalling( Snipe.GetX, Map() )
		case STATE_JUMPING:
			ActionJumping( Map() )
			if( Dx > 0 ) then
				Flipmode = GL2D.FLIP_H
			else
				Flipmode = GL2D.FLIP_NONE
			endif
			if( ((Counter and 3) = 0) and (Dy > 0) ) then 
				dim as single ix = Snipe.GetX - x
				dim as single iy = Snipe.GetY - y
				Bullets.Spawn( x + Wid\2, y + Hei - 16, RAD2DEG(atan2(iy,ix)), 7.5, Bullet.STATE_NORMAL, Bullet.ID_DEFAULT )
			endif
		case STATE_IDLE:
			Frame = 0
			ActionIdle( Map() )
		case STATE_STUNNED:
			Frame = 0
			ActionStunned( Map() )
		case STATE_FIRE:
			Frame = 0
			ActionFire( Bullets, Map() )
		case STATE_FLY:
			ActionFly( Snipe, Bullets, Map() )
			if( Dx > 0 ) then
				Flipmode = GL2D.FLIP_H
			else
				Flipmode = GL2D.FLIP_NONE
			endif	
	end select	
	

	BoxNormal.Init( x, y, wid, Hei)
	BoxNormal.Resize(0.45, 1 )
	BoxSmall = BoxNormal.GetAABB
	BoxSmall.Resize(0.3, 1 )
 	if( Flipmode = GL2D.FLIP_NONE ) then
 		BoxEye.Init( x + Wid\2 - 16, y + 2, 16, 32)
 	else
 		BoxEye.Init( x + Wid\2, y + 2, 16, 32)
 	endif

	if( InvincibleCounter >= 0  ) then
		InvincibleCounter -= 1
	endif
	
End Sub


sub BossGyrobot.Explode()
	
	Explosion.Spawn( Vector3D(x + Wid\2, y + Hei\2, 2), 50 )
	
	Kill()
	
End Sub

sub BossGyrobot.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub BossGyrobot.Draw( SpriteSet() as GL2D.IMAGE ptr )
		
	if( (InvincibleCounter > 0) and ((InvincibleCounter and 3) = 0 ) ) then	
		GL2D.EnableSpriteStencil( TRUE, GL2D_RGBA(255,255,255,255), GL2D_RGBA(255,255,255,255) )
		GL2D.Sprite( x, y, FlipMode, SpriteSet( BaseFrame + Frame ) )
		GL2D.EnableSpriteStencil( FALSE )
	else
		if( State = STATE_STUNNED ) then
			glColor4f(rnd,rnd,rnd,1)
		endif	
		GL2D.Sprite( x, y, FlipMode, SpriteSet( BaseFrame + Frame ) )
		glColor4f(1,1,1,1)		
	endif	
	
End Sub

sub BossGyrobot.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	BoxSmall.Draw( 4, GL2D_RGB( 0, 255, 255 ) )
	BoxEye.Draw( 4, GL2D_RGB( 255, 255, 0 ) )
	
end sub

sub BossGyrobot.DrawStatus( SpriteSet() as GL2D.IMAGE ptr )

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


sub BossGyrobot.CollideWithPlayer( byref Snipe as Player )
	
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxSmall.Intersects(Box) ) then
			Snipe.HitAnimation( x, 75 )
		endif		
	endif
	
	dim as integer AttackEnergy = 0
	
	AttackEnergy = Snipe.CollideShots( BoxEye )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 10
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 20000 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxEye )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 10
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 20000 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxEye )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 10
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 20000 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideMines( BoxEye )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 10
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 20000 )
		endif
	endif
	
	
	Snipe.CollideShots( BoxNormal )
	
	Snipe.CollideDynamites( BoxNormal )
	
	AttackEnergy = Snipe.CollideMines( BoxNormal )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		State = STATE_STUNNED
		Dy = 1
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxNormal )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 52
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 20000 )
		endif
	endif
		
end sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function BossGyrobot.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function BossGyrobot.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function BossGyrobot.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' BossGyrobotFactory
''
''*****************************************************************************

constructor BossGyrobotFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(BossGyrobots)
		BossGyrobots(i).Kill()
	Next
	
End Constructor

destructor BossGyrobotFactory()

End Destructor

property BossGyrobotFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property BossGyrobotFactory.GetMaxEntities() as integer
	property = ubound(BossGyrobots)
end property 

property BossGyrobotFactory.GetPos( byval i as integer ) as Vector2D
	property = type<Vector2D>(BossGyrobots(i).GetX, BossGyrobots(i).GetY) 
end property
	
function BossGyrobotFactory.UpdateEntities( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType ) as integer
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(BossGyrobots)
		if( BossGyrobots(i).IsActive ) then
			BossGyrobots(i).Update( Snipe, Bullets, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
	if( ActiveEntities > 0 ) then return TRUE
	
	return FALSE
		
end function

sub BossGyrobotFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(BossGyrobots)
		if( BossGyrobots(i).IsActive ) then
			BossGyrobots(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub BossGyrobotFactory.DrawEntitiesStatus( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(BossGyrobots)
		if( BossGyrobots(i).IsActive ) then
			BossGyrobots(i).DrawStatus( SpriteSet() )
		EndIf
	Next
	
end sub

sub BossGyrobotFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(BossGyrobots)
		if( BossGyrobots(i).IsActive ) then
			BossGyrobots(i).DrawAABB()
		EndIf
	Next
	
end sub

sub BossGyrobotFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(BossGyrobots)
		if( BossGyrobots(i).IsActive ) then
			BossGyrobots(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub BossGyrobotFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(BossGyrobots)
		
		if( BossGyrobots(i).IsActive ) then
			BossGyrobots(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub BossGyrobotFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(BossGyrobots)
		if( BossGyrobots(i).IsActive = FALSE ) then
			BossGyrobots(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function BossGyrobotFactory.GetAABB( byval i as integer ) as AABB
	
	return BossGyrobots(i).GetBox
	
End Function
	