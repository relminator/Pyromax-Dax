''*****************************************************************************
''
''
''	Pyromax Dax Bullet Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Bullet.bi"

const as integer MAX_BOUNCE_COUNT = 3

constructor Bullet()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	State = STATE_NORMAL
	ID = ID_DEFAULT
	BounceCount = 0
	
	x = 0
	y = 0
	Dx = 0
	Dy = 0
	
	Frame = 0
	BaseFrame = 31
	NumFrames = 4
	
	Wid = 12
	Hei	= 12
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor Bullet()

End Destructor


property Bullet.IsActive() as integer
	property = Active
End Property
		
property Bullet.GetX() as single
	property = x
End Property

property Bullet.GetY() as single
	property = y
End Property

property Bullet.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Bullet.GetBox() as AABB
	property = BoxNormal
End Property


sub Bullet.ActionNormal( Map() as TileType )
	
	x += Dx
	y += Dy
	
	if( Map(x \TILE_SIZE, y \TILE_SIZE).Collision >= TILE_SOLID  ) then
		Explode()
	endif
	
end sub

sub Bullet.ActionBounce( Map() as TileType )
	
	if( MapUtil.GetTile( x + Dx, y, Map() ) >= TILE_SOLID ) then
		Dx = -Dx
		BounceCount += 1
	else
		x += Dx
	endif
	
	if( MapUtil.GetTile( x, y + Dy, Map() ) >= TILE_SOLID ) then
		Dy = -Dy
		BounceCount += 1
	else
		y += Dy
	endif
		
	if( BounceCount > MAX_BOUNCE_COUNT ) then
		Explode()
	endif
	
end sub

sub Bullet.ActionGravity( Map() as TileType )
	
	x += Dx
	y += Dy
	Dy += GRAVITY
	
	if( Map(x \TILE_SIZE, y \TILE_SIZE).Collision >= TILE_SOLID  ) then
		Explode()
	endif
	
end sub

sub Bullet.ActionGravityBounce( Map() as TileType )
	
	if( MapUtil.GetTile( x + Dx, y, Map() ) >= TILE_SOLID ) then
		Dx = -Dx
		BounceCount += 1
	else
		x += Dx
	endif
	
	if( Dy > 0 ) then
		if( MapUtil.GetTile( x, y + Dy, Map() ) >= TILE_SOLID ) then
			Dy = -JUMPHEIGHT/2
			BounceCount += 1
		else
			y += Dy
		endif
	else
		if( MapUtil.GetTile( x, y + Dy, Map() ) >= TILE_SOLID ) then
			Dy = -Dy
			BounceCount += 1
		else
			y += Dy
		endif
	endif
	
	Dy += GRAVITY
		
	if( BounceCount > MAX_BOUNCE_COUNT ) then
		Explode()
	endif
	
end sub

sub Bullet.ResolveAnimationParameters()
	
	select case ID
		
		case ID_DEFAULT:
			BaseFrame = 31
			NumFrames = 4
			Wid = 12
			Hei	= 12
		case ID_SAGO:
			BaseFrame = 19
			NumFrames = 4
			Wid = 8
			Hei	= 8
		case ID_PLATE:
			BaseFrame = 24
			NumFrames = 1
			Wid = 22
			Hei	= 22
		case ID_MINI_FRISBEE:
			BaseFrame = 25
			NumFrames = 3
			Wid = 12
			Hei	= 12
		case ID_FRISBEE:
			BaseFrame = 28
			NumFrames = 3
			Wid = 20
			Hei	= 20
		case ID_ARROW:
			BaseFrame = 35
			NumFrames = 1
			Wid = 12
			Hei	= 12
		case ID_STONE:
			BaseFrame = 45
			NumFrames = 2
			Wid = 20
			Hei	= 20
		case ID_VOLCANIC:
			BaseFrame = 173
			NumFrames = 1
			Wid = 20
			Hei	= 20
		case ID_MISSILE:
			BaseFrame = 189
			NumFrames = 3 
			Wid = 12
			Hei	= 12
		case ID_BLADE:
			BaseFrame = 192
			NumFrames = 1 
			Wid = 20
			Hei	= 20
	end select
	
