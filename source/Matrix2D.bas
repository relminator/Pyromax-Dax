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

#include once "Matrix2D.bi"

''*****************************************************************************
''
''
''
''*****************************************************************************
constructor Matrix2D()
End Constructor

destructor Matrix2D()	
End Destructor


sub Matrix2D.LoadIndentity()

	'' (1,0,0)
	'' (0,1,0)
	'' (0,0,1)

	Elements(0,0) = 1.0
	Elements(0,1) = 0.0
	Elements(0,2) = 0.0
	Elements(1,0) = 0.0
	Elements(1,1) = 1.0
	Elements(1,2) = 0.0
	Elements(2,0) = 0.0
	Elements(2,1) = 0.0
	Elements(2,2) = 1.0
	
end sub

sub Matrix2D.LoadTranslation( byval tx as single, byval ty as single )

	'' scale translate
	'' (sx, 0,tx)
	'' ( 0,sy,ty)
	
	Elements(0,0) = 1.0
	Elements(0,1) = 0.0
	Elements(0,2) = tx
	Elements(1,0) = 0.0
	Elements(1,1) = 1.0
	Elements(1,2) = ty
	Elements(2,0) = 0.0
	Elements(2,1) = 0.0
	Elements(2,2) = 1.0
	
		
end sub


sub Matrix2D.LoadScaling( byval sx as single, byval sy as single )

	'' scale translate
	'' (sx, 0,tx)
	'' ( 0,sy,ty)
	
	Elements(0,0) = sx
	Elements(0,1) = 0.0
	Elements(0,2) = 0.0
	Elements(1,0) = 0.0
	Elements(1,1) = sy
	Elements(1,2) = 0.0
	Elements(2,0) = 0.0
	Elements(2,1) = 0.0
	Elements(2,2) = 1.0
	
end sub


sub Matrix2D.LoadRotation( byval Degrees as integer )

	'' rotation
	'' (ca,-sa,0)
	'' (sa, ca,0)
	
	dim as single sa = sin( DEG2RAD(Degrees) )
	dim as single ca = cos( DEG2RAD(Degrees) )
	
	Elements(0,0) = ca
	Elements(0,1) = -sa
	Elements(0,2) = 0.0
	Elements(1,0) = sa
	Elements(1,1) = ca
	Elements(1,2) = 0.0
	Elements(2,0) = 0.0
	Elements(2,1) = 0.0
	Elements(2,2) = 1.0
	
	
end sub


sub Matrix2D.Copy( byref Matrix as const Matrix2D )

	for i as integer = 0 to 2
		for j as integer = 0 to 2 	
			Elements(i,j) = Matrix.Elements(i,j)
		next j
	next i

end sub


sub Matrix2D.Copy( Array() as single )

	for i as integer = 0 to 2
		for j as integer = 0 to 2 	
			Elements(i,j) = Array(i,j)
		next j
	next i

end sub


sub Matrix2D.Multiply( byref Matrix as const Matrix2D )

	'' Combines 2 matrices this() and matrix()
	'' ie. Result = matrix x this
	'' Warning matrix multiplication is not commutative.
	'' matrix x this != this x matrix
	
	dim Result(0 to 2, 0 to 2) as single
	for i as integer = 0 to 2
	    for j as integer = 0 to 2
	        Result(i, j) = 0
	        for k as integer = 0 to 2
	            Result(i, j) = Result(i, j) + matrix.Elements(i, k) * Elements(k, j)
	        next k
	    next j
	next i
		
	'copy to our original matrix
	for row as integer = 0 to 2
		for col as integer = 0 to 2
		    Elements(row, col) = Result(row, col)
		next col
	next row

end sub



function Matrix2D.TransformPoint( byref P as const Vector2D ) as Vector2D

	dim as Vector2D Out
	Out.x = (P.x * Elements(0,0)) +_  
		    (P.y * Elements(0,1)) +_ 
		    Elements(0,2)

	Out.y = (P.x * Elements(1,0)) +_  
	        (P.y * Elements(1,1)) +_ 
		    Elements(1,2)

	return Out
	
end function

sub Matrix2D.Rotate( byval Degrees as integer )

	dim as Matrix2D M2
	
	M2.LoadRotation( Degrees )
	
	this.Multiply( M2 )
	
end sub


sub Matrix2D.Translate( byval tx as single, byval ty as single )

	dim as Matrix2D M2
	
	M2.LoadTranslation( tx, ty )
	
	this.Multiply( M2 )
	
end sub


sub Matrix2D.Scale( byval sx as single, byval sy as single )

	dim as Matrix2D M2
	
	M2.LoadScaling( sx, sy )
	
	this.Multiply( M2 )
	
end sub


