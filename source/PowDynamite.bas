''*****************************************************************************
''
''
''	Pyromax Dax PowDynamite Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "PowDynamite.bi"


constructor PowDynamite()

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
	BaseFrame = 84
	NumFrames = 4
	
	Wid = 16
	Hei	= 16
	
	BoxNormal.Init( x - Wid\2, y - Hei\2, wid, Hei)
	
End Constructor

destructor PowDynamite()

End Destructor


property PowDynamite.IsActive() as integer
	property = Active
End Property

property PowDynamite.GetID() as integer
	property = ID
End Property
		
property PowDynamite.GetX() as single
	property = x
End Property

property PowDynamite.GetY() as single
	property = y
End Property

property PowDynamite.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property PowDynamite.GetBox() as AABB
	property = BoxNormal
End Property


sub PowDynamite.ActionFalling( Map() as TileType )
	
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

	
sub PowDynamite.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
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
	BaseFrame = 84
	NumFrames = 4
	
	Wid = 16
	Hei	= 16
	
	BoxNormal.Init( x, y, Wid, Hei)
	
End Sub


sub PowDynamite.Update( byref Snipe as Player, Map() as TileType )

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


sub PowDynamite.Explode()
	
	Explosion.Spawn( Vector3D(x + Wid\2, y + Hei\2, 2), Vector3D(0, 0, 0), Explosion.TWINKLE )
	
	Kill()
	
End Sub

sub PowDynamite.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub PowDynamite.Draw( SpriteSet() as GL2D.IMAGE ptr )
	GL2D.SpriteRotateScaleXY3D( x + Wid\2, y + Hei\2, -2, sin(Counter*0.1) * 20, 1 + abs(sin(Counter*0.25)) * 0.7, 1 + abs(sin(Counter*0.25)) * 0.7, FlipMode, SpriteSet( BaseFrame + Frame ) )
End Sub

sub PowDynamite.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


function PowDynamite.CollideWithPlayer( byref Snipe as Player ) as integer
	
	
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
function PowDynamite.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function PowDynamite.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' PowDynamiteFactory
''
''*****************************************************************************

constructor PowDynamiteFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(PowDynamites)
		PowDynamites(i).Kill()
	Next
	
End Constructor

destructor PowDynamiteFactory()

End Destructor

property PowDynamiteFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property PowDynamiteFactory.GetMaxEntities() as integer
	property = ubound(PowDynamites)
end property 

sub PowDynamiteFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(PowDynamites)
		if( PowDynamites(i).IsActive ) then
			PowDynamites(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub PowDynamiteFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(PowDynamites)
		if( PowDynamites(i).IsActive ) then
			PowDynamites(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub PowDynamiteFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(PowDynamites)
		if( PowDynamites(i).IsActive ) then
			PowDynamites(i).DrawAABB()
		EndIf
	Next
	
end sub

sub PowDynamiteFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(PowDynamites)
		if( PowDynamites(i).IsActive ) then
			PowDynamites(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

function PowDynamiteFactory.HandleCollisions( byref Snipe as Player ) as integer
	
	for i as integer = 0 to ubound(PowDynamites)
		
		if( PowDynamites(i).IsActive ) then
			if( PowDynamites(i).CollideWithPlayer( Snipe ) ) then
				return TRUE
			EndIf
		endif
		
	Next i
	
	return FALSE
	
end function

sub PowDynamiteFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(PowDynamites)
		if( PowDynamites(i).IsActive = FALSE ) then
			PowDynamites(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function PowDynamiteFactory.GetAABB( byval i as integer ) as AABB
	
	return PowDynamites(i).GetBox
	
End Function

function PowDynamiteFactory.GetID( byval i as integer ) as integer
	return PowDynamites(i).GetID
End Function
			