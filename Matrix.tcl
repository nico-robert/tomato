# Copyright (c) 2021-2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval tomato::mathmatrix {
    # Ruff documentation
    variable _ruff_preamble "Defines the base class for Matrix classes."
}

oo::class create tomato::mathmatrix::Matrix {
    
    variable _rowCount
    variable _columnCount
    variable _values

    constructor {row col {value 0.0}} {
        # Initializes a new base class for Matrix Class.
        #
        # row   - Number of rows.
        # col   - Number of columns.
        # value - Init value matrix

        set matrix {}

        for {set r 0} {$r < $row} {incr r} {
            set datamat {}

            for {set c 0} {$c < $col} {incr c} {
                lappend datamat $value
            }

            lappend matrix $datamat
        }        

        set _rowCount    $row
        set _columnCount $col
        set _values $matrix

    }
}

oo::define tomato::mathmatrix::Matrix {

    method RowCount {} {
        # Gets the number of rows.
        return $_rowCount
    }

    method ColumnCount {} {
        # Gets the number of columns.
        return $_columnCount
    }

    method Values {} {
        # Gets the matrix's data.
        return $_values
    }

    method SetCell {rowIndex colIndex value} {
        # Set the cell value of base matrix
        #
        # rowIndex - index of row
        # colIndex - index of column
        # value    - value of row/column
        #
        # Returns nothing
        if {$colIndex > ($_columnCount - 1)} {
            error "Index Column must be between 0 & [expr {$_columnCount - 1}]"
        }
        if {$rowIndex > ($_rowCount - 1)} {
            error "Index Row must be between 0 & [expr {$_rowCount - 1}]"
        }

        lset _values [list $rowIndex $colIndex] $value
    }

    method GetCell {rowIndex colIndex} {
        # Gets the cell value of base matrix
        #
        # rowIndex - index of row
        # colIndex - index of column
        #
        # Returns value of row/column
        if {$colIndex > ($_columnCount - 1)} {
            error "Index Column must be between 0 & [expr {$_columnCount - 1}]"
        }
        if {$rowIndex > ($_rowCount - 1)} {
            error "Index Row must be between 0 & [expr {$_rowCount - 1}]"
        }
        return [lindex $_values $rowIndex $colIndex]
    }

    method SetColumn {colIndex columnlistvalues} {
        # Set Column of base matrix.
        #
        # colIndex  - index of column
        # columnlistvalues - values of column
        #
        # Returns nothing
        if {$colIndex > ($_columnCount - 1)} {
            error "Index Column must be between 0 & [expr {$_columnCount - 1}]"
        }

        if {[llength $columnlistvalues] != $_rowCount} {
            error "All vectors must have the same dimensionality."
        }

        set len [my RowCount]

        for {set row 0} {$row < $len} {incr row} {
            lset _values [list $row $colIndex] [lindex $columnlistvalues $row]
        }
    }

    method GetColumn {colIndex} {
        # Gets Column of base matrix.
        #
        # colIndex  - index of column
        #
        # Returns values of column
        if {$colIndex > ($_columnCount - 1)} {
            error "Index Column must be between 0 & [expr {$_columnCount - 1}]"
        }

        set len [my RowCount]

        for {set row 0} {$row < $len} {incr row} {
            lappend valcolumn [lindex $_values $row $colIndex]
        }

        return $valcolumn
    }

    method SetRow {rowIndex rowlistvalues} {
        # Set Row of base matrix.
        #
        # rowIndex  - index of row
        # rowlistvalues - values of row
        #
        # Returns nothing
        if {($rowIndex + 1) > $_rowCount} {
            error "Index Row must be between 0 & [expr {$_rowCount - 1}]"
        }

        if {[llength $rowlistvalues] != $_columnCount} {
            error "All vectors must have the same dimensionality."
        }

        lset _values $rowIndex $rowlistvalues
    }

    method GetRow {rowIndex} {
        # Get Row of base matrix.
        #
        # rowIndex  - index of row
        #
        # Returns values of row
        if {($rowIndex + 1) > $_rowCount} {
            error "Index Row must be between 0 & [expr {$_rowCount - 1}]"
        }

        return [lindex $_values $rowIndex]

    }

    method Add {other} {
        # Add matrix to another matrix
        #
        # other - [Matrix]
        #
        # Return a new base matrix [Matrix]
        if {([my RowCount] != [$other RowCount]) || ([my ColumnCount] != [$other ColumnCount])} {
            error "DimensionsDontMatch..."
        }

        set mat [oo::copy [self]] ; # copy matrix...
        set len [$mat RowCount]

        for {set row 0} {$row < $len} {incr row} {

            set addresult {}

            foreach cell1 [$mat GetRow $row] cell2 [$other GetRow $row] {
                lappend addresult [expr {$cell1 + $cell2}]
            }

            $mat SetRow $row $addresult
        }

        return $mat

    }

    method Multiply {entity} {
        # Multiply matrix...
        # 
        # entity - Options described below.
        #
        # value  - A double value
        # Matrix - [Matrix]
        # Vector - [mathvec3d::Vector3d]
        #
        # Returns a new base matrix [Matrix] if double value , a TCL list for other types
        set mat [oo::copy [self]]

        if {[string is double $entity]} {
            return [tomato::mathmatrix::MatrixMulByDouble $mat $entity]
        }

        switch -glob [$entity GetType] {
            *Matrix {
                if {[$mat ColumnCount] != [$entity ColumnCount]} {
                    error "DimensionsDontMatch..."
                }

                if {[$entity RowCount] == 1} {
                    return [tomato::mathmatrix::MatrixMulColumnVector $mat $entity] ; # return tcl list values
                }
            
                return [tomato::mathmatrix::MatrixMulMatrix $mat $entity] ; # return tcl list values
            }
            *Vector3d {
                if {[$mat ColumnCount] != 3} {
                    error "ColumnCount not match..."
                }

                if {[$mat RowCount] != 3} {
                    error "RowCount not match..."
                }

                return [tomato::mathmatrix::MatrixMulVector $mat $entity] ; # return tcl list values
            }
            default {
                error "Entity must be Matrix, Vector3d or Double Value..."
            }
        }

    }

    method SubMatrix {rowIndex rowCount columnIndex columnCount} {
        # Creates a matrix that contains the values from the requested sub-matrix.
        #
        # rowIndex    - The row to start copying from.
        # rowCount    - The number of rows to copy. Must be positive.
        # columnIndex - The column to start copying from.
        # columnCount - The number of columns to copy. Must be positive.
        #
        # Returns The requested sub-matrix [Matrix].
        set target [self]

        set storage [tomato::mathmatrix::Matrix new $rowCount $columnCount]
        return [tomato::mathmatrix::CopySubMatrixTo $storage $target $rowIndex 0 $rowCount $columnIndex 0 $columnCount]


    }

    method SetSubMatrix {args} {
        # Copies the values of a given matrix into a region in this matrix.
        #
        # args - Options described below.
        #
        # rowIndex    - The row to start copying to.
        # rowCount    - The number of rows to copy. Must be positive.
        # subMatrix   - The sub-matrix to copy from.
        # Or          - 
        # rowIndex    - The row to start copying to.
        # rowCount    - The number of rows to copy. Must be positive.
        # columnIndex - The column to start copying to.
        # columnCount - The number of columns to copy. Must be positive.
        # subMatrix   - The sub-matrix to copy from.
        #
        # Returns base matrix [Matrix]

        set target [self]

        if {[llength $args] == 3} {

            lassign $args rowIndex columnIndex subMatrix
            return [tomato::mathmatrix::CopySubMatrixTo $target $subMatrix 0 $rowIndex [$subMatrix RowCount] 0 $columnIndex [$subMatrix ColumnCount]]
            
        } elseif {[llength $args] == 5} {

            lassign $args rowIndex rowCount columnIndex columnCount subMatrix
            return [tomato::mathmatrix::CopySubMatrixTo $target $subMatrix 0 $rowIndex $rowCount 0 $columnIndex $columnCount]
        
        } else {
            error "llength args must be 3 or 5..."
        }

    }

    method Transpose {} {
        # Transpose a matrix.
        # [mathematica Transpose](http://reference.wolfram.com/mathematica/ref/Transpose.html)
        #
        # Returns a new transposed matrix [Matrix]

        set matrix [my Values]
        set transpose [tomato::mathmatrix::Matrix new [my ColumnCount] [my RowCount]] ; # inverse row & column
        set c 0
        set r 0

        foreach col [lindex $matrix 0] {
            set newrow {}
            foreach row $matrix {
                lappend newrow [lindex $row $c]
            }
            $transpose SetRow $r $newrow
            incr c
            incr r
        }

        return $transpose
        
    }

    method Determinant {} {
        # Gets the determinant of the matrix for which the Crout's LU decomposition was computed.

        lassign [my Decompose] toggle lum perm
        set result $toggle
        set len [$lum RowCount]

        for {set i 0} {$i < $len} {incr i} {
            set result [expr {$result * [$lum GetCell $i $i]}]
        }

        return $result
    }

    method Decompose {} {
        # The combined lower-upper decomposition of matrix
        # 
        # See also: MatrixDecompose
        return [tomato::mathmatrix::MatrixDecompose [self]]

    }

    method Inverse {} {
        # Matrix inverse using Crout's LU decomposition
        if {[my Determinant] == 0.0} {
            throw {singular} "Matrix is singular..." 
        }

        return [tomato::mathmatrix::MatrixInverse [self]]

    }

    method IsOrthogonal {} {
        # Gets if matrix is orthogonal
        if {[my ColumnCount] != [my RowCount]} {
            # error "Matrix is not square..."
            return 0
        }        

        return [[[my Transpose] Multiply [self]] == [tomato::mathmatrix::CreateIdentity [my RowCount]]]

    }    

    method == {other {tolerance $::tomato::helper::TolEquals}} {
        # Gets value that indicates whether each pair of elements in two specified matrixes is equal.
        #
        # other     - The second matrix [Matrix] to compare.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the matrixes are the same. Otherwise false.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolEquals
        }

        return [expr {[tomato::mathmatrix::Equals [self] $other $tolerance]}]
        
    }

    method != {other {tolerance $::tomato::helper::TolEquals}} {
        # Gets value that indicates whether any pair of elements in two specified matrixes is not equal.
        #
        # other - The second matrix [Matrix] to compare.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the matrixes are different. Otherwise false.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolEquals
        }

        return [expr {![tomato::mathmatrix::Equals [self] $other $tolerance]}]
        
    }

    method GetType {} {
        # Gets the name of class.
        return [tomato::helper::TypeClass [self]]
    }

    method GetSize {} {
        # Returns the size of this object.
        return [format {%sx%s} [my RowCount] [my ColumnCount]]
    }

    method ToCsys {} {
        # Returns a csys from Matrix.
        if {([my RowCount] != 4) && ([my ColumnCount] != 4)} {
            error "Must be a Matrix 4x4..."
        }
        return [tomato::mathcsys::Csys new [self]]
    }

    method ToMatrixString {} {
        # Returns a string representation of this object.
        return [join [my Values] "\n"]
    }

    export RowCount ColumnCount Values GetRow SetRow GetCell SetCell Multiply ToMatrixString GetType GetSize
    export Add GetColumn SetColumn SetSubMatrix SubMatrix Transpose Determinant Decompose Inverse ToCsys
    export == != IsOrthogonal

}


