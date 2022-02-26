# Copyright (c) 2021-2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval tomato::mathvec3d {
    # Ruff documentation
    variable _ruff_preamble "A Class representing a Vector in 3D space"
}

oo::class create tomato::mathvec3d::Vector3d {

    variable _x ; # The x component.
    variable _y ; # The y component.
    variable _z ; # The z component.

    constructor {args} {
        # Initializes a new Vector3d Class.
        #
        # args - Options described below.
        #
        # Class  - A Class [Vector3d].
        # List   - A TCL list including 3 components values.
        # values - 3 components values.
        #
        if {[llength $args] == 1} {
            # args Class Vector3d
            if {[TypeOf $args Isa "Vector3d"]} {

                set _x [$args X]
                set _y [$args Y]
                set _z [$args Z]
                
            # args list > ex : Vector3d new {1 2 3}
            } elseif {[llength {*}$args] == 3} {
                lassign {*}$args x y z

                set _x $x
                set _y $y
                set _z $z

            } else {
                #ruff
                # An error exception is list is not equal to 3 or 'Vector3d' class
                error "Must be a list of 3 values or 'Vector3d' class"
            }
        
        # args values > ex : Vector3d new 1 2 3
        } elseif {[llength $args] == 3} {
            lassign $args x y z

            set _x $x
            set _y $y
            set _z $z
            
        } else {
            # default values
            set _x 0
            set _y 0
            set _z 1
        }
    }
}

