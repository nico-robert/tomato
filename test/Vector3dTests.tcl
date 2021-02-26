lappend auto_path [file dirname [file dirname [info script]]]

package require tomato
package require tcltest

namespace import ::tcltest::*
namespace path tomato


set X {1 0 0}
set Y {0 1 0}
set Z {0 0 1}

set NegativeX {-1 0 0}
set NegativeY {0 -1 0}
set NegativeZ {0 0 -1}


set actual [mathvec3d::Vector3d new 1 2 3]

foreach axis {X Y Z} value {1 2 3} {
    test Vector [list \
        Test $axis
    ] -body [list \
        $actual $axis
     ] -result $value
}

set TestCase {}

lappend TestCase {{1 2 3} {1 2 3} 1e-4}

foreach value $TestCase {

    lassign $value v1s v2s tol expected

    set v1 [mathvec3d::Vector3d new $v1s]
    set v2 [mathvec3d::Vector3d new $v2s]
  
    test AreEqual [list \
        Test == operator : $value 
    ] -body {
        $v1 == $v2
    } -result 1

    test AreEqual [list \
        Test Equals : $value 
    ] -body {
         mathvec3d::Equals $v1 $v2 $tol
    } -result 1

    test AreEqual [list \
        Test != operator : $value 
     ] -body {
        $v1 != $v2
    } -result 0

}


set TestCase {}

lappend TestCase {{1 2 -3} {3} {3 6 -9}}

foreach value $TestCase {

    lassign $value vs multiplier expected

    set v   [mathvec3d::Vector3d new $vs]
    set exp [mathvec3d::Vector3d new $expected]
    set mul [$v * $multiplier]

    test AreEqual [list \
        Test OperatorMultiply : $value 
     ] -body {
        mathvec3d::Equals $mul $exp 1e-6
    } -result 1

}

set TestCase {}

lappend TestCase {{1 0 0}}
lappend TestCase {{1 1 0}}
lappend TestCase {{1 -1 0}}

foreach value $TestCase {

    lassign $value vs

    set v [mathvec3d::Vector3d new $vs]
    set orthogonal [$v Orthogonal]

    test AreEqual [list \
        Test Orthogonal : $value 
     ] -body {
        expr {[$orthogonal DotProduct $v] < 1e-6}
    } -result 1

}


set TestCase {}

lappend TestCase [list $X $Y $Z]
lappend TestCase [list $X {1 1 0} $Z]
lappend TestCase [list $X $NegativeY $NegativeZ]
lappend TestCase [list $Y $Z $X]
lappend TestCase [list $Y {0.1 0.1 1} {1 0 -0.1}]
lappend TestCase [list $Y {-0.1 -0.1 1} {1 0 0.1}]

foreach value $TestCase {

    lassign $value v1s v2s ves

    set vector1  [mathvec3d::Vector3d new $v1s]
    set vector2  [mathvec3d::Vector3d new $v2s]
    set expected [mathvec3d::Vector3d new $ves]

    set crossProduct [$vector1 CrossProduct $vector2]

    test AreEqual [list \
        Test CrossProduct : $value 
     ] -body {
        mathvec3d::Equals $crossProduct $expected 1e-6
    } -result 1    

}

set TestCase {}

lappend TestCase [list $X $Y $Z 90]
lappend TestCase [list $X $X $Z 0]
lappend TestCase [list $X $NegativeY $Z -90]
lappend TestCase [list $X $NegativeX $Z 180]

foreach value $TestCase {

    lassign $value fromString toString axisString degreeAngle

    set fromVector  [mathvec3d::Vector3d new $fromString]
    set toVector    [mathvec3d::Vector3d new $toString]
    set aboutVector [mathvec3d::Vector3d new $axisString]

    set signedAngle [$fromVector SignedAngleTo $toVector $aboutVector]
 
    test AreEqual [list \
        Test SignedAngleTo : $value
    ] -body {
        expr {[helper::RadiansToDegrees $signedAngle] == $degreeAngle}
    } -result 1

}


set TestCase {}

lappend TestCase [list {1 0 1} $Y {-1 0 1} 90]

foreach value $TestCase {

    lassign $value fromString toString axisString degreeAngle

    set fromVector  [mathvec3d::Vector3d new $fromString]
    set toVector    [mathvec3d::Vector3d new $toString]
    set aboutVector [mathvec3d::Vector3d new $axisString]

    set signedAngle [$fromVector SignedAngleTo $toVector $aboutVector]

    test AreEqual [list \
        Test SignedAngleToArbitraryVector : $value
    ] -body {
        expr {abs([helper::RadiansToDegrees $signedAngle] - $degreeAngle) < 1e-6}
    } -result 1

}

