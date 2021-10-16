lappend auto_path [file dirname [file dirname [info script]]]

package require tomato
package require tcltest

namespace import ::tcltest::*
namespace path tomato


set X {1 0 0}
set Z {0 0 1}

set NegativeZ {0 0 -1}
set ZeroPoint {0 0 0}


set plane1 [mathplane::Plane new [mathpt3d::Point3d new 0 0 3] [mathvec3d::UnitZ]]
set plane2 [mathplane::Plane new {0 0 3 -3}]
set plane3 [mathplane::Plane new [mathvec3d::UnitZ] 3]
set plane4 [mathplane::FromPoints [mathpt3d::Point3d new 0 0 3] [mathpt3d::Point3d new 5 3 3] [mathpt3d::Point3d new -2 1 3]]

test AreEqual [list \
    Test Equals : plane1 plane2 
] -body {
     mathplane::Equals $plane1 $plane2 1e-4
} -result 1

test AreEqual [list \
    Test Equals : plane1 plane3 
] -body {
     mathplane::Equals $plane1 $plane3 1e-4
} -result 1

test AreEqual [list \
    Test Equals : plane1 plane4 
] -body {
     mathplane::Equals $plane1 $plane4 1e-4
} -result 1


set TestCase {}

lappend TestCase {{0 0 0} {1 0 0} {0 0 0} {1 0 0}}

foreach value $TestCase {

    lassign $value rootPoint unitVector pds vds

    set plane [mathplane::Plane new [mathpt3d::Point3d new $rootPoint] [mathvec3d::Vector3d new $unitVector]]

    set rp [$plane RootPoint]
    set pn [$plane Normal]

    set p [mathpt3d::Point3d new $pds]
    set vd [mathvec3d::Vector3d new $vds]


    test AreEqual [list \
        Test Equals : p rp > $value
    ] -body {
        mathpt3d::Equals $p $rp 1e-4
    } -result 1

    test AreEqual [list \
        Test Equals : vd pn > $value
    ] -body {
        mathvec3d::Equals $vd $pn 1e-4
    } -result 1

}

set TestCase {}

lappend TestCase [list $ZeroPoint {0 0 0} {0 0 1} $ZeroPoint]
lappend TestCase [list $ZeroPoint {0 0 -1} {0 0 1} {0 0 -1}]
lappend TestCase [list $ZeroPoint {0 0 1} {0 0 -1} {0 0 1}]
lappend TestCase [list {1 2 3} {0 0 0} {0 0 1} {1 2 0}]

foreach value $TestCase {

    lassign $value ps rootPoint unitVector eps

    set plane [mathplane::Plane new [mathpt3d::Point3d new $rootPoint] [mathvec3d::Vector3d new $unitVector]]
    set projectedPoint [$plane Project [mathpt3d::Point3d new $ps]]
    set expected [mathpt3d::Point3d new $eps]


    test ProjectPointOn [list \
        Test Equals : projectedPoint expected > $value
    ] -body {
        mathpt3d::Equals $projectedPoint $expected 1e-9
    } -result 1

}


set TestCase {}

lappend TestCase [list $ZeroPoint $Z $ZeroPoint 0]
lappend TestCase [list $ZeroPoint $Z {1 2 0} 0]
lappend TestCase [list $ZeroPoint $Z {1 -2 0} 0]
lappend TestCase [list $ZeroPoint $Z {1 2 3} 3]
lappend TestCase [list $ZeroPoint $Z {-1 -2 -3} -3]
lappend TestCase [list $ZeroPoint $NegativeZ $ZeroPoint 0]
lappend TestCase [list $ZeroPoint $NegativeZ {1 2 1} -1]
lappend TestCase [list $ZeroPoint $NegativeZ {1 2 -1} 1]
lappend TestCase [list {0 0 -1} $NegativeZ $ZeroPoint -1]
lappend TestCase [list {0 0 1} $NegativeZ $ZeroPoint 1]
lappend TestCase [list $ZeroPoint $X {1 0 0} 1]
lappend TestCase [list {188.6578 147.0620 66.0170} $Z {118.6578 147.0620 126.1170} 60.1]

foreach value $TestCase {

    lassign $value prps pns ps expected

    set plane [mathplane::Plane new [mathvec3d::Vector3d new $pns] [mathpt3d::Point3d new $prps]]
    set p [mathpt3d::Point3d new $ps]

    test SignedDistanceToPoint [list \
        Test Equals : SignedDistanceToPoint $expected > $value
    ] -body {
        expr {abs($expected - [$plane SignedDistanceTo $p]) < 1e-6}
    } -result 1

}


set TestCase {}

lappend TestCase [list $ZeroPoint $Z $ZeroPoint $Z 0]
lappend TestCase [list $ZeroPoint $Z {0 0 1} $Z 1]
lappend TestCase [list $ZeroPoint $Z {0 0 -1} $Z -1]
lappend TestCase [list $ZeroPoint $NegativeZ {0 0 -1} $Z 1]

