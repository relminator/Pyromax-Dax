''*****************************************************************************
''
''
''	Pyromax Dax Bomb Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "fbgfx.bi"
#include once "FBGL2D7.bi"     	'' We're gonna use Hardware acceleration
#include once "UTIL.bi"
#include once "Vector2D.bi"
#include once "Vector3D.bi"
#include once "AABB.bi"
#include once "Globals.bi"
#include once "Map.bi"
#include once "Keyboard.bi"
#include once "Joystick.bi"
#include once "Particles.bi"
#include once "Explosion.bi"
#include once "Sound.bi"

type Bomb
	
	declare constructor()
	declare destructor()
	
	declare property SetX( byval v as single )
	declare property SetY( byval v as single )
	declare property SetDX( byval v as single )
	declare property SetDY( byval v as single )
	
	declare property IsActive() as integer
	declare property GetX() as single
	declare property GetY() as single
	declare property GetDX() as Single
	declare property GetDY() as Single
	declare property GetWid() as Single
	declare property GetHei() as Single
	declare property GetDrawFrame() as integer
	declare property GetEnergyUse() as integer
	
	declare sub Spawn( byval ix as integer, byval iy as integer, byval direction as integer )
	declare sub Update(  Map() as TileType )
	declare sub Explode()
	declare sub Kill()
	declare sub Draw( SpriteSet() as GL2D.IMAGE ptr )
	declare function CollideWithAABB( byref Box as const AABB ) as integer
	declare sub DrawAABB()
	
private:

	declare function CollideFloors(byval ix as integer, byval iy as integer, byref iTileY as integer, Map() as TileType ) as integer
	
	as integer Active
	as integer Counter
	as integer CountActive
	as integer FlipMode
	
	as single x
	as single y
	as single Dx
	as single Dy
	
	as integer Frame
	as integer BaseFrame
	as integer NumFrames

	as integer Wid
	as integer Hei	

	as integer EnergyUse	

	as AABB BoxNormal
		
End Type
