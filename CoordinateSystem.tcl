# Copyright (c) 2021-2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval tomato::mathcsys {
    # Ruff documentation
    variable _ruff_preamble "A Class representing a Coordinate System."
}

oo::class create tomato::mathcsys::Csys {

    variable _origin
    variable _xaxis
    variable _yaxis
    variable _zaxis
    variable _baseclass

    constructor {args} {
        # Initializes a new Coordinate System Class.
        #
        # args - Options described below.
        #
        # Matrix   - A Matrix. [mathmatrix::Matrix]<br>
        #            Xaxis  == Column 0<br>
        #            Yaxis  == Column 1<br>
        #            Zaxis  == Column 2<br>
        #            Origin == Column 3
        # 4 values - 4 distinct values :<br>
        #            The first value represents the origin [mathpt3d::Point3d]<br>
        #            The second value represents the Xaxis [mathvec3d::Vector3d]<br>
        #            The third value represents the Yaxis [mathvec3d::Vector3d]<br>
        #            The fourth value represents the Zaxis [mathvec3d::Vector3d]<br>

        if {[llength $args] == 1} {

            if {[TypeOf $args Isa "Matrix"]} {
                
                set _baseclass $args
                set _xaxis   [tomato::mathvec3d::Vector3d new [lrange [$_baseclass GetColumn 0] 0 2]]
                set _yaxis   [tomato::mathvec3d::Vector3d new [lrange [$_baseclass GetColumn 1] 0 2]]
                set _zaxis   [tomato::mathvec3d::Vector3d new [lrange [$_baseclass GetColumn 2] 0 2]]
                set _origin  [tomato::mathpt3d::Point3d   new [lrange [$_baseclass GetColumn 3] 0 2]]
            } else {
                error "Must be a matrix if args equal to 1..."
            }

        } elseif {[llength $args] == 4} {

            foreach entity $args {
                if {![tomato::helper::IsaObject $entity]} {
                    error "\$entity must be a object..."
                }
            }

            lassign $args _or v1 v2 v3

            if {![TypeOf $_or Isa "Point3d"]} {
                error "\[lindex $args 0\] must be a Point3d..."
            }

            foreach entity [list $v1 $v2 $v3] {
                if {![TypeOf $entity Isa "Vector3d"]} {
                    error "\$entity must be a Vector3d..."
                }
            }

            set mat [tomato::mathmatrix::Matrix new 4 4]
            set _baseclass $mat

            set _xaxis   $v1
            set _yaxis   $v2
            set _zaxis   $v3
            set _origin $_or

            $mat SetColumn 0 [list {*}[$_xaxis Get] 0]
            $mat SetColumn 1 [list {*}[$_yaxis Get] 0]
            $mat SetColumn 2 [list {*}[$_zaxis Get] 0]
            $mat SetColumn 3 [list {*}[$_origin Get] 1]

        } else {
            # default values
            set mat [tomato::mathmatrix::Matrix new 4 4]
            set _baseclass $mat

            set _xaxis  [tomato::mathvec3d::UnitX]
            set _yaxis  [tomato::mathvec3d::UnitY]
            set _zaxis  [tomato::mathvec3d::UnitZ]
            set _origin [tomato::mathpt3d::Point3d new 0 0 0]
            
            $mat SetColumn 0 [list {*}[$_xaxis Get] 0]
            $mat SetColumn 1 [list {*}[$_yaxis Get] 0]
            $mat SetColumn 2 [list {*}[$_zaxis Get] 0]
            $mat SetColumn 3 [list {*}[$_origin Get] 1]

        }
    }
}

