# Copyright (c) 2021-2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval tomato::mathquat {
    # Ruff documentation
    variable _ruff_preamble "A Class representing a Quaternion"
}

oo::class create tomato::mathquat::Quaternion {

    variable _w ; # The rotation component of the Quaternion. (real part)
    variable _x ; # The X-value of the vector component of the Quaternion.
    variable _y ; # The Y-value of the vector component of the Quaternion.
    variable _z ; # The Z-value of the vector component of the Quaternion. (imaginary part)

    constructor {args} {
        # Initializes a new Quaternion Class.
        #
        # args - Options described below.
        #
        # list       - A list of 4 elements
        # vector     - A Vector3d Class [mathvec3d::Vector3d]
        # scalar     - A scalar value
        # values     - 3 values or 4 values
        # component1 - -scalar & -vector
        # component2 - -axis & -angle
        #

        if {[llength $args] == 1} {

            if {[llength {*}$args] == 4} {
                #ruff
                # * Create a quaternion by specifying a list of 4 real-numbered scalar elements.<br>
                # ```
                # tomato::mathquat::Quaternion new {1 2 3 4}
                # > (1 + 2i + 3j + 4k)
                # ```
                lassign {*}$args w x y z
                set _w $w
                set _x $x
                set _y $y
                set _z $z

            } elseif {[TypeOf $args Isa "Vector3d"]} {
                #ruff
                # * Create a quaternion by specifying a Vector3d Class.<br>
                # ```
                # tomato::mathquat::Quaternion new $vectorobj
                # > (0 + xi + yj + zk)
                # ```
                lassign [$args Get] x y z
                set _w 0
                set _x $x
                set _y $y
                set _z $z

            } elseif {[tomato::mathquat::_checkvalue $args]} {
                #ruff
                # * Create the quaternion representation of a scalar (single real number) value.<br>
                # ```
                # tomato::mathquat::Quaternion new "2"
                # The imaginary part of the resulting quaternion will always be 0i + 0j + 0k.
                # > (2 + 0i + 0j + 0k)
                # ```
                set _w $args
                set _x 0
                set _y 0
                set _z 0 

            } else {
                error "arg must be a Vector3d, one scalar value, or 4 values ..."
            }

        } elseif {[llength $args] == 3} {
            #ruff
            # * Create a quaternion by specifying 3 real-numbered scalar elements.<br>
            # ```
            # tomato::mathquat::Quaternion new 1 2 3
            # > (0 + 1i + 2j + 3k)
            # ```
            lassign $args x y z
            set _w 0
            set _x $x
            set _y $y
            set _z $z            
                
        } elseif {[llength $args] == 4} {

            if {[tomato::mathquat::_checkvalue $args]} {
                #ruff
                # * Create a quaternion by specifying 4 real-numbered scalar elements.<br>
                # ```
                # tomato::mathquat::Quaternion new 1 1 1 1
                # > (1 + 1i + 1j + 1k)
                # ```
                lassign $args w x y z
                set _w $w
                set _x $x
                set _y $y
                set _z $z
                
            } else {

                if {[string match "*-scalar*" $args] && ![string match "*-vector*" $args]} {
                    #ruff
                    # * Create a quaternion by specifying a scalar and a vector.<br>
                    # The scalar (real) and vector (imaginary) parts of the desired quaternion.
                    # -vector - Can be a Vector3d class [mathvec3d::Vector3d] or list of 3 values
                    # ```
                    # tomato::mathquat::Quaternion new -scalar 1 -vector {1 1 1}
                    # > (1 + 1i + 1j + 1k)
                    # ```
                    error "Key 'scalar' must be associated with 'vector'"
                }

                if {[string match "*-axis*" $args] && ![string match "*-angle*" $args]} {
                    #ruff
                    # * Create a quaternion by specifying a axis and a angle in degrees.<br>
                    # Specify the angle (degrees) for a rotation about an axis vector \[x, y, z] to be described by the quaternion object
                    # -axis - Can be a Vector3d class [mathvec3d::Vector3d] or list of 3 values
                    # ```
                    # tomato::mathquat::Quaternion new -axis {0 1 0} -angle 90
                    # > (0.707 +0i +0.707j +0k)
                    # ```
                    error "Key 'axis' must be associated with 'angle'"
                }

                set options [dict create]

                foreach {key value} $args {

                    if {$value eq ""} {
                        error "No value specified for key '$key'"
                    }

                    switch -exact -- $key {
                        "-scalar" {dict set options Scalar $value}
                        "-axis" -
                        "-vector" {
                                    if {[TypeOf $value Isa "Vector3d"]} {
                                        dict set options Vector $value
                                    } elseif {[string is list $value] && [llength $value] == 3} {
                                        dict set options Vector [tomato::mathvec3d::Vector3d new $value]
                                    } else {
                                        error "Value for Key '$key' must be an Class Vector3d or a list of 3 elements..."
                                    }
                                  }
                        "-angle" {dict set options Angle $value}
                        default  {error "Unknown key '$key' specified"}

                    }

                }

                if {[dict exists $options Vector] && [dict exists $options Angle]} {
                    lassign [tomato::mathquat::_init_from_vector_angle [dict get $options Vector] \
                                                                       [dict get $options Angle]] w x y z

                    set _w $w ; set _x $x ; set _y $y ; set _z $z

                } elseif {[dict exists $options Scalar] && [dict exists $options Vector]} {

                    lassign [[dict get $options Vector] Get] x y z

                    set _w [dict get $options Scalar] ; set _x $x ; set _y $y ; set _z $z
                }


            }

        } else {
            #ruff
            # * Default value :
            # ```
            # tomato::mathquat::Quaternion new
            # > (1 +0i +0j +0k)
            # ```
            set _w 1
            set _x 0
            set _y 0
            set _z 0
        }
    }
}

