''*****************************************************************************
''
''
''	Pyromax Dax PowMine Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "PowMine.bi"


constructor PowMine()

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
	BaseFrame = 88
	NumFrames = 4
	
	Wid = 16
	Hei	= 16
	
	BoxNormal.Init( x - Wid\2, y - Hei\2, wid, Hei)
	
End Constructor

destructor PowMine()

End Destructor


property PowMine.IsActive() as integer
	property = Active
End Property

property PowMine.GetID() as integer
	property = ID
End Property
		
property PowMine.GetX() as single
	property = x
End Property

property PowMine.GetY() as single
	property = y
End Property

property PowMine.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property PowMine.GetBox() as AABB
	property = BoxNormal
End Property


sub PowMine.ActionFalling( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - Hei - 1
		if( Orientation = ORIENTATION_LEFT ) then						
			Dy = -JUMPHEIGHT/2
			Dx = 0
		else
			Dy = -JUMPHEIGHT/2
			Dx = 0
		endif
	else
		y += Dy												
		Dy += GRAVITY
	endif
	
		
end sub

	
sub PowMine.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Orientation = iOrientation
	State = STATE_FALLING
	if( Orientation = ORIENTATION_LEFT ) then
		FlipMode = GL2D.FLIP_NONE
	else
		FlipMode = GL2D.FLIP_H
	endif
	
	Speed = 0
	
	x = ix
	y = iy
	
	Dx = 0
	Dy = 1
	
	Frame = 0
	BaseFrame = 88
	NumFrames = 4
	
	Wid = 16
	Hei	= 16
	
	BoxNormal.Init( x, y, Wid, Hei)
	
End Sub


sub PowMine.Update( byref Snipe as Player, Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 12  ) then return
	
	Counter + = 1
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	select case State
		case STATE_FALLING:
			ActionFalling( Map() )
		case else
	end select	
	

	BoxNormal.Init( x, y, Wid, Hei)
	 
			
End Sub


sub PowMine.Explode()
	
	Explosion.Spawn( Vector3D(x + Wid\2, y + Hei\2, 2), Vector3D(0, 0, 0), Explosion.TWINKLE )
	
	Kill()
	
End Sub

sub PowMine.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub PowMine.Draw( SpriteSet() as GL2D.IMAGE ptr )
	GL2D.SpriteRotateScaleXY3D( x + Wid\2, y + Hei\2, -2, sin(Counter*0.1) * 20, 1 + abs(sin(Counter*0.25)) * 0.7, 1 + abs(sin(Counter*0.25)) * 0.7, FlipMode, SpriteSet( BaseFrame + Frame ) )
End Sub

sub PowMine.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


function PowMine.CollideWithPlayer( byref Snipe as Player ) as integer
	
	
	if( (Snipe.GetState <> Player.DIE) ) then	
		dim as AABB Box = Snipe.GetBoxNormal
		if( BoxNormal.Intersects(Box) ) then
			Explode()
			Snipe.AddToScore( 501 )
			Sound.PlaySFX( Sound.SFX_POWER_UP)
			return TRUE
		endif		
	endif
	
	return FALSE
	
end function


''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function PowMine.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function PowMine.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' PowMineFactory
''
''*****************************************************************************

constructor PowMineFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(PowMines)
		PowMines(i).Kill()
	Next
	
End Constructor

destructor PowMineFactory()

End Destructor

property PowMineFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property PowMineFactory.GetMaxEntities() as integer
	property = ubound(PowMines)
end property 

sub PowMineFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(PowMines)
		if( PowMines(i).IsActive ) then
			PowMines(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub PowMineFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(PowMines)
		if( PowMines(i).IsActive ) then
			PowMines(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub PowMineFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(PowMines)
		if( PowMines(i).IsActive ) then
			PowMines(i).DrawAABB()
		EndIf
	Next
	
end sub

sub PowMineFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(PowMines)
		if( PowMines(i).IsActive ) then
			PowMines(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

function PowMineFactory.HandleCollisions( byref Snipe as Player ) as integer
	
	for i as integer = 0 to ubound(PowMines)
		
		if( PowMines(i).IsActive ) then
			if( PowMines(i).CollideWithPlayer( Snipe ) ) then
				return TRUE
			EndIf
		endif
		
	Next i
	
	return FALSE
	
end function

sub PowMineFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(PowMines)
		if( PowMines(i).IsActive = FALSE ) then
			PowMines(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function PowMineFactory.GetAABB( byval i as integer ) as AABB
	
	return PowMines(i).GetBox
	
End Function

function PowMineFactory.GetID( byval i as integer ) as integer
	return PowMines(i).GetID
End Function
			