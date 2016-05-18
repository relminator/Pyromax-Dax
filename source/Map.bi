''*****************************************************************************
''
''
''	Pyromax Dax Map Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Globals.bi"

''*****************************************************************************
''
''	Our Map
''
''*****************************************************************************

Enum E_TILE_TYPE
	TILE_VINE_SHORT_RIGHT = -14
	TILE_VINE_SHORT_LEFT = -13
	TILE_VINE_LONG_RIGHT = -12
	TILE_VINE_LONG_LEFT = -11
	TILE_VINE_SHORT = -10
	TILE_VINE_LONG = -9
	TILE_FENCE_TOP = -8
	TILE_FENCE = -7
	TILE_SIGN = -6
	TILE_LEFT_RIGHT_WATER = -5
	TILE_LEFT_WATER = -4
	TILE_RIGHT_WATER = -3
	TILE_TOP_WATER = -2
	TILE_WATER = -1
	TILE_NONE = 0,
	TILE_MUD,
	TILE_TRIGGER,
	TILE_SOLID,
	TILE_ICE,
	TILE_SEMI_ICE,
	TILE_SPIKE_CEILING,
	TILE_SPIKE_FLOOR,
	TILE_RUBBER,
	TILE_SOFT_BRICK,
	TILE_SOFT_ICE,
	TILE_PLATFORM_COLLISION,
End Enum

Type TileType
	Index as Integer					'' Used to draw
	Collision as integer				'' Used to collide
End Type

namespace MapUtil
	
declare function GetTile( byval x as integer, byval y as integer, Map() as TileType ) as integer	

end namespace

