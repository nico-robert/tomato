# Copyright (c) 2021-2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval tomato::helper {
    # Ruff documentation
    variable _ruff_preamble "Helper tomato::math..."

    # export
    namespace export TypeOf

    # The number of binary digits used to represent the binary number for a double precision floating
    # point value. i.e. there are this many digits used to represent the
    # actual number, where in a number as: 0.134556 * 10^5 the digits are 0.134556 and the exponent is 5.
    variable DoubleWidth 53

    # default tolerances values
    variable TolEquals 1e-8
    variable TolGeom   1e-12

}

namespace eval tcl::mathfunc {
    # Pi value
    proc Pi {} {
        return [expr {acos(-1)}]
    }
    # Opposite value
    proc Inv x {
        return [expr {$x * -1}]
    }
}

proc tomato::helper::Pi {} {
    # Defines the value of Pi
    #
    # ***Obsolete*** use `[expr {Pi()}]` instead.
    return [expr {acos(-1)}]
}

proc tomato::helper::Clamp {n min max} {
    # Clamps a number between a minimum and a maximum.
    #
    # n   - The number to clamp.
    # min - The minimum allowed value.
    # max - The maximum allowed value.
    #
    # Returns min, if n is lower than min; max, if n is higher than max; n otherwise.

    return [expr {max(min($n, $max), $min)}]
}

proc tomato::helper::DegreesToRadians {degrees} {
    # Convert degrees to radians.
    #
    # degrees - An angle in degrees.
    #
    # Returns The angle expressed in radians.

    set degToRad [expr {Pi() / 180.0}]
    return [expr {$degrees * $degToRad}]
}

proc tomato::helper::RadiansToDegrees {radians} {
    # Convert radians to degrees.
    #
    # radians - An angle in radians.
    #
    # Returns The angle expressed in degrees.

    set radToDeg [expr {180.0 / Pi()}]
    return [expr {$radians * $radToDeg}]
}

proc tomato::helper::TypeOf {obj Isa myclass} {
    # Match type of class
    #
    # obj  - Instance.
    # Isa  - name (arg Not Used...)
    # myclass - The name of class.
    #
    # Returns True or False.

    if {![tomato::helper::IsaObject $obj]} {
       return 0 
    }

    return [string match -nocase *$myclass [info object class $obj]]
}

proc tomato::helper::TypeClass {obj} {
    # Name of class
    #
    # obj  - Instance.
    #
    # Returns name of class or nothing.

    if {![tomato::helper::IsaObject $obj]} {
       return "" 
    }

    return [info object class $obj]
}

proc tomato::helper::IsaObject {obj} {
    # Check if variable $obj is an object
    #
    # obj  - Instance.
    #
    # Returns True or False.

    return [info object isa object $obj]
}

proc tomato::helper::DoublePrecision {} {
    # Standard epsilon, the maximum relative precision of IEEE 754 double-precision floating numbers (64 bit).
    # According to the definition of Prof. Demmel and used in LAPACK and Scilab.
    return [expr {pow(2, -$::tomato::helper::DoubleWidth)}]

}

proc tomato::helper::MachineEpsilon {} {
    # Actual double precision machine epsilon, the smallest number that can be subtracted from 1, yielding a results different than 1.
    # This is also known as unit roundoff error. According to the definition of Prof. Demmel.
    # On a standard machine this is equivalent to `DoublePrecision`.
    #
    # Return Positive Machine epsilon
    
    set eps 1.0

    while {(1.0 - ($eps / 2.0)) < 1.0} {
        set eps [expr {$eps / 2.0}]
    }

    return $eps
}

proc tomato::helper::L2Norm {x y z {exception False}} {
    # Check if the provided values are scaled to L2 norm
    #
    # x - The x component
    # y - The y component
    # z - The z component
    # exception - Throw an exception if result is false
    #
    # Returns True or false 
    set norm [expr {sqrt(($x**2) + ($y**2) + ($z**2))}]

    if {$norm < $::tomato::helper::Epsilon} {
        if {$exception} {
            throw {LessNormEuclideanNorm} "The Euclidean norm of x, y, z is less than tolerance Epsilon" 
        }
        return 0
    }

    if {abs($norm - 1.0) > $::tomato::helper::Epsilon} {
        if {$exception} {
            throw {MoreNormEuclideanNorm} "The Euclidean norm of x, y, z differs more than tolerance Epsilon from 1" 
        }
        return 0
    }

    return 1

}

namespace eval tomato::helper {

    variable PositiveInfinity [expr {1.0 / 0.0}]
    variable Epsilon          [MachineEpsilon]

}