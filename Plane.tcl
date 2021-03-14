# Copyright (c) 2021 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval tomato::mathplane {
    # Ruff documentation
    variable _ruff_preamble "A Class representing a Plane in 3D space"
}

oo::class create tomato::mathplane::Plane {
    variable _normal ; # The normal vector of the Plane.
    variable _d      ; # The distance to the Plane along its normal from the origin.

    constructor {args} {
        # Initializes a new Plane Class.
        # Constructs a Plane from the given normal and distance along the normal from the origin.
        #
        # args - Options described below.
        #
        # Vector3d+double value  - The Plane's normal vector. [mathvec3d::Vector3d]<br>
        #                        + double value (the distance to the Plane along its normal from the origin).
        # Vector3d+Point3d       - The Plane's normal vector. [mathvec3d::Vector3d]<br>
        #                        + The Plane's distance from the origin along its normal vector. [mathpt3d::Point3d].
        # Point3d+Vector3d       - The Plane's distance from the origin along its normal vector. [mathpt3d::Point3d]<br>
        #                        + The Plane's normal vector. [mathvec3d::Vector3d].
        # 4 values               - List of 4 values or 4 distinct values : The first 3 values represent The Plane's normal vector<br>
        #                          and the last the distance to the Plane along its normal from the origin

        if {[llength $args] == 2} {

            lassign $args obj value

            if {[TypeOf $obj Isa "Vector3d"] && [string is double $value]} {

                set _normal [$obj Normalized]
                set _d      [expr {$value * -1}]

            } elseif {[TypeOf $obj Isa "Vector3d"] && [TypeOf $value Isa "Point3d"]} {

                set _normal [$obj Normalized]
                set _d      [expr {[tomato::mathvec3d::Dot $_normal $value] * -1}]

            } elseif {[TypeOf $obj Isa "Point3d"] && [TypeOf $value Isa "Vector3d"]} {

                set _normal [$value Normalized]
                set _d      [expr {[tomato::mathvec3d::Dot $_normal $obj] * -1}]

            } else {
                #ruff
                # An error exception is raised if \[llength $args] == 2 and two values are not as described above.
                error "Args must be A Vector3d with double value , A Vector3d with Point3d Or A Point3d with Vector3d..."
            }

        } elseif {[llength $args] == 1} {

            if {[llength {*}$args] != 4} {
                #ruff
                # An error exception is raised if \[length {*}$args] != 4.
                error "Must be a list of 4 values... : $args"
            }

            lassign {*}$args x y z d
            set _normal [[tomato::mathvec3d::Vector3d new $x $y $z] Normalized]
            set _d $d


        } elseif {[llength $args] == 4} {
        
            lassign $args x y z d

            set _normal [[tomato::mathvec3d::Vector3d new $x $y $z] Normalized]
            set _d $d

        } else {
            # Default value
            set _normal [tomato::mathvec3d::Vector3d new 0.0 0.0 1.0]
            set _d -1
        }
    }
}

