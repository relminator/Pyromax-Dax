''*****************************************************************************
''
''
''	Pyromax Dax PowBomb Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "PowBomb.bi"


constructor PowBomb()

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
	BaseFrame = 80
	NumFrames = 4
	
	Wid = 16
	Hei	= 16
	
	BoxNormal.Init( x - Wid\2, y - Hei\2, wid, Hei)
	
End Constructor

destructor PowBomb()

End Destructor


property PowBomb.IsActive() as integer
	property = Active
End Property

property PowBomb.GetID() as integer
	property = ID
End Property
		
property PowBomb.GetX() as single
	property = x
End Property

property PowBomb.GetY() as single
	property = y
End Property

property PowBomb.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property PowBomb.GetBox() as AABB
	property = BoxNormal
End Property


sub PowBomb.ActionFalling( Map() as TileType )
	
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

	
sub PowBomb.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
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
	BaseFrame = 80
	NumFrames = 4
	
	Wid = 16
	Hei	= 16
	
	BoxNormal.Init( x, y, Wid, Hei)
	
End Sub


sub PowBomb.Update( byref Snipe as Player, Map() as TileType )
	
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


sub PowBomb.Explode()
	
	Explosion.Spawn( Vector3D(x + Wid\2, y + Hei\2, 2), Vector3D(0, 0, 0), Explosion.TWINKLE )
	
	Kill()
	
End Sub

sub PowBomb.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub PowBomb.Draw( SpriteSet() as GL2D.IMAGE ptr )
	GL2D.SpriteRotateScaleXY3D( x + Wid\2, y + Hei\2, -2, sin(Counter*0.1) * 20, 1 + abs(sin(Counter*0.25)) * 0.7, 1 + abs(sin(Counter*0.25)) * 0.7, FlipMode, SpriteSet( BaseFrame + Frame ) )
End Sub

sub PowBomb.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


function PowBomb.CollideWithPlayer( byref Snipe as Player ) as integer
	
	
	if( (Snipe.GetState <> Player.DIE) ) then	
		dim as AABB Box = Snipe.GetBoxNormal
		if( BoxNormal.Intersects(Box) ) then
			Explode()
			Sound.PlaySFX( Sound.SFX_POWER_UP)
			Snipe.AddToScore( 501 )
			return TRUE
		endif		
	endif
	
	return FALSE
	
end function


''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function PowBomb.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function PowBomb.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' PowBombFactory
''
''*****************************************************************************

constructor PowBombFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(PowBombs)
		PowBombs(i).Kill()
	Next
	
End Constructor

destructor PowBombFactory()

End Destructor

property PowBombFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property PowBombFactory.GetMaxEntities() as integer
	property = ubound(PowBombs)
end property 

sub PowBombFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(PowBombs)
		if( PowBombs(i).IsActive ) then
			PowBombs(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub PowBombFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(PowBombs)
		if( PowBombs(i).IsActive ) then
			PowBombs(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub PowBombFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(PowBombs)
		if( PowBombs(i).IsActive ) then
			PowBombs(i).DrawAABB()
		EndIf
	Next
	
end sub

sub PowBombFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(PowBombs)
		if( PowBombs(i).IsActive ) then
			PowBombs(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

function PowBombFactory.HandleCollisions( byref Snipe as Player ) as integer
	
	for i as integer = 0 to ubound(PowBombs)
		
		if( PowBombs(i).IsActive ) then
			if( PowBombs(i).CollideWithPlayer( Snipe ) ) then
				return TRUE
			EndIf
		endif
		
	Next i
	
	return FALSE
	
end function

sub PowBombFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(PowBombs)
		if( PowBombs(i).IsActive = FALSE ) then
			PowBombs(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function PowBombFactory.GetAABB( byval i as integer ) as AABB
	
	return PowBombs(i).GetBox
	
End Function

function PowBombFactory.GetID( byval i as integer ) as integer
	return PowBombs(i).GetID
End Function
			