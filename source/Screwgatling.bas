''*****************************************************************************
''
''
''	Pyromax Dax ScrewGatling Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Screwgatling.bi"

const as integer MAX_IDLE_COUNTER = 60
const as integer MAX_FIRE_COUNTER = 190

constructor Screwgatling()

	Active = FALSE
	Counter = 0 
	Orientation = FLOOR
	State = STATE_IDLE
	Idlecounter = MAX_IDLE_COUNTER
	Firecounter = MAX_FIRE_COUNTER
	
	x = 0
	y = 0
	

	Frame = 0
	BaseFrame = 163
	NumFrames = 1
	
	Wid = 24
	Hei	= 24
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor Screwgatling()

End Destructor


property Screwgatling.IsActive() as integer
	property = Active
End Property
		
property Screwgatling.GetX() as single
	property = x
End Property

property Screwgatling.GetY() as single
	property = y
End Property

property Screwgatling.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Screwgatling.GetBox() as AABB
	property = BoxNormal
End Property

''*****************************************************************************
''
''*****************************************************************************
sub Screwgatling.ActionIdle( Map() as TileType )
	
	Idlecounter -= 1
	if( Idlecounter <= 0 ) then
		State = STATE_SCREW_UP
		Idlecounter = MAX_IDLE_COUNTER + (rnd * MAX_IDLE_COUNTER * 4)
		ResolveAnimationParameters()	
	endif
	
end sub

sub Screwgatling.ActionScrewUp( Map() as TileType )
	
	if( (Counter and 3) = 0 ) then
		Frame += 1
		if( Frame > NumFrames ) then
			State = STATE_FIRE
			ResolveAnimationParameters()
			Idlecounter = MAX_IDLE_COUNTER + (rnd * MAX_IDLE_COUNTER * 4)
			Firecounter = MAX_FIRE_COUNTER
		endif
	endif	
	

end sub

sub Screwgatling.ActionScrewDown( Map() as TileType )
	
	if( (Counter and 3) = 0 ) then
		Frame += 1
		if( Frame > NumFrames ) then
			State = STATE_IDLE
			ResolveAnimationParameters()
			Idlecounter = MAX_IDLE_COUNTER + (rnd * MAX_IDLE_COUNTER * 4)
			Firecounter = MAX_FIRE_COUNTER
		endif
	endif	
	
	
end sub

sub Screwgatling.ActionFire( Map() as TileType, byref Bullets as BulletFactory )

	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	Firecounter -= 1
	if( (Firecounter and 63) = 0 ) then
		Sound.PlaySFX( Sound.SFX_ENEMY_SHOT_02 )
		if( Orientation = FLOOR ) then
			Bullets.Spawn( x + Wid, y + 5, 0, 5.5, Bullet.STATE_GRAVITY_BOUNCE, Bullet.ID_DEFAULT )
			Bullets.Spawn( x, y + 5, 180, 5.5, Bullet.STATE_GRAVITY_BOUNCE, Bullet.ID_DEFAULT )
		else
			Bullets.Spawn( x + Wid, y + Hei - 5, 360 - 20, 5.5 , Bullet.STATE_GRAVITY_BOUNCE, Bullet.ID_DEFAULT )
			Bullets.Spawn( x, y + Hei - 5, 180 + 20, 5.5, Bullet.STATE_GRAVITY_BOUNCE, Bullet.ID_DEFAULT )
		endif
		
	endif
	
	if( Firecounter <= 0 ) then
		State = STATE_SCREW_DOWN
		Firecounter = MAX_FIRE_COUNTER
		ResolveAnimationParameters()	
	endif
	
end sub


	
sub Screwgatling.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = 0 
	Idlecounter = MAX_IDLE_COUNTER + (rnd * MAX_IDLE_COUNTER * 4)
	Firecounter = MAX_FIRE_COUNTER + (rnd * MAX_FIRE_COUNTER * 4)
	BlinkCounter = -1
	Hp = 100
	
	Orientation = iOrientation
	State = STATE_IDLE
	
	x = ix + TILE_SIZE \ 5
	if( Orientation = FLOOR ) then
		FlipMode = GL2D.FLIP_NONE
		y = iy + 1 + TILE_SIZE \ 4	
	else
		FlipMode = GL2D.FLIP_V
		y = iy + 1
	endif
	
	
	
	Frame = 0
	BaseFrame = 163
	NumFrames = 1
	
	Wid = 22
	Hei	= 22
	
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Sub


