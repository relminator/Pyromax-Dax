''*****************************************************************************
''
''
''	Pyromax Dax Jumpbot Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Jumpbot.bi"


const as integer MAX_IDLE_COUNTER = 60

constructor Jumpbot()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	Orientation = ORIENTATION_LEFT
	State = STATE_FALLING
	IdleCounter = MAX_IDLE_COUNTER
		
	Speed = 1	
	x = 0
	y = 0
	Dx = 0
	Dy = 1
	

	Frame = 0
	BaseFrame = 104
	NumFrames = 14
	
	Wid = 22
	Hei	= 30
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor Jumpbot()

End Destructor


property Jumpbot.IsActive() as integer
	property = Active
End Property
		
property Jumpbot.GetX() as single
	property = x
End Property

property Jumpbot.GetY() as single
	property = y
End Property

property Jumpbot.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Jumpbot.GetBox() as AABB
	property = BoxNormal
End Property

''*****************************************************************************
''
''*****************************************************************************

function Jumpbot.CollideOnMap( Map() as TileType ) as integer
	
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
			Dy += GRAVITY														'' with gravity
		endif
			
	else	'' Stationary or moving down
		
		if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	'' (y + Dy + hei) = Foot of player
			y = ( TileY ) * TILE_SIZE - Hei - 1								'' Snap above the tile
			Dy = 1															'' Set to 1 so that we always collide with floor next frame
			return TRUE
		else
			y += Dy															'' No collision so move
			Dy += GRAVITY
		EndIf
		
	EndIf
	
	return FALSE
	
end function

sub Jumpbot.ActionFalling( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - Hei - 1
		if( Orientation = ORIENTATION_LEFT ) then						
			Dy = 1
			Speed = -Speed
			Dx = Speed
			State = STATE_IDLE
			IdleCounter = MAX_IDLE_COUNTER
		else
			Dy = 1
			Dx = Speed
			State = STATE_IDLE
			IdleCounter = MAX_IDLE_COUNTER
		endif
	else
		y += Dy												
		Dy += GRAVITY
	endif
	
		
end sub

sub Jumpbot.ActionJumping( Map() as TileType )
	
	if( CollideOnMap( Map() ) ) then
		State = STATE_IDLE
	endif
	
end sub

sub Jumpbot.ActionIdle( byref Snipe as Player, Map() as TileType )
	
	Dx = 0
	Dy = 1
	IdleCounter -= 1
	if( IdleCounter <= 0 ) then
		State = STATE_JUMPING
		IdleCounter = MAX_IDLE_COUNTER
		if( (x - Snipe.GetX) > (TILE_SIZE*2) ) then
			Speed = -0.75 - (rnd * 5)
		elseif( (x - Snipe.GetX) < -(TILE_SIZE*2) ) then
			Speed = 0.75 + (rnd * 5)
		endif
		Dx = Speed
		Dy = -JUMPHEIGHT
	endif
	
	
	CollideOnMap( Map() )
	
end sub

	
sub Jumpbot.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Orientation = iOrientation
	State = STATE_FALLING
	FlipMode = GL2D.FLIP_NONE
	IdleCounter = MAX_IDLE_COUNTER
		
	Speed = 0.75
	
	BlinkCounter = -1
	Hp = 100
	
	x = ix
	y = iy
	
	Dx = 0
	Dy = 1
	
	Frame = 0
	BaseFrame = 104
	NumFrames = 14
	
	Wid = 22
	Hei	= 30
	
	BoxNormal.Init( x, y, wid, Hei)
	

End Sub


sub Jumpbot.Update( byref Snipe as Player, Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 12  ) then return
	
	Counter + = 1
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	if( BlinkCounter > 0 ) then
		BlinkCounter -= 1
	endif
	
	select case State
		case STATE_FALLING:
			ActionFalling( Map() )
		case STATE_JUMPING:
			ActionJumping( Map() )
		case STATE_IDLE:
			Frame = 0
			ActionIdle( Snipe, Map() )
		case else
	end select	
	

	BoxNormal.Init( x, y, wid, Hei)
	 
			
End Sub


sub Jumpbot.Explode()
	
	Explosion.SpawnMulti( Vector3D(x + Wid\2, y + Hei\2, 2), 2, rnd * 360, Explosion.MEDIUM_YELLOW_03, Explosion.SMOKE_02, 4 )		
	Kill()
	
End Sub

sub Jumpbot.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub Jumpbot.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	if( (BlinkCounter > 0)  and ((BlinkCounter and 3) = 0) ) then
		GL2D.EnableSpriteStencil( TRUE, GL2D_RGBA(255,255,255,255), GL2D_RGBA(255,255,255,255) )
		GL2D.Sprite( x-4, y-6, FlipMode, SpriteSet( BaseFrame + Frame ) )
		GL2D.EnableSpriteStencil( FALSE )
	else
		GL2D.Sprite( x-4, y-6, FlipMode, SpriteSet( BaseFrame + Frame ) )
	endif
	
	
End Sub

sub Jumpbot.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


sub Jumpbot.CollideWithPlayer( byref Snipe as Player )
	
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxNormal.Intersects(Box) ) then
			Snipe.HitAnimation( x, 45 )
		endif		
	endif
	
	dim as integer AttackEnergy = 0
	
	AttackEnergy = Snipe.CollideShots( BoxNormal )
	if( AttackEnergy ) then
		Hp -= 26
		BlinkCounter = MAX_ENEMY_BLINK_COUNTER
		if( Hp <= 0 ) then
			Explode()
			Snipe.AddToScore( 402 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 402 )
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 402 )
	endif
	
	AttackEnergy = Snipe.CollideMines( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 402 )
	endif
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Jumpbot.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function Jumpbot.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function Jumpbot.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' JumpbotFactory
''
''*****************************************************************************

constructor JumpbotFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Jumpbots)
		Jumpbots(i).Kill()
	Next
	
End Constructor

destructor JumpbotFactory()

End Destructor

property JumpbotFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property JumpbotFactory.GetMaxEntities() as integer
	property = ubound(Jumpbots)
end property 

sub JumpbotFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Jumpbots)
		if( Jumpbots(i).IsActive ) then
			Jumpbots(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub JumpbotFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Jumpbots)
		if( Jumpbots(i).IsActive ) then
			Jumpbots(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub JumpbotFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Jumpbots)
		if( Jumpbots(i).IsActive ) then
			Jumpbots(i).DrawAABB()
		EndIf
	Next
	
end sub

sub JumpbotFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Jumpbots)
		if( Jumpbots(i).IsActive ) then
			Jumpbots(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub JumpbotFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(Jumpbots)
		
		if( Jumpbots(i).IsActive ) then
			Jumpbots(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub JumpbotFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(Jumpbots)
		if( Jumpbots(i).IsActive = FALSE ) then
			Jumpbots(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function JumpbotFactory.GetAABB( byval i as integer ) as AABB
	
	return Jumpbots(i).GetBox
	
End Function
	