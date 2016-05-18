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

#include once "Map.bi"
namespace MapUtil
	
function GetTile( byval x as integer, byval y as integer, Map() as TileType ) as integer
	return Map( x \ TILE_SIZE, y \ TILE_SIZE ).Collision
end function

end namespace