set TestCase {}

lappend TestCase [list $X 5]
lappend TestCase [list $Y 5]
lappend TestCase [list {1 1 0} 5]
lappend TestCase [list {1 0 1} 5]
lappend TestCase [list {0 1 1} 5]
lappend TestCase [list {1 1 1} 5]
lappend TestCase [list $X 90]
lappend TestCase [list $Y 90]
lappend TestCase [list {1 1 0} 90]
lappend TestCase [list {1 0 1} 90]
lappend TestCase [list {0 1 1} 90]
lappend TestCase [list {1 1 1} 90]
lappend TestCase [list {1 0 1} -90]
lappend TestCase [list {1 0 1} 180]
lappend TestCase [list {1 0 1} 0]

foreach value $TestCase {

    lassign $value vectorDoubles rotationInDegrees

    set vector  [mathvec3d::Vector3d new $vectorDoubles]
    set angle   $rotationInDegrees
    set rotated [mathvec3d::Vector3d new [[mathmatrix3d::RotationAroundZAxis $angle] Multiply $vector]]
    set vectorZ [mathvec3d::Vector3d new $Z]
    set actual  [$vector SignedAngleTo $rotated $vectorZ]

    test AreEqual [list \
        Test SignedAngleToArbitraryVector : $value
    ] -body {
        expr {abs([helper::RadiansToDegrees $actual] - $rotationInDegrees) < 1e-6} 
    } -result 1

}

set TestCase {}

lappend TestCase [list $X $Y 90]
lappend TestCase [list $Y $X 90]
lappend TestCase [list $X $Z 90]
lappend TestCase [list $Z $X 90]
lappend TestCase [list $Y $Z 90]
lappend TestCase [list $Z $Y 90]
lappend TestCase [list $X $X 0]
lappend TestCase [list $Y $Y 0]
lappend TestCase [list $Z $Z 0]
lappend TestCase [list $X $NegativeY 90]
lappend TestCase [list $Y $NegativeY 180]
lappend TestCase [list $Z $NegativeZ 180]
lappend TestCase [list {1 1 0} $X 45]
lappend TestCase [list {1 1 0} $Y 45]
lappend TestCase [list {1 1 0} $Z 90]
lappend TestCase [list {2 2 0} {0 0 2} 90]
lappend TestCase [list {1 1 1} $X 54.74]
lappend TestCase [list {1 1 1} $Y 54.74]
lappend TestCase [list {1 1 1} $Z 54.74]
lappend TestCase [list {1 0 0} {1 0 0} 0]
lappend TestCase [list {-1 -1 1} {-1 -1 1} 0]
lappend TestCase [list {1 1 1} {-1 -1 -1} 180]

foreach value $TestCase {

    lassign $value v1s v2s ea

    set v1 [mathvec3d::Vector3d new $v1s]
    set v2 [mathvec3d::Vector3d new $v2s]

    lappend vect {v1:v2}
    lappend angles [$v1 AngleTo $v2]
    lappend vect {v2:v1}
    lappend angles [$v2 AngleTo $v1]

    set expected [helper::DegreesToRadians $ea]

    foreach angle $angles between $vect {

        test AreEqual [list \
            Test AngleTo $between : $value
        ] -body {
            expr {abs($angle - $expected) < 1e-2} 
        } -result 1

    }

    set angles {}
    set vect {}

}


set TestCase {}

lappend TestCase {{5 0 0} {1 0 0}}
lappend TestCase {{-5 0 0} {-1 0 0}}
lappend TestCase {{0 5 0} {0 1 0}}
lappend TestCase {{0 -5 0} {0 -1 0}}
lappend TestCase {{0 0 5} {0 0 1}}
lappend TestCase {{0 0 -5} {0 0 -1}}
lappend TestCase {{2 2 2} {0.577350269189626 0.577350269189626 0.577350269189626}}
lappend TestCase {{-2 15 2} {-0.131024356416084 0.982682673120628 0.131024356416084}}

foreach value $TestCase {

    lassign $value vs evs

    set vector [mathvec3d::Vector3d new $vs]
    set uv     [$vector Normalized]

    set expected [mathvec3d::Vector3d new $evs]

    test AreEqual [list \
        Test Normalize : $value
    ] -body {
        mathvec3d::Equals $uv $expected 1e-6
    } -result 1

}

set TestCase {}

lappend TestCase {{1 -1 10} {5} {5 -5 50}}

foreach value $TestCase {

    lassign $value vs s evs

    set v [mathvec3d::Vector3d new $vs]
    set expected [mathvec3d::Vector3d new $evs]
    set actual [$v ScaleBy $s]

    test AreEqual [list \
        Test Scale : $value
    ] -body {
        mathvec3d::Equals $actual $expected 1e-6
    } -result 1

}