oo::define tomato::mathcsys::Csys {

    method XAxis {} {
        # Gets the X Axis
        #
        # Returns A vector [mathvec3d::Vector3d]
        return $_xaxis
    }

    method YAxis {} {
        # Gets the Y Axis
        #
        # Returns A vector [mathvec3d::Vector3d]
        return $_yaxis
    }

    method ZAxis {} {
        # Gets the Z Axis
        #
        # Returns A vector [mathvec3d::Vector3d]
        return $_zaxis
    }

    method Origin {} {
        # Gets the Origin
        #
        # Returns A point [mathpt3d::Point3d]
        return $_origin
    }

    method BaseClass {} {
        # Gets the base class (Matrix obj)
        return $_baseclass
    }

    method OffsetToBase {} {
        # Gets the offset to origin
        #
        # Returns A vector [mathvec3d::Vector3d]
        return [$_origin ToVector3D]
    }

    method BaseChangeMatrix {} {
        # Gets the base change matrix
        #
        # Returns A matrix [mathmatrix::Matrix]
        set matrix [tomato::mathcsys::GetRotationSubMatrix [self]]
        set cs [tomato::mathcsys::SetRotationSubMatrix [$matrix Transpose] [self]]
        return [$cs BaseClass]

    }

    method Transform {entity} {
        # Transforms...
        # 
        # entity - Options described below.
        #
        # Csys     - [Csys]
        # Vector3d - [mathvec3d::Vector3d]
        # Point3d  - [mathpt3d::Point3d]
        # Ray3d    - [mathray3d::Ray3d]
        #
        # Returns a new entity transformed

        switch -glob [$entity GetType] {
            *Csys {
                return [tomato::mathcsys::Csys new [[my BaseClass] Multiply [$entity BaseClass]]]
            }
            *Vector3d {
                set matrix [tomato::mathcsys::GetRotationSubMatrix [self]]
                lassign [$matrix Multiply $entity] x y z

                return [tomato::mathvec3d::Vector3d new $x $y $z]
            }
            *Point3d {
                set mat [tomato::mathmatrix::Matrix new 1 4]
                $mat SetRow 0 [list {*}[$entity Get] 1]

                lassign [[my BaseClass] Multiply $mat] x y z

                return [tomato::mathpt3d::Point3d new $x $y $z]
            }
            *Ray3d {
                return [tomato::mathray3d::Ray3d new [[self] Transform [$entity ThroughPoint]] [[self] Transform [$entity Direction]]]
            }
            default {
                error "Entity must be Csys, Vector3d, Point3d or Ray3d..."
            }
        }

    }

    method TransformBy {entity} {
        # Transforms...
        # 
        # entity - Options described below.
        #
        # Csys   - [Csys]
        # Matrix - [mathmatrix::Matrix]
        #
        # Returns this by the coordinate system and returns the transformed if csys or a transformed coordinate system if matrix.

        switch -glob [$entity GetType] {
            *Csys {
                return [$entity Transform [self]]
            }
            *Matrix {
                return [tomato::mathcsys::Csys new [$entity Multiply [my BaseClass]]]
            }
            default {
                error "Entity must be Csys or Matrix..."
            }
        }

    }

    method ResetRotations {} {
        # Resets rotations preserves scales
        #
        # Returns A new coordinate system with reset rotation [Csys]

        set x [[[my XAxis] Length] * [tomato::mathvec3d::UnitX]]
        set y [[[my YAxis] Length] * [tomato::mathvec3d::UnitY]]
        set z [[[my ZAxis] Length] * [tomato::mathvec3d::UnitZ]]

        return [tomato::mathcsys::Csys new [my Origin] $x $y $z]

    }

    method RotateCoordSysAroundVector {about angle} {
        # Rotates a coordinate system around a vector
        #
        # about - A vector [mathvec3d::Vector3d]
        # angle - An angle in degrees
        #
        # Returns A rotated coordinate system [Csys]

        set rcs [tomato::mathcsys::RotationAngleVector $angle $about]
        return [$rcs Transform [self]]

    }

    method RotateNoReset {yaw pitch roll} {
        # Rotate without Reset
        #
        # yaw - The yaw
        # pitch - The pitch
        # roll - The roll
        #
        # Returns A rotated coordinate system [Csys]

        set rcs [tomato::mathcsys::RotationByAngles $yaw $pitch $roll]
        return [$rcs Transform [self]]

    }

    method OffsetBy {v} {
        # Translates a coordinate system
        #
        # v - a translation vector [mathvec3d::Vector3d]
        #
        # Returns A new translated coordinate system [Csys]

        set vnormalize [$v Normalized]
        return [tomato::mathcsys::Csys new [[my Origin] + $vnormalize] [my XAxis] [my YAxis] [my ZAxis]]

    }

    method TranslateCsys {v d} {
        # Translates a coordinate system follow vector and distance
        #
        # v - a translation vector [mathvec3d::Vector3d]
        # d - Distance translation
        #
        # Returns A new translated coordinate system [Csys]
        return [tomato::mathcsys::Csys new [[my Origin] TranslatePoint $v $d] [my XAxis] [my YAxis] [my ZAxis]]

    }

    method TransformToCoordSys {entity} {
        # Transforms entity according to this change matrix
        # 
        # entity - Options described below.
        #
        # Ray3d   - [mathray3d::Ray3d]
        # Point3d - [mathpt3d::Point3d]
        #
        # Returns a transformed point if Point3d or a transformed ray [mathray3d::Ray3d] if Ray3d.

        switch -glob [$entity GetType] {
            *Ray3d {
                set p  [$entity ThroughPoint]
                set uv [$entity Direction]

                set baseChangeMatrix [my BaseChangeMatrix]

                # The position and the vector are transformed
                set point [[[$baseChangeMatrix ToCsys] Transform $p] + [my OffsetToBase]]
                set direction [$uv TransformBy $baseChangeMatrix]

                return [tomato::mathray3d::Ray3d new $point $direction]
            }
            *Point3d {
                set baseChangeMatrix [my BaseChangeMatrix]
                set point [[[$baseChangeMatrix ToCsys] Transform $entity] + [my OffsetToBase]]

                return $point
            }
            default {
                error "Entity must be Ray3d Or Point3d..."
            }
        }

    }

    method TransformFromCoordSys {entity} {
        # Transforms entity according to the inverse of this change matrix
        # 
        # entity - Options described below.
        #
        # Ray3d   - [mathray3d::Ray3d]
        # Point3d - [mathpt3d::Point3d]
        #
        # Returns a transformed point [mathpt3d::Point3d] if Point3d or a transformed ray if Ray3d.

        switch -glob [$entity GetType] {
            *Ray3d {
                set p  [$entity ThroughPoint]
                set uv [$entity Direction]

                set baseChangeMatrix [my BaseChangeMatrix]
                set matinv    [$baseChangeMatrix Inverse]
                set mattocsys [$matinv ToCsys]

                set point [[$mattocsys Transform $p] + [my OffsetToBase]]
                set direction [$mattocsys Transform $uv]

                return [tomato::mathray3d::Ray3d new $point $direction]
            }
            *Point3d {
                set baseChangeMatrix [my BaseChangeMatrix]
                set point [[[[$baseChangeMatrix Inverse] ToCsys] Transform $entity] + [my OffsetToBase]]

                return $point
            }
            default {
                error "Entity must be Ray3d Or Point3d..."
            }
        }

    }

    method SetTranslation {v} {
        # Gets a translation coordinate system
        #
        # v - [mathvec3d::Vector3d]
        #
        # Returns A new coordinate system [Csys]
        return [tomato::mathcsys::Csys new [$v ToPoint3D] [my XAxis] [my YAxis] [my ZAxis]]

    }

    method Invert {} {
        # Inverts this coordinate system
        #
        # Returns An inverted coordinate system [Csys]
        return [tomato::mathcsys::Csys new [[my BaseClass] Inverse]]

    }

    method == {other {tolerance $::tomato::helper::TolEquals}} {
        # Gets value that indicates whether each pair of elements in two specified coordinate system is equal.
        #
        # other     - The second coordinate system [Csys] to compare.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the coordinate system are the same. Otherwise false.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolEquals
        }

        return [expr {[tomato::mathcsys::Equals [self] $other $tolerance]}]
        
    }

    method != {other {tolerance $::tomato::helper::TolEquals}} {
        # Gets value that indicates whether any pair of elements in two specified coordinate system is not equal.
        #
        # other - The second coordinate system [Csys] to compare.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the coordinate system are different. Otherwise false.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolEquals
        }

        return [expr {![tomato::mathcsys::Equals [self] $other $tolerance]}]
        
    }

    method GetType {} {
        # Gets the name of class.
        return [tomato::helper::TypeClass [self]]
    }

    method ToString {} {
        # Returns a string representation of this object.
        lappend infocsys [list Origin: [$_origin ToString]]
        lappend infocsys [list XAxis: [$_xaxis ToString]]
        lappend infocsys [list YAxis: [$_yaxis ToString]]
        lappend infocsys [list ZAxis: [$_zaxis ToString]]

        return [join $infocsys ", "]

    }

    export XAxis YAxis ZAxis Origin BaseClass ToString GetType ResetRotations Invert
    export RotateCoordSysAroundVector RotateNoReset OffsetBy BaseChangeMatrix TranslateCsys
    export OffsetToBase TransformBy Transform TransformFromCoordSys TransformToCoordSys SetTranslation
    export == !=

}