end sub

	
sub Bullet.Spawn( byval ix as integer, byval iy as integer,_
				  byval iangle as integer, byval ispeed as single,_
			      byval iState as integer = STATE_NORMAL, byval iType as integer = ID_DEFAULT )
					   
	State = iState
	ID = iType
	
	Active = TRUE
	Counter = 0 
	BounceCount = 0
	
	x = ix
	y = iy
 
 	Angle = iAngle
 	Dx = cos(DEG2RAD(Angle)) * iSpeed
	Dy = sin(DEG2RAD(Angle)) * iSpeed
 
	
	Frame = 0
	ResolveAnimationParameters()
	
	BoxNormal.Init( x, y, wid, Hei)
	

End Sub


sub Bullet.Update( byref Snipe as Player, Map() as TileType )
	
	Counter += 1
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	
	select case State
		case STATE_NORMAL:
			ActionNormal( Map() )
		case STATE_BOUNCE:
			ActionBounce( Map() )
		case STATE_GRAVITY:
			ActionGravity( Map() )
		case STATE_GRAVITY_BOUNCE:
			ActionGravityBounce( Map() )
	end select
	
	if( abs(((Snipe.GetCameraX + SCREEN_WIDTH\2)\TILE_SIZE) - (x \ TILE_SIZE)) > 12   ) then
		Kill()
	endif
	
	if( Active ) then BoxNormal.Init( x-Wid\2, y-Hei\2, Wid, Hei )
	 		
End Sub


sub Bullet.Explode()
	
	Explosion.Spawn( Vector3D(x, y, 2), Vector3D(0, 0, 0), Explosion.TINY_YELLOW_01 )
	
	Kill()
	
End Sub

sub Bullet.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub Bullet.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	
	select case ID
		case ID_ARROW:
			GL2D.SpriteRotateScaleXY3D( x, y, 4, Angle, 1, 1, FlipMode, SpriteSet( BaseFrame + Frame ) )
		case ID_MISSILE:
			GL2D.SpriteRotateScaleXY3D( x, y, 4, Angle, 1, 1, FlipMode, SpriteSet( BaseFrame + Frame ) )
		case else
			GL2D.SpriteRotateScaleXY3D( x, y, 4, 0, 1, 1, FlipMode, SpriteSet( BaseFrame + Frame ) )
	end select
	
	
End Sub

sub Bullet.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


sub Bullet.CollideWithPlayer( byref Snipe as Player )
	
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxNormal.Intersects(Box) ) then
			Snipe.HitAnimation( x, 45 )
		endif		
	endif
	
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************


function Bullet.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' BulletFactory
''
''*****************************************************************************

constructor BulletFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Bullets)
		Bullets(i).Kill()
	Next
	
End Constructor

destructor BulletFactory()

End Destructor

property BulletFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property BulletFactory.GetMaxEntities() as integer
	property = ubound(Bullets)
end property 

sub BulletFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Bullets)
		if( Bullets(i).IsActive ) then
			Bullets(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub BulletFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Bullets)
		if( Bullets(i).IsActive ) then
			Bullets(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub BulletFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Bullets)
		if( Bullets(i).IsActive ) then
			Bullets(i).DrawAABB()
		EndIf
	Next
	
end sub

sub BulletFactory.ExplodeAllEntities()
	
	for i as integer = 0 to ubound(Bullets)
		if( Bullets(i).IsActive ) then
			Bullets(i).Explode()
			Bullets(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub BulletFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Bullets)
		if( Bullets(i).IsActive ) then
			Bullets(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub BulletFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(Bullets)
		
		if( Bullets(i).IsActive ) then
			Bullets(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub BulletFactory.Spawn( byval ix as integer, byval iy as integer,_
					   	 byval angle as integer, byval ispeed as single,_
					   	 byval iState as integer = Bullet.STATE_NORMAL, byval iType as integer = Bullet.ID_DEFAULT )
	
	for i as integer = 0 to ubound(Bullets)
		if( Bullets(i).IsActive = FALSE ) then
			Bullets(i).Spawn( ix, iy, angle, ispeed, iState, iType )
			exit for
		EndIf
	Next
	
end sub

function BulletFactory.GetAABB( byval i as integer ) as AABB
	
	return Bullets(i).GetBox
	
End Function
	