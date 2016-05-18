''*****************************************************************************
''
''
''	Pyromax Dax Sound Module
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************


#include once "fmod.bi"
#include once "UTIL.bi"

#ifndef FALSE
	#define FALSE 0
	#define TRUE -1
#endif

namespace Sound

enum SOUND_SFX
	SFX_ATTACK = 0,
	SFX_JUMP,
	SFX_PLANT_INCENDIARY,
	SFX_BOUNCE,
	SFX_HURT,
	SFX_POWER_UP,
	SFX_COIN_UP,
	SFX_EXPLODE,
	SFX_MINE_ACTIVE,
	SFX_DYNAMITE_LAUNCH,
	SFX_MENU_OK,
	SFX_LEVEL_COMPLETE,
	SFX_CLICK,
	SFX_1UP,
	SFX_GO,
	SFX_METAL_HIT,
	SFX_ENEMY_SHOT_01,
	SFX_ENEMY_SHOT_02,
	SFX_ICE_HIT,
	SFX_YAHOO,
	NUM_SFX
End Enum

enum SOUND_BGM
	BGM_LEVEL_01 = 0,
	BGM_LEVEL_02,
	BGM_LEVEL_03,
	BGM_LEVEL_04,
	BGM_LEVEL_BOSS,
	BGM_CREDITS,
	BGM_TITLE,
	BGM_COMPLETE,
	BGM_GAME_OVER,
	BGM_END,
	BGM_INTERMISSION,
	BGM_INTRO,
	NUM_BGM
End Enum

type SFX
	declare constructor()
	declare destructor()
	
	Sample			as FSOUND_SAMPLE ptr = 0
	Channel 		as integer
	Volume			as integer
end type

type BGM
	declare constructor()
	declare destructor()
	
	Music			as FMUSIC_MODULE ptr = 0
	Volume			as integer
	
end type


declare sub Initialize( byval hz_mixrate as integer, byval num_channels as integer, byval flags as integer )
declare function GetMasterVolumeBGM() as  integer
declare function GetMasterVolumeSFX() as  integer
declare sub SetCurrentBGM( byval v as integer )
declare sub SetVolumeBGM( byval index as SOUND_BGM, byval volume as integer )
declare sub SetVolumeCurrentBGM( byval volume as integer )
declare sub SetVolumeSFX( byval index as SOUND_SFX, byval volume as integer )
declare sub SetMasterVolume( byval volume as integer )
declare sub SetMasterVolumeBGM( byval volume as integer )
declare sub SetMasterVolumeSFX( byval volume as integer )
declare sub PlaySFX(byval index as SOUND_SFX)
declare sub FreeSFX(byval index as SOUND_SFX)
declare sub PlayBGM(byval index as SOUND_BGM, byval Loopit as integer = TRUE )
declare sub StopBGM( byval index as SOUND_BGM )
declare sub PauseBGM( byval index as SOUND_BGM )
declare sub UnPauseBGM( byval index as SOUND_BGM )
declare sub PlayCurrentBGM( byval Loopit as integer = TRUE )
declare sub StopCurrentBGM()
declare sub PauseCurrentBGM()
declare sub UnPauseCurrentBGM()
declare sub StopAllBGMs()
declare sub FreeBGM( byval index as SOUND_BGM )
declare function LoadSFX( byref filename as string, byval index as SOUND_SFX, byval volume as integer = 255 ) as integer
declare function LoadBGM(byref filename as string, byval index as SOUND_BGM, byval volume as integer = 255 ) as integer
declare sub ShutDown()
	
	
End Namespace