proc tomato::mathmatrix::SetNewDataListMatrix {data} {
    # Create a new base matrix [Matrix] based on a list
    #
    # data - list
    #
    # Returns A new [Matrix]

    set row    [llength $data]
    set column [llength [lindex $data 0]]

    set mat [tomato::mathmatrix::Matrix new $row $column]
    set r 0

    foreach row $data {
        $mat SetRow $r $row
        incr r
    }

    return $mat
}


proc tomato::mathmatrix::CreateIdentity {size} {
    # Create a new identity matrix where each diagonal value is set to One.<br>
    # From package tcllib [math::linearalgebra](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/math/linalg.md)
    # *(Modify according to my needs)*.
    #
    # size - dimension of matrix
    #
    # Returns a new base matrix indentity [Matrix]
    set mat [tomato::mathmatrix::Matrix new $size $size]

    while { $size > 0 } {
        incr size -1
        $mat SetCell $size $size 1.0
    }

    return $mat
}


proc tomato::mathmatrix::CopyTo {target storage} {
    # Copies the elements of this matrix to the given matrix.
    #
    # target - The matrix [Matrix] to copy values into.
    # storage - The base matrix [Matrix].
    #
    # Returns matrix [Matrix]

    if {[$storage RowCount] != [$target RowCount] || [$storage ColumnCount] != [$target ColumnCount]} {
        error "Matrix dimensions must agree: op1 is [$storage GetSize], op2 is [$target GetSize]."
    }

    for {set j 0} {$j < [$storage ColumnCount] } {incr j} {
        for {set i 0} {$i < [$storage RowCount]} {incr i} {
            $target SetCell $i $j [$storage GetCell $i $j]
        }
    }

    return $target
}

