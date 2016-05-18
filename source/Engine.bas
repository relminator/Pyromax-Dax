''*****************************************************************************
''
''
''	Pyromax Dax Engine(Main) Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "Engine.bi"
#include once "uvcoord_gui_sprite.bi"
#include once "uvcoord_seasons_sprite.bi"
#include once "uvcoord_splashes.bi"
#include once "uvcoord_enemies_sprite.bi"

	
redim shared as GL2D.IMAGE ptr GripeImages(0)
redim shared as GL2D.IMAGE ptr TilesImages(0)
redim shared as GL2D.IMAGE ptr IncendiariesImages(0)
redim shared as GL2D.IMAGE ptr GUIImages(0)
redim shared as GL2D.IMAGE ptr SeasonsImages(0)
redim shared as GL2D.IMAGE ptr SplashesImages(0)
redim shared as GL2D.IMAGE ptr EnemiesImages(0)
redim shared as TileType Map()

redim shared as string DialogScripts()
redim shared as WarpInfo WarpScripts()

dim shared as HighScore HighScores(10) => _
{ _
	( "ANYA THERESE",      55000 ), _
	( "ROSMELLY",          50000 ), _
	( "MARIE CRISTINA",    44000 ), _
	( "CRISTINA MARIE",    40000 ), _
	( "LACHIE DAZDARIAN",  33000 ), _
	( "VALDIR SALGUERO",   30000 ), _
	( "JON PETROSKY",      22000 ), _
	( "RICHARD ERIC",      20000 ), _
	( "DAVE STANLEY",      11000 ), _
	( "JOE ANTOON",        10000 ), _
	( "ANON X. FOO",       00000 )  _	
} 
	
		
''*****************************************************************************
''
''
''
''*****************************************************************************
constructor Engine()
	
	State = STATE_TITLE
	CurrentLevel = 0
	CurrentSeason = 0
	
	IsBossStage = FALSE
	BossActive = FALSE
	
	Frame = 0
	SecondsElapsed = 0
	FPS = 60
	Dt = 0
	Accumulator = 0
	
	FullScreen = FALSE
	Vsynch = FALSE
	ShowFPS = FALSE
	ShowDialogs = TRUE
	NoFrame = FALSE
	PhysicalScreenWidth = SCREEN_WIDTH
	PhysicalScreenHeight = SCREEN_HEIGHT
	
	CurrentDialogID = 0
	CurrentWarpID = 0
	
	PressedOK = FALSE
	PressedCancel = FALSE
	
	KeyUp = FB.SC_UP
	KeyDown = FB.SC_DOWN
	KeyLeft = FB.SC_LEFT
	KeyRight = FB.SC_RIGHT
	KeyJump = FB.SC_SPACE
	KeyAttack = FB.SC_Z
	KeyDie = FB.SC_C
	KeyOk = FB.SC_ENTER
	KeyCancel = FB.SC_ESCAPE
	
	JoyJump = JOY_KEY_2
	JoyAttack = JOY_KEY_1
	JoyOk = JOY_KEY_3
	JoyCancel = JOY_KEY_4
	JoyDie = JOY_KEY_5

	
	
	IncendiaryMenuAngle = 0
	ActiveIncendiary = 0
	
	MasterVolumeBGM = 128
	MasterVolumeSFX = 200
	
	DebugMode = FALSE
	
	DrawAABB = FALSE
			
	
End Constructor

destructor Engine()

End Destructor

''*****************************************************************************
''
''
''
''*****************************************************************************
property Engine.SetState( byval v as integer )
	State = v
End Property

''*****************************************************************************
''
''
''
''*****************************************************************************
sub Engine.Initialize()
	
	'State = STATE_END
	'State = STATE_STORY
	State = STATE_SPLASH
	'State = STATE_TITLE
	PreviousState  = STATE_TITLE
	NextState = STATE_TITLE
	
	CurrentLevel = 0
	CurrentSeason = 0
	
	
	HiScore = 0
	
	IsBossStage = FALSE
	BossActive = FALSE
	WindDirection = 0
	WindFrame = 0
	

	Frame = 0
	SecondsElapsed = 0
	FPS = 60
	Dt = 0
	Accumulator = 0
	
	FullScreen = FALSE
	
	ShowDialogs = TRUE
		
End Sub

sub Engine.GetInput()
	
	Joy.ScanButtons()
	
	PressedOK = Keys.Pressed(FB.SC_ENTER) or Keys.Pressed(KeyOk) or Joy.KeyPressed(JoyOk) 
	PressedCancel = Keys.Pressed(FB.SC_ESCAPE) or Keys.Pressed(KeyCancel) or Joy.KeyPressed(JoyCancel)
	
	PressedRight = Keys.Pressed(FB.SC_RIGHT) or Keys.Pressed(KeyRight) or Joy.RightPressed 
	PressedLeft = Keys.Pressed(FB.SC_LEFT) or Keys.Pressed(KeyLeft) or Joy.LeftPressed 
	PressedUp = Keys.Pressed(FB.SC_UP) or Keys.Pressed(KeyUp) or Joy.UpPressed 
	PressedDown = Keys.Pressed(FB.SC_DOWN) or Keys.Pressed(KeyDown) or Joy.DownPressed 
	
	'if( Keys.Pressed(FB.SC_F1) ) then
	'	DrawAABB = not DrawAABB
	'endif
	
	'if( Keys.Pressed(FB.SC_F2) ) then
	'	DebugMode = not DebugMode
	'endif
	
	'if( Keys.Held(FB.SC_F3) ) then
		'Cam.Zoom( 1 )
		'Sound.SetVolumeCurrentBGM( MasterVolumeBGM  )
	'endif
	
	'if( Keys.Held(FB.SC_F4) ) then
		'Cam.Zoom( -1 )
		'State = InputName
	'endif
	
	'if( Keys.Pressed(FB.SC_F5) ) then
	'	Snipe.AddLives(9)
	'endif
	
end sub

function Engine.InputName() as integer
	
	
	dim as integer Done = FALSE
	dim as integer flow = 0
	dim as single t = 0
	dim as single t2 = 0
	dim as integer PressedButton = FALSE
	dim as integer StartEntry = 0
	dim as integer MyFrame = 0
	dim as zstring * 17 Text
	dim as integer MaxChars = 16
	dim as integer column = 60
	dim as integer row = 250
	
	Text = "" 
	
	GL2D.ClearScreen()
	
	dt = GL2D.GetDeltaTime( FPS, timer )

	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			MyFrame += 1
			
			
			if( MyFrame >= StartEntry ) then						
				
				if( flow = 0 ) then
					t += 0.01
					if( t >= 1 ) then
						t2 + = 0.005
						t2 = UTIL.Clamp( t2, 0.0, 1.0 )
						dim as integer Leng = Len(Text)
						for i as integer = 1 to &h58
							if( Keys.Pressed(i) ) then
								select case i
									case FB.SC_BACKSPACE:
										Text = left( Text, Leng-1 )
									case FB.SC_LEFT:
										Text = left( Text, Leng-1 )
									case FB.SC_RIGHT:
									case FB.SC_RSHIFT:
									case FB.SC_LSHIFT:
									case FB.SC_SPACE:
										if( Leng < MaxChars ) then
											Text &= " "
										endif
									case FB.SC_ESCAPE:
										Text = "ANON X. FOO"
									case FB.SC_ENTER:
										flow = 1
										PressedButton = TRUE
										Done = TRUE
									case else
										if( Leng < MaxChars ) then
											Text &= left(UTIL.PrintKeyString( i ),1)
										endif
								end select
								Sound.PlaySFX( Sound.SFX_CLICK ) 
							endif
						next		
					endif
				else
					t -= 0.01
					if( PressedButton ) then
						if( t <= 0 ) then
							Done = TRUE
						endif
					endif
				endif
				
			endif
			
			t = UTIL.Clamp( t, 0.0, 1.0 )
			
			accumulator -= FIXED_TIME_STEP
			
			dim as integer Blinker = (int( SecondsElapsed * 1 ) and 1)
	
			'' Set up some opengl crap (some are not needed)
			glMatrixMode( GL_MODELVIEW )
			glLoadIdentity() 
			glPolygonMode( GL_FRONT, GL_FILL )
			glPolygonMode( GL_BACK, GL_FILL )
			glEnable( GL_DEPTH_TEST )
			glDepthFunc( GL_LEQUAL )
			
			glEnable( GL_TEXTURE_2D )
			glEnable( GL_ALPHA_TEST )
			glAlphaFunc(GL_GREATER, 0)
					
			GL2D.ClearScreen()  '' no motion blur
			
			
			GL2D.Begin2D()
				
				ResizeScreen()
			
				GL2D.SetBlendMode( GL2D.BLEND_TRANS )	
				GL2D.BoxFilled(0,0,SCREEN_WIDTH,SCREEN_HEIGHT, GL2D_RGBA(100, 128, 200,255 ))
	
				GL2D.SetBlendMode( GL2D.BLEND_ALPHA )	
				glColor4f( 1, 1, 1, SMOOTH_STEP(t) * 0.5)
				
				dim as integer Px = 64 + UTIL.LerpSmooth(0, SCREEN_WIDTH\2, t)
				dim as integer Py = 64 + UTIL.LerpSmooth(0, SCREEN_HEIGHT\2, t)
				GL2D.SpriteStretch( SCREEN_WIDTH\2 - Px, SCREEN_HEIGHT\2 - Py, Px*2,  Py*2, GUIimages(1) )
			
				GL2D.SetBlendMode( GL2D.BLEND_TRANS )	
			
				glColor4f( 1, 1, 1, 1 )
				
				dim as integer iy = UTIL.LerpSmooth( -200, 10, SMOOTH_STEP(t) )
				
				CenterText( iy, 2, "congratulations" )    
				CenterText( iy + 60, 1, "YOU GOT A NEW RECORD!" )    
				CenterText( iy + 100, 1, "PLEASE ENTER YOUR NAME..." )    
				
				dim as integer rw = UTIL.LerpSmooth( 1500, Row, t )
				dim as string TextDisplay = Text & string( MaxChars-len(Text), "-")
				GL2D.PrintScale(column,rw,2, ucase(TextDisplay) )
			
				dim as single col = abs(sin(Frame*0.2)) 
				glColor4f( col, 1- col, col, 255)
				if(Len(Text) < MaxChars) then
					Gl2D.PrintScale(column+Len(Text)*32,rw,2, ucase(right(TextDisplay, 1)) )
				else
					Gl2D.PrintScale(column+(Len(Text)-1)*32,rw,2, ucase(right(TextDisplay, 1)) )
				endif
				
				glColor4f( 1 - col, col, 1 - col, 255)
				CenterText( rw + 100, 2, "SCORE : " & UTIL.Int2Score( Snipe.GetScore, 7, "0" ) )	
			
				glColor4f( 1, 1, 1, 255)
				if( Blinker ) then 
					CenterText( rw + 200, 1, "PRESS |enter/ok| TO ACCEPT" )
				else
					CenterText( rw + 200, 1, "PRESS |escape/cancel| TO RESET FIELD" )
				endif
				
			GL2D.End2D()
			
			flip
		
		wend
		
		
		sleep 1,1
		
	Loop until ( Done )

	Done = FALSE
	
	HighScores(10).MyName = ucase((Text)) 
	HighScores(10).Score = Snipe.GetScore
	SortHighScores()
	
	return Done
	
End function

function Engine.Update() as integer
	
	
	''  Check-up what function to call depending on the state of the engine
	dim as integer Done = FALSE
	
	select case State		
		case STATE_PLAY:
			Done = StatePlay()
		case STATE_PAUSE:
			Done = StatePause()
		case STATE_START:
			Done = StateStart()
		case STATE_END:
			Done = StateEnd()
		case STATE_WARP:
			Done = StateWarp()
		case STATE_STAGE_BOSS_COMPLETE:
			Done = StateStageBossComplete()
		case STATE_STAGE_BOSS_FAIL:
			Done = StateStageBossFail()
		case STATE_GAME_OVER:
			Done = StateGameOver()
		case STATE_OPTIONS:
			Done = StateOptions()
		case STATE_CONTROLS:
			Done = StateControls()
		case STATE_CREDITS:
			Done = StateCredits()
		case STATE_TITLE:
			Done = StateTitle()
		case STATE_YES_OR_NO:
			Done = StateYesOrNo()
		case STATE_DIALOG:
			Done = StateDialog()
		case STATE_MOVE_TO_SPAWN_AREA:
			Done = StateMoveToSpawnArea()
		case STATE_RESPAWN_PLAYER:
			Done = StateRespawnPlayer()
		case STATE_INTERMISSION:
			Done = StateIntermission()
		case STATE_RECORDS:
			Done = StateRecords()
		case STATE_STORY:
			Done = StateStory()
		case STATE_SPLASH:
			Done = StateSplash()
		case STATE_EXIT:
			Done = TRUE
	End Select
	
	return Done
	
End function


sub Engine.HandleObjectCollisions()
	
	Snipe.SetOnPlatform = FALSE
	Snipe.SetOnSideOfPlatform = FALSE

	PlatformVs.HandleCollisions( Snipe, Map() )
	PlatformHs.HandleCollisions( Snipe )
	
	FallingBlocks.HandleCollisions( Snipe )
	
	
	'Incendiary Collisions
	for i as integer = 0 to PlatformVs.GetMaxEntities
		dim as AABB PlatformBox = PlatformVs.GetAABB(i)
		Snipe.CollideShotsPlatforms( PlatformBox )
		Snipe.CollideBombsPlatforms( PlatformBox )
		Snipe.CollideDynamitesPlatforms( PlatformBox )
		Snipe.CollideMinesPlatforms( PlatformBox )
	Next
	
	for i as integer = 0 to PlatformHs.GetMaxEntities
		dim as AABB PlatformBox = PlatformHs.GetAABB(i)
		Snipe.CollideShotsPlatforms( PlatformBox )
		Snipe.CollideBombsPlatforms( PlatformBox )
		Snipe.CollideDynamitesPlatforms( PlatformBox )
		Snipe.CollideMinesPlatforms( PlatformBox )
	Next
	
	if( Snipe.IsDead ) then 
		ActiveIncendiary = 0
		IncendiaryMenuAngle = 0
		return
	endif
	
	Bullets.HandleCollisions( Snipe )
	
	''Enemies
	Megatons.HandleCollisions( Snipe )
	Wallers.HandleCollisions( Snipe )
	Grogs.HandleCollisions( Snipe )
	Wheelies.HandleCollisions( Snipe )
	Jumpbots.HandleCollisions( Snipe )
	Heliheads.HandleCollisions( Snipe )
	Springers.HandleCollisions( Snipe )
	Eyesores.HandleCollisions( Snipe )
	Bouncers.HandleCollisions( Snipe )
	Nails.HandleCollisions( Snipe )
	Robats.HandleCollisions( Snipe )
	Roboxs.HandleCollisions( Snipe )
	Screwgatlings.HandleCollisions( Snipe )
	Watchers.HandleCollisions( Snipe )
	Drumbots.HandleCollisions( Snipe )
	Plasmos.HandleCollisions( Snipe )
	
	CurrentDialogID = DialogTriggers.HandleCollisions( Snipe )		
	if( (CurrentDialogID > 0) and (CurrentDialogID <= (ubound(DialogScripts) + 1) ) ) then
		State = STATE_DIALOG
	endif
	
	if( PowBombs.HandleCollisions( Snipe ) ) then
		 Snipe.AddBombs(3)
	endif
	
	if( PowDynamites.HandleCollisions( Snipe ) ) then
		 Snipe.AddDynamites(3)
	endif
	
	if( PowMines.HandleCollisions( Snipe ) ) then
		 Snipe.AddMines(3)
	endif
	
	if( PowEnergys.HandleCollisions( Snipe ) ) then
		 Snipe.AddHp(50)
	endif
	
	CurrentWarpID = Warps.HandleCollisions( Snipe )
	if( (CurrentWarpID > 0) and (CurrentWarpID <= (ubound(WarpScripts) + 1) ) ) then
		 State = STATE_INTERMISSION
	endif

	dim as integer sx, sy
	if( Checkpoints.HandleCollisions( Snipe, sx, sy ) ) then
		SpawnX = sx
		SpawnY = sy 
	endif
	
	'' Bosses
	
	BossBigEyes.HandleCollisions( Snipe )
	BossGyrobots.HandleCollisions( Snipe )
	BossRobbits.HandleCollisions( Snipe )
	BossJokers.HandleCollisions( Snipe )
	
			
end sub

sub Engine.HandleObjectDestructions()
	
	Snipe.ResetAll()
	
	Particle.KillAll()
	Explosion.KillAll()
	LeavesParticle.KillAll()
	
	PlatformVs.KillAllEntities()
	PlatformHs.KillAllEntities()
	
	Bullets.KillAllEntities()
	
	''Enemies
	Wallers.KillAllEntities()
	Grogs.KillAllEntities()
	Wheelies.KillAllEntities()
	Jumpbots.KillAllEntities() 
	Heliheads.KillAllEntities() 
	Springers.KillAllEntities() 
	Eyesores.KillAllEntities() 
	Bouncers.KillAllEntities() 
	Nails.KillAllEntities() 
	Robats.KillAllEntities() 
	Roboxs.KillAllEntities() 
	Screwgatlings.KillAllEntities() 
	Watchers.KillAllEntities() 
	Megatons.KillAllEntities() 
	Drumbots.KillAllEntities() 
	Plasmos.KillAllEntities() 
	
	
	DialogTriggers.KillAllEntities()
	PowBombs.KillAllEntities()
	PowDynamites.KillAllEntities()
	PowMines.KillAllEntities()
	PowEnergys.KillAllEntities()
	
	Warps.KillAllEntities()
	Checkpoints.KillAllEntities()
	
	FallingBlocks.KillAllEntities()
	
	
	BossBigEyes.KillAllEntities() 
	BossJokers.KillAllEntities() 
	BossRobbits.KillAllEntities() 
	BossGyrobots.KillAllEntities() 

	WindFrame = 0
		
end sub

sub Engine.HandleObjectRenders()
	
	PlatformVs.DrawEntities( EnemiesImages() ) 
	PlatformHs.DrawEntities( EnemiesImages() ) 
	
	BossBigEyes.DrawEntities( EnemiesImages() ) 
	BossJokers.DrawEntities( EnemiesImages() ) 
	BossRobbits.DrawEntities( EnemiesImages() ) 
	BossGyrobots.DrawEntities( EnemiesImages() ) 
	
	Wallers.DrawEntities( EnemiesImages() ) 
	Grogs.DrawEntities( EnemiesImages() ) 
	Wheelies.DrawEntities( EnemiesImages() ) 
	Jumpbots.DrawEntities( EnemiesImages() ) 
	Heliheads.DrawEntities( EnemiesImages() ) 
	Springers.DrawEntities( EnemiesImages() ) 
	Eyesores.DrawEntities( EnemiesImages() ) 
	Bouncers.DrawEntities( EnemiesImages() ) 
	Nails.DrawEntities( EnemiesImages() ) 
	Robats.DrawEntities( EnemiesImages() ) 
	Roboxs.DrawEntities( EnemiesImages() ) 
	Screwgatlings.DrawEntities( EnemiesImages() ) 
	Watchers.DrawEntities( EnemiesImages() ) 
	Megatons.DrawEntities( EnemiesImages() ) 
	Drumbots.DrawEntities( EnemiesImages() ) 
	Plasmos.DrawEntities( EnemiesImages() ) 
	
	
	CheckPoints.DrawEntities( EnemiesImages() )
	
	Warps.DrawEntities( EnemiesImages() )
	
	FallingBlocks.DrawEntities( EnemiesImages() )
	
	DialogTriggers.DrawEntities( EnemiesImages() )
	PowBombs.DrawEntities( EnemiesImages() )
	PowDynamites.DrawEntities( EnemiesImages() )
	PowMines.DrawEntities( EnemiesImages() )
	PowEnergys.DrawEntities( EnemiesImages() )
	
	Snipe.Draw( GripeImages() )
	Snipe.DrawShots( IncendiariesImages() )
	Snipe.DrawBombs( IncendiariesImages() )
	Snipe.DrawDynamites( IncendiariesImages() )
	Snipe.DrawMines( IncendiariesImages() )

	
	if( DrawAABB ) then DrawCollisionBoxes()
		
	GL2D.SetBlendMode( GL2D.BLEND_BLENDED )
	Particle.DrawAll()
	GL2D.SetBlendMode( GL2D.BLEND_TRANS )
	Explosion.DrawAll()
	
	Bullets.DrawEntities( EnemiesImages() ) 
	
			
end sub

sub Engine.HandleObjectUpdates()
	
	Snipe.Update( Keys, Joy, Map() )     '' Do player movements
 	
 	
 	PlatformVs.UpdateEntities( Snipe.GetCameraX, Map() )
	PlatformHs.UpdateEntities( Snipe.GetCameraX, Map() )
	
	Bullets.UpdateEntities( Snipe, Map() )
	
	Wallers.UpdateEntities( Snipe, Map() )
	Grogs.UpdateEntities( Snipe, Map() )
	Wheelies.UpdateEntities( Snipe, Map() )
	Jumpbots.UpdateEntities( Snipe, Map() )
	Heliheads.UpdateEntities( Snipe, Map() )
	Springers.UpdateEntities( Snipe, Map() )
	Eyesores.UpdateEntities( Snipe, Bullets, Map() )
	Bouncers.UpdateEntities( Snipe, Map() )
	Nails.UpdateEntities( Snipe, Map() )
	Robats.UpdateEntities( Snipe, Bullets, Map() )
	Roboxs.UpdateEntities( Snipe, Map() )
	Screwgatlings.UpdateEntities( Snipe, Bullets, Map() )
	Watchers.UpdateEntities( Snipe, Bullets, Map() )
	Megatons.UpdateEntities( Snipe, Map() )
	Drumbots.UpdateEntities( Snipe, Bullets, Map() )
	Plasmos.UpdateEntities( Snipe, Map() )
	
	DialogTriggers.UpdateEntities( Snipe, Map() )
	PowBombs.UpdateEntities( Snipe, Map() )
	PowDynamites.UpdateEntities( Snipe, Map() )
	PowMines.UpdateEntities( Snipe, Map() )
	PowEnergys.UpdateEntities( Snipe, Map() )
	
	Warps.UpdateEntities( Snipe, Map() )
	Checkpoints.UpdateEntities( Snipe, Map() )
	
	FallingBlocks.UpdateEntities( Snipe, Map() )
	
	Particle.Update()
	Explosion.Update()
	if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
		LeavesParticle.Update()
	endif
	
	select case (CurrentLevel+1)
		case 90:
			BossActive = BossBigEyes.UpdateEntities( Snipe, Bullets, Map() )
		case 91:
			BossActive = BossGyrobots.UpdateEntities( Snipe, Bullets, Map() )
		case 92:
			BossActive = BossRobbits.UpdateEntities( Snipe, Bullets, Map() )
		case 93:
			BossActive = BossJokers.UpdateEntities( Snipe, Bullets, Map() )
	end select
	
	'' Destroy everything when currentboss is destroyed
	if( IsBossStage ) then
		if( not BossActive ) then
			State = STATE_STAGE_BOSS_COMPLETE
		else
			select case (CurrentLevel+1)
				case 90:
					BossDieX = BossBigEyes.GetPos(0).x + 26
					BossDieY = BossBigEyes.GetPos(0).y + 10
				case 91:
					BossDieX = BossGyrobots.GetPos(0).x + 26
					BossDieY = BossGyrobots.GetPos(0).y + 10
				case 92:
					BossDieX = BossRobbits.GetPos(0).x + 26
					BossDieY = BossRobbits.GetPos(0).y + 10
				case 93:
					BossDieX = BossJokers.GetPos(0).x + 26
					BossDieY = BossJokers.GetPos(0).y + 10
			end select
		endif
	endif
		
