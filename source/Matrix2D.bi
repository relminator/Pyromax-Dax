''*****************************************************************************
''
''
''	Matrix2D class
''	Richard Eric M. Lope
''	http://rel.phatcode.net
''
''	Matrix 2D Class (Not OpenGL compliant)
''	
''	Row-Major-Order
''	3x3
''	Only 2D
''	Non-Stack based so mathematically correct but can't be used with GL
''	Reversed Order of Operations than GL 
''
''*****************************************************************************

#include once "Vector2D.bi"

#ifndef MATRIX2D_BI
#define MATRIX2D_BI

#ifndef FALSE
	const as integer FALSE = 0
	const as integer TRUE = NOT FALSE
#endif



type Matrix2D
	
public:

	declare constructor()
	declare destructor()	
	declare sub LoadIndentity()
	declare sub LoadTranslation( byval tx as single, byval ty as single )
	declare sub LoadScaling( byval sx as single, byval sy as single )
	declare sub LoadRotation( byval Degrees as integer )
	declare sub Copy( byref Matrix as const Matrix2D )
	declare sub Copy( Array() as single )
	declare sub Multiply( byref Matrix as const Matrix2D )
	declare function TransformPoint( byref P as const Vector2D ) as Vector2D
	declare sub Rotate( byval Degrees as integer )
	declare sub Translate( byval tx as single, byval ty as single )
	declare sub Scale( byval sx as single, byval sy as single )

private:

	dim as single Elements(2,2)		'' (x,y)
	
End Type



#endif

