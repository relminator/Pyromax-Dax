''*****************************************************************************
''
''
''	Pyromax Dax Robox Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Robox.bi"

const as integer MAX_IDLE_COUNTER = 60 * 2

constructor Robox()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	Orientation = HORIZONTAL
	State = STATE_IDLE
	Idlecounter = MAX_IDLE_COUNTER
	
	Speed = 1	
	x = 0
	y = 0
	Dx = 0
	Dy = 1
	

	Frame = 0
	BaseFrame = 49
	NumFrames = 1
	
	Wid = 24
	Hei	= 24
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor Robox()

End Destructor


property Robox.IsActive() as integer
	property = Active
End Property
		
property Robox.GetX() as single
	property = x
End Property

property Robox.GetY() as single
	property = y
End Property

property Robox.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Robox.GetBox() as AABB
	property = BoxNormal
End Property

''*****************************************************************************
''
''*****************************************************************************
sub Robox.ActionIdle( Map() as TileType )
	
	Dx = 0
	Dy = 0
	
	select case IdleCounter 
		case MAX_IDLE_COUNTER: 
			Frame = 2
		case MAX_IDLE_COUNTER\3:
			Frame = 1
		case MAX_IDLE_COUNTER\4:
			Frame = 0
	end select
	
	Idlecounter -= 1
	if( Idlecounter <= 0 ) then
		State = NextState
		ResolveDirectionVectors()
	endif
	
end sub

sub Robox.ActionMoveRight( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideWalls( int(x + Dx + Wid), int(y), TileX, Map() ) ) then
		x = TileX * TILE_SIZE - Wid - 1
		State = STATE_IDLE
		NextState = STATE_MOVE_LEFT
		Idlecounter = MAX_IDLE_COUNTER
		ResolveDirectionVectors()							
	else
		x += Dx
	endif

end sub

sub Robox.ActionMoveLeft( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideWalls( int(x + Dx), int(y), TileX, Map() ) ) then
		x = ( TileX + 1 ) * TILE_SIZE + 1
		State = STATE_IDLE
		NextState = STATE_MOVE_RIGHT
		Idlecounter = MAX_IDLE_COUNTER
		ResolveDirectionVectors()
	else
		x += Dx
	endif
	
end sub

sub Robox.ActionMoveUp( Map() as TileType )

	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy), TileY, Map() ) ) then
		y = ( TileY + 1 ) * TILE_SIZE + 1						
		State = STATE_IDLE
		NextState = STATE_MOVE_DOWN
		Idlecounter = MAX_IDLE_COUNTER
		ResolveDirectionVectors()
	else
		y += Dy
	endif
	
end sub

