''*****************************************************************************
''
''
''	Pyromax Dax Plasmo Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Plasmo.bi"

#define MAX_TURN_COUNTER 8

constructor Plasmo()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	Orientation = NORMAL
	TurnCounter = MAX_TURN_COUNTER 
	State = STATE_FALLING
	
	Speed = 1	
	x = 0
	y = 0
	Dx = 0
	Dy = 1
	

	Frame = 0
	BaseFrame = 140
	NumFrames = 13
	
	Wid = 24
	Hei	= 24
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor Plasmo()

End Destructor


property Plasmo.IsActive() as integer
	property = Active
End Property
		
property Plasmo.GetX() as single
	property = x
End Property

property Plasmo.GetY() as single
	property = y
End Property

property Plasmo.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Plasmo.GetBox() as AABB
	property = BoxNormal
End Property

''*****************************************************************************
''
''*****************************************************************************
sub Plasmo.ActionFalling( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - Hei - 1
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
	else
		y += Dy												
		Dy += GRAVITY
	endif
	
	Rotation = 0
		
end sub

sub Plasmo.ActionMoveRightNormal( Map() as TileType )
	
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
			'CheckDiagonalTiles( -TILE_SIZE\2, -TILE_SIZE\2, Map() )   '' Check for adjacent tiles so we fall down when the tile is destroyed
			TurnCounter = MAX_TURN_COUNTER
		endif
	endif

	Rotation = 180
end sub

sub Plasmo.ActionMoveLeftNormal( Map() as TileType )
	
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
	
	Rotation = 0
		
end sub

sub Plasmo.ActionMoveUpNormal( Map() as TileType )

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
	
	Rotation = 90
	
end sub

sub Plasmo.ActionMoveDownNormal( Map() as TileType )
	
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
	
	Rotation = 270
	
end sub

''*****************************************************************************
''
''*****************************************************************************
sub Plasmo.ActionMoveRightReverse( Map() as TileType )
	
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

	Rotation = 0
end sub

sub Plasmo.ActionMoveLeftReverse( Map() as TileType )
	
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
	
	Rotation = 180
		
end sub

sub Plasmo.ActionMoveUpReverse( Map() as TileType )

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
	
	Rotation = 270
	
end sub

sub Plasmo.ActionMoveDownReverse( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		''y = ( TileY ) * TILE_SIZE - Hei						
		Dy = 0
		Dx = Speed
		State = STATE_MOVE_RIGHT
		TurnCounter = MAX_TURN_COUNTER
	else
		y += Dy
		if( not CollideWalls( int(x - Speed - Wid), int(y), TileX, Map() ) ) then
			Dx = -Speed
			Dy = 0
			State = STATE_MOVE_LEFT
			TurnCounter = MAX_TURN_COUNTER
		endif												
	endif
	
	Rotation = 90
	
end sub

	
sub Plasmo.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Rotation = 0
	TurnCounter = MAX_TURN_COUNTER
	Orientation = iOrientation
	State = STATE_FALLING
	if( Orientation = NORMAL ) then
		FlipMode = GL2D.FLIP_NONE
	else
		FlipMode = GL2D.FLIP_H
	EndIf
	
	Speed = 2.5
	
	x = ix
	y = iy
	
	Dx = 0
	Dy = 1
	
	Frame = 0
	BaseFrame = 140
	NumFrames = 13
	
	Wid = 24
	Hei	= 24
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Sub


sub Plasmo.Update( byref Snipe as Player,  Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 20  ) then return
	
	
	Counter + = 1
	TurnCounter -= 1
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	if( Orientation = NORMAL ) then
		select case State
			case STATE_FALLING:
				ActionFalling( Map() )
			case STATE_MOVE_RIGHT:
				ActionMoveRightNormal( Map() )
			case STATE_MOVE_LEFT:
				ActionMoveLeftNormal( Map() )
			case STATE_MOVE_UP:
				ActionMoveUpNormal( Map() )
			case STATE_MOVE_DOWN:
				ActionMoveDownNormal( Map() )
			case else
		end select	
		
	else
			select case State
			case STATE_FALLING:
				ActionFalling( Map() )
			case STATE_MOVE_RIGHT:
				ActionMoveRightReverse( Map() )
			case STATE_MOVE_LEFT:
				ActionMoveLeftReverse( Map() )
			case STATE_MOVE_UP:
				ActionMoveUpReverse( Map() )
			case STATE_MOVE_DOWN:
				ActionMoveDownReverse( Map() )
			case else
		end select	
	
	endif
	

	BoxNormal.Init( x, y, wid, Hei)
	 
			
End Sub


sub Plasmo.Explode()
	
	Explosion.Spawn( Vector3D(x + Wid\2, y + Hei\2, 2), Vector3D(0, 0, 0), Explosion.MEDIUM_YELLOW_01 )
	
	Kill()
	
End Sub

sub Plasmo.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub Plasmo.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	GL2D.SpriteRotateScaleXY3D( x + Wid/2,_
							    y + Hei/2,_
							    -4,_
							    Rotation,_
							    1,_
							    1,_
							    FlipMode,_
							    SpriteSet( BaseFrame + Frame ) )
	
End Sub

sub Plasmo.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


sub Plasmo.CollideWithPlayer( byref Snipe as Player )
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxNormal.Intersects(Box) ) then
			Snipe.HitAnimation( x, 65 )
		endif		
	endif
	
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Plasmo.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function Plasmo.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function Plasmo.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function

sub Plasmo.FallDown( )

	if( TurnCounter >= 0 ) then
		Dx = 0
		Dy = 1
		State = STATE_FALLING	
	endif	

end sub

function Plasmo.CheckDiagonalTiles( byval xOffset as integer, byval yOffset as integer, Map() as TileType ) as integer  
	
	
	dim as integer Cx = x + Wid\2
	dim as integer Cy = y + Hei\2

	dim as integer T = MapUtil.GetTile( Cx + xOffset, Cy + yOffset, Map() )   
	
	if( (T = TILE_NONE) or (TurnCounter >= 0) ) then
		Dx = 0
		Dy = 1
		State = STATE_FALLING	
		return TRUE		
	endif	
	
	return FALSE
	
End Function

		


''*****************************************************************************
''
'' PlasmoFactory
''
''*****************************************************************************

constructor PlasmoFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Plasmos)
		Plasmos(i).Kill()
	Next
	
End Constructor

destructor PlasmoFactory()

End Destructor

property PlasmoFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property PlasmoFactory.GetMaxEntities() as integer
	property = ubound(Plasmos)
end property 

sub PlasmoFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Plasmos)
		if( Plasmos(i).IsActive ) then
			Plasmos(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub PlasmoFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Plasmos)
		if( Plasmos(i).IsActive ) then
			Plasmos(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub PlasmoFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Plasmos)
		if( Plasmos(i).IsActive ) then
			Plasmos(i).DrawAABB()
		EndIf
	Next
	
end sub

sub PlasmoFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Plasmos)
		if( Plasmos(i).IsActive ) then
			Plasmos(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub PlasmoFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(Plasmos)
		
		if( Plasmos(i).IsActive ) then
			Plasmos(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub PlasmoFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(Plasmos)
		if( Plasmos(i).IsActive = FALSE ) then
			Plasmos(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function PlasmoFactory.GetAABB( byval i as integer ) as AABB
	
	return Plasmos(i).GetBox
	
End Function
	