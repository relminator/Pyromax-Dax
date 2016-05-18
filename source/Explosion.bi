''*****************************************************************************
''
''
''	Pyromax Dax Explosion Module (emulates a singleton)
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
#include once "uvcoord_explosions_sprite.bi"

#ifndef FALSE
	#define FALSE 0
	#define TRUE -1
#endif


''*****************************************************************************
''
''
''
''*****************************************************************************
namespace Explosion

enum EXPLOSION_TYPE 
	ATOMIC = 0,
	SHOT_BURST_SMALL,
	SHOT_BURST_BIG,
	SMOKE_01,
	INVINCIBILITY,
	MEDIUM_BLUE_01,
	MEDIUM_YELLOW_01,
	TINY_YELLOW_01,
	MEDIUM_YELLOW_02,
	TINY_YELLOW_02,
	MEDIUM_BLUE_02,
	BIG_YELLOW,
	MEDIUM_YELLOW_03,
	MEDIUM_BLUE_03,
	TWINKLE,
	SMOKE_02
End Enum

extern as integer ActiveExplosions
	
declare sub Init( byref filename as string )
declare sub KillAll()
declare sub Spawn overload( byref Posi as Vector3D, byref Dire as Vector3D, byval ID as integer, byval xFlipMode as GL2D.GL2D_FLIP_MODE = GL2D.FLIP_NONE )
declare sub Spawn overload( byref Posi as Vector3D, byval spd as single, byval ang as integer, byval ID as integer, byval xFlipMode as GL2D.GL2D_FLIP_MODE = GL2D.FLIP_NONE )
declare sub Spawn overload( byref Posi as Vector3D, byval NumParticles as integer )
declare sub SpawnMulti( byref Posi as Vector3D, byval spd as single, byval ang as integer, byval ID1 as integer, byval ID2 as integer, byval NumBranches as integer = 4 )
declare sub Update()
declare sub DrawAll()
declare sub Release()
	
	
	
End Namespace