oo::define tomato::mathvec3d::Vector3d {

    method X {} {
        # Returns The x component.
        return $_x
    }

    method Y {} {
        # Returns The y component.
        return $_y
    }

    method Z {} {
        # Returns The z component.
        return $_z
    }

    method Get {} {
        # Gets values from the Vector3D Class under TCL list form.
        return [list $_x $_y $_z]
    }

    method Configure {args} {
        # Configure component value.
        #
        # args - Options described below.
        #
        # -X - The x component.
        # -Y - The y component.
        # -Z - The z component.
        foreach {key value} $args {

            if {$value eq ""} {
                error "No value specified for key '$key'"
            }

            switch -exact -- $key {
                "-X"    {set _x $value}
                "-Y"    {set _y $value}
                "-Z"    {set _z $value}
                default {error "Unknown key '$key' specified"}

            }
        }
    }

    method Cget {axis} {
        # Gets component value.
        #
        # axis - Options described below.
        #
        # -X - The x component.
        # -Y - The y component.
        # -Z - The z component.
        switch -exact -- $axis {
            "-X" {return $_x}
            "-Y" {return $_y}
            "-Z" {return $_z}
            default {error "Unknown key '$key' : $axis"}
        }

    }

    method Length {} {
        # Gets the Euclidean Norm.
        return [expr {sqrt(($_x**2) + ($_y**2) + ($_z**2))}]
    }

    method LengthSquared {} {
        # Gets the length of the vector squared
        return [expr {($_x**2) + ($_y**2) + ($_z**2)}]
    }

    method Normalized {} {
        # Compute and return a copy unit vector from this vector
        #
        # Returns a copy normalized unit vector [Vector3d] if necessary.
        set vec [self]

        if {[$vec IsNormalized]} {
            return $vec
        }

        set v [oo::copy $vec]
        $v Normalize
        return $v

    }

    method IsNormalized {{tolerance $::tomato::helper::TolGeom}} {
        # Check if vector is normalized.
        #
        # tolerance - The allowed deviation
        #
        # Returns true, if the Vector object is normalized. Otherwise false.
        if {[llength [info level 0]] < 3} {
            set tolerance $::tomato::helper::TolGeom
        }

        set norm [my Length]

        if {abs($norm - 1.0) < $tolerance} {
            return true
        }

        return false
    }

    method Normalize {} {
        # Transform self Vector to Normalize Vector.
        #
        # Returns nothing.
        #
        # See also: Normalized IsNormalized
        set norm [my Length]

        if {$norm == 0.0} {
            error "The Euclidean norm of x, y, z is equal to 0..."
        }

        set scale [expr {1.0 / $norm}]

        set _x [expr {$_x * $scale}]
        set _y [expr {$_y * $scale}]
        set _z [expr {$_z * $scale}]

        return ""
    }

    method IsPerpendicularTo {other {tolerance $::tomato::helper::TolGeom}} {
        # Computes whether or not this vector is perpendicular to another vector using the dot product method and
        # comparing it to within a specified tolerance
        #
        # other - The other vector [Vector3d] Object.
        # tolerance - A tolerance value for the dot product method.
        #
        # Returns true if the vector dot product is within the given tolerance of zero, false if not.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolGeom
        }

        set va [self]

        set vaN    [$va Normalized]
        set otherN [$other Normalized]

        set dp [expr {abs([$vaN DotProduct $otherN])}]
        return [expr {$dp < $tolerance}]

    }

    method IsParallelTo {other {tolerance $::tomato::helper::TolGeom}} {
        # Computes whether or not this vector is parallel to another vector using the Cross product method and comparing it
        # to within a specified tolerance.
        #
        # other - The other vector [Vector3d] Object.
        # tolerance - A tolerance value for the Cross product method.
        #
        # Returns true if the vector dot product is within the given tolerance of unity, false if it is not.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolGeom
        }

        set va [self]

        set vaN    [$va Normalized]
        set otherN [$other Normalized]

        set cross [$vaN CrossProduct $otherN]
        set det   [$cross LengthSquared]

        return [expr {abs($det) <= $tolerance}]

    }

    method Orthogonal {} {
        # Gets a unit vector orthogonal to this
        #
        # Returns a new vector Normalized [Vector3d].
        if {(Inv($_x) - $_y) > 0.1} {
            set v [tomato::mathvec3d::Vector3d new $_z $_z [expr {Inv($_x) - $_y}]]
            $v Normalize
            return $v
        }

        set v [tomato::mathvec3d::Vector3d new [expr {Inv($_y)- $_z}] $_x $_x]
        $v Normalize
        return $v

    }

    method DotProduct {other} {
        # Compute the dot product of two vectors.
        #
        # other - The other vector [Vector3d] Object.
        #
        # Returns the dot product.
        return [tomato::mathvec3d::Dot [self] $other]

    }

    method CrossProduct {other} {
        # Compute the cross product of this vector and another vector
        #
        # other - The other vector [Vector3d] Object.
        #
        # Returns A new vector with the cross product result.
        return [tomato::mathvec3d::Cross [self] $other]

    }

    method + {other} {
        # Adds two vectors
        #
        # other - The other vector [Vector3d] Object.
        #
        # Returns A new summed vector [Vector3d].
        set vx [expr {$_x + [$other X]}]
        set vy [expr {$_y + [$other Y]}]
        set vz [expr {$_z + [$other Z]}]

        return [tomato::mathvec3d::Vector3d new $vx $vy $vz]
    }

    method - {other} {
        # Subtracts two vectors
        #
        # other - The other vector [Vector3d] Object.
        #
        # Returns A new difference vector [Vector3d].
        set vx [expr {$_x - [$other X]}]
        set vy [expr {$_y - [$other Y]}]
        set vz [expr {$_z - [$other Z]}]

        return [tomato::mathvec3d::Vector3d new $vx $vy $vz]
    }

    method * {type} {
        # Multiplies a vector by a scalar if $type is a scale
        # or Compute the Dot product if $type is an object.
        #
        # type - Options described below.
        #
        # scalar - A scalar component.
        # object - A object component.
        #
        # Returns A new scaled vector [Vector3d] if scalar or A scalar result if object.
        if {[tomato::helper::IsaObject $type]} {
            return [my DotProduct $other]
        } else {

            set vx [expr {$_x * $type}]
            set vy [expr {$_y * $type}]
            set vz [expr {$_z * $type}]

            return [tomato::mathvec3d::Vector3d new $vx $vy $vz]

        }
    }

    method / {scale} {
        # Divides a vector by a scalar.
        #
        # scale - A scalar
        #
        # Returns A new scaled vector [Vector3d].
        if {$scale == 0} {
            error "Divide [tomato::helper::TypeClass [self]] by zero..."
        }

        set vx [expr {$_x / $scale}]
        set vy [expr {$_y / $scale}]
        set vz [expr {$_z / $scale}]

        return [tomato::mathvec3d::Vector3d new $vx $vy $vz]
    }

    method == {other {tolerance $::tomato::helper::TolEquals}} {
        # Gets value that indicates whether each pair of elements in two specified vectors is equal.
        #
        # other     - The second vector [Vector3d] to compare.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the vectors are the same. Otherwise false.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolEquals
        }

        return [expr {[tomato::mathvec3d::Equals [self] $other $tolerance]}]
        
    }

    method != {other {tolerance $::tomato::helper::TolEquals}} {
        # Gets value that indicates whether any pair of elements in two specified vectors is not equal.
        #
        # other - The second vector [Vector3d] to compare.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the vectors are different. Otherwise false.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolEquals
        }

        return [expr {![tomato::mathvec3d::Equals [self] $other $tolerance]}]
        
    }

    method SignedAngleTo {v about} {
        # Gets signed angle.
        #
        # v     - The vector [Vector3d] to calculate the signed angle to
        # about - The vector [Vector3d] around which to rotate to get the correct sign
        #
        # Returns A signed Angle (In radian).
        if {[my IsParallelTo $about]} {
            error "Self parallel to aboutVector"
        }

        if {[$v IsParallelTo $about]} {
            error "FromVector parallel to aboutVector"
        }

        set rp  [tomato::mathplane::Plane new [tomato::mathpt3d::Point3d new 0 0 0] $about]
        set pfv [[my ProjectOn $rp] Direction]
        set ptv [[$v ProjectOn $rp] Direction]
        set dp  [$pfv DotProduct $ptv]
        
        if {abs($dp - 1.0) < 1e-15} {return 0}
        if {abs($dp + 1.0) < 1e-15} {return [expr {Pi()}]}

        set angle       [expr {acos($dp)}]
        set cpv         [$pfv CrossProduct $ptv]
        $cpv Normalize
        set sign        [$cpv DotProduct [$rp Normal]]
        set signedAngle [expr {$sign * $angle}]

        return $signedAngle

    }

    method AngleTo {v} {
        # Compute the angle between this vector and another using the arccosine of the dot product.
        #
        # v - The other vector [Vector3d]
        #
        # Returns The angle in radian between the vectors, with a range between 0° and 180°
        set uv1 [my Normalized]
        set uv2 [$v Normalized]

        # Formatting value to avoid error : 'argument not in valid range'
        # ex with this value : 1.0000000000000002
        set t     [regexp -inline {[0-9]+$} $::tomato::helper::TolGeom]
        set dp    [format "%.${t}f" [$uv1 DotProduct $uv2]] 
        set angle [expr {acos($dp)}]

        return $angle
    }

    method ScaleBy {scaleFactor} {
        # Multiplies the current vector by a scalar
        #
        # scaleFactor - a scalar
        #
        # Returns a new scaled vector [Vector3d]
        return [my * $scaleFactor]

    }

    method GetUnitTensorProduct {} {
        # A matrix with the unit tensor product<br>
        # \[ux^2,  ux*uy, ux*uz]<br>
        # \[ux*uy, uy^2,  uy*uz]<br>
        # \[ux*uz, uy*uz, uz^2]
        #
        # Returns a matrix [mathmatrix::Matrix]

        set xy [expr {$_x * $_y}]
        set xz [expr {$_x * $_z}]
        set yz [expr {$_y * $_z}]

        set mat [tomato::mathmatrix::Matrix new 3 3]

        $mat SetCell 0 0 [expr {$_x * $_x}]
        $mat SetCell 1 0 $xy
        $mat SetCell 2 0 $xz
        $mat SetCell 0 1 $xy
        $mat SetCell 1 1 [expr {$_y * $_y}]
        $mat SetCell 2 1 $yz
        $mat SetCell 0 2 $xz
        $mat SetCell 1 2 $yz
        $mat SetCell 2 2 [expr {$_z * $_z}]

        return $mat

    }

    method CrossProductMatrix {} {
        # A matrix containing the cross product of this vector
        #
        # Returns a matrix [mathmatrix::Matrix]
        set mat [tomato::mathmatrix::Matrix new 3 3]

        $mat SetCell 0 0 0.0
        $mat SetCell 1 0 $_z
        $mat SetCell 2 0 [expr {Inv($_y)}]
        $mat SetCell 0 1 [expr {Inv($_z)}]
        $mat SetCell 1 1 0.0
        $mat SetCell 2 1 $_x
        $mat SetCell 0 2 $_y
        $mat SetCell 1 2 [expr {Inv($_x)}]
        $mat SetCell 2 2 0.0
       
       return $mat

    }

    method Negate {} {
        # Inverses the direction of the vector
        #
        # Returns a new vector [Vector3d] pointing in the opposite direction
        return [tomato::mathvec3d::Vector3d new [expr {Inv($_x)}] [expr {Inv($_y)}] [expr {Inv($_z)}]]
    }

    method ToPoint3D {} {
        # A point equivalent to the vector
        #
        # Returns a new Point3d [mathpt3d::Point3d]
        return [tomato::mathpt3d::Point3d new $_x $_y $_z]
    }

    method ProjectOn {entity} {
        # Projects the vector onto a plane if '$entity' is a plane
        # The Dot product of the current vector and a unit vector if '$entity' is a vector.
        #
        # entity - Options described below.
        #
        # Vector3d - [Vector3d]
        # Plane    - [mathplane::Plane]
        #
        # Returns a new vector [Vector3d] if '$entity' is a vector or a new Ray if '$entity' is a Plane.
        switch -glob [$entity GetType] {
            *Vector3d {
                set pd [my DotProduct [$entity Normalized]]
                return [$entity * $pd]
            }
            *Plane {
                return [$entity Project [self]]
            }
            default {
                error "Entity must be Vector3d or Plane..."
            }
        }

    }

    method TransformBy {entity} {
        # Transforms the vector by a coordinate system 
        #
        # entity - Options described below.
        #
        # Matrix           - [mathmatrix::Matrix]
        # coordinatesystem - [mathcsys::Csys]
        #
        # Returns a new transformed vector [Vector3d]
        switch -glob [$entity GetType] {
            *Csys {
                return [$entity Transform [self]]
            }
            *Matrix {
                lassign [$entity Multiply [self]] x y z
                return [tomato::mathvec3d::Vector3d new $x $y $z]
            }
            default {
                error "Entity must be Matrix or Csys..."
            }
        }
    }

    method Rotate {aboutVector angle} {
        # Gets a vector that is this vector rotated the signed angle around the about vector.
        #
        # aboutVector - A vector [Vector3d] to rotate about
        # angle - An angle in degree
        #
        # Returns a rotated vector [Vector3d].
        set cs [tomato::mathcsys::RotationAngleVector $angle [$aboutVector Normalized]]
        return [$cs Transform [self]]

    }    

    method GetType {} {
        # Gets the name of class.
        return [tomato::helper::TypeClass [self]]
    }

    method ToString {} {
        # Returns a string representation of this object.
        return [format {%s, %s, %s} $_x $_y $_z]
    }

    # export Private method to public method...
    export X Y Z Length Cget ToString Normalized Normalize Get IsNormalized ProjectOn SignedAngleTo
    export IsPerpendicularTo IsParallelTo ToPoint3D DotProduct CrossProduct LengthSquared Orthogonal
    export GetUnitTensorProduct CrossProductMatrix GetType TransformBy AngleTo ScaleBy Rotate Negate
    export + - * / == != Configure

}

