''*****************************************************************************
''
''
''	Pyromax Dax Explosion (simulates a singleton) Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Explosion.bi"


namespace Explosion

#define MAX_EXPLOSIONS 511

'' BaseFrame, NumFrames
dim as integer AtlasIndex(15,1) =>_
{	{  0,  8 },_		'ATOMIC				0
	{  8,  4 },_		'SHOT_BURST_SMALL	1
	{ 12,  4 },_		'SHOT_BURST_BIG		2
	{ 16,  8 },_		'SMOKE_01			3
	{ 24,  6 },_		'INVINCIBILITY		4
	{ 30,  4 },_		'MEDIUM_BLUE_01		5
	{ 34,  6 },_		'MEDIUM_YELLOW_01	6
	{ 40,  8 },_		'TINY_YELLOW_01		7
	{ 48,  5 },_		'MEDIUM_YELLOW_02	8
	{ 53,  5 },_		'TINY_YELLOW_02		9
	{ 58,  4 },_		'MEDIUM_BLUE_02		10
	{ 62,  7 },_		'BIG_YELLOW			11
	{ 69, 13 },_		'MEDIUM_YELLOW_03	12
	{ 82, 13 },_		'MEDIUM_BLUE_03		13
	{ 95, 12 },_		'TWINKLE			14
	{ 107, 8 } 	} 		'SMOKE_02			15


type Explode

public:

	declare constructor()
	declare sub Spawn overload( byref Posi as Vector3D, byref Dire as Vector3D, byval ID as integer, byval xFlipMode as GL2D.GL2D_FLIP_MODE = GL2D.FLIP_NONE )
	declare sub Spawn overload( byref Posi as Vector3D, byval spd as single, byval ang as integer, byval ID as integer, byval xFlipMode as GL2D.GL2D_FLIP_MODE = GL2D.FLIP_NONE )
	declare sub Update()

	
	as integer	Active
	
	as integer  Counter
	as integer  Frame
	as integer  BaseFrame
	as integer  NumFrames
	as GL2D.GL2D_FLIP_MODE FlipMode	
	as Vector3D Position
	as Vector3D Direction
	
	as integer	ID
	
End Type

''*****************************************************************************
''
''
''
''*****************************************************************************
constructor Explode()
	Active = FALSE
	ID = SMOKE_01
	Counter = 0
	Frame = 0
	BaseFrame = 0
	FlipMode = GL2D.FLIP_NONE
	
End Constructor

sub Explode.Spawn overload( byref Posi as Vector3D, byref Dire as Vector3D, byval sID as integer, byval xFlipMode as GL2D.GL2D_FLIP_MODE = GL2D.FLIP_NONE )
	
	Active = TRUE

	Position = Posi
	Direction = Dire
	
	ID = sID
	
	Counter = 0
	Frame = 0
	BaseFrame = AtlasIndex(ID,0)
	NumFrames = AtlasIndex(ID,1)
	FlipMode = xFlipMode
	
End Sub

sub Explode.Spawn overload( byref Posi as Vector3D, byval spd as single, byval ang as integer, byval sID as integer, byval xFlipMode as GL2D.GL2D_FLIP_MODE = GL2D.FLIP_NONE )
	
	Active = TRUE
	Position = Posi
	Direction = Type<Vector3D>( cos(DEG2RAD(ang)), sin(DEG2RAD(ang)), 0 ) * spd
	
	ID = sID
	
	Counter = 0
	Frame = 0
	BaseFrame = AtlasIndex(ID,0)
	NumFrames = AtlasIndex(ID,1)
	FlipMode = xFlipMode
	
		
End Sub

sub Explode.Update()
	
	Counter += 1
	if( (Counter and 3) = 0) then
		Frame += 1
	EndIf
	
	if( Frame >= NumFrames ) then
		Active = FALSE
	endif
	
	Position += Direction
	
end sub

''*****************************************************************************
''
''
''
''*****************************************************************************	
dim as Explode Explosions( MAX_EXPLOSIONS )
dim as GL2D.IMAGE ptr ExplosionsImages()
dim as integer ActiveExplosions = 0
''*****************************************************************************
''
''
''
''*****************************************************************************	
sub Init( byref filename as string )

	ActiveExplosions = 0
	GL2D.InitSprites( ExplosionsImages(), explosions_sprite_texcoords(),filename, GL_NEAREST )
	KillAll()
	
End Sub

sub Spawn overload( byref Posi as Vector3D, byref Dire as Vector3D, byval ID as integer, byval xFlipMode as GL2D.GL2D_FLIP_MODE = GL2D.FLIP_NONE )
	
	for i as integer = 0 to MAX_EXPLOSIONS
		if( Explosions(i).Active = FALSE ) then
			Explosions(i).Spawn( Posi, Dire, ID, xFlipMode )
			exit for
		endif
	next i
	
End Sub

sub Spawn overload( byref Posi as Vector3D, byval spd as single, byval ang as integer, byval ID as integer, byval xFlipMode as GL2D.GL2D_FLIP_MODE = GL2D.FLIP_NONE )
	
	for i as integer = 0 to MAX_EXPLOSIONS
		if( Explosions(i).Active = FALSE ) then
			Explosions(i).Spawn( Posi, spd, ang, ID, xFlipMode )
			exit for
		endif
	next i
	
End Sub

sub Spawn overload( byref Posi as Vector3D, byval NumExplosions as integer )
	
	for j as integer = 0 to NumExplosions - 1
		for i as integer = 0 to MAX_EXPLOSIONS
			if( Explosions(i).Active = FALSE ) then
				dim as integer ang = rnd * 360
				dim as integer ID = (rnd * 14)
				Explosions(i).Spawn( Posi, rnd * 20, ang, ID )
				exit for
			endif
		next i
	next j
	
End Sub

sub SpawnMulti( byref Posi as Vector3D, byval spd as single, byval ang as integer, byval ID1 as integer, byval ID2 as integer, byval NumBranches as integer = 4 )

	Explosion.Spawn( Posi, Vector3D(0, 0, 0), ID1 )
	dim as integer Delta = 360 \ NumBranches
	for i as integer = 1 to NumBranches 
		Explosion.Spawn( Posi, spd, UTIL.WRAP(ang + (Delta\2) + Delta * i , 0, 359), ID2 )
	next
		
end sub


sub Update()
	
	ActiveExplosions = 0
	for i as integer = 0 to MAX_EXPLOSIONS
		if( Explosions(i).Active ) then
			Explosions(i).Update()
			ActiveExplosions += 1
		endif
	next i
	
End Sub
	
sub KillAll()
	
	for i as integer = 0 to MAX_EXPLOSIONS
		if( Explosions(i).Active ) then
			Explosions(i).Active = FALSE
		endif
	next i
	
	ActiveExplosions = 0
	
End Sub

sub DrawAll()
	
	for i as integer = 0 to MAX_EXPLOSIONS
		if( Explosions(i).Active ) then
			GL2D.SpriteRotateScaleXY3D( Explosions(i).Position.x,_
									  Explosions(i).Position.y,_
									  Explosions(i).Position.z,_
									  0,_
									  1,_
									  1,_
									  Explosions(i).FlipMode,_
									  ExplosionsImages( Explosions(i).BaseFrame + Explosions(i).Frame ) )
		endif
	next i
			
End Sub


sub Release()
	
	GL2D.DestroySprites( ExplosionsImages() )
	
End Sub

End Namespace
