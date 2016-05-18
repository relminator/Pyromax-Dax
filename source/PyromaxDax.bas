''*****************************************************************************
''
''
''	Pyromax Dax (Main Module)
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "FBGFX.bi"
#include once "FBGL2D7.bi"     	'' We're gonna use Hardware acceleration
#include once "Vector2D.bi"

#include once "Globals.bi"
#include once "Map.bi"
#include once "Player.bi"
#include once "Camera.bi"
#include once "Engine.bi"


''*****************************************************************************
'' Our main sub
''*****************************************************************************
sub main()

	
	dim as Engine Game
	Game.Initialize()
	Game.InitEverything()	
	
	dim as integer Done = FALSE
	while( not Done )
		Done = Game.Update()
	wend
	
	Game.ShutDown()
	
end sub


''*****************************************************************************
''
''
''
''*****************************************************************************


main()


end




