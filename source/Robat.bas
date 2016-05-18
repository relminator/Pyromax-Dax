''*****************************************************************************
''
''
''	Pyromax Dax Robat Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Robat.bi"


const as integer MAX_IDLE_COUNTER = 30
const as integer MAX_CHANGE_DIRECTION_COUNTER = 60 * 3
const as integer MAX_STATE_COUNTER = 60 

constructor Robat()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	Orientation = ORIENTATION_LEFT
	State = STATE_PASSIVE
	IdleCounter = MAX_IDLE_COUNTER
	ChangeDirectionCounter = 0
		
	Speed = 1	
	x = 0
	y = 0
	Dx = 0
	Dy = 0
	

	Frame = 0
	BaseFrame = 0
	NumFrames = 1
	
	Wid = 20
	Hei	= 20
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor Robat()

End Destructor


property Robat.IsActive() as integer
	property = Active
End Property
		
property Robat.GetX() as single
	property = x
End Property

property Robat.GetY() as single
	property = y
End Property

property Robat.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Robat.GetBox() as AABB
	property = BoxNormal
End Property

''*****************************************************************************
''
''*****************************************************************************

function Robat.CollideOnMap( Map() as TileType ) as integer
	
	dim as integer TileX, TileY

	if( Dx > 0 ) then 
		if( CollideWalls( int(x + Dx + Wid), int(y), TileX, Map() ) ) then 
			x = TileX * TILE_SIZE - Wid - 1
			Dx = -Dx							
		else
			x += Dx 													
		endif
	
	elseif( Dx < 0 ) then																					
		if( CollideWalls( int(x + Dx), int(y), TileX, Map() ) ) then			
			x = ( TileX + 1 ) * TILE_SIZE + 1
			Dx = -Dx						
		else
			x += Dx 													
		endif
	endif
	
	

	if( Dy < 0 ) then   	'' moving Up
		
		if( CollideFloors( int(x), int(y + Dy), TileY, Map() ) ) then   		'' hit the roof
			y = ( TileY + 1 ) * TILE_SIZE + 1									'' Snap below the tile
			Dy = 0    															'' Arrest movement
			return TRUE		
		else
			y += Dy																'' No collision so move
		endif
			
	elseif( Dy > 0 ) then	'' Stationary or moving down
		
		if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	'' (y + Dy + hei) = Foot of player
			y = ( TileY ) * TILE_SIZE - Hei - 1								'' Snap above the tile
			Dy = 0															'' Set to 1 so that we always collide with floor next frame
		else
			y += Dy															'' No collision so move
		endif
		
	endif
	
	return FALSE
	
end function


sub Robat.ActionIdle( Map() as TileType )
	
	Dx = 0
	Dy = 0
	CollideOnMap( Map() )
	
	IdleCounter -= 1
	if( IdleCounter <= 0 ) then
		StateCounter = MAX_STATE_COUNTER
		State = STATE_GO_DOWN
		IdleCounter = MAX_IDLE_COUNTER
		ResolveAnimationParameters()
	elseif( IdleCounter = MAX_IDLE_COUNTER \ 2 ) then
		BaseFrame = 1
	endif
	
end sub

sub Robat.ActionBackUp( Map() as TileType )
	
	Dx = 0
	Dy = -Speed * 5

	if( CollideOnMap( Map() ) ) then
		StateCounter = MAX_STATE_COUNTER
		State = STATE_IDLE
		IdleCounter = MAX_IDLE_COUNTER
		ResolveAnimationParameters()
	endif
	
end sub

sub Robat.ActionGoDown( Map() as TileType )
	
	Dx = 0
	Dy = 0
	CollideOnMap( Map() )

	StateCounter -= 1
	if( StateCounter <= MAX_STATE_COUNTER-10 ) then
		StateCounter = MAX_STATE_COUNTER
		State = STATE_PASSIVE
		IdleCounter = MAX_IDLE_COUNTER
		ResolveAnimationParameters()
	endif
	
end sub


sub Robat.ActionPassive( Map() as TileType )
	
	CollideOnMap( Map() )
	
end sub

