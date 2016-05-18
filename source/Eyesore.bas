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

#include once "Eyesore.bi"


const as integer MAX_IDLE_COUNTER = 60 * 2
const as integer MAX_MOVING_COUNTER = 60 * 4

constructor Eyesore()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	Direction = D_LEFT
	State = STATE_IDLE
	IdleCounter = MAX_IDLE_COUNTER
	MovingCounter = MAX_MOVING_COUNTER
		
	Xspeed = 1	
	Yspeed = 1	
	
	x = 0
	y = 0
	Dx = 0
	Dy = 1
	

	Frame = 0
	BaseFrame = 153
	NumFrames = 10
	
	Wid = 24
	Hei	= 24
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor Eyesore()

End Destructor


property Eyesore.IsActive() as integer
	property = Active
End Property
		
property Eyesore.GetX() as single
	property = x
End Property

property Eyesore.GetY() as single
	property = y
End Property

property Eyesore.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Eyesore.GetBox() as AABB
	property = BoxNormal
End Property

''*****************************************************************************
''
''*****************************************************************************

function Eyesore.CollideOnMap( Map() as TileType ) as integer
	
	dim as integer TileX, TileY

	if( (Direction = D_RIGHT) or (Direction = D_LEFT) ) then
	
		if( Dx > 0 ) then 
			if( CollideWalls( int(x + Dx + Wid), int(y), TileX, Map() ) ) then 
				x = TileX * TILE_SIZE - Wid - 1
				Xspeed = -Xspeed
				Dx = Xspeed							
			else
				x += Dx 													
			endif
		
		elseif( Dx < 0 ) then																					
			if( CollideWalls( int(x + Dx), int(y), TileX, Map() ) ) then			
				x = ( TileX + 1 ) * TILE_SIZE + 1
				Xspeed = -Xspeed
				Dx = Xspeed						
			else
				x += Dx 													
			endif
		endif
	
	endif	
	

	if( (Direction = D_UP) or (Direction = D_DOWN) ) then
	
		if( Dy < 0 ) then
			
			if( CollideFloors( int(x), int(y + Dy), TileY, Map() ) ) then
				y = ( TileY + 1 ) * TILE_SIZE + 1
				Yspeed = -Yspeed								
				Dy = Yspeed
			else
				y += Dy														
			endif
				
		elseif( Dy > 0 ) then	'' Stationary or moving down
			
			if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then
				y = ( TileY ) * TILE_SIZE - Hei - 1
				Yspeed = -Yspeed								
				Dy = Yspeed														
			else
				y += Dy															
			endif
			
		endif
	
	endif
	return FALSE
	
end function


sub Eyesore.ActionIdle( Map() as TileType, byref Bullets as BulletFactory )
	
	Dx = 0
	Dy = 0
	
	if( IsNearPlayer ) then		
		if( (Counter and 7) = 0 ) then
			Sound.PlaySFX( Sound.SFX_ENEMY_SHOT_01 )
			Bullets.Spawn( x + Wid, y + Hei\2, 0 + Counter, 1.5, Bullet.STATE_NORMAL, Bullet.ID_SAGO )
			Bullets.Spawn( x, y + Hei\2, 180 + Counter, 1.5, Bullet.STATE_NORMAL, Bullet.ID_SAGO )
			Bullets.Spawn( x + Wid\2, y + Hei, 90 + Counter, 1.5, Bullet.STATE_NORMAL, Bullet.ID_SAGO )
			Bullets.Spawn( x + Wid\2, y, 270 + Counter, 1.5, Bullet.STATE_NORMAL, Bullet.ID_SAGO )
		endif
	endif
	
	IdleCounter -= 1
	if( IdleCounter <= 0 ) then
		State = STATE_MOVING
		Direction = int(rnd * 3) + 1
		MovingCounter = (MAX_MOVING_COUNTER\2) + ((rnd * MAX_MOVING_COUNTER)\2)
		ResolveDirectionVectors()
	endif
	
	CollideOnMap( Map() )
	
end sub

sub Eyesore.ActionMoving( Map() as TileType )
	
	MovingCounter -= 1
	if( MovingCounter <= 0 ) then
		if( rnd > 0.2 ) then
			State = STATE_IDLE
			IdleCounter = (MAX_IDLE_COUNTER\2) + ((rnd * MAX_IDLE_COUNTER)\2)
		else
			State = STATE_MOVING
			Direction = int( rnd * 3 ) + 1
			MovingCounter = (MAX_MOVING_COUNTER\2) + ((rnd * MAX_MOVING_COUNTER)\2)
			ResolveDirectionVectors()
		endif
	endif
	
	CollideOnMap( Map() )
	