proc tomato::mathmatrix::CopySubMatrixTo {target storage sourceRowIndex targetRowIndex rowCount sourceColumnIndex targetColumnIndex columnCount} {
    # Copies the values of a given matrix into a region in this matrix.
    #
    # target             - The matrix [Matrix] to copy values into.
    # storage            - The base matrix [Matrix].
    # sourceRowIndex     - The row index of source
    # targetRowIndex     - The row index of target
    # rowCount           - The number of rows to copy
    # sourceColumnIndex  - The column index of source
    # targetColumnIndex  - The column index of source
    # columnCount        - The number of columns to copy
    #
    # Returns matrix copy [Matrix]

    if {$rowCount == 0 || $columnCount == 0} {
        return $target
    }

    if {($sourceRowIndex == 0) && ($targetRowIndex == 0 )
        && ($rowCount == [$storage RowCount]) && ($rowCount == [$target RowCount])
        && ($sourceColumnIndex == 0) && ($targetColumnIndex == 0)
        && ($columnCount == [$storage ColumnCount]) && ($columnCount == [$target ColumnCount])} {

        return [tomato::mathmatrix::CopyTo $target $storage]
    }

    for {set j $sourceColumnIndex ; set jj $targetColumnIndex} {$j < [expr {$sourceColumnIndex + $columnCount}]} {incr j ; incr jj} {
        for {set i $sourceRowIndex ; set ii $targetRowIndex} {$i < [expr {$sourceRowIndex + $rowCount}]} {incr i ; incr ii} {
            $target SetCell $ii $jj [$storage GetCell $i $j]
        }
    }

    return $target

}

