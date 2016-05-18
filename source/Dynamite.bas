''*****************************************************************************
''
''
''	Pyromax Dax Dynamite Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************


#include once "Dynamite.bi"

constructor Dynamite()

	Active = FALSE
	Counter = 0 
	CountActive = 60 * 4
	FlipMode = GL2D.FLIP_NONE
	
	x = 0
	y = 0
	Dx = 0
	Dy = 0
	Speed = 0
	
	Frame = 0
	BaseFrame = 4
	NumFrames = 4
	
	Wid = 16
	Hei	= 16

	EnergyUse = 24
	BoxNormal.Init( -1000, -1000, wid, Hei)
	
End Constructor

destructor Dynamite()

End Destructor


property Dynamite.IsActive() as integer
	property = Active
End Property
		
property Dynamite.GetX() as single
	property = x
End Property

property Dynamite.GetY() as single
	property = y
End Property

property Dynamite.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Dynamite.GetEnergyUse() as integer
	property = EnergyUse
End Property
		
	
sub Dynamite.Spawn( byval ix as integer, byval iy as integer, byval direction as integer )
	
	Active = TRUE
	Counter = 0 
	CountActive = 60 * 4
	FlipMode = GL2D.FLIP_NONE
	
	x = ix
	y = iy
	Dx = 0
	Dy = 0
	Speed = 0
		
	Frame = 0
	BaseFrame = 4
	NumFrames = 4
	
	Wid = 16
	Hei	= 16

	Sound.PlaySFX( Sound.SFX_DYNAMITE_LAUNCH )
	
	BoxNormal.Init( x, y, wid, Hei)
	    	
End Sub


sub Dynamite.Update(  Map() as TileType )
	
	Counter += 1
	
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
		dim as single rndy = rnd
		Explosion.Spawn( Vector3D(x + Wid\2, y + Hei, 2), Vector3D(rndy, rndy, 0), Explosion.SMOKE_02 )
		Explosion.Spawn( Vector3D(x + Wid\2, y + Hei, 2), Vector3D(-rndy, rndy, 0), Explosion.SMOKE_02 )
	endif	
	
	dim as integer iTileY
	dim as integer HitCeiling = FALSE
	if( CollideFloors( int(x), int(y + Dy), iTileY, Map() ) ) then	
		y = ( iTileY + 1 ) * TILE_SIZE + 1						
		HitCeiling = TRUE													
	else
		Speed += ACCEL/4
		Speed -= (Speed * FRICTION/8)  		
		Dy = -Speed
		y += Dy													
	EndIf
	
	BoxNormal.Init( x, y, wid, Hei)
	
	dim as integer TileX = x \ TILE_SIZE
	dim as integer TileY = (y + Hei\2) \ TILE_SIZE
	
	dim as integer Tx = TileX
	dim as integer Ty = TileY - 1
	
	if( Ty < 0 ) then 
		Kill()
		return
	EndIf
	
	if( HitCeiling ) then
		
		if( Map(Tx,Ty).Collision >= TILE_SOFT_BRICK ) then
			Map(Tx,Ty).Index = TILE_NONE
			Map(Tx,Ty).Collision = TILE_NONE
			Explosion.Spawn( Vector3D(Tx * TILE_SIZE + 16, Ty * TILE_SIZE + 16, 2), Vector3D(0, 0, 0), Explosion.MEDIUM_BLUE_01 )
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


sub Dynamite.Explode()
	
	Explosion.Spawn( Vector3D(x + Wid\2, y + Hei\2, 2), Vector3D(0, 0, 0), Explosion.BIG_YELLOW )
	Kill()
	Sound.PlaySFX( Sound.SFX_EXPLODE )
	
End Sub


sub Dynamite.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -1000, -1000, wid, Hei)
	
End Sub

sub Dynamite.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	GL2D.Sprite3D( x, y, 2, Flipmode, SpriteSet(BaseFrame + Frame))
	
End Sub

sub Dynamite.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 0,255,255 ) )
	
end sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Dynamite.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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


function Dynamite.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function
	