end sub

	
sub Eyesore.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Direction = int(rnd*3) + 1
	State = STATE_IDLE
	IdleCounter = (MAX_IDLE_COUNTER\2) + ((rnd * MAX_IDLE_COUNTER)\2)
	MovingCounter = (MAX_MOVING_COUNTER\2) + ((rnd * MAX_MOVING_COUNTER)\2)
			
	x = ix
	y = iy
	
	BlinkCounter = -1
	Hp = 100

	ResolveDirectionVectors()
	
	Frame = 0
	BaseFrame = 153
	NumFrames = 10
	
	Wid = 24
	Hei	= 24
	
	BoxNormal.Init( x, y, wid, Hei)
	

End Sub


sub Eyesore.Update( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 15  ) then return
	
	Counter += 1
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	

	if( BlinkCounter > 0 ) then
		BlinkCounter -= 1
	endif
		
	IsNearPlayer = FALSE
	dim as single Dist = ((Snipe.GetX - x) ^ 2)  + ((Snipe.GetY - y) ^ 2)
	if( Dist <= (( TILE_SIZE * 10) ^ 2) ) then IsNearPlayer = TRUE
	
	select case State
		case STATE_IDLE:
			ActionIdle( Map(), Bullets )
		case STATE_MOVING:
			ActionMoving( Map() )
		case else
	end select	
	
	Animate()
	
	BoxNormal.Init( x, y, wid, Hei)
	 
			
End Sub


sub Eyesore.Explode()
	
	Explosion.SpawnMulti( Vector3D(x + Wid\2, y + Hei\2, 2), 2, rnd * 360, Explosion.MEDIUM_YELLOW_01, Explosion.TINY_YELLOW_02, 4 )
	
	Kill()
	
End Sub

sub Eyesore.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
end sub

sub Eyesore.ResolveDirectionVectors()
	
	select case Direction
		case D_RIGHT:
			Xspeed = 0.25	
			Yspeed = 0	
		case D_LEFT:
			Xspeed = -0.25	
			Yspeed = 0
		case D_UP:
			Xspeed = 0	
			Yspeed = -0.25
		case D_DOWN:
			Xspeed = 0	
			Yspeed = -0.25
	end select

	Dx = Xspeed
	Dy = Yspeed
	
end sub
	
sub Eyesore.Animate()
	
	if( Dx < 0) then
		Flipmode = GL2D.FLIP_NONE
	else
		Flipmode = GL2D.FLIP_H
	endif
	
end sub
	
sub Eyesore.Draw( SpriteSet() as GL2D.IMAGE ptr )
		
	if( State = STATE_IDLE ) then frame = 0	
	
	if( (BlinkCounter > 0)  and ((BlinkCounter and 3) = 0) ) then
		GL2D.EnableSpriteStencil( TRUE, GL2D_RGBA(255,255,255,255), GL2D_RGBA(255,255,255,255) )
		GL2D.Sprite( x-2, y-2, FlipMode, SpriteSet( BaseFrame + Frame ) )
		GL2D.EnableSpriteStencil( FALSE )
	else
		GL2D.Sprite( x-2, y-2, FlipMode, SpriteSet( BaseFrame + Frame ) )
	endif
	
	
End Sub

sub Eyesore.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


sub Eyesore.CollideWithPlayer( byref Snipe as Player )
	
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxNormal.Intersects(Box) ) then
			Snipe.HitAnimation( x, 45 )
		endif		
	endif
	
	dim as integer AttackEnergy = 0
	
	AttackEnergy = Snipe.CollideShots( BoxNormal )
	if( AttackEnergy ) then
		Hp -= 36
		BlinkCounter = MAX_ENEMY_BLINK_COUNTER
		if( Hp <= 0 ) then
			Explode()
			Snipe.AddToScore( 311 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 311 )
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 311 )
	endif
	
	AttackEnergy = Snipe.CollideMines( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 311 )
	endif
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Eyesore.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function Eyesore.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function Eyesore.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' EyesoreFactory
''
''*****************************************************************************

constructor EyesoreFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Eyesores)
		Eyesores(i).Kill()
	Next
	
End Constructor

destructor EyesoreFactory()

End Destructor

property EyesoreFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property EyesoreFactory.GetMaxEntities() as integer
	property = ubound(Eyesores)
end property 

sub EyesoreFactory.UpdateEntities( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Eyesores)
		if( Eyesores(i).IsActive ) then
			Eyesores(i).Update( Snipe, Bullets, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub EyesoreFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Eyesores)
		if( Eyesores(i).IsActive ) then
			Eyesores(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub EyesoreFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Eyesores)
		if( Eyesores(i).IsActive ) then
			Eyesores(i).DrawAABB()
		EndIf
	Next
	
end sub

sub EyesoreFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Eyesores)
		if( Eyesores(i).IsActive ) then
			Eyesores(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub EyesoreFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(Eyesores)
		
		if( Eyesores(i).IsActive ) then
			Eyesores(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub EyesoreFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(Eyesores)
		if( Eyesores(i).IsActive = FALSE ) then
			Eyesores(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function EyesoreFactory.GetAABB( byval i as integer ) as AABB
	
	return Eyesores(i).GetBox
	
End Function
	