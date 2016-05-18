# Pyromax-Dax
A 2.5D platformer game with anime-style pseudo-physics made in FreeBasic

![Alt text](http://www.rel.phatcode.net/Temp/pyromax_screen_title.png "PD")

![Alt text](http://www.rel.phatcode.net/Temp/pyromax_screen_04.png "PD")

Game: Pyromax Dax

Code: Richard Eric M. Lope BSN, RN (Relminator)

GFX: Marc Russell (spicypixel.net)
	 Joseph Collins
	 Adigun A. Polack
	 Ari Fieldman
	 Relminator
	 
Audio: vgmusic

Design: Relminator/Anya Therese B. Lope

Tools: Easy GL2D, FreeBASIC, OpenGL, Fmod and FBedit

Latest version could always be downloaded at:
	http://rel.phatcode.net

Email:
	vic_viperph@yahoo.com
	
Default Controls:
	-Can be remapped via "Controls" screen
	Jump -> SPACE
	Attack -> Z
	Pause/Change Incendiaries -> ENTER
	Change Incendiaries -> LEFT/RIGHT (When paused)
	Menu Controls -> LEFT/RIGHT and ENTER
	Switch to FullScreen -> ALT + ENTER
	Note: You can only attack when not moving except with the
		  Shot attack which you can use even when jumping.
		  
About the game:
	A game that I made as a supplement to my Platforming tutorial.
	Also became an entry for FBGD 2k13
	
Gameplay:
	Imagine Megaman style attack system with Mario style physics.
	
Sourcecode:
	Sourcecode is provided for learning purposes.
	Use to your hearts content, but I would enjoy knowing the things you used it for.
	Code should never be used to harm anyone.
	I used FBedit to code this game 
	Source is compatible with FB 0.24
	

How to compile:
	Just issue this command:
	fbc -s gui "PyromaxDax.bas" "FBGL2D7.bas" "Joystick.bas" "Keyboard.bas" "Mouse.bas" "Player.bas" "Map.bas" "Vector2D.bas" "Camera.bas" "Engine.bas" "UTIL.bas" "Particles.bas" "Vector3D.bas" "Explosion.bas" "Bomb.bas" "Dynamite.bas" "Mine.bas" "Sound.bas" "AABB.bas" "PlatformV.bas" "PlatformH.bas" "Waller.bas" "Grog.bas" "Wheelie.bas" "DialogTrigger.bas" "VectorSpring.bas" "Jumpbot.bas" "Helihead.bas" "Springer.bas" "Eyesore.bas" "Bouncer.bas" "Nail.bas" "Robat.bas" "Robox.bas" "Screwgatling.bas" "Bullet.bas" "Watcher.bas" "Megaton.bas" "Drumbot.bas" "Plasmo.bas" "PowBomb.bas" "PowDynamite.bas" "PowMine.bas" "Warp.bas" "PowEnergy.bas" "BossBigEye.bas" "BossJoker.bas" "BossRobbit.bas" "BossGyrobot.bas" "Globals.bas" "FallingBlock.bas" "Checkpoint.bas" "LeavesParticle.bas"

	Or if your in Windows and have FBedit, just open PyromaxDax.fbp and compile.
	
Greets:
	- See in-game credits.
 

FAQS:

	Q: Can I edit levels?
	A: Yes, see "HowToEditLevels.txt" for more details.
	
	Q: Can I make a different game out of this engine?
	A: Yes, just give some credits.
	
	Q: Can I redistribute this game?
	A: Of course, as long as the whole package stays the same.
	
	Q: Can I sell this game?
	A: No.
	
	Q: Can I publish this game under your name?
	A: Mail me. ;*)
	
	Q: My question is not in thins FAQ.
	A: Mail me.
 
 
Changelog:

	02-14-13
		Valentines Day and I'm done!
		 
	02-13-13
		Changes to BigEye boss AI
		Changes to Robbit boss AI
		Added a few tile types for easthetics
		Some Level changes
		Finalized all levels
		Incendiaries reset to shot when player dies
		Cheat and debug disabled
		Stages rollover after the ending
		
	02-12-13
		Dialog tips can be enabled or disabled via the options screen
		Small AI changes to Joke-iz boss
		Finalized summer levels
		Changes to Joker boss AI
		Changes to Gyrobot boss AI
		
	02-11-13
		More tile types for aesthetics
		Edited levels for aesthetics
		Reset wind direction at stage start
		Some Player and Engine class additions
		One-Up every successful level
		Increased Lives stock to 5
		
	02-10-13
		Story Screen
		Splash Screen
		Small Changes to level 02
		
	02-08-13
		Level 12.
		Winds now get reset when you die.
		Small AI changes to Wheelie enemy.
		Small AI changes to Boss Gyrobot.
		
	02-07-13
		Fixed the high-score display bug by using zstrings instead of strings.
		HighScore table can now be saved.
		Allowed all the hazards in spring (bounce tiles, wind, ice and toxic water)
		Level 11
		Small AI change to Robat enemy
		
	02-06-13
		Made the intermission presentation better
		Hi-score system
		Toxic water
		Level 10
		Small changes to Drumbot and Eyesore AIs
		HiScore/Records screen
		Player can now input their names when they get a new hi-score
		
	02-05-13
		Added Score system
		Intermission/Report State
		Ending State
		Change BGM for title (Lachie sez it suxxors)
		Added BGM for ending
		Added BGM for spring season
		
	02-04-13
		Level 08
		Some AI changes to Jumpbot enemy
		Player can shoot moar shots now
		Player orientation stays the same when hit.
		
	02-03-13
		Fixed the -1 Lives glitch
		Made the sound fade instead of pause while in dialogs, pause and yes or no mode
		Changed a few AI stuff with boss Robbit
		Few AI changes to Helihead enemy
		Level 07
		
	02-01-13
		Level 06
		Few changes to boss Gyrobot
		Added per season BGMs
		Allowed the player to continue but you start from the season starting level
		
	01-31-13
		Level 04
		Few changes to Plasmo and Waller enemies
		Level 05
		
	01-30-13
		Decided to make the game more mario than megaman
		Added "Fall" season hazard (wind)
		
	01-29-13
		Level 03
		Few AI changes to megaton press
		Few AI changes to BossBigEye
	
	01-28-13
		Added ability for moving platforms to get amx distance traveled.
		Started designing Level 02
		Added Ceiling spikes
		
	01-27-13
		Added hit animations for all the popcorn enemies.
		Added hit animations for all the bosses
		Added Checkpoints
	01-26-13
		Dialog scripts are now sorted on load so dialogs area easier to add.
		Intro/tutorial level done!
		Warp scripts are now sorted on load so dialogs area easier to add.
		
	01-25-13
		Added Falling blocks
		Updated explosion code
		Started working on Level 01
		
	01-24-13
		New Boss(Gyrobot) - Flies around, tries to mash player (weakness = bomb, can be stunned by mines)
		Added ability to do eathquakes
		Fixed the shot controls 
		New SFX
		Enlarged the Dialog Text
		Cleaned up sound module so that changing BGMs on the fly is easier
		Added a way to call up dialog boxes in Boss stages(conversations between snipe and bosses perhaps?)
		
	01-23-13
		New Boss(Joker) - Bounces, sticks to walls, etc (weakness = dynamite)
		Fixed some engine class intricacies
		New Boss(Robbit) - Skater, jumper and attacker(weakness = bomb, stunned by shot in the eye) 
	
	01-20-13
		Did some BGM and SFX stuff 
		
	01-18-13
		One month to go...
		Implemented the First Boss ( BigEye - Jumps around reckelessly for now )(weakness = mine + shot)
		Bigeye can only be hurt when hit in the eye.
		Bigeye can be stunned for 5 seconds when hit anywhere with mine, bomb and dynamite
		Bigeye cannot spew bullets when stunned
		Added another test level
		
	01-17-13
		Added a new enemy - Megaton (a chained megaton press attached to chainlinks)
		Added a new enemy - Drumbot (a 5-stacked enemy, player can bounce on top of drumbot)
		Changed some enemies so that they can spew bullets
		Added Bomb powerup
		Added Dynamite powerup
		Added Mine powerup
		Status change display
		Incendiaries are now limited by the poweerups collected
		Added warpzone
		Implemented level warping via warpzones
		Added EnergyUp powerup
		
	01-16-13
		Too busy cooking stuff since today is my Birthday.
		
	01-15-13
		Added a new enemy - Robox (a boxed eye enemy with linear movement and idletime)
		Added Bullets - Some enemies can spew bullets
		Added a new enemy - Screwgatling (an enemy attached to floor or ceiling. Spews bullets)
		Bullets has 4 different behaviors and lots of IDs
		Added a new enemy - Watcher (Double eyed. Spews missiles)
		
	01-14-13
		After 3 coding days of almost pure GFX stuff, I'm back in coding mode! YAY!
		Added a new enemy - Jumpbot (jumping enemy)
		Added a new enemy - Helihead (L/R when passive and follows player when aggressive)
		Added a new enemy - Springer (gets aggressive player nearby and "springs" when touched)
		Added a new enemy - Eyesore (Pretty stupid enemy with randomized direction, spews lotsa bullets)
		Added a new enemy - Bouncer (Fireball that bounces on the floor)
		Added a new enemy - Nail (Moving screw spikes on floor and ceiling)
		Added a new enemy - Robat (Behaves like those bats in megaman/megamanx, spews bullets)

	01-13-13
		Same as yesterday. ;*(
		Wrestled with Graphics Gale and Paint.Net in order to make some nice text GFX
		Made some additions to the presentation
		Implemented basic Seasons
		
	01-12-13
		Same as yesterday. ;*(
	
	01-11-13
		Added images and optimized GFX atlas
	
	01-10-13
		Game over state
		Player energy and player lives are now useable fields
		Added a nice FX for the player energy when hit
		Added 2 new BGMs
		
	01-09-13
		Got my hands on my old 14 button gamepad so implemented proper joystick controls
		Used a keyheld event for attack instead of a keydown event. (tentative change)
		Proper death and respawn engine state events implemented
		
	01-08-13
		Animated all the GUIs with some nice transition FX
		Controls screen done
		Game Controls can now be remapped via controls screen
		Player Controls can now be remapped via controls screen
		Added some new sound FX
		
	01-07-13
		Credits screen done
		Added a way to resize screens in windowed mode
		Options screen done
		Added a little spring physics to the options menu
		
	01-06-13
		Dialog scripts are now loaded from file
		Implemented "start" state for engine class
		Implemented "yes or no" state for engine class
		Diamond fade FX
		Title screen behavior change (remembers last choice)
		
	01-05-13
		Spiked tiles
		Grog gets aggressive when player is near him
		Funky dialog boxes and scripted dialogs
		
	01-04-13
		Player incendiaries collision to enemies/objects
		Added a new enemy Grog(player can ride Grog)
		Added a new enemy Wheelie(player can bounce on Wheelie)
		Attached SFX's to some more actions
	
	01-02-13
		Updated player physics for a more mario like "feel" to it	
	
	01-01-13
		Happy New Year!!!
		Changed platform collisions to multi-sampling system
		Waller enemy ( stick on walls enemy )
	
	12-31-12
		Happy New Year's eve!!!
		Horizontal moving platoforms
		Shot, Bomb, Dynamite and Mine to platform collisions
		Player to Platform collisions
		
	12-30-12
		Vertical Moving Platforms
		AABB collisions
	
	12-28-12(not much work. Darn typhoon!)
		Water Tiles
		Water Physics
		Fixed Bounce floor collisions
		
	12-24-12
		Merry Christmas!!!!
		Bounce on floor and walls
		Moar physics stuff
		2 Types of ice tiles
		Energy meter for incendiaries
		Small delay for incendiary actions
		
	12-23-12
		Ice Tiles physics
		Added moar GFX
		Controlled Sounds
	
	12-21-12
		Mayan Calendar what?!!!!
		Implemented the Engine Class as a state machine
		Streamlined the controls by having a single button for attack
		
	12-17-12
		Shots
		Bombs
		Mine
		Dynamite
		Destructable tiles
		
	12-16-12
		Explosions
		Particles
		Keyboard/Mouse/Joystick wrappers
		
	12-12-12
		Started on the engine 
		Decided I want oldskool tilebased collisions so I ditched the slopes
		Implemented physics
		Filebased maps

