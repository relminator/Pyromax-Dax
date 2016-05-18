''*****************************************************************************
''
''
''	Pyromax Dax Checkpoint Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Checkpoint.bi"

const as integer MAX_VANISH_COUNTER = 60 * 2
 
constructor Checkpoint()

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
	
	VanishCounter = MAX_VANISH_COUNTER
	VanishInterpolator = 0
	
	Frame = 0
	BaseFrame = 80
	NumFrames = 4
	
	Wid = 16
	Hei	= 16
	
	BoxNormal.Init( x - Wid\2, y - Hei\2, wid, Hei)
	
End Constructor

destructor Checkpoint()

End Destructor


property Checkpoint.IsActive() as integer
	property = Active
End Property

property Checkpoint.GetID() as integer
	property = ID
End Property
		
property Checkpoint.GetX() as single
	property = x
End Property

property Checkpoint.GetY() as single
	property = y
End Property

property Checkpoint.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Checkpoint.GetBox() as AABB
	property = BoxNormal
End Property


sub Checkpoint.ActionFalling( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - Hei - 1
		if( Orientation = ORIENTATION_LEFT ) then						
			Dy = 1
			Dx = 0
		else
			Dy = 1
			Dx = 0
		endif
	else
		y += Dy												
		Dy += GRAVITY
	endif
	
		
end sub

sub Checkpoint.ActionVanish( Map() as TileType )
	
	VanishCounter -= 1	
	if( VanishCounter < 0 ) then
		Kill()
	endif
	
end sub
	
sub Checkpoint.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
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
	
	VanishCounter = MAX_VANISH_COUNTER
	
	Dx = 0
	Dy = 1
	
	Frame = 0
	BaseFrame = 19
	NumFrames = 4
	
	Wid = 16
	Hei	= 32*4
	
	BoxNormal.Init( x, y, Wid, Hei)
	
End Sub


sub Checkpoint.Update( byref Snipe as Player, Map() as TileType )
	
	'if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 12  ) then return
	
	Counter += 1
	
	if( (Counter and 7) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	select case State
		case STATE_FALLING:
			ActionFalling( Map() )
		case STATE_VANISH:
			ActionVanish( Map() )
	end select	
	

	BoxNormal.Init( x, y, Wid, Hei)
	 
			
End Sub


sub Checkpoint.Explode()
	
	for i as integer = 0 to Hei\16
		Explosion.Spawn( Vector3D(x + Wid\2, y + (i * 16) + 8, 2), Vector3D(0, 0, 0), Explosion.TWINKLE )
	next i
	
	State = STATE_VANISH
	'Kill()
	
End Sub

sub Checkpoint.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub Checkpoint.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	if( State = STATE_FALLING ) then
		dim as single wd =  1 + (16) * abs(sin(Counter*0.1))
		GL2D.SpriteStretch( x-wd/2 + 8, y, wd, Hei, SpriteSet( BaseFrame + Frame ) )
	else
		if( VanishCounter > 0 ) then
			dim as single c = abs(sin(VanishCounter*0.2))
			glColor4f(c,c,c,1)
			GL2D.PrintScale( x - 16 * 4,  y - 32, 1, "checkpoint" )
			glColor4f(1,1,1,1)    
		endif
	endif
		
End Sub


sub Checkpoint.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


function Checkpoint.CollideWithPlayer( byref Snipe as Player, byref SpawnX as integer, byref SpawnY as integer ) as integer
	
	
	if( State = STATE_VANISH ) then
		return FALSE
	endif
	
	if( (Snipe.GetState <> Player.DIE) ) then	
		dim as AABB Box = Snipe.GetBoxNormal
		if( BoxNormal.Intersects(Box) ) then
			SpawnX = x
			SpawnY = y + hei - Snipe.GetHei				
			Explode()
			Sound.PlaySFX( Sound.SFX_POWER_UP)
			return TRUE
		endif		
	endif
	
	return FALSE
	
end function


''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Checkpoint.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function Checkpoint.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' CheckpointFactory
''
''*****************************************************************************

constructor CheckpointFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Checkpoints)
		Checkpoints(i).Kill()
	Next
	
End Constructor

destructor CheckpointFactory()

End Destructor

property CheckpointFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property CheckpointFactory.GetMaxEntities() as integer
	property = ubound(Checkpoints)
end property 

sub CheckpointFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Checkpoints)
		if( Checkpoints(i).IsActive ) then
			Checkpoints(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub CheckpointFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Checkpoints)
		if( Checkpoints(i).IsActive ) then
			Checkpoints(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub CheckpointFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Checkpoints)
		if( Checkpoints(i).IsActive ) then
			Checkpoints(i).DrawAABB()
		EndIf
	Next
	
end sub

sub CheckpointFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Checkpoints)
		if( Checkpoints(i).IsActive ) then
			Checkpoints(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

function CheckpointFactory.HandleCollisions( byref Snipe as Player, byref SpawnX as integer, byref SpawnY as integer  ) as integer
	
	for i as integer = 0 to ubound(Checkpoints)
		
		if( Checkpoints(i).IsActive ) then
			if( Checkpoints(i).CollideWithPlayer( Snipe, SpawnX, SpawnY ) ) then
				return TRUE
			EndIf
		endif
		
	Next i
	
	return FALSE
	
end function

sub CheckpointFactory.SortEntities()
	
	'' Hell yeah! Bubble sort!
	for i as integer = 0 to ubound(Checkpoints)
		if( Checkpoints(i).IsActive ) then
			for j as integer = 0 to ubound(Checkpoints) - 1
				if( Checkpoints(j).IsActive ) then
					if( Checkpoints(i).GetX < Checkpoints(j).GetX ) then
						swap Checkpoints(i), Checkpoints(j)
					endif
				endif
			next
		endif
	next
	
end sub

sub CheckpointFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(Checkpoints)
		if( Checkpoints(i).IsActive = FALSE ) then
			Checkpoints(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function CheckpointFactory.GetAABB( byval i as integer ) as AABB
	
	return Checkpoints(i).GetBox
	
End Function

function CheckpointFactory.GetID( byval i as integer ) as integer
	return Checkpoints(i).GetID
End Function
			