proc tomato::mathvec3d::UnitX {} {
    # A unit length Vector X-axis
    #
    # Returns a unit length vector [Vector3d] that points towards the X-axis
    return [tomato::mathvec3d::Vector3d new 1.0 0.0 0.0]
}

proc tomato::mathvec3d::UnitY {} {
    # A unit length Vector Y-axis
    #
    # Returns a unit length vector [Vector3d] that points towards the Y-axis
    return [tomato::mathvec3d::Vector3d new 0.0 1.0 0.0]
}

proc tomato::mathvec3d::UnitZ {} {
    # A unit length Vector Z-axis
    #
    # Returns a unit length vector [Vector3d] that points towards the Z-axis
    return [tomato::mathvec3d::Vector3d new 0.0 0.0 1.0]
}

proc tomato::mathvec3d::ComponentMin {v1 v2} {
    # A vector created from the smallest of the corresponding components of the given vectors.
    #
    # v1 - [Vector3d]
    # v2 - [Vector3d]
    #
    # Returns a new vector [Vector3d] component-wise minimum.
    set vx [expr {[$v1 X] < [$v2 X] ? [$v1 X] : [$v2 X]}]
    set vy [expr {[$v1 Y] < [$v2 Y] ? [$v1 Y] : [$v2 Y]}]
    set vz [expr {[$v1 Z] < [$v2 Z] ? [$v1 Z] : [$v2 Z]}]

    return [tomato::mathvec3d::Vector3d new $vx $vy $vz]
}
proc tomato::mathvec3d::ComponentMax {v1 v2} {
    # A vector created from the largest of the corresponding components of the given vectors.
    #
    # v1 - [Vector3d]
    # v2 - [Vector3d]
    #
    # Returns a new vector [Vector3d] component-wise maximum.
    set vx [expr {[$v1 X] > [$v2 X] ? [$v1 X] : [$v2 X]}]
    set vy [expr {[$v1 Y] > [$v2 Y] ? [$v1 Y] : [$v2 Y]}]
    set vz [expr {[$v1 Z] > [$v2 Z] ? [$v1 Z] : [$v2 Z]}]

    return [tomato::mathvec3d::Vector3d new $vx $vy $vz]
}
proc tomato::mathvec3d::MagnitudeMax {left right} {
    # A vector with the maximum magnitude.
    #
    # left  - [Vector3d]
    # right - [Vector3d]
    #
    # Returns Vector [Vector3d] magnitude-wise maximum.
    return [expr {[$left Length] >= [$right Length] ? $left : $right}]    
}
proc tomato::mathvec3d::MagnitudeMin {left right} {
    # A vector with the minimum magnitude
    #
    # left  - [Vector3d]
    # right - [Vector3d]
    #
    # Returns Vector [Vector3d] magnitude-wise minimum.
    return [expr {[$left Length] < [$right Length] ? $left : $right}]    
}
proc tomato::mathvec3d::Clamp {vec min max} {
    # Clamp a vector to the given minimum and maximum vectors.
    #
    # vec - Input vector   [Vector3d]
    # min - Minimum vector [Vector3d]
    # max - Maximum vector [Vector3d]
    #
    # Returns a new clamped vector [Vector3d].
    set vx [expr {[$vec X] < [$min X] ? [$min X] : [$vec X] > [$max X] ? [$max X] : [$vec X]}]
    set vy [expr {[$vec Y] < [$min Y] ? [$min Y] : [$vec Y] > [$max Y] ? [$max Y] : [$vec Y]}]
    set vz [expr {[$vec Z] < [$min Z] ? [$min Z] : [$vec Z] > [$max Z] ? [$max Z] : [$vec Z]}]

    return [tomato::mathvec3d::Vector3d new $vx $vy $vz]
}