oo::define tomato::mathquat::Quaternion {

    method Real {} {
        # Gets the real part of the quaternion.
        return $_w
    }

    method ImagX {} {
        # Gets the imaginary X part (coefficient of complex I) of the quaternion.
        return $_x
    }

    method ImagY {} {
        # Gets the imaginary Y part (coefficient of complex J) of the quaternion.
        return $_y
    }

    method ImagZ {} {
        # Gets the imaginary Z part (coefficient of complex K) of the quaternion.
        return $_z
    }

    method Get {} {
        # Gets values from the Quaternion Class under TCL list form.
        return [list $_x $_y $_z $_w]
    }

    method NormSquared {} {
        # Gets the sum of the squares of the four components.
        return [tomato::mathquat::ToNormSquared $_w $_x $_y $_z]
    }

    method Norm {} {
        # Gets the norm of the quaternion q: square root of the sum of the squares of the four components.
        return [expr {sqrt([my NormSquared])}]
    }

    method Arg {} {
        # Gets the argument phi = arg(q) of the quaternion q, such that q = r*(cos(phi) + <br>
        # u*sin(phi)) = r*exp(phi*u) where r is the absolute and u the unit vector of <br>
        # q.
        return [expr {acos($_w / [my Norm])}]
    }

    method IsUnitQuaternion {} {
        # Gets a value indicating whether the quaternion q has length |q| = 1.
        # To normalize a quaternion to a length of 1, use the [Normalized] method.
        # All unit quaternions form a 3-sphere.
        return [expr {abs(1.0 - [my NormSquared]) < 1e-15}]
    }

    method Scalar {} {
        # Gets a new Quaternion q with the Scalar part only.
        return [tomato::mathquat::Quaternion new $_w 0 0 0]
    }

    method Vector {} {
        # Gets a new Quaternion q with the Vector part only.
        return [tomato::mathquat::Quaternion new 0 $_x $_y $_z]
    }

    method NormalizedVector {} {
        # Gets a new normalized Quaternion u with the Vector part only, such that ||u|| = 1.
        return [tomato::mathquat::ToUnitQuaternion 0 $_x $_y $_z]
    }

    method Normalized {} {
        # Gets a new normalized Quaternion q with the direction of this quaternion.
        return [expr {[[self] == $::tomato::mathquat::Zero] ? [self] : [tomato::mathquat::ToUnitQuaternion $_w $_x $_y $_z]}]
    }

    method Inversed {} {
        # Gets an inverted quaternion. Inversing Zero returns Zero
        if {[[self] == $::tomato::mathquat::Zero]} {
            return [self]
        }

        set normSquared [my NormSquared]
        return [tomato::mathquat::Quaternion new [expr {$_w      / double($normSquared)}] \
                                                 [expr {Inv($_x) / double($normSquared)}] \
                                                 [expr {Inv($_y) / double($normSquared)}] \
                                                 [expr {Inv($_z) / double($normSquared)}]]

    }

    method IsNan {} {
        # Gets a value indicating whether the quaternion is not a number
        foreach value [my Get] {
            if {$value eq "NaN"} {
                return 1
            }
        }
        return 0
    }

    method IsInfinity {} {
        # Gets a value indicating whether the quaternion is not a number
        foreach value [my Get] {
            if {$value eq "Inf"} {
                return 1
            }
        }
        return 0
    }

    method Negate {} {
        # Negate a quaternion.
        #
        # Returns A negated quaternion [Quaternion].
        return [tomato::mathquat::Quaternion new [expr {Inv($_w)}] \
                                                 [expr {Inv($_x)}] \
                                                 [expr {Inv($_y)}] \
                                                 [expr {Inv($_z)}]]
    }

    method + {entity} {
        # Add a floating point number to a quaternion, if $entity is double
        # or Add a quaternion to a quaternion, if $entity is an Quaternion object.
        #
        # entity - Options described below.
        #
        # scalar - A double value.
        # object - A Quaternion component.
        #
        # Returns A quaternion whose real value is increased by a scalar if $entity is double value or <br>
        # the sum of two quaternions [Quaternion] if $entity is a quaternion object.
        if {[string is double $entity]} {
            return [tomato::mathquat::Quaternion new [expr {$_w + $entity}] $_x $_y $_z]
        }

        if {[TypeOf $entity Isa "Quaternion"]} {
            return [tomato::mathquat::Quaternion new [expr {$_w + [$entity Real]}] \
                                                     [expr {$_x + [$entity ImagX]}] \
                                                     [expr {$_y + [$entity ImagY]}] \
                                                     [expr {$_z + [$entity ImagZ]}]]
        }

    }

    method - {entity} {
        # Subtract a floating point number from a quaternion, if $entity is double
        # or Subtract a quaternion from a quaternion, if $entity is an Quaternion object.
        #
        # entity - Options described below.
        #
        # scalar - A double value.
        # object - A Quaternion component.
        #
        # Returns A quaternion whose real value is discreased by a scalar if $entity is double value or <br>
        # the quaternion [Quaternion] difference if $entity is a quaternion object.
        if {[string is double $entity]} {
            return [tomato::mathquat::Quaternion new [expr {$_w - $entity}] $_x $_y $_z]
        }

        if {[TypeOf $entity Isa "Quaternion"]} {
            return [tomato::mathquat::Quaternion new [expr {$_w - [$entity Real]}] \
                                                     [expr {$_x - [$entity ImagX]}] \
                                                     [expr {$_y - [$entity ImagY]}] \
                                                     [expr {$_z - [$entity ImagZ]}]]
        }

    }

    method * {entity} {
        # Multiply a floating point number with a quaternion, if $entity is double
        # or Multiply a quaternion with a quaternion, if $entity is an Quaternion object.
        #
        # entity - Options described below.
        #
        # scalar - A double value.
        # object - A Quaternion component.
        #
        # Returns A new quaternion [Quaternion].
        if {[string is double $entity]} {
            return [tomato::mathquat::Quaternion new [expr {$_w * $entity}] \
                                                     [expr {$_x * $entity}] \
                                                     [expr {$_y * $entity}] \
                                                     [expr {$_z * $entity}]]
        }

        if {[TypeOf $entity Isa "Quaternion"]} {

            set ci [expr {($_x      * [$entity Real])  + ($_y * [$entity ImagZ]) - ($_z * [$entity ImagY]) + ($_w * [$entity ImagX])}]
            set cj [expr {(Inv($_x) * [$entity ImagZ]) + ($_y * [$entity Real])  + ($_z * [$entity ImagX]) + ($_w * [$entity ImagY])}]
            set ck [expr {($_x      * [$entity ImagY]) - ($_y * [$entity ImagX]) + ($_z * [$entity Real])  + ($_w * [$entity ImagZ])}]
            set cr [expr {(Inv($_x) * [$entity ImagX]) - ($_y * [$entity ImagY]) - ($_z * [$entity ImagZ]) + ($_w * [$entity Real])}]

            return [tomato::mathquat::Quaternion new $cr $ci $cj $ck]
        }

    }

    method / {entity} {
        # Divide a quaternion by a floating point number, if $entity is double
        # or Divide a quaternion by a quaternion, if $entity is an Quaternion object.
        #
        # entity - Options described below.
        #
        # scalar - A double value.
        # object - A Quaternion component.
        #
        # Returns A new divided quaternion [Quaternion].
        if {[string is double $entity]} {
            return [tomato::mathquat::Quaternion new [expr {$_w / double($entity)}] \
                                                     [expr {$_x / double($entity)}] \
                                                     [expr {$_y / double($entity)}] \
                                                     [expr {$_z / double($entity)}]]
        }

        if {[TypeOf $entity Isa "Quaternion"]} {

            if {[$entity == $::tomato::mathquat::Zero]} {
                if {[[self] == $::tomato::mathquat::Zero]} {
                    return [tomato::mathquat::Quaternion new "NaN" "NaN" "NaN" "NaN"]
                }

                return [tomato::mathquat::Quaternion new "Inf" "Inf" "Inf" "Inf"]
                
            }

            set normSquared [$entity NormSquared]
            set t0 [expr {(([$entity Real] * $_w) + ([$entity ImagX] * $_x) + ([$entity ImagY] * $_y) + ([$entity ImagZ] * $_z)) / double($normSquared)}]
            set t1 [expr {(([$entity Real] * $_x) - ([$entity ImagX] * $_w) - ([$entity ImagY] * $_z) + ([$entity ImagZ] * $_y)) / double($normSquared)}]
            set t2 [expr {(([$entity Real] * $_y) + ([$entity ImagX] * $_z) - ([$entity ImagY] * $_w) - ([$entity ImagZ] * $_x)) / double($normSquared)}]
            set t3 [expr {(([$entity Real] * $_z) - ([$entity ImagX] * $_y) + ([$entity ImagY] * $_x) - ([$entity ImagZ] * $_w)) / double($normSquared)}]

            return [tomato::mathquat::Quaternion new $t0 $t1 $t2 $t3]
        }

    }

    method ^ {entity} {
        # Raise a quaternion to a floating point number.
        #
        # entity - A double value.
        #
        # Returns A new quaternion [Quaternion].
        return [tomato::mathquat::Pow [self] $entity]
    }

    method == {entity {tolerance $::tomato::helper::TolEquals}} {
        # Equality operator for two quaternions if $entity is quaternion component.
        # Equality operator for quaternion and double if $entity is double.
        # 
        # entity - Options described below.
        #
        # scalar    - A double value.
        # object    - A Quaternion component.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the quaternions are the same if $entity is a quaternion or 
        # True if the real part of the quaternion is almost equal to the double and the rest of the quaternion is almost 0. Otherwise false.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolEquals
        }

        if {[string is double $entity]} {
            return [expr {
                            (($_w - $entity) < $tolerance) &&
                            (($_x - 0) < $tolerance) &&
                            (($_y - 0) < $tolerance) &&
                            (($_z - 0) < $tolerance)
                        }]
        }

        if {[TypeOf $entity Isa "Quaternion"]} {
            return [tomato::mathquat::Equals [self] $entity $tolerance]
        }

    }

    method != {entity {tolerance $::tomato::helper::TolEquals}} {
        # Inequality operator for two quaternions if $entity is quaternion component.
        # Inequality operator for quaternion and double if $entity is double.
        # 
        # entity - Options described below.
        #
        # scalar    - A double value.
        # object    - A Quaternion component.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the quaternions are not the same if $entity is a quaternion or 
        # True if the real part of the quaternion is not equal to the double and the rest of the quaternion is almost 0. Otherwise false.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolEquals
        }

        return [expr {![my == $entity $tolerance]}]
    }

    method Distance {q} {
        # Gets the distance |a-b| of two quaternions, forming a metric space.
        #
        # q - A Quaternion component.
        #
        # Returns The distance between two quaternions.
        return [[my - $q] Norm]
    }    

    method RotateRotationQuaternion {rotation} {
        # Rotates the provided rotation quaternion with this quaternion.
        #
        # rotation - The rotation quaternion to rotate.
        #
        # Returns A rotated quaternion [Quaternion].
        if {![$rotation IsUnitQuaternion]} {
            error "The quaternion provided is not a rotation"
        }

        return [$rotation * [self]]
    }

    method RotateUnitQuaternion {unitQuaternion} {
        # Rotates the provided unit quaternion with this quaternion.
        #
        # unitQuaternion - The rotation quaternion to rotate.
        #
        # Returns A rotated quaternion [Quaternion].
        if {![my IsUnitQuaternion]} {
            error "You cannot rotate with this quaternion as it is not a Unit Quaternion"
        }

        # if {![$unitQuaternion IsUnitQuaternion]} {
        #     error "The quaternion provided is not a Unit Quaternion"
        # }

        return [[my * $unitQuaternion] * [my Conjugate]]

    }

    method Rotate {entity} {
        # Rotate a 3D vector or 3D point by the rotation stored in the Quaternion object
        #
        # entity - Options described below.
        #
        # point  - A point object.
        # vector - A vector object.
        #
        # Returns The rotated vector or point returned as the same type it was specified at input
        set myentity $entity

        if {[TypeOf $entity Isa "Vector3d"]} {

            if {![$entity IsNormalized]} {
                set myentity [$entity Normalized]
            }
            
        } elseif {[TypeOf $entity Isa "Point3d"]} {

            set myentity [$entity ToVector3D] ; # convert to vector
            
        } else {
            error "Entity must be an Class Vector3d Or an Class Point3d..."
        }

        set quat [tomato::mathquat::Quaternion new $myentity]
        set q    [self]

        if {![$q IsUnitQuaternion]} {
            set q [my Normalized]
        }

        set result [$q RotateUnitQuaternion $quat]

        if {[TypeOf $entity Isa "Vector3d"]} {
            return [$result ToVector3D]
        } else {
            return [[$result ToVector3D] ToPoint3D]
        }
    }

    method ToVector3D {} {
        # Gets the Vector part only.
        #
        # Returns A new vector3d [mathvec3d::Vector3d]
        return [tomato::mathvec3d::Vector3d new $_x $_y $_z]
    }

    method Conjugate {} {
        # Conjugate this quaternion.
        #
        # Returns A new conjugated quaternion [Quaternion]
        return [tomato::mathquat::Quaternion new $_w \
                                                 [expr {Inv($_x)}] \
                                                 [expr {Inv($_y)}] \
                                                 [expr {Inv($_z)}]]

    }

    method Log {{lbase ""}} {
        # Logarithm to a given base.
        #
        # lbase - A base
        #
        # Returns A new quaternion [Quaternion]
        if {[llength [info level 0]] < 3} {

            if {[my == $::tomato::mathquat::One]} {return $::tomato::mathquat::One}

            set quat [[my NormalizedVector] * [my Arg]]
            return [tomato::mathquat::Quaternion new [expr {log([my Norm])}] [$quat ImagX] [$quat ImagY] [$quat ImagZ]]

        } else {
            return [[my Log] / [expr {log($lbase)}]]
        }

    }

    method Log10 {} {
        # Common Logarithm to base 10.
        #
        # Returns A new quaternion
        return [[my Log] / [expr {log(10)}]]
    }

    method Exp {} {
        # Exponential Function.
        #
        # Returns A new quaternion [Quaternion]
        set mathE 2.7182818284590451 ; # https://docs.microsoft.com/en-us/dotnet/api/system.math.e?view=net-5.0

        set real       [expr {pow($mathE, $_w)}]
        set vector     [my Vector]
        set vectorNorm [$vector Norm]
        set cos [expr {cos($vectorNorm)}]
        set sgn [expr {[$vector == $::tomato::mathquat::Zero] ? $::tomato::mathquat::Zero : [$vector / $vectorNorm]}]
        set sin [expr {sin($vectorNorm)}]

        return [[[$sgn * $sin] + $cos] * $real]

    }

    method Sqrt {} {
        # Square root of the Quaternion: q^(1/2).
        #
        # Returns A new quaternion [Quaternion]
        set arg [expr {[my Arg] * 0.5}]

        return [[my NormalizedVector] * [expr {sin($arg) + cos($arg) + sqrt($_w)}]]

    }

    method Angle {} {
        # Gets the angle (in radians) describing the magnitude of the quaternion rotation about it's rotation axis.
        #
        # Returns A real number in the range (-pi:pi) describing the angle of rotation
        # in radians about a Quaternion object's axis of rotation
        set q [self]

        if {![$q IsUnitQuaternion]} {
            set q [$q Normalized]
        }

        set norm [[$q ToVector3D] Length]

        return [tomato::mathquat::_wrap_angle [expr {2.0 * atan2($norm, [my Real])}]]
    }

 
    method GetType {} {
        # Gets the name of class.
        return [tomato::helper::TypeClass [self]]
    }

    method ToString {} {
        # Returns a string representation of this object.

        set formatimgx [expr {($_x < 0 ) ? "%si" : "+%si"}]
        set formatimgy [expr {($_y < 0 ) ? "%sj" : "+%sj"}]
        set formatimgz [expr {($_z < 0 ) ? "%sk" : "+%sk"}]


        return [format [list %s $formatimgx $formatimgy $formatimgz] $_w $_x $_y $_z]
    }

    # export Private method to public method...
    export Real ImagX ImagY ImagZ Get NormSquared Norm Arg
    export IsUnitQuaternion Scalar Vector NormalizedVector
    export Normalized Inversed IsNan IsInfinity Negate
    export + - * / ^ != == Distance RotateRotationQuaternion
    export Rotate RotateUnitQuaternion ToVector3D Angle Conjugate Log Log10 Exp Sqrt
    export GetType ToString
}