sub Screwgatling.Update( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 12  ) then return
	
	Counter += 1
	
	if( BlinkCounter > 0 ) then
		BlinkCounter -= 1
	endif
	
	select case State
		case STATE_IDLE:
			ActionIdle( Map() )
			if( Orientation = FLOOR ) then
				BoxNormal.Init( x, y + 10, wid, Hei)
			else	
				BoxNormal.Init( x, y, wid, Hei - 10)
			endif
			dim as single Dist = ((Snipe.GetX - x) ^ 2)  + ((Snipe.GetY - y) ^ 2)
			if( Dist > (( TILE_SIZE * 9) ^ 2) ) then
				Idlecounter = MAX_IDLE_COUNTER
			endif
		case STATE_SCREW_UP:
			ActionScrewUp( Map() )
			if( Orientation = FLOOR ) then
				BoxNormal.Init( x, y + 5, wid, Hei)
			else	
				BoxNormal.Init( x, y, wid, Hei - 5)
			endif
		case STATE_SCREW_DOWN:
			ActionScrewDown( Map() )
			if( Orientation = FLOOR ) then
				BoxNormal.Init( x, y + 5, wid, Hei)
			else	
				BoxNormal.Init( x, y, wid, Hei - 5)
			endif
		case STATE_FIRE:
			ActionFire( Map(), Bullets )
			BoxNormal.Init( x, y, wid, Hei)
	end select	
	
	 
			
end sub

sub Screwgatling.ResolveAnimationParameters()
	
	select case State
		case STATE_IDLE:
			Frame = 0
			BaseFrame = 163
			NumFrames = 1		
		case STATE_SCREW_UP:
			Frame = 0
			BaseFrame = 163
			NumFrames = 3
		case STATE_SCREW_DOWN:
			Frame = 0
			BaseFrame = 169
			NumFrames = 3
		case STATE_FIRE:
			Frame = 0
			BaseFrame = 166
			NumFrames = 4
	end select	
	
end sub

sub Screwgatling.Explode()
	
	Explosion.SpawnMulti( Vector3D(x + Wid\2, y + Hei\2, 2), 2, rnd * 360, Explosion.MEDIUM_YELLOW_03, Explosion.SMOKE_02, 4 )	
	
	Kill()
	
End Sub

sub Screwgatling.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub Screwgatling.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	if( (BlinkCounter > 0)  and ((BlinkCounter and 3) = 0) ) then
		GL2D.EnableSpriteStencil( TRUE, GL2D_RGBA(255,255,255,255), GL2D_RGBA(255,255,255,255) )
		GL2D.Sprite3D( x - 2, y - 2, -4, FlipMode, SpriteSet( BaseFrame + Frame ) )
		GL2D.EnableSpriteStencil( FALSE )
	else	
		GL2D.Sprite3D( x - 2, y - 2, -4, FlipMode, SpriteSet( BaseFrame + Frame ) )
	endif
	
End Sub

sub Screwgatling.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


sub Screwgatling.CollideWithPlayer( byref Snipe as Player )
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxNormal.Intersects(Box) ) then
			Snipe.HitAnimation( x, 65 )
		endif		
	endif
	
	dim as integer AttackEnergy = 0
	
	AttackEnergy = Snipe.CollideShots( BoxNormal )
	if( AttackEnergy ) then
		Hp -= 26
		BlinkCounter = MAX_ENEMY_BLINK_COUNTER
		if( Hp <= 0 ) then
			Explode()
			Snipe.AddToScore( 301 )
		endif
	endif
	
	AttackEnergy = Snipe.CollideBombs( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 301 )
	endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 301 )
	endif
	
	AttackEnergy = Snipe.CollideMines( BoxNormal )
	if( AttackEnergy ) then
		Explode()
		Snipe.AddToScore( 301 )
	endif
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************



function Screwgatling.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' ScrewgatlingFactory
''
''*****************************************************************************

constructor ScrewgatlingFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Screwgatlings)
		Screwgatlings(i).Kill()
	Next
	
End Constructor

destructor ScrewgatlingFactory()

End Destructor

property ScrewgatlingFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property ScrewgatlingFactory.GetMaxEntities() as integer
	property = ubound(Screwgatlings)
end property 

sub ScrewgatlingFactory.UpdateEntities( byref Snipe as Player, byref Bullets as BulletFactory, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Screwgatlings)
		if( Screwgatlings(i).IsActive ) then
			Screwgatlings(i).Update( Snipe, Bullets, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub ScrewgatlingFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Screwgatlings)
		if( Screwgatlings(i).IsActive ) then
			Screwgatlings(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub ScrewgatlingFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Screwgatlings)
		if( Screwgatlings(i).IsActive ) then
			Screwgatlings(i).DrawAABB()
		EndIf
	Next
	
end sub

sub ScrewgatlingFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Screwgatlings)
		if( Screwgatlings(i).IsActive ) then
			Screwgatlings(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub ScrewgatlingFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(Screwgatlings)
		
		if( Screwgatlings(i).IsActive ) then
			Screwgatlings(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub ScrewgatlingFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(Screwgatlings)
		if( Screwgatlings(i).IsActive = FALSE ) then
			Screwgatlings(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function ScrewgatlingFactory.GetAABB( byval i as integer ) as AABB
	
	return Screwgatlings(i).GetBox
	
End Function
	