end sub

sub Engine.RespawnSnipe()
	
	Particle.KillAll()
	Explosion.KillAll()
	
	Snipe.Spawn( SpawnX, SpawnY )
	
	if( (CurrentLevel+1) > = 90 ) then
		Snipe.AddBombs(99)
		Snipe.AddDynamites(99)
		Snipe.AddMines(99)
	endif
	
	Snipe.SetIncendiaryType = Snipe.INCENDIARY_SHOT
	ActiveIncendiary = 0
	IncendiaryMenuAngle = 0

end sub

sub Engine.InitEverything()
	
	randomize timer

		
	Sound.Initialize( 44000, 32, 0 )

	LoadSounds()	
	
	Sound.SetMasterVolumeBGM( MasterVolumeBGM )
	Sound.SetMasterVolumeSFX( MasterVolumeSFX )
 	
 	'' Load config file if there is one
	if( dir( "PyromaxDax.cfg" ) = "PyromaxDax.cfg" ) then
		LoadConfig( "PyromaxDax.cfg" )	
	endif
	
	'' Load keymapping if there is one
	if( dir( "PyromaxDaxKey.cfg" ) = "PyromaxDaxKey.cfg" ) then
		LoadControls( "PyromaxDaxKey.cfg" )	
		Snipe.LoadControls( "PyromaxDaxKey.cfg" )	
	endif
	
	'' High scores
	if( dir( "PyromaxDax.his" ) = "PyromaxDax.his" ) then
		LoadHighScores( "PyromaxDax.his" )	
	endif
	
	SortHighScores()
	HiScore = HighScores(0).Score
	
	'FullScreen = TRUE
	dim as integer flag = FB.GFX_WINDOWED
	if( FullScreen ) then flag = FB.GFX_FULLSCREEN
	if( NoFrame ) then flag = flag or FB.GFX_NO_FRAME
	
	GL2D.ScreenInit( PhysicalScreenWidth, PhysicalScreenHeight, flag )   ''Set up GL screen
			
	if( Vsynch ) then GL2D.VsyncOn()
	
	GL2D.EnableAntialias( TRUE )
	
	LoadImages()
	
	Particle.Init( "images/flare.bmp" )
	Explosion.Init( "images/explosions_sprite.bmp" )
	LeavesParticle.Init( "images/explosions_sprite.bmp" )
	
		
End Sub


sub Engine.LoadLevel( byval LoadSpawnPoint as integer )
	
	
	HandleObjectDestructions()
	
	dim as string TempMap()
	dim as string Filename = "maps/level" & trim(UTIL.Int2Score(CurrentLevel+1, 2, "0")) & ".txt"
	LoadMap( Filename, TempMap() )
	ConvertMap( Map(), TempMap(), LoadSpawnPoint )
	
	DialogTriggers.SortEntities()
	Warps.SortEntities()
	Checkpoints.SortEntities()

	LoadDialogScripts()
	LoadWarpScripts()
	
	MapWidth =  ubound(Map,1) + 1
	MapHeight =  ubound(Map,2) + 1
	
	CurrentDialogID = 0
	CurrentWarpID = 0
	
	Globals.SetQuakeCounter( 0 )
	LeavesParticle.SpawnAll( SCREEN_WIDTH, SCREEN_HEIGHT )
	WindDirection = 0
	
end sub

sub Engine.LoadImages()
	
	GL2D.InitSprites( GripeImages(), 32,32, "images/snipe.bmp", GL_NEAREST )
	GL2D.InitSprites( TilesImages(), 32,32, "images/tiles.bmp", GL_NEAREST )
	GL2D.InitSprites( IncendiariesImages(), 16,16, "images/incendiaries.bmp", GL_NEAREST )
	GL2D.InitSprites( GUIImages(), gui_sprite_texcoords(), "images/gui_sprite.bmp", GL_NEAREST )
	GL2D.InitSprites( SeasonsImages(), seasons_sprite_texcoords(), "images/seasons_sprite.bmp" )
	GL2D.InitSprites( SplashesImages(), splashes_texcoords(), "images/splashes.bmp" )
	GL2D.InitSprites( EnemiesImages(), enemies_sprite_texcoords(), "images/enemies_sprite.bmp", GL_NEAREST )
	
	GL2D.FontLoad( 16, 16, 32, "images/kroma256.bmp" )

End Sub

	
sub Engine.LoadSounds()
	
	
	Sound.LoadSFX( "audio/sfx/attack.wav", Sound.SFX_ATTACK )
	Sound.LoadSFX( "audio/sfx/jump.wav", Sound.SFX_JUMP )
	Sound.LoadSFX( "audio/sfx/attack.wav", Sound.SFX_PLANT_INCENDIARY )
	Sound.LoadSFX( "audio/sfx/bounce.wav", Sound.SFX_BOUNCE )
	Sound.LoadSFX( "audio/sfx/hurt.wav", Sound.SFX_HURT )
	Sound.LoadSFX( "audio/sfx/power_up.wav", Sound.SFX_POWER_UP )
	Sound.LoadSFX( "audio/sfx/coin_up.wav", Sound.SFX_COIN_UP )
	Sound.LoadSFX( "audio/sfx/explode.wav", Sound.SFX_EXPLODE )
	Sound.LoadSFX( "audio/sfx/mine_active.wav", Sound.SFX_MINE_ACTIVE )
	Sound.LoadSFX( "audio/sfx/dynamite_launch.wav", Sound.SFX_DYNAMITE_LAUNCH )
	Sound.LoadSFX( "audio/sfx/menu_ok.wav", Sound.SFX_MENU_OK )
	Sound.LoadSFX( "audio/sfx/level_complete.wav", Sound.SFX_LEVEL_COMPLETE )
	Sound.LoadSFX( "audio/sfx/click.wav", Sound.SFX_CLICK )
	Sound.LoadSFX( "audio/sfx/1up.wav", Sound.SFX_1UP )
	Sound.LoadSFX( "audio/sfx/go.wav", Sound.SFX_GO )
	Sound.LoadSFX( "audio/sfx/metal_hit.wav", Sound.SFX_METAL_HIT )
	Sound.LoadSFX( "audio/sfx/enemy_shot_01.wav", Sound.SFX_ENEMY_SHOT_01 )
	Sound.LoadSFX( "audio/sfx/enemy_shot_02.wav", Sound.SFX_ENEMY_SHOT_02 )
	Sound.LoadSFX( "audio/sfx/ice_hit.wav", Sound.SFX_ICE_HIT )
	Sound.LoadSFX( "audio/sfx/yahoo.wav", Sound.SFX_YAHOO )
	
	Sound.LoadBGM( "audio/bgm/level_01.mid", Sound.BGM_LEVEL_01, 128 )
	Sound.LoadBGM( "audio/bgm/level_02.mid", Sound.BGM_LEVEL_02, 128 )
	Sound.LoadBGM( "audio/bgm/level_03.mid", Sound.BGM_LEVEL_03, 128 )
	Sound.LoadBGM( "audio/bgm/level_04.mid", Sound.BGM_LEVEL_04, 128 )
	Sound.LoadBGM( "audio/bgm/boss.mid", Sound.BGM_LEVEL_BOSS, 128 )
	Sound.LoadBGM( "audio/bgm/credits.mid", Sound.BGM_CREDITS, 128 )
	Sound.LoadBGM( "audio/bgm/title.mid", Sound.BGM_TITLE, 128 )
	Sound.LoadBGM( "audio/bgm/complete.mid", Sound.BGM_COMPLETE, 128 )
	Sound.LoadBGM( "audio/bgm/game_over.mid", Sound.BGM_GAME_OVER, 128 )
	Sound.LoadBGM( "audio/bgm/end.mid", Sound.BGM_END, 128 )
	Sound.LoadBGM( "audio/bgm/intermission.mid", Sound.BGM_INTERMISSION, 128 )
	Sound.LoadBGM( "audio/bgm/intro.mid", Sound.BGM_INTRO, 128 )
	
	
End Sub

sub Engine.LoadDialogScripts()
	
	dim as string Directory = "scripts/dialogs/" & "level" & trim(UTIL.Int2Score(CurrentLevel+1, 2, "0"))& "/"
	dim as integer Numdialogs = UTIL.CountFiles(  Directory & "*.txt", fbarchive )
	redim DialogScripts(Numdialogs-1)
	
	for i as integer = 0 to ubound(DialogScripts)
		dim as string Filename = Directory & "dialog" & trim(UTIL.Int2Score(i+1, 2, "0")) & ".txt" 
		LoadScript( FileName, DialogScripts(i) )
		DialogScripts(i) &= " | "
	next
	
	
End Sub

sub Engine.LoadScript( byref FileName as string, byref OutString as string )
	
	dim as integer FileNum = FreeFile
	
	if( open( FileName for input as #FileNum ) ) <> 0 then 
		Outstring = "Error Loading File !!!"
	else
		dim as string Lin
		do until( eof(1) )
			line input #1, Lin
			Outstring += ucase(trim(Lin)) 
		loop		
		
	endif
	
	close #FileNum
	
End Sub

sub Engine.LoadWarpScripts()
	
	dim as string Directory = "scripts/warps/" & "level" & trim(UTIL.Int2Score(CurrentLevel+1, 2, "0"))& "/"
	dim as integer NumWarps = UTIL.CountFiles(  Directory & "*.txt", fbarchive )
	redim WarpScripts(Numwarps-1)
	
	for i as integer = 0 to ubound(WarpScripts)
		dim as string Filename = Directory & "warp" & trim(UTIL.Int2Score(i+1, 2, "0")) & ".txt" 
		LoadWarpInfo( FileName, WarpScripts(i) )
	next
	
end sub

sub Engine.LoadWarpInfo( byref FileName as string, byref OutInfo as WarpInfo )

	dim as integer FileNum = FreeFile
	
	if( open( FileName for input as #FileNum ) ) <> 0 then 
		 print "Error Loading File in WarpInfo !!!"
	else
		dim as string lin(3)
		line input #1, lin(0)
		line input #1, lin(1)
		line input #1, lin(2)
		line input #1, lin(3)
	
		OutInfo.SpawnTileX = val( right(lin(0), len(lin(0))-instr(lin(0),"=") ))
		OutInfo.SpawnTileY = val( right(lin(1), len(lin(1))-instr(lin(1),"=") ))
		OutInfo.LevelNum = val( right(lin(2), len(lin(2))-instr(lin(2),"=") ))
		OutInfo.SeasonType = val( right(lin(3), len(lin(3))-instr(lin(3),"=") ))

	endif
	
	close #FileNum

end sub

sub Engine.ShutDown()
	
	GL2D.DestroySprites( GripeImages() )
	GL2D.DestroySprites( TilesImages() )
	GL2D.DestroySprites( GUIImages() )
	GL2D.DestroySprites( SeasonsImages() )
	GL2D.DestroySprites( EnemiesImages() )
	GL2D.DestroySprites( IncendiariesImages() )
	GL2D.DestroySprites( SplashesImages() )
	
	
	Particle.Release()
	Explosion.Release()
	LeavesParticle.Release()
	
	GL2D.ShutDown()
	Sound.ShutDown()

End Sub
		
''*****************************************************************************
''
''	Main Gameplay state
''
''*****************************************************************************	
function Engine.StatePlay() as integer

	
	dim as integer Done = FALSE
	
	dt = GL2D.GetDeltaTime( FPS, timer )
	
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )		
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			WindFrame += 1
			
    		'if( CurrentSeason = SEASON_FALL ) then
    		'	Globals.SetQuakeCounter( 10 )
    		'endif
    	
    		if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
    			if( not IsBossStage ) then
    				if( (CurrentLevel + 1) <  90 ) then 
						if( (WindFrame and 511) = 0 ) then
							WindDirection += 1 
							LeavesParticle.ChangeWindDirection( int(sin(DEG2RAD(WindDirection * 90)) + 0.5) )
						endif
					endif
    			else
    				LeavesParticle.SetWindDirection( 0 )
    			endif
    		else
    			LeavesParticle.SetWindDirection( 0 )
    		endif
    		
    		HandleObjectCollisions()
    		HandleObjectUpdates()
					
   			if( (Snipe.GetY \ TILE_SIZE) = (MapHeight-3) ) then
   				if( not Snipe.IsDead ) then 
   					Snipe.Kill()
   					WindDirection = 0
   					WindFrame = 0
   					LeavesParticle.ResetAll()
   				endif
   			endif
			
			'' Player has lives left
			if( Snipe.GetLives >= 0 ) then
				if( not IsBossStage ) then     '' normal state when not in boss state
					if( Snipe.GetState = Player.DEAD ) then
		    			State = STATE_MOVE_TO_SPAWN_AREA
		    			OldPlayerX = Snipe.GetX
		    			OldPlayerY = Snipe.GetY
		    			WindDirection = 0
		    			WindFrame = 0
		    			LeavesParticle.ResetAll()
					endif
				else		'' Do special stuff when boss kills snipe
					if( Snipe.GetState = Player.DEAD ) then
		    			State = STATE_STAGE_BOSS_FAIL
					endif
				endif
			else
				State = STATE_GAME_OVER
			endif
			
			
    		accumulator -= FIXED_TIME_STEP
			
			Draw()
				
		wend
		
		
		''' Update input
		GetInput()

		
		if( PressedCancel ) then State = STATE_YES_OR_NO
		
		if( PressedOK ) then State = STATE_PAUSE
		
		sleep 1,1
		
	Loop until ( State <> STATE_PLAY )
	
	if( Snipe.GetScore > HiScore ) then HiScore = Snipe.GetScore

	select case State		
		case STATE_PAUSE:
		case STATE_START:
		case STATE_END:
		case STATE_WARP:
			Sound.StopCurrentBGM()
		case STATE_GAME_OVER:
			Sound.StopCurrentBGM()
		case STATE_TITLE:
			Sound.StopCurrentBGM( )
		case STATE_YES_OR_NO:
		case STATE_DIALOG:
		case STATE_MOVE_TO_SPAWN_AREA:
		case STATE_RESPAWN_PLAYER:
		case STATE_INTERMISSION:
		case STATE_EXIT:
			Sound.StopCurrentBGM()
		case STATE_STAGE_BOSS_COMPLETE:
			Sound.StopCurrentBGM()
		case STATE_STAGE_BOSS_FAIL:
			Sound.StopCurrentBGM()
	end select
	
	return Done
	
End function


''*****************************************************************************
''
''	Paused state
''
''*****************************************************************************	
function Engine.StatePause() as integer
	
	const as integer CHOICES = 4
	const as integer DEGREE_STEPS = 360\CHOICES
	dim as integer AnimationDirection = 1
	
	ActiveIncendiary = Snipe.GetIncendiaryType
	
	dim as integer Done = FALSE
	dim as single SoundLerp = 0
	dim as integer Volume = MasterVolumeBGM \ 2
	
	Sound.PlaySFX( Sound.SFX_COIN_UP )
	
	dim as single t = 0
	dt = GL2D.GetDeltaTime( FPS, timer )
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			SoundLerp = Util.Clamp( SoundLerp + 0.05, 0.0, 1.0 )
				
			if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
				LeavesParticle.Update()
			endif
	
			if( IncendiaryMenuAnimate ) then
				IncendiaryMenuAngle = (IncendiaryMenuAngle + (DEGREE_STEPS\15) * AnimationDirection )
				IncendiaryMenuAngle = UTIL.Wrap( IncendiaryMenuAngle, 0, 360 )
				if( (IncendiaryMenuAngle mod DEGREE_STEPS) = 0 ) then
					IncendiaryMenuAnimate = FALSE
				EndIf
			EndIf
			
			accumulator -= FIXED_TIME_STEP
			
			Draw()
			
			Sound.SetVolumeCurrentBGM( UTIL.LerpSmooth(MasterVolumeBGM, Volume, SoundLerp)  )
	
		wend
		
		
		GetInput()
    	
    	if( not IncendiaryMenuAnimate ) then
	    	if( PressedRight ) then
	    		Sound.PlaySFX( Sound.SFX_BOUNCE )
				IncendiaryMenuAnimate = TRUE
				AnimationDirection = 1
	    		ActiveIncendiary = (ActiveIncendiary + (CHOICES - 1)) mod CHOICES
	    	EndIf
			if( PressedLeft ) then 
				Sound.PlaySFX( Sound.SFX_BOUNCE )
				IncendiaryMenuAnimate = TRUE
				AnimationDirection = -1
				ActiveIncendiary = (ActiveIncendiary + 1) mod CHOICES
			EndIf
    	endif
    	
		if( PressedOK or Keys.Pressed(KeyJump) or Joy.KeyPressed(JoyJump) ) then State = STATE_PLAY
		
		sleep 1,1
		
	Loop until ( State <> STATE_PAUSE )

	Snipe.SetCanJump( FALSE )
	
	Sound.SetVolumeCurrentBGM( MasterVolumeBGM )
	
	Sound.PlaySFX( Sound.SFX_COIN_UP )
	
	Snipe.SetIncendiaryType =  ActiveIncendiary
	
	return Done
	
End function

''*****************************************************************************
''
''	State called before Playing
''
''*****************************************************************************	

function Engine.StateStart() as integer
	
	dim as integer Done = FALSE
	dim as integer CountDown = 60 * 6
	dim as single t = 0
	dim as single t2 = 0
	dim as integer PlaySound = FALSE
	dim as integer PlaySound2 = FALSE
	
	dt = GL2D.GetDeltaTime( FPS, timer )
	
	RespawnSnipe()
	Snipe.SetInvincible = FALSE
	
	WindDirection = 0
	WindFrame = 0
	LeavesParticle.ResetAll()

	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			CountDown -= 1
			
			if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
				LeavesParticle.Update()
			endif
	
			t += 0.005
			
			if( t >= 1) then 
				
				t2 += 0.01
				if( t2 >= 0.5 ) then
					if( not PlaySound) then Sound.PlaySFX( Sound.SFX_GO )
					PlaySound = TRUE
				endif
				if( t2 >= 1.3 ) then
					if( not PlaySound2 ) then Sound.PlaySFX( Sound.SFX_GO )
					PlaySound2 = TRUE
				endif
			endif
			
			accumulator -= FIXED_TIME_STEP			
			DrawStartEnd( UTIL.Clamp( t, 0.0, 1.0 ), t2 )
		
		wend
		
		
		if( CountDown <= 0 ) then
			if( ((CurrentLevel+1) >= 90) and (ShowDialogs) ) then
				CurrentDialogID = 1
				State = STATE_DIALOG
			else
				State = STATE_PLAY
			endif
	   		
		endif
		
		sleep 1,1
		
	Loop until ( State <> STATE_START )

	Sound.StopCurrentBGM()
	if( (CurrentLevel+1) >= 90 ) then
		Sound.SetCurrentBGM( Sound.BGM_LEVEL_BOSS )
		Sound.PlayCurrentBGM()
	else
		select case CurrentSeason
			case SEASON_SUMMER:
				Sound.SetCurrentBGM( Sound.BGM_LEVEL_01 )
			case SEASON_FALL:
				Sound.SetCurrentBGM( Sound.BGM_LEVEL_02 )
			case SEASON_WINTER:
				Sound.SetCurrentBGM( Sound.BGM_LEVEL_03 )
			case SEASON_SPRING:
				Sound.SetCurrentBGM( Sound.BGM_LEVEL_04 )
		end select
		Sound.PlayCurrentBGM()
	endif

	Snipe.SetInvincible = TRUE
	
	return Done
	
End function

''*****************************************************************************
''
''	State called after player dies and after moved to respawnpoint
''
''*****************************************************************************	
function Engine.StateEnd() as integer
	
	dim as string Text(0 to ...) =>_									
	{ "||the|end||" ,_
	"",_
	"",_
	"",_
	"THANK YOU MARIO,",_
	"BUT OUR PRINCESS IS IN ANOTHER CASTLE.",_
	"",_
	"OOPS! WRONG GAME.",_
	"",_
	"CONGRATULATIONS!",_
	"",_
	"YOU'VE DONE WELL MY LITTLE,",_
	"BEER-BELLIED, PINK BUNDLE OF",_
	"AWESOMENESS.",_
	"",_
	"THE ANDROBOTS(NO RELATION TO FEMBOTS)",_
	"LEFT AND THE SEASONS",_
	"ARE RESTORED TO NORMAL.",_
	"",_
	"THEIR LEADER, JOKE-IZ WAS NOWHERE",_
	"TO BE FOUND THOUGH.",_
	"",_
	"SO, PERHAPS, A SEQUEL IS IN",_
	" ORDER? WE'LL SEE, IF PYROMAX DAX",_
	"'DA RETURN OF DA COMEBACK'",_
	"GETS THE LIGHT OF DAY.",_
	"",_
	"",_
	"THANK YOU",_
	"FOR PLAYING!",_
	"" }
	
	dim as integer Done = FALSE
	dim as integer Fade = FALSE
	dim as single t = 0
	dim as single t2 = 0
	dim as single Scroller = SCREEN_HEIGHT

	dim as Vector2D Tarps(3)
	for i as integer = 0 to ubound(Tarps)
		Tarps(i).x = rnd * SCREEN_WIDTH
		Tarps(i).y = rnd * SCREEN_HEIGHT
	next
	
	Sound.StopCurrentBGM()
	Sound.SetCurrentBGM( Sound.BGM_END )
	Sound.PlayCurrentBGM()

	dt = GL2D.GetDeltaTime( FPS, timer )
	
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			
			if( not Fade ) then
				t += 0.008
			else
				t -= 0.008
			endif
			
			t = UTIL.Clamp(t, 0.0, 1.0) 
			
			accumulator -= FIXED_TIME_STEP			
			
			Scroller -= 0.5
			if( Scroller < ( -(ubound(Text)-1) * 20 ) )  then
				Fade = TRUE
			endif	
			if( Scroller < ( -(ubound(Text)+3) * 20 ) )  then
				Done = TRUE
			endif
			
			Tarps(0).x = SCREEN_WIDTH\2 + (sin(Frame * 0.002) + sin(Frame * 0.005)) * 200
			Tarps(0).y = SCREEN_HEIGHT\2 + (cos(Frame * 0.006) + sin(Frame* 0.0015)) * 128
		
			Tarps(1).x = SCREEN_WIDTH\2 + (cos(Frame * 0.001) + sin(Frame * 0.00715)) * 200
			Tarps(1).y = SCREEN_HEIGHT\2 + (sin(Frame * 0.0016) + cos(Frame* 0.00215)) * 128
		
			Tarps(2).x = SCREEN_WIDTH\2 + (cos(Frame * 0.0052) + cos(Frame * 0.0035)) * 200
			Tarps(2).y = SCREEN_HEIGHT\2 + (sin(Frame * 0.0076) + sin(Frame* 0.0015)) * 128
			
			Tarps(3).x = SCREEN_WIDTH\2 + (cos(Frame * 0.00152) + sin(Frame * 0.00235)) * 200
			Tarps(3).y = SCREEN_HEIGHT\2 + (sin(Frame * 0.0036) + cos(Frame* 0.00715)) * 128
		
			GL2D.ClearScreen()
		
			GL2D.Begin2D()
			
			
				glColor4ub(255,255,255,255)
				
				GL2D.BoxFilled( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT,_
								GL2D_RGBA( 128,64,0,255 ) )
				
				for i as integer = 0 to ubound(Tarps)
					GL2D.SpriteRotateScaleXY( Tarps(i).x, Tarps(i).y, (Frame * 0.5) + i * 45, _
											  sin(((Frame) * 0.0173) + ((PI/2) * i)), 1, _
											  GL2D.FLIP_NONE, SeasonsImages(12+i) )
				next
	
				Gl2D.SetBlendMode( GL2D.BLEND_TRANS )
				
				for i as integer = 0 to ubound(Text)
					dim as string s = Text(i)
					glColor4ub(255,255,255,255)
					CenterText( Scroller + i * 20, 1, s )			    	
				next i	
				
				GL2D.SetBlendMode( GL2D.BLEND_ALPHA )
				GL2D.BoxFilledGradient( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT/2,_
										GL2D_RGBA( 0,12,0,255 ),_
										GL2D_RGBA( 0,0,0,0 ),_
										GL2D_RGBA( 0,0,0,0 ),_
										GL2D_RGBA( 0,12,0,255 ) )
				GL2D.BoxFilledGradient( 0, SCREEN_HEIGHT/2, SCREEN_WIDTH, SCREEN_HEIGHT,_
										GL2D_RGBA( 0,0,0,0 ),_
										GL2D_RGBA( 12,0,0,255 ),_
										GL2D_RGBA( 12,0,0,255 ),_
										GL2D_RGBA( 0,0,0,0 ) )
				
				
				GL2D.BoxFilled( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT,GL2D_RGBA( 0, 0, 0, (1-t) * 255 ) )
				
			GL2D.End2D()
		
			flip
		
		wend
				
		sleep 1,1
		
	Loop until ( Done )

	Done = FALSE
	
	CurrentWarpID = 1
	State = STATE_WARP
	
	Sound.StopCurrentBGM()
	
	return Done
	
End function

''*****************************************************************************
''
''	State called after player dies and after moved to respawnpoint
''
''*****************************************************************************	
function Engine.StateWarp() as integer
	
	dim as integer Done = FALSE
	dim as single t = 0
	dim as single t2 = 3
	
	dt = GL2D.GetDeltaTime( FPS, timer )
	
	if( (CurrentLevel + 1) < 93 ) then
		do
			
			dt = GL2D.GetDeltaTime( FPS, timer )
			
			if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
			accumulator += dt
			SecondsElapsed += dt
			
			'' Update at a fixed timestep	
			while( accumulator >= FIXED_TIME_STEP )
			
				Frame += 1
				
				if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
					LeavesParticle.Update()
				endif
		
				t += 0.005
				t2 += 0.005
				if( t >= 1) then
					t = 1
					State = STATE_START
				endif
				
				accumulator -= FIXED_TIME_STEP			
				DrawStartEnd( UTIL.Clamp( 1-t, 0.0, 1.0 ), t2 )
			
			wend
					
			sleep 1,1
			
		loop until ( State <> STATE_WARP )

	endif
	
	State = STATE_START
	
	SpawnX = WarpScripts(CurrentWarpID-1).SpawnTileX * TILE_SIZE
	SpawnY = WarpScripts(CurrentWarpID-1).SpawnTileY * TILE_SIZE
	CurrentLevel = WarpScripts(CurrentWarpID-1).LevelNum - 1
	CurrentSeason = WarpScripts(CurrentWarpID-1).SeasonType
	Snipe.SetDx = 0
	Snipe.SetDy = 0
	Snipe.AddLives(1)
	
	LoadLevel( FALSE )
	
	return Done
	
End function

''*****************************************************************************
''
''	State called after player dies and after moved to respawnpoint
''
''*****************************************************************************	
function Engine.StateStageBossComplete() as integer
	
	dim as integer Done = FALSE
	dim as single t = 0
	dim as single t2 = 3
	dim as integer EnditCounter = 60 * 5
	
	dt = GL2D.GetDeltaTime( FPS, timer )
	
	Bullets.ExplodeAllEntities()
	
	
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			EnditCounter -= 1
			
			if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
				LeavesParticle.Update()
			endif
	
			if( (EnditCounter > 0)  ) then 
				if( (EnditCounter > (60 * 4)) ) then
					if( EnditCounter and 1) then
						dim as integer ang = rnd * (PI * 2)
						Explosion.Spawn( Vector3D(BossDieX + cos(ang) * 30, BossDieY + sin(ang) * 30, 4) , 2 )
					endif
				endif
				if( (EnditCounter > (60 * 3)) ) then
					if( (EnditCounter and 7) = 0 ) then
						Sound.PlaySFX( Sound.SFX_EXPLODE )
					endif
				endif

				HandleObjectUpdates()
			endif
   			
   			if( EnditCounter = 60 * 3 ) then
   				Sound.SetCurrentBGM(Sound.BGM_COMPLETE)
   				Sound.PlayCurrentBGM( FALSE )
   			endif
	
			if( EnditCounter <= 0 ) then
				t += 0.005
				t2 += 0.005
				if( t >= 1) then
					t = 1
					State = STATE_START
					HandleObjectDestructions()
					CurrentWarpID = 1   '' warp to next stage
				endif
			endif
			
			accumulator -= FIXED_TIME_STEP			
			DrawStartEnd( UTIL.Clamp( 1-t, 0.0, 1.0 ), t2 )
		
		wend
				
		sleep 1,1
		
	Loop until ( State <> STATE_STAGE_BOSS_COMPLETE )

	if( (CurrentLevel + 1) < 93 ) then
		SpawnX = WarpScripts(CurrentWarpID-1).SpawnTileX * TILE_SIZE
		SpawnY = WarpScripts(CurrentWarpID-1).SpawnTileY * TILE_SIZE
		CurrentLevel = WarpScripts(CurrentWarpID-1).LevelNum - 1
		CurrentSeason = WarpScripts(CurrentWarpID-1).SeasonType
		Snipe.SetDx = 0
		Snipe.SetDy = 0
		LoadLevel( FALSE )
	else
		if( Snipe.GetScore > HighScores(10).Score ) then
			InputName()
		endif
		State = STATE_END
	endif
	
	Sound.StopCurrentBGM()
	
	return Done
	
End function

''*****************************************************************************
''
''	State called after player dies and after moved to respawnpoint
''
''*****************************************************************************	
function Engine.StateStageBossFail() as integer
	
	dim as integer Done = FALSE
	dim as single t = 0
	dim as single t2 = 0
	dim as integer EnditCounter = 60 * 3
	
	dt = GL2D.GetDeltaTime( FPS, timer )
	
	Sound.SetCurrentBGM( Sound.BGM_GAME_OVER )
	Sound.PlayCurrentBGM( FALSE )
	
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			EnditCounter -= 1
			
			if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
				LeavesParticle.Update()
			endif
	
			if( EnditCounter <= 0 ) then
				t += 0.005
				if( t >= 1) then
					t = 1
					State = STATE_START
				endif
				DrawStartEnd( UTIL.Clamp( 1-t, 0.0, 1.0 ), t2 )
			else
				Draw()
			endif	
			
			accumulator -= FIXED_TIME_STEP			
			
		wend
		
		sleep 1,1
		
	Loop until ( State <> STATE_STAGE_BOSS_FAIL )

	HandleObjectDestructions()
	BossActive = TRUE
	select case (CurrentLevel+1)
		case 90:
			BossBigEyes.Spawn( BossSpawnX, BossSpawnY, 0  )
		case 91:
			BossGyrobots.Spawn( BossSpawnX, BossSpawnY, 0  )
		case 92:
			BossRobbits.Spawn( BossSpawnX, BossSpawnY, 0  )
		case 93:
			BossJokers.Spawn( BossSpawnX, BossSpawnY, 0  )
	end select

	Sound.StopCurrentBGM()
	
	return Done
	
End function


''*****************************************************************************
''
''	State called after player dies
''
''*****************************************************************************	
function Engine.StateMoveToSpawnArea() as integer
	
	dim as integer Done = FALSE
	dim as single t = 0
	
	dt = GL2D.GetDeltaTime( FPS, timer )
	
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			
			if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
				LeavesParticle.Update()
			endif
	
			Snipe.Update( Keys, Joy, Map() )     '' So we animate
 			
			t += 0.01
			if( t >= 1) then
				t = 1
				State = STATE_RESPAWN_PLAYER
			endif
			dim as single ix = UTIL.LerpSmooth( OldPlayerX, SpawnX, t )
			dim as single iy = UTIL.LerpSmooth( OldPlayerY, SpawnY, t )
			Snipe.SetX = ix
			Snipe.SetY = iy
			
			accumulator -= FIXED_TIME_STEP			
			Draw()
		
		wend
				
		sleep 1,1
		
	Loop until ( State <> STATE_MOVE_TO_SPAWN_AREA )

	return Done
	
End function

''*****************************************************************************
''
''	State called after player dies
''
''*****************************************************************************	
function Engine.StateRespawnPlayer() as integer
	
	dim as integer Done = FALSE
	dim as single t = 0
	dim as integer Countdown = 60 * 3
	
	Snipe.SetState(Player.FALLING)
	dt = GL2D.GetDeltaTime( FPS, timer )
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			Countdown -= 1
			
			if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
				LeavesParticle.Update()
			endif
				
			accumulator -= FIXED_TIME_STEP			
			Draw()
		
		wend
				
		sleep 1,1
		
	Loop until ( Countdown <= 0 )
	
	RespawnSnipe()
	State = STATE_PLAY
	
	return Done
	
End function

''*****************************************************************************
''
''	Game over state
''
''*****************************************************************************	

function Engine.StateGameOver() as integer
	
	dim as integer Done = FALSE
	dim as single t = 0
	dim as single t2 = 0
	dim as integer Endit = FALSE
	dim as integer GoOn = FALSE
	 
	Sound.StopCurrentBGM()
	Sound.SetCurrentBGM( Sound.BGM_GAME_OVER )
	Sound.PlayCurrentBGM( FALSE )
	
	dt = GL2D.GetDeltaTime( FPS, timer )
	
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			
			if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
				LeavesParticle.Update()
			endif
	
			if( Endit ) then
				t += 0.005
				if( t >= 1) then
					t = 1
					Done = TRUE
				endif
				DrawStartEnd( UTIL.Clamp( 1-t, 0.0, 1.0 ), t2 )
			else
				Draw()
			endif	
			
			accumulator -= FIXED_TIME_STEP			
			
		wend
		
		GetInput()
		
		if( PressedOk ) then
			Endit = TRUE
			GoOn = TRUE
		elseif( PressedCancel ) then
			Endit = TRUE
			GoOn = FALSE
		endif
		
		sleep 1,1
		
	loop until ( Done )

	Done = FALSE
	
	Sound.StopCurrentBGM()
	
	if( GoOn ) then
		if( Snipe.GetScore > HighScores(10).Score ) then
			InputName()
		endif
		PreviousState = STATE_GAME_OVER
		State = STATE_START
		Snipe.ContinueGame()
		select case CurrentSeason
			case SEASON_SUMMER:
				CurrentLevel = 0
				Sound.SetCurrentBGM( Sound.BGM_LEVEL_01 )
			case SEASON_FALL:
				CurrentLevel = 3
				Sound.SetCurrentBGM( Sound.BGM_LEVEL_02 )
			case SEASON_WINTER:
				CurrentLevel = 6
				Sound.SetCurrentBGM( Sound.BGM_LEVEL_03 )
			case SEASON_SPRING:
				CurrentLevel = 9
				Sound.SetCurrentBGM( Sound.BGM_LEVEL_04 )
		end select
		LoadLevel(TRUE)
		Snipe.Initialize()
		SpawnX = Snipe.GetX
		SpawnY = Snipe.GetY
		'Sound.PlayCurrentBGM()
		'Sound.PauseCurrentBGM()
		WindDirection = 0
		WindFrame = 0
		LeavesParticle.ResetAll()
	else 
		if( Snipe.GetScore > HighScores(10).Score ) then
			InputName()
		endif
		State = STATE_TITLE
	endif
	
	return Done
	
End function

''*****************************************************************************
''
''	Options screen state
''
''*****************************************************************************	

function Engine.StateOptions() as integer
	
	dim as integer Rows(0 to ...) =>_
									{ 65  ,_  '' 0
									  125 ,_  '' 1
									  185 ,_  '' 2
									  215 ,_  '' 3
									  255 ,_  '' 4
									  285 ,_  '' 5
									  315 ,_  '' 6
									  345 ,_  '' 7
									  385 ,_  '' 8
									  420 }   '' 9   
	
	dim as String Menu(0 to ...) =>_
									{ "BGM VOLUME"             ,_  '' 0
									  "SFX VOLUME"             ,_  '' 1
									  "SCREEN MODE       :"          ,_  '' 2
									  "SCREEN SIZE       :"          ,_  '' 3
									  "ENABLE VSYNCH     :"          ,_  '' 4
									  "FRAMELESS WINDOW  :"          ,_  '' 5
									  "SHOW FPS          :"          ,_  '' 6
									  "SHOW DIALOG TIPS  :"          ,_  '' 7
									  "RESTORE DEFAULTS   "          ,_  '' 8
									  "      SAVE AND RETURN TO TITLE     " }  '' 9   
	
	dim as String Help(0 to ...) =>_
									{ "CHANGE VOLUME OF BACKGROUND MUSIC"  ,_  '' 0
									  "CHANGE VOLUME OF SOUND EFFECTS"  ,_  '' 1
									  "FULL SCREEN OR WINDOWED" ,_  '' 2
									  "WINDOWED SCREEN SIZE" ,_  '' 3
									  "PREVENTS GFX 'SHEARING'" ,_  '' 4
									  "FRAMES ARE NOT SHOWN WHEN WINDOWED" ,_  '' 5
									  "SHOW NUMBER OF FRAMES PER SECOND" ,_  '' 6
									  "SPAWN IN-GAME DIALOG TIPS" ,_  '' 7
									  "RESTORE DEFAULT OPTIONS" ,_  '' 8
									  "SAVE CONFIG AND GO BACK TO TITLE SCREEN" }   '' 9   
	
	dim as integer MAX_CHOICE = ubound(Menu) + 1
	
	dim as integer Done = FALSE
	dim as integer OptionActive = 0
	dim as integer flow = 0
	dim as single t = 0
	dim as integer CanGetInput = FALSE
	dim as integer Save = FALSE
	
	dim as integer ScreenSizeIndex = 0
	select case PhysicalScreenWidth
		case 640
			ScreenSizeIndex = 0
		case 800
			ScreenSizeIndex = 1
		case 1024
			ScreenSizeIndex = 2
		case 320
			ScreenSizeIndex = 3
		case else
			ScreenSizeIndex = 0
	end select

	dim as VectorSpring Ypos
	Ypos.SetOy = Rows(0)
	Ypos.Sety = Rows(0)
	Ypos.Update()
	
	Sound.SetCurrentBGM( Sound.BGM_CREDITS )
	Sound.PlayCurrentBGM()

	dt = GL2D.GetDeltaTime( FPS, timer )
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			
			accumulator -= FIXED_TIME_STEP

			if( CanGetInput ) then
				if( Keys.Held( KeyLeft ) or Joy.Left() ) then 
					select case OptionActive
						case 0:
							Sound.SetMasterVolumeBGM( Sound.GetMasterVolumeBGM() - 1 )
						case 1:
							Sound.SetMasterVolumeSFX( Sound.GetMasterVolumeSFX() - 1 )
						case 2:
						case 3:
					End Select
				EndIf
				
				if( Keys.Held( KeyRight ) or Joy.Right() ) then 
					select case OptionActive
						case 0:
							Sound.SetMasterVolumeBGM( Sound.GetMasterVolumeBGM() + 1 )
						case 1:
							Sound.SetMasterVolumeSFX( Sound.GetMasterVolumeSFX() + 1 )
						case 2:
						case 3:
					end select
				endif
			endif
			
			
			if( flow = 0 ) then
				t += 0.01
				if( t > 1 ) then 
					t = 1
					CanGetInput = TRUE
				EndIf
			else
				CanGetInput = FALSE
				t -= 0.01
				if( t < 0 ) then 
					t = 0
					Done = TRUE
				EndIf
			endif
			
			
			Ypos.SetOy = Rows(OptionActive)
			Ypos.Update()
			DrawOptions( OptionActive, ScreenSizeIndex, Ypos, Rows(), Menu(), Help(), t )
		
		wend
		
		if( CanGetInput ) then 
		
			GetInput()
		
			if( PressedRight or PressedLeft ) then 
				select case OptionActive
					case 0:
					case 1:
					case 2:		'' Full Screen
						FullScreen = not FullScreen
						Sound.PlaySFX( Sound.SFX_CLICK )
						'ResetScreen()
					case 3:		'' Full Screen
						ScreenSizeIndex = (ScreenSizeIndex + 1) mod 4
						Sound.PlaySFX( Sound.SFX_CLICK )
					case 4:		'' Vsynch
						Vsynch = not Vsynch
						Sound.PlaySFX( Sound.SFX_CLICK )
					case 5:		'' Frame
						NoFrame = not NoFrame
						Sound.PlaySFX( Sound.SFX_CLICK )
					case 6:		'' Show FPS
						ShowFPS = Not ShowFPS
						Sound.PlaySFX( Sound.SFX_CLICK )
					case 7:		'' Show Dialogs
						ShowDialogs = Not ShowDialogs
						Sound.PlaySFX( Sound.SFX_CLICK )
					case 8:		'' default
					case 9:		'' Exit
	
				end select
			endif
			
			if( PressedOK or Keys.Pressed(KeyJump) or Joy.KeyPressed(JoyJump) ) then 
				if( OptionActive = (MAX_CHOICE-1) ) then
				endif
				select case OptionActive
					case 8:		'' default
						FullScreen = FALSE
						Vsynch = FALSE
						ShowFPS = FALSE
						ShowDialogs = TRUE
						NoFrame = FALSE
						ScreenSizeIndex = 0
						PhysicalScreenWidth = SCREEN_WIDTH
						PhysicalScreenHeight = SCREEN_HEIGHT
						MasterVolumeBGM = 128
						MasterVolumeSFX = 200
						Sound.SetMasterVolumeBGM( MasterVolumeBGM )
						Sound.SetMasterVolumeSFX( MasterVolumeSFX )
						Sound.PlaySFX( Sound.SFX_MENU_OK )
					case 9:		'' Exit
						flow = 1
						Save = TRUE
						Sound.PlaySFX( Sound.SFX_MENU_OK )		
				end select
			endif
			
			if( PressedCancel or Keys.Pressed(KeyAttack) or Joy.KeyPressed(JoyAttack) ) then 
				Sound.PlaySFX( Sound.SFX_CLICK )
				Save = FALSE
				flow = 1
			EndIf
			
			if( PressedDown ) then
				OptionActive = (OptionActive + 1) mod MAX_CHOICE
				Sound.PlaySFX( Sound.SFX_CLICK )
			EndIf
			
			if( PressedUp ) then 
				OptionActive = (OptionActive + (MAX_CHOICE - 1)) mod MAX_CHOICE
				Sound.PlaySFX( Sound.SFX_CLICK )
			endif
		
		endif
    			
		sleep 1,1
		
	Loop until ( Done )

	if( Vsynch ) then
		GL2D.VsyncOn()
	endif
	
	MasterVolumeBGM = Sound.GetMasterVolumeBGM()
	MasterVolumeSFX = Sound.GetMasterVolumeSFX()
	
	
	select case ScreenSizeIndex
		case 0
			PhysicalScreenWidth = SCREEN_WIDTH
			PhysicalScreenHeight = SCREEN_HEIGHT
		case 1
			PhysicalScreenWidth = 800
			PhysicalScreenHeight = 600
		case 2
			PhysicalScreenWidth = 1024
			PhysicalScreenHeight = 768
		case 3
			PhysicalScreenWidth = 320
			PhysicalScreenHeight = 240
		case else
			PhysicalScreenWidth = SCREEN_WIDTH
			PhysicalScreenHeight = SCREEN_HEIGHT
	end select
	
	if( FullScreen ) then
		PhysicalScreenWidth = SCREEN_WIDTH
		PhysicalScreenHeight = SCREEN_HEIGHT
	endif
	
	if( Save ) then SaveConfig( "PyromaxDax.cfg" )
	
	Done = FALSE
	State = STATE_TITLE
	
	Sound.StopCurrentBGM()
	
	return Done
	
End function

''*****************************************************************************
''
''	Title state
''
''*****************************************************************************	

function Engine.StateTitle() as integer
	
	dim as integer Done = FALSE
	const as integer CHOICES = 6
	const as integer DEGREE_STEPS = 360\CHOICES
	dim as integer AnimationDirection = 1
	dim as integer MenuAnimate = FALSE
	dim as integer MenuFrame = 0
	static as integer MenuAngle = 0
	
	static as integer Active = 0
	
	dim as single t = 0
	dim as integer flow = 0
	dim as integer CanGetInput = FALSE
	dim as integer PlayGame = FALSE

	ResetAll()
	
	Snipe.SetScore = 0
	
	Sound.StopCurrentBGM()
	Sound.SetCurrentBGM( Sound.BGM_TITLE )
	Sound.PlayCurrentBGM()

	dt = GL2D.GetDeltaTime( FPS, timer )
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			MenuFrame += 1
			
			if( MenuAnimate ) then
				MenuAngle = (MenuAngle + (DEGREE_STEPS\15) * AnimationDirection )
				MenuAngle = UTIL.Wrap( MenuAngle, 0, 360 )
				if( (MenuAngle mod DEGREE_STEPS) = 0 ) then
					MenuAnimate = FALSE
				EndIf
			EndIf
			
			
			accumulator -= FIXED_TIME_STEP
			
			if( flow = 0 ) then
				t += 0.01
				if( t > 1 ) then 
					t = 1
					CanGetInput = TRUE
				endif
			else
				CanGetInput = FALSE
				t -= 0.01
				if( t < 0 ) then 
					t = 0
					Done = TRUE
				endif
			endif
			
			DrawTitle( Active, MenuAngle, MenuFrame, PlayGame, t )
		
		wend
		
		if( CanGetInput ) then
			
			GetInput()
		
	    	if( not MenuAnimate ) then
		    	if( PressedRight ) then
		    		Sound.PlaySFX( Sound.SFX_CLICK )
					MenuAnimate = TRUE
					AnimationDirection = 1
					Active = (Active + 1) mod CHOICES
		    		MenuFrame = 0
		    	EndIf
				if( PressedLeft ) then 
					Sound.PlaySFX( Sound.SFX_CLICK )
					MenuAnimate = TRUE
					AnimationDirection = -1
					Active = (Active + (CHOICES - 1)) mod CHOICES
					MenuFrame = 0
				EndIf
	    	endif	
	    	
			if( PressedOK or Keys.Pressed(KeyJump) or Joy.KeyPressed(JoyJump) ) then 
				flow = 1
				Sound.PlaySFX( Sound.SFX_MENU_OK )
				if( Active = CHOICE_START_GAME ) then
					PlayGame = TRUE
					CanGetInput = FALSE
				endif
			endif
			if( PressedCancel or Keys.Pressed(KeyAttack) or Joy.KeyPressed(JoyAttack) ) then 
				Active = CHOICE_EXIT
				flow = 1
				CanGetInput = FALSE
			endif
		
		endif
    		
		sleep 1,1
		
	Loop until ( Done )


	Sound.StopCurrentBGM()


	Done = FALSE
	select case Active
		
		case CHOICE_START_GAME:
			State = STATE_START
			LoadLevel(TRUE)
			Snipe.Initialize()	
		case CHOICE_OPTIONS:
			State = STATE_OPTIONS
		case CHOICE_CONTROLS:
			State = STATE_CONTROLS
		case CHOICE_RECORDS:
			State = STATE_RECORDS
		case CHOICE_CREDITS:
			State = STATE_CREDITS
		case CHOICE_EXIT:
			SaveHighScores( "PyromaxDax.his" )
			Done = TRUE
		case else
			
	End Select

	
	
	
	return Done
	
End function

function Engine.StateCredits() as integer
	
	dim as string Items1(0 to ...) =>_									
	{ "||code||" ,_
	"RICHARD ERIC M. LOPE",_
	"HTTP://REL.PHATCODE.NET",_
	"",_
	"||graphics||",_
	"MARC RUSSELL (SPICYPIXEL.NET)",_
	"JOSEPH COLLINS",_
	"ARI FIELDMAN",_
	"ADIGUN A. POLACK",_
	"RICHARD ERIC M. LOPE",_
	"",_
	"||music|and|sfx||",_
	"VGMUSIC.COM",_
	"",_
	"||design||",_
	"ANYA THERESE B. LOPE",_
	"",_
	"||devtools||",_
	"EASY GL2D (REL.PHATCODE.NET)    ",_
	"FREEBASIC (FREEBASIC.NET)       ",_
	"OPENGL    (OPENGL.ORG)          ",_
	"FMOD      (FMOD.ORG)            ",_
	"FBEDIT    (FBEDIT.FREEBASIC.NET)" }
	
	dim as string Items2(0 to ...) =>_									
	{ "||greetz||",_
	"GOD",_
	"ROSE LOPE",_
	"PETER LOPE",_
	"LILY LOPE",_
	"MARIE CRISTINA ABEJUELA",_
	"CRISTINA MARIE SENOSA",_
	"RICH ABEJUELA",_
	"STANLEY SENOSA",_
	"DR DAVENSTEIN",_
	"V1CTOR",_
	"PLASMA",_
	"JOFERS",_
	"PIPTOL",_
	"JOCKE",_
	"LACHIE",_
	"L_O_J",_
	"MICHAEL NISSEN",_
	"HELLFIRE",_
	"SHOCKWAVE",_
	"VALDIR (DUDEABOT) SALGUERO",_
	"OXBADCODE",_
	"RYAN DA RHYNO" }

	dim as string Items3(0 to ...) =>_									
	{ "||greetz||",_
	"MOTORHERP",_
	"VATOLOCO",_
	"JURASSIC PLAYER",_
	"ANOTHER WORLD",_
	"ZEROMUS",_
	"CEARN",_
	"DISCOSTEW",_
	"HEADKAZE",_
	"FLASH",_
	"SPACEFRACTAL",_
	"SVERX",_
	"DJ PETERS",_
	"DKL",_
	"BLITZ",_
	"NEKROPHIDIUS",_
	"WILDCARD",_
	"KRIS WINDSOR",_
	"FEROFAX",_
	"DAV",_
	"PIPTOL",_
	"PRITCHARD",_
	"COUNTING PINE" }

	dim as string Items4(0 to ...) =>_									
	{ "||greetz||",_
	"OPTIMUS",_
	"BADMRBOX",_
	"SMC",_
	"STONEMONKEY",_
	"JIM",_
	"BENNY!",_
	"RAIZOR",_
	"NZO",_
	"COMBATKING",_
	"LANDEEL",_
	"CLYDE",_
	"TAJ",_
	"TETRA",_
	"RBZ",_
	"HOTSHOT",_
	"PIXEL_OUTLAW",_
	"VA!N",_
	"NINOGENIO",_
	"RAIN_STORM",_
	"YALOOPY",_
	"MIND",_
	"SLINKS" }   

	dim as string Items5(0 to ...) =>_									
	{ "||greetz||",_
	"JONGE",_
	"OZ",_
	"X-OUT",_
	"ZAWRAN",_
	"MORIAH, MAGAN AND KELLY STANLEY",_
	"NATHAN",_
	"SSJX",_
	"",_
	"PHATCODE.NET",_
	"FREEBASIC.NET",_
	"DEVKITPRO.ORG",_
	"GBATEMP.NET",_
	"SHMUP-DEV.COM",_
	"SHMUPS.COM",_
	"SYMBIANIZE.COM",_
	"GBADEV.ORG",_
	"DBFINTERACTIVE.COM",_
	"GREATFLASH.CO.UK",_
	"GAMES.FREEBASIC.NET",_
	"ROMHACKING.NET",_
	"",_
	"AND ALL THOSE I FORGOT." }   


	redim as string Items( ubound(Items1) )									  
	for i as integer = 0 to ubound(Items)
		Items(i) = Items1(i)	
	Next
	
	redim as integer Xpos( ubound(Items) )
	for i as integer = 0 to ubound(Items)
		Xpos(i) = (SCREEN_WIDTH - (16 * len( Items(i) )))/2
	next i	
	
	dim as integer Done = FALSE
	dim as single t = 0
	dim as integer flow = 0
	dim as integer PressedButton = FALSE
	dim as integer FrameCounter = 0
	const as integer AnimationDelay = 60 * 7
	dim as integer GroupNumber = 0
	
	Sound.SetCurrentBGM( Sound.BGM_CREDITS )
	Sound.PlayCurrentBGM()
	
	GL2D.ClearScreen()
	
	dt = GL2D.GetDeltaTime( FPS, timer )
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			FrameCounter += 1
			
			if( flow = 0 ) then
				t += 0.01
			else
				t -= 0.01
				if( PressedButton ) then
					if( t <= 0 ) then
						Done = TRUE
					endif
				endif
			endif
			t = UTIL.Clamp( t, 0.0, 1.0 )
			
			accumulator -= FIXED_TIME_STEP
			
			DrawCredits( Items(), Xpos(), SMOOTH_STEP(t) )
		
		wend
		
		'' Enter da dragon
		if( flow = 0 ) then
			if( FrameCounter >= AnimationDelay ) then
				flow = not flow
				FrameCounter = 0
			endif
		else	'' Egress da dragon
			if( FrameCounter >= (AnimationDelay/5) ) then
				flow = not flow
				FrameCounter = 0
				if( not PressedButton ) then GroupNumber = (GroupNumber + 1) mod 5
				select case GroupNumber
					case 0
						redim as string Items( ubound(Items1) )									  
						for i as integer = 0 to ubound(Items)
							Items(i) = Items1(i)	
						next			
					case 1
						redim as string Items( ubound(Items2) )									  
						for i as integer = 0 to ubound(Items)
							Items(i) = Items2(i)	
						next
					case 2
						redim as string Items( ubound(Items3) )									  
						for i as integer = 0 to ubound(Items)
							Items(i) = Items3(i)	
						next
					case 3
						redim as string Items( ubound(Items4) )									  
						for i as integer = 0 to ubound(Items)
							Items(i) = Items4(i)	
						next
					case 4
						redim as string Items( ubound(Items5) )									  
						for i as integer = 0 to ubound(Items)
							Items(i) = Items5(i)	
						next
				end select
				
				redim as integer Xpos( ubound(Items) )
				for i as integer = 0 to ubound(Items)
					Xpos(i) = (SCREEN_WIDTH - (16 * len( Items(i) )))/2
				next i	
				
			endif
		endif
		
		GetInput()
    	
		if( PressedOK or PressedCancel  or Keys.Pressed(KeyJump) or Keys.Pressed(KeyAttack) or Joy.KeyPressed(JoyJump) or Joy.KeyPressed(JoyAttack) ) then 
			flow = 1
			PressedButton = TRUE
		endif
		
		sleep 1,1
		
	Loop until ( Done )

	Done = FALSE
	State = STATE_TITLE
	Sound.StopCurrentBGM()

	return Done
	
End function

function Engine.StateControls() as integer
	
	dim as integer Rows(0 to ...) =>_
									{ 65  ,_  '' 0
									  95 ,_  '' 1
									  125 ,_  '' 2
									  155 ,_  '' 3
									  215 ,_  '' 4
									  245 ,_  '' 5
									  305 ,_  '' 6
									  335 ,_  '' 7
									  385 ,_  '' 8
									  420 }   '' 9   
	
	dim as String Menu(0 to ...) =>_
								{ 	"|||up|||||||:          :",_
									"|||down|||||:          :",_
									"|||left|||||:          :",_
									"|||right||||:          :",_
									"|||jump|||||:          :",_
									"|||attack|||:          :",_
									"|||ok|||||||:          :",_
									"|||cancel|||:          :",_
									"        |restore|defaults|",_
									"     |save|and|return|to|title|    " }  '' 8   
	
	dim as integer Scancodes(0 to ...) =>_
								{	FB.SC_UP,_
									FB.SC_DOWN,_  
									FB.SC_LEFT,_  
									FB.SC_RIGHT,_  
									FB.SC_SPACE,_  
									FB.SC_Z,_  
									FB.SC_ENTER,_  
									FB.SC_ESCAPE,_
									0,_  
									0 }	              '' 8   
	
	dim as integer Joycodes(0 to ...) =>_
								{	0,_
									0,_  
									0,_  
									0,_  
									JoyJump,_  
									JoyAttack,_  
									JoyOk,_  
									JoyCancel,_
									0,_  
									0 }	              '' 8   
	
	Scancodes(0) = KeyUp
	Scancodes(1) = KeyDown
	Scancodes(2) = KeyLeft
	Scancodes(3) = KeyRight
	Scancodes(4) = KeyJump
	Scancodes(5) = KeyAttack
	Scancodes(6) = KeyOk
	Scancodes(7) = KeyCancel
	
	dim as integer JoyButtonCode(0 to 15)
	
	for i as integer = 0 to 15
		JoyButtonCode(i) = 1 shl i
	next
	
	dim as integer MAX_CHOICE = ubound(Menu) + 1
	
	dim as integer Done = FALSE
	dim as integer OptionActive = 0
	dim as integer flow = 0
	dim as single t = 0
	dim as integer CanGetInput = FALSE
	dim as integer Save = FALSE
	dim as integer WaitForKeypress = 0
	
	dim as VectorSpring Ypos
	Ypos.SetOy = Rows(0)
	Ypos.Sety = Rows(0)
	Ypos.Update()
	
	Sound.SetCurrentBGM( Sound.BGM_CREDITS )
	Sound.PlayCurrentBGM()

	dt = GL2D.GetDeltaTime( FPS, timer )
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			
			accumulator -= FIXED_TIME_STEP

			
			if( flow = 0 ) then
				t += 0.01
				if( t > 1 ) then 
					t = 1
					CanGetInput = TRUE
				EndIf
			else
				CanGetInput = FALSE
				t -= 0.01
				if( t < 0 ) then 
					t = 0
					Done = TRUE
				EndIf
			endif
			
			
			Ypos.SetOy = Rows(OptionActive)
			Ypos.Update()
			DrawControls( OptionActive, WaitForKeyPress, Ypos, Rows(), Menu(), Scancodes(), JoyCodes(), t )
		
		wend
		
		if( CanGetInput ) then 
		
			GetInput()
		
	    	if( PressedOK or Keys.Pressed(KeyJump) or Joy.KeyPressed(JoyJump) ) then 
				select case OptionActive
					case 8:		'' default
						Sound.PlaySFX( Sound.SFX_MENU_OK )
						KeyUp = FB.SC_UP
						KeyDown = FB.SC_DOWN
						KeyLeft = FB.SC_LEFT
						KeyRight = FB.SC_RIGHT
						KeyJump = FB.SC_SPACE
						KeyAttack = FB.SC_Z
						KeyOk = FB.SC_ENTER
						KeyCancel = FB.SC_ESCAPE
						Scancodes(0) = KeyUp
						Scancodes(1) = KeyDown
						Scancodes(2) = KeyLeft
						Scancodes(3) = KeyRight
						Scancodes(4) = KeyJump
						Scancodes(5) = KeyAttack
						Scancodes(6) = KeyOk
						Scancodes(7) = KeyCancel
		
						JoyJump = JOY_KEY_2
						JoyAttack = JOY_KEY_1
						JoyOk = JOY_KEY_3
						JoyCancel = JOY_KEY_4
						Joycodes(4) = JoyJump
						Joycodes(5) = JoyAttack
						Joycodes(6) = JoyOk
						Joycodes(7) = JoyCancel
						
					case 9:		'' Exit
						flow = 1
						Save = TRUE
						
						KeyUp = Scancodes(0)
						KeyDown = Scancodes(1)
						KeyLeft = Scancodes(2)
						KeyRight = Scancodes(3)
						KeyJump = Scancodes(4)
						KeyAttack = Scancodes(5)
						KeyOk = Scancodes(6)
						KeyCancel = Scancodes(7)
						
						JoyJump = Joycodes(4)
						JoyAttack = Joycodes(5)
						JoyOk = Joycodes(6)
						JoyCancel = Joycodes(7)
						
						Sound.PlaySFX( Sound.SFX_MENU_OK )
					case else
						WaitForKeypress = not WaitForKeypress
						Sound.PlaySFX( Sound.SFX_MENU_OK )
				end select
			endif
			
			if( PressedCancel or Keys.Pressed(KeyAttack) or Joy.KeyPressed(JoyAttack) ) then 
				if( not WaitForKeypress ) then
					Sound.PlaySFX( Sound.SFX_CLICK )
					Save = FALSE
					flow = 1
				else
					WaitForKeypress = FALSE
				endif
			EndIf
			
			if( PressedDown ) then
				OptionActive = (OptionActive + 1) mod MAX_CHOICE
				Sound.PlaySFX( Sound.SFX_CLICK )
			EndIf
			
			if( PressedUp ) then 
				OptionActive = (OptionActive + (MAX_CHOICE - 1)) mod MAX_CHOICE
				Sound.PlaySFX( Sound.SFX_CLICK )
			EndIf
			
			if( WaitForKeyPress ) then
				for Keycode as integer = 1 to 127
				'' test keypress
					if Keys.Pressed(Keycode) then
						Scancodes(OptionActive) = Keycode
						WaitForKeyPress = FALSE
						exit for
					end if
				next
				
				for JoyButton as integer = 0 to 15
					if( Joy.KeyPressed( JoyButtonCode(JoyButton) ) ) then
						Joycodes(OptionActive) = JoyButtonCode(JoyButton)
						WaitForKeyPress = FALSE
						exit for
					endif
				next
	
			endif
		
		endif
    			
		sleep 1,1
		
	Loop until ( Done )

	if( Save ) then 
		SaveControls( "PyromaxDaxKey.cfg" )
		Snipe.LoadControls( "PyromaxDaxKey.cfg" )	
	endif
	
	Done = FALSE
	State = STATE_TITLE
	
	Sound.StopCurrentBGM()
	
	return Done
	
End function

function Engine.StateRecords() as integer
		
	dim as integer Done = FALSE
	dim as single t = 0
	dim as integer flow = 0
	dim as integer PressedButton = FALSE
	dim as integer FrameCounter = 0
	const as integer AnimationDelay = 60 * 7
	dim as integer GroupNumber = 0
	
	Sound.SetCurrentBGM( Sound.BGM_CREDITS )
	Sound.PlayCurrentBGM()
	
	GL2D.ClearScreen()
	
	dt = GL2D.GetDeltaTime( FPS, timer )
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		dim as integer Blinker = (int( SecondsElapsed * 2 ) and 1)
	
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			FrameCounter += 1
			
			if( flow = 0 ) then
				t += 0.01
				if( t > 1 ) then 
					t = 1
				endif
			else
				t -= 0.01
				if( t < 0 ) then 
					t = 0
					Done = TRUE
				endif
			endif
			
			
			accumulator -= FIXED_TIME_STEP			
			
			GL2D.ClearScreen()
	
			GL2D.Begin2D()
				ResizeScreen()
				
				Gl2D.SetBlendMode( GL2D.BLEND_TRANS )
				
				GL2D.Sprite( 0,0, GL2D.FLIP_NONE, GUIImages(10) )
				
				dim as single col = abs(sin(Frame * 0.03))
				glColor4f(col,1-col,col,1)
				CenterText( UTIL.LerpSmooth( 500, 10, t ), 2, "||hall|of|fame||" )
				
				glColor4f(1,1,1,1)
				dim as integer ix
				for i as integer = 0 to ubound(HighScores) - 1
					dim as string MyName = string( 16-len(trim(HighScores(i).Myname)), " " ) & HighScores(i).Myname
					ix = UTIL.LerpSmooth( 650 + (ubound(HighScores) - i) * 100, 50, SMOOTH_STEP(t) )
					GL2D.PrintScale( ix,  70 + i * 40, 1, Myname & " ------ " & UTIL.Int2Score( HighScores(i).Score, 7,"0") )    
				next i
				
				if( Blinker and (t >= 1) ) then CenterText( 470, 0.5, "PRESS |enter/ok| OR |escape/cancel| TO GO BACK" )
				
			GL2D.End2D()
		
			flip
			
		wend
		
		
		GetInput()
    	
		if( PressedOK or PressedCancel  or Keys.Pressed(KeyJump) or Keys.Pressed(KeyAttack) or Joy.KeyPressed(JoyJump) or Joy.KeyPressed(JoyAttack) ) then 
			flow = 1
		endif
		
		sleep 1,1
		
	Loop until ( Done )

	Done = FALSE
	State = STATE_TITLE
	Sound.StopCurrentBGM()

	return Done
	
End function

function Engine.StateIntermission() as integer
	
	dim as string Items(0 to ...) =>_									
  { "    BOMBS  LEFT  1000 X   =",_
	"DYNAMITES  LEFT  1000 X   =",_
	"    MINES  LEFT  1000 X   =",_
	"    LIVES  LEFT  5000 X   =",_
	"            TOTAL BONUS   =",_
	"            TOTAL SCORE   =" }
	

	dim as integer Xpos( ubound(Items) )
	for i as integer = 0 to ubound(Items)
		Xpos(i) = 10
	next i	
	
	dim as integer ScoreValue( ubound(Items) )
	ScoreValue(0) = 1000 * Snipe.GetBombs
	ScoreValue(1) = 1000 * Snipe.GetDynamites
	ScoreValue(2) = 1000 * Snipe.GetMines
	ScoreValue(3) = 5000 * Snipe.GetLives
	ScoreValue(4) = ScoreValue(0) + ScoreValue(1) + ScoreValue(2) + ScoreValue(3)
	ScoreValue(5) = Snipe.GetScore 
	
	dim as integer Orig(ubound(ScoreValue))
	for i as integer = 0 to ubound(Orig)
		Orig(i) = ScoreValue(i)
	next
	
	dim as integer Done = FALSE
	dim as integer flow = 0
	dim as single t = 0
	dim as single t2 = 0
	dim as integer PressedButton = FALSE
	dim as integer StartAnimationFrame = 60 * 2
	dim as integer MyFrame = 0
	 
	Sound.StopCurrentBGM()
	Sound.SetCurrentBGM( Sound.BGM_INTERMISSION  )
	Sound.PlayCurrentBGM( TRUE )

	GL2D.ClearScreen()
	
	dt = GL2D.GetDeltaTime( FPS, timer )

	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			MyFrame += 1

			
			if( MyFrame >= StartAnimationFrame ) then						
				
				if( MyFrame = StartAnimationFrame ) then 
					Sound.StopCurrentBGM()
					Sound.PlaySFX( Sound.SFX_YAHOO )
				endif
	
				if( flow = 0 ) then
					t += 0.01
					if( t >= 1 ) then
						t2 + = 0.005
						t2 = UTIL.Clamp( t2, 0.0, 1.0 )
						for i as integer = 0 to ubound(orig)-1
							ScoreValue(i) = UTIL.Lerp( Orig(i), 0, t2 )
						next
						ScoreValue(5) = UTIL.Lerp( Orig(5), Orig(5) + Orig(4), t2 )
						Snipe.SetScore( ScoreValue(5) )
						if( t2 < 1 ) then
							if( (Frame and 3) = 0 ) then
								Sound.PlaySFX( Sound.SFX_CLICK )
							endif
						endif
					endif
				else
					t -= 0.01
					if( PressedButton ) then
						if( t <= 0 ) then
							Done = TRUE
						endif
					endif
				endif
				
			endif
			
			t = UTIL.Clamp( t, 0.0, 1.0 )
			
			accumulator -= FIXED_TIME_STEP
			
			DrawIntermission( Items(), Xpos(), ScoreValue(), SMOOTH_STEP(t), SMOOTH_STEP(t2) )
	
		wend
		
		
		GetInput()
    	
		if( PressedOK or PressedCancel  or Keys.Pressed(KeyJump) or Keys.Pressed(KeyAttack) or Joy.KeyPressed(JoyJump) or Joy.KeyPressed(JoyAttack) ) then 
			flow = 1
			if( not PressedButton ) then
				for i as integer = 0 to ubound(orig)-1
					ScoreValue(i) = 0
				next
				Snipe.AddToScore( Orig(4) )
				Snipe.SetScore(Orig(4)+Orig(5))
				ScoreValue(5) = Snipe.GetScore
			endif
			PressedButton = TRUE 							
		endif
		
		sleep 1,1
		
	Loop until ( Done )

	Done = FALSE
	
	Sound.StopCurrentBGM()

	State = STATE_WARP
	
	
	return Done
	
End function


function Engine.StateYesOrNo() as integer
	
	dim as integer Done = FALSE
	dim as integer PrintText = FALSE
	dim as integer CurrentChoice = 1
	dim as integer Okayed = FALSE
	dim as single t = 0
	dim as integer flow = 0
	dim as single SoundLerp = 0
	dim as integer Volume = MasterVolumeBGM \ 2
	
	Sound.PlaySFX( Sound.SFX_COIN_UP )
	
	dt = GL2D.GetDeltaTime( FPS, timer )
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			SoundLerp = Util.Clamp( SoundLerp + 0.05, 0.0, 1.0 )
			
			if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
				LeavesParticle.Update()
			endif
	
			if( flow = 0 ) then
				t += 0.05
				if( t > 1 ) then 
					t = 1
					PrintText = TRUE
				EndIf
			else
				t -= 0.1
				if( t < 0 ) then 
					t = 0
					if( Okayed ) then
						if( CurrentChoice = 0 ) then 
							State = STATE_TITLE
						else
							State = STATE_PLAY
						endif
					else
						State = STATE_PLAY
					endif
				endif
			endif
					
			accumulator -= FIXED_TIME_STEP
			
			DrawYesOrNo( SMOOTH_STEP(t), "EXIT TO TITLE?", PrintText, CurrentChoice )
			
			Sound.SetVolumeCurrentBGM( UTIL.LerpSmooth(MasterVolumeBGM, Volume, SoundLerp)  )
	

		wend
		
		
		GetInput()
    	
    	if( PressedRight ) then
    		CurrentChoice += 1
    		Sound.PlaySFX( Sound.SFX_MENU_OK )
    	endif
		
		if( PressedLeft ) then
    		CurrentChoice -= 1
    		Sound.PlaySFX( Sound.SFX_MENU_OK )
		endif
		
		CurrentChoice = CurrentChoice and 1
		
		if( (PressedOK or Keys.Pressed(KeyJump) or Joy.KeyPressed(JoyJump)) and PrintText ) then 
			Sound.PlaySFX( Sound.SFX_MENU_OK )
			flow = 1
			PrintText = FALSE
			Okayed = TRUE
		EndIf
		
		if( (PressedCancel or Keys.Pressed(KeyAttack) or Joy.KeyPressed(JoyAttack)) and PrintText ) then 
			if( PrintText ) then
				flow = 1
				PrintText = FALSE
				Okayed = FALSE
			endif
		EndIf
		
		sleep 1,1
		
	Loop until ( State <> STATE_YES_OR_NO )
	
	Sound.SetVolumeCurrentBGM( MasterVolumeBGM )
	
	if( CurrentChoice = 0 ) then
		Sound.StopCurrentBGM()
	else
		Sound.UnPauseCurrentBGM()
	endif
	
	return Done
	
end function

''*****************************************************************************
''
''	Dialog state
''
''*****************************************************************************	
function Engine.StateDialog() as integer
	
	
	dim as integer Done = FALSE
	dim as integer PrintText = FALSE
	
	dim as single t = 0
	dim as integer flow = 0
	dim as single SoundLerp = 0
	dim as integer Volume = MasterVolumeBGM \ 2
	
	Sound.PlaySFX( Sound.SFX_COIN_UP )
	
	dt = GL2D.GetDeltaTime( FPS, timer )
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			SoundLerp = Util.Clamp( SoundLerp + 0.05, 0.0, 1.0 )
			
			if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
				LeavesParticle.Update()
			endif
	
			if( flow = 0 ) then
				t += 0.05
				if( t > 1 ) then 
					t = 1
					PrintText = TRUE
				EndIf
			else
				t -= 0.1
				if( t < 0 ) then 
					t = 0
					State = STATE_PLAY
				EndIf
			endif
					
			accumulator -= FIXED_TIME_STEP
			
			DrawDialog( SMOOTH_STEP(t), DialogScripts(CurrentDialogID-1), PrintText )
			
			Sound.SetVolumeCurrentBGM( UTIL.LerpSmooth(MasterVolumeBGM, Volume, SoundLerp)  )
	

		wend
		
		
		GetInput()
    	
    	
		if( PressedOK or PressedCancel or Keys.Pressed(KeyJump) or Keys.Pressed(KeyAttack) or Joy.KeyPressed(JoyJump) or Joy.KeyPressed(JoyAttack) )  then 
			if( PrintText ) then
				flow = 1
				PrintText = FALSE
			endif
		endif
		
		sleep 1,1
		
	Loop until ( State <> STATE_DIALOG )
	
	Sound.SetVolumeCurrentBGM( MasterVolumeBGM )
	
	return Done
	
End function

function Engine.StateStory() as integer
	
	dim as string Text(0 to ...) =>_									
	{ "" ,_
		"",_
		"THERE WAS NO WARNING.",_
		"",_
		"THEY JUST ATTACKED FUZEDLANDIA",_
		"AND IMPRISONED ALMOST ALL OF",_ 
		"ITS INHABITANTS.",_
		"",_
		"THEY ARE CALLED THE ANDROBOTS",_ 
		"AND THEY LIKE MAYHEM MORE THAN",_
		"ANYTHING ELSE.",_
		"",_
		"THEY STARTED TO MESS AROUND WITH",_
		"THE SEASONS. FOR WHAT PURPOSE?",_  
		"NO ONE KNOWS.",_
		"",_
		"HOWEVER, THEY FORGOT THAT FUZEDLANDIA",_
		"HAS A PROTECTOR.  A MEMBER OF",_
		"THE BOMBADEER SQUAD,"_ 
		"AND HE'S PISSED HIS",_
		"FAVORITE SPA HAS BEEN TURNED INTO",_
		"A TOXIC LAVA FLOW.",_
		"",_
		"HE'S PINK, BEER-BELLIED AND HE LIKES",_
		"ANYTHING THAT EXPLODES.",_
		"HE IS...",_
		"", _
	"" }
	
	dim as integer Done = FALSE
	dim as single t = 0
	dim as single t2 = 0
	dim as single Scroller = SCREEN_HEIGHT
	
	Sound.StopCurrentBGM()
	Sound.SetCurrentBGM( Sound.BGM_INTRO )
	Sound.PlayCurrentBGM()

	dt = GL2D.GetDeltaTime( FPS, timer )
	
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			
			accumulator -= FIXED_TIME_STEP			
			
			t = UTIL.Clamp( t + 0.001, 0.0, 1.0 )
			Scroller -= 0.5
			if( Scroller < ( -(ubound(Text)+2) * 20 ) )  then
				Done = TRUE
			endif
		
			GL2D.ClearScreen()
		
			GL2D.Begin2D()
			
			
				glColor4ub(255,255,255,255)
				
				GL2D.SetBlendMode( GL2D.BLEND_TRANS )
				GL2D.BoxFilled( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT,_
								GL2D_RGBA( 64,128,0,255 ) )
				
				for i as integer = 0 to ubound(Text)
					dim as string s = Text(i)
					glColor4ub(255,255,255,255)
					CenterText( Scroller + i * 20, 1, s )			    	
				next i	
				
				
				GL2D.SetBlendMode( GL2D.BLEND_ALPHA )
				GL2D.BoxFilledGradient( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT/2,_
										GL2D_RGBA( 0,0,12,255 ),_
										GL2D_RGBA( 0,0,0,0 ),_
										GL2D_RGBA( 0,0,0,0 ),_
										GL2D_RGBA( 0,0,12,255 ) )
				GL2D.BoxFilledGradient( 0, SCREEN_HEIGHT/2, SCREEN_WIDTH, SCREEN_HEIGHT,_
										GL2D_RGBA( 0,0,0,0 ),_
										GL2D_RGBA( 12,0,0,255 ),_
										GL2D_RGBA( 12,0,0,255 ),_
										GL2D_RGBA( 0,0,0,0 ) )
				
				GL2D.BoxFilled( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT,_
								GL2D_RGBA( 0,0,0,(1-t)*255 ) )
				
			GL2D.End2D()
		
			flip
		
		wend
				
		sleep 1,1
		
		GetInput()
		
		if( PressedOK or PressedCancel  or Keys.Pressed(KeyJump) or Keys.Pressed(KeyAttack) or Joy.KeyPressed(JoyJump) or Joy.KeyPressed(JoyAttack) ) then 
			Done = TRUE
		endif
		
	Loop until ( Done )

	Done = FALSE
	State = STATE_TITLE
	
	Sound.StopCurrentBGM()
	
	return Done
	
End function

function Engine.StateSplash() as integer
	
	const as integer Delay = 60 * 5
	dim as integer Done = FALSE
	dim as single t = 0
	dim as single t2 = 0
	dim as integer NumImages = 4
	dim as integer MyFrame = 0
	dim as integer CurrentImage = 0
	dim as integer Animate = TRUE
	
	dt = GL2D.GetDeltaTime( FPS, timer )
	
	do
		
		dt = GL2D.GetDeltaTime( FPS, timer )
		
		if( dt > FIXED_TIME_STEP ) then dt = FIXED_TIME_STEP   '' limit dt so that we don't jerk around too much
		accumulator += dt
		SecondsElapsed += dt
		
		'' Update at a fixed timestep	
		while( accumulator >= FIXED_TIME_STEP )
		
			Frame += 1
			MyFrame += 1 
			
			
			if( (MyFrame mod Delay) = 0 ) then			
				if( CurrentImage < 4 ) then
					CurrentImage += 1
					Animate = TRUE
				else
					Done = TRUE
				endif
			endif
	
			if( Animate ) then
				t += 0.01
				if( t >= 1 ) then
					Animate = FALSE
					t = 0
					if( CurrentImage > 3 ) then Done = TRUE
				endif				
			endif
			accumulator -= FIXED_TIME_STEP			
			
		
			GL2D.ClearScreen()
		
			GL2D.Begin2D()
						
				Gl2D.SetBlendMode( GL2D.BLEND_ALPHA )
				if( Animate ) then
					if( (CurrentImage - 1) >= 0 ) then
						glColor4f( 1, 1, 1, 1 - t )
						GL2D.SpriteRotate( SCREEN_WIDTH\2, SCREEN_HEIGHT\2, 0, GL2D.FLIP_NONE, SplashesImages(UTIL.Clamp(CurrentImage - 1, 0, 3 ) ) )
					endif
					if( CurrentImage < 4 ) then
						glColor4f( 1, 1, 1, t )
						GL2D.SpriteRotate( SCREEN_WIDTH\2, SCREEN_HEIGHT\2, 0, GL2D.FLIP_NONE, SplashesImages(CurrentImage) )
					endif
				else
					if( CurrentImage < 4 ) then
						glColor4f( 1, 1, 1, 1 )
						GL2D.SpriteRotate( SCREEN_WIDTH\2, SCREEN_HEIGHT\2, 0, GL2D.FLIP_NONE, SplashesImages(CurrentImage) )
					endif
				endif		
			
			GL2D.End2D()
		
			flip
		
		wend
				
		sleep 1,1
		
	Loop until ( Done )

	Done = FALSE
	State = STATE_STORY

	return Done
	
End function

''*****************************************************************************
''
''
''
''*****************************************************************************
sub Engine.Draw()
	
	dim as integer Blinker = (int( SecondsElapsed * 1.5 ) and 1)
	
	'' Set up some opengl crap (some are not needed)
	glMatrixMode( GL_MODELVIEW )
	glLoadIdentity() 
	glPolygonMode( GL_FRONT, GL_FILL )
	glPolygonMode( GL_BACK, GL_FILL )
	glEnable( GL_DEPTH_TEST )
	glDepthFunc( GL_LEQUAL )
	
	glEnable( GL_TEXTURE_2D )
	glEnable( GL_ALPHA_TEST )
	glAlphaFunc(GL_GREATER, 0)

	
	'' Move cam according to player's pos
	'Cam.FollowFixed( Snipe.GetX, Snipe.GetY, Map() )
	
	Cam.Follow( Snipe.GetX, Snipe.GetY, Map() )
	
	'' reverse y direction for oldskool coords(FBGFX friendly)
	glScalef( 1, -1, 1 )
	
	'' Look
	Cam.Look()
	
	
	GL2D.ClearScreen()  '' no motion blur
	
	'glClear(GL_DEPTH_BUFFER_BIT)   ''use this for motion blur
	
	GL2D.SetBlendMode( GL2D.BLEND_TRANS )
	glColor4ub( 255, 255, 255, 255 )

	'' Draw 3D stuff
	glPushMatrix()   
	
		glPushMatrix()
			
			if( Globals.Quake() ) then
				glTranslatef(-2 + rnd * 4, -2 + rnd * 4 , 0 )
			endif
			DrawBG( Snipe.GetX, Snipe.GetY, Map(), SeasonsImages(CurrentSeason+4) )
			
			'' Use Tiles texture
			GL2D.SetBlendMode( GL2D.BLEND_TRANS )
			DrawMap( Snipe.GetX, Snipe.GetY, Map(), TilesImages() )
			
			HandleObjectRenders()
			
			'' Draw waters and mud
			'glDisable( GL_DEPTH_TEST)
			GL2D.SetBlendMode( GL2D.BLEND_BLENDED )
			DrawTransMap( Snipe.GetX, Snipe.GetY, Map(), TilesImages() )
			GL2D.SetBlendMode( GL2D.BLEND_TRANS )
			'glEnable( GL_DEPTH_TEST )
		
		glPopMatrix()
		
		select case State
		
			case STATE_PLAY:
			case STATE_PAUSE:
				Snipe.DrawIncendiaryMenu( ActiveIncendiary, IncendiaryMenuAngle, 50, Frame, IncendiariesImages() )
			case STATE_START:
			case STATE_GAME_OVER:
			case STATE_OPTIONS:
			case STATE_CONTROLS:
			case STATE_CREDITS:
			case STATE_TITLE:
			case STATE_DIALOG:
			case STATE_EXIT:
				
		End Select
		
	glPopMatrix()    
	
	
	GL2D.Begin2D()
		ResizeScreen()
		
		Gl2D.SetBlendMode( GL2D.BLEND_TRANS )
		
		if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
			if( not IsBossStage ) then LeavesParticle.DrawAll()
		endif
	
		select case State
		
			case STATE_PLAY:
			case STATE_PAUSE:
				if( Blinker ) then 
					GL2D.SpriteRotateScaleXY( SCREEN_WIDTH\2,_
							SCREEN_HEIGHT\2,_
							0,_
							1,_
							1,_
							GL2D.FLIP_NONE,_
							SeasonsImages(2) )
				else
					CenterText( 230, 1, "PRESS |arrow|keys| TO CHANGE INCENDIARY.")
					CenterText( 260, 1, "PRESS |ok| TO CONTINUE GAME.")
				EndIf
			case STATE_START:
			case STATE_GAME_OVER:
					if( Blinker ) then
						GL2D.SpriteRotateScaleXY( SCREEN_WIDTH\2,_
								SCREEN_HEIGHT\2,_
								0,_
								1,_
								1,_
								GL2D.FLIP_NONE,_
								SeasonsImages(0) )
					else
						CenterText( 230, 1, "PRESS |ok| TO CONTINUE.")
						CenterText( 260, 1, "PRESS |cancel| RETURN TO TITLE.")
					endif
			case STATE_OPTIONS:
			case STATE_CONTROLS:
			case STATE_CREDITS:
			case STATE_TITLE:
			case STATE_DIALOG:
			case STATE_RESPAWN_PLAYER:
				if( Blinker ) then 
					GL2D.SpriteRotateScaleXY( SCREEN_WIDTH\2,_
						SCREEN_HEIGHT\2,_
						0,_
						1,_
						1,_
						GL2D.FLIP_NONE,_
						SeasonsImages(3) )
				EndIf
			case STATE_EXIT:
				
		End Select
		
		DrawStatus()
		
		if( DebugMode ) then DrawDebug()
		
	GL2D.End2D()
	
	
	
	flip
		
End Sub


''*****************************************************************************
''
''
''
''*****************************************************************************
sub Engine.DrawTitle( byval Active as integer, byval MenuAngle as integer, byval MenuFrame as integer, byval PlayGame as integer, byval t as single  )

	
	dim as integer Blinker = (int( SecondsElapsed * 2 ) and 1)
	
	GL2D.ClearScreen()  '' no motion blur
	
	'glClear(GL_DEPTH_BUFFER_BIT)   ''use this for motion blur
	
	
	GL2D.Begin2D()
		ResizeScreen()
			
		
		Gl2D.SetBlendMode( GL2D.BLEND_TRANS )
		
		GL2D.Sprite( 0,0, GL2D.FLIP_NONE, GUIImages(10) )
		
		'' Motion blur
		'Gl2D.SetBlendMode( GL2D.BLEND_ALPHA )
		'GL2D.BoxFilled(0,0,SCREEN_WIDTH,SCREEN_HEIGHT,GL2D_RGBA(0,0,0,32))
		GL2D.SpriteRotateScaleXY (  SCREEN_WIDTH/2,_
									UTIL.LerpSmooth( 500, 240, SMOOTH_STEP(t)),_
									sin(SecondsElapsed * 10) * 5,_
									1,_
									1,_
									GL2D.FLIP_NONE,_
									GUIImages(12+Active) )
		
		CenterText( UTIL.LerpSmooth( -50, 0, SMOOTH_STEP(t)), 1, "HI-SCORE:" & UTIL.Int2Score(HiScore, 7, "0") )
		
		if( PlayGame ) then
			DrawDiamonds( UTIL.LerpSmooth( 64, 0, SMOOTH_STEP(t)), GL2D_RGBA(100, 128, 200, 255 ) )
		endif
		
		CenterText( UTIL.LerpSmooth( 650, 480-20, SMOOTH_STEP(t)), 1, "VER." & "1.0" )
			
	GL2D.End2D()
	
	
	glMatrixMode( GL_MODELVIEW )
	glLoadIdentity() 
	glPolygonMode( GL_FRONT, GL_FILL )
	glPolygonMode( GL_BACK, GL_FILL )
	glEnable( GL_DEPTH_TEST )
	glDepthFunc( GL_LEQUAL )
	
	glEnable( GL_TEXTURE_2D )
	glEnable( GL_ALPHA_TEST )
	glAlphaFunc(GL_GREATER, 0)

	gluLookAt( 0, 0, TILE_SIZE * 18,_    	'' camera pos
			   0, 0, 0,_     	   	'' camera target
               0, 1, 0)						'' Up

	'' reverse y direction for oldskool coords(FBGFX friendly)
	glScalef( 1, -1, 1 )
	
	'glClear(GL_DEPTH_BUFFER_BIT)   ''use this for motion blur
	
	Gl2D.SetBlendMode( GL2D.BLEND_TRANS )
	glColor4ub( 255, 255, 255, 255 )

	'' Draw 3D stuff
	glPushMatrix()
		
		dim as single iscale =  UTIL.LerpSmooth( 0, 1, SMOOTH_STEP(t))
		dim as integer iangle =  UTIL.LerpSmooth( 360 * 5, 0, SMOOTH_STEP(t))
		   
		dim as single c = 0.5 + abs(sin(SecondsElapsed * 1)) * 0.5
		
		glColor3f( c, c, 1 - c )
		GL2D.SpriteRotateScaleXY3D( 0,_
									-160,_
									FOREGROUND_PLANE + 10,_
									iangle,_
									iscale + (abs(sin(SecondsElapsed * 4)) * 0.6) * t,_
									iscale + (abs(sin(SecondsElapsed * 2)) * 0.4) * t,_
									GL2D.FLIP_NONE,_
									GUIImages(0) )
		glColor3f( 1, 1, 1 )
		
		DrawMainMenu( Active, MenuAngle, UTIL.LerpSmooth( 700, 150, SMOOTH_STEP(t)), MenuFrame )
		
		
	glPopMatrix()    
	
	
	flip
		
End Sub

sub Engine.DrawOptions( byval choice as integer, byval ScreenSizeIndex as integer, byref ypos as VectorSpring, Rows() as integer, Menu() as string, Help() as string, byval t as single )
	
	dim as integer Blinker = (int( SecondsElapsed * 0.5 ) and 1)
	
	GL2D.ClearScreen()
	GL2D.Begin2D()
		ResizeScreen()
		
		Gl2D.SetBlendMode( GL2D.BLEND_TRANS )
		GL2D.Sprite( 0,0, GL2D.FLIP_NONE, GUIImages(10) )
		GL2D.Sprite( 0, UTIL.LerpSmooth(-64, 0, SMOOTH_STEP(t)), GL2D.FLIP_NONE, GUIimages(11) )
		GL2D.Sprite( 0, UTIL.LerpSmooth(-32, 32, SMOOTH_STEP(t)), GL2D.FLIP_V, GUIimages(11) )
		GL2D.Sprite( 0, UTIL.LerpSmooth(480+64, 480-32, SMOOTH_STEP(t)), GL2D.FLIP_NONE, GUIimages(11) )
		
		
		dim as integer col = abs(sin(SecondsElapsed * 4)) * 127
		glColor4ub( 128+col, 255-col, 128+col,255)
		CenterText( UTIL.LerpSmooth(480, 20, SMOOTH_STEP(t)), 1, "OPTIONS" )
		
		
		glColor4ub(255,255,255,255)
		for i as integer = 0 to ubound(Menu)
			GL2D.PrintScale( UTIL.LerpSmooth(660 + i * 200, 30, SMOOTH_STEP(t)), Rows(i), 1, Menu(i) )
		Next

		dim as string a = "*"
		GL2D.PrintScale( UTIL.LerpSmooth(760 - 17 , 7, SMOOTH_STEP(t)), ypos.GetY , 1, a )
		
		col = abs(sin(SecondsElapsed * 4)) * 127
		glColor4ub( 128+col, 255-col, 128+col,255)
		GL2D.PrintScale( UTIL.LerpSmooth(660, 30, SMOOTH_STEP(t)), Rows(choice), 1, Menu(choice) )
		
		glColor4ub( 255,255,0,255)
		CenterText( UTIL.LerpSmooth(-30, 460, SMOOTH_STEP(t)), 1, Help(choice) )
		
		dim as integer ix = UTIL.LerpSmooth(740, 40, SMOOTH_STEP(t))
		GL2D.SpriteStretch( ix-16, UTIL.LerpSmooth(1740, Rows(0) + 16, SMOOTH_STEP(t)), 585, 38, GUIimages(1) )
		GL2D.SpriteStretch( ix-16, UTIL.LerpSmooth(740, Rows(1) + 16, SMOOTH_STEP(t)), 585, 38, GUIimages(1) )
		
		GL2D.SetBlendMode( GL2D.BLEND_GLOW )
		glColor4ub(255,255,255,255)
		
		dim as single Length = UTIL.Lerp( 1, 550, Sound.GetMasterVolumeBGM/255 )
		GL2D.LineGlow( ix, Rows(0) + 35, ix + Length, Rows(0) + 35, 32, GL2D_RGBA( 255, 255, 255, 255 ) )
		
		ix = UTIL.LerpSmooth(840, 40, SMOOTH_STEP(t))
		Length = UTIL.Lerp( 1, 550, Sound.GetMasterVolumeSFX/255 )
		GL2D.LineGlow( ix, Rows(1) + 35, ix + Length, Rows(1) + 35, 32, GL2D_RGBA( 255, 255, 255, 255 ) )
	
		
		GL2D.SetBlendMode( GL2D.BLEND_TRANS )
		
		ix = UTIL.LerpSmooth(650, 355, SMOOTH_STEP(t))
		
		dim as integer leng = 16 * 3
		
		'' Full Screen
		if( FullScreen ) then
			leng = len(ucase("|full|screen|"))
			leng = UTIL.Clamp( Leng - 1, 0, Leng )
			GL2D.SpriteStretch( ix - 7, Rows(2) - 9, 28 + Leng * 16 , 32, GUIimages(1) )
			GL2D.PrintScale( ix, Rows(2), 1, "|full|screen|" )
		else
			leng = len(ucase("|windowed|"))
			leng = UTIL.Clamp( Leng - 1, 0, Leng )
			GL2D.SpriteStretch( ix - 7, Rows(2) - 9, 28 + Leng * 16 , 32, GUIimages(1) )
			GL2D.PrintScale( ix, Rows(2), 1, "|windowed|" )
		endif
		
		select case ScreenSizeIndex
			case 0
				leng = len(ucase(" 640 X 480 "))
				leng = UTIL.Clamp( Leng - 1, 0, Leng )
				GL2D.SpriteStretch( ix - 7, Rows(3) - 9, 28 + Leng * 16 , 32, GUIimages(1) )
				GL2D.PrintScale( ix, Rows(3), 1, string(leng+1,"|") )
				GL2D.PrintScale( ix, Rows(3), 1, " 640 X 480 " )
			case 1
				leng = len(ucase(" 800 X 600 "))
				leng = UTIL.Clamp( Leng - 1, 0, Leng )
				GL2D.SpriteStretch( ix - 7, Rows(3) - 9, 28 + Leng * 16 , 32, GUIimages(1) )
				GL2D.PrintScale( ix, Rows(3), 1, string(leng+1,"|") )
				GL2D.PrintScale( ix, Rows(3), 1, " 800 X 600 " )
			case 2
				leng = len(ucase(" 1024 X 768 "))
				leng = UTIL.Clamp( Leng - 1, 0, Leng )
				GL2D.SpriteStretch( ix - 7, Rows(3) - 9, 28 + Leng * 16 , 32, GUIimages(1) )
				GL2D.PrintScale( ix, Rows(3), 1, string(leng+1,"|") )
				GL2D.PrintScale( ix, Rows(3), 1, " 1024 X 768 " )
			case 3
				leng = len(ucase(" 320 X 240 "))
				leng = UTIL.Clamp( Leng - 1, 0, Leng )
				GL2D.SpriteStretch( ix - 7, Rows(3) - 9, 28 + Leng * 16 , 32, GUIimages(1) )
				GL2D.PrintScale( ix, Rows(3), 1, string(leng+1,"|") )
				GL2D.PrintScale( ix, Rows(3), 1, " 320 X 240 " )
		end select
		
		'' Vsynch
		if( Vsynch ) then
			leng = len(ucase("|on|"))
			leng = UTIL.Clamp( Leng - 1, 0, Leng )
			GL2D.SpriteStretch( ix - 7, Rows(4) - 9, 28 + Leng * 16 , 32, GUIimages(1) )
			GL2D.PrintScale( ix, Rows(4), 1, "|on|" )
		else
			leng = len(ucase("|off|"))
			leng = UTIL.Clamp( Leng - 1, 0, Leng )
			GL2D.SpriteStretch( ix - 7, Rows(4) - 9, 28 + Leng * 16 , 32, GUIimages(1) )
			GL2D.PrintScale( ix, Rows(4), 1, "|off|" )
		endif
		
		'' Frameless window
		if( NoFrame ) then
			leng = len(ucase("|yes|"))
			leng = UTIL.Clamp( Leng - 1, 0, Leng )
			GL2D.SpriteStretch( ix - 7, Rows(5) - 9, 28 + Leng * 16 , 32, GUIimages(1) )
			GL2D.PrintScale( ix, Rows(5), 1, "|yes|" )
		else
			leng = len(ucase("|no|"))
			leng = UTIL.Clamp( Leng - 1, 0, Leng )
			GL2D.SpriteStretch( ix - 7, Rows(5) - 9, 28 + Leng * 16 , 32, GUIimages(1) )
			GL2D.PrintScale( ix, Rows(5), 1, "|no|" )
		endif
		
		'' Show FPS
		if( ShowFPS ) then
			leng = len(ucase("|yes|"))
			leng = UTIL.Clamp( Leng - 1, 0, Leng )
			GL2D.SpriteStretch( ix - 7, Rows(6) - 9, 28 + Leng * 16 , 32, GUIimages(1) )
			GL2D.PrintScale( ix, Rows(6), 1, "|yes|" )
		else
			leng = len(ucase("|no|"))
			leng = UTIL.Clamp( Leng - 1, 0, Leng )
			GL2D.SpriteStretch( ix - 7, Rows(6) - 9, 28 + Leng * 16 , 32, GUIimages(1) )
			GL2D.PrintScale( ix, Rows(6), 1, "|no|" )
		endif
		
		'' Show Dialogs
		if( ShowDialogs ) then
			leng = len(ucase("|yes|"))
			leng = UTIL.Clamp( Leng - 1, 0, Leng )
			GL2D.SpriteStretch( ix - 7, Rows(7) - 9, 28 + Leng * 16 , 32, GUIimages(1) )
			GL2D.PrintScale( ix, Rows(7), 1, "|yes|" )
		else
			leng = len(ucase("|no|"))
			leng = UTIL.Clamp( Leng - 1, 0, Leng )
			GL2D.SpriteStretch( ix - 7, Rows(7) - 9, 28 + Leng * 16 , 32, GUIimages(1) )
			GL2D.PrintScale( ix, Rows(7), 1, "|no|" )
		endif
		
		
		
		dim as integer iy = UTIL.LerpSmooth(480, Rows(Choice) + 22, SMOOTH_STEP(t))
		if( Blinker ) then
			if( Choice < 7 ) then
				CenterText( iy, 0.5, "|left or right| TO CHANGE VALUES" )
			else
				if( Choice = 7 ) then
					CenterText( iy, 0.5, "|enter/ok| TO RESTORE DEFAULTS" )
				else
					CenterText( iy, 0.5, "|enter/ok| TO CONFIRM SAVE AND RETURN TO TITLE" )
				endif
			endif
		else
			CenterText( iy, 0.5, "|escape/cancel| TO RETURN TO TITLE" )
		EndIf
	
			
	GL2D.End2D()
	
	flip
		
end sub

sub Engine.DrawControls( byval choice as integer, byval WaitForKeyPress as integer, byref ypos as VectorSpring, Rows() as integer, Menu() as string, Scancodes() as integer, JoyCodes() as integer, byval t as single )
	
	dim as integer Blinker = (int( SecondsElapsed * 0.5 ) and 1)
	
	GL2D.ClearScreen()
	GL2D.Begin2D()
		ResizeScreen()
		
		Gl2D.SetBlendMode( GL2D.BLEND_TRANS )
		GL2D.Sprite( 0,0, GL2D.FLIP_NONE, GUIImages(10) )
		GL2D.Sprite( 0, UTIL.LerpSmooth(-64, 0, SMOOTH_STEP(t)), GL2D.FLIP_NONE, GUIimages(11) )
		GL2D.Sprite( 0, UTIL.LerpSmooth(-32, 32, SMOOTH_STEP(t)), GL2D.FLIP_V, GUIimages(11) )
		GL2D.Sprite( 0, UTIL.LerpSmooth(480+64, 480-32, SMOOTH_STEP(t)), GL2D.FLIP_NONE, GUIimages(11) )
		
		dim as integer col = abs(sin(SecondsElapsed * 4)) * 127
		glColor4ub( 128+col, 255-col, 128+col,255)
		CenterText( UTIL.LerpSmooth(1480, 20, SMOOTH_STEP(t)), 1, "CONTROLS" )
		
		
		glColor4ub(255,255,255,255)
		for i as integer = 0 to ubound(Menu)
			GL2D.PrintScale( UTIL.LerpSmooth(660 + i * 200, 30, SMOOTH_STEP(t)), Rows(i), 1, Menu(i) )
		Next

		dim as string a = "*"
		GL2D.PrintScale( UTIL.LerpSmooth(760 - 17 , 7, SMOOTH_STEP(t)), ypos.GetY , 1, a )
		
		
		'' Wait for keypressed = true
		if( WaitForKeyPress and (Choice < (ubound(Rows)-1) )) then
			'' Keys
			dim as integer leng = len(ucase(UTIL.PrintKeyString(Scancodes(Choice))))
			leng = UTIL.Clamp( Leng - 1, 0, Leng )
			GL2D.SpriteStretch( 234, Rows(Choice) - 8, 48 + Leng * 16 , 32, GUIimages(1) )
			'' Joy
			if( (Choice > 3) and (Choice <= (ubound(menu)-2)) ) then
				dim as string JoyVal = "JOY BUTTON " & trim(str(len(bin(JoyCodes(Choice)))))
				leng = len(JoyVal)
				leng = UTIL.Clamp( Leng - 1, 0, Leng )
				GL2D.SpriteStretch( 410, Rows(Choice) - 8, 48 + Leng * 16 , 32, GUIimages(1) )
			endif
		endif
		
		'' Scancodes
		glColor4ub( 255, 255, 255, 255)
		for i as integer = 0 to ubound(Menu)
			GL2D.PrintScale( 250, UTIL.LerpSmooth(500 + i * 500, Rows(i), SMOOTH_STEP(t)), 1, ucase(UTIL.PrintKeyString(Scancodes(i))) )
		Next
		
		'' JoyCodes
		GL2D.PrintScale( 426, UTIL.LerpSmooth(500 + 0 * 1500, Rows(0), SMOOTH_STEP(t)), 1, "JOY UP" )
		GL2D.PrintScale( 426, UTIL.LerpSmooth(500 + 1 * 1500, Rows(1), SMOOTH_STEP(t)), 1, "JOY DOWN" )
		GL2D.PrintScale( 426, UTIL.LerpSmooth(500 + 2 * 1500, Rows(2), SMOOTH_STEP(t)), 1, "JOY LEFT" )
		GL2D.PrintScale( 426, UTIL.LerpSmooth(500 + 3 * 1500, Rows(3), SMOOTH_STEP(t)), 1, "JOY RIGHT" )
		for i as integer = 4 to (ubound(Menu) - 2)
			dim as string JoyVal = "JOY BUTTON " & str(len(bin(JoyCodes(i))))
			GL2D.PrintScale( 426, UTIL.LerpSmooth(500 + i * 1500, Rows(i), SMOOTH_STEP(t)), 1, Joyval )
		Next

		dim as integer iy = UTIL.LerpSmooth(480, Rows(Choice) + 22, SMOOTH_STEP(t))
		if( Blinker ) then
			if( Choice < 7 ) then
				if( not WaitForKeyPress ) then
					CenterText( iy, 0.5, "|enter/ok|then|press|key| TO CHANGE VALUES" )
				else
					CenterText( iy, 0.5, "|now|press|the|key|you|want|to|use|" )
				endif
			else
				if( Choice = 7 ) then
					CenterText( iy, 0.5, "|enter/ok| TO RESTORE DEFAULTS" )
				else
					CenterText( iy, 0.5, "|enter/ok| TO CONFIRM SAVE AND RETURN TO TITLE" )
				endif
			endif
		else
			if( not WaitForKeyPress ) then	
				CenterText( iy, 0.5, "|escape/cancel| TO RETURN TO TITLE" )
			else
				CenterText( iy, 0.5, "|escape/cancel| TO RESTORE OLD VALUE" )
			endif
		endif
	
		'' Active choice
		col = abs(sin(SecondsElapsed * 4)) * 127
		glColor4ub( 128+col, 255-col, 128+col,255)
		GL2D.PrintScale( UTIL.LerpSmooth(660, 30, SMOOTH_STEP(t)), Rows(choice), 1, Menu(choice) )
		
		'' Active Scancode
		GL2D.PrintScale( 250, UTIL.LerpSmooth(700 + Choice * 500, Rows(Choice), SMOOTH_STEP(t)), 1, ucase(UTIL.PrintKeyString(Scancodes(Choice))) )
		
		'' Active Joy
		if( (Choice > 3) and (Choice <= (ubound(menu)-2)) ) then
			dim as string JoyVal = "JOY BUTTON " & str(len(bin(JoyCodes(Choice))))
			GL2D.PrintScale( 426, UTIL.LerpSmooth(500 + Choice * 1500, Rows(Choice), SMOOTH_STEP(t)), 1, Joyval )
		endif	
	
	GL2D.End2D()
	
	flip
		
end sub

sub Engine.DrawCredits( Items() as string, Xpos() as integer, byval t as single )

	
	dim as integer Blinker = (int( SecondsElapsed * 2 ) and 1)
	dim as single t2 = SMOOTH_STEP(t)
	
	GL2D.ClearScreen()
	'glClear(GL_DEPTH_BUFFER_BIT)   ''use this for motion blur
	
	GL2D.Begin2D()
		ResizeScreen()
			
		
		'GL2D.SetBlendMode( GL2D.BLEND_ALPHA )
		'GL2D.BoxFilled( 0,0, SCREEN_WIDTH + 1, SCREEN_HEIGHT + 1, GL2D_RGBA(0,0,0,32) )
		
		Gl2D.SetBlendMode( GL2D.BLEND_TRANS )
		
		GL2D.Sprite( 0,0, GL2D.FLIP_NONE, GUIImages(10) )
		
		dim as integer ix
		for i as integer = 0 to ubound(Items)
			if( i and 1 ) then
				ix = UTIL.LerpSmooth( 650 + i * 60, Xpos(i), SMOOTH_STEP(t2) )
			else
				ix = UTIL.LerpSmooth( -400 - i * 60, Xpos(i), SMOOTH_STEP(t2) )
			endif
			
			GL2D.PrintScale( ix,  10 + i * 20, 1, Items(i) )    
		next i
		
		if( Blinker ) then CenterText( 470, 0.5, "PRESS |enter/ok| OR |escape/cancel| TO GO BACK" )
		
	GL2D.End2D()
	
	flip
		
End Sub

sub Engine.DrawIntermission( Items() as string, Xpos() as integer, ScoreValue() as integer, byval t as single, byval t2 as single )

	
	dim as integer Blinker = (int( SecondsElapsed * 2 ) and 1)
	static as integer f = 0
	
	if( (Frame and 3) = 0 ) then
		f = (f + 1) and 3
	endif
	
	'' Set up some opengl crap (some are not needed)
	glMatrixMode( GL_MODELVIEW )
	glLoadIdentity() 
	glPolygonMode( GL_FRONT, GL_FILL )
	glPolygonMode( GL_BACK, GL_FILL )
	glEnable( GL_DEPTH_TEST )
	glDepthFunc( GL_LEQUAL )
	
	glEnable( GL_TEXTURE_2D )
	glEnable( GL_ALPHA_TEST )
	glAlphaFunc(GL_GREATER, 0)

	
	'' Move cam according to player's pos
	'Cam.FollowFixed( Snipe.GetX, Snipe.GetY, Map() )
	
	Cam.Follow( Snipe.GetX, Snipe.GetY, Map() )
	
	'' reverse y direction for oldskool coords(FBGFX friendly)
	glScalef( 1, -1, 1 )
	
	'' Look
	Cam.Look()
	
	GL2D.ClearScreen()  '' no motion blur
	
	'glClear(GL_DEPTH_BUFFER_BIT)   ''use this for motion blur
	
	GL2D.SetBlendMode( GL2D.BLEND_TRANS )
	glColor4ub( 255, 255, 255, 255 )

	'' Draw 3D stuff
	glPushMatrix()   
	
		DrawBG( Snipe.GetX, Snipe.GetY, Map(), SeasonsImages(CurrentSeason+4) )
		
		'' Use Tiles texture
		GL2D.SetBlendMode( GL2D.BLEND_TRANS )
		DrawMap( Snipe.GetX, Snipe.GetY, Map(), TilesImages() )
		
		HandleObjectRenders()
		
	
		'' Draw waters and mud
		'glDisable( GL_DEPTH_TEST)
		GL2D.SetBlendMode( GL2D.BLEND_BLENDED )
		DrawTransMap( Snipe.GetX, Snipe.GetY, Map(), TilesImages() )
		GL2D.SetBlendMode( GL2D.BLEND_TRANS )
		'glEnable( GL_DEPTH_TEST )
	
		
	glPopMatrix()    
	
	
	GL2D.Begin2D()
		ResizeScreen()
	
		if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
			if( not IsBossStage ) then LeavesParticle.DrawAll()
		endif
		
		DrawStatus()
		
		GL2D.SetBlendMode( GL2D.BLEND_ALPHA )	
		glColor4f( 1, 1, 1, SMOOTH_STEP(t) * 0.5)
		
		dim as integer Px = 64 + UTIL.LerpSmooth(0, SCREEN_WIDTH\2, t)
		dim as integer Py = 64 + UTIL.LerpSmooth(0, SCREEN_HEIGHT\2, t)
		GL2D.SpriteStretch( SCREEN_WIDTH\2 - Px, SCREEN_HEIGHT\2 - Py, Px*2,  Py*2, GUIimages(1) )
	
		GL2D.SetBlendMode( GL2D.BLEND_TRANS )	
	
		glColor4f( 1, 1, 1, 1 )
		
		dim as integer ix
		for i as integer = 0 to ubound(Items)
			if( i and 1 ) then
				ix = UTIL.LerpSmooth( 650 + i * 60, Xpos(i), SMOOTH_STEP(t) )
			else
				ix = UTIL.LerpSmooth( -650 - i * 60, Xpos(i), SMOOTH_STEP(t) )
			endif
			
			GL2D.PrintScale( ix,  50 + i * 60, 1, Items(i) )    
			
			GL2D.PrintScale( ix + 450,  50 + i * 60, 1, str(ScoreValue(i)) )    
						
			if( (i < 3) ) then
				GL2D.Sprite( ix + 150, 50 + i * 60, GL2D.FLIP_NONE, EnemiesImages(80 + (i) * 4 + f) )
			endif
			
			select case i
				case 0:
					GL2D.PrintScale( ix + 375,  50 + i * 60, 1, UTIL.Int2Score(Snipe.GetBombs, 2, "0") )    	
				case 1:
					GL2D.PrintScale( ix + 375,  50 + i * 60, 1, UTIL.Int2Score(Snipe.GetDynamites, 2, "0") )    	
				case 2:
					GL2D.PrintScale( ix + 375,  50 + i * 60, 1, UTIL.Int2Score(Snipe.GetMines, 2, "0") )    	
				case 3:
					GL2D.PrintScale( ix + 375,  50 + i * 60, 1, UTIL.Int2Score(Snipe.GetLives, 2, "0") )    	
			end select
		next i
			
	GL2D.End2D()
	
	flip
	
End Sub

sub Engine.DrawMainMenu( byval activ as integer, byval Angle as integer, byval Radius as integer, byval count as integer )
	
	const as integer CHOICES = 6
	const as integer DEGREE_STEPS = 360\CHOICES
	
	dim as integer sBaseFrame =0
	dim as integer sFrame = (Count \ 8) and 3
	dim as integer CurrentAngle = Angle 
	dim as single sScale = 1 
	
	dim as single idx = 0
	 
	for i as integer = CurrentAngle to (359+CurrentAngle) step DEGREE_STEPS
		
		dim as integer mx = cos(i * PI/ 180 + PI/2) * Radius
		dim as integer mz = sin(i * PI/ 180 + PI/2) * Radius
		
		if( idx = activ ) then
			sScale = 0.5 + abs(sin(Count / 16)) * 0.7
			glColor4f( 1, 1, 1, 1 )	
		else
			sScale = 1
			glColor4f( 0.5, 0.5, 0.5, 1 )
		endif
		
		GL2D.SpriteRotateScaleXY3D( mx * 1.5,_
									-10 + mz/2,_
									FOREGROUND_PLANE + mz * 1.5,_
									0,_
									sScale,_
									sScale,_
									GL2D.FLIP_NONE,_
									GUIImages(2 + idx) )
		
		idx = (idx + (CHOICES - 1)) mod CHOICES
	
	next i

	glColor4f( 1, 1, 1, 1 )
		
		
End Sub

sub Engine.DrawDialog( byval t as single, byref Text as string, byval PrintText as integer )
	
	dim as integer Blinker = (int( SecondsElapsed * 2 ) and 1)
	
	'' Set up some opengl crap (some are not needed)
	glMatrixMode( GL_MODELVIEW )
	glLoadIdentity() 
	glPolygonMode( GL_FRONT, GL_FILL )
	glPolygonMode( GL_BACK, GL_FILL )
	glEnable( GL_DEPTH_TEST )
	glDepthFunc( GL_LEQUAL )
	
	glEnable( GL_TEXTURE_2D )
	glEnable( GL_ALPHA_TEST )
	glAlphaFunc(GL_GREATER, 0)

	
	'' Move cam according to player's pos
	'Cam.FollowFixed( Snipe.GetX, Snipe.GetY, Map() )
	
	Cam.Follow( Snipe.GetX, Snipe.GetY, Map() )
	
	'' reverse y direction for oldskool coords(FBGFX friendly)
	glScalef( 1, -1, 1 )
	
	'' Look
	Cam.Look()
	
	GL2D.ClearScreen()  '' no motion blur
	
	'glClear(GL_DEPTH_BUFFER_BIT)   ''use this for motion blur
	
	GL2D.SetBlendMode( GL2D.BLEND_TRANS )
	glColor4ub( 255, 255, 255, 255 )

	'' Draw 3D stuff
	glPushMatrix()   
	
		DrawBG( Snipe.GetX, Snipe.GetY, Map(), SeasonsImages(CurrentSeason+4) )
		
		'' Use Tiles texture
		GL2D.SetBlendMode( GL2D.BLEND_TRANS )
		DrawMap( Snipe.GetX, Snipe.GetY, Map(), TilesImages() )
		
		HandleObjectRenders()
		
	
		'' Draw waters and mud
		'glDisable( GL_DEPTH_TEST)
		GL2D.SetBlendMode( GL2D.BLEND_BLENDED )
		DrawTransMap( Snipe.GetX, Snipe.GetY, Map(), TilesImages() )
		GL2D.SetBlendMode( GL2D.BLEND_TRANS )
		'glEnable( GL_DEPTH_TEST )
	
		
	glPopMatrix()    
	
	
	GL2D.Begin2D()
		ResizeScreen()
		
		if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
			if( not IsBossStage ) then LeavesParticle.DrawAll()
		endif
	
		GL2D.SetBlendMode( GL2D.BLEND_ALPHA )	
	
		glColor4f( 1, 1, 1, SMOOTH_STEP(t) * 0.5)
		
		dim as integer Px = SCREEN_WIDTH - 320 * t
		dim as integer Py = SCREEN_HEIGHT - 320 * t
		GL2D.SpriteStretch( Px\2-48, Py\2-48,  64 + 350 * t,  64 + 150 * t, GUIimages(1) )
	
		GL2D.SetBlendMode( GL2D.BLEND_TRANS )	
	
		glColor4f( 1,1,1,1 )
		
		DrawStatus()
		
		if( PrintText ) then PrintDialog( 130, 55, 24, Text )
		
			
	GL2D.End2D()
	
	
	
	flip
	
	
		
end sub

sub Engine.DrawStartEnd( byval t as single, byval t2 as single )
	
	dim as integer Blinker = (int( SecondsElapsed * 1.5 ) and 1)
	
	'' Set up some opengl crap (some are not needed)
	glMatrixMode( GL_MODELVIEW )
	glLoadIdentity() 
	glPolygonMode( GL_FRONT, GL_FILL )
	glPolygonMode( GL_BACK, GL_FILL )
	glEnable( GL_DEPTH_TEST )
	glDepthFunc( GL_LEQUAL )
	
	glEnable( GL_TEXTURE_2D )
	glEnable( GL_ALPHA_TEST )
	glAlphaFunc(GL_GREATER, 0)

	
	'' Move cam according to player's pos
	'Cam.FollowFixed( Snipe.GetX, Snipe.GetY, Map() )
	
	Cam.Follow( Snipe.GetX, Snipe.GetY, Map() )
	
	'' reverse y direction for oldskool coords(FBGFX friendly)
	glScalef( 1, -1, 1 )
	
	'' Look
	Cam.Look()
	
	GL2D.ClearScreen()  '' no motion blur
	
	'glClear(GL_DEPTH_BUFFER_BIT)   ''use this for motion blur
	
	GL2D.SetBlendMode( GL2D.BLEND_TRANS )
	glColor4ub( 255, 255, 255, 255 )

	'' Draw 3D stuff
	glPushMatrix()   
	
		DrawBG( Snipe.GetX, Snipe.GetY, Map(), SeasonsImages(CurrentSeason+4) )
		
		'' Use Tiles texture
		GL2D.SetBlendMode( GL2D.BLEND_TRANS )
		DrawMap( Snipe.GetX, Snipe.GetY, Map(), TilesImages() )
		
		HandleObjectRenders()
		
	
		'' Draw waters and mud
		'glDisable( GL_DEPTH_TEST)
		GL2D.SetBlendMode( GL2D.BLEND_BLENDED )
		DrawTransMap( Snipe.GetX, Snipe.GetY, Map(), TilesImages() )
		GL2D.SetBlendMode( GL2D.BLEND_TRANS )
		'glEnable( GL_DEPTH_TEST )
	
		
	glPopMatrix()    
	
	
	GL2D.Begin2D()
		ResizeScreen()
		
		if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
			if( not IsBossStage ) then LeavesParticle.DrawAll()
		endif
			
		'' Seasons
		if( Blinker and (State = STATE_START) ) then
			if( ( not IsBossStage ) ) then
			GL2D.SpriteRotateScaleXY( SCREEN_WIDTH\2,_
									SCREEN_HEIGHT\2-50,_
									0,_
									1,_
									1,_
									GL2D.FLIP_NONE,_
									SeasonsImages(CurrentSeason+8) )
			else
				GL2D.SpriteRotateScaleXY( SCREEN_WIDTH\2,_
									SCREEN_HEIGHT\2-50,_
									0,_
									1,_
									1,_
									GL2D.FLIP_NONE,_
									SeasonsImages(3) )
			endif
		endif
		
		'' "GO"
		dim as integer ix
		if( t2 <= 1 ) then
			ix  = UTIL.LerpSmooth( -300, SCREEN_WIDTH\2, SMOOTH_STEP(t2) )
		else	
			ix  = UTIL.LerpSmooth( SCREEN_WIDTH\2, 640+300 , SMOOTH_STEP(t2-1) )
		endif
		GL2D.SpriteRotateScaleXY(   ix,_
									SCREEN_HEIGHT\2+50,_
									0,_
									1,_
									1,_
									GL2D.FLIP_NONE,_
									SeasonsImages(1) )
		
		
		DrawStatus()
		
		GL2D.SetBlendMode( GL2D.BLEND_ALPHA )
		DrawDiamonds( UTIL.LerpSmooth(64,0,SMOOTH_STEP(t)), GL2D_RGBA(100, 128, 200,UTIL.LerpSmooth(255,128,t)) )
	
			
	GL2D.End2D()
	
	flip
		
end sub

sub Engine.DrawYesOrNo( byval t as single, byref Text as string, byval PrintText as integer, byval Activ as integer )
	
	dim as integer Blinker = (int( SecondsElapsed * 2 ) and 1)
	
	'' Set up some opengl crap (some are not needed)
	glMatrixMode( GL_MODELVIEW )
	glLoadIdentity() 
	glPolygonMode( GL_FRONT, GL_FILL )
	glPolygonMode( GL_BACK, GL_FILL )
	glEnable( GL_DEPTH_TEST )
	glDepthFunc( GL_LEQUAL )
	
	glEnable( GL_TEXTURE_2D )
	glEnable( GL_ALPHA_TEST )
	glAlphaFunc(GL_GREATER, 0)

	
	'' Move cam according to player's pos
	'Cam.FollowFixed( Snipe.GetX, Snipe.GetY, Map() )
	
	Cam.Follow( Snipe.GetX, Snipe.GetY, Map() )
	
	'' reverse y direction for oldskool coords(FBGFX friendly)
	glScalef( 1, -1, 1 )
	
	'' Look
	Cam.Look()
	
	GL2D.ClearScreen()  '' no motion blur
	
	'glClear(GL_DEPTH_BUFFER_BIT)   ''use this for motion blur
	
	GL2D.SetBlendMode( GL2D.BLEND_TRANS )
	glColor4ub( 255, 255, 255, 255 )

	'' Draw 3D stuff
	glPushMatrix()   
	
		DrawBG( Snipe.GetX, Snipe.GetY, Map(), SeasonsImages(CurrentSeason+4) )
		
		'' Use Tiles texture
		GL2D.SetBlendMode( GL2D.BLEND_TRANS )
		DrawMap( Snipe.GetX, Snipe.GetY, Map(), TilesImages() )
		
		HandleObjectRenders()
		
	
		'' Draw waters and mud
		'glDisable( GL_DEPTH_TEST)
		GL2D.SetBlendMode( GL2D.BLEND_BLENDED )
		DrawTransMap( Snipe.GetX, Snipe.GetY, Map(), TilesImages() )
		GL2D.SetBlendMode( GL2D.BLEND_TRANS )
		'glEnable( GL_DEPTH_TEST )
	
		
	glPopMatrix()    
	
	
	GL2D.Begin2D()
		ResizeScreen()
	
		if( (CurrentSeason = SEASON_FALL) or ((CurrentLevel + 1) >=  11) ) then
			if( not IsBossStage ) then LeavesParticle.DrawAll()
		endif
	
		GL2D.SetBlendMode( GL2D.BLEND_ALPHA )	
		glColor4f( 1, 1, 1, SMOOTH_STEP(t) * 0.5)
		
		dim as integer Px = SCREEN_WIDTH - 320 * t
		dim as integer Py = SCREEN_HEIGHT - 100 * t
		GL2D.SpriteStretch( Px\2-48, Py\2-48,  64 + 350 * t,  64 + 100 * t, GUIimages(18) )
	
		GL2D.SetBlendMode( GL2D.BLEND_TRANS )	
	
		glColor4f( 1, 1, 1, 1 )
		
		DrawStatus()
		
		if( PrintText ) then 
			CenterText( 170, 1, Text )
			CenterText( 250, 1, "YES          NO" )
			glColor4f( abs(sin(SecondsElapsed*5)), abs(sin(SecondsElapsed*10)), abs(sin(SecondsElapsed*15)), 1 )
			if( Activ = 0 )  then 
				CenterText( 250, 1, "<    >            " )
			else
				CenterText( 250, 1, "             <   >" )
			endif
		EndIf
		
			
	GL2D.End2D()
	
	flip
		
end sub


sub Engine.DrawCollisionBoxes()
	
	Snipe.DrawAABB()
	
	Bullets.DrawCollisionBoxes()
	
	Wallers.DrawCollisionBoxes()
	Grogs.DrawCollisionBoxes()
	Wheelies.DrawCollisionBoxes()
	Jumpbots.DrawCollisionBoxes()
	Heliheads.DrawCollisionBoxes()
	Springers.DrawCollisionBoxes()
	Eyesores.DrawCollisionBoxes()
	Bouncers.DrawCollisionBoxes()
	Nails.DrawCollisionBoxes()
	Robats.DrawCollisionBoxes()
	Roboxs.DrawCollisionBoxes()
	Screwgatlings.DrawCollisionBoxes()
	Watchers.DrawCollisionBoxes()
	Megatons.DrawCollisionBoxes()
	Drumbots.DrawCollisionBoxes()
	Plasmos.DrawCollisionBoxes()
	
	DialogTriggers.DrawCollisionBoxes()
	PowBombs.DrawCollisionBoxes()
	PowDynamites.DrawCollisionBoxes()
	PowMines.DrawCollisionBoxes()
	PowEnergys.DrawCollisionBoxes()
	Warps.DrawCollisionBoxes()
	Checkpoints.DrawCollisionBoxes()
	
	FallingBlocks.DrawCollisionBoxes()
	
	BossBigEyes.DrawCollisionBoxes()
	BossJokers.DrawCollisionBoxes()
	BossRobbits.DrawCollisionBoxes()
	BossGyrobots.DrawCollisionBoxes()
	
end sub

sub Engine.DrawDebug()

	GL2D.PrintScale(0,  60, 0.5, "LEVEL = " & str(Currentlevel+1) )    
	GL2D.PrintScale(0,  70, 0.5, "DIALOGS = " & str(ubound(DialogScripts)) )    
	GL2D.PrintScale(0,  80, 0.5, "WARPS = " & str(ubound(WarpScripts)) )    
	GL2D.PrintScale(0,  100, 0.5, "MAPWIDTH = " & str(ubound(Map,1)) & " : " & str(MapWidth) )    
	GL2D.PrintScale(0,  110, 0.5, "MAPHEIGHT = " & str(ubound(Map,2)) & " : " & str(MapHeight) )    
	GL2D.PrintScale(0,  150, 0.5, "PARTICLES = " & str(Particle.ActiveParticles))    
	GL2D.PrintScale(0,  160, 0.5, "EXPLOSIONS = " & str(Explosion.ActiveExplosions))    
	
	GL2D.PrintScale(0,  170, 0.5, "PLATFORMH = " & str(PlatformHs.GetActiveEntities) & "/" & str(PlatformHs.GetMaxEntities + 1) )    
	GL2D.PrintScale(0,  180, 0.5, "PLATFORMV = " & str(PlatformVs.GetActiveEntities) & "/" & str(PlatformVs.GetMaxEntities + 1) )    
	GL2D.PrintScale(0, 190, 0.5, "WALLERS = " & str(Wallers.GetActiveEntities) & "/" & str(Wallers.GetMaxEntities + 1) )    
	GL2D.PrintScale(0,  200, 0.5, "GROGS = " & str(Grogs.GetActiveEntities) & "/" & str(Grogs.GetMaxEntities + 1) )    
	
	GL2D.PrintScale(0,  210, 0.5, "SpawnX = " & str(SpawnX) )    
	GL2D.PrintScale(0,  220, 0.5, "SpawnY = " & str(SpawnY) )    
	
	Snipe.DrawDebug( 320 )
		
end sub

sub Engine.DrawStatus( byval t as single = 1.0 )
	
	static as integer f = 0
	
	if( (Frame and 3) = 0 ) then
		f = (f + 1) and 3
	endif
	
	GL2D.SpriteStretch( 0, 16, 32, 128, GUIimages(1) )
	GL2D.SpriteStretch( 32, 32 * (Snipe.GetIncendiaryType+1) - 16, 32, 32, GUIimages(1) )
	
	
	if( ShowFPS ) then GL2D.PrintScale(0,  463, 1, "FPS = " & FPS )    
	
	dim as integer SnipeLeft = Snipe.GetLives
	if( (Snipe.GetState <> Player.DEAD) or (Snipe.GetState <> Player.DIE) )	then
		if( (State <> STATE_MOVE_TO_SPAWN_AREA) and (Snipe.GetState <> Player.DIE) ) then
			GL2D.PrintScale(0,  0, 1, "LIVES=" & UTIL.Int2Score(SnipeLeft, 2, "0") )
		else
			GL2D.PrintScale(0,  0, 1, "LIVES=" & UTIL.Int2Score(SnipeLeft+1, 2, "0") )	
		endif
	else
		GL2D.PrintScale(0,  0, 1, "LIVES=" & UTIL.Int2Score(SnipeLeft+1, 2, "0") )	
	endif
	
	GL2D.PrintScale( 432,  0, 1, "SCORE=" & UTIL.Int2Score(Snipe.GetScore, 7, "0") )
	
	GL2D.Sprite( 32 + 8, 32 * 1 - 8, GL2D.FLIP_NONE, EnemiesImages(80 + f) )
	GL2D.PrintScale( 64, 32 * 1 - 8, 1, "=" & UTIL.Int2Score(Snipe.GetBombs, 2, "0") )
	
	GL2D.Sprite( 32 + 8, 32 * 2 - 8, GL2D.FLIP_NONE, EnemiesImages(80 + 4 + f) )
	GL2D.PrintScale( 64, 32 * 2 - 8, 1, "=" & UTIL.Int2Score(Snipe.GetDynamites, 2, "0") )
	
	GL2D.Sprite( 32 + 8, 32 * 3 - 8, GL2D.FLIP_NONE, EnemiesImages(80 + 8 + f) )
	GL2D.PrintScale( 64, 32 * 3 - 8, 1, "=" & UTIL.Int2Score(Snipe.GetMines, 2, "0") )
	
	GL2D.Sprite( 32 + 8, 32 * 4 - 8, GL2D.FLIP_NONE, EnemiesImages(80 + 12 + f) )
	GL2D.PrintScale( 64, 32 * 4 - 8, 1, "=" & "**" )
	
	GL2D.SetblendMode( GL2D.BLEND_GLOW )
	
	dim as integer hOld = UTIL.Lerp( 0, 106, UTIL.Clamp(Snipe.GetOldEnergy/256, 0.0, 1.0) )    
	dim as integer h = UTIL.Lerp( 0, 106, UTIL.Clamp(Snipe.GetEnergy/256, 0.0, 1.0) )    
	dim as integer hh = UTIL.Lerp( 0, h, SMOOTH_STEP(t) )    
	
	if( not Snipe.IsInWater ) then
		
		GL2D.LineGlow( 16, 134, 16, 134 - hOld, 32,GL2D_RGB(255,0,255) )
		GL2D.LineGlow( 16, 134, 16, 134 - hh, 32,GL2D_RGB(255,255,0) )
	else
		GL2D.LineGlow( 16, 134, 16, 134 - hOld, 32,GL2D_RGB(rnd*255,rnd*255,rnd*255) )
		GL2D.LineGlow( 16, 134, 16, 134 - hh, 32,GL2D_RGB(rnd*255,rnd*255,rnd*255) )
		
	endif
	
	
	GL2D.SetblendMode( GL2D.BLEND_TRANS )
	
	
	select case (CurrentLevel+1)
		case 90:
			BossBigEyes.DrawEntitiesStatus( GUIImages() ) 
		case 91:
			BossGyrobots.DrawEntitiesStatus( GUIImages() )
		case 92:
			BossRobbits.DrawEntitiesStatus( GUIImages() )
		case 93:
			BossJokers.DrawEntitiesStatus( GUIImages() ) 
	end select

			
end sub

sub Engine.DrawDiamonds( byval scale as single, byval GL2Dcolor as GLuint  )
	
	glDisable(GL_TEXTURE_2D)
	glColor4ubv( cast( GLubyte ptr, @GL2Dcolor ) )
    
	glBegin(GL_QUADS)
	
	for x as integer = 0 to 640 + 64 step 64
		for y  as integer = 0 to 480 + 64 step 64
			glVertex2f( x, y - scale )
			glVertex2f( x + scale, y )
			glVertex2f( x, y + scale )
			glVertex2f( x - scale, y )
		next y
	next x
	
	glEnd()
	
	glEnable(GL_TEXTURE_2D)
	
	glColor4f( 1, 1, 1, 1 )
	
end sub
		

sub Engine.LoadMap( byref FileName as string, TempMap() as string )
	
	dim as integer FileNum = FreeFile
	
	open FileName for input as #FileNum

	dim as string Lin
	dim as integer MapWidth = 0
	dim as integer MapHeight = 0
	do until( eof(1) )
		line input #1, Lin
		Lin = trim(Lin) 
		if( len(Lin) > MapWidth ) then MapWidth = len(Lin)
		MapHeight += 1
	loop
	
	redim TempMap( 0 to (MapHeight - 1) )
	
	seek FileNum, 1
	
	dim as integer i = 0
	do until( eof(1) )
		line input #1, Lin
		TempMap(i) = trim(Lin) 
		i += 1
	loop
	
	close #FileNum
End Sub

''*************************************
'' Converts an Ascii map to integer map 
''*************************************
sub Engine.ConvertMap( Map() as TileType, StrMap() as string, byval LoadSpawnPoint as integer )
	
	'' Resize array according to size of ascii map
	redim Map(len(Strmap(0)), ubound(StrMap) )
	
	
	'' ¤ ¶ § | Ç æ Æ ô ö ò Ö û ù Ü
	'' ¢ £ ¥ ƒ ª º « » ß µ ± • °
	'' @ = Tile 1 
	'' # = Tile 2
	IsBossStage = FALSE
	BossActive = FALSE
	 
	for y as integer = 0 to ubound(StrMap)	
		for x as integer = 1 to len(StrMap(y))
			dim as string a = mid(StrMap(y), x, 1)
			select case a
				case "#"
					if( CurrentSeason = SEASON_WINTER ) then Map(x-1,y).Index = 15 else Map(x-1,y).Index = 2
					Map(x-1,y).Collision = TILE_SOLID
				case "+"
					if( CurrentSeason = SEASON_WINTER ) then Map(x-1,y).Index = 17 else Map(x-1,y).Index = 14
					Map(x-1,y).Collision = TILE_SOLID
				case "*"
					if( CurrentSeason = SEASON_WINTER ) then Map(x-1,y).Index = 19 else Map(x-1,y).Index = 3
					Map(x-1,y).Collision = TILE_SOFT_BRICK
				case "-"
					Map(x-1,y).Index = 16
					Map(x-1,y).Collision = TILE_SEMI_ICE
				case "_"
					Map(x-1,y).Index = 18
					Map(x-1,y).Collision = TILE_ICE
				case "@"
					Map(x-1,y).Index = 25
					Map(x-1,y).Collision = TILE_RUBBER
				case "!"
					Map(x-1,y).Index = 4
					Map(x-1,y).Collision = TILE_SPIKE_CEILING
				case "^"
					Map(x-1,y).Index = 4
					Map(x-1,y).Collision = TILE_SPIKE_FLOOR
				case "W"
					Map(x-1,y).Index = 0
					Map(x-1,y).Collision = TILE_TOP_WATER
				case "w"
					Map(x-1,y).Index = 0
					Map(x-1,y).Collision = TILE_WATER
				case "{"
					Map(x-1,y).Index = 0
					Map(x-1,y).Collision = TILE_LEFT_WATER
				case "}"
					Map(x-1,y).Index = 0
					Map(x-1,y).Collision = TILE_RIGHT_WATER
				case "|"
					Map(x-1,y).Index = 0
					Map(x-1,y).Collision = TILE_LEFT_RIGHT_WATER
				case "&"
					if( CurrentSeason = SEASON_WINTER ) then Map(x-1,y).Index = 21 else Map(x-1,y).Index = 5
					Map(x-1,y).Collision = TILE_SIGN
				case ","
					if( rnd > 0.5 ) then Map(x-1,y).Index = 6 else Map(x-1,y).Index = 7 
					Map(x-1,y).Collision = TILE_VINE_SHORT
				case ";"
					if( rnd > 0.5 ) then Map(x-1,y).Index = 11 else Map(x-1,y).Index = 10 
					Map(x-1,y).Collision = TILE_VINE_LONG
				case "("
					if( rnd > 0.5 ) then Map(x-1,y).Index = 6 else Map(x-1,y).Index = 7 
					Map(x-1,y).Collision = TILE_VINE_SHORT_LEFT
				case ")"
					if( rnd > 0.5 ) then Map(x-1,y).Index = 6 else Map(x-1,y).Index = 7 
					Map(x-1,y).Collision = TILE_VINE_SHORT_RIGHT
				case "["
					if( rnd > 0.5 ) then Map(x-1,y).Index = 11 else Map(x-1,y).Index = 10 
					Map(x-1,y).Collision = TILE_VINE_LONG_LEFT
				case "]"
					if( rnd > 0.5 ) then Map(x-1,y).Index = 11 else Map(x-1,y).Index = 10 
					Map(x-1,y).Collision = TILE_VINE_LONG_RIGHT
				case "~"
					Map(x-1,y).Index = 12
					Map(x-1,y).Collision = TILE_FENCE_TOP
				case "$"
					Map(x-1,y).Index = 13
					Map(x-1,y).Collision = TILE_FENCE
				case "¤"
					if( LoadSpawnPoint ) then
						SpawnX = (x-1) * TILE_SIZE
						SpawnY = y * TILE_SIZE
					endif
				case "V"
					dim as string b = mid(StrMap(y), x+1, 1)
					if( b <> " " ) then
						PlatformVs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, -0.75, val(b)  )
					else
						PlatformVs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, -0.75  )
					endif
				case "v"
					dim as string b = mid(StrMap(y), x+1, 1)
					if( b <> " " ) then
						PlatformVs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0.75, val(b)  )
					else
						PlatformVs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0.75  )
					endif
				case "P"
					dim as string b = mid(StrMap(y), x+1, 1)
					if( b <> " " ) then
						PlatformVs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, -0.3, val(b)  )
					else
						PlatformVs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, -0.3  )
					endif
				case "p"
					dim as string b = mid(StrMap(y), x+1, 1)
					if( b <> " " ) then
						PlatformVs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0.3, val(b)  )
					else
						PlatformVs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0.3  )
					endif
				case ">"
					dim as string b = mid(StrMap(y), x+1, 1)
					if( b <> " " ) then
						PlatformHs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1.0, val(b)  )
					else
						PlatformHs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1.0  )
					endif
				case "<"
					dim as string b = mid(StrMap(y), x+1, 1)
					if( b <> " " ) then
						PlatformHs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, -1.0, val(b)  )
					else
						PlatformHs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, -1.0  )
					endif
				case "«"
					dim as string b = mid(StrMap(y), x+1, 1)
					if( b <> " " ) then
						PlatformHs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, -0.5  )
					else
						PlatformHs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, -0.5  )
					endif
				case "»"
					dim as string b = mid(StrMap(y), x+1, 1)
					if( b <> " " ) then
						PlatformHs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0.5  )
					else
						PlatformHs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0.5  )
					endif
				case "•"
					Wallers.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "°"
					Wallers.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "G"
					Grogs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "g"
					Grogs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "ô"
					Wheelies.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "ö"
					Wheelies.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "J"
					Jumpbots.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "j"
					Jumpbots.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "H"
					Heliheads.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "h"
					Heliheads.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "S"
					Springers.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "s"
					Springers.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "E"
					Eyesores.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "e"
					Eyesores.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "B"
					Bouncers.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "b"
					Bouncers.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "/"
					Nails.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "\"
					Nails.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "R"
					Robats.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "r"
					Robats.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "O"
					Roboxs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "o"
					Roboxs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "T"
					Screwgatlings.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "t"
					Screwgatlings.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "Ö"
					Watchers.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "Ü"
					Watchers.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "Æ"
					Megatons.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "D"
					Drumbots.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "d"
					Drumbots.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "ª"
					Plasmos.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "º"
					Plasmos.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 1  )
				case "¶"
					if( ShowDialogs ) then DialogTriggers.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "ß"
					PowBombs.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "µ"
					PowDynamites.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "±"
					PowMines.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "ƒ"
					PowEnergys.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "§"
					Warps.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "Ç"
					CheckPoints.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "%"
					FallingBlocks.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
					Map(x-1,y).Collision = TILE_SOLID
				case "?"
					IsBossStage = TRUE
					BossActive = TRUE
					BossSpawnX = (x-1) * TILE_SIZE
					BossSpawnY = y * TILE_SIZE
					BossBigEyes.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "¥"
					IsBossStage = TRUE
					BossActive = TRUE
					BossSpawnX = (x-1) * TILE_SIZE
					BossSpawnY = y * TILE_SIZE
					BossGyrobots.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "£"
					IsBossStage = TRUE
					BossActive = TRUE
					BossSpawnX = (x-1) * TILE_SIZE
					BossSpawnY = y * TILE_SIZE
					BossRobbits.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case "¢"
					IsBossStage = TRUE
					BossActive = TRUE
					BossSpawnX = (x-1) * TILE_SIZE
					BossSpawnY = y * TILE_SIZE
					BossJokers.Spawn( (x-1) * TILE_SIZE, y * TILE_SIZE, 0  )
				case else	
					Map(x-1,y).Index = 0
					Map(x-1,y).Collision = 0
			End Select
		Next
	Next
	

End Sub


''*************************************
'' Draws the map in 3D
'' Only draws what can be seen so this
'' is fast
''*************************************
sub Engine.DrawMap( byval PlayerX as single, byval PlayerY as single, Map() as TileType, spriteset() as GL2D.IMAGE ptr )
	
	'' Need this for some extra tiles to draw
	'' outside the screen dimensions since when you zoom out
	'' the number of tiles needed to draw increases
	const as integer SCROLL_OFFSET = TILE_SIZE * 4
		
	'' Recalculate new "virtual" screen dimensions		
	const as integer SCREEN_W = SCREEN_WIDTH + SCROLL_OFFSET
	const as integer SCREEN_H = SCREEN_HEIGHT + SCROLL_OFFSET
	
	'' map dimensions
	dim as integer MAP_WID = Ubound(Map,1) + 1
	dim as integer MAP_HEI = Ubound(Map,2) + 1
	
	'' Number of Tiles we draw at one time ( Just a screenfull of it)
	const as integer ScreenTilesX = (SCREEN_W \ TILE_SIZE)
	const as integer ScreenTilesY = (SCREEN_H \ TILE_SIZE)
	
	'' Starting tiles = (Player - Halfscreen) \ TileSize
	dim as integer TileX = ( int(PlayerX) - SCREEN_W \ 2 ) \ TILE_SIZE
	dim as integer TileY = ( int(PlayerY) - SCREEN_H \ 2 ) \ TILE_SIZE
	
	
	'' Limit right = (Player - Halfscreen) \ TileSize
	dim as integer MaxX = MAP_WID - ScreenTilesX 
	if( TileX > MaxX ) then TileX = MaxX
	
	'' Limit bottom
	dim as integer MaxY = MAP_HEI - ScreenTilesY 
	if( TileY > MaxY ) then TileY = MaxY
	
	'' Limit left-top
	if( TileX < 0 ) then TileX = 0
	if( TileY < 0 ) then TileY = 0
	
	dim as integer TileMaxX = (TileX + (ScreenTilesX - 1))
	dim as integer TileMaxY = (TileY + (ScreenTilesY - 1))
	
	if( TileMaxX >= MAP_WID ) then TileMaxX = MAP_WID - 1
	if( TileMaxY >= MAP_HEI ) then TileMaxY = MAP_HEI - 1
	
	glPushMatrix()					'' Just to be safe since we are scaling below
	glScalef( 1.0, 1.0, 2.0 )
	
	'' Read Tile values on the 2D array
	'' Then draw if not empty(0)
	for y as integer = TileY to  TileMaxY
		for x as integer = TileX to TileMaxX
			dim as TileType Tile = Map(x,y)
			if( Tile.Index > 0 ) then
				select case Tile.Collision
					case TILE_SPIKE_CEILING
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, -TILE_SIZE\2, GL2D.FLIP_V, Spriteset(Tile.Index-1) )
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, 0, GL2D.FLIP_V, Spriteset(Tile.Index-1) )
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE\2, GL2D.FLIP_V, Spriteset(Tile.Index-1) )
					case TILE_SPIKE_FLOOR
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, -TILE_SIZE\2, GL2D.FLIP_NONE, Spriteset(Tile.Index-1) )
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, 0, GL2D.FLIP_NONE, Spriteset(Tile.Index-1) )
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE\2, GL2D.FLIP_NONE, Spriteset(Tile.Index-1) )
					case TILE_SIGN
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE\2, GL2D.FLIP_NONE, Spriteset(Tile.Index-1) )
					case TILE_VINE_SHORT
						GL2D.Sprite3D( x * TILE_SIZE, (y-1) * TILE_SIZE, TILE_SIZE\2, GL2D.FLIP_NONE, Spriteset(Tile.Index-1) )
					case TILE_VINE_LONG
						GL2D.Sprite3D( x * TILE_SIZE, (y-1) * TILE_SIZE, TILE_SIZE\2, GL2D.FLIP_NONE, Spriteset(Tile.Index-1) )
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, -TILE_SIZE\2, GL2D.FLIP_NONE, Spriteset(Tile.Index-3) )
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE\2, GL2D.FLIP_NONE, Spriteset(Tile.Index-3) )
					case TILE_VINE_SHORT_LEFT
						GL2D.DrawCubePlus( x * TILE_SIZE, (y-1) * TILE_SIZE, 0, TILE_SIZE, 0, 0, Spriteset(Tile.Index-1),_
				  		    			   TRUE, FALSE, FALSE, TRUE, FALSE )
					case TILE_VINE_SHORT_RIGHT
						GL2D.DrawCubePlus( x * TILE_SIZE, (y-1) * TILE_SIZE, 0, TILE_SIZE, 0, 0, Spriteset(Tile.Index-1),_
				  		    			   TRUE, FALSE, FALSE, FALSE, TRUE )
					case TILE_VINE_LONG_LEFT
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, -TILE_SIZE\2, GL2D.FLIP_NONE, Spriteset(Tile.Index-3) )
						GL2D.DrawCubePlus( x * TILE_SIZE, (y-1) * TILE_SIZE, 0, TILE_SIZE, 0, 0, Spriteset(Tile.Index-1),_
				  		    			   TRUE, FALSE, FALSE, TRUE, FALSE )
				  		GL2D.DrawCubePlus( x * TILE_SIZE, y * TILE_SIZE, 0, TILE_SIZE, 0, 0, Spriteset(Tile.Index-3),_
				  		    			   TRUE, FALSE, FALSE, TRUE, FALSE )
					case TILE_VINE_LONG_RIGHT
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, -TILE_SIZE\2, GL2D.FLIP_NONE, Spriteset(Tile.Index-3) )
						GL2D.DrawCubePlus( x * TILE_SIZE, (y-1) * TILE_SIZE, 0, TILE_SIZE, 0, 0, Spriteset(Tile.Index-1),_
				  		    			   TRUE, FALSE, FALSE, FALSE, TRUE )
				  		GL2D.DrawCubePlus( x * TILE_SIZE, y * TILE_SIZE, 0, TILE_SIZE, 0, 0, Spriteset(Tile.Index-3),_
				  		    			   TRUE, FALSE, FALSE, FALSE, TRUE )
					case TILE_FENCE
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, -TILE_SIZE\2, GL2D.FLIP_NONE, Spriteset(Tile.Index-1) )
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE\2, GL2D.FLIP_NONE, Spriteset(Tile.Index-1) )
					case TILE_FENCE_TOP
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, -TILE_SIZE\2, GL2D.FLIP_NONE, Spriteset(Tile.Index-1) )
						GL2D.Sprite3D( x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE\2, GL2D.FLIP_NONE, Spriteset(Tile.Index-1) )
					case else	
						GL2D.DrawCube( x * TILE_SIZE, y * TILE_SIZE, 0, TILE_SIZE, Spriteset(Tile.Index-1) )
				end select
			end if
		next x	
	next y
	

	
	glPopMatrix()
	
end sub

''*************************************
'' Draws the map in 3D
'' Only draws what can be seen so this
'' is fast
''*************************************
sub Engine.DrawTransMap( byval PlayerX as single, byval PlayerY as single, Map() as TileType, spriteset() as GL2D.IMAGE ptr )
	
	'' Need this for some extra tiles to draw
	'' outside the screen dimensions since when you zoom out
	'' the number of tiles needed to draw increases
	const as integer SCROLL_OFFSET = TILE_SIZE * 4
		
	'' Recalculate new "virtual" screen dimensions		
	const as integer SCREEN_W = SCREEN_WIDTH + SCROLL_OFFSET
	const as integer SCREEN_H = SCREEN_HEIGHT + SCROLL_OFFSET
	
	'' map dimensions
	dim as integer MAP_WID = Ubound(Map,1) + 1
	dim as integer MAP_HEI = Ubound(Map,2) + 1
	
	'' Number of Tiles we draw at one time ( Just a screenfull of it)
	const as integer ScreenTilesX = (SCREEN_W \ TILE_SIZE)
	const as integer ScreenTilesY = (SCREEN_H \ TILE_SIZE)
	
	'' Starting tiles = (Player - Halfscreen) \ TileSize
	dim as integer TileX = ( int(PlayerX) - SCREEN_W \ 2 ) \ TILE_SIZE
	dim as integer TileY = ( int(PlayerY) - SCREEN_H \ 2 ) \ TILE_SIZE
	
	static as integer ScrollOffset = 0
	
	ScrollOffset = (ScrollOffset - 4) and 255
	
	'' Limit right = (Player - Halfscreen) \ TileSize
	dim as integer MaxX = MAP_WID - ScreenTilesX 
	if( TileX > MaxX ) then TileX = MaxX
	
	'' Limit bottom
	dim as integer MaxY = MAP_HEI - ScreenTilesY 
	if( TileY > MaxY ) then TileY = MaxY
	
	'' Limit left-top
	if( TileX < 0 ) then TileX = 0
	if( TileY < 0 ) then TileY = 0
	
	dim as integer TileMaxX = (TileX + (ScreenTilesX - 1))
	dim as integer TileMaxY = (TileY + (ScreenTilesY - 1))
	
	if( TileMaxX >= MAP_WID ) then TileMaxX = MAP_WID - 1
	if( TileMaxY >= MAP_HEI ) then TileMaxY = MAP_HEI - 1
	
	glPushMatrix()					'' Just to be safe since we are scaling below
	glScalef( 1.0, 1.0, 2.0 )
			
	'' Read Tile values on the 2D array
	'' Then draw if not empty(0)
	for y as integer = TileY to  TileMaxY
		for x as integer = TileX to TileMaxX
			dim as TileType Tile = Map(x,y)
			select case Tile.Collision
				case TILE_LEFT_RIGHT_WATER:
					GL2D.DrawCubePlus( x * TILE_SIZE, y * TILE_SIZE, 0, TILE_SIZE, 0, ScrollOffset/256.0, Spriteset(0), _
									   TRUE, FALSE, FALSE, TRUE, TRUE )
				case TILE_LEFT_WATER:
					GL2D.DrawCubePlus( x * TILE_SIZE, y * TILE_SIZE, 0, TILE_SIZE, 0, ScrollOffset/256.0, Spriteset(0), _
					 				   TRUE, FALSE, FALSE, TRUE, FALSE )
				case TILE_RIGHT_WATER:
					GL2D.DrawCubePlus( x * TILE_SIZE, y * TILE_SIZE, 0, TILE_SIZE, 0, ScrollOffset/256.0, Spriteset(0), _
					 				   TRUE, FALSE, FALSE, FALSE, TRUE )
				case TILE_TOP_WATER:
					GL2D.DrawCubeTopFront( x * TILE_SIZE, y * TILE_SIZE, 0, TILE_SIZE, 0, ScrollOffset/256.0, Spriteset(0) )
				case TILE_WATER:
					GL2D.DrawCubeFront( x * TILE_SIZE, y * TILE_SIZE, 0, TILE_SIZE, 0, ScrollOffset/256.0, Spriteset(0) )
			end select
		next x	
	next y
	

	
	glPopMatrix()
	
end sub

sub Engine.DrawBG( byval PlayerX as single, byval PlayerY as single, Map() as TileType, spr as GL2D.IMAGE ptr )
	
	glPushmatrix()
	glScalef(2,2,1)
		for y as integer = -1 to 1
			for x as integer = -1 to 25
				GL2D.Sprite3D( x * 163, y * 251, -400, GL2D.FLIP_NONE, spr)
			Next
		Next
	glPopMatrix()
	
End Sub

sub Engine.CenterText( byval y as integer, byval scale as single, byref text as string, byval charwid as integer = 16 )

	charwid *= scale

	dim as integer col = (SCREEN_WIDTH - (charwid * len( text )))/2

	Gl2D.PrintScale( col, y, scale, text )
	
End Sub
	
	
sub Engine.PrintScore( byval x as integer, byval y as integer, byval scale as single, byval sc as integer, byval numchars as integer, byref filler as string )
	
	dim as string score = str(sc)
	dim as string text = string(numchars - len(score), filler) 
	
	text = text & score
	Gl2D.PrintScale( x, y, scale, text )
	
End Sub

function Engine.PrintDialog( byval x as integer, byval y as integer, byval LineLength as integer, byref Text as string ) as integer

	dim as integer Finished = FALSE
	dim as integer CurrentSpace = 1
	dim as integer OldSpace = 1
	dim as integer NumWords = 0
	dim as integer Currentrow = 0

	
	while( not Finished )
		
		dim as integer EndOfLine = FALSE
		dim as string CurrentLine = ""
		while( not EndOfLine ) 
			CurrentSpace = instr( CurrentSpace, Text, " ")
			if( CurrentSpace <> 0 ) then
				dim as string Word = mid( Text, OldSpace, CurrentSpace - OldSpace )
				if(  trim(Word) = "|" ) then 
					EndOfLine = TRUE
					Finished = TRUE
				else 
					if( len(CurrentLine + Word) <= LineLength  ) then
						CurrentLine += Word
						OldSpace = CurrentSpace
						CurrentSpace += 1
						NumWords += 1
					else
						EndOfLine = TRUE
					endif
				endif
			else
				Finished = TRUE
			endif
		wend
		
		GL2D.PrintScale( x, y + CurrentRow * 20, 1, trim(CurrentLine) )
		    
		Currentrow += 1
	
	wend
	
	return NumWords
	
end function


sub Engine.ResizeScreen()
	
	dim as integer ViewPort(3)
    glGetIntegerv(GL_VIEWPORT, @ViewPort(0))
	'' rescale screen 
	dim as single ScaleX = ViewPort(2)/SCREEN_WIDTH
	dim as single ScaleY = ViewPort(3)/SCREEN_HEIGHT
	glScalef( ScaleX, ScaleY, 1.0 )
	
end sub


sub Engine.SaveConfig( byref filename as string )
	
	dim as integer f = FreeFile

	if( open( filename for binary as #f ) = 0 ) then
		
		put #f,, Sound.GetMasterVolumeBGM
		put #f,, Sound.GetMasterVolumeSFX
		put #f,, FullScreen
		put #f,, Vsynch
		put #f,, ShowFPS
		put #f,, ShowDialogs
		put #f,, NoFrame
		put #f,, PhysicalScreenWidth 
		put #f,, PhysicalScreenHeight 
		close #f

	endif
	
	
end sub

sub Engine.LoadConfig( byref filename as string )
	
	dim as integer f = FreeFile
	if( open( filename for binary as #f ) = 0 ) then
		
		get #f,, MasterVolumeBGM
		get #f,, MasterVolumeSFX
		get #f,, FullScreen
		get #f,, Vsynch
		get #f,, ShowFPS
		get #f,, ShowDialogs
		get #f,, NoFrame 
		get #f,, PhysicalScreenWidth
		get #f,, PhysicalScreenHeight
		
		close #f
	 
	endif

	Sound.SetMasterVolumeBGM( MasterVolumeBGM )
	Sound.SetMasterVolumeSFX( MasterVolumeSFX )
	
	
end sub

sub Engine.SaveControls( byref filename as string )
	
	dim as integer f = FreeFile

	if( open( filename for binary as #f ) = 0 ) then
		
		put #f,, KeyUp
		put #f,, KeyDown 
		put #f,, KeyLeft 
		put #f,, KeyRight 
		put #f,, KeyJump 
		put #f,, KeyAttack 
		put #f,, KeyOk 
		put #f,, KeyCancel
		put #f,, KeyDie 
		put #f,, JoyJump 
		put #f,, JoyAttack 
		put #f,, JoyOk 
		put #f,, JoyCancel 
		put #f,, JoyDie 
		
	
		close #f

	endif
	
	
end sub

sub Engine.LoadControls( byref filename as string )
	
	dim as integer f = FreeFile
	if( open( filename for binary as #f ) = 0 ) then
		
		get #f,, KeyUp
		get #f,, KeyDown 
		get #f,, KeyLeft 
		get #f,, KeyRight 
		get #f,, KeyJump 
		get #f,, KeyAttack 
		get #f,, KeyOk 
		get #f,, KeyCancel
		get #f,, KeyDie 
		get #f,, JoyJump 
		get #f,, JoyAttack 
		get #f,, JoyOk 
		get #f,, JoyCancel 
		get #f,, JoyDie 
		
		close #f
	 
	endif

	
end sub

sub Engine.SaveHighScores( byref filename as string )
	
	dim as integer f = FreeFile

	if( open( filename for binary as #f ) = 0 ) then
		
		for i as integer = 0 to ubound(HighScores)
			put #f,, HighScores(i)
		next i
		
		close #f

	endif
	
	
end sub

sub Engine.LoadHighScores( byref filename as string )
	
	dim as integer f = FreeFile

	if( open( filename for binary as #f ) = 0 ) then
		
		for i as integer = 0 to ubound(HighScores)
			get #f,, HighScores(i)
		next i
		
		close #f

	endif
	
	
end sub

sub Engine.ResetAll()
	
	CurrentLevel = 0
	CurrentSeason = 0
	
	ActiveIncendiary = 0
	
	WindFrame = 0
	
	CurrentLevel = 0
	CurrentSeason = 0
	IsBossStage = FALSE
	BossActive = FALSE
	
	Frame = 0
	SecondsElapsed = 0
	
	
	IncendiaryMenuAngle = 0
	Snipe.SetIncendiaryType =  Player.INCENDIARY_SHOT
	ActiveIncendiary = Snipe.GetIncendiaryType
	
end sub

sub Engine.SortHighScores()
	
	'' Bubble sort is da bomb!
	for i as integer = 0 to ubound(HighScores)
		for j as integer = 0 to ubound(HighScores) - 1
			if( HighScores(i).Score > HighScores(j).Score ) then
				swap HighScores(i), HighScores(j)
			elseif( HighScores(i).Score = HighScores(j).Score ) then
				if( ucase(HighScores(i).MyName) < ucase(HighScores(j).MyName) ) then
					swap HighScores(i), HighScores(j)
				endif
			endif
		next
	next
	
end sub