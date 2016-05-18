''*****************************************************************************
''
''
''	Pyromax Dax Utilities Module
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#include once "UTIL.bi"

namespace UTIL

function CountFiles( byref filespec as string, byval attrib as integer ) as integer
    
    dim as integer filecount = 0
    dim as string filename = dir(filespec, attrib) 
    do while len(filename) > 0 
        filename = dir()
        filecount += 1
    loop
    return filecount
    
end function
	
''  Utility function to interpolate from a to b given t[0..1]  
function Lerp( byval a as single, byval b as single, byval t as single ) as single
	return a + (b-a) * t
end function

function LerpSmooth( byval a as single, byval b as single, byval t as single ) as single
	return a + (b-a) * SMOOTH_STEP(t)
end function


function SmoothStep( byval a as single, byval b as single, byval v as single ) as single
	if( v < a ) then return 0
	if( v > b ) then return 1
	v = ( v - a )/( b - a )
	return SMOOTH_STEP(v)
end function

''--------------------------------------
'' v = current value
'' w = destination
'' n = slowdown factor
''--------------------------------------
function WeightedAverage( byval v as single, byval w as single, byval n as single ) as single
	 return ((v * (n - 1)) + w) / n 
end function

function LerpPow(  byval a as single, byval b as single, byval t as single ) as single
	dim pmax as single = abs(b - a) 
	t = t * pmax
	return pmax-((pmax-t)^4)/(pmax^3)
end function

''--------------------------------------
''
''--------------------------------------
function CatMullRom( byval p0 as single, byval p1 as single, byval p2 as single, byval p3 as single, byval t as single ) as single
	
	return 0.5f * ( (2 * p1) +_
				  (-p0 + p2) * t +_
				  (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t +_
				  (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t )

end function

''--------------------------------------
''	
''--------------------------------------
function Bezier( byval p0 as single, byval p1 as single, byval p2 as single, byval p3 as single, byval t as single ) as single
	
	dim as single b = 1 - t
    dim as single b2 = b * b
    dim as single b3 = b * b * b
    
    dim as single t2 = t * t
    dim as single t3 = t * t * t
    
    return p1 * b3 + 3* p0 *(b2) * t + 3 * p3 *(b) * (t2) + p2 * (t3)
	
end function

function Clamp overload( byval a as single, byval minimum as single, byval maximum as single ) as single
	if( a < minimum ) then return minimum
	if( a > maximum ) then return maximum
	return a
end function

function Clamp overload( byval a as integer, byval minimum as integer, byval maximum as integer ) as integer
	if( a < minimum ) then return minimum
	if( a > maximum ) then return maximum
	return a
end function

function Wrap overload( byval a as single, byval minimum as single, byval maximum as single ) as single
	if( a < minimum ) then return (a - minimum) + maximum
	if( a > maximum ) then return (a - maximum) + minimum
	return a
end function

function Wrap overload( byval a as integer, byval minimum as single, byval maximum as integer ) as integer
	if( a < minimum ) then return (a - minimum) + maximum
	if( a > maximum ) then return (a - maximum) + minimum
	return a
end function

function Min overload( byval a as single, byval b as single ) as single
	if( a < b ) then return a
	return b
end function

function Min overload( byval a as integer, byval b as integer ) as integer
	if( a < b ) then return a
	return b
end function

function Max overload( byval a as single, byval b as single ) as single
	if( a > b ) then return a
	return b
end function

function Max overload( byval a as integer, byval b as integer ) as integer
	if( a > b ) then return a
	return b
end function

function PrintKeyString( byval i as integer ) as string

	'' Array I got from FB examples
	dim Key(1 to &h58) as string * 12 => _
	{ _
		"Esc", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "Backspace", _
		"Tab", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "(", ")", "Enter", _
		"Control", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "~", "L-shift", _
		"\", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/", "R-shift", "*", "Alt", _
		"Space", "Capslock", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", _
		"Numlock", "Scrllock", "Home", "Up", "Page up", "-", "Left", "???", _
		"Right", "+", "End", "Down", "Page down", "Insert", "Delete", "???", _
		"???", "???", "F11", "F12" _
	}
	
	if( (i > 0) and (i < &h58) ) then
		return Key(i)
	else
		return ""
	endif
	
end function

function Int2Score( byval sc as integer, byval numchars as integer, byref filler as string ) as string
	
	dim as string score = str(sc)
	dim as string text = string(numchars - len(score), filler) 
	
	return (text & score)
	
end function

End Namespace
