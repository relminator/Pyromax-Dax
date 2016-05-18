''*****************************************************************************
''
''
''	Pyromax Dax Nail Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Nail.bi"


constructor Nail()

	Active = FALSE
	Counter = 0 
	FlipMode = GL2D.FLIP_NONE
	Orientation = ORIENTATION_BOTTOM
	
	x = 0
	y = 0
	Dx = 0
	Dy = 0
	Yorig = 0
	Radius = 38

	Frame = 0
	BaseFrame = 118
	NumFrames = 6
	
	Wid = 12
	Hei	= 38
	
	BoxNormal.Init( x, y, wid, Hei)
	
End Constructor

destructor Nail()

End Destructor


property Nail.IsActive() as integer
	property = Active
End Property
		
property Nail.GetX() as single
	property = x
End Property

property Nail.GetY() as single
	property = y
End Property

property Nail.GetDrawFrame() as integer
	property = (BaseFrame + Frame)
End Property

property Nail.GetBox() as AABB
	property = BoxNormal
End Property


	
sub Nail.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )
	
	Active = TRUE
	Counter = rnd * 10000 
	Orientation = iOrientation
	if( Orientation = ORIENTATION_BOTTOM ) then
		FlipMode = GL2D.FLIP_NONE
		Yorig = iy - 4
	else
		FlipMode = GL2D.FLIP_V
		Yorig = iy - 8 - TILE_SIZE
	endif
	
	Radius = 38
	Speed = 0.3 + rnd
	
	x = ix + TILE_SIZE\2 - 3
	y = Yorig + abs(sin(DEG2RAD(Counter/2))) * Radius
 
	
	Dx = 0
	Dy = 0
	
	Frame = 0
	BaseFrame = 118
	NumFrames = 6
	
	Wid = 12
	Hei	= 38

	BoxNormal.Init( x, y, wid, Hei)
	

End Sub


sub Nail.Update( byref Snipe as Player, Map() as TileType )
	
	if( (abs(x - (Snipe.GetCameraX + SCREEN_WIDTH\2)) \ TILE_SIZE) > 12  ) then return
	
	Counter + = 1
	
	if( (Counter and 3) = 0 ) then
		Frame = ( Frame + 1 ) mod NumFrames
	endif	
	
	y = Yorig + abs(sin(DEG2RAD(Counter * Speed))) * Radius

	BoxNormal.Init( x, y, wid, Hei)
	 
			
End Sub


sub Nail.Explode()
	
	Explosion.Spawn( Vector3D(x + Wid\2, y + Hei\2, 2), Vector3D(0, 0, 0), Explosion.MEDIUM_YELLOW_01 )
	
	Kill()
	
End Sub

sub Nail.Kill()
	
	Active = FALSE
	x = 0
	y = 0
	
	BoxNormal.Init( -10000, -1000, wid, Hei)
	
End Sub

sub Nail.Draw( SpriteSet() as GL2D.IMAGE ptr )
	
	
	GL2D.Sprite( x, y, FlipMode, SpriteSet( BaseFrame + Frame ) )
	
End Sub

sub Nail.DrawAABB()
	
	BoxNormal.Draw( 4, GL2D_RGB( 255, 0, 255 ) )
	
end sub


sub Nail.CollideWithPlayer( byref Snipe as Player )
	
	
	if( (not Snipe.IsDead) and (not Snipe.IsInvincible) ) then	
		dim as AABB Box = Snipe.GetBoxSmall
		if( BoxNormal.Intersects(Box) ) then
			Snipe.HitAnimation( x, 45 )
		endif		
	endif
	
	dim as integer AttackEnergy = 0
	
	AttackEnergy = Snipe.CollideShots( BoxNormal )
	'if( AttackEnergy ) then
	'	Explode()
	'endif
	
	AttackEnergy = Snipe.CollideBombs( BoxNormal )
	'if( AttackEnergy ) then
	'	Explode()
	'endif
	
	AttackEnergy = Snipe.CollideDynamites( BoxNormal )
	'if( AttackEnergy ) then
	'	Explode()
	'endif
	
	AttackEnergy = Snipe.CollideMines( BoxNormal )
	'if( AttackEnergy ) then
	'	Explode()
	'endif
	
End Sub

''*****************************************************************************
'' Collides the object box with the tiles on the y-axis
''*****************************************************************************


function Nail.CollideWithAABB( byref Box as const AABB ) as integer

	if( BoxNormal.Intersects( Box ) ) then
		return TRUE
	EndIf

	return FALSE

End Function



''*****************************************************************************
''
'' NailFactory
''
''*****************************************************************************

constructor NailFactory()

	ActiveEntities = 0
	
	for i as integer = 0 to ubound(Nails)
		Nails(i).Kill()
	Next
	
End Constructor

destructor NailFactory()

End Destructor

property NailFactory.GetActiveEntities() as integer
	property = ActiveEntities
end property 

property NailFactory.GetMaxEntities() as integer
	property = ubound(Nails)
end property 

sub NailFactory.UpdateEntities( byref Snipe as Player, Map() as TileType )
	
	ActiveEntities = 0
	for i as integer = 0 to ubound(Nails)
		if( Nails(i).IsActive ) then
			Nails(i).Update( Snipe, Map() )
			ActiveEntities += 1
		EndIf
	Next
	
end sub

sub NailFactory.DrawEntities( SpriteSet() as GL2D.IMAGE ptr )
	
	for i as integer = 0 to ubound(Nails)
		if( Nails(i).IsActive ) then
			Nails(i).Draw( SpriteSet() )
		EndIf
	Next
	
end sub

sub NailFactory.DrawCollisionBoxes()
	
	for i as integer = 0 to ubound(Nails)
		if( Nails(i).IsActive ) then
			Nails(i).DrawAABB()
		EndIf
	Next
	
end sub

sub NailFactory.KillAllEntities()
	
	for i as integer = 0 to ubound(Nails)
		if( Nails(i).IsActive ) then
			Nails(i).Kill()
		EndIf
	Next
	ActiveEntities = 0
	
end sub

sub NailFactory.HandleCollisions( byref Snipe as Player )
	
	for i as integer = 0 to ubound(Nails)
		
		if( Nails(i).IsActive ) then
			Nails(i).CollideWithPlayer( Snipe )
		endif
		
	Next i
	
	
end sub

sub NailFactory.Spawn( byval ix as integer, byval iy as integer, byval iOrientation as integer )

	
	for i as integer = 0 to ubound(Nails)
		if( Nails(i).IsActive = FALSE ) then
			Nails(i).Spawn( ix, iy, iOrientation )
			exit for
		EndIf
	Next
	
end sub

function NailFactory.GetAABB( byval i as integer ) as AABB
	
	return Nails(i).GetBox
	
End Function
	