''*****************************************************************************
''
''
''	Pyromax Dax PlatformV Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "PlatformV.bi"

constructor PlatformV()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	
	TravelDistance = 16
	SpawnY = 0
	
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

destructor PlatformV()

End Destructor


property PlatformV.IsActive() as integer
	property = Active
End Property
		
property PlatformV.GetX() as single
	property = x
End Property

property PlatformV.GetY() as single
	property = y
End Property

property PlatformV.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property PlatformV.GetBox() as AABB
	property = BoxNormal
End Property
	
sub PlatformV.Spawn( byval ix as integer, byval iy as integer, byval direction as single, byval Distance as integer = 16 )
	
	Active = TRUE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	
	x = ix
	y = iy
	
	TravelDistance = Distance
	SpawnY = y
	
	Dx = 0
	Dy = Direction
	
	Frame = 0
	BaseFrame = 13
	NumFrames = 1
	
	Wid = 63
	Hei	= 31
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Sub


sub PlatformV.Update( byval CameraX as integer, Map() as TileType )
	
	if( (abs((x + wid\2) - (CameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) >= 14  ) then return
	
	Counter += 1
	
	if( abs(y-SpawnY) > ((TravelDistance*TILE_SIZE)) ) then
		Dy = -Dy
	endif
	
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	CollideOnMap( Map() )
	
	BoxNormal.Init( x, y, wid, Hei )
	 
			
End Sub



sub PlatformV.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub PlatformV.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	GL2D.DrawCube( x, y, 0, TILE_SIZE, SpriteSet(BaseFrame) )
	GL2D.DrawCube( x+TILE_SIZE, y, 0, TILE_SIZE, SpriteSet(BaseFrame) )
	'BoxNormal.Draw( 4, GL2D_RGB(255,0,255) )
	
End Sub

function PlatformV.ObjectCollideWalls( byref Snipe as Player ) as integer
	
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

function PlatformV.ObjectCollideFloors( byref Snipe as Player ) as integer
	
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


sub PlatformV.CollideWithPlayer( byref Snipe as Player, Map() as TileType )
	

	'' Jumping
	if( Snipe.GetDy < 0 ) then

		if( ObjectCollideFloors( Snipe ) ) then			
			Snipe.SetY = y + Hei + 2
			Snipe.SetDy = 1
		endif

	else  '' Falling or stationary
		
		'' if platform is about to crush snipe on the floor
		if( (Snipe.GetY >= y + Hei-2 ) ) then
			
			if( (Dy > 0) ) then
				dim as AABB Box = Snipe.GetBoxNormal
				if( BoxNormal.intersects(Box) ) then
					Dy = -Dy
					y += Dy
				EndIf	
			EndIf
			
		else
		
			if( ObjectCollideFloors( Snipe ) ) then
				Snipe.SetY = ((y - Snipe.GetHei) - 2) + Dy
				Snipe.SetDy = 1
				Snipe.SetOnPlatform = TRUE
				
				'' Player standing above platform but will colide with tile above
				'' ie. Player is on the tip of the platform
				if( Dy < 0 ) then
					dim as integer xx = Snipe.GetX+1 
					for i as integer = 0 to 1
						if( Map(xx\TILE_SIZE, (Snipe.GetY+1)\TILE_SIZE).Collision >= TILE_SOLID ) then
							Dy = -Dy
						endif
						xx += Snipe.GetWid-2
					next i
				endif
			endif	
		endif
	endif

	
	if( Snipe.GetDx > 0 ) then

		if( ObjectCollideWalls( Snipe ) ) then				'' Collide to left side of platform
			Snipe.SetX = ((x - Snipe.GetWid) - 1)
			Snipe.SetDx = 0
			Snipe.SetSpeed = 1
			Snipe.SetOnSideOfPlatform = TRUE
		endif	
	
	elseif( Snipe.GetDx < 0 ) then
		
		if( ObjectCollideWalls( Snipe ) ) then
			Snipe.SetX = (x + Wid + 1)
			Snipe.SetDx = 0
			Snipe.SetSpeed = 1
			Snipe.SetOnSideOfPlatform = TRUE
		endif

	endif

	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function PlatformV.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function PlatformV.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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
function PlatformV.CollideOnMap( Map() as TileType ) as integer
	
	dim as Integer TileX, TileY
	dim as integer CollisionType = COLLIDE_NONE    '' Return value. Assume no collision
	
	if( Dy < 0 ) then   	'' moving Up
		
		if( CollideFloors( int(x), int(y + Dy - TILE_SIZE), TileY, Map() ) ) then   		'' hit the roof
			y = ( TileY + 2 ) * TILE_SIZE + 1						'' Snap below the tile
			Dy = -Dy  
			CollisionType = COLLIDE_FLOOR
		else
			y += Dy													'' No collision so move
		EndIf
			
	else	'' Stationary or moving down
		
		if( CollideFloors( int(x), int(y + Dy + Hei + TILE_SIZE), TileY, Map() ) ) then	'' (y + Dy + hei) = Foot of player
			y = ( TileY - 1 ) * TILE_SIZE - Hei - 1						'' Snap above the tile
			Dy = -Dy													'' Set to 1 so that we always collide with floor next frame
			CollisionType = COLLIDE_FLOOR
		else
			y += Dy													'' No collision so move
		EndIf
		
	EndIf
		
	return CollisionType
	
End function


function PlatformV.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function
	
	


''*****************************************************************************
''
'' PlatformVFactory
''
''*****************************************************************************

constructor PlatformVFactory()

End Constructor

destructor PlatformVFactory()

End Destructor

property PlatformVFactory.GetActiveEntities() as Integer
	property = ActiveEntities
end property 

property PlatformVFactory.GetMaxEntities() as integer
	property = ubound(PlatformVs)
end property 

sub PlatformVFactory.UpdateEntities( byval CameraX as integer, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(PlatformVs)
		if( PlatformVs(i).IsActive ) then
			PlatformVs(i).Update( CameraX, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub PlatformVFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	glPushMatrix()					'' Just to be safe since we are scaling below
	glScalef( 1.0, 1.0, 2.0 )
	
	for i as integer = 0 to ubound(PlatformVs)
		if( PlatformVs(i).IsActive ) then
			PlatformVs(i).Draw( SpriteSet() )
		EndIf
	Next
	
	glPopMatrix()
	
end sub

sub PlatformVFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(PlatformVs)
		if( PlatformVs(i).IsActive ) then
			PlatformVs(i).Kill()
		EndIf
	Next
	
	ActiveEntities = 0
	
end sub

sub PlatformVFactory.HandleCollisions( byref Snipe as Player, Map() as TileType )
	
	
	for i as integer = 0 to ubound(PlatformVs)
		
		if( PlatformVs(i).IsActive ) then
			PlatformVs(i).CollideWithPlayer( Snipe, Map() )
		endif
		
	Next i
	
end sub

sub PlatformVFactory.Spawn( byval ix as integer, byval iy as integer, byval direction as single, byval Distance as integer = 16 )

	
	for i as integer = 0 to ubound(PlatformVs)
		if( PlatformVs(i).IsActive = FALSE ) then
			PlatformVs(i).Spawn( ix, iy, direction, Distance )
			exit for
		EndIf
	Next
	
end sub

function PlatformVFactory.GetAABB( byval i as integer ) as AABB
	
	return PlatformVs(i).GetBox
	
End Function
	