''*****************************************************************************
''
''
''	Pyromax Dax Drumbot Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Drumbot.bi"


constructor Drumbot()

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
	BaseFrame = 14
	NumFrames = 4
	
	Wid = 24
	Hei	= 26 * 5
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor Drumbot()

End Destructor


property Drumbot.IsActive() as integer
	property = Active
End Property
		
property Drumbot.GetX() as single
	property = x
End Property

property Drumbot.GetY() as single
	property = y
End Property

property Drumbot.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Drumbot.GetBox() as AABB
	property = BoxNormal
End Property

''*****************************************************************************
''
''*****************************************************************************

sub Drumbot.CollideOnFloors( Map() as TileType )
	
	dim as integer TileX, TileY

	if( Dy < 0 ) then   	'' moving Up
		
		if( CollideFloors( int(x), int(y + Dy), TileY, Map() ) ) then   		'' hit the roof
			y = ( TileY + 1 ) * TILE_SIZE + 1									'' Snap below the tile
			Dy = 0    															'' Arrest movement
		else
			y += Dy																'' No collision so move
			Dy += GRAVITY														'' with gravity
		EndIf
			
	else	'' Stationary or moving down
		
		if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	'' (y + Dy + hei) = Foot of player
			y = ( TileY ) * TILE_SIZE - Hei - 1								'' Snap above the tile
			Dy = 1															'' Set to 1 so that we always collide with floor next frame
		else
			y += Dy															'' No collision so move
			Dy += GRAVITY
		EndIf
		
	EndIf
	
end sub

sub Drumbot.ActionFalling( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideFloors( int(x), int(y + Dy + Hei), TileY, Map() ) ) then	
		y = ( TileY ) * TILE_SIZE - Hei - 1
		if( Orientation = ORIENTATION_LEFT ) then						
			Dy = 1
			Dx = -Speed
			State = STATE_MOVE_LEFT
		else
			Dy = 1
			Dx = Speed
			State = STATE_MOVE_RIGHT
		endif
	else
		y += Dy												
		Dy += GRAVITY
	endif
	
		
end sub

sub Drumbot.ActionMoveRight( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideWalls( int(x + Dx + Wid), int(y), TileX, Map() ) ) then
		x = TileX * TILE_SIZE - Wid - 1
		Dx = -Speed
		State = STATE_MOVE_LEFT
	else		
		x += Dx
	endif
	
	CollideOnFloors( Map() )
	
end sub

sub Drumbot.ActionMoveLeft( Map() as TileType )
	
	dim as integer TileX, TileY
	if( CollideWalls( int(x + Dx), int(y), TileX, Map() ) ) then
		x = ( TileX + 1 ) * TILE_SIZE + 1
		Dx = Speed
		State = STATE_MOVE_RIGHT
	else
		x += Dx
	endif

	CollideOnFloors( Map() )
	
end sub

	
sub Drumbot.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Orientation = iOrientation
	State = STATE_FALLING
	if( Orientation = ORIENTATION_LEFT ) then
		FlipMode = GL2D.FLIP_NONE
	else
		FlipMode = GL2D.FLIP_H
	endif
	
	Speed = 0.15
	
	BlinkCounter = -1
	Hp = 100
	
	x = ix
	y = iy
	
	Dx = 0
	Dy = 1
	
	Frame = 0
	BaseFrame = 14
	NumFrames = 3
	
	Wid = 24
	Hei	= 26 * 5
	
	BoxNormal.Init( x, y, wid, Hei)
	BoxSmall.Init( x, y + 26, wid, 26 )
	

End Sub