set TestCase {}

lappend TestCase {{5 0 0} {5}}
lappend TestCase {{-5 0 0} {5}}
lappend TestCase {{-3 0 4} {5}}

foreach value $TestCase {

    lassign $value vectorString length

    set vector [mathvec3d::Vector3d new $vectorString]
    set len [$vector Length]

        test AreEqual [list \
            Test Length : $value
        ] -body {
            expr {$length == $len} 
        } -result 1

}


set TestCase {}

lappend TestCase [list $X $X 1]
lappend TestCase [list $X $NegativeX 1]
lappend TestCase [list $Y $Y 1]
lappend TestCase [list $Y $NegativeY 1]
lappend TestCase [list $Z $NegativeZ 1]
lappend TestCase [list $Z $Z 1]
lappend TestCase [list {1 -8 7} {1 -8 7} 1]
lappend TestCase [list $X {1 -8 7} 0]
lappend TestCase [list {1 -1.2 0} $Z 0]

foreach value $TestCase {

    lassign $value vector1 vector2 expected

    set v1 [mathvec3d::Vector3d new $vector1]
    set v2 [mathvec3d::Vector3d new $vector2]

    test AreEqual [list \
        Test IsParallelTo v1 v1 : $value
    ] -body {
        $v1 IsParallelTo $v1 1e-6
    } -result 1

    test AreEqual [list \
        Test IsParallelTo v2 v2 : $value
    ] -body {
        $v2 IsParallelTo $v2 1e-6
    } -result 1

    test AreEqual [list \
        Test IsParallelTo v1 v2 : $value
    ] -body {
        $v1 IsParallelTo $v2 1e-6
    } -result $expected

    test AreEqual [list \
        Test IsParallelTo v2 v1 : $value
    ] -body {
        $v2 IsParallelTo $v1 1e-6
    } -result $expected
}


set TestCase {}

lappend TestCase {{0 1 0} {0 1 0} {1e-10} 1}
lappend TestCase {{0 1 0} {0 -1 0} {1e-10} 1}
lappend TestCase {{0 1 0} {0 1 1} {1e-10} 0}
lappend TestCase {{0 1 1} {0 1 1} {1e-10} 1}
lappend TestCase {{0 1 -1} {0 -1 1} {1e-10} 1}
lappend TestCase {{0 1 0} {0 1 0.001} {1e-10} 0}
lappend TestCase {{0 1 0} {0 1 -0.001} {1e-10} 0}
lappend TestCase {{0 -1 0} {0 1 0.001} {1e-10} 0}
lappend TestCase {{0 -1 0} {0 1 -0.001} {1e-10} 0}
lappend TestCase {{0 1 0} {0 1 0.001} {1e-6} 1}
lappend TestCase {{0 1 0} {0 1 -0.001} {1e-6} 1}
lappend TestCase {{0 -1 0} {0 1 0.001} {1e-6} 1}
lappend TestCase {{0 -1 0} {0 1 -0.001} {1e-6} 1}
lappend TestCase {{0 1 0.5} {0 -1 -0.5} {1e-10} 1}

foreach value $TestCase {

    lassign $value v1s v2s tolerance expected

    set v1 [mathvec3d::Vector3d new $v1s]
    set v2 [mathvec3d::Vector3d new $v2s]

    test AreEqual [list \
        Test IsParallelToByDoubleTolerance v1 v2 : $value
    ] -body {
        $v1 IsParallelTo $v2 $tolerance
    } -result $expected 

    test AreEqual [list \
        Test IsParallelToByDoubleTolerance v2 v1 : $value
    ] -body {
        $v2 IsParallelTo $v1 $tolerance
    } -result $expected 

}


set TestCase {}

lappend TestCase [list $X $X 0]
lappend TestCase [list $NegativeX $X 0]
lappend TestCase [list {-11 0 0} $X 0]
lappend TestCase [list {1 1 0} $X 0]
lappend TestCase [list $X $Y 1]
lappend TestCase [list $X $Z 1]
lappend TestCase [list $Y $X 1]
lappend TestCase [list $Y $Z 1]
lappend TestCase [list $Z $Y 1]
lappend TestCase [list $Z $X 1]

foreach value $TestCase {

    lassign $value v1s v2s expected

    set v1 [mathvec3d::Vector3d new $v1s]
    set v2 [mathvec3d::Vector3d new $v2s]

    test AreEqual [list \
        Test IsPerpendicularTo v1 v2 : $value
    ] -body {
        $v1 IsPerpendicularTo $v2 $tolerance
    } -result $expected 

}


cleanupTests