proc tomato::mathvec3d::Lerp {v1 v2 blend} {
    # Lerp a new Vector that is the linear blend of the 2 given Vectors.
    #
    # v1 - [Vector3d]
    # v2 - [Vector3d]
    # blend - The blend factor. v1 when blend=0, v2 when blend=1
    #
    # Returns v1 when blend=0, v2 when blend=1, and a linear combination otherwise..
    set vx [expr {$blend * ([$v2 X] - [$v1 X]) + [$v1 X]}]
    set vy [expr {$blend * ([$v2 Y] - [$v1 Y]) + [$v1 Y]}]
    set vz [expr {$blend * ([$v2 Z] - [$v1 Z]) + [$v1 Z]}]

    return [tomato::mathvec3d::Vector3d new $vx $vy $vz]
}

proc tomato::mathvec3d::Dot {v1 v2} {
    # Compute the dot product of 2 vectors
    #
    # v1 - [Vector3d]
    # v2 - [Vector3d]
    #
    # See : method DotProduct
    return [expr {([$v1 X] * [$v2 X]) + ([$v1 Y] * [$v2 Y]) + ([$v1 Z] * [$v2 Z])}]  
}

proc tomato::mathvec3d::Cross {v1 v2} {
    # Compute the cross product of 2 vectors
    #
    # v1 - [Vector3d]
    # v2 - [Vector3d]
    #
    # See : method CrossProduct
    set vx [expr {([$v1 Y] * [$v2 Z]) - ([$v1 Z] * [$v2 Y])}]
    set vy [expr {([$v1 Z] * [$v2 X]) - ([$v1 X] * [$v2 Z])}]
    set vz [expr {([$v1 X] * [$v2 Y]) - ([$v1 Y] * [$v2 X])}]

    return [tomato::mathvec3d::Vector3d new $vx $vy $vz]
}

proc tomato::mathvec3d::Equals {vector other tolerance} {
    # Indicate if this vector is equivalent to a given unit vector
    #
    # vector - First input vector [Vector3d]
    # other - Second input vector [Vector3d]
    # tolerance - A tolerance (epsilon) to adjust for floating point error
    #
    # Returns true if the vectors are equal, otherwise false.
    #
    # See : methods == !=
    if {$tolerance < 0} {
        #ruff
        # An error exception is raised if tolerance (epsilon) < 0.
        error "epsilon < 0"
    }

    return [expr {
                  (abs([$other X] - [$vector X]) < $tolerance) && 
                  (abs([$other Y] - [$vector Y]) < $tolerance) && 
                  (abs([$other Z] - [$vector Z]) < $tolerance)
                }]
}