sub Robox.ActionMoveDown( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - Hei - 1						
		State = STATE_IDLE
		NextState = STATE_MOVE_UP
		Idlecounter = MAX_IDLE_COUNTER
		ResolveDirectionVectors()
	else
		y += Dy
	endif

end sub

	
sub Robox.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Idlecounter = MAX_IDLE_COUNTER + (rnd * MAX_IDLE_COUNTER * 4)
	Orientation = iOrientation
	State = STATE_IDLE
	FlipMode = GL2D.FLIP_NONE
	
	if( Orientation = HORIZONTAL ) then
		NextState = STATE_MOVE_LEFT
	else
		NextState = STATE_MOVE_UP
	endif
	
	Speed = 1.8
	
	BlinkCounter = -1
	Hp = 100

	x = ix
	y = iy
	
	Dx = 0
	Dy = 0
	
	Frame = 2
	BaseFrame = 49
	NumFrames = 1
	
	Wid = 22
	Hei	= 22
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Sub


sub Robox.Update( byref Snipe as Player,  Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 12  ) then return
	
	Counter + = 1

	'if( (Counter and 3) = 0 ) then
	'	Frame = ( Frame + 1 ) mod NumFrames
	'endif	
	
	if( BlinkCounter > 0 ) then
		BlinkCounter -= 1
	endif
	
	select case State
		case STATE_IDLE:
			ActionIdle( Map() )
		case STATE_MOVE_RIGHT:
			Frame = 6
			ActionMoveRight( Map() )
		case STATE_MOVE_LEFT:
			Frame = 5
			ActionMoveLeft( Map() )
		case STATE_MOVE_UP:
			Frame = 3
			ActionMoveUp( Map() )
		case STATE_MOVE_DOWN:
			Frame = 4
			ActionMoveDown( Map() )
		case else
	end select	
	
	BoxNormal.Init( x, y, wid, Hei)
	 
			
end sub

sub Robox.ResolveDirectionVectors()

	select case State
		case STATE_IDLE:
			Dx = 0
			Dy = 0
		case STATE_MOVE_RIGHT:
			Dx = Speed
			Dy = 0
		case STATE_MOVE_LEFT:
			Dx = -Speed
			Dy = 0
		case STATE_MOVE_UP:
			Dx = 0
			Dy = -Speed
		case STATE_MOVE_DOWN:
			Dx = 0
			Dy = Speed
		case else
	end select	

end sub


sub Robox.Explode()
	
	Explosion.SpawnMulti( Vector3D(x + Wid\2, y + Hei\2, 2), 2, rnd * 360, Explosion.MEDIUM_YELLOW_02, Explosion.TINY_YELLOW_02, 4 )	
	
	Kill()
	
End Sub

sub Robox.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub Robox.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	if( (BlinkCounter > 0)  and ((BlinkCounter and 3) = 0) ) then
		GL2D.EnableSpriteStencil( TRUE, GL2D_RGBA(255,255,255,255), GL2D_RGBA(255,255,255,255) )
		GL2D.Sprite3D( x - 2, y - 2, -4, FlipMode, SpriteSet( BaseFrame + Frame ) )
		GL2D.EnableSpriteStencil( FALSE )
	else
		GL2D.Sprite3D( x - 2, y - 2, -4, FlipMode, SpriteSet( BaseFrame + Frame ) )
	endif
	
End Sub

sub Robox.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


sub Robox.CollideWithPlayer( byref Snipe as Player )
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxNormal.Intersects(Box) ) then
			Snipe.HitAnimation( x, 65 )
		endif		
	endif
	
	dim as integer AttackEnergy = 0
	
	AttackEnergy = Snipe.CollideShots( BoxNormal )
	if( AttackEnergy ) then
		Hp -= 19
		BlinkCounter = MAX_ENEMY_BLINK_COUNTER
		if( Hp <= 0 ) then
			Explode()
			Snipe.AddToScore( 401 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 401 )
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 401 )
	endif
	
	AttackEnergy = Snipe.CollideMines( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 401 )
	endif
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Robox.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function Robox.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function Robox.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' RoboxFactory
''
''*****************************************************************************

constructor RoboxFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Roboxs)
		Roboxs(i).Kill()
	Next
	
End Constructor

destructor RoboxFactory()

End Destructor

property RoboxFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property RoboxFactory.GetMaxEntities() as integer
	property = ubound(Roboxs)
end property 

sub RoboxFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Roboxs)
		if( Roboxs(i).IsActive ) then
			Roboxs(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub RoboxFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Roboxs)
		if( Roboxs(i).IsActive ) then
			Roboxs(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub RoboxFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Roboxs)
		if( Roboxs(i).IsActive ) then
			Roboxs(i).DrawAABB()
		EndIf
	Next
	
end sub

sub RoboxFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Roboxs)
		if( Roboxs(i).IsActive ) then
			Roboxs(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub RoboxFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(Roboxs)
		
		if( Roboxs(i).IsActive ) then
			Roboxs(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub RoboxFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(Roboxs)
		if( Roboxs(i).IsActive = FALSE ) then
			Roboxs(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function RoboxFactory.GetAABB( byval i as integer ) as AABB
	
	return Roboxs(i).GetBox
	
End Function
	