oo::define tomato::mathplane::Plane {

    method A {} {
        # Gets the Normal x component.
        return [$_normal X]
    }

    method B {} {
        # Gets the Normal y component.
        return [$_normal Y]
    }

    method C {} {
        # Gets the Normal z component.
        return [$_normal Z]
    }

    method D {} {
        # Gets the distance to the Plane along its normal from the origin
        return $_d
    }

    method Normal {} {
        # Gets the normal vector of the Plane
        return $_normal
    }

    method IntersectionWith {entity {tolerance 1e-4}} {
        # Finds the intersection...
        # 
        # entity - Options described below.
        #
        # Plane  - [Plane]
        # Ray    - [mathray3d::Ray3d]
        # Line   - [mathline3d::Line3d]
        # tolerance - A tolerance (epsilon) to account for floating point error
        #
        # See also: IntersectionWithPlane IntersectionWithRay IntersectionWithLine

        switch -glob [$entity GetType] {
            *Plane {
                return [tomato::mathplane::IntersectionWithPlane [self] $entity $tolerance]
            }
            *Ray3d {
                return [tomato::mathplane::IntersectionWithRay [self] $entity]
            }
            *Line3d {
                return [tomato::mathplane::IntersectionWithLine [self] $entity $tolerance]
            }
            default {
                #ruff
                # An error exception is raised if entity is not as described above.
                error "Entity must be Plane, Line3d or Ray3d..."
            }
        }

    }

    method Project {entity {direction "null"}} {
        # Projection...
        # 
        # entity - Options described below.
        #
        # Point  - [mathpt3d::Point3d]
        # Vector - [mathvec3d::Vector3d]
        # Line   - [mathline3d::Line3d]
        # direction - The direction of projection [mathvec3d::Vector3d]
        #
        # See also: ProjectPointOnplane ProjectVectorOnplane ProjectLine3dOnplane

        switch -glob [$entity GetType] {
            *Point3d {
                return [tomato::mathplane::ProjectPointOnplane [self] $entity $direction]
            }
            *Vector3d {
                return [tomato::mathplane::ProjectVectorOnplane [self] $entity $direction]
            }
            *Line3d {
                return [tomato::mathplane::ProjectLine3dOnplane [self] $entity $direction]
            }
            default {
                #ruff
                # An error exception is raised if entity is not as described above.
                error "Entity must be Point3d, Vector3d or Line3d..."
            }
        }

    }

    method SignedDistanceTo {entity} {
        # Gets the signed distance
        # 
        # entity - Options described below.
        #
        # Point  - [mathpt3d::Point3d]
        # Plane  - [Plane]
        # Ray    - [mathray3d::Ray3d]
        #
        # Returns 
        # The distance to the point along the "Normal" if entity is Point
        # The distance to the plane along the "Normal" if entity is Plane
        # The distance to the ThroughPoint of "ray" along the "Normal" if entity is Ray

        switch -glob [$entity GetType] {
            *Point3d {
                set p [my Project $entity]
                set v [$p VectorTo $entity]

                return [$v DotProduct [my Normal]]
            }
            *Plane {
                if {![[my Normal] IsParallelTo [$entity Normal] 1e-15]} {
                    error "Planes are not parallel..."
                }

                return [my SignedDistanceTo [$entity RootPoint]]
            }
            *Ray3d {
                if {abs([[$entity Direction] DotProduct [my Normal]] - 0) < 1e-15} {
                    return [my SignedDistanceTo [$entity ThroughPoint]]
                }

                return 0
                }
            default {
                #ruff
                # An error exception is raised if entity is not as described above.
                error "Entity must be Point3d, Plane or Ray3d..."
            }
        }

    }

    method AbsoluteDistanceTo {point} {
        # Gets the distance to the point.
        #
        # point  - A point [mathpt3d::Point3d]
        #
        # Returns the distance
        return [expr {abs([my SignedDistanceTo $point])}]

    }

    method MirrorAbout {point} {
        # Gets point mirrored about the plane.
        #
        # point  - A point [mathpt3d::Point3d]
        #
        # Returns The mirrored point [mathpt3d::Point3d].
        set p2 [my Project $point]
        set d  [my SignedDistanceTo $point]

        return [$p2 - [[my Normal] * $d]]

    }

    method Rotate {aboutVector angle} {
        # Rotates a plane
        #
        # aboutVector - The vector about which to rotate [mathvec3d::Vector3d]
        # angle - The angle to rotate in degrees
        #
        # Returns A rotated plane [Plane]

        set rootPoint [my RootPoint]
        set rotatedPoint [$rootPoint Rotate $aboutVector $angle]
        set rotatedPlaneVector [[my Normal] Rotate $aboutVector $angle]

        return [tomato::mathplane::Plane new $rotatedPlaneVector $rotatedPoint]

    }

    method == {other {tolerance 1e-4}} {
        # Gets value that indicates whether each pair of elements in two specified planes is equal.
        #
        # other     - The first plane to compare [Plane].
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the planes are the same. Otherwise false.
        return [expr {[tomato::mathplane::Equals [self] $other $tolerance]}]
    }

    method != {other {tolerance 1e-4}} {
        # Gets value that indicates whether any pair of elements in two specified planes is not equal.
        #
        # other - The second plane to compare [Plane].
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the planes are different. Otherwise false.
        return [expr {![tomato::mathplane::Equals [self] $other $tolerance]}]
    }

    method RootPoint {} {
        # Gets the point on the plane closest to origin.
        return [[[my Normal] * [expr {[my D] * -1}]] ToPoint3D]
    }

    method GetType {} {
        # Gets the name of class.
        return [tomato::helper::TypeClass [self]]
    }

    method ToString {} {
        # Returns a string representation of this object.
        return [format {%s, %s, %s, %s} [my A] [my B] [my C] [my D]]
        
    }


    export A B C D Normal RootPoint ToString IntersectionWith Project SignedDistanceTo AbsoluteDistanceTo
    export == != MirrorAbout Rotate GetType

}