sub Robat.ActionAggressive( Map() as TileType )
	
	CollideOnMap( Map() )
	
end sub

	
sub Robat.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Orientation = iOrientation
	State = STATE_IDLE
	FlipMode = GL2D.FLIP_NONE
	IdleCounter = MAX_IDLE_COUNTER
	ChangeDirectionCounter = 0
	
	Speed = 0.275
	Angle = 0
	
	BlinkCounter = -1
	Hp = 100
	
	x = ix
	y = iy + 2
	
	Dx = 0
	Dy = 0
	
	Frame = 0
	BaseFrame = 0
	NumFrames = 1
	
	Wid = 20
	Hei	= 20
	
	BoxNormal.Init( x, y, wid, Hei)
	

End Sub


sub Robat.Update( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 15  ) then return
	
	Counter += 1
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	if( BlinkCounter > 0 ) then
		BlinkCounter -= 1
	endif
	
	
	select case State
		case STATE_IDLE:
			ActionIdle( Map() )
		case STATE_BACK_UP:
			ActionBackUp( Map() )
		case STATE_GO_DOWN:
			ActionGoDown( Map() )
		case STATE_PASSIVE:
			ChangeDirectionCounter -= 1
			if( ChangeDirectionCounter <= 0 ) then
				Angle = atan2(Snipe.GetY-y, Snipe.GetX-x)
				ChangeDirectionCounter = MAX_CHANGE_DIRECTION_COUNTER
				Dx = cos(Angle) * Speed
				Dy = sin(Angle) * Speed
			endif
			dim as single Dist = ((Snipe.GetX - x) ^ 2)  + ((Snipe.GetY - y) ^ 2)
			if( Dist <= (( TILE_SIZE * 8) ^ 2) ) then
				State = STATE_AGGRESSIVE
				ResolveAnimationparameters()
			endif	
			if( ((Counter and 255) = 0) and (Dist <= (( TILE_SIZE * 7) ^ 2)) ) then
				Sound.PlaySFX( Sound.SFX_ENEMY_SHOT_01 )
				dim as integer a = RAD2DEG(Angle)
				Bullets.Spawn( x + Wid\2, y + Hei\2 + 4, UTIL.Wrap(a - 30, 0, 359), 1.5, Bullet.STATE_BOUNCE, Bullet.ID_MINI_FRISBEE )
				Bullets.Spawn( x + Wid\2, y + Hei\2 + 4, a, 2.5, Bullet.STATE_BOUNCE, Bullet.ID_FRISBEE )
				Bullets.Spawn( x + Wid\2, y + Hei\2 + 4, UTIL.Wrap(a + 30, 0, 359), 1.5, Bullet.STATE_BOUNCE, Bullet.ID_MINI_FRISBEE )
			endif
			ActionPassive( Map() )	
		case STATE_AGGRESSIVE:
			ChangeDirectionCounter -= 1
			if( ChangeDirectionCounter <= 0 ) then
				Angle = atan2(Snipe.GetY-y, Snipe.GetX-x)
				ChangeDirectionCounter = MAX_CHANGE_DIRECTION_COUNTER \ 8
				Dx = cos(Angle) * Speed * 3
				Dy = sin(Angle) * Speed * 3
			endif
			dim as single Dist = ((Snipe.GetX - x) ^ 2)  + ((Snipe.GetY - y) ^ 2)
			if( Dist >= (( TILE_SIZE * 8) ^ 2) ) then
				State = STATE_PASSIVE
				ResolveAnimationparameters()
			endif
			if( ((Counter and 255) = 0) and (Dist <= (( TILE_SIZE * 7) ^ 2)) ) then
				dim as integer a = RAD2DEG(Angle)
				Bullets.Spawn( x + Wid\2, y + Hei\2 + 4, UTIL.Wrap(a - 30, 0, 359), 1.5, Bullet.STATE_BOUNCE, Bullet.ID_MINI_FRISBEE )
				Bullets.Spawn( x + Wid\2, y + Hei\2 + 4, a, 2.5, Bullet.STATE_BOUNCE, Bullet.ID_FRISBEE )
				Bullets.Spawn( x + Wid\2, y + Hei\2 + 4, UTIL.Wrap(a + 30, 0, 359), 1.5, Bullet.STATE_BOUNCE, Bullet.ID_MINI_FRISBEE )
			endif
			ActionAggressive( Map() )
		case else
	end select	
	
	
	BoxNormal.Init( x, y, wid, Hei)
	 
			
