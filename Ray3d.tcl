# Copyright (c) 2021-2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval tomato::mathray3d {
    # Ruff documentation
    variable _ruff_preamble "A Class representing a Ray in 3D space"
}

oo::class create tomato::mathray3d::Ray3d {

    variable _throughpoint ; # The start point of the ray
    variable _direction ; # The direction of the ray

    constructor {point direction} {
        # Initializes a new Ray3d Class.
        #
        # point     - [mathpt3d::Point3d]
        # direction - [mathvec3d::Vector3d].
        #

        if {[TypeOf $point Isa "Point3d"]} {
            set _throughpoint $point
        } else {
            error "Must be 'Point3d' ClassType"
        }

        if {[TypeOf $direction Isa "Vector3d"]} {
            set _direction [$direction Normalized]
        } else {
            error "Must be 'Vector3d' ClassType"
        }

    }
}

oo::define tomato::mathray3d::Ray3d {

    method ThroughPoint {} {
        # Gets the start point [mathpt3d::Point3d] of the ray 
        return $_throughpoint
    }

    method Direction {} {
        # Gets the direction [mathvec3d::Vector3d] of the ray
        return $_direction
    }

    method Get {} {
        # Gets the start point and direction of the ray in the form of a TCL list
        return [list $_throughpoint $_direction]
    }

    method ShortestLineTo {point3d} {
        # the shortest line from a point to the ray
        #
        # point3d - A point [mathpt3d::Point3d]
        #
        # Returns a new line [mathline3d::Line3d] from the point to the closest point on the ray
        set v [[my ThroughPoint] VectorTo $point3d]
        set alongVector [$v ProjectOn [my Direction]]

        return [tomato::mathline3d::Line3d new [[my ThroughPoint] + $alongVector] $point3d]

    }

    method == {other {tolerance $::tomato::helper::TolEquals}} {
        # Gets value that indicates whether each pair of elements in two specified rays is equal.
        #
        # other     - The second ray [Ray3d] to compare.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the rays are the same. Otherwise false.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolEquals
        }

        return [expr {[tomato::mathray3d::Equals [self] $other $tolerance]}]
        
    }

    method != {other {tolerance $::tomato::helper::TolEquals}} {
        # Gets value that indicates whether any pair of elements in two specified rays is not equal.
        #
        # other - The second ray [Ray3d] to compare.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the rays are different. Otherwise false.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolEquals
        }

        return [expr {![tomato::mathray3d::Equals [self] $other $tolerance]}]
        
    }

    method IsCollinear {other {tolerance $::tomato::helper::TolGeom}} {
        # Returns a value to indicate if a pair of rays are collinear
        #
        # other - The ray to compare against [Ray3d]
        # tolerance - A tolerance (epsilon) for plane parallel verification.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolGeom
        }

        return [[my Direction] IsParallelTo [$other Direction] $tolerance]
    
    }

    method GetType {} {
        # Gets the name of class.
        return [tomato::helper::TypeClass [self]]
    }

    method ToString {} {
        # Returns a string representation of this object.
        lappend value "ThroughPoint = [$_throughpoint ToString]"
        lappend value "Direction    = [$_direction ToString]"
            
        return [join $value "\n"]
    }

    export ThroughPoint Direction Get ShortestLineTo ToString GetType
    export == !=
    export IsCollinear

}

proc tomato::mathray3d::IntersectionRayWithPlane {ray plane {tolerance $::tomato::helper::TolGeom}} {
    # Gets the intersection of ray and plane.
    #
    # ray       - [Ray3d]
    # plane     - [mathplane::Plane]
    # tolerance - A tolerance (epsilon) for ray parallel with plane verification.
    #
    # Returns a point [mathpt3d::Point3d] at the intersection with plane.
    if {[llength [info level 0]] < 4} {
        set tolerance $::tomato::helper::TolGeom
    }

    return [$plane IntersectionWith $ray $tolerance]

}

proc tomato::mathray3d::IntersectionPlaneWithPlane {plane1 plane2 {tolerance $::tomato::helper::TolGeom}} {
    # Gets the intersection of the two planes.
    #
    # plane1 - The first plane  [mathplane::Plane]
    # plane2 - The second plane [mathplane::Plane]
    # tolerance - A tolerance (epsilon) for plane parallel verification.
    #
    # Returns a ray [Ray3d] at the intersection of two planes.
    if {[llength [info level 0]] < 4} {
        set tolerance $::tomato::helper::TolGeom
    }

    return [$plane1 IntersectionWith $plane2 $tolerance]

}

proc tomato::mathray3d::Equals {ray other tolerance} {
    # Indicate if this ray is equivalent to a given ray
    #
    # ray - First input ray [Ray3d]
    # other - Second input ray [Ray3d]
    # tolerance - A tolerance (epsilon) to adjust for floating point error
    #
    # Returns true if the rays are equal, otherwise false.
    #
    # See : methods == !=
    if {$tolerance < 0} {
        #ruff
        # An error exception is raised if tolerance (epsilon) < 0.
        error "epsilon < 0"
    }

    return [expr {
                  [tomato::mathpt3d::Equals  [$ray ThroughPoint] [$other ThroughPoint] $tolerance] && 
                  [tomato::mathvec3d::Equals [$ray Direction] [$other Direction] $tolerance]
                }]
}