proc tomato::mathplane::ProjectPointOnplane {plane point direction} {
    # Projects a point onto the plane
    #
    # plane - The plane projection [Plane]
    # point - [mathpt3d::Point3d]
    # direction - The direction of projection [mathvec3d::Vector3d] (can be equal to "null")
    #
    # Returns A projected point [mathpt3d::Point3d]

    set dotProduct [[$plane Normal] DotProduct [$point ToVector3D]]
    set projectiononNormal [expr {$direction eq "null" ? [$plane Normal] : [$direction Normalized]}]

    set projectionVector [$projectiononNormal * [expr {$dotProduct + [$plane D]}]]
    return [$point - $projectionVector]

}

proc tomato::mathplane::ProjectVectorOnplane {plane vector direction} {
    # Projects a point onto the plane
    #
    # plane - The plane projection [Plane]
    # vector - [mathvec3d::Vector3d]
    # direction - The direction of projection [mathvec3d::Vector3d] (can be equal to "null")
    #
    # Returns A projected ray [mathray3d::Ray3d]

    set projectedEndPoint [$plane Project [$vector ToPoint3D] $direction]
    set projectedZero     [$plane Project [tomato::mathpt3d::Point3d new 0 0 0] $direction]

    return [tomato::mathray3d::Ray3d new $projectedZero [[$projectedZero VectorTo $projectedEndPoint] Normalized]]

}

proc tomato::mathplane::ProjectLine3dOnplane {plane line direction} {
    # Projects a point onto the plane
    #
    # plane - The plane projection [Plane]
    # line - [mathline3d::Line3d]
    # direction - The direction of projection [mathvec3d::Vector3d] (can be equal to "null")
    #
    # Returns A projected line [mathline3d::Line3d]

    set projectedStartPoint [$plane Project [$line StartPoint] $direction]
    set projectedEndPoint   [$plane Project [$line EndPoint] $direction]

    return [tomato::mathline3d::Line3d new $projectedStartPoint $projectedEndPoint]

}


proc tomato::mathplane::FromPoints {p1 p2 p3 {tolerance 1e-4}} {
    # Initializes a new instance of the Plane class.
    # Creates a plane that contains the three given points.
    #
    # p1  - The first point on the plane. [mathpt3d::Point3d]
    # p2  - The second point on the plane. [mathpt3d::Point3d]
    # p3  - The third point on the plane. [mathpt3d::Point3d]
    # tolerance  - To ensure than the 3 points are not on the same line.
    #
    # Returns The plane containing the three points.

    # http://www.had2know.com/academics/equation-plane-through-3-points.html
    if {[$p1 == $p2] || [$p1 == $p3] || [$p2 == $p3]} {
        error "Must use three different points"
    }

    set v1 [tomato::mathvec3d::Vector3d new [expr {[$p2 X] - [$p1 X]}] \
                                          [expr {[$p2 Y] - [$p1 Y]}] \
                                          [expr {[$p2 Z] - [$p1 Z]}]]
            
    set v2 [tomato::mathvec3d::Vector3d new [expr {[$p3 X] - [$p1 X]}] \
                                          [expr {[$p3 Y] - [$p1 Y]}] \
                                          [expr {[$p3 Z] - [$p1 Z]}]]

    set cross [tomato::mathvec3d::Cross $v1 $v2]

    if {[$cross Length] < $tolerance} {
        error "The 3 points should not be on the same line"
    }

    return [tomato::mathplane::Plane new [$cross Normalized] $p1]

}