proc tomato::mathmatrix::MatrixMulMatrix {mat other} {
    # Multiply matrix by matrix.<br>
    # From package tcllib [math::linearalgebra](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/math/linalg.md)
    # *(Modify according to my needs)*.
    #
    # mat   - base matrix [Matrix]
    # other - Second matrix [Matrix]
    #
    # Returns mul matrix [Matrix]

    set tmat [[$other Transpose] Values]
    set mat1 [$mat Values]
    set r 0

    foreach row1 $mat1 {
        set newrow {}
        foreach row2 $tmat {
            set sum 0.0
            foreach c1 $row1 c2 $row2 {
                set sum [expr {$sum + ($c1 * $c2)}]
            }
            lappend newrow $sum
        }

        $mat SetRow $r $newrow
        incr r
    }

    return $mat

}

proc tomato::mathmatrix::MatrixMulVector {mat other} {
    # Multiply matrix by vector.<br>
    # From package tcllib [math::linearalgebra](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/math/linalg.md)
    # *(Modify according to my needs)*.
    #
    # mat   - base matrix [Matrix]
    # other - vector [mathvec3d::Vector3d]
    #
    # Returns TCL list (mul matrix)
    set newvect {}
    set mat1 [$mat Values]
    set vec1 [$other Get]

    foreach row $mat1 {
        set sum 0.0
        foreach v $vec1 c $row {
            set sum [expr {$sum + $v * $c}]
        }
        lappend newvect $sum

    }

    return $newvect
}

