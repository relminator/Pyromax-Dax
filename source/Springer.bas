''*****************************************************************************
''
''
''	Pyromax Dax Springer Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Springer.bi"

const as integer MAX_GO_CRAZY_COUNTER = 60 * 5
	
constructor Springer()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	Orientation = ORIENTATION_LEFT
	State = STATE_FALLING
	GoCrazyCounter = MAX_GO_CRAZY_COUNTER
	OldState = State
	
	Speed = 0.25	
	x = 0
	y = 0
	Dx = 0
	Dy = 1
	

	Frame = 0
	BaseFrame = 182
	NumFrames = 1
	
	Wid = 24
	Hei	= 16
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor Springer()

End Destructor


property Springer.IsActive() as integer
	property = Active
End Property
		
property Springer.GetX() as single
	property = x
End Property

property Springer.GetY() as single
	property = y
End Property

property Springer.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Springer.GetBox() as AABB
	property = BoxNormal
End Property

''*****************************************************************************
''
''*****************************************************************************

sub Springer.CollideOnFloors( Map() as TileType )
	
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

sub Springer.ActionFalling( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - Hei - 1
		if( Orientation = ORIENTATION_LEFT ) then						
			Dy = 1
			Dx = -Speed
			State = STATE_MOVE_LEFT
			ResolveAnimationParameters()
		else
			Dy = 1
			Dx = Speed
			State = STATE_MOVE_RIGHT
			ResolveAnimationParameters()
		endif
	else
		y += Dy												
		Dy += GRAVITY
	endif
	
		
end sub

sub Springer.ActionMoveRight( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideWalls( int(x + Dx * SpeedUp + Wid), int(y), TileX, Map() ) ) then
		x = TileX * TILE_SIZE - Wid - 1
		Dx = -Speed
		State = STATE_MOVE_LEFT
		ResolveAnimationParameters()
	elseif( not CollideFloors( int(x + Wid), (y + Hei + TILE_SIZE\2), TileY, Map() ) ) then	
		Dx = -Speed
		State = STATE_MOVE_LEFT
		ResolveAnimationParameters()
	else
		x += Dx * SpeedUp
	endif
	
	CollideOnFloors( Map() )
	
end sub

sub Springer.ActionMoveLeft( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideWalls( int(x + Dx * SpeedUp), int(y), TileX, Map() ) ) then
		x = ( TileX + 1 ) * TILE_SIZE + 1
		Dx = Speed
		State = STATE_MOVE_RIGHT
		ResolveAnimationParameters()
	elseif( not CollideFloors( int(x - Wid), (y + Hei + TILE_SIZE\2), TileY, Map() ) ) then	
		Dx = Speed
		State = STATE_MOVE_RIGHT
		ResolveAnimationParameters()
	else
		x += Dx * SpeedUp
	endif

	CollideOnFloors( Map() )
	
end sub


sub Springer.ActionGoCrazy( Map() as TileType )
	
	Dx = 0
	Dy = 0
	GoCrazyCounter -= 1
	if( GoCrazyCounter <= 0 ) then
		GoCrazyCounter = MAX_GO_CRAZY_COUNTER
		State = OldState
		if( State = STATE_MOVE_LEFT ) then
			Dx = -Speed
		else
			Dx = Speed
		endif
		ResolveAnimationParameters()
	endif
	
	CollideOnFloors( Map() )
	
end sub

	
sub Springer.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Orientation = iOrientation
	State = STATE_FALLING
	GoCrazyCounter = MAX_GO_CRAZY_COUNTER
	OldState = State
	
	FlipMode = GL2D.FLIP_NONE
	
	Speed = 0.25
	SpeedUp = 1
	
	BlinkCounter = -1
	Hp = 100
	
	x = ix
	y = iy
	
	Dx = 0
	Dy = 1
	
	Frame = 0
	BaseFrame = 182
	NumFrames = 1
	
	Wid = 24
	Hei	= 16
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Sub

function Springer.SeePlayer( byref Snipe as Player, Map() as TileType ) as integer
	
	const as integer TileDistanceThreshold = 9
	
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
	
sub Springer.Update( byref Snipe as Player, Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 12  ) then return
		
	Counter + = 1
	
	if( (Counter and 7) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	if( BlinkCounter > 0 ) then
		BlinkCounter -= 1
	endif
	
	if( SeePlayer( Snipe, Map() ) )  then
		SpeedUp = 10.0
	else
		SpeedUp = 1
	endif
	
	select case State
		case STATE_FALLING:
			ActionFalling( Map() )
			BoxNormal.Init( x, y, wid, Hei)
		case STATE_MOVE_RIGHT:
			ActionMoveRight( Map() )
			BoxNormal.Init( x, y, wid, Hei)
		case STATE_MOVE_LEFT:
			ActionMoveLeft( Map() )
			BoxNormal.Init( x, y, wid, Hei)
		case STATE_GO_CRAZY:
			ActionGoCrazy( Map() )
			BoxNormal.Init( x, y-20, wid, Hei+20)
		case else
	end select	
	

	 
			
End Sub


sub Springer.Explode()
	
	Explosion.SpawnMulti( Vector3D(x + Wid\2, y + Hei\2, 2), 2, rnd * 360, Explosion.MEDIUM_YELLOW_02, Explosion.MEDIUM_YELLOW_01, 8 )	
	
	Kill()
	
End Sub

sub Springer.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub Springer.ResolveAnimationParameters()
	
	select case State
		case STATE_FALLING:
			Frame = 0
			BaseFrame = 184
			NumFrames = 1	
		case STATE_MOVE_LEFT:
			Frame = 0
			BaseFrame = 182
			NumFrames = 1
		case STATE_MOVE_RIGHT:
			Frame = 0
			BaseFrame = 183
			NumFrames = 1
		case STATE_GO_CRAZY:
			Frame = 0
			BaseFrame = 185
			NumFrames = 4
		case else
	end select	
end sub

sub Springer.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	if( (BlinkCounter > 0)  and ((BlinkCounter and 3) = 0) ) then
		GL2D.EnableSpriteStencil( TRUE, GL2D_RGBA(255,255,255,255), GL2D_RGBA(255,255,255,255) )
		GL2D.Sprite( x-20, y-28, FlipMode, SpriteSet( BaseFrame + Frame ) )
		GL2D.EnableSpriteStencil( FALSE )
	else
		GL2D.Sprite( x-20, y-28, FlipMode, SpriteSet( BaseFrame + Frame ) )
	endif
	
End Sub

sub Springer.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


sub Springer.CollideWithPlayer( byref Snipe as Player )
	
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxNormal.Intersects(Box) ) then
			Snipe.HitAnimation( x, 65 )
			OldState = State
			State = STATE_GO_CRAZY
			ResolveAnimationParameters()
		endif		
	endif
	
	dim as integer AttackEnergy = 0
	
	AttackEnergy = Snipe.CollideShots( BoxNormal )
	if( AttackEnergy ) then
		Hp -= 26
		BlinkCounter = MAX_ENEMY_BLINK_COUNTER
		if( Hp <= 0 ) then
			Explode()
			Snipe.AddToScore( 305 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 305 )
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 305 )
	endif
	
	AttackEnergy = Snipe.CollideMines( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 305 )
	endif
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Springer.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function Springer.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function Springer.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' SpringerFactory
''
''*****************************************************************************

constructor SpringerFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Springers)
		Springers(i).Kill()
	Next
	
End Constructor

destructor SpringerFactory()

End Destructor

property SpringerFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property SpringerFactory.GetMaxEntities() as integer
	property = ubound(Springers)
end property 

sub SpringerFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Springers)
		if( Springers(i).IsActive ) then
			Springers(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub SpringerFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Springers)
		if( Springers(i).IsActive ) then
			Springers(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub SpringerFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Springers)
		if( Springers(i).IsActive ) then
			Springers(i).DrawAABB()
		EndIf
	Next
	
end sub

sub SpringerFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Springers)
		if( Springers(i).IsActive ) then
			Springers(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub SpringerFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(Springers)
		
		if( Springers(i).IsActive ) then
			Springers(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub SpringerFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(Springers)
		if( Springers(i).IsActive = FALSE ) then
			Springers(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function SpringerFactory.GetAABB( byval i as integer ) as AABB
	
	return Springers(i).GetBox
	
End Function
	