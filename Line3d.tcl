# Copyright (c) 2021-2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval tomato::mathline3d {
    # Ruff documentation
    variable _ruff_preamble "A Class representing a Line in 3D space"
}

oo::class create tomato::mathline3d::Line3d {
    variable _startpoint ; # The start point of the line
    variable _endpoint ; # The end point of the line

    constructor {pt other} {
        # Initializes a new Line3d Class.
        #
        # pt     - [mathpt3d::Point3d]
        # other  - [mathpt3d::Point3d]

        if {![TypeOf $pt Isa "Point3d"]}    {error "Must be 'Point3d' ClassType"}
        if {![TypeOf $other Isa "Point3d"]} {error "Must be 'Point3d' ClassType"}

        set _startpoint $pt
        set _endpoint $other

        if {[$_startpoint == $_endpoint]} {
            #ruff
            # Throws an ArgumentException if the **startPoint** is equal to the **endPoint**
            error "StartPoint == EndPoint"
        }

    }
}

oo::define tomato::mathline3d::Line3d {

    method StartPoint {} {
        # Returns The start point of the line [mathpt3d::Point3d].
        return $_startpoint
    }

    method EndPoint {} {
        # Returns The end point of the line [mathpt3d::Point3d].
        return $_endpoint
    }

    method Get {} {
        # Returns List of 2 elements : [StartPoint] + [EndPoint]
        return [list $_startpoint $_endpoint]
    }

    method Length {} {
        # Gets distance from [StartPoint] and [EndPoint], the length of the line.
        return [$_startpoint DistanceTo $_endpoint]
    }

    method Direction {} {
        # Gets distance from [StartPoint] to [EndPoint]
        #
        # Returns [mathvec3d::Vector3d].
        return [[$_startpoint VectorTo $_endpoint] Normalized]
    }

    method LineTo {p mustStartBetweenStartAndEnd} {
        # Gets the shortest line between this line and a point.
        #
        # p - the point to create a line to [mathpt3d::Point3d]
        # mustStartBetweenStartAndEnd - If false the start point can extend beyond the start and endpoint of the line
        #
        # Returns The shortest line between the line and the point [Line3d].
        return [tomato::mathline3d::Line3d new [my ClosestPointTo $p $mustStartBetweenStartAndEnd] $p]
    }

    method ClosestPointTo {p mustBeOnSegment} {
        # Gets the closest point on the line to the given point.
        #
        # p               - The point that the returned point is the closest point on the line to [mathpt3d::Point3d]
        # mustBeOnSegment - If true the returned point is contained by the segment ends,<br>
        #                   otherwise it can be anywhere on the projected line
        #
        # Returns The closest point [mathpt3d::Point3d] on the line to the provided point.

        set v [$p - [my StartPoint]]
        set dotProduct [$v DotProduct [my Direction]]

        if {$mustBeOnSegment} {
            
            if {$dotProduct < 0} {
                set dotProduct 0
            } elseif {$dotProduct > [my Length]} {
                set dotProduct [my Length]
            }
        }

        set alongVector [[[my Direction] * $dotProduct] ToPoint3D]
        return [[my StartPoint] + $alongVector]

    }

    method ProjectOn {plane} {
        # Gets The line projected on a plane.
        #
        # plane - [mathplane::Plane]
        # 
        # Returns A projected line [Line3d].
        return [$plane Project [self]]
    }

    method IsParallelTo {other} {
        # Checks to determine whether or not two lines are parallel to each other, using the Cross product within
        # the double precision specified in the tomato::helper package
        #
        # other - [Line3d]
        # 
        # Returns A projected line [Line3d].
        return [[my Direction] IsParallelTo [$other Direction] [expr {[::tomato::helper::DoublePrecision] * 2}]]
    }

    method ClosestPointsBetween {other {mustBeOnSegments ""}} {
        # Computes the pair of points which represent the closest distance between this Line3D and another Line3D, with the first
        # point being the point on this Line3D, and the second point being the corresponding point on the other Line3D.  If the lines
        # intersect the points will be identical, if the lines are parallel the first point will be the start point of this line.
        #
        # other - line [Line3d] to compute the closest points with
        # mustBeOnSegments - if true, the lines are treated as segments bounded by the start and end point
        # 
        # Returns A List of two points representing the endpoints of the shortest distance between the two lines

        if {$mustBeOnSegments eq ""} {

            if {[my IsParallelTo $other]} {
                return [list [my StartPoint] [$other ClosestPointTo [my StartPoint] False]]
            }

            # http://geomalgorithms.com/a07-_distance.html
            set point0 [my StartPoint]
            set u      [my Direction]
            set point1 [$other StartPoint]
            set v      [$other Direction]

            set w0 [$point0 - $point1]
            set a  [$u DotProduct $u]
            set b  [$u DotProduct $v]
            set c  [$v DotProduct $v]
            set d  [$u DotProduct $w0]
            set e  [$v DotProduct $w0]

            set sc [expr {(($b * $e) - ($c * $d)) / (($a * $c) - ($b * $b))}]
            set tc [expr {(($a * $e) - ($b * $d)) / (($a * $c) - ($b * $b))}]

            return [list [$point0 + [[$u * $sc] ToPoint3D]] [$point1 + [[$v * $tc] ToPoint3D]]]
                
        } else {


            if {![my IsParallelTo $other] || !$mustBeOnSegments} {

                set result [my ClosestPointsBetween $other]

                if {!$mustBeOnSegments} {
                    return $result
                }

                lassign $result Item1 Item2
                set mylen    [my Length]
                set otherlen [$other Length]

                if {[$Item1 DistanceTo [my StartPoint]] <= $mylen &&
                    [$Item1 DistanceTo [my EndPoint]] <= $mylen &&
                    [$Item2 DistanceTo [$other StartPoint]] <= $otherlen &&
                    [$Item2 DistanceTo [$other StartPoint]] <= $otherlen} {

                    return $result            
                }
            }

            set checkPoint [$other ClosestPointTo [my StartPoint] true]
            set distance [$checkPoint DistanceTo [my StartPoint]]
            set closestPair [list [my StartPoint] $checkPoint]
            set minDistance $distance

            set checkPoint [$other ClosestPointTo [my EndPoint] true]
            set distance [$checkPoint DistanceTo [my EndPoint]]

            if {$distance < $minDistance} {
                set closestPair [list [my EndPoint] $checkPoint]
                set minDistance $distance
            }

            set checkPoint [my ClosestPointTo [$other StartPoint] true]
            set distance [$checkPoint DistanceTo [$other StartPoint]]

            if {$distance < $minDistance} {
                set closestPair [list $checkPoint [$other StartPoint]]
                set minDistance $distance
            }

            set checkPoint [my ClosestPointTo [$other EndPoint] true]
            set distance [$checkPoint DistanceTo [$other EndPoint]]

            if {$distance < $minDistance} {
                set closestPair [list $checkPoint [$other EndPoint]]
            }

            return $closestPair

        }

    }

    method IntersectionWith {intersectingPlane {tolerance $::tomato::helper::TolGeom}} {
        # Find the intersection between the line and a plane.
        #
        # intersectingPlane - [mathplane::Plane]
        # tolerance - A tolerance (epsilon) to compensate for floating point error.
        #
        # Returns A point [mathpt3d::Point3d] where the line and plane intersect, *** nothing *** if no such point exists
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolGeom
        }

        return [$intersectingPlane IntersectionWith [self] $tolerance]
            
    }

    method == {other {tolerance $::tomato::helper::TolEquals}} {
        # Gets value that indicates whether each pair of elements in two specified lines is equal.
        #
        # other     - The second line [Line3d] to compare.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the lines are the same. Otherwise false.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolEquals
        }

        return [expr {[tomato::mathline3d::Equals [self] $other $tolerance]}]
        
    }

    method != {other {tolerance $::tomato::helper::TolEquals}} {
        # Gets value that indicates whether any pair of elements in two specified lines is not equal.
        #
        # other - The second line [Line3d] to compare.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the lines are different. Otherwise false
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolEquals
        }

        return [expr {![tomato::mathline3d::Equals [self] $other $tolerance]}]
        
    }

    method GetType {} {
        # Gets the name of class.
        return [tomato::helper::TypeClass [self]]
    }

    method ToString {} {
        # Returns a string representation of this object.
        lappend value "StartPoint = [$_startpoint ToString]"
        lappend value "EndPoint   = [$_endpoint ToString]"
            
        return [join $value "\n"]
    }

    export StartPoint EndPoint Get Length Direction IntersectionWith ToString
    export == != GetType LineTo ClosestPointTo ClosestPointsBetween IsParallelTo ProjectOn

}


proc tomato::mathline3d::Equals {line other tolerance} {
    # Indicate if this line is equivalent to a given line
    #
    # line - First input line [Line3d]
    # other - Second input line [Line3d]
    # tolerance - A tolerance (epsilon) to adjust for floating point error
    #
    # Returns true if the lines are equal, otherwise false.
    #
    # See : methods == !=
    if {$tolerance < 0} {
        #ruff
        # An error exception is raised if tolerance (epsilon) < 0.
        error "epsilon < 0"
    }
    return [expr {
                  [tomato::mathpt3d::Equals [$other StartPoint] [$line StartPoint] $tolerance] && 
                  [tomato::mathpt3d::Equals [$other EndPoint] [$line EndPoint] $tolerance]
                }]
}