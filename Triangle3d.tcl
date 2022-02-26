# Copyright (c) 2021-2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval tomato::mathtriangle {
    # Ruff documentation
    variable _ruff_preamble "A Class representing a Triangle in 3D space"
}

oo::class create tomato::mathtriangle::Triangle {
    variable _a ;
    variable _b ;
    variable _c ;

    constructor {args} {
        # Initializes a new Triangle Class.

        if {[llength $args] != 3} {
            error "Must be a list of 3 values... : \$args = [llength $args]"
        }

        set _triangle {}

        foreach val $args {

            if {[TypeOf $val Isa "Point3d"]} {
                lappend _triangle $val

            } elseif {[string is list $val] && ([llength $val] == 3)} {
                lappend _triangle [tomato::mathpt3d::Point3d new {*}$val]

            } else {
                error "list of 3 values or 'Point3d' class..."
            }
        }

        if {[llength $_triangle] != 3} {
            error "Triangle must be a list of 3 values... : $_triangle"
        }

        if {[tomato::mathpt3d::IsCollinearPoints {*}$_triangle]} {
            error "Collinear points..."
        }

        lassign $_triangle _a _b _c
    }
}

oo::define tomato::mathtriangle::Triangle {

    method A {} {
        # Returns the first point of the Triangle [mathpt3d::Point3d].
        return $_a
    }

    method B {} {
        # Returns the second point of the Triangle [mathpt3d::Point3d].
        return $_b
    }

    method C {} {
        # Returns the third point of the Triangle [mathpt3d::Point3d].
        return $_c
    }

    method AB {} {
        # Gets Length of AB side.
        return [$_a DistanceTo $_b]
    }

    method AC {} {
        # Gets Length of AC side.
        return [$_a DistanceTo $_c]
    }

    method BC {} {
        # Gets Length of BC side.
        return [$_b DistanceTo $_c]
    }

    method Perimeter {} {
        # Gets Perimeter of the triangle.
        return [expr {[my AB] + [my BC] + [my AC]}]
    }

    method Aera {} {
        # Gets Aera of the triangle.
        set v1 [$_a VectorTo $_b]
        set v2 [$_a VectorTo $_c]

        return [expr {0.5 * [[$v1 CrossProduct $v2] Length]}]
        
    }

    method Normal {} {
        # Gets Normal of the triangle [mathvec3d::Vector3d].
        set v1 [$_a VectorTo $_b]
        set v2 [$_a VectorTo $_c]

        return [$v1 CrossProduct $v2]
    }

    method ToPlane {} {
       # Convert triangle to plane object [mathplane::Plane]. 
       return [tomato::mathplane::Plane new $_a [my Normal]]
    }

    method AngleA {} {
        # Gets Angle at the vertex A
        #
        # Returns The angle in radian between the vectors, with a range between 0° and 180°
        set v1 [$_a VectorTo $_b]
        set v2 [$_a VectorTo $_c]

        return [$v1 AngleTo $v2]
    }

    method AngleB {} {
        # Gets Angle at the vertex B
        #
        # Returns The angle in radian between the vectors, with a range between 0° and 180°
        set v1 [$_b VectorTo $_a]
        set v2 [$_b VectorTo $_c]

        return [$v1 AngleTo $v2]
    }

    method AngleC {} {
        # Gets Angle at the vertex C
        #
        # Returns The angle in radian between the vectors, with a range between 0° and 180°
        set v1 [$_c VectorTo $_a]
        set v2 [$_c VectorTo $_b]

        return [$v1 AngleTo $v2]
    }

    method BisectorA {} {
        # Angle bisector at the vertex A
        #
        # Returns [mathline3d::Line3d]
        set p [$_b + [[$_c - $_b] / [expr {1.0 + [my AC] / [my AB]}]]]

        return [tomato::mathline3d::Line3d new $_a $p]

    }

    method BisectorB {} {
        # Angle bisector at the vertex B
        #
        # Returns [mathline3d::Line3d]
        set p [$_c + [[$_a - $_c] / [expr {1.0 + [my AB] / [my BC]}]]]

        return [tomato::mathline3d::Line3d new $_b $p]

    }

    method BisectorC {} {
        # Angle bisector at the vertex C
        #
        # Returns [mathline3d::Line3d]
        set p [$_a + [[$_b - $_a] / [expr {1.0 + [my BC] / [my AC]}]]]

        return [tomato::mathline3d::Line3d new $_c $p]

    } 

    method Centroid {} {
        # Gets Centroid of the triangle
        #
        # Returns [mathpt3d::Point3d]
        return [tomato::mathpt3d::Centroid [list [my A] [my B] [my C]]]
    }

    method IntersectionWith {entity {tolerance $::tomato::helper::TolGeom}} {
        # Finds the intersection...
        # [Möller–Trumbore_intersection_algorithm](https://en.wikipedia.org/wiki/Möller–Trumbore_intersection_algorithm)
        #
        # entity - Options described below.
        #
        # Ray    - [mathray3d::Ray3d]
        # Line   - [mathline3d::Line3d]
        # tolerance - A tolerance (epsilon) to account for floating point error
        #
        # Returns nothing is no intersection, A [mathpt3d::Point3d] if intersection.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolGeom
        }

        switch -glob [$entity GetType] {
            *Ray3d {
                set ip [tomato::mathplane::IntersectionWithRay [my ToPlane] $entity $tolerance]
            }
            *Line3d {
                set ip [tomato::mathplane::IntersectionWithLine [my ToPlane] $entity $tolerance]
            }
            default {
                #ruff
                # An error exception is raised if entity is not as described above.
                error "Entity must be Line3d or Ray3d..."
            }
        }

        # get intersect point of line with triangle plane
        if {$ip eq ""} {
            # no intersection...
            return ""
        }

        set u [$_b VectorTo $_a]
        set v [$_c VectorTo $_a]
        set w [$ip VectorTo $_a]

        set uu [$u DotProduct $u]
        set uv [$u DotProduct $v]
        set vv [$v DotProduct $v]

        set wu [$w DotProduct $u]
        set wv [$w DotProduct $v]

        set D [expr {($uv * $uv) - ($uu * $vv)}]

        # ip is outside T ?
        set s [expr {(($uv * $wv) - ($vv * $wu)) / $D}]

        if {$s < 0.0 || $s > 1.0}  {
            return ""
        }

        # ip is outside T ?
        set t [expr {(($uv * $wu) - ($uu * $wv)) / $D}]

        if {$t < 0.0 || ($s + $t) > 1.0}  {
            return ""
        }

        return $ip

    }

    method == {other {tolerance $::tomato::helper::TolEquals}} {
        # Gets value that indicates whether each pair of elements in two specified points is equal.
        #
        # other     - The second triangle [Triangle] to compare.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the triangles are the same. Otherwise false.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolEquals
        }

        return [expr {[tomato::mathtriangle::Equals [self] $other $tolerance]}]
        
    }

    method != {other {tolerance $::tomato::helper::TolEquals}} {
        # Gets value that indicates whether any pair of elements in two specified points is not equal.
        #
        # other - The second triangle [Triangle] to compare.
        # tolerance - A tolerance (epsilon) to adjust for floating point error.
        #
        # Returns true if the triangles are different. Otherwise false.
        if {[llength [info level 0]] < 4} {
            set tolerance $::tomato::helper::TolEquals
        }

        return [expr {![tomato::mathtriangle::Equals [self] $other $tolerance]}]
        
    }

    method GetType {} {
        # Gets the name of class.
        return [tomato::helper::TypeClass [self]]
    }

    export A B C AB AC BC Perimeter Aera Normal ToPlane
    export AngleA AngleB AngleC Centroid IntersectionWith
    export BisectorA BisectorB BisectorC GetType
    export == !=


}


proc tomato::mathtriangle::Equals {triangle other tolerance} {
    # Gets a value to indicate if a pair of triangles are equal
    #
    # triangle  - First input triangle [Triangle]
    # other     - Second input triangle [Triangle]
    # tolerance - A tolerance (epsilon) to adjust for floating point error
    #
    # Returns true if the triangles are equal, otherwise false.
    #
    # See : methods == !=
    if {$tolerance < 0} {
        #ruff
        # An error exception is raised if tolerance (epsilon) < 0.
        error "epsilon < 0"
    }

    return [expr {[[$triangle Centroid] == [$other Centroid] $tolerance] &&
                  (([$triangle Aera] - [$other Aera]) < $tolerance)
                  }]
}
