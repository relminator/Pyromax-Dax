''*****************************************************************************
''
''
''	Pyromax Dax Grog Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Grog.bi"


constructor Grog()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	Orientation = ORIENTATION_LEFT
	State = STATE_FALLING
	
	Speed = 1	
	x = 0
	y = 0
	Dx = 0
	Dy = 1
	

	Frame = 0
	BaseFrame = 66
	NumFrames = 8
	
	Wid = 24
	Hei	= 24
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor Grog()

End Destructor


property Grog.IsActive() as integer
	property = Active
End Property
		
property Grog.GetX() as single
	property = x
End Property

property Grog.GetY() as single
	property = y
End Property

property Grog.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Grog.GetBox() as AABB
	property = BoxNormal
End Property

''*****************************************************************************
''
''*****************************************************************************

sub Grog.CollideOnFloors( Map() as TileType )
	
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
			Dy = 1															'' Set to 1 so that we always collide with floor next frame
		else
			y += Dy															'' No collision so move
			Dy += GRAVITY
		EndIf
		
	EndIf
	
end sub

sub Grog.ActionFalling( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - Hei - 1
		if( Orientation = ORIENTATION_LEFT ) then						
			Dy = 1
			Dx = -Speed
			State = STATE_MOVE_LEFT
		else
			Dy = 1
			Dx = Speed
			State = STATE_MOVE_RIGHT
		endif
	else
		y += Dy												
		Dy += GRAVITY
	endif
	
		
end sub

sub Grog.ActionMoveRight( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideWalls( int(x + Dx * SpeedUp + Wid), int(y), TileX, Map() ) ) then
		x = TileX * TILE_SIZE - Wid - 1
		Dx = -Speed
		State = STATE_MOVE_LEFT
	elseif( not CollideFloors( int(x + Wid), (y + Hei + TILE_SIZE\2), TileY, Map() ) ) then	
		Dx = -Speed
		State = STATE_MOVE_LEFT
	else
		x += Dx * SpeedUp
	endif
	
	CollideOnFloors( Map() )
	
end sub

sub Grog.ActionMoveLeft( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideWalls( int(x + Dx * SpeedUp), int(y), TileX, Map() ) ) then
		x = ( TileX + 1 ) * TILE_SIZE + 1
		Dx = Speed
		State = STATE_MOVE_RIGHT
	elseif( not CollideFloors( int(x - Wid), (y + Hei + TILE_SIZE\2), TileY, Map() ) ) then	
		Dx = Speed
		State = STATE_MOVE_RIGHT
	else
		x += Dx * SpeedUp
	endif

	CollideOnFloors( Map() )
	
end sub

	
sub Grog.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Orientation = iOrientation
	State = STATE_FALLING
	
	BlinkCounter = -1
	Hp = 100
	
	if( Orientation = ORIENTATION_LEFT ) then
		FlipMode = GL2D.FLIP_NONE
	else
		FlipMode = GL2D.FLIP_H
	endif
	
	Speed = 0.75
	SpeedUp = 1
	
	x = ix
	y = iy
	
	Dx = 0
	Dy = 1
	
	Frame = 0
	BaseFrame = 66
	NumFrames = 8
	
	Wid = 24
	Hei	= 24
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Sub

function Grog.SeePlayer( byref Snipe as Player, Map() as TileType ) as integer
	
	const as integer TileDistanceThreshold = 5
	
	dim as integer Tx = x \ TILE_SIZE
	dim as integer Ty = y \ TILE_SIZE
	dim as integer Ptx = Snipe.GetX \ TILE_SIZE 
	dim as integer Pty = Snipe.GetY \ TILE_SIZE 
	
	if( Pty = Ty ) then	
		if( abs(Ptx - Tx) <= TileDistanceThreshold ) then
			return TRUE
		endif
	endif
	
	return FALSE
	
End Function
	
sub Grog.Update( byref Snipe as Player, Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > (MAX_DISTANCE_FROM_PLAYER + 4)  ) then return
	
	Counter + = 1
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	if( BlinkCounter > 0 ) then
		BlinkCounter -= 1
	endif
	
	if( SeePlayer( Snipe, Map() ) )  then
		SpeedUp = 2.5
	else
		SpeedUp = 1
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


sub Grog.Explode()
	
	Explosion.SpawnMulti( Vector3D(x + Wid\2, y + Hei\2, 2), 2, rnd * 360, Explosion.MEDIUM_YELLOW_01, Explosion.TINY_YELLOW_01, 4 )
	
	Kill()
	
End Sub

sub Grog.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub Grog.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
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

sub Grog.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub

function Grog.PlayerCollideHead( byref Snipe as Player ) as integer
	
	dim as AABB Box = Snipe.GetBoxNormal
	dim as integer TestEnd = Snipe.GetX + Snipe.GetWid
	dim as integer ix = Snipe.GetX
	
	Box.y1 += Snipe.GetDy * 3
	Box.y2 += Snipe.GetDy * 3
	
	while( ix <= TestEnd ) 
		if( ix >= x ) then
			if( ix <= (x + Wid) ) then
				if( BoxNormal.Intersects(Box) ) then
					return TRUE
				endif
			endif
		endif
		ix += Snipe.GetWid
	Wend
	
	return FALSE
				
End Function

sub Grog.CollideWithPlayer( byref Snipe as Player )
	
	if( (Snipe.GetDy > 0) and ((Snipe.GetY + Snipe.GetHei) <= y) ) then
		if( PlayerCollideHead( Snipe ) ) then		 '' Snap player to top of head 
			Snipe.SetY = ((y - Snipe.GetHei) - 2)
			Snipe.SetDy = 1
			Snipe.SetOnPlatform = TRUE
			if( (Snipe.GetState <> Player.WALKING) and (Snipe.GetState <> Player.BREAKING) ) then   '' Account for speed  
				Snipe.SetOnSideOfPlatform = FALSE													'' of Platform when snipe
				Snipe.SetX = Snipe.GetX + Dx
				Snipe.SetDx = Snipe.GetDx + Dx														'' is riding above it
			endif
			
		endif		
	endif
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxNormal.Intersects(Box) ) then
			Snipe.HitAnimation( x, 65 )
		endif		
	endif
	
	dim as integer AttackEnergy = 0
	
	AttackEnergy = Snipe.CollideShots( BoxNormal )
	if( AttackEnergy ) then
		Hp -= 26
		BlinkCounter = MAX_ENEMY_BLINK_COUNTER
		if( Hp <= 0 ) then
			Explode()
			Snipe.AddToScore( 202 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 202 )
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 202 )
	endif
	
	AttackEnergy = Snipe.CollideMines( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 202 )
	endif
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Grog.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function Grog.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function Grog.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' GrogFactory
''
''*****************************************************************************

constructor GrogFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Grogs)
		Grogs(i).Kill()
	Next
	
End Constructor

destructor GrogFactory()

End Destructor

property GrogFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property GrogFactory.GetMaxEntities() as integer
	property = ubound(Grogs)
end property 

sub GrogFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Grogs)
		if( Grogs(i).IsActive ) then
			Grogs(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub GrogFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Grogs)
		if( Grogs(i).IsActive ) then
			Grogs(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub GrogFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Grogs)
		if( Grogs(i).IsActive ) then
			Grogs(i).DrawAABB()
		EndIf
	Next
	
end sub

sub GrogFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Grogs)
		if( Grogs(i).IsActive ) then
			Grogs(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub GrogFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(Grogs)
		
		if( Grogs(i).IsActive ) then
			Grogs(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub GrogFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(Grogs)
		if( Grogs(i).IsActive = FALSE ) then
			Grogs(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function GrogFactory.GetAABB( byval i as integer ) as AABB
	
	return Grogs(i).GetBox
	
End Function
	