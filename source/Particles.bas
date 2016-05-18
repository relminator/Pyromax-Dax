''*****************************************************************************
''
''
''	Pyromax Dax Particle Module
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Particles.bi"


namespace Particle

#define MAX_PARTICLES 511



type Part

public:

	declare constructor()
	declare sub Spawn overload( byref Posi as Vector3D, byref Dire as Vector3D, byval ID as integer )
	declare sub Spawn overload( byref Posi as Vector3D, byval ang as integer, byval ID as integer )
	declare sub Spawn overload( byref Posi as Vector3D, byval Dire as Vector3D, byval spd as single, byval ID as integer )
	declare sub Update()

	
	as integer	Active
	as single	Speed
	
	as integer	TimeActive
	as integer	Tima
	
	as integer	Red
	as integer	Green
	as integer	Blue
	as single	Alpa 
	as integer  Angle	
	
	as Vector3D Position
	as Vector3D Direction
	
	as integer	DeathID
	
End Type

''*****************************************************************************
''
''
''
''*****************************************************************************
constructor Part()
	Active = FALSE
	Speed = 8		'' 400 pixels per second
	TimeActive = 60	'' 1 second 
	Tima = 0		'' 
	DeathID = TINY
End Constructor

sub Part.Spawn overload( byref Posi as Vector3D, byref Dire as Vector3D, byval ID as integer )
	
	Active = TRUE
	Speed = rnd * (10 + int(ID) * 10) + Rnd * ( 10 + int(ID) * 10)	'' 100 pixels per second
	Tima = 0		 
	Angle = RAD2DEG( atan2( Dire.y, Dire.x ) )
	Position = Posi
	Direction = Dire
	
	DeathID = ID
	TimeActive = 20 + RND *( 120 )	 
	
	select case( DeathID )
		case TINY:
			Red = 200
			Green = 200
			Blue = 0
			Alpa = 255
		case MEDIUM:
			Red = rnd * 255
			Green = rnd * 255
			Blue = rnd * 255
			Alpa = 255
		case LARGE:
			Red = rnd * 255
			Green = rnd * 255
			Blue = rnd * 255
			Alpa = 255
		case else
			Red = rnd * 255
			Green = rnd * 255
			Blue = rnd * 255
			Alpa = 255
	end select
		
End Sub

sub Part.Spawn overload( byref Posi as Vector3D, byval ang as integer, byval ID as integer )
	
	Active = TRUE
	Speed = rnd * (10 + int(ID) * 10) + Rnd * ( 10 + int(ID) * 10)
	Tima = 0		 
	
	Position = Posi
	Angle = ang
	Direction = Type<Vector3D>( cos(DEG2RAD(Angle)), sin(DEG2RAD(Angle)), 0 )
	
	DeathID = ID
	TimeActive = 20 + RND * ( 120 )	 
	
	select case( DeathID )
		case TINY:
			Red = 200
			Green = 200
			Blue = 0
			Alpa = 255
		case MEDIUM:
			Red = rnd * 255
			Green = rnd * 255
			Blue = rnd * 255
			Alpa = 255
		case LARGE:
			Red = rnd * 255
			Green = rnd * 255
			Blue = rnd * 255
			Alpa = 255
		case else
			Red = rnd * 255
			Green = rnd * 255
			Blue = rnd * 255
			Alpa = 255
	end select
		
End Sub

sub Part.Spawn overload( byref Posi as Vector3D, byval Dire as Vector3D, byval spd as single, byval ID as integer )
	
	Active = TRUE
	Speed = spd
	Tima = 0		 
	
	Position = Posi
	Direction = Dire
	Angle = RAD2DEG( atan2( Dire.y, Dire.x ) ) 
	
	DeathID = ID
	TimeActive = ( 120 )	 
	
	select case( DeathID )
		case TINY:
			Red = 200
			Green = 200
			Blue = 0
			Alpa = 255
		case MEDIUM:
			Red = rnd * 255
			Green = rnd * 255
			Blue = rnd * 255
			Alpa = 255
		case LARGE:
			Red = rnd * 255
			Green = rnd * 255
			Blue = rnd * 255
			Alpa = 255
		case else
			Red = rnd * 255
			Green = rnd * 255
			Blue = rnd * 255
			Alpa = 255
	end select

