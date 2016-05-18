''*****************************************************************************
''
''
''	Pyromax Dax FallingBlock Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "FallingBlock.bi"


const as integer MAX_FALL_COUNTER = 60

constructor FallingBlock()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	State = STATE_FALLING
	FallCounter = MAX_FALL_COUNTER
	IsReadyToFall = FALSE
	
	Speed = 1	
	x = 0
	y = 0
	Dx = 0
	Dy = 0
	

	Frame = 0
	BaseFrame = 13
	NumFrames = 1
	
	Wid = 31
	Hei	= 31
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor FallingBlock()

End Destructor


property FallingBlock.IsActive() as integer
	property = Active
End Property

property FallingBlock.GetID() as integer
	property = ID
End Property
		
property FallingBlock.GetX() as single
	property = x
End Property

property FallingBlock.GetY() as single
	property = y
End Property

property FallingBlock.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property FallingBlock.GetBox() as AABB
	property = BoxNormal
End Property

sub FallingBlock.ActionIdle( Map() as TileType )
	
	dim as integer Tx = x \ TILE_SIZE
	dim as integer Ty = y \ TILE_SIZE
	
	if( IsReadyToFall ) then
		if(FallCounter = MAX_FALL_COUNTER) then Sound.PlaySFX( Sound.SFX_ICE_HIT )
		FallCounter -= 1
		if( FallCounter = 0 ) then
			Map( Tx, Ty ).Collision = TILE_NONE
			State = STATE_FALLING
		else
			Map( Tx, Ty ).Collision = TILE_SOLID
		endif
	else
		Map( Tx, Ty ).Collision = TILE_SOLID
	endif
			
end sub


sub FallingBlock.ActionFalling( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - Hei - 1
		Explode()
	else
		y += Dy												
		Dy += GRAVITY
	endif
		
end sub

	
sub FallingBlock.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	
	State = STATE_IDLE
	FlipMode = GL2D.FLIP_NONE
	
	FallCounter = MAX_FALL_COUNTER
	IsReadyToFall = FALSE
	
	Speed = 0
	
	x = ix
	y = iy
	
	Dx = 0
	Dy = 0
	
	Frame = 0
		BaseFrame = 13
	NumFrames = 1
	
	Wid = 31
	Hei	= 31

	BoxNormal.Init( x, y, Wid, Hei)
	
End Sub


sub FallingBlock.Update( byref Snipe as Player, Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 12  ) then return
	
	Counter += 1
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	select case State
		case STATE_IDLE:
			ActionIdle( Map() )
		case STATE_FALLING:
			ActionFalling( Map() )
	end select	
	
	'if( abs(((Snipe.GetCameraX + SCREEN_WIDTH\2)\TILE_SIZE) - (x \ TILE_SIZE)) > 12   ) then
	'	Kill()
	'endif
	
	BoxNormal.Init( x-1, y, Wid+2, Hei/4)
	 
			
End Sub


sub FallingBlock.Explode()
	
	Explosion.SpawnMulti( Vector3D(x + Wid\2, y + Hei\2, 2), 2, rnd * 360, Explosion.MEDIUM_YELLOW_02, Explosion.MEDIUM_BLUE_01, 8 )
	Sound.PlaySFX( Sound.SFX_EXPLODE )
	
	Kill()
	
End Sub

sub FallingBlock.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub FallingBlock.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	
	if( IsReadyToFall ) then
		dim as single c = 0.5 + abs(sin(Counter*0.15)) * 0.5
		glColor4f( c, 1-c, 1 - c, 1 )
		GL2D.DrawCube( x, y, 0, TILE_SIZE, Spriteset(BaseFrame + Frame) )
		glColor4f( 1, 1, 1, 1 )
	else
		glColor4f( 0, 1, 0, 1 )
		GL2D.DrawCube( x, y, 0, TILE_SIZE, Spriteset(BaseFrame + Frame) )
		glColor4f( 1, 1, 1, 1 )
	endif

	
end sub

sub FallingBlock.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


function FallingBlock.CollideWithPlayer( byref Snipe as Player ) as integer
	
	
	if( (Snipe.GetState <> Player.DIE) ) then	
		dim as AABB Box = Snipe.GetBoxNormal
		if( BoxNormal.Intersects(Box) ) then
			if( Snipe.GetY + Snipe.GetHei <= y ) then
				IsReadyToFall = TRUE
				return TRUE
			endif
		endif		
	endif
	
	return FALSE
	
end function


''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function FallingBlock.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function FallingBlock.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' FallingBlockFactory
''
''*****************************************************************************

constructor FallingBlockFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(FallingBlocks)
		FallingBlocks(i).Kill()
	Next
	
End Constructor

destructor FallingBlockFactory()

End Destructor

property FallingBlockFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property FallingBlockFactory.GetMaxEntities() as integer
	property = ubound(FallingBlocks)
end property 

sub FallingBlockFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(FallingBlocks)
		if( FallingBlocks(i).IsActive ) then
			FallingBlocks(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub FallingBlockFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	glPushMatrix()					'' Just to be safe since we are scaling below
	glScalef( 1.0, 1.0, 2.0 )
	
		for i as integer = 0 to ubound(FallingBlocks)
			if( FallingBlocks(i).IsActive ) then
				FallingBlocks(i).Draw( SpriteSet() )
			EndIf
		Next

	glPopMatrix()
	
end sub

sub FallingBlockFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(FallingBlocks)
		if( FallingBlocks(i).IsActive ) then
			FallingBlocks(i).DrawAABB()
		EndIf
	Next
	
end sub

sub FallingBlockFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(FallingBlocks)
		if( FallingBlocks(i).IsActive ) then
			FallingBlocks(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

function FallingBlockFactory.HandleCollisions( byref Snipe as Player ) as integer
	
	for i as integer = 0 to ubound(FallingBlocks)
		
		if( FallingBlocks(i).IsActive ) then
			if( FallingBlocks(i).CollideWithPlayer( Snipe ) ) then
				return TRUE
			EndIf
		endif
		
	Next i
	
	return FALSE
	
end function

sub FallingBlockFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(FallingBlocks)
		if( FallingBlocks(i).IsActive = FALSE ) then
			FallingBlocks(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function FallingBlockFactory.GetAABB( byval i as integer ) as AABB
	
	return FallingBlocks(i).GetBox
	
End Function

function FallingBlockFactory.GetID( byval i as integer ) as integer
	return FallingBlocks(i).GetID
End Function
			