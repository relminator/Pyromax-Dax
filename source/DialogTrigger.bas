''*****************************************************************************
''
''
''	Pyromax Dax Dialogtrigger Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "DialogTrigger.bi"


constructor DialogTrigger()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	Orientation = ORIENTATION_LEFT
	State = STATE_FALLING
	
	Speed = 1	
	x = -TILE_SIZE * 1024
	y = 0
	Dx = 0
	Dy = 1
	

	Frame = 0
	BaseFrame = 174
	NumFrames = 8
	
	Wid = 16
	Hei	= 16
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor DialogTrigger()

End Destructor


property DialogTrigger.IsActive() as integer
	property = Active
End Property

property DialogTrigger.GetID() as integer
	property = ID
End Property
		
property DialogTrigger.GetX() as single
	property = x
End Property

property DialogTrigger.GetY() as single
	property = y
End Property

property DialogTrigger.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property DialogTrigger.GetBox() as AABB
	property = BoxNormal
End Property


sub DialogTrigger.ActionFalling( Map() as TileType )
	
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

	
sub DialogTrigger.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
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
	BaseFrame = 174
	NumFrames = 8
	
	Wid = 16
	Hei	= 16
	
	BoxNormal.Init( x, y, wid, Hei)
	

End Sub


sub DialogTrigger.Update( byref Snipe as Player, Map() as TileType )
	
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
	

	BoxNormal.Init( x, y, wid, Hei)
	 
			
End Sub


sub DialogTrigger.Explode()
	
	Explosion.Spawn( Vector3D(x + Wid\2, y + Hei\2, 2), Vector3D(0, 0, 0), Explosion.TWINKLE )
	
	Kill()
	
End Sub

sub DialogTrigger.Kill()
	
	Active = FALSE
	x = -TILE_SIZE * 1024
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub DialogTrigger.Draw( SpriteSet() as GL2D.IMAGE ptr )
	GL2D.Sprite3D( x, y, -2, FlipMode, SpriteSet( BaseFrame + Frame ) )
End Sub

sub DialogTrigger.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


function DialogTrigger.CollideWithPlayer( byref Snipe as Player ) as integer
	
	
	if( (Snipe.GetState <> Player.DIE) ) then	
		dim as AABB Box = Snipe.GetBoxNormal
		if( BoxNormal.Intersects(Box) ) then
			Explode()
			return TRUE
		endif		
	endif
	
	return FALSE
	
end function


''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function DialogTrigger.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function DialogTrigger.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' DialogTriggerFactory
''
''*****************************************************************************

constructor DialogTriggerFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(DialogTriggers)
		DialogTriggers(i).Kill()
	Next
	
End Constructor

destructor DialogTriggerFactory()

End Destructor

property DialogTriggerFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property DialogTriggerFactory.GetMaxEntities() as integer
	property = ubound(DialogTriggers)
end property 

sub DialogTriggerFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(DialogTriggers)
		if( DialogTriggers(i).IsActive ) then
			DialogTriggers(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub DialogTriggerFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(DialogTriggers)
		if( DialogTriggers(i).IsActive ) then
			DialogTriggers(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub DialogTriggerFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(DialogTriggers)
		if( DialogTriggers(i).IsActive ) then
			DialogTriggers(i).DrawAABB()
		EndIf
	Next
	
end sub

sub DialogTriggerFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(DialogTriggers)
		if( DialogTriggers(i).IsActive ) then
			DialogTriggers(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

function DialogTriggerFactory.HandleCollisions( byref Snipe as Player ) as integer
	
	for i as integer = 0 to ubound(DialogTriggers)
		
		if( DialogTriggers(i).IsActive ) then
			if( DialogTriggers(i).CollideWithPlayer( Snipe ) ) then
				return (i+1)
			EndIf
		endif
		
	Next i
	
	return 0
	
end function

sub DialogTriggerFactory.SortEntities()
	
	'' Hell yeah! Bubble sort!
	for i as integer = 0 to ubound(DialogTriggers)
		if( DialogTriggers(i).IsActive ) then
			for j as integer = 0 to ubound(DialogTriggers) - 1
				if( DialogTriggers(j).IsActive ) then
					if( DialogTriggers(i).GetX < DialogTriggers(j).GetX ) then
						swap DialogTriggers(i), DialogTriggers(j)
					endif
				endif
			next
		endif
	next
	
end sub

sub DialogTriggerFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(DialogTriggers)
		if( DialogTriggers(i).IsActive = FALSE ) then
			DialogTriggers(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function DialogTriggerFactory.GetAABB( byval i as integer ) as AABB
	
	return DialogTriggers(i).GetBox
	
End Function

function DialogTriggerFactory.GetID( byval i as integer ) as integer
	return DialogTriggers(i).GetID
End Function
			