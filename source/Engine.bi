''*****************************************************************************
''
''
''	Pyromax Dax Engine(main) Class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "FBGFX.bi"
#include once "FBGL2D7.bi"     	'' We're gonna use Hardware acceleration
#include once "dir.bi"

#include once "UTIL.bi"
#include once "Vector2D.bi"
#include once "VectorSpring.bi"

#include once "Keyboard.bi"
#include once "Mouse.bi"
#include once "Joystick.bi"
#include once "Sound.bi"

#include once "Particles.bi"
#include once "Explosion.bi"
#include once "LeavesParticle.bi"

#include once "Globals.bi"
#include once "Map.bi"
#include once "Player.bi"
#include once "Camera.bi"


#include once "PlatformV.bi"
#include once "PlatformH.bi"

#include once "Bullet.bi"

#include once "Waller.bi"
#include once "Grog.bi"
#include once "Wheelie.bi"
#include once "Jumpbot.bi"
#include once "Helihead.bi"
#include once "Springer.bi"
#include once "Eyesore.bi"
#include once "Bouncer.bi"
#include once "Nail.bi"
#include once "Robat.bi"
#include once "Robox.bi"
#include once "Screwgatling.bi"
#include once "Watcher.bi"
#include once "Megaton.bi"
#include once "Drumbot.bi"
#include once "Plasmo.bi"

#include once "BossBigEye.bi"
#include once "BossJoker.bi"
#include once "BossRobbit.bi"
#include once "BossGyrobot.bi"

#include once "DialogTrigger.bi"
#include once "PowBomb.bi"
#include once "PowDynamite.bi"
#include once "PowMine.bi"
#include once "PowEnergy.bi"
#include once "Warp.bi"
#include once "Checkpoint.bi"

#include once "FallingBlock.bi"

type WarpInfo
	as integer SpawnTileX
	as integer SpawnTileY
	as integer LevelNum
	as integer SeasonType
end type

type HighScore
	as zstring * 17  Myname
	as integer       Score 		
end type
	
type Engine
	
public:
	'' We are going to use FSM for the engine itself
	enum 
		STATE_PLAY = 0,
		STATE_PAUSE,
		STATE_START,
		STATE_END,
		STATE_WARP,
		STATE_STAGE_BOSS_COMPLETE,
		STATE_STAGE_BOSS_FAIL,
		STATE_GAME_OVER,
		STATE_OPTIONS,
		STATE_CONTROLS,
		STATE_CREDITS,
		STATE_TITLE,
		STATE_YES_OR_NO,
		STATE_DIALOG,
		STATE_MOVE_TO_SPAWN_AREA,
		STATE_RESPAWN_PLAYER,
		STATE_INTERMISSION,
		STATE_RECORDS,
		STATE_STORY,
		STATE_SPLASH,
		STATE_EXIT 
	end enum
	
	''Menu choices
	enum 
		CHOICE_START_GAME = 0,
		CHOICE_OPTIONS,
		CHOICE_CONTROLS,
		CHOICE_RECORDS,
		CHOICE_CREDITS,
		CHOICE_EXIT
	end enum

	enum
		SEASON_SUMMER = 0,
		SEASON_FALL,
		SEASON_WINTER,
		SEASON_SPRING,
	end enum 
						
	declare constructor()
	declare destructor()
	
	
	declare sub Initialize()
	declare function Update() as integer
	declare sub InitEverything()
	declare sub ShutDown()
	
	
	
