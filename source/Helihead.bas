''*****************************************************************************
''
''
''	Pyromax Dax Helihead Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Helihead.bi"


const as integer MAX_IDLE_COUNTER = 60

constructor Helihead()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	Orientation = ORIENTATION_LEFT
	State = STATE_PASSIVE
	IdleCounter = MAX_IDLE_COUNTER
		
	Speed = 1	
	x = 0
	y = 0
	Dx = 0
	Dy = 1
	

	Frame = 0
	BaseFrame = 76
	NumFrames = 4
	
	Wid = 24
	Hei	= 24
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor Helihead()

End Destructor


property Helihead.IsActive() as integer
	property = Active
End Property
		
property Helihead.GetX() as single
	property = x
End Property

property Helihead.GetY() as single
	property = y
End Property

property Helihead.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Helihead.GetBox() as AABB
	property = BoxNormal
End Property

''*****************************************************************************
''
''*****************************************************************************

function Helihead.CollideOnMap( Map() as TileType ) as integer
	
	dim as integer TileX, TileY

	if( Dx > 0 ) then 
		if( CollideWalls( int(x + Dx + Wid), int(y), TileX, Map() ) ) then 
			x = TileX * TILE_SIZE - Wid - 1
			Speed = -Speed
			Dx = Speed							
		else
			x += Dx 													
		endif
	
	elseif( Dx < 0 ) then																					
		if( CollideWalls( int(x + Dx), int(y), TileX, Map() ) ) then			
			x = ( TileX + 1 ) * TILE_SIZE + 1
			Speed = -Speed
			Dx = Speed						
		else
			x += Dx 													
		endif
	endif
	
	

	if( Dy < 0 ) then   	'' moving Up
		
		if( CollideFloors( int(x), int(y + Dy), TileY, Map() ) ) then   		'' hit the roof
			y = ( TileY + 1 ) * TILE_SIZE + 1									'' Snap below the tile
			Dy = 0    															'' Arrest movement
		else
			y += Dy																'' No collision so move
		endif
			
	else	'' Stationary or moving down
		
		if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	'' (y + Dy + hei) = Foot of player
			y = ( TileY ) * TILE_SIZE - Hei - 1								'' Snap above the tile
			Dy = 0															'' Set to 1 so that we always collide with floor next frame
		else
			y += Dy															'' No collision so move
		endif
		
	endif
	
	return FALSE
	
end function


sub Helihead.ActionPassive( Map() as TileType )
	
	Dy = 0
	CollideOnMap( Map() )
	
end sub

sub Helihead.ActionAggressive( Map() as TileType )
	
	Dx = Speed * 3	
	CollideOnMap( Map() )
	
end sub

	
sub Helihead.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Orientation = iOrientation
	State = STATE_PASSIVE
	FlipMode = GL2D.FLIP_NONE
	IdleCounter = MAX_IDLE_COUNTER
	
	if( Orientation = ORIENTATION_LEFT ) then	
		Speed = -0.75
	else
		Speed = 0.75
		FlipMode = GL2D.FLIP_H
	endif
	
	BlinkCounter = -1
	Hp = 100
	
	x = ix
	y = iy
	
	Dx = Speed
	Dy = 0
	
	Frame = 0
	BaseFrame = 76
	NumFrames = 4
	
	Wid = 24
	Hei	= 24
	
	BoxNormal.Init( x, y, wid, Hei)
	

End Sub


sub Helihead.Update( byref Snipe as Player, Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 12  ) then return
	
	Counter + = 1
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	if( BlinkCounter > 0 ) then
		BlinkCounter -= 1
	endif
	
	dim as single Dist = ((Snipe.GetX - x) ^ 2)  + ((Snipe.GetY - y) ^ 2)
	if( Dist <= (( TILE_SIZE * 5) ^ 2) ) then
		State = STATE_AGGRESSIVE
		if( abs(y - Snipe.GetY) > (TILE_SIZE\8) ) then
			Dy = -sgn(y - Snipe.GetY )		
		endif
	else
		State = STATE_PASSIVE
		Dy = 0 
	endif
	
	
	select case State
		case STATE_PASSIVE:
			ActionPassive( Map() )
			if( (x - Snipe.GetX) > (TILE_SIZE*4) ) then
				Speed = -0.75
				Dx = Speed						
			elseif( (x - Snipe.GetX) < -(TILE_SIZE*4) ) then
				Speed = 0.75
				Dx = Speed						
			endif
		case STATE_AGGRESSIVE:
			ActionAggressive( Map() )
		case else
	end select	
	
	Animate()
	
	BoxNormal.Init( x, y, wid, Hei)
	 
			
End Sub


sub Helihead.Explode()
	
	Explosion.SpawnMulti( Vector3D(x + Wid\2, y + Hei\2, 2), 2, rnd * 360, Explosion.MEDIUM_YELLOW_01, Explosion.SMOKE_01, 4 )	

	Kill()
	
End Sub

sub Helihead.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
end sub

sub Helihead.Animate()
	
	if( Dx < 0) then
		Flipmode = GL2D.FLIP_NONE
	else
		Flipmode = GL2D.FLIP_H
	endif
	
end sub
	
sub Helihead.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	if( (BlinkCounter > 0)  and ((BlinkCounter and 3) = 0) ) then
		GL2D.EnableSpriteStencil( TRUE, GL2D_RGBA(255,255,255,255), GL2D_RGBA(255,255,255,255) )
		GL2D.Sprite( x-8, y - 4, FlipMode, SpriteSet( BaseFrame + Frame ) )
		GL2D.EnableSpriteStencil( FALSE )
	else
		GL2D.Sprite( x-8, y - 4, FlipMode, SpriteSet( BaseFrame + Frame ) )
	endif
	
End Sub

sub Helihead.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


sub Helihead.CollideWithPlayer( byref Snipe as Player )
	
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxNormal.Intersects(Box) ) then
			Snipe.HitAnimation( x, 45 )
		endif		
	endif
	
	dim as integer AttackEnergy = 0
	
	AttackEnergy = Snipe.CollideShots( BoxNormal )
	if( AttackEnergy ) then
		Hp -= 36
		BlinkCounter = MAX_ENEMY_BLINK_COUNTER
		if( Hp <= 0 ) then
			Explode()
			Snipe.AddToScore( 302 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 302 )
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 302 )
	endif
	
	AttackEnergy = Snipe.CollideMines( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 302 )
	endif
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Helihead.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function Helihead.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function Helihead.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' HeliheadFactory
''
''*****************************************************************************

constructor HeliheadFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Heliheads)
		Heliheads(i).Kill()
	Next
	
End Constructor

destructor HeliheadFactory()

End Destructor

property HeliheadFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property HeliheadFactory.GetMaxEntities() as integer
	property = ubound(Heliheads)
end property 

sub HeliheadFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Heliheads)
		if( Heliheads(i).IsActive ) then
			Heliheads(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub HeliheadFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Heliheads)
		if( Heliheads(i).IsActive ) then
			Heliheads(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub HeliheadFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Heliheads)
		if( Heliheads(i).IsActive ) then
			Heliheads(i).DrawAABB()
		EndIf
	Next
	
end sub

sub HeliheadFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Heliheads)
		if( Heliheads(i).IsActive ) then
			Heliheads(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub HeliheadFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(Heliheads)
		
		if( Heliheads(i).IsActive ) then
			Heliheads(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub HeliheadFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(Heliheads)
		if( Heliheads(i).IsActive = FALSE ) then
			Heliheads(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function HeliheadFactory.GetAABB( byval i as integer ) as AABB
	
	return Heliheads(i).GetBox
	
End Function
	