''*****************************************************************************
''
''
''	Pyromax Dax LeavesParticle Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "FBGFX.bi"
#include once "FBGL2D7.bi"

#include once "UTIL.bi"
#include once "Vector2D.bi"
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
namespace LeavesParticle

extern as integer ActiveLeavesParticles
	
declare function GetWindFactor() as single
declare sub ChangeWindDirection( byval d as integer )
declare sub SetWindDirection( byval v as single )
declare sub Init( byref filename as string )
declare sub KillAll()
declare sub Spawn( byref Posi as Vector2D, byval spd as single, byval ang as integer, byval ID as integer )
declare sub SpawnAll( byval wid as integer, byval Hei as integer )
declare sub Update( byval UpdateDirection as integer = TRUE )
declare sub DrawAll()
declare sub ResetAll()
declare sub Release()
	
	
	
End Namespace
