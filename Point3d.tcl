# Copyright (c) 2021 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE.md for details.

namespace eval tomato::mathpt3d {
    # Ruff documentation
    variable _ruff_preamble "A Class representing a Point in 3D space"
}

oo::class create tomato::mathpt3d::Point3d {

    variable _x ; # The x component.
    variable _y ; # The y component.
    variable _z ; # The z component.

    constructor {args} {
        # Initializes a new Point3d Class.
        #
        # args - Options described below.
        #
        # Class  - A Class [Point3d].
        # List   - A TCL list including 3 components values.
        # values - 3 components values.

        if {[llength $args] == 1} {
            # args Class Point3d
            if {[TypeOf $args Isa "Point3d"]} {

                set _x [$args X]
                set _y [$args Y]
                set _z [$args Z]

            } else {
                # args list > ex : Point3d new {1 2 3}
                if {[llength [split {*}$args]] == 3} {
                    lassign [split {*}$args] x y z
                    set _x $x
                    set _y $y
                    set _z $z
                } else {
                    #ruff
                    # An error exception is raised if length \[list] $args != 3.
                    error "Must be a list of 3 values... : $args"
                }
            }
        # args values > ex : Point3d new 1 2 3    
        } elseif {[llength $args] == 3} {
            lassign $args x y z
            set _x $x
            set _y $y
            set _z $z
        } else {
            # default values
            set _x 0
            set _y 0
            set _z 0
        }
    }
}