proc tomato::mathmatrix::MatrixMulColumnVector {mat other} {
    # Multiply matrix by column vector.<br>
    # From package tcllib [math::linearalgebra](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/math/linalg.md)
    # *(Modify according to my needs)*.
    # 
    #
    # mat   - [Matrix]
    # other - [Matrix]
    #
    # Returns TCL list (mul matrix)
    set newvect {}

    set mat1 [$mat Values]
    set vec1 {*}[$other Values]

    foreach row $mat1 {
        set sum 0.0
        foreach v $vec1 c $row {
            set sum [expr {$sum + $v * $c}]
        }

        lappend newvect $sum

    }

    return $newvect
}

proc tomato::mathmatrix::MatrixMulByDouble {mat other} {
    # Multiply matrix by double value
    #
    # mat   - [Matrix]
    # other - double value
    #
    # Returns mul matrix [Matrix]
    for {set row 0} {$row < [$mat RowCount]} {incr row} {
        for {set col 0} {$col < [$mat ColumnCount]} {incr col} {
            $mat SetCell $row $col [expr {[$mat GetCell $row $col] * $other}]
        }
    }

    return $mat
}

proc tomato::mathmatrix::MatrixDecompose {storage} {
    # Crout's LU decomposition for matrix determinant and inverse
    # [docs.microsoft.com](https://docs.microsoft.com/fr-fr/archive/msdn-magazine/2016/july/test-run-matrix-inversion-using-csharp)
    #
    # storage - [Matrix]
    # 
    # Returns list with : +1 or -1 according to even or odd number of row permutations,<br>
    #                     combined lower & upper in lummat [Matrix] & row permuations into permmat [Matrix].

    set toggle 1 ; # even (+1) or odd (-1) row permutations
    set n [$storage RowCount]

    # make a copy of storage into lummat
    set lummat [tomato::mathmatrix::Matrix new $n $n]
    set lummat [tomato::mathmatrix::CopyTo $lummat $storage]

    # make permmat
    set permmat [tomato::mathmatrix::Matrix new 1 $n]
    for {set i 0} {$i < $n} {incr i} {
        $permmat SetCell 0 $i $i
    }

    for {set j 0} {$j < [expr {$n - 1}]} {incr j} { ; # process by column. note n-1 

        set max [expr {abs([$lummat GetCell $j $j])}]
        set piv $j

        for {set i [expr {$j + 1}]} {$i < $n} {incr i} { ; # find pivot index

            set xij [expr {abs([$lummat GetCell $i $j])}]
            if {$xij > $max} {
                set max $xij
                set piv $i
            }
        }

        if {$piv != $j} {

            set tmp [$lummat GetRow $piv] ; # swap rows j, piv
            $lummat SetRow $piv [$lummat GetRow $j]
            $lummat SetRow $j $tmp

            set t [$permmat GetCell 0 $piv] ; # swap perm elements
            $permmat SetCell 0 $piv [$permmat GetCell 0 $j]
            $permmat SetCell 0 $j $t

            set toggle [expr {Inv($toggle)}]

        }

        set xjj [$lummat GetCell $j $j]

        if {$xjj != 0.0} {
            
            for {set i [expr {$j + 1}]} {$i < $n} {incr i} {
                set xij [expr {[$lummat GetCell $i $j] / $xjj}]
                $lummat SetCell $i $j $xij

                for {set k [expr {$j + 1}]} {$k < $n} {incr k} {
                    $lummat SetCell $i $k [expr {[$lummat GetCell $i $k] - ($xij * [$lummat GetCell $j $k])}]
                    
                }   
            }
        }
    }

    return [list $toggle $lummat $permmat]
}