proc tomato::mathquat::Dot {q0 q1} {
    # Dot Product between 2 quaternions
    #
    # q0 - First quaternion component
    # q1 - Second quaternion component
    #
    # Returns the dot product.
    return [expr {
                    ([$q0 ImagX] * [$q1 ImagX]) +
                    ([$q0 ImagY] * [$q1 ImagY]) +
                    ([$q0 ImagZ] * [$q1 ImagZ]) +
                    ([$q0 Real]  * [$q1 Real])
                 }]
}

proc tomato::mathquat::Pow {q power} {
    # Raise the quaternion to a given power.
    #
    # q     - A quaternion component.
    # power - A double, integer or quaternion value.
    #
    # Returns The quaternion [Quaternion] raised to a power of another quaternion
    if {[string is double -strict $power]} {

        if {[$q == $::tomato::mathquat::Zero]} {return $::tomato::mathquat::Zero}
        if {[$q == $::tomato::mathquat::One]} {return $::tomato::mathquat::One}

        return [[[$q Log] * $power] Exp]
    }

    if {[string is integer -strict $power]} {

        if {$power == 0} {return $::tomato::mathquat::One}
        if {$power == 1} {return $q}
        if {[$q == $::tomato::mathquat::Zero] || [$q == $::tomato::mathquat::One]} {return $q}

        set quat [tomato::mathquat::Quaternion new [$q Real] [$q ImagX] [$q ImagY] [$q ImagZ]]

        return [$quat * [tomato::mathquat::Pow $quat [expr {$power - 1}]]]

    }

    if {[TypeOf $power Isa "Quaternion"]} {

        if {[$q == $::tomato::mathquat::Zero]} {return $::tomato::mathquat::Zero}
        if {[$q == $::tomato::mathquat::One]} {return $::tomato::mathquat::One}     

        return [[$power * [$q Log]] Exp]
        
    }
}