proc tomato::mathplane::PointFromPlanes {plane1 plane2 plane3} {
    # Gets a point of intersection between three planes
    #
    # plane1  - The first plane. [Plane]
    # plane2  - The second plane. [Plane]
    # plane3  - The third plane. [Plane]
    #
    # Returns The intersection point. [mathpt3d::Point3d]

    return [tomato::mathpt3d::IntersectionOf3Planes $plane1 $plane2 $plane3]

}

proc tomato::mathplane::IntersectionWithPlane {plane1 plane2 tolerance} {
    # Finds the intersection of the two planes, throws if they are parallel
    #
    # plane1  - The first plane. [Plane]
    # plane2  - The second plane. [Plane]
    # tolerance  - A tolerance (epsilon) to account for floating point error.
    #
    # Returns A ray at the intersection. [mathray3d::Ray3d]

    set dir [[$plane1 Normal] CrossProduct [$plane2 Normal]]
    set det [$dir LengthSquared]

    if {abs($det) > $tolerance} {

        set v1 [$dir CrossProduct [$plane2 Normal]]
        set v2 [$v1 * [$plane1 D]]

        set v3 [[$plane1 Normal] CrossProduct $dir]
        set v4 [$v2 + [$v3 * [$plane2 D]]]

        set pt [$v4 * [expr {1.0 / $det}]]
        
    } else {
        error "Planes are parallel"
    }

    return [tomato::mathray3d::Ray3d new [$pt ToPoint3D] $dir]
}

proc tomato::mathplane::IntersectionWithRay {plane1 ray} {
    # Finds the intersection between a ray and plane, throws if ray is parallel to the plane
    # <http://www.cs.princeton.edu/courses/archive/fall00/cs426/lectures/raycast/sld017.htm>
    # 
    # plane1  - [Plane]
    # ray     - [mathray3d::Ray3d]
    #
    # Returns The point of intersection. [mathpt3d::Point3d]

    if {[[$plane1 Normal] IsPerpendicularTo [$ray Direction]]} {
        error "Ray is parallel to the plane..."
    }

    set d [$plane1 SignedDistanceTo [$ray ThroughPoint]]
    set t [expr {(-1 * $d) / [[$ray Direction] DotProduct [$plane1 Normal]]}]
    return [[$ray ThroughPoint] + [[$ray Direction] * $t]]
}

proc tomato::mathplane::IntersectionWithLine {plane1 line tolerance} {
    # Find intersection between Line3D and Plane
    # <http://geomalgorithms.com/a05-_intersect-1.html>
    # 
    # plane1   - [Plane]
    # line     - [mathline3d::Line3d]
    # tolerance - A tolerance (epsilon) to adjust for floating point error
    #
    # Returns Intersection Point [mathpt3d::Point3d] or nothing
    set dir [$line Direction]

    if {[$dir IsPerpendicularTo [$plane1 Normal] $tolerance]} {

        # either parallel or lies in the plane
        set projectedPoint [$plane1 Project [$line StartPoint] $dir]

        if {[$projectedPoint == [$line StartPoint]]} {
            error "Line lies in the plane"
        }

    }
 
    set d [$plane1 SignedDistanceTo [$line StartPoint]]
    set u [[$line StartPoint] VectorTo [$line EndPoint]]
    set dot [$u DotProduct [$plane1 Normal]]

    set t [expr {(-1 * $d) / double($dot)}]

    if {($t > 1) || ($t < 0)} {
        # They are not intersected
        return ""
    }

    return [[$line StartPoint] + [$u * $t]]

    
}

proc tomato::mathplane::Equals {plane other tolerance} {
    # Indicate if a pair of geometric planes are equal
    #
    # plane - First input plane [Plane]
    # other - Second input plane [Plane]
    # tolerance - A tolerance (epsilon) to adjust for floating point error
    #
    # Returns true if the planes are equal, otherwise false.
    #
    # See : methods == !=
    if {$tolerance < 0} {
        #ruff
        # An error exception is raised if tolerance (epsilon) < 0.
        error "epsilon < 0"
    }
    return [expr {
                  abs([$other D] - [$plane D]) < $tolerance && 
                  [[$plane Normal] == [$other Normal]]
                }]
}