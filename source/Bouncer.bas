''*****************************************************************************
''
''
''	Pyromax Dax Bouncer Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Bouncer.bi"


constructor Bouncer()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	Orientation = ORIENTATION_LEFT
	State = STATE_FALLING
	
	Speed = 1	
	CurrentJumpHeight = JUMPHEIGHT
	
	x = 0
	y = 0
	Dx = 0
	Dy = 1
	

	Frame = 0
	BaseFrame = 56
	NumFrames = 4
	
	Wid = 20
	Hei	= 20
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor Bouncer()

End Destructor


property Bouncer.IsActive() as integer
	property = Active
End Property
		
property Bouncer.GetX() as single
	property = x
End Property

property Bouncer.GetY() as single
	property = y
End Property

property Bouncer.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Bouncer.GetBox() as AABB
	property = BoxNormal
End Property

''*****************************************************************************
''
''*****************************************************************************

sub Bouncer.CollideOnFloors( Map() as TileType )
	
	dim as integer TileX, TileY

	if( Dy < 0 ) then   	'' moving Up
		
		if( CollideFloors( int(x), int(y + Dy), TileY, Map() ) ) then   		'' hit the roof
			y = ( TileY + 1 ) * TILE_SIZE + 1									'' Snap below the tile
			Dy = 0    															'' Arrest movement
		else
			y += Dy																'' No collision so move
			Dy += GRAVITY														'' with gravity
		EndIf
			
	else	'' Stationary or moving down
		
		if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	'' (y + Dy + hei) = Foot of player
			y = ( TileY ) * TILE_SIZE - Hei - 1								'' Snap above the tile
			CurrentJumpHeight *= 0.8
			if( CurrentJumpHeight <= (JUMPHEIGHT/8)) then
				CurrentJumpHeight = JUMPHEIGHT
			endif
			Dy = -CurrentJumpHeight						
		else
			y += Dy															'' No collision so move
			Dy += GRAVITY
		EndIf
		
	EndIf
	
end sub

sub Bouncer.ActionFalling( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - Hei - 1
		if( Orientation = ORIENTATION_LEFT ) then						
			Dy = -CurrentJumpHeight
			Dx = -Speed
			State = STATE_MOVE_LEFT
		else
			Dy = -CurrentJumpHeight
			Dx = Speed
			State = STATE_MOVE_RIGHT
		endif
	else
		y += Dy												
		Dy += GRAVITY
	endif
	
		
end sub

sub Bouncer.ActionMoveRight( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideWalls( int(x + Dx + Wid), int(y), TileX, Map() ) ) then
		x = TileX * TILE_SIZE - Wid - 1
		Dx = -Speed
		State = STATE_MOVE_LEFT
	else		
		x += Dx
	endif
	
	CollideOnFloors( Map() )
	
end sub

sub Bouncer.ActionMoveLeft( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideWalls( int(x + Dx), int(y), TileX, Map() ) ) then
		x = ( TileX + 1 ) * TILE_SIZE + 1
		Dx = Speed
		State = STATE_MOVE_RIGHT
	else
		x += Dx
	endif

	CollideOnFloors( Map() )
	
end sub

	
sub Bouncer.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Orientation = iOrientation
	State = STATE_FALLING
	if( Orientation = ORIENTATION_LEFT ) then
		FlipMode = GL2D.FLIP_NONE
	else
		FlipMode = GL2D.FLIP_H
	endif
	
	Speed = 0.75
	CurrentJumpHeight = JUMPHEIGHT
	
	Hp = 100
	BlinkCounter = -1
	
	x = ix
	y = iy
	
	Dx = 0
	Dy = 1
	
	Frame = 0
	BaseFrame = 56
	NumFrames = 4
	
	Wid = 20
	Hei	= 20
	
	BoxNormal.Init( x, y, wid, Hei)
	

End Sub


sub Bouncer.Update( byref Snipe as Player, Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 12  ) then return
	
	Counter + = 1
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	if( BlinkCounter > 0 ) then
		BlinkCounter -= 1
	endif
	
	select case State
		case STATE_FALLING:
			ActionFalling( Map() )
		case STATE_MOVE_RIGHT:
			ActionMoveRight( Map() )
		case STATE_MOVE_LEFT:
			ActionMoveLeft( Map() )
		case else
	end select	
	

	BoxNormal.Init( x, y, wid, Hei)
	 
			
End Sub


sub Bouncer.Explode()

	Explosion.SpawnMulti( Vector3D(x + Wid\2, y + Hei\2, 2), 2, rnd * 360, Explosion.MEDIUM_YELLOW_02, Explosion.SMOKE_01, 4 )	
	Kill()
	
End Sub

sub Bouncer.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub Bouncer.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	if( State = STATE_MOVE_RIGHT ) then
		FlipMode = GL2D.FLIP_NONE
	else
		FlipMode = GL2D.FLIP_H
	endif


	if( (BlinkCounter > 0)  and ((BlinkCounter and 3) = 0) ) then
		GL2D.EnableSpriteStencil( TRUE, GL2D_RGBA(255,255,255,255), GL2D_RGBA(255,255,255,255) )
		GL2D.Sprite( x-4, y, FlipMode, SpriteSet( BaseFrame + Frame ) )
		GL2D.EnableSpriteStencil( FALSE )
	else
		GL2D.Sprite( x-4, y, FlipMode, SpriteSet( BaseFrame + Frame ) )
	endif
End Sub

sub Bouncer.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


sub Bouncer.CollideWithPlayer( byref Snipe as Player )
	
	
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
			Snipe.AddToScore( 102 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 102 )
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 102 )
	endif
	
	AttackEnergy = Snipe.CollideMines( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 102 )
	endif
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Bouncer.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function Bouncer.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function Bouncer.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' BouncerFactory
''
''*****************************************************************************

constructor BouncerFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Bouncers)
		Bouncers(i).Kill()
	Next
	
End Constructor

destructor BouncerFactory()

End Destructor

property BouncerFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property BouncerFactory.GetMaxEntities() as integer
	property = ubound(Bouncers)
end property 

sub BouncerFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Bouncers)
		if( Bouncers(i).IsActive ) then
			Bouncers(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub BouncerFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Bouncers)
		if( Bouncers(i).IsActive ) then
			Bouncers(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub BouncerFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Bouncers)
		if( Bouncers(i).IsActive ) then
			Bouncers(i).DrawAABB()
		EndIf
	Next
	
end sub

sub BouncerFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Bouncers)
		if( Bouncers(i).IsActive ) then
			Bouncers(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub BouncerFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(Bouncers)
		
		if( Bouncers(i).IsActive ) then
			Bouncers(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub BouncerFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(Bouncers)
		if( Bouncers(i).IsActive = FALSE ) then
			Bouncers(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function BouncerFactory.GetAABB( byval i as integer ) as AABB
	
	return Bouncers(i).GetBox
	
End Function
	