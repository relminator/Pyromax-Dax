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


#include once "Sound.bi"


namespace Sound

const as integer SOFTWARE_CHANNELS = 32
const as integer HARDWARE_CHANNELS = SOFTWARE_CHANNELS + 1

dim as SFX Sfxs( NUM_SFX-1 )
dim as BGM Bgms( NUM_BGM-1 )
dim as integer Channels
dim as integer MasterVolumeBGM = 255
dim as integer MasterVolumeSFX = 255

dim as integer CurrentBGM = 0
    
''*****************************************************************************
''
''
''
''*****************************************************************************
constructor SFX()

	Channel			= 0
	Volume			= 255
	
End Constructor

destructor SFX()

End Destructor

''*****************************************************************************
''
''
''
''*****************************************************************************		
constructor BGM()
	Volume			= 255
End Constructor

destructor BGM()

End Destructor


''*****************************************************************************
''
''
''
''*****************************************************************************		
sub Initialize( byval hz_mixrate as integer, byval num_channels as integer, byval flags as integer )

	FSOUND_Init( hz_mixrate, num_channels, flags )
	
	Channels = num_channels

	MasterVolumeBGM = 255
	MasterVolumeSFX = 255
	
end sub

private sub Release()
	
	for i as integer = 0 to NUM_SFX - 1
		if Sfxs(i).Sample then FSOUND_Sample_Free( Sfxs(i).Sample )		
	next i

	for i as integer = 0 to NUM_BGM - 1
		if Bgms(i).Music then FMUSIC_FreeSong( Bgms(i).Music )	
	next i    
	
End Sub

function GetMasterVolumeBGM() as  integer
	return MasterVolumeBGM
End Function

function GetMasterVolumeSFX() as  integer
	return MasterVolumeSFX
End Function

sub SetCurrentBGM( byval v as integer )
	
	v = UTIL.Clamp( v, 0, ubound(Bgms) )
	CurrentBGM = v 
	 
end sub

sub SetMasterVolume( byval volume as integer )
	
	if( volume < 0 ) then volume = 0
	if( volume > 255 ) then volume = 255
	
	SetMasterVolumeBGM( volume )
	SetMasterVolumeSFX( volume )
	
End Sub

sub SetMasterVolumeBGM( byval volume as integer )
	
	if( volume < 0 ) then volume = 0
	if( volume > 255 ) then volume = 255
	
	for index as integer = 0 to NUM_BGM - 1
		if( Bgms(index).Music ) then
			FMUSIC_SetMasterVolume(Bgms(index).Music, volume)	
			Bgms(index).Volume = volume
		endif
	next index
	
	MasterVolumeBGM = volume
	
end sub

sub SetMasterVolumeSFX( byval volume as integer )

	if( volume < 0 ) then volume = 0
	if( volume > 255 ) then volume = 255
	
	FSOUND_SetSFXMasterVolume( volume )
	MasterVolumeSFX = volume
	
end sub

sub SetVolumeBGM( byval index as SOUND_BGM, byval volume as integer )
	
	if( volume < 0 ) then volume = 0
	if( volume > 255 ) then volume = 255
	
	if( Bgms(index).Music ) then
		FMUSIC_SetMasterVolume(Bgms(index).Music, volume)	
		Bgms(index).Volume = volume
	endif
	
end sub

sub SetVolumeCurrentBGM( byval volume as integer )
	
	if( volume < 0 ) then volume = 0
	if( volume > 255 ) then volume = 255
	
	if( Bgms(CurrentBGM).Music ) then
		FMUSIC_SetMasterVolume(Bgms(CurrentBGM).Music, volume)	
		Bgms(CurrentBGM).Volume = volume
	endif
	
end sub

sub SetVolumeSFX( byval index as SOUND_SFX, byval volume as integer )

	if( volume < 0 ) then volume = 0
	if( volume > 255 ) then volume = 255
	
	if Sfxs(index).Sample then 
		FSOUND_SetVolume( Sfxs(index).Channel, Volume )
	endif	
	
end sub

sub PlaySFX(byval index as SOUND_SFX)
	
	FSOUND_PlaySound( Sfxs(index).Channel, Sfxs(index).Sample )
	