End Sub


sub Robat.Explode()
	
	Explosion.SpawnMulti( Vector3D(x + Wid\2, y + Hei\2, 2), 2, rnd * 360, Explosion.MEDIUM_YELLOW_03, Explosion.SMOKE_01, 4 )	
	
	Kill()
	
End Sub

sub Robat.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
end sub

sub Robat.ResolveAnimationParameters()
	
	select case State
		case STATE_IDLE:
			Frame = 0
			BaseFrame = 0
			NumFrames = 1
		case STATE_BACK_UP:
			Frame = 0
			BaseFrame = 2
			NumFrames = 1
		case STATE_GO_DOWN:
			Frame = 0
			BaseFrame = 2
			NumFrames = 1
		case STATE_PASSIVE:
			Frame = 0
			BaseFrame = 3
			NumFrames = 7
		case STATE_AGGRESSIVE:
			Frame = 0
			BaseFrame = 3
			NumFrames = 7
	end select	
	
end sub
	
sub Robat.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	if( (BlinkCounter > 0)  and ((BlinkCounter and 3) = 0) ) then
		GL2D.EnableSpriteStencil( TRUE, GL2D_RGBA(255,255,255,255), GL2D_RGBA(255,255,255,255) )
		GL2D.Sprite( x-12, y - 4, FlipMode, SpriteSet( BaseFrame + Frame ) )
		GL2D.EnableSpriteStencil( FALSE )
	else
		GL2D.Sprite( x-12, y - 4, FlipMode, SpriteSet( BaseFrame + Frame ) )
	endif
		
End Sub

sub Robat.DrawAABB()
	
	'dim as single iDx = cos(Angle) * 32
	'dim as single iDy = sin(Angle) * 32
	'
	'GL2D.Box3D( x + iDx, y + iDy,x + iDx + 1, y + iDy + 1, 4, GL2D_RGB(255,255,255)  )
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


sub Robat.CollideWithPlayer( byref Snipe as Player )
	
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxNormal.Intersects(Box) ) then
			Snipe.HitAnimation( x, 45 )
			StateCounter = MAX_STATE_COUNTER
			State = STATE_BACK_UP
			ResolveAnimationParameters()
		endif		
	endif
	
	dim as integer AttackEnergy = 0
	
	AttackEnergy = Snipe.CollideShots( BoxNormal )
	if( AttackEnergy ) then
		Hp -= 36
		BlinkCounter = MAX_ENEMY_BLINK_COUNTER
		if( Hp <= 0 ) then
			Explode()
			Snipe.AddToScore( 501 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 501 )
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 501 )
	endif
	
	AttackEnergy = Snipe.CollideMines( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 501 )
	endif
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Robat.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function Robat.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function Robat.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' RobatFactory
''
''*****************************************************************************

constructor RobatFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Robats)
		Robats(i).Kill()
	Next
	
End Constructor

destructor RobatFactory()

End Destructor

property RobatFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property RobatFactory.GetMaxEntities() as integer
	property = ubound(Robats)
end property 

sub RobatFactory.UpdateEntities( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Robats)
		if( Robats(i).IsActive ) then
			Robats(i).Update( Snipe, Bullets, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub RobatFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Robats)
		if( Robats(i).IsActive ) then
			Robats(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub RobatFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Robats)
		if( Robats(i).IsActive ) then
			Robats(i).DrawAABB()
		EndIf
	Next
	
end sub

sub RobatFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Robats)
		if( Robats(i).IsActive ) then
			Robats(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub RobatFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(Robats)
		
		if( Robats(i).IsActive ) then
			Robats(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub RobatFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(Robats)
		if( Robats(i).IsActive = FALSE ) then
			Robats(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function RobatFactory.GetAABB( byval i as integer ) as AABB
	
	return Robats(i).GetBox
	
End Function
	