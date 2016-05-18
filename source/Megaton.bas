''*****************************************************************************
''
''
''	Pyromax Dax Megaton Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Megaton.bi"

const as integer MAX_IDLE_COUNTER = 60 * 2

constructor Megaton()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	State = STATE_IDLE
	Idlecounter = MAX_IDLE_COUNTER
	
	Speed = 1	
	x = 0
	y = 0
	Dx = 0
	Dy = 1
	Ypos = y

	Frame = 0
	BaseFrame = 38
	NumFrames = 1
	
	Wid = 52
	Hei	= 56
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor Megaton()

End Destructor


property Megaton.IsActive() as integer
	property = Active
End Property
		
property Megaton.GetX() as single
	property = x
End Property

property Megaton.GetY() as single
	property = y
End Property

property Megaton.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Megaton.GetBox() as AABB
	property = BoxNormal
End Property

''*****************************************************************************
''
''*****************************************************************************
sub Megaton.ActionIdle( Map() as TileType )
	
	Dx = 0
	Dy = 0
	
	Idlecounter -= 1
	if( Idlecounter <= 0 ) then
		State = NextState
		ResolveDirectionVectors()
	endif
	
end sub


sub Megaton.ActionMoveUp( Map() as TileType )

	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy), TileY, Map() ) ) then
		y = ( TileY + 1 ) * TILE_SIZE + 1						
		State = STATE_IDLE
		NextState = STATE_MOVE_DOWN
		Idlecounter = MAX_IDLE_COUNTER
		ResolveDirectionVectors()
	else
		y += Dy
	endif
	
end sub

sub Megaton.ActionMoveDown( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - Hei - 1						
		State = STATE_IDLE
		NextState = STATE_MOVE_UP
		Idlecounter = MAX_IDLE_COUNTER
		ResolveDirectionVectors()
		Sound.PlaySFX( Sound.SFX_METAL_HIT )
		Globals.SetQuakeCounter(30)
	else
		y += Dy
		Dy += GRAVITY
	endif

end sub

sub Megaton.ActionWait( byval SnipeX as integer, Map() as TileType )
	
	Dx = 0
	Dy = 0
	if( abs( (x + Wid/2) - (SnipeX + 6) ) < (TILE_SIZE*2.5) ) then
		State = STATE_IDLE
	endif
	
end sub

	
sub Megaton.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Idlecounter = -1 'MAX_IDLE_COUNTER + (rnd * MAX_IDLE_COUNTER * 4)
	State = STATE_WAIT
	FlipMode = GL2D.FLIP_NONE
	
	NextState = STATE_MOVE_DOWN
	
	Speed = 1
	
	x = ix
	y = iy
	Ypos = y
	YposOffset = 0
	
	Dx = 0
	Dy = 1
	
	BaseFrame = 38
	NumFrames = 1
	
	Wid = 52
	Hei	= 56
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Sub


sub Megaton.Update( byref Snipe as Player,  Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 12  ) then 
		if( State <> STATE_WAIT ) then
			State = STATE_WAIT
			NextState = STATE_MOVE_DOWN
			y = Ypos
			Idlecounter = -1
		else
			return
		endif
		
	EndIf
	
	Counter += 1

	
	select case State
		case STATE_IDLE:
			ActionIdle( Map() )
		case STATE_MOVE_UP:
			ActionMoveUp( Map() )
		case STATE_MOVE_DOWN:
			ActionMoveDown( Map() )
		case STATE_WAIT:
			ActionWait( Snipe.GetX, Map() )
	end select	
	
	YposOffset = y and 15
	
	BoxNormal.Init( x, (y + Hei) - 16, Wid, 16)
	 
			
end sub

sub Megaton.ResolveDirectionVectors()

	select case State
		case STATE_IDLE:
			Dx = 0
			Dy = 0
		case STATE_MOVE_UP:
			Dx = 0
			Dy = -0.75
		case STATE_MOVE_DOWN:
			Dx = 0
			Dy = 1
		case STATE_WAIT:
			Dx = 0
			Dy = 0
	end select	

end sub


sub Megaton.Explode()
	
	Explosion.Spawn( Vector3D(x + Wid\2, y + Hei\2, 2), Vector3D(0, 0, 0), Explosion.MEDIUM_YELLOW_01 )
	
	Kill()
	
End Sub

sub Megaton.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub Megaton.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	dim as integer dist = (y - Ypos) + YposOffset
	dim as integer NumChains = dist \ 16
	
	
	GL2D.Sprite3D( x, y, -4, FlipMode, SpriteSet( BaseFrame + Frame ) )
	
	for i as integer = 0 to Numchains
		GL2D.Sprite3D( x + 20, y - i*16, -4, FlipMode, SpriteSet( 37 ) )
		GL2D.Sprite3D( x + 20, y - i*16 - 8, -4, FlipMode, SpriteSet( 36 ) )
	next
	
End Sub

sub Megaton.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


sub Megaton.CollideWithPlayer( byref Snipe as Player )
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxNormal.Intersects(Box) ) then
			Snipe.HitAnimation( x, 65 )
		endif		
	endif
	
	
	Snipe.CollideShots( BoxNormal )
	Snipe.CollideBombs( BoxNormal )	
	Snipe.CollideDynamites( BoxNormal )
	Snipe.CollideMines( BoxNormal )
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Megaton.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function Megaton.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' MegatonFactory
''
''*****************************************************************************

constructor MegatonFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Megatons)
		Megatons(i).Kill()
	Next
	
End Constructor

destructor MegatonFactory()

End Destructor

property MegatonFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property MegatonFactory.GetMaxEntities() as integer
	property = ubound(Megatons)
end property 

sub MegatonFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Megatons)
		if( Megatons(i).IsActive ) then
			Megatons(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub MegatonFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Megatons)
		if( Megatons(i).IsActive ) then
			Megatons(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub MegatonFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Megatons)
		if( Megatons(i).IsActive ) then
			Megatons(i).DrawAABB()
		EndIf
	Next
	
end sub

sub MegatonFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Megatons)
		if( Megatons(i).IsActive ) then
			Megatons(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub MegatonFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(Megatons)
		
		if( Megatons(i).IsActive ) then
			Megatons(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub MegatonFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(Megatons)
		if( Megatons(i).IsActive = FALSE ) then
			Megatons(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function MegatonFactory.GetAABB( byval i as integer ) as AABB
	
	return Megatons(i).GetBox
	
End Function
	