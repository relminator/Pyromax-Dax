''*****************************************************************************
''
''
''	Pyromax Dax Utilities module
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	
''
''*****************************************************************************

#ifndef UTIL_BI
#define UTIL_BI

#ifndef FALSE
	#define FALSE 0
	#define TRUE -1
#endif

#ifndef PI
	#define PI			( 3.14159265359f )
	#define TWOPI		( PI * 2 )
	#define DEG2RAD(a)	( PI/180.0f*(a) )
	#define RAD2DEG(a)	( 180.0f/PI*(a) )	
	#define SMOOTH_STEP(x) ((x) * (x) * (3 - 2 * (x)))
	#define SMOOTHER_STEP(x) (((x) * (x)* (x)) * ( (x) * ((x) * 6 - 15 ) + 10 ))
#endif

namespace UTIL

declare function CountFiles( byref filespec as string, byval attrib as integer ) as integer
declare function Lerp( byval a as single, byval b as single, byval t as single ) as single
declare function LerpSmooth( byval a as single, byval b as single, byval t as single ) as single
declare function LerpPow(  byval a as single, byval b as single, byval t as single ) as single
declare function SmoothStep( byval a as single, byval b as single, byval v as single ) as single
declare function WeightedAverage( byval v as single, byval w as single, byval n as single ) as single
declare function CatMullRom( byval p0 as single, byval p1 as single, byval p2 as single, byval p3 as single, byval t as single ) as single
declare function Bezier( byval p0 as single, byval p1 as single, byval p2 as single, byval p3 as single, byval t as single ) as single
declare function Clamp overload( byval a as single, byval min as single, byval max as single ) as single
declare function Clamp overload( byval a as integer, byval min as integer, byval max as integer ) as integer
declare function Wrap overload( byval a as single, byval min as single, byval max as single ) as single
declare function Wrap overload( byval a as integer, byval min as single, byval max as integer ) as integer
declare function Min overload( byval a as single, byval b as single ) as single
declare function Min overload( byval a as integer, byval b as integer ) as integer
declare function Max overload( byval a as single, byval b as single ) as single
declare function Max overload( byval a as integer, byval b as integer ) as integer
declare function PrintKeyString( byval i as integer ) as string
declare function Int2Score( byval sc as integer, byval numchars as integer, byref filler as string ) as string
	
End Namespace

#endif