proc tomato::mathmatrix::MatrixInverse {storage} {
    # Crout's LU decomposition for matrix inverse.
    #
    # storage - A Matrix [Matrix]
    #
    # Returns A Matrix Inverse

    set n [$storage RowCount]
    set result [tomato::mathmatrix::Matrix new $n $n]
    set result [tomato::mathmatrix::CopyTo $result $storage]

    lassign [$storage Decompose] toggle lum perm

    set b [tomato::mathmatrix::Matrix new 1 $n]

    for {set i 0} {$i < $n} {incr i} {
        for {set j 0} {$j < $n} {incr j} {
            
            if {$i == [$perm GetCell 0 $j]} {
                $b SetCell 0 $j 1.0
            } else {
                $b SetCell 0 $j 0.0
            }

        }

        set x [tomato::mathmatrix::_MatrixHelper $lum $b]
        for {set j 0} {$j < $n} {incr j} {
            $result SetCell $j $i [$x GetCell 0 $j]
        }
    }

    return $result
}

proc tomato::mathmatrix::Equals {mat other tolerance} {
    # Indicate if this matrix is equivalent to a another matrix
    #
    # mat   - First input matrix  [Matrix]
    # other - Second input matrix [Matrix]
    # tolerance - A tolerance (epsilon) to adjust for floating point error
    #
    # Returns true if matrixes are equal, otherwise false.
    #
    # See : methods == !=
    if {$tolerance < 0} {
        #ruff
        # An error exception is raised if tolerance (epsilon) < 0.
        error "epsilon < 0"
    }

    if {([$mat RowCount] != [$other RowCount]) || ([$mat ColumnCount] != [$other ColumnCount])} {
        return 0
    }

    set len [$mat RowCount]

    for {set row 0} {$row < $len} {incr row} {
        foreach cellmat [$mat GetRow $row] cellother [$other GetRow $row] {
            if {abs($cellmat - $cellother) > $tolerance} {
                return 0
            }
        }
    }

    return 1
}

proc tomato::mathmatrix::_MatrixHelper {luMatrix bMatrix} {

    set n [$luMatrix RowCount]
    set x [oo::copy $bMatrix]

    for {set i 1} {$i < $n} {incr i} {

        set sum [$x GetCell 0 $i]

        for {set j 0} {$j < $i} {incr j} {
            set sum [expr {$sum - ([$luMatrix GetCell $i $j] * [$x GetCell 0 $j])}]
        }

        $x SetCell 0 $i $sum
        
    }

    set nms1 [expr {$n - 1}] 

    $x SetCell 0 $nms1 [expr {[$x GetCell 0 $nms1] / [$luMatrix GetCell $nms1 $nms1]}]

    for {set i [expr {$n - 2}] } {$i >= 0} {incr i -1} {
        set sum [$x GetCell 0 $i]

        for {set j [expr {$i + 1}] } {$j < $n} {incr j} {
            set sum [expr {$sum - ([$luMatrix GetCell $i $j] * [$x GetCell 0 $j])}]
        }

        $x SetCell 0 $i [expr {$sum / [$luMatrix GetCell $i $i]}]
        
    }

    return $x
}
