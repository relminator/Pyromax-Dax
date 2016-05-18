''*****************************************************************************
''
''
''	Pyromax Dax PlatformH Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "PlatformH.bi"

constructor PlatformH()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	TravelDistance = 32
	SpawnX = 0
	
	x = 0
	y = 0
	Dx = 0
	Dy = 0
	

	Frame = 0
	BaseFrame = 1
	NumFrames = 1
	
	Wid = 63
	Hei	= 31
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor PlatformH()

End Destructor


property PlatformH.IsActive() as integer
	property = Active
End Property
		
property PlatformH.GetX() as single
	property = x
End Property

property PlatformH.GetY() as single
	property = y
End Property

property PlatformH.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property PlatformH.GetBox() as AABB
	property = BoxNormal
End Property
	
sub PlatformH.Spawn( byval ix as integer, byval iy as integer, byval direction as single, byval Distance as integer = 16 )
	
	Active = TRUE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	
	
	x = ix
	y = iy
	
	TravelDistance = Distance
	SpawnX = x
	
	Dx = Direction
	Dy = 0
	
	Frame = 0
	BaseFrame = 13
	NumFrames = 1
	
	Wid = 63
	Hei	= 31
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Sub


sub PlatformH.Update( byval CameraX as integer, Map() as TileType )
	
	if( (abs((x + wid\2) - (CameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) >= 16  ) then return
	
	Counter += 1
	
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	if( abs(x-SpawnX) > ((TravelDistance*TILE_SIZE)) ) then
		Dx = -Dx
	endif
	
	dim as integer OnFloor = CollideOnMap( Map() )
	
	BoxNormal.Init( x, y, wid, Hei)
	 
			
End Sub



sub PlatformH.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub PlatformH.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	GL2D.DrawCube( x, y, 0, TILE_SIZE, SpriteSet(BaseFrame) )
	GL2D.DrawCube( x+TILE_SIZE, y, 0, TILE_SIZE, SpriteSet(BaseFrame) )
	
End Sub

function PlatformH.ObjectCollideWalls( byref Snipe as Player ) as integer
	
	dim as AABB Box = Snipe.GetBoxNormal
	dim as integer TestEnd = Snipe.GetY + Snipe.GetHei
	dim as integer iy = Snipe.GetY
	
	Box.x1 += Snipe.GetDx * 3			'' Offset player box to account for stutters when colliding with
	Box.x2 += Snipe.GetDx * 3			'' moving platforms
	
	'' Multisample our test from head to foot
	while( iy <= TestEnd ) 
		if( iy >= y ) then
			if( iy <= (y + Hei) ) then
				if( BoxNormal.Intersects(Box) ) then		'' if point is within axis and box intersects...
					return TRUE
				endif
			endif
		endif
		iy += Snipe.GetHei
	Wend
	
	return FALSE
				
End Function

function PlatformH.ObjectCollideFloors( byref Snipe as Player ) as integer
	
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


sub PlatformH.CollideWithPlayer( byref Snipe as Player )
	
	
	if( Snipe.GetDx > 0 ) then

		if( ObjectCollideWalls( Snipe ) ) then				'' Let platform push player even when walking
			Snipe.SetX = (x - Snipe.GetWid) - 1
			Snipe.SetDx = 0
			Snipe.SetSpeed = 1
			Snipe.SetOnSideOfPlatform = TRUE
		endif	
	
	elseif( Snipe.GetDx < 0 ) then
		
		if( ObjectCollideWalls( Snipe ) ) then
			Snipe.SetX = x + Wid + 1
			Snipe.SetDx = 0
			Snipe.SetSpeed = 1
			Snipe.SetOnSideOfPlatform = TRUE
		endif
		
	else
		
		'' Let platform push snipe when not walking too
		dim as AABB Box = Snipe.GetBoxNormal
		if( BoxNormal.Intersects(Box) ) then
			if( (Snipe.GetY + Snipe.GetHei) >= y  ) then
				if( Snipe.GetX < x + Wid/2 ) then
					Snipe.SetX = (x - Snipe.GetWid) - 1
				else
					Snipe.SetX = x + Wid + 1
				endif
			endif
			Snipe.SetDx = Dx
			Snipe.SetSpeed = 1
			Snipe.SetOnSideOfPlatform = TRUE
		EndIf
		
	endif


	if( Snipe.GetDy < 0 ) then

		if( ObjectCollideFloors( Snipe ) ) then      '' Player jumping and hit bottom of platform
			Snipe.SetY = y + Hei + 1
			Snipe.SetDy = 0
		endif

	else											 '' Player going down

		if( ObjectCollideFloors( Snipe ) ) then		 '' Snap player to top of platform 
			Snipe.SetY = ((y - Snipe.GetHei) - 2)
			Snipe.SetDy = 1
			Snipe.SetOnPlatform = TRUE
			if( (Snipe.GetState <> Player.WALKING) and (Snipe.GetState <> Player.BREAKING) ) then   '' Account for speed  
				Snipe.SetOnSideOfPlatform = FALSE													'' of Platform when snipe
				Snipe.SetX = Snipe.GetX + Dx														'' is riding above it
				Snipe.SetDx = Snipe.GetDx + Dx
			endif
				
		endif	

	endif
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function PlatformH.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function PlatformH.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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

''*************************************
'' Checks player collisions on the map
''*************************************
function PlatformH.CollideOnMap( Map() as TileType ) as integer
	
	dim as Integer TileX, TileY
	dim as integer CollisionType = COLLIDE_NONE    '' Return value. Assume no collision
	
	if( Dx < 0 ) then   	'' moving left
		
		if( CollideWalls( int(x + Dx - TILE_SIZE), int(y), TileX, Map() ) ) then   		'' hit right
			x = ( TileX + 2 ) * TILE_SIZE + 1						'' Snap right tile
			Dx = -Dx  
			CollisionType = COLLIDE_RIGHT
		else
			x += Dx													'' No collision so move
		EndIf
			
	elseif( Dx > 0 ) then
		
		if( CollideWalls( int(x + Dx + Wid + TILE_SIZE), int(y), TileX, Map() ) ) then
			x = ( TileX - 1 ) * TILE_SIZE - Wid - 1						
			Dx = -Dx													
			CollisionType = COLLIDE_LEFT
		else
			x += Dx													'' No collision so move
		EndIf
	
	EndIf
		
	return CollisionType
	
End function


function PlatformH.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function
	
	


''*****************************************************************************
''
'' PlatformHFactory
''
''*****************************************************************************

constructor PlatformHFactory()

End Constructor

destructor PlatformHFactory()

End Destructor

property PlatformHFactory.GetActiveEntities() as Integer
	property = ActiveEntities
end property 

property PlatformHFactory.GetMaxEntities() as integer
	property = ubound(PlatformHs)
end property 

sub PlatformHFactory.UpdateEntities( byval CameraX as integer, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(PlatformHs)
		if( PlatformHs(i).IsActive ) then
			PlatformHs(i).Update( CameraX, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub PlatformHFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	glPushMatrix()					'' Just to be safe since we are scaling below
	glScalef( 1.0, 1.0, 2.0 )
	
	for i as integer = 0 to ubound(PlatformHs)
		if( PlatformHs(i).IsActive ) then
			PlatformHs(i).Draw( SpriteSet() )
		EndIf
	Next
	
	glPopMatrix()
	
end sub

sub PlatformHFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(PlatformHs)
		if( PlatformHs(i).IsActive ) then
			PlatformHs(i).Kill()
		EndIf
	Next
	
	ActiveEntities = 0
	
end sub

sub PlatformHFactory.HandleCollisions( byref Snipe as Player )
	
	
	for i as integer = 0 to ubound(PlatformHs)
		
		if( PlatformHs(i).IsActive ) then
			PlatformHs(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
end sub

sub PlatformHFactory.Spawn( byval ix as integer, byval iy as integer, byval direction as single, byval Distance as integer = 16 )

	
	for i as integer = 0 to ubound(PlatformHs)
		if( PlatformHs(i).IsActive = FALSE ) then
			PlatformHs(i).Spawn( ix, iy, direction, Distance )
			exit for
		EndIf
	Next
	
end sub

function PlatformHFactory.GetAABB( byval i as integer ) as AABB
	
	return PlatformHs(i).GetBox
	
End Function
	