oo::define tomato::mathpt3d::Point3d {

    method X {} {
        # Gets The x component.
        return $_x
    }

    method Y {} {
        # Gets The y component.
        return $_y
    }

    method Z {} {
        # Gets The z component.
        return $_z
    }

    method Get {} {
        # Gets values from the Point3d Class under TCL list form.
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

    method Origin {} {
        # Getss a point at the origin
        return [tomato::mathpt3d::Point3d new 0.0 0.0 0.0]
    }

    method + {other} {
        # Adds a point and a vector together
        #
        # other - [mathvec3d::Vector3d]
        #
        # Returns a new point at the summed location
        set ptx [expr {[my X] + [$other X]}]
        set pty [expr {[my Y] + [$other Y]}]
        set ptz [expr {[my Z] + [$other Z]}]

        return [tomato::mathpt3d::Point3d new $ptx $pty $ptz]
    }

    method - {other} {
        # Subtracts a vector from a point or Subtracts the first point from the second point
        #
        # other  - A vector [mathvec3d::Vector3d] or a Point [Point3d]
        #
        # Returns a new point [Point3d] at the difference if Point3d, a vector [mathvec3d::Vector3d] pointing to the difference if Vector3d.
        set valuex [expr {[my X] - [$other X]}]
        set valuey [expr {[my Y] - [$other Y]}]
        set valuez [expr {[my Z] - [$other Z]}]

        if {[TypeOf $other Isa "Point3d"]} {
            return [tomato::mathvec3d::Vector3d new $valuex $valuey $valuez]
        } else {
            return [tomato::mathpt3d::Point3d new $valuex $valuey $valuez]
        }
    }

    method == {other {tolerance 1e-4}} {
        # Gets value that indicates whether each pair of elements in two specified points is equal.
        #
        # other     - The second point [Point3d] to compare.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the points are the same. Otherwise false.
        return [expr {[tomato::mathpt3d::Equals [self] $other $tolerance]}]
        
    }

    method != {other {tolerance 1e-4}} {
        # Gets value that indicates whether any pair of elements in two specified points is not equal.
        #
        # other - The second point [Point3d] to compare.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the points are different. Otherwise false.
        return [expr {![tomato::mathpt3d::Equals [self] $other $tolerance]}]
        
    }

    method VectorTo {p} {
        # Getss a vector from this point to another point
        #
        # p - The point [Point3d] to which the vector should go.
        #
        # Returns a vector [mathvec3d::Vector3d] pointing to the other point.
        return [$p - [self]]
    }

    method DistanceTo {p} {
        # Finds the straight line distance to another point
        #
        # p - [Point3d]
        #
        # Returns a distance measure
        set vector [my VectorTo $p]
        return [$vector Length]
    }

    method MirrorAbout {plane} {
        # Gets the mirror point of this point across a plane
        #
        # plane - [mathplane::Plane]
        #
        # Returns the mirrored point [Point3d]
        return [$plane MirrorAbout [self]]
    }

    method ProjectOn {plane} {
        # Projects a point onto a plane
        #
        # plane - [mathplane::Plane]
        #
        # Returns projected point [Point3d]
        return [$plane Project [self]]
    }

    method Rotate {aboutVector angle} {
        # Rotates the point about a given vector
        #
        # aboutVector - [mathvec3d::Vector3d]
        # angle - The angle to rotate in degrees
        #
        # Returns The rotated point [Point3d]
        set cs [tomato::mathcsys::RotationAngleVector $angle [$aboutVector Normalized]]
        return [$cs Transform [self]]

    }

    method TransformBy {cs} {
        # Applies a transform coordinate system to the point
        #
        # cs - A coordinate system [mathcsys::Csys]
        #
        # Returns A new 3d point [Point3d]
        return [$cs Transform [self]]
    }

    method ToVector3D {} {
        # Converts this point into a vector from the origin
        #
        # Returns A new vector [mathvec3d::Vector3d] equivalent to this point
        return [tomato::mathvec3d::Vector3d new $_x $_y $_z]
    }

    method GetType {} {
        # Gets the name of class.
        return [tomato::helper::TypeClass [self]]
    }

    method ToString {} {
        # Returns a string representation of this object.
        return [format {%s, %s, %s} $_x $_y $_z]
    }


    export Get Origine ToString GetType DistanceTo TransformBy
    export X Y Z
    export ToVector3D VectorTo MirrorAbout ProjectOn Rotate
    export + - == != Configure

}


proc tomato::mathpt3d::Average {listaxisPt} {
    # Gets the average value of list
    #
    # listaxisPt - list in the form of a TCL list
    #
    # Returns The average value
    return [expr {[tcl::mathop::+ {*}$listaxisPt 0.0] / max(1, [llength $listaxisPt])}]

}

proc tomato::mathpt3d::MidPoint {pt1 pt2} {
    # Gets the midpoint of two points
    #
    # pt1 - The first point [mathvec3d::Vector3d]
    # pt2 - The second point
    #
    # Returns The midpoint of the points [Point3d]
    return [tomato::mathpt3d::Centroid [list $pt1 $pt2]]

}

proc tomato::mathpt3d::Centroid {listPts} {
    # Gets the centroid of an arbitrary collection of points
    #
    # listPts - The list of points [Point3d]
    #
    # Returns The centroid of the points [Point3d]
    if {![llength $listPts]} {
        error "list points must be > 0"
    }

    foreach points $listPts {
        lassign [$points Get] x y z
        lappend ptx $x
        lappend pty $y
        lappend ptz $z
    }

    set centx [tomato::mathpt3d::Average $ptx]
    set centy [tomato::mathpt3d::Average $pty]
    set centz [tomato::mathpt3d::Average $ptz]

    return [tomato::mathpt3d::Point3d new $centx $centy $centz]
}

proc tomato::mathpt3d::IntersectionOf3Planes {plane1 plane2 plane3} {
    # Gets the point at which three planes intersect
    #
    # plane1 - [mathplane::Plane]
    # plane2 - [mathplane::Plane]
    # plane3 - [mathplane::Plane]
    #
    # Returns The point of intersection [Point3d]
    set ray [$plane1 IntersectionWith $plane2]
    return  [$plane3 IntersectionWith $ray]

}

proc tomato::mathpt3d::IntersectionOfPlaneRay {plane ray} {
    # Gets the point of intersection between a plane and a ray
    #
    # plane - [mathplane::Plane]
    # ray   - [mathray3d::Ray3d]
    #
    # Returns The point of intersection [Point3d]
    return [$plane IntersectionWith $ray]

}

proc tomato::mathpt3d::Equals {pt other tolerance} {
    # Gets a value to indicate if a pair of points are equal
    #
    # pt - First input point [Point3d]
    # other - Second input point [Point3d]
    # tolerance - A tolerance (epsilon) to adjust for floating point error
    #
    # Returns true if the points are equal, otherwise false.
    #
    # See : methods == !=
    if {$tolerance < 0} {
        #ruff
        # An error exception is raised if tolerance (epsilon) < 0.
        error "epsilon < 0"
    }

    return [expr {
                  abs([$other X] - [$pt X]) < $tolerance && 
                  abs([$other Y] - [$pt Y]) < $tolerance && 
                  abs([$other Z] - [$pt Z]) < $tolerance
                }]
}