proc tomato::mathcsys::Parse {args} {
    # Transform a list to coordinate system 
    #
    # args - Options described below.
    #
    # The first  value represents the origin \[Tcl list]<br>
    # The second value represents the Xaxis \[Tcl list]<br>
    # The third  value represents the Yaxis \[Tcl list]<br>
    # The fourth value represents the Zaxis \[Tcl list]<br>
    #
    # Returns A new coordinate system [Csys]

    if {[llength $args] == 1} {

        if {[llength {*}$args] != 4} {
            error "must be a list 4 elements..."
        }

        lassign {*}$args or vx vy vz

        set p  [tomato::mathpt3d::Point3d new $or]
        set v1 [tomato::mathvec3d::Vector3d new $vx]
        set v2 [tomato::mathvec3d::Vector3d new $vy]
        set v3 [tomato::mathvec3d::Vector3d new $vz]

        return [tomato::mathcsys::Csys new $p $v1 $v2 $v3]

    } elseif {[llength $args] == 4} {

        lassign $args or vx vy vz

        set p  [tomato::mathpt3d::Point3d new $or]
        set v1 [tomato::mathvec3d::Vector3d new $vx]
        set v2 [tomato::mathvec3d::Vector3d new $vy]
        set v3 [tomato::mathvec3d::Vector3d new $vz]

        return [tomato::mathcsys::Csys new $p $v1 $v2 $v3]
        
    } else {
        error "must be a list of 1 with 4 sub lists or 4 elements..."
    }
}