proc tomato::mathquat::ToNormSquared {real imagX imagY imagZ} {
    # Calculates norm of quaternion from it's algebraical notation
    #
    # real  - The rotation component of the Quaternion.
    # imagX - The X-value of the vector component of the Quaternion.
    # imagY - The Y-value of the vector component of the Quaternion.
    # imagZ - The Z-value of the vector component of the Quaternion.
    #
    # Returns A norm squared quaternion
    return [expr {($imagX**2) + ($imagY**2) + ($imagZ**2) + ($real**2)}]

}

proc tomato::mathquat::ToUnitQuaternion {real imagX imagY imagZ} {
    # Creates unit quaternion (it's norm == 1) from it's algebraical notation
    #
    # real  - The rotation component of the Quaternion.
    # imagX - The X-value of the vector component of the Quaternion.
    # imagY - The Y-value of the vector component of the Quaternion.
    # imagZ - The Z-value of the vector component of the Quaternion.
    #
    # Returns A unit quaternion [Quaternion]
    set norm [expr {sqrt([tomato::mathquat::ToNormSquared $real $imagX $imagY $imagZ])}]

    return [tomato::mathquat::Quaternion new [list [expr {$real  / double($norm)}] \
                                                   [expr {$imagX / double($norm)}] \
                                                   [expr {$imagY / double($norm)}] \
                                                   [expr {$imagZ / double($norm)}]]]

}

