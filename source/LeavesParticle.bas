''*****************************************************************************
''
''
''	Pyromax Dax Leavesparticle Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "LeavesParticle.bi"


namespace LeavesParticle

#define MAX_LEAVESPARTICLES 255

dim shared as single WindDirection = 0


type Leaf

public:

	declare constructor()
	declare sub Spawn ( byref Posi as Vector2D, byval spd as single, byval ang as integer, byval ID as integer )
	declare sub Update()

	
	as integer	Active
	
	as integer  Counter
	as integer  Frame
	as integer  BaseFrame
	as integer  NumFrames
	
	as GL2D.GL2D_FLIP_MODE FlipMode	
	
	as Vector2D Position
	as Vector2D Direction
	
	as integer	ID
	
End Type

''*****************************************************************************
''
''
''
''*****************************************************************************
constructor Leaf()
	
	Active = FALSE
	ID = 0
	Counter = 0
	Frame = 0
	BaseFrame = 0
	FlipMode = GL2D.FLIP_NONE
	
End Constructor


sub Leaf.Spawn ( byref Posi as Vector2D, byval spd as single, byval ang as integer, byval sID as integer )
	
	Active = TRUE
	Position = Posi
	Direction = Type<Vector2D>( cos(DEG2RAD(ang)), sin(DEG2RAD(ang))) * spd
	
	ID = sID
	
	Counter = 0
	Frame = rnd * 12
	BaseFrame = 95
	NumFrames = 12
	FlipMode = GL2D.FLIP_NONE
	
	Frame = Frame mod NumFrames
		
End Sub

sub Leaf.Update()
	
	Counter += 1
	if( (Counter and 3) = 0) then
		Frame = (Frame + 1) mod NumFrames
	EndIf
	
	
	Position += Direction
	Position.x += WindDirection
	
	Position.x = UTIL.Wrap( Position.x, 0.0, cast(single,SCREEN_WIDTH) )
	Position.y = UTIL.Wrap( Position.y, 0.0, cast(single,SCREEN_HEIGHT) )
	
end sub

''*****************************************************************************
''
''
''
''*****************************************************************************	
dim as Leaf LeavesParticles( MAX_LEAVESPARTICLES )
dim as GL2D.IMAGE ptr LeavesParticlesImages()
dim as integer ActiveLeavesParticles = 0
dim as single Interpolator = 0
dim as single FinalWindDirection = 0

function GetWindFactor() as single
	return WindDirection * 0.35
end function

sub ChangeWindDirection( byval d as integer )
	
	 if( d < 0 ) then
	 	Interpolator = 0
	 	FinalWindDirection = -5
	 elseif( d > 0 ) then
	 	Interpolator = 0
	 	FinalWindDirection = 6
	 else
	 	Interpolator = 0
	 	FinalWindDirection = 0
	 endif
	 
end sub 

sub SetWindDirection( byval v as single )
	WindDirection = v
end sub
''*****************************************************************************
''
''
''
''*****************************************************************************	
sub Init( byref filename as string )

	ActiveLeavesParticles = 0
	GL2D.InitSprites( LeavesParticlesImages(), explosions_sprite_texcoords(),filename, GL_NEAREST )
	KillAll()
	
	Interpolator = 0
	FinalWindDirection = 0
	WindDirection = 0
	
End Sub


sub Spawn( byref Posi as Vector2D, byval spd as single, byval ang as integer, byval ID as integer )
	
	for i as integer = 0 to MAX_LEAVESPARTICLES
		if( LeavesParticles(i).Active = FALSE ) then
			LeavesParticles(i).Spawn( Posi, spd, ang, ID )
			exit for
		endif
	next i
	
End Sub

sub SpawnAll( byval wid as integer, byval Hei as integer )
	
	KillAll()
	
	for i as integer = 0 to MAX_LEAVESPARTICLES
		if( LeavesParticles(i).Active = FALSE ) then
			dim as Vector2D Posi = Vector2D( rnd * Wid, rnd * Hei )
			dim as single spd = 1 + rnd * 3
			dim as integer ang = 90 + rnd * 50
			LeavesParticles(i).Spawn( Posi, spd, ang, 0 )
		endif
	next i

end sub

sub Update( byval UpdateDirection as integer = TRUE )
	
	if( UpdateDirection ) then
		if( InterPolator <= 1 ) then InterPolator += 0.0021
		WindDirection = UTIL.LerpSmooth( WindDirection, FinalWindDirection, SMOOTH_STEP(Interpolator) )
	endif
	
	ActiveLeavesParticles = 0
	for i as integer = 0 to MAX_LEAVESPARTICLES
		if( LeavesParticles(i).Active ) then
			LeavesParticles(i).Update()
			ActiveLeavesParticles += 1
		endif
	next i
	
End Sub
	
sub KillAll()
	
	for i as integer = 0 to MAX_LEAVESPARTICLES
		if( LeavesParticles(i).Active ) then
			LeavesParticles(i).Active = FALSE
		endif
	next i
	
	ActiveLeavesParticles = 0
	
End Sub

sub DrawAll()
	
	glColor4f( 0.45, 0.45, 0, 1 )
	for i as integer = 0 to MAX_LEAVESPARTICLES
		if( LeavesParticles(i).Active ) then
			GL2D.SpriteRotateScaleXY( LeavesParticles(i).Position.x,_
									  LeavesParticles(i).Position.y,_
									  0,_
									  1,_
									  1,_
									  LeavesParticles(i).FlipMode,_
									  LeavesParticlesImages( LeavesParticles(i).BaseFrame + LeavesParticles(i).Frame ) )
		endif
	next i
	glColor4f( 1, 1, 1, 1 )
			
End Sub

sub ResetAll()
	
	Interpolator = 0
	FinalWindDirection = 0
	WindDirection = 0
	
end sub

sub Release()
	
	GL2D.DestroySprites( LeavesParticlesImages() )
	
End Sub

End Namespace
