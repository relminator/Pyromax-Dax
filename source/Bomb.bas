''*****************************************************************************
''
''
''	Pyromax Dax Bomb Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************


#include once "Bomb.bi"

constructor Bomb()

	Active = FALSE
	Counter = 0 
	CountActive = 60 * 4
	FlipMode = GL2D.FLIP_NONE
	
	x = 0
	y = 0
	Dx = 0
	Dy = 0
	

	Frame = 0
	BaseFrame = 0
	NumFrames = 4
	
	Wid = 16
	Hei	= 16

	EnergyUse = 16

	BoxNormal.Init( x, y, wid, Hei )
		
End Constructor

destructor Bomb()

End Destructor

property Bomb.SetX( byval v as single )
	x = v
End Property

property Bomb.SetY( byval v as single )
	y = v
End Property

property Bomb.SetDX( byval v as single )
	Dx = v
End Property

property Bomb.SetDY( byval v as single )
	Dy = v
End Property


property Bomb.IsActive() as integer
	property = Active
End Property
		
property Bomb.GetX() as single
	property = x
End Property

property Bomb.GetY() as single
	property = y
End Property

property Bomb.GetDX() as Single
	Property = Dx
End Property 

property Bomb.GetDY() as Single
	Property = Dy
End Property

property Bomb.GetWid() as Single
	Property = Wid
End Property 

property Bomb.GetHei() as Single
	Property = Hei
End Property

property Bomb.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Bomb.GetEnergyUse() as integer
	property = EnergyUse
End Property
			
	
sub Bomb.Spawn( byval ix as integer, byval iy as integer, byval direction as integer )
	
	Active = TRUE
	Counter = 0 
	CountActive = 60 * 4
	if( direction > 0 ) then
		FlipMode = GL2D.FLIP_H
	else
		FlipMode = GL2D.FLIP_NONE
	endif
	
	x = ix
	y = iy
	Dx = 0
	Dy = 1
	
	Frame = 0
	BaseFrame = 0
	NumFrames = 4
	
	Wid = 16
	Hei	= 16

	'Sound.PlaySFX( Sound.SFX_BOUNCE )
	BoxNormal.Init( x, y, wid, Hei )
			
End Sub


sub Bomb.Update(  Map() as TileType )
	
	Counter + = 1
	
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	dim as integer iTileY
	dim as integer OnFloor = FALSE
	if( CollideFloors( int(x), int(y + Dy + Hei), iTileY, Map() ) ) then	
		y = ( iTileY ) * TILE_SIZE - Hei - 1						
		Dy = 1
		OnFloor = TRUE													
	else
		y += Dy													
		Dy += GRAVITY
	EndIf
	
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
			if( OnFloor ) then
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
			endif
		EndIf
		
		Explode()
		
	EndIf
	
	
	
End Sub


sub Bomb.Explode()
	
	Explosion.Spawn( Vector3D(x + Wid\2, y + Hei\2 - 16, 2), Vector3D(0, 0, 0), Explosion.ATOMIC )
	Kill()
	Sound.PlaySFX( Sound.SFX_EXPLODE )
	
End Sub


sub Bomb.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -1000, -1000, wid, Hei)
	
End Sub

sub Bomb.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	GL2D.Sprite3D( x, y, 2, Flipmode, SpriteSet(BaseFrame + Frame))
	
End Sub

sub Bomb.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 0,255,255 ) )
	
end sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Bomb.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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

function Bomb.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function
