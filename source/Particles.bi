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

#include once "FBGFX.bi"
#include once "FBGL2D7.bi"

#include once "UTIL.bi"
#include once "Vector3D.bi"
#include once "Globals.bi"

#ifndef FALSE
	#define FALSE 0
	#define TRUE -1
#endif


''*****************************************************************************
''
''
''
''*****************************************************************************
namespace Particle

enum EXPLODE_TYPE 
	TINY = 0,
	MEDIUM,
	LARGE
End Enum

extern as integer ActiveParticles
	
declare sub Init( byref filename as string )
declare sub KillAll()
declare sub Spawn overload( byref Posi as Vector3D, byref Dire as Vector3D, byval ID as integer )
declare sub Spawn overload( byref Posi as Vector3D, byval ang as integer, byval ID as integer )
declare sub Spawn overload( byref Posi as Vector3D, byval NumParticles as integer )
declare sub Spawn overload( byref Posi as Vector3D, byval Dire as Vector3D, byval spd as single, byval ID as integer )
declare sub Update()
declare sub DrawAll()
declare sub Release()
	
	
	
End Namespace