proc tomato::mathcsys::RotateTo {fromVector3D toVector3D {axis "null"}} {
    # Sets to the matrix of rotation that aligns the 'from' vector with the 'to' vector.<br>
    # The optional Axis argument may be used when the two vectors are perpendicular and in opposite directions<br>
    # to specify a specific solution, but is otherwise ignored.<br>
    #
    # fromVector3D - Input Vector object to align from.
    # toVector3D   - Input Vector object to align to.
    # axis         - Input Vector object.
    #
    # Returns A rotated coordinate system [Csys]

    set r [tomato::mathmatrix3d::RotationTo $fromVector3D $toVector3D $axis]
    set coordinateSystem [tomato::mathcsys::Csys new]
    set cs [tomato::mathcsys::SetRotationSubMatrix $r $coordinateSystem]

    return $cs

}

proc tomato::mathcsys::SetRotationSubMatrix {r coordinateSystem} {
    # Creates a rotating coordinate system
    #
    # r                  - A 3x3 matrix with the rotation portion [mathmatrix::Matrix]
    # coordinateSystem   - A rotated coordinate system [Csys]
    #
    # Returns A rotating coordinate system [Csys]
    if {[$r RowCount] != 3 || [$r ColumnCount] != 3} {
        error "[tomato::helper::TypeClass $r] must be Matrix3x3..."
    }

    set cs [tomato::mathcsys::Csys new [$coordinateSystem Origin] \
                                     [$coordinateSystem XAxis] \
                                     [$coordinateSystem YAxis] \
                                     [$coordinateSystem ZAxis] \
                                     ]

    set csbase [$cs BaseClass]
    $csbase SetSubMatrix 0 [$r RowCount] 0 [$r ColumnCount] $r

    return [tomato::mathcsys::Csys new $csbase]

}


proc tomato::mathcsys::RotationAngleVector {angle v} {
    # Creates a rotating coordinate system
    #
    # angle - Angle to rotate in degrees
    # v   - Vector to rotate about [mathvec3d::Vector3d]
    #
    # Returns A rotating coordinate system [Csys]

    set mat [tomato::mathmatrix::Matrix new 4 4]
    $mat SetSubMatrix 0 3 0 3 [tomato::mathmatrix3d::RotationAroundArbitraryVector [$v Normalized] [tomato::helper::DegreesToRadians $angle]]

    $mat SetCell 3 3 1

    return [tomato::mathcsys::Csys new $mat]

}

proc tomato::mathcsys::RotationByAngles {yaw pitch roll} {
    # Rotation around Z (yaw) then around Y (pitch) and then around X (roll)
    # http://en.wikipedia.org/wiki/Aircraft_principal_axes
    #
    # yaw   - Rotates around Z (angle in degrees)
    # pitch - Rotates around Y (angle in degrees)
    # roll  - Rotates around X (angle in degrees)
    #
    # Returns A rotated coordinate system [Csys]

    set cs [tomato::mathcsys::Csys new]

    set yt [tomato::mathcsys::Yaw $yaw]
    set pt [tomato::mathcsys::Pitch $pitch]
    set rt [tomato::mathcsys::Roll $roll]

    return [$rt Transform [$pt Transform [$yt Transform $cs]]]

}

proc tomato::mathcsys::Yaw {av} {
    # Rotates around Z
    #
    # av - Angle  in degrees
    #
    # Returns A rotated coordinate system [Csys]
    return [tomato::mathcsys::RotationAngleVector $av [tomato::mathvec3d::UnitZ]]
    
}

proc tomato::mathcsys::Pitch {av} {
    # Rotates around Y
    #
    # av - Angle  in degrees
    #
    # Returns A rotated coordinate system [Csys]
    return [tomato::mathcsys::RotationAngleVector $av [tomato::mathvec3d::UnitY]]
    
}