foreach value $TestCase {

    lassign $value prps pns otherPlaneRootPointString otherPlaneNormalString expectedValue

    set plane      [mathplane::Plane new [mathvec3d::Vector3d new $pns] [mathpt3d::Point3d new $prps]]
    set otherPlane [mathplane::Plane new [mathvec3d::Vector3d new $otherPlaneNormalString] [mathpt3d::Point3d new $otherPlaneRootPointString]]

    test SignedDistanceToOtherPlane [list \
        Test Equals : SignedDistanceToOtherPlane $expectedValue > $value
    ] -body {
        expr {abs($expectedValue - [$plane SignedDistanceTo $otherPlane]) < 1e-6}
    } -result 1

}


set TestCase {}

lappend TestCase [list $ZeroPoint $Z $ZeroPoint $Z 0]
lappend TestCase [list $ZeroPoint $Z $ZeroPoint $X 0]
lappend TestCase [list $ZeroPoint $Z {0 0 1} $X 1]

foreach value $TestCase {

    lassign $value prps pns rayThroughPointString rayDirectionString expectedValue

    set plane      [mathplane::Plane new [mathvec3d::Vector3d new $pns] [mathpt3d::Point3d new $prps]]
    set otherPlane [mathray3d::Ray3d new [mathpt3d::Point3d new $rayThroughPointString] [mathvec3d::Vector3d new $rayDirectionString]]

    test SignedDistanceToRay [list \
        Test Equals : SignedDistanceToRay $expectedValue > $value
    ] -body {
        expr {abs($expectedValue - [$plane SignedDistanceTo $otherPlane]) < 1e-6}
    } -result 1

}

set unitVector [mathvec3d::UnitZ]
set rootPoint  [mathpt3d::Point3d new {0 0 1}]
set plane      [mathplane::Plane new $unitVector $rootPoint]
set line       [mathline3d::Line3d new [mathpt3d::Point3d new {0 0 0}] [mathpt3d::Point3d new {1 0 0}]]
set expected   [mathline3d::Line3d new [mathpt3d::Point3d new {0 0 1}] [mathpt3d::Point3d new {1 0 1}]]
set projectOn  [$plane Project $line]

test ProjectLineOn [list \
    Test Equals : ProjectLineOn
] -body {
        mathline3d::Equals $projectOn $expected 1e-9
} -result 1

set unitVector [mathvec3d::UnitZ]
set rootPoint  [mathpt3d::Point3d new {0 0 1}]
set plane      [mathplane::Plane new $unitVector $rootPoint]
set vector     [mathvec3d::Vector3d new {1 0 0}]  
set projectOn  [$plane Project $vector]

test ProjectVectorOn1 [list \
    Test Equals : ProjectVectorOn 1
] -body {
        mathvec3d::Equals [$projectOn Direction] [mathvec3d::Vector3d new {1 0 0}] 1e-9
} -result 1

test ProjectVectorOn2 [list \
    Test Equals : ProjectVectorOn 2
] -body {
        mathpt3d::Equals [$projectOn ThroughPoint] [mathpt3d::Point3d new {0 0 1}] 1e-9
} -result 1


set TestCase {}

lappend TestCase {{0 0 0} {0 0 1} {0 0 0} {0 1 0} {0 0 0} {-1 0 0}}
lappend TestCase {{0 0 2} {0 0 1} {0 0 0} {0 1 0} {0 0 2} {-1 0 0}}

foreach value $TestCase {

    lassign $value rootPoint1 unitVector1 rootPoint2 unitVector2 eps evs

    set plane1 [mathplane::Plane new [mathpt3d::Point3d new $rootPoint1] [mathvec3d::Vector3d new $unitVector1]]
    set plane2 [mathplane::Plane new [mathpt3d::Point3d new $rootPoint2] [mathvec3d::Vector3d new $unitVector2]]

    set intersections {}

    lappend intersections [$plane1 IntersectionWith $plane2]
    lappend intersections [$plane2 IntersectionWith $plane1]


    set pe [mathpt3d::Point3d new $eps]
    set ve [mathvec3d::Vector3d new $evs]

    foreach intersection $intersections {

        test InterSectionWithPlane1 [list \
            Test Equals : InterSectionWithPlane 1
        ] -body {
                mathpt3d::Equals [$intersection ThroughPoint] $pe 1e-9
        } -result 1

        test InterSectionWithPlane2 [list \
            Test Equals : InterSectionWithPlane 2
        ] -body {
                expr {[mathvec3d::Equals [$intersection Direction] $ve 1e-9] || 
                      [mathvec3d::Equals [[$intersection Direction] Negate] $ve 1e-9]}
        } -result 1

    }
}


set plane       [mathplane::Plane new [mathvec3d::UnitZ] [mathpt3d::Point3d new {0 0 0}]]
set point3D     [mathpt3d::Point3d new {1 2 3}]
set MirrorAbout [$plane MirrorAbout $point3D]