proc tomato::mathquat::Slerp {q0 q1 {arcposition 0.5}} {
    # Spherical Linear Interpolation between quaternions.
    # Implemented as described in [wiki/Slerp](https://en.wikipedia.org/wiki/Slerp)
    #
    # q0          - First endpoint rotation as a Quaternion object.
    # q1          - Second endpoint rotation as a Quaternion object.
    # arcposition - interpolation parameter between 0 and 1. This describes the linear placement position of <br>
    #               the result along the arc between endpoints; 0 being at `q0` and 1 being at `q1`.
    #
    # Returns A new Quaternion object representing the interpolated rotation

    # Ensure quaternion inputs are unit quaternions and 0 <= amount <=1
    if {![$q0 IsUnitQuaternion]} {
        set q0 [$q0 Normalized]
    }

    if {![$q1 IsUnitQuaternion]} {
        set q1 [$q1 Normalized]
    }

    set clamparcpos [tomato::helper::Clamp $arcposition 0 1]

    set dot [tomato::mathquat::Dot $q0 $q1]

    # If the dot product is negative, slerp won't take the shorter path.
    # Note that v1 and -v1 are equivalent when the negation is applied to all four components.
    # Fix by reversing one quaternion
    if {$dot < 0.0} {
        set q0  [$q0 Negate]
        set dot [expr {Inv($dot)}]
    }

    # sinalpha0 can not be zero
    if {$dot > 0.9995} {
        set q [$q0 + [[$q1 - $q0] * $clamparcpos]]
        if {![$q IsUnitQuaternion]} {
            set q [$q Normalized]
        }
        return $q
    }

    set alpha0    [expr {acos($dot)}] ; # # Since dot is in range [0, 0.9995], acos() is safe
    set sinalpha0 [expr {sin($alpha0)}]

    set alpha [expr {$alpha0 * $clamparcpos}]
    set sinalpha [expr {sin($alpha)}]

    set s0 [expr {cos($alpha) - (($dot * $sinalpha) / double($sinalpha0))}]
    set s1 [expr {$sinalpha / double($sinalpha0)}]

    set q [[$q0 * $s0] + [$q1 * $s1]]

    if {![$q IsUnitQuaternion]} {
        set q [$q Normalized]
    }

    return $q
}