proc tomato::mathcsys::Roll {av} {
    # Rotates around X
    #
    # av - Angle  in degrees
    #
    # Returns A rotated coordinate system [Csys]
    return [tomato::mathcsys::RotationAngleVector $av [tomato::mathvec3d::UnitX]]
    
}

proc tomato::mathcsys::GetRotationSubMatrix {coordinateSystem} {
    # Gets a rotation submatrix from a coordinate system
    #
    # coordinateSystem - [Csys]
    #
    # Returns A rotation matrix [mathmatrix::Matrix]
    set csbase [$coordinateSystem BaseClass]
    return [$csbase SubMatrix 0 3 0 3]
    
}

proc tomato::mathcsys::CreateMappingCoordinateSystem {fromCs toCs} {
    # Creates a coordinate system that maps from the 'from' coordinate system to the 'to' coordinate system.
    #
    # fromCs - The from coordinate system [Csys]
    # toCs   - The to coordinate system [Csys]
    #
    # Returns A mapping coordinate system [Csys]
    set singular 0
    set det -1

    try {
        set det [[$fromCs BaseClass] Determinant]
    } trap {singular} {} {
        set singular 1
    } on error {msg} {
        error $msg
    }

    if {$singular || (abs($det) < $::tomato::helper::TolEquals)} {
        set mat [[$toCs BaseClass] Multiply [$fromCs BaseClass]]
    } else {
        set mat [[$toCs BaseClass] Multiply [[$fromCs BaseClass] Inverse]]
    }

    $mat SetCell 3 3 1

    return [tomato::mathcsys::Csys new $mat]

}

proc tomato::mathcsys::SetToAlignCoordinateSystems {fromOrigin fromXAxis fromYAxis fromZAxis toOrigin toXAxis toYAxis toZAxis} {
    # Sets this matrix to be the matrix that maps from the 'from' coordinate system to the 'to' coordinate system.
    #
    # fromOrigin - Input [mathpt3d::Point3d] that defines the origin to map the coordinate system from
    # fromXAxis  - Input [mathvec3d::Vector3d] object that defines the X-axis to map the coordinate system from.
    # fromYAxis  - Input [mathvec3d::Vector3d] object that defines the Y-axis to map the coordinate system from.
    # fromZAxis  - Input [mathvec3d::Vector3d] object that defines the Z-axis to map the coordinate system from.
    # toOrigin   - Input [mathpt3d::Point3d] object that defines the origin to map the coordinate system to.
    # toXAxis    - Input [mathvec3d::Vector3d] object that defines the X-axis to map the coordinate system to.
    # toYAxis    - Input [mathvec3d::Vector3d] object that defines the Y-axis to map the coordinate system to.
    # toZAxis    - Input [mathvec3d::Vector3d] object that defines the Z-axis to map the coordinate system to.
    #
    # Returns A mapping coordinate system [Csys]

    set cs1 [tomato::mathcsys::Csys new $fromOrigin $fromXAxis $fromYAxis $fromZAxis]
    set cs2 [tomato::mathcsys::Csys new $toOrigin $toXAxis $toYAxis $toZAxis]
    set mcs [tomato::mathcsys::CreateMappingCoordinateSystem $cs1 $cs2]

    return $mcs

}

proc tomato::mathcsys::Translation {translation} {
    # Creates a translation.
    #
    # translation - A translation vector [mathvec3d::Vector3d]
    #
    # Returns A translated coordinate system [Csys]
    return [tomato::mathcsys::Csys new [$translation ToPoint3D] [tomato::mathvec3d::UnitX] [tomato::mathvec3d::UnitY] [tomato::mathvec3d::UnitZ]]

}

proc tomato::mathcsys::Equals {cs other tolerance} {
    # Indicate if this coordinate system is equivalent to a another coordinate system
    #
    # cs - First input coordinate system  [Csys]
    # other - Second input coordinate system  [Csys]
    # tolerance - A tolerance (epsilon) to adjust for floating point error
    #
    # Returns true if the coordinate system are equal, otherwise false.
    #
    # See : methods == !=
    if {$tolerance < 0} {
        #ruff
        # An error exception is raised if tolerance (epsilon) < 0.
        error "epsilon < 0"
    }
    return [expr {
                  [tomato::mathpt3d::Equals  [$cs Origin] [$other Origin] $tolerance] && 
                  [tomato::mathvec3d::Equals [$cs XAxis] [$other XAxis] $tolerance] && 
                  [tomato::mathvec3d::Equals [$cs YAxis] [$other YAxis] $tolerance] && 
                  [tomato::mathvec3d::Equals [$cs ZAxis] [$other ZAxis] $tolerance]
                }]
}