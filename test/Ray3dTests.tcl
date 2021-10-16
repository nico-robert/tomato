lappend auto_path [file dirname [file dirname [info script]]]

package require tomato
package require tcltest

namespace import ::tcltest::*
namespace path tomato

set TestCase {}

lappend TestCase {{1 2 3} {0 0 1} {1 2 3} {0 0 1}}

foreach value $TestCase {

    lassign $value rootPoint unitVector eps evs

    set p1 [mathpt3d::Point3d new $rootPoint]
    set v1 [mathvec3d::Vector3d new $unitVector]

    set ray [mathray3d::Ray3d new $p1 $v1]

    test AreEqual [list \
        Test Equals ray.ThroughPoint : $value 
    ] -body {
         mathpt3d::Equals [$ray ThroughPoint] [mathpt3d::Point3d new $eps] 1e-9
    } -result 1

    test AreEqual [list \
        Test Equals ray.Direction : $value 
    ] -body {
         mathvec3d::Equals [$ray Direction] [mathvec3d::Vector3d new $evs] 1e-9
    } -result 1


}


set TestCase {}

lappend TestCase {{0 0 0} {0 0 1} {0 0 0} {0 1 0} {0 0 0} {-1 0 0}}
lappend TestCase {{0 0 2} {0 0 1} {0 0 0} {0 1 0} {0 0 2} {-1 0 0}}

foreach value $TestCase {

    lassign $value rootPoint1 unitVector1 rootPoint2 unitVector2 eps evs

    set plane1 [mathplane::Plane new [mathpt3d::Point3d new $rootPoint1] [mathvec3d::Vector3d new $unitVector1]]
    set plane2 [mathplane::Plane new [mathpt3d::Point3d new $rootPoint2] [mathvec3d::Vector3d new $unitVector2]]

    set actual   [mathray3d::IntersectionPlaneWithPlane $plane1 $plane2]
    set expected [mathray3d::Ray3d new [mathpt3d::Point3d new $eps] [mathvec3d::Vector3d new $evs]]

    test IntersectionOf [list \
        Test Equals IntersectionOf : $value 
    ] -body {
         mathray3d::Equals $actual $expected 1e-9
    } -result 1

}


set ray [mathray3d::Ray3d new [mathpt3d::Point3d new {0 0 0}] [mathvec3d::Vector3d new {0 0 1}]]
set point3D [mathpt3d::Point3d new {1 0 0}]
set line3DTo [$ray ShortestLineTo $point3D]

test LineToTest1 [list \
    Test Equals LineToTest 1
] -body {
     mathpt3d::Equals [$line3DTo StartPoint] [mathpt3d::Point3d new {0 0 0}] 1e-9
} -result 1

test LineToTest2 [list \
    Test Equals LineToTest 2
] -body {
     mathpt3d::Equals [$line3DTo EndPoint] $point3D 1e-9
} -result 1


set TestCase {}

lappend TestCase {{0 0 0} {1 -1 1} {0 0 0} {1 -1 1} 1}
lappend TestCase {{0 0 2} {1 -1 1} {0 0 0} {1 -1 1} 0}
lappend TestCase {{0 0 0} {1 -1 1} {0 0 0} {2 -1 1} 0}

foreach value $TestCase {

    lassign $value p1s v1s p2s v2s bool

    set ray1 [mathray3d::Ray3d new [mathpt3d::Point3d new $p1s] [mathvec3d::Vector3d new $v1s]]
    set ray2 [mathray3d::Ray3d new [mathpt3d::Point3d new $p2s] [mathvec3d::Vector3d new $v2s]]

    test Equals [list \
        Test Equals ray
    ] -body {
        mathray3d::Equals $ray1 $ray2 1e-9
    } -result $bool

    test Equals [list \
        Test Equals == ray
    ] -body {
        $ray1 == $ray2
    } -result $bool

    test Equals [list \
        Test Equals != ray
    ] -body {
        $ray1 != $ray2
    } -result [expr {!$bool}]

}

cleanupTests