test MirrorPoint [list \
    Test Equals : MirrorPoint
] -body {
        mathpt3d::Equals [mathpt3d::Point3d new {1 2 -3}] $MirrorAbout 1e-9
} -result 1


set plane [mathplane::Plane new [mathvec3d::UnitZ] [mathpt3d::Point3d new {0 0 100}]]

test SignOfD [list \
    Test Equals : SignOfD
] -body {
        expr {[$plane D] == -100}
} -result 1


set plane1 [mathplane::Plane new [mathvec3d::Vector3d new {0.8 0.3 0.01}] [mathpt3d::Point3d new {20 0 0}]]
set plane2 [mathplane::Plane new [mathvec3d::Vector3d new {0.002 1 0.1}] [mathpt3d::Point3d new {0 0 0}]]
set plane3 [mathplane::Plane new [mathvec3d::Vector3d new {0.5 0.5 1}] [mathpt3d::Point3d new {0 0 -30}]]

set pointFromPlanes1 [mathplane::PointFromPlanes $plane1 $plane2 $plane3]
set pointFromPlanes2 [mathplane::PointFromPlanes $plane2 $plane1 $plane3]
set pointFromPlanes3 [mathplane::PointFromPlanes $plane3 $plane1 $plane2]


test InterSectionPointDifferentOrder1 [list \
    Test Equals : InterSectionPointDifferentOrder 1
] -body {
        mathpt3d::Equals $pointFromPlanes1 $pointFromPlanes2 1e-10
} -result 1

test InterSectionPointDifferentOrder2 [list \
    Test Equals : InterSectionPointDifferentOrder 2
] -body {
        mathpt3d::Equals $pointFromPlanes3 $pointFromPlanes2 1e-10
} -result 1



set TestCase {}

lappend TestCase {{0 0 0} {1 0 0} {0 0 0} {0 1 0} {0 0 0} {0 0 1} {0 0 0}}
lappend TestCase {{0 0 0} {-1 0 0} {0 0 0} {0 1 0} {0 0 0} {0 0 1} {0 0 0}}
lappend TestCase {{20 0 0} {1 0 0} {0 0 0} {0 1 0} {0 0 -30} {0 0 1} {20 0 -30}}

foreach value $TestCase {

    lassign $value rootPoint1 unitVector1 rootPoint2 unitVector2 rootPoint3 unitVector3 eps

    set plane1 [mathplane::Plane new [mathpt3d::Point3d new $rootPoint1] [mathvec3d::Vector3d new $unitVector1]]
    set plane2 [mathplane::Plane new [mathpt3d::Point3d new $rootPoint2] [mathvec3d::Vector3d new $unitVector2]]
    set plane3 [mathplane::Plane new [mathpt3d::Point3d new $rootPoint3] [mathvec3d::Vector3d new $unitVector3]]

    set points {}

    lappend points [mathplane::PointFromPlanes $plane1 $plane2 $plane3]
    lappend points [mathplane::PointFromPlanes $plane2 $plane1 $plane3]
    lappend points [mathplane::PointFromPlanes $plane1 $plane3 $plane2]
    lappend points [mathplane::PointFromPlanes $plane2 $plane3 $plane1]
    lappend points [mathplane::PointFromPlanes $plane3 $plane2 $plane1]
    lappend points [mathplane::PointFromPlanes $plane3 $plane1 $plane2]


    set expected [mathpt3d::Point3d new $eps]

    foreach point $points {

        test PointFromPlanes [list \
            Test Equals : PointFromPlanes > $value
        ] -body {
                mathpt3d::Equals $expected $point 1e-4
        } -result 1

    }
}


set TestCase {}

lappend TestCase {{1 1 0 -12} {-1 1 0 -12} {0 0 1 -5} {0 16.970563 5}}
foreach value $TestCase {

    lassign $value planeString1 planeString2 planeString3 eps

    set plane1 [mathplane::Plane new $planeString1]
    set plane2 [mathplane::Plane new $planeString2]
    set plane3 [mathplane::Plane new $planeString3]

    set points {}

    lappend points [mathplane::PointFromPlanes $plane1 $plane2 $plane3]
    lappend points [mathplane::PointFromPlanes $plane2 $plane1 $plane3]
    lappend points [mathplane::PointFromPlanes $plane1 $plane3 $plane2]
    lappend points [mathplane::PointFromPlanes $plane2 $plane3 $plane1]
    lappend points [mathplane::PointFromPlanes $plane3 $plane2 $plane1]
    lappend points [mathplane::PointFromPlanes $plane3 $plane1 $plane2]

    set expected [mathpt3d::Point3d new $eps]

    foreach point $points {

        test PointFromPlanes [list \
            Test Equals : PointFromPlanes > $value
        ] -body {
                mathpt3d::Equals $expected $point 1e-4
        } -result 1

    }
}

cleanupTests