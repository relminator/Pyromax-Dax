''*****************************************************************************
''
''
''	Pyromax Dax Globals
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#ifndef FALSE
	#define FALSE 0
	#define TRUE -1
#endif

#define SCREEN_WIDTH 640
#define SCREEN_HEIGHT 480

#define FIXED_TIME_STEP (1.0f/60.0f)

#define TILE_SIZE 32

#define JUMPHEIGHT  7

#define GRAVITY 0.30f
#define FRICTION 0.022f
#define ACCEL 0.099f
#define DAMPER (FRICTION * 4)
#define ICE_DAMPER (FRICTION)
#define MINIMUM_SPEED_THRESHOLD 0.5f

#define PARALLAX_PLANE (-28)
#define BACKGROUND_PLANE (-2)
#define FOREGROUND_PLANE 28

#define MAX_DISTANCE_FROM_PLAYER 12 
#define MAX_ENEMY_BLINK_COUNTER 15

namespace Globals

declare sub SetQuakeCounter( byval v as integer )
declare function GetQuakeCounter() as integer
declare function Quake() as integer

end namespace
