# Copyright (c) 2021 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE.md for details.

namespace eval tomato::helper {
    # Ruff documentation
    variable _ruff_preamble "Helper tomato::math..."

    # export
    namespace export TypeOf

    # The number of binary digits used to represent the binary number for a double precision floating
    # point value. i.e. there are this many digits used to represent the
    # actual number, where in a number as: 0.134556 * 10^5 the digits are 0.134556 and the exponent is 5.
    variable DoubleWidth 53

}

proc tomato::helper::Pi {} {
    # Defines the value of Pi
    return [expr {acos(-1)}]
}

proc tomato::helper::DegreesToRadians {degrees} {
    # Convert degrees to radians.
    #
    # degrees - An angle in degrees.
    #
    # Returns The angle expressed in radians.

    set degToRad [expr {[tomato::helper::Pi] / 180.0}]
    return [expr {$degrees * $degToRad}]
}

proc tomato::helper::RadiansToDegrees {radians} {
    # Convert radians to degrees.
    #
    # radians - An angle in radians.
    #
    # Returns The angle expressed in degrees.

    set radToDeg [expr {180.0 / [tomato::helper::Pi]}]
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

namespace eval tomato::helper {

    variable PositiveInfinity [expr {1.0 / 0.0}]
    variable Epsilon          [MachineEpsilon]

}