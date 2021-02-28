# Copyright (c) 2021 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
# tomato - math::geometry 3D library

package require Tcl 8.6

set dir [file dirname [file normalize [info script]]]

source [file join $dir Matrix.tcl]
source [file join $dir Matrix3d.tcl]
source [file join $dir Vector3d.tcl]
source [file join $dir Point3d.tcl]
source [file join $dir Ray3d.tcl]
source [file join $dir Line3d.tcl]
source [file join $dir Plane.tcl]
source [file join $dir CoordinateSystem.tcl]
source [file join $dir Helper.tcl]

namespace eval tomato {
    variable version 1.0

    variable _Intro {
        # tomato - math::geometry 3D library
        ` tomato math::geometry ` is an opensource geometry 3D library with basics functions for working
        in 3D space...
        This [Tcl](https://www.tcl.tk) package is inspired , copied (as best I could) from this great library written in .Net [Math.NET Spatial](https://spatial.mathdotnet.com/#Math-NET-Spatial).

        ** Currently geometries supported are : **
        Vector            - * A Class representing a Vector in 3D space *
        Ray               - * A Class representing a Ray in 3D space *
        Point             - * A Class representing a Point in 3D space *
        Plane             - * A Class representing a Plane in 3D space *
        Matrix3d          - * Helper class for working with 3D matrixes *
        Basic Matrix      - * Defines the base class for Matrix classes * (basic matrixes for `CoordinateSystem`, `Matrix3d` and `Vector`)
        Line              - * A Class representing a Line in 3D space *
        Coordinate System - * A Class representing a Coordinate System *

        #### Examples

        ```
        package require tomato
        namespace path tomato
        ```

        * Find angle between two vectors :
        ```
        set v1 [mathvec3d::Vector3d new {1 0 0}]
        set v2 [mathvec3d::Vector3d new 0 1 0]

        set angletov1v2 [$v1 AngleTo $v2]
        puts [helper::RadiansToDegrees $angletov1v2]
        # 90.0
        ```
        * IsParallelTo :
        ```
        set v1 [mathvec3d::Vector3d new {1 0 0}]
        set v2 [mathvec3d::Vector3d new {1 0 0}]
        puts [$v1 IsParallelTo $v2]
        # True
        ```
        * Find the distance between 2 points :
        ```
        set p1  [mathpt3d::Point3d new {0 0 0}]
        set p2  [mathpt3d::Point3d new {0 0 1}]

        puts [$p1 DistanceTo $p2]
        # 1
        ```
        * Rotated a point :
        ```
        set p [mathpt3d::Point3d new {1 2 3}]
        set angle 90
        set css [mathcsys::RotationAngleVector $angle [mathvec3d::Vector3d new {0 0 1}]]
        set rotatedPoint [$css Transform $p]
        puts [$rotatedPoint ToString]
        # -2 1 3
        ```
        * Projected point onto a plane :
        ```
        set plane [mathplane::Plane new [mathpt3d::Point3d new {0 0 0}] [mathvec3d::Vector3d new {0 0 1}]]
        set projectedPoint [$plane Project [mathpt3d::Point3d new {1 2 3}]]
        puts [$projectedPoint ToString]
        # 1 2 0
        ```
        * Define a Coordinate system :
        ```
        set origin [mathpt3d::Point3d new {1 2 3}]
        set xAxis  [mathvec3d::Vector3d new {1 0 0}]
        set yAxis  [mathvec3d::Vector3d new {0 1 0}]
        set zAxis  [mathvec3d::Vector3d new {0 0 1}]

        set css [mathcsys::Csys new $origin $xAxis $yAxis $zAxis]

        # Get baseclass
        set base [$css BaseClass]
        puts [$base ToMatrixString]
        # Column1 = XAxis; Column2 = YAxis; Column3 = ZAxis; Column4 = Origin
        # 
        # 1 0 0 1
        # 0 1 0 2
        # 0 0 1 3
        # 0 0 0 1
        ```
        * ShortestLineTo between a point and a ray :
        ```
        set ray [mathray3d::Ray3d new [mathpt3d::Point3d new {0 0 0}] [mathvec3d::Vector3d new {0 0 1}]]
        set point3D [mathpt3d::Point3d new {1 0 0}]
        set line3DTo [$ray ShortestLineTo $point3D]
        puts [[$line3DTo StartPoint] ToString]
        # 0 0 0
        puts [[$line3DTo EndPoint] ToString]
        # 1 0 0
        ```

        #### License
        <br>
        **tomato math::geometry** is covered under the terms of the [MIT](LICENSE.md) license.
    }
}

namespace import tomato::helper::TypeOf

package provide tomato $::tomato::version