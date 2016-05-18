''*****************************************************************************
''
''
''	Pyromax Dax Mine Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************


#include once "Mine.bi"

constructor Mine()

	Active = FALSE
	Counter = 0 
	CountActive = 60 * 4
	FlipMode = GL2D.FLIP_NONE
	
	x = 0
	y = 0
	Dx = 0
	Dy = 0
	

	Frame = 0
	BaseFrame = 8
	NumFrames = 4
	
	Wid = 16
	Hei	= 16
	
	EnergyUse = 20
	
	BoxNormal.Init( x, y, wid, Hei )
	
End Constructor

destructor Mine()

End Destructor

property Mine.SetX( byval v as single )
	x = v
End Property

property Mine.SetY( byval v as single )
	y = v
End Property

property Mine.SetDX( byval v as single )
	Dx = v
End Property

property Mine.SetDY( byval v as single )
	Dy = v
End Property

property Mine.IsActive() as integer
	property = Active
End Property
		
property Mine.GetX() as single
	property = x
End Property

property Mine.GetY() as single
	property = y
End Property

property Mine.GetDX() as Single
	Property = Dx
End Property 

property Mine.GetDY() as Single
	Property = Dy
End Property

property Mine.GetWid() as Single
	Property = Wid
End Property 

property Mine.GetHei() as Single
	Property = Hei
End Property

property Mine.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Mine.GetEnergyUse() as integer
	property = EnergyUse
End Property
		
	
sub Mine.Spawn( byval ix as integer, byval iy as integer, byval direction as integer )
	
	Active = TRUE
	Counter = 0 
	CountActive = 60 * 4
	FlipMode = GL2D.FLIP_NONE
	if( direction > 0 ) then
		Dx = -3
	else
		Dx = 3
	endif
	
	x = ix
	y = iy
	Dy = 1
	
	Frame = 0
	BaseFrame = 8
	NumFrames = 4
	
	Wid = 16
	Hei	= 16

	BoxNormal.Init( x, y, wid, Hei )
	
End Sub


sub Mine.Update(  Map() as TileType )
	
	Counter + = 1
	
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	dim as integer iTileY
	
	dim as integer OnFloor = CollideOnMap( Map() )
	
	BoxNormal.Init( x, y, wid, Hei)
	 
	dim as integer TileX = x \ TILE_SIZE
	dim as integer TileY = (y + Hei\2) \ TILE_SIZE
	
	dim as integer Tx = TileX
	dim as integer Ty = TileY + 1
	
	if( Counter >= CountActive ) then
		
		if( Map(Tx,Ty).Collision >= TILE_SOFT_BRICK ) then
			Map(Tx,Ty).Index = TILE_NONE
			Map(Tx,Ty).Collision = TILE_NONE
			Explosion.Spawn( Vector3D(Tx * TILE_SIZE + 16, Ty * TILE_SIZE + 16, 2), Vector3D(0, 0, 0), Explosion.MEDIUM_YELLOW_02 )
		elseif( Map(Tx,Ty).Collision < TILE_SOLID ) then
			if( Map(Tx + 1,Ty).Collision >= TILE_SOFT_BRICK ) then
				Tx += 1
				Map(Tx,Ty).Index = TILE_NONE
				Map(Tx,Ty).Collision = TILE_NONE
				Explosion.Spawn( Vector3D(Tx * TILE_SIZE + 16, Ty * TILE_SIZE + 16, 2), Vector3D(0, 0, 0), Explosion.MEDIUM_YELLOW_02 )
			elseif( Map(Tx - 1,Ty).Collision >= TILE_SOFT_BRICK ) then
				Tx -= 1
				Map(Tx,Ty).Index = TILE_NONE
				Map(Tx,Ty).Collision = TILE_NONE
				Explosion.Spawn( Vector3D(Tx * TILE_SIZE + 16, Ty * TILE_SIZE + 16, 2), Vector3D(0, 0, 0), Explosion.MEDIUM_YELLOW_02 )		
			endif
		EndIf
	
		Explode()
	
	EndIf
			
End Sub


sub Mine.Explode()
	
	Explosion.Spawn( Vector3D(x + Wid\2, y + Hei\2, 2), Vector3D(0, 0, 0), Explosion.MEDIUM_BLUE_02 )
	Kill()
	Sound.PlaySFX( Sound.SFX_EXPLODE )
	
End Sub


sub Mine.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -1000, -1000, wid, Hei)
	
End Sub

sub Mine.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	GL2D.Sprite3D( x, y, 2, Flipmode, SpriteSet(BaseFrame + Frame))
	
End Sub

sub Mine.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 0,255,255 ) )
	
end sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Mine.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function Mine.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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
function Mine.CollideOnMap( Map() as TileType ) as integer
	
	dim as Integer TileX, TileY
	dim as integer CollisionType = COLLIDE_NONE    '' Return value. Assume no collision
	
	if( Dx > 0 ) then 		'' Right movement
		
		if( CollideWalls( int(x + Dx + Wid), int(y), TileX, Map() ) ) then    '' (x + Dx + wid) = Right side of player
			x = TileX * TILE_SIZE - Wid - 1							'' Snap left when there's a collision
			CollisionType = COLLIDE_RIGHT
			Dx = -Dx
		else
			x += Dx													'' No collision, so move
		EndIf
	
	elseif( Dx < 0 ) then 	'' Left movement																					
		'' FB alert!!! Nega stuff needs an int
		if( CollideWalls( int(x + Dx), int(y), TileX, Map() ) ) then			'' (x + Dx) = Left side of player
			x = ( TileX + 1 ) * TILE_SIZE + 1						'' Snap to right of tile
			CollisionType = COLLIDE_LEFT
			Dx = -Dx
		else
			x += Dx 													'' No collision, so move
		EndIf
		
	EndIf
	
	
	if( Dy >= 0 ) then   	'' Down
		
		if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	'' (y + Dy + hei) = Foot of player
			y = ( TileY ) * TILE_SIZE - Hei - 1						'' Snap above the tile
			Dy = 1													'' Set to 1 so that we always collide with floor next frame
			CollisionType = COLLIDE_FLOOR
		else
			y += Dy													'' No collision so move
			Dy += GRAVITY
		EndIf
		
	EndIf
	
	return CollisionType
	
End function

function Mine.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function