end sub

sub Part.Update()
	
	Position += (Direction * Speed)
	
	Alpa -= 10
	if( Alpa < 0 ) then Alpa = 0
	
	
	Tima += 1
	
	if( Tima >= TimeActive ) then
		Active = FALSE
	endif
	
end sub

''*****************************************************************************
''
''
''
''*****************************************************************************	
dim as Part Particles( MAX_PARTICLES )
dim as GL2D.IMAGE ptr FlareImage
dim as integer ActiveParticles = 0

''*****************************************************************************
''
''
''
''*****************************************************************************	
sub Init( byref filename as string )

	ActiveParticles = 0
	FlareImage = GL2D.LoadBmpToGLsprite( filename, GL_LINEAR )
	KillAll()
	
End Sub

sub Spawn overload( byref Posi as Vector3D, byref Dire as Vector3D, byval ID as integer )
	
	for i as integer = 0 to MAX_PARTICLES
		if( Particles(i).Active = FALSE ) then
			Particles(i).Spawn( Posi, Dire, ID )
			exit for
		endif
	next i
	
End Sub

sub Spawn overload( byref Posi as Vector3D, byval ang as integer, byval ID as integer )
	
	for i as integer = 0 to MAX_PARTICLES
		if( Particles(i).Active = FALSE ) then
			Particles(i).Spawn( Posi, ang, ID )
			exit for
		endif
	next i
	
End Sub

sub Spawn overload( byref Posi as Vector3D, byval NumParticles as integer )
	
	for j as integer = 0 to NumParticles - 1
		for i as integer = 0 to MAX_PARTICLES
			if( Particles(i).Active = FALSE ) then
				dim as integer ang = rnd * 360
				dim as integer ID = int(rnd * 3)
				Particles(i).Spawn( Posi, ang, ID )
				exit for
			endif
		next i
	next j
	
End Sub

sub Spawn overload( byref Posi as Vector3D, byval Dire as Vector3D, byval spd as single, byval ID as integer )
	
	for i as integer = 0 to MAX_PARTICLES
		if( Particles(i).Active = FALSE ) then
			Particles(i).Spawn( Posi, Dire, spd, ID )
			exit for
		endif
	next i
	
End Sub

sub Update()
	
	ActiveParticles = 0
	for i as integer = 0 to MAX_PARTICLES
		if( Particles(i).Active ) then
			Particles(i).Update()
			ActiveParticles += 1
		endif
	next i
	
End Sub
	
sub KillAll()
	
	for i as integer = 0 to MAX_PARTICLES
		if( Particles(i).Active ) then
			Particles(i).Active = FALSE
		endif
	next i
	
	ActiveParticles = 0
	
End Sub

sub DrawAll()
		
	for i as integer = 0 to MAX_PARTICLES
		if( Particles(i).Active ) then
			glColor4ub( Particles(i).Red, Particles(i).Green, Particles(i).Blue, Particles(i).Alpa )
			select case( Particles(i).DeathID )
				case TINY:
					GL2D.SpriteRotateScaleXY3D( Particles(i).Position.x,_
											  Particles(i).Position.y,_
											  Particles(i).Position.z,_
											  Particles(i).Angle,_
											  0.5,_
											  0.3,_
											  GL2D.FLIP_NONE,_
											  FlareImage )
				case MEDIUM:
					GL2D.SpriteRotateScaleXY3D( Particles(i).Position.x,_
											  Particles(i).Position.y,_
											  Particles(i).Position.z,_
											  Particles(i).Angle,_
											  1,_
											  1,_
											  GL2D.FLIP_NONE,_
											  FlareImage )				
				case LARGE:
					GL2D.SpriteRotateScaleXY3D( Particles(i).Position.x,_
											  Particles(i).Position.y,_
											  Particles(i).Position.z,_
											  Particles(i).Angle,_
											  1.5,_
											  0.3,_
											  GL2D.FLIP_NONE,_
											  FlareImage )
			end select
		endif
	next i
	
	glColor4ub( 255, 255, 255, 255 )
			
End Sub


sub Release()
	
	GL2D.DestroyImage( FlareImage )

End Sub

End Namespace
