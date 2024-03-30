# Copyright (c) 2021-2024 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
package ifneeded tomato 1.2.4 [list apply {dir {

    source [file join $dir tomato.tcl]
    source [file join $dir Matrix.tcl]
    source [file join $dir Matrix3d.tcl]
    source [file join $dir Vector3d.tcl]
    source [file join $dir Point3d.tcl]
    source [file join $dir Ray3d.tcl]
    source [file join $dir Line3d.tcl]
    source [file join $dir Plane.tcl]
    source [file join $dir CoordinateSystem.tcl]
    source [file join $dir Quaternion.tcl]
    source [file join $dir Triangle3d.tcl]
    source [file join $dir Helper.tcl]

}} $dir]