proc tomato::mathquat::Equals {quaternion other tolerance} {
    # Indicate if this quaternion is equivalent to a given quaternion
    #
    # quaternion - First input vector  [Quaternion]
    # other      - Second input vector [Quaternion]
    # tolerance  - A tolerance (epsilon) to adjust for floating point error
    #
    # Returns true if the quaternions are equal, otherwise false.
    #
    # See : methods == !=

    if {([$other IsNan] && [$quaternion IsNan]) || ([$other IsInfinity] && [$quaternion IsInfinity])} {
        return 1
    }

    if {$tolerance < 0} {
        #ruff
        # An error exception is raised if tolerance (epsilon) < 0.
        error "epsilon < 0"
    }

    return [expr {
                  abs([$quaternion Real]  - [$other Real])  < $tolerance && 
                  abs([$quaternion ImagX] - [$other ImagX]) < $tolerance && 
                  abs([$quaternion ImagY] - [$other ImagY]) < $tolerance && 
                  abs([$quaternion ImagZ] - [$other ImagZ]) < $tolerance
                }]
}

proc tomato::mathquat::_checkvalue {values} {
    # Check if value is double
    foreach val $values {
        if {![string is double $val]} {
            return 0
        }
    }

    return 1

}

proc tomato::mathquat::_init_from_vector_angle {vector angle} {
    # transform vector + angle
    # return list
    set v [$vector Normalized]
    set angleRadian [tomato::helper::DegreesToRadians $angle]

    set alpha [expr {$angleRadian / 2.0}]
    set r     [expr {cos($alpha)}]
    lassign   [[$v * [expr {sin($alpha)}]] Get] xv yv zv

    return [list $r $xv $yv $zv]

}

proc tomato::mathquat::_wrap_angle {alpha} {

    set result [expr {fmod(($alpha + Pi()), (2 * Pi())) - Pi()}]

    if {$result == Inv(Pi())} {
        set result [expr {Pi()}]
    }

    return $result
    
}

proc tomato::mathquat::_intermediates {q0 q1 n {include_endpoints 0}} {


    set step_size [expr {1.0 / ($n + 1)}]

    set steps {}

    if {$include_endpoints} {
        for {set i 0} {$i < [expr {$n + 2}]} {incr i} {
            lappend steps [expr {$step_size * $i}]
        }
    } else {
        for {set i 1} {$i < [expr {$n + 1}]} {incr i} {
            lappend steps [expr {$step_size * $i}]
        }   
    }

    set listslerp {}

    foreach step $steps {
        lappend listslerp [tomato::mathquat::Slerp $q0 $q1 $step]
    }

    return $listslerp

}


namespace eval tomato::mathquat {

    variable Zero [tomato::mathquat::Quaternion new 0 0 0 0]
    variable One  [tomato::mathquat::Quaternion new 1 0 0 0]

}