sub Drumbot.Update( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 12  ) then return
	
	
	Counter += 1
	
	if( (Counter and 7) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	
	if( BlinkCounter > 0 ) then
		BlinkCounter -= 1
	endif
	
	select case State
		case STATE_FALLING:
			ActionFalling( Map() )
		case STATE_MOVE_RIGHT:
			ActionMoveRight( Map() )
			if( (Counter and 127) = 0 ) then
				Bullets.Spawn( x + Wid\2, y + 32, 360 - 80, 12.5, Bullet.STATE_GRAVITY_BOUNCE, Bullet.ID_PLATE )
			endif	
		case STATE_MOVE_LEFT:
			ActionMoveLeft( Map() )
			if( (Counter and 127) = 0 ) then
				Bullets.Spawn( x + Wid\2, y + 32, 180 + 80, 12.5, Bullet.STATE_GRAVITY_BOUNCE, Bullet.ID_PLATE )
			endif
		case else
	end select	
	

	BoxNormal.Init( x, y, wid, Hei)
	BoxSmall.Init( x, y + 26, wid, 26 )
	 
			
End Sub


sub Drumbot.Explode()
	
	for i as integer = 0 to 4
		Explosion.SpawnMulti( Vector3D((x-2) + sin((Counter+ i * 10) * 0.15) * 2, y + i * 26, 2), 2, rnd * 360, Explosion.MEDIUM_YELLOW_03, Explosion.SMOKE_01, 2 )
	next i
	
	Kill()
	
End Sub

sub Drumbot.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub Drumbot.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	if( State = STATE_MOVE_RIGHT ) then
		FlipMode = GL2D.FLIP_H
	else
		FlipMode = GL2D.FLIP_NONE
	endif

	if( (BlinkCounter > 0)  and ((BlinkCounter and 3) = 0) ) then
		GL2D.EnableSpriteStencil( TRUE, GL2D_RGBA(255,255,255,255), GL2D_RGBA(255,255,255,255) )
		for i as integer = 0 to 4
			if( i = 1 ) then
				GL2D.Sprite( (x-2) + sin((Counter+ i * 10) * 0.15) * 2, y + i * 26, FlipMode, SpriteSet( BaseFrame + Frame ) )
			else
				GL2D.Sprite( (x-2) + sin((Counter+ i * 10) * 0.15) * 2, y + i * 26, FlipMode, SpriteSet( BaseFrame + 4 ) )
			endif
		next i
		GL2D.EnableSpriteStencil( FALSE )
	else
		for i as integer = 0 to 4
			if( i = 1 ) then
				GL2D.Sprite( (x-2) + sin((Counter+ i * 10) * 0.15) * 2, y + i * 26, FlipMode, SpriteSet( BaseFrame + Frame ) )
			else
				GL2D.Sprite( (x-2) + sin((Counter+ i * 10) * 0.15) * 2, y + i * 26, FlipMode, SpriteSet( BaseFrame + 4 ) )
			endif
		next i
	endif
	
End Sub

sub Drumbot.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	BoxSmall.Draw( 4, GL2D_RGB( 0, 255, 255 ) )
	
end sub

function Drumbot.PlayerCollideHead( byref Snipe as Player ) as integer
	
	dim as AABB Box = Snipe.GetBoxNormal
	dim as integer TestEnd = Snipe.GetX + Snipe.GetWid
	dim as integer ix = Snipe.GetX
	
	Box.y1 += Snipe.GetDy * 3
	Box.y2 += Snipe.GetDy * 3
	
	while( ix <= TestEnd ) 
		if( ix >= x ) then
			if( ix <= (x + Wid) ) then
				if( BoxNormal.Intersects(Box) ) then
					return TRUE
				endif
			endif
		endif
		ix += Snipe.GetWid
	Wend
	
	return FALSE
				
End Function

sub Drumbot.CollideWithPlayer( byref Snipe as Player )
	
	if( (Snipe.GetDy >= 0) and ((Snipe.GetY + Snipe.GetHei) <= y) ) then
		if( PlayerCollideHead( Snipe ) ) then		 '' Bounce 
			Snipe.SetY = ((y - Snipe.GetHei) - 1)
			Snipe.SetDy = -JUMPHEIGHT * 1.5
			Snipe.SetState( Player.BOUNCING )
			Sound.PlaySFX( Sound.SFX_BOUNCE )
		endif		
	endif
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxNormal.Intersects(Box) ) then
			Snipe.HitAnimation( x, 45 )
		endif		
	endif
	
	dim as integer AttackEnergy = 0
	
	AttackEnergy = Snipe.CollideShots( BoxSmall )
	if( AttackEnergy ) then
		Hp -= 26
		BlinkCounter = MAX_ENEMY_BLINK_COUNTER
		if( Hp <= 0 ) then
			Explode()
			Snipe.AddToScore( 211 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxSmall )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 211 )
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxSmall )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 211 )
	endif
	
	AttackEnergy = Snipe.CollideMines( BoxSmall )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 211 )
	endif
	
	Snipe.CollideShots( BoxNormal )
	Snipe.CollideBombs( BoxNormal )
	Snipe.CollideDynamites( BoxNormal )
	Snipe.CollideMines( BoxNormal )
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************
function Drumbot.CollideWalls(byval ix as integer, byval iy as integer, byref iTileX as integer, Map() as TileType ) as integer
	
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
function Drumbot.CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
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



function Drumbot.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' DrumbotFactory
''
''*****************************************************************************

constructor DrumbotFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Drumbots)
		Drumbots(i).Kill()
	Next
	
End Constructor

destructor DrumbotFactory()

End Destructor

property DrumbotFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property DrumbotFactory.GetMaxEntities() as integer
	property = ubound(Drumbots)
end property 

sub DrumbotFactory.UpdateEntities( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Drumbots)
		if( Drumbots(i).IsActive ) then
			Drumbots(i).Update( Snipe, Bullets, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub DrumbotFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Drumbots)
		if( Drumbots(i).IsActive ) then
			Drumbots(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub DrumbotFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Drumbots)
		if( Drumbots(i).IsActive ) then
			Drumbots(i).DrawAABB()
		EndIf
	Next
	
end sub

sub DrumbotFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Drumbots)
		if( Drumbots(i).IsActive ) then
			Drumbots(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub DrumbotFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(Drumbots)
		
		if( Drumbots(i).IsActive ) then
			Drumbots(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub DrumbotFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(Drumbots)
		if( Drumbots(i).IsActive = FALSE ) then
			Drumbots(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function DrumbotFactory.GetAABB( byval i as integer ) as AABB
	
	return Drumbots(i).GetBox
	
End Function
	