End Sub

sub FreeSFX(byval index as SOUND_SFX)
	
	if Sfxs(index).Sample then FSOUND_Sample_Free( Sfxs(index).Sample )
	
End Sub

sub PlayCurrentBGM( byval Loopit as integer = TRUE )
	
	if FMUSIC_IsPlaying( Bgms(CurrentBGM).Music ) = FALSE then		
		FMUSIC_PlaySong( Bgms(CurrentBGM).Music )
	    if( Loopit ) then FMUSIC_SetLooping( Bgms(CurrentBGM).Music, TRUE )
	endif 

end sub

sub StopCurrentBGM()
	
	if FMUSIC_IsPlaying( Bgms(CurrentBGM).Music ) then		
		FMUSIC_StopSong( Bgms(CurrentBGM).Music )
	endif 
	
end sub

sub PauseCurrentBGM()
	
	if FMUSIC_GetPaused( Bgms(CurrentBGM).Music ) = FALSE then
		FMUSIC_SetPaused( Bgms(CurrentBGM).Music, TRUE)
	end if
	
End Sub

sub UnPauseCurrentBGM()
	
	if FMUSIC_GetPaused( Bgms(CurrentBGM).Music ) then
		FMUSIC_SetPaused( Bgms(CurrentBGM).Music, FALSE )
	end if
	
End Sub
	
sub PlayBGM(byval index as SOUND_BGM, byval Loopit as integer = TRUE )
	
	if FMUSIC_IsPlaying( Bgms(index).Music ) = FALSE then		
		FMUSIC_PlaySong( Bgms(index).Music )
	    if( Loopit ) then FMUSIC_SetLooping( Bgms(index).Music, TRUE )
	endif 
	
end sub

sub StopBGM( byval index as SOUND_BGM )
	
	if FMUSIC_IsPlaying( Bgms(index).Music ) then		
		FMUSIC_StopSong( Bgms(index).Music )
	endif 
	
end sub

sub StopAllBGMs()
	
	for i as integer = 0 to NUM_BGM - 1
		StopBGM(i)	
	next i    
	
end sub

sub PauseBGM( byval index as SOUND_BGM )
	
	if FMUSIC_GetPaused( Bgms(index).Music ) = FALSE then
		FMUSIC_SetPaused( Bgms(index).Music, TRUE)
	end if
	
End Sub

sub UnPauseBGM( byval index as SOUND_BGM )
	
	if FMUSIC_GetPaused( Bgms(index).Music ) then
		FMUSIC_SetPaused( Bgms(index).Music, FALSE )
	end if
	
End Sub


sub FreeBGM( byval index as SOUND_BGM )
	if( Bgms(index).Music ) then FMUSIC_FreeSong( Bgms(index).Music )
end sub



function LoadSFX( byref filename as string, byval index as SOUND_SFX, byval volume as integer = 255 ) as integer

	'' check if ptr is already occupied
	if Sfxs(index).Sample then
		dim f as integer = freefile
		Open Cons For Input As #f
		print #f, "ERROR!!! SFX slot already occupied"
		close 
		end
	endif

	Sfxs(index).Sample = FSOUND_Sample_Load(FSOUND_FREE, filename, FSOUND_HW2D, 0, 0)
	Sfxs(index).Channel = HARDWARE_CHANNELS + index
	Sfxs(index).Volume = volume
	
	FSOUND_SetVolume( Sfxs(index).Channel, volume )
	
	if Sfxs(index).Sample then
		return TRUE
	else
		return FALSE
	endif
	
end function

function LoadBGM(byref filename as string, byval index as SOUND_BGM, byval volume as integer = 255 ) as integer
	
	'' check if ptr is already occupied
	if Bgms(index).Music then 
		FMUSIC_FreeSong(Bgms(index).Music)
	endif
	
	Bgms(index).Music = FMUSIC_LoadSong(filename)
	FMUSIC_SetMasterVolume(Bgms(index).Music, volume)
	Bgms(index).Volume = volume
	
	if Bgms(index).Music then
		return TRUE
	else
		return FALSE
	endif
	
end function

sub ShutDown()

	Release()
	
	FSOUND_Close()
	
	
End Sub
	
	
End Namespace


