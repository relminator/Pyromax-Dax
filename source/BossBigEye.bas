''*****************************************************************************
''
''
''	Pyromax Dax Boss Bigeye Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "BossBigEye.bi"


const as integer MAX_IDLE_COUNTER = 60
const as integer MAX_STUNNED_COUNTER = 60 * 5
const as integer MAX_FIRE_COUNTER = 60 * 1
const as integer MAX_INVINCIBLE_COUNTER = 60 * 1

constructor BossBigEye()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	Orientation = ORIENTATION_LEFT
	State = STATE_FALLING
	IdleCounter = MAX_IDLE_COUNTER
	StunnedCounter = MAX_STUNNED_COUNTER
	InvincibleCounter = -1
	FireCounter = MAX_FIRE_COUNTER
		
	HP = 256
		
	Speed = 1	
	x = 0
	y = 0
	Dx = 0
	Dy = 1
	

	Frame = 0
	BaseFrame = 10
	NumFrames = 3
	
	Wid = 54
	Hei	= 80
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor BossBigEye()

End Destructor


property BossBigEye.IsActive() as integer
	property = Active
End Property
		
property BossBigEye.GetX() as single
	property = x
End Property

property BossBigEye.GetY() as single
	property = y
End Property

property BossBigEye.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property BossBigEye.GetBox() as AABB
	property = BoxNormal
End Property

property BossBigEye.GetHP() as integer
	property = HP
End Property

property BossBigEye.GetOldHP() as integer
	property = OldHP
End Property

property BossBigEye.GetMaxHP() as integer
	property = 256
End Property

''*****************************************************************************
''
''*****************************************************************************

function BossBigEye.CollideOnMap( Map() as TileType ) as integer
	
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

sub BossBigEye.ActionFalling( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - Hei - 1
		Sound.PlaySFX( Sound.SFX_METAL_HIT )
		Globals.SetQuakeCounter(30)
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

sub BossBigEye.ActionJumping( byref Bullets as BulletFactory, Map() as TileType )
	
	if( CollideOnMap( Map() ) ) then
		Sound.PlaySFX( Sound.SFX_METAL_HIT )
		Globals.SetQuakeCounter(30)
		State = STATE_FIRE
		for i as integer = 2 to 19
			if( rnd > 0.55 ) then 
				Bullets.Spawn( i * 32, 32, 90, rnd*3, Bullet.STATE_GRAVITY_BOUNCE, Bullet.ID_VOLCANIC )
			endif
		next
	endif
	
end sub

sub BossBigEye.ActionIdle( Map() as TileType )
	
	Dx = 0
	Dy = 1
	IdleCounter -= 1
	if( IdleCounter <= 0 ) then
		State = STATE_JUMPING
		IdleCounter = MAX_IDLE_COUNTER
		Speed = (1 + rnd * 4) * sgn(Speed)
		Dx = Speed
		Dy = -( (JUMPHEIGHT\2) + rnd * (JUMPHEIGHT) )   
	endif
	CollideOnMap( Map() )
	
end sub


sub BossBigEye.ActionStunned( Map() as TileType )
	
	Dx = 0
	StunnedCounter -= 1
	if( StunnedCounter <= 0 ) then
		State = STATE_IDLE
		IdleCounter = MAX_IDLE_COUNTER
		StunnedCounter = MAX_STUNNED_COUNTER
	endif
	CollideOnMap( Map() )
	
end sub

sub BossBigEye.ActionFire( byref Bullets as BulletFactory, Map() as TileType )
	
	Dx = 0
	if( (FireCounter and 15) = 0 ) then
		Sound.PlaySFX( Sound.SFX_ENEMY_SHOT_01 )
		if( Flipmode = GL2D.FLIP_NONE ) then
			Bullets.Spawn( x + Wid\2 - 28, y + 8, 180 + 40, 5.5, Bullet.STATE_BOUNCE, Bullet.ID_DEFAULT )
			Bullets.Spawn( x + Wid\2 - 28, y + 8, 180 - 40, 5.5, Bullet.STATE_BOUNCE, Bullet.ID_DEFAULT )
		else
			Bullets.Spawn( x + Wid\2 + 28, y + 8, 0 + 40, 5.5, Bullet.STATE_BOUNCE, Bullet.ID_DEFAULT )
			Bullets.Spawn( x + Wid\2 + 28, y + 8, 270 + 50, 5.5, Bullet.STATE_BOUNCE, Bullet.ID_DEFAULT )
		endif
	endif

	FireCounter -= 1
	if( FireCounter <= 0 ) then
		State = STATE_IDLE
		FireCounter = MAX_FIRE_COUNTER
	endif
	CollideOnMap( Map() )
	
end sub
	
sub BossBigEye.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Orientation = iOrientation
	State = STATE_FALLING
	FlipMode = GL2D.FLIP_NONE
	IdleCounter = MAX_IDLE_COUNTER
	StunnedCounter = MAX_STUNNED_COUNTER
	InvincibleCounter = -1
	FireCounter = MAX_FIRE_COUNTER
		
	HP = 256
	OldHP = HP
		
	Speed = 0.75
	
	x = ix
	y = iy
	
	Dx = 0
	Dy = 1
	
	BaseFrame = 10
	NumFrames = 3
	
	Wid = 54
	Hei	= 80

	BoxNormal.Init( x, y, wid, Hei)
	BoxSmall = BoxNormal.GetAABB
	BoxSmall.Resize(0.7)
	if( Flipmode = GL2D.FLIP_NONE ) then
 		BoxEye.Init( x + Wid\2 - 16, y + 2, 16, 24)
 	else
 		BoxEye.Init( x + Wid\2, y + 2, 16, 24)
 	endif
	
end sub


sub BossBigEye.Update( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	
	Counter += 1
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	if( OldHP > HP ) then OldHP -= 1
	
	select case State
		case STATE_FALLING:
			Frame = 0
			ActionFalling( Map() )
		case STATE_JUMPING:
			Frame = 0
			ActionJumping( Bullets, Map() )
			if( Dx > 0 ) then
				Flipmode = GL2D.FLIP_H
			else
				Flipmode = GL2D.FLIP_NONE
			endif
		case STATE_IDLE:
			Frame = 0
			ActionIdle( Map() )
		case STATE_STUNNED:
			Frame = 1
			ActionStunned( Map() )
		case STATE_FIRE:
			Frame = 0
			ActionFire( Bullets, Map() )
		case else
	end select	
	

	BoxNormal.Init( x, y, wid, Hei)
	BoxNormal.Resize(0.6, 1 )
	BoxSmall = BoxNormal.GetAABB
	BoxSmall.Resize(0.3, 1 )
 	if( Flipmode = GL2D.FLIP_NONE ) then
 		BoxEye.Init( x + Wid\2 - 16, y + 2, 16, 32)
 	else
 		BoxEye.Init( x + Wid\2, y + 2, 16, 32)
 	endif

	if( InvincibleCounter >= 0  ) then
		InvincibleCounter -= 1
		Frame = int( rnd * 3)
	endif
	
End Sub


sub BossBigEye.Explode()
	
	Explosion.Spawn( Vector3D(x + Wid\2, y + Hei\2, 2), 50 )
	
	Kill()
	
End Sub

sub BossBigEye.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub BossBigEye.Draw( SpriteSet() as GL2D.IMAGE ptr )
		
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

sub BossBigEye.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	BoxSmall.Draw( 4, GL2D_RGB( 0, 255, 255 ) )
	BoxEye.Draw( 4, GL2D_RGB( 255, 255, 0 ) )
	
end sub

sub BossBigEye.DrawStatus( SpriteSet() as GL2D.IMAGE ptr )

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


sub BossBigEye.CollideWithPlayer( byref Snipe as Player )
	
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxSmall.Intersects(Box) ) then
			Snipe.HitAnimation( x, 75 )
		endif		
	endif
	
	dim as integer AttackEnergy = 0
	
	AttackEnergy = Snipe.CollideShots( BoxEye )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 30
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 10000 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxEye )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 30
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 10000 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxEye )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 30
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 10000 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideMines( BoxEye )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		Hp -= 30
		if( HP > 0 ) then
			InvincibleCounter = MAX_INVINCIBLE_COUNTER
		else
			Explode()
			Snipe.AddToScore( 10000 )
		endif
	endif
	
	
	Snipe.CollideShots( BoxNormal )
	
	AttackEnergy = Snipe.CollideMines( BoxNormal )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		State = STATE_STUNNED
		Dy = 1
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxNormal )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		State = STATE_STUNNED
		Dy = 1
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxNormal )
	if( (AttackEnergy) and (InvincibleCounter < 0) ) then
		State = STATE_STUNNED
		Dy = 1
	endif
		
end sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function BossBigEye.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function BossBigEye.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function BossBigEye.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' BossBigEyeFactory
''
''*****************************************************************************

constructor BossBigEyeFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(BossBigEyes)
		BossBigEyes(i).Kill()
	Next
	
End Constructor

destructor BossBigEyeFactory()

End Destructor

property BossBigEyeFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property BossBigEyeFactory.GetMaxEntities() as integer
	property = ubound(BossBigEyes)
end property 

property BossBigEyeFactory.GetPos( byval i as integer ) as Vector2D
	property = type<Vector2D>(BossBigEyes(i).GetX, BossBigEyes(i).GetY) 
end property
	
function BossBigEyeFactory.UpdateEntities( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType ) as integer
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(BossBigEyes)
		if( BossBigEyes(i).IsActive ) then
			BossBigEyes(i).Update( Snipe, Bullets, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
	if( ActiveEntities > 0 ) then return TRUE
	
	return FALSE
		
end function

sub BossBigEyeFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(BossBigEyes)
		if( BossBigEyes(i).IsActive ) then
			BossBigEyes(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub BossBigEyeFactory.DrawEntitiesStatus( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(BossBigEyes)
		if( BossBigEyes(i).IsActive ) then
			BossBigEyes(i).DrawStatus( SpriteSet() )
		EndIf
	Next
	
end sub

sub BossBigEyeFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(BossBigEyes)
		if( BossBigEyes(i).IsActive ) then
			BossBigEyes(i).DrawAABB()
		EndIf
	Next
	
end sub

sub BossBigEyeFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(BossBigEyes)
		if( BossBigEyes(i).IsActive ) then
			BossBigEyes(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub BossBigEyeFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(BossBigEyes)
		
		if( BossBigEyes(i).IsActive ) then
			BossBigEyes(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub BossBigEyeFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(BossBigEyes)
		if( BossBigEyes(i).IsActive = FALSE ) then
			BossBigEyes(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function BossBigEyeFactory.GetAABB( byval i as integer ) as AABB
	
	return BossBigEyes(i).GetBox
	
End Function
	