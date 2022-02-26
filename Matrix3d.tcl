# Copyright (c) 2021-2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval tomato::mathmatrix3d {
    # Ruff documentation
    variable _ruff_preamble "Helper class for working with 3D matrixes"
}

proc tomato::mathmatrix3d::RotationAroundXAxis {angle} {
    # Creates a rotation matrix around the X axis
    #
    # angle - The Angle in degrees
    #
    # Returns A rotation matrix [mathmatrix::Matrix]

    set rotationMatrix [tomato::mathmatrix::Matrix new 3 3]
    set angletoradian  [tomato::helper::DegreesToRadians $angle]

    $rotationMatrix SetCell 0 0 1
    $rotationMatrix SetCell 1 1 [expr {cos($angletoradian)}]
    $rotationMatrix SetCell 1 2 [expr {-sin($angletoradian)}]
    $rotationMatrix SetCell 2 1 [expr {sin($angletoradian)}]
    $rotationMatrix SetCell 2 2 [expr {cos($angletoradian)}]

    return $rotationMatrix

}

proc tomato::mathmatrix3d::RotationAroundYAxis {angle} {
    # Creates a rotation matrix around the Y axis
    #
    # angle - The Angle in degrees
    #
    # Returns A rotation matrix [mathmatrix::Matrix]

    set rotationMatrix [tomato::mathmatrix::Matrix new 3 3]
    set angletoradian  [tomato::helper::DegreesToRadians $angle]

    $rotationMatrix SetCell 0 0 [expr {cos($angletoradian)}]
    $rotationMatrix SetCell 0 2 [expr {sin($angletoradian)}]
    $rotationMatrix SetCell 1 1 1
    $rotationMatrix SetCell 2 0 [expr {-sin($angletoradian)}]
    $rotationMatrix SetCell 2 2 [expr {cos($angletoradian)}]

    return $rotationMatrix

}

proc tomato::mathmatrix3d::RotationAroundZAxis {angle} {
    # Creates a rotation matrix around the Z axis
    #
    # angle - The Angle in degrees
    #
    # Returns A rotation matrix [mathmatrix::Matrix]

    set rotationMatrix [tomato::mathmatrix::Matrix new 3 3]
    set angletoradian  [tomato::helper::DegreesToRadians $angle]

    $rotationMatrix SetCell 0 0 [expr {cos($angletoradian)}]
    $rotationMatrix SetCell 0 1 [expr {-sin($angletoradian)}]
    $rotationMatrix SetCell 1 0 [expr {sin($angletoradian)}]
    $rotationMatrix SetCell 1 1 [expr {cos($angletoradian)}]
    $rotationMatrix SetCell 2 2 1

    return $rotationMatrix

}

proc tomato::mathmatrix3d::RotationTo {fromVector toVector {axis "null"}} {
    # Sets to the matrix of rotation that would align the 'from' vector with the 'to' vector.
    # The optional Axis argument may be used when the two vectors are parallel
    # and in opposite directions to specify a specific solution, but is otherwise ignored.
    #
    # fromVector - Input Vector object to align from. [mathvec3d::Vector3d]
    # toVector   - Input Vector object to align to. [mathvec3d::Vector3d]
    # axis       - Input Vector object. [mathvec3d::Vector3d]
    #
    # Returns A transform matrix [mathmatrix::Matrix]

    set fromVectornormalize [$fromVector Normalized]
    set toVectornormalize   [$toVector Normalized]

    if {[$fromVectornormalize == $toVectornormalize]} {
        return [tomato::mathmatrix::CreateIdentity 3]
    }

    if {[$fromVectornormalize IsParallelTo $toVectornormalize]} {

        if {$axis eq "null"} {
            set axis [$fromVector Orthogonal]
        }
        
    } else {
        set axis [$fromVectornormalize CrossProduct $toVectornormalize]
        $axis Normalize
    }

    set signedAngleTo [$fromVectornormalize SignedAngleTo $toVectornormalize $axis]

    return [tomato::mathmatrix3d::RotationAroundArbitraryVector $axis $signedAngleTo]

}

proc tomato::mathmatrix3d::RotationAroundArbitraryVector {aboutVector angle} {
    # Creates a rotation matrix around an arbitrary vector
    #
    # aboutVector - The vector. [mathvec3d::Vector3d]
    # angle - Angle in radians
    #
    # Returns A transform matrix [mathmatrix::Matrix]

    # http://en.wikipedia.org/wiki/Rotation_matrix
    set unitTensorProduct  [$aboutVector GetUnitTensorProduct]
    set crossproductMatrix [$aboutVector CrossProductMatrix]

    set mat [tomato::mathmatrix::CreateIdentity 3]

    set r1 [$mat Multiply [expr {cos($angle)}]]
    set r2 [$crossproductMatrix Multiply [expr {sin($angle)}]]
    set r3 [$unitTensorProduct Multiply [expr {1 - cos($angle)}]]
  
    set totalR [[$r1 Add $r2] Add $r3]

    return $totalR

}