private:
	
	declare function StatePlay() as integer     '' Engine State Functions
	declare function StatePause() as integer
	declare function StateStart() as integer
	declare function StateEnd() as integer
	declare function StateWarp() as integer
	declare function StateStageBossComplete() as integer
	declare function StateStageBossFail() as integer
	declare function StateGameOver() as integer
	declare function StateOptions() as integer
	declare function StateTitle() as integer
	declare function StateCredits() as integer
	declare function StateControls() as integer
	declare function StateYesOrNo() as integer
	declare function StateDialog() as integer
	declare function StateMoveToSpawnArea() as integer
	declare function StateRespawnPlayer() as integer
	declare function StateIntermission() as integer
	declare function StateRecords() as integer
	declare function StateStory() as integer
	declare function StateSplash() as integer
	
	declare property SetState( byval v as integer )

	declare sub Draw()
	declare sub DrawTitle( byval Active as integer, byval MenuAngle as integer, byval MenuFrame as integer, byval PlayGame as integer, byval t as single )
	declare sub DrawOptions( byval choice as integer, byval ScreenSizeIndex as integer, byref ypos as VectorSpring, Rows() as integer, Menu() as string, Help() as string, byval t as single )
	declare sub DrawControls( byval choice as integer, byval WaitForKeyPress as integer, byref ypos as VectorSpring, Rows() as integer, Menu() as string, Scancodes() as integer, JoyCodes() as integer, byval t as single )
	declare sub DrawDialog( byval t as single, byref Text as string, byval PrintText as integer )
	declare sub DrawStartEnd( byval t as single, byval t2 as single )
	declare sub DrawYesOrNo( byval t as single, byref Text as string, byval PrintText as integer, byval Activ as integer )
	declare sub DrawCredits( Items() as string, Xpos() as integer, byval t as single )
	declare sub DrawIntermission( Items() as string, Xpos() as integer, ScoreValue() as integer, byval t as single, byval t2 as single )
	
	declare sub GetInput()
	declare function InputName() as integer
	
	declare sub LoadSounds()
	declare sub LoadImages()
	declare sub LoadDialogScripts()
	declare sub LoadScript( byref FileName as string, OutString as string )
	declare sub LoadWarpScripts()
	declare sub LoadWarpInfo( byref FileName as string, byref OutInfo as WarpInfo )
	declare sub LoadLevel( byval LoadSpawnPoint as integer )	
	
	declare sub DrawMainMenu( byval activ as integer, byval Angle as integer, byval Radius as integer, byval count as integer )
	declare sub DrawMap( byval PlayerX as single, byval PlayerY as single, Map() as TileType, spriteset() as GL2D.IMAGE ptr )
	declare sub DrawTransMap( byval PlayerX as single, byval PlayerY as single, Map() as TileType, spriteset() as GL2D.IMAGE ptr )
	declare sub DrawBG( byval PlayerX as single, byval PlayerY as single, Map() as TileType, spr as GL2D.IMAGE ptr )
	declare sub DrawCollisionBoxes()
	declare sub DrawDebug()
	declare sub DrawStatus( byval t as single = 1.0)
	declare sub DrawDiamonds( byval scale as single, byval GL2Dcolor as GLuint )
	
	declare sub HandleObjectCollisions()
	declare sub HandleObjectDestructions()
	declare sub HandleObjectRenders()
	declare sub HandleObjectUpdates()
	
	declare sub RespawnSnipe()
	
	declare sub ConvertMap( Map() as TileType, StrMap() as string, byval LoadSpawnPoint as integer )
	declare sub LoadMap( byref FileName as string, TempMap() as string )
	declare sub CenterText( byval y as integer, byval scale as single, byref text as string, byval charwid as integer = 16 )
	declare sub PrintScore( byval x as integer, byval y as integer, byval scale as single, byval sc as integer, byval numchars as integer, byref filler as string )
	declare function PrintDialog( byval x as integer, byval y as integer, byval LineLength as integer, byref Text as string ) as integer
	
	declare sub ResizeScreen()
	
	declare sub SaveConfig( byref filename as string )
	declare sub LoadConfig( byref filename as string )
	declare sub SaveControls( byref filename as string )
	declare sub LoadControls( byref filename as string )
	declare sub SaveHighScores( byref filename as string )
	declare sub LoadHighScores( byref filename as string )
	declare sub SortHighScores()
	declare sub ResetAll()
	
	as integer 	State
	as integer  PreviousState
	as integer  NextState
	as integer 	CurrentLevel
	as integer	CurrentSeason
	as integer  IsBossStage
	as integer  BossActive
	as integer  WindDirection
	as integer  WindFrame
		
	as integer 	Frame
	as single 	SecondsElapsed
	as double 	FPS
	as double 	Dt
	as double 	Accumulator

		
	as Mouse 	Rat
	as Keyboard Keys
	as Joystick Joy
	
	as Player 	Snipe
	as Camera	Cam
	as integer  SpawnX
	as integer  SpawnY
	as integer  OldPlayerX
	as integer  OldPlayerY
	
	as integer  BossSpawnX
	as integer  BossSpawnY
	
	as integer  BossDieX
	as integer  BossDieY
	
	as integer  MapWidth
	as integer  MapHeight
	
	as integer  FullScreen
	as integer  Vsynch
	as integer  ShowFPS
	as integer  NoFrame
	as integer  PhysicalScreenWidth
	as integer  PhysicalScreenHeight 
	as integer  ShowDialogs
	 	
	as integer  CurrentDialogID
	as integer  CurrentWarpID
	
	as integer IncendiaryMenuAngle
	as integer IncendiaryMenuAnimate
	
	as integer PressedRight
	as integer PressedLeft
	as integer PressedUp
	as integer PressedDown
	
	as integer PressedOK
	as integer PressedCancel
	
	KeyUp as integer
	KeyDown as integer
	KeyLeft as integer
	KeyRight as integer
	KeyJump as integer
	KeyAttack as integer
	KeyDie as integer
	KeyOk as integer
	KeyCancel as integer
	
	JoyJump as integer
	JoyAttack as integer
	JoyDie as integer
	JoyOk as integer
	JoyCancel as integer

	
	as integer ActiveIncendiary
	

	as integer MasterVolumeBGM
	as integer MasterVolumeSFX	

	as integer HiScore
		
	as PlatformVFactory PlatformVs
	as PlatformHFactory PlatformHs
	
	as BulletFactory Bullets
	
	as WallerFactory Wallers
	as GrogFactory Grogs
	as WheelieFactory Wheelies
	as JumpbotFactory Jumpbots
	as HeliheadFactory Heliheads
	as SpringerFactory Springers
	as EyesoreFactory Eyesores
	as BouncerFactory Bouncers
	as NailFactory Nails
	as RobatFactory Robats
	as RoboxFactory Roboxs
	as ScrewgatlingFactory Screwgatlings
	as WatcherFactory Watchers
	as MegatonFactory Megatons
	as DrumbotFactory Drumbots
	as PlasmoFactory Plasmos
	
	as BossBigEyeFactory BossBigEyes
	as BossJokerFactory BossJokers
	as BossRobbitFactory BossRobbits
	as BossGyrobotFactory BossGyrobots
	
	as DialogTriggerFactory DialogTriggers
	as PowBombFactory PowBombs
	as PowDynamiteFactory PowDynamites
	as PowMineFactory PowMines
	as PowEnergyFactory PowEnergys
	
	as WarpFactory Warps
	as CheckpointFactory Checkpoints
	
	as FallingBlockFactory FallingBlocks
	
	'' Debuggers
	as integer DebugMode
	as integer DrawAABB		
	
End Type
