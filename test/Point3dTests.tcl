lappend auto_path [file dirname [file dirname [info script]]]

package require tomato
package require tcltest

namespace import ::tcltest::*
namespace path tomato


set actual [mathpt3d::Point3d new 1 2 3]

foreach axis {X Y Z} value {1 2 3} {
    test Point [list \
        Test $axis
    ] -body [list \
        $actual $axis
     ] -result $value
}


set TestCase {}

lappend TestCase {{1 2 3} {1 2 3} {1e-4}}

foreach value $TestCase {

    lassign $value p1s p2s tol expected

    set p1 [mathpt3d::Point3d new $p1s]
    set p2 [mathpt3d::Point3d new $p2s]
  
    test AreEqual [list \
        Test == operator : $value 
    ] -body {
        $p1 == $p2
    } -result 1

    test AreEqual [list \
        Test Equals : $value 
    ] -body {
         mathpt3d::Equals $p1 $p2 $tol
    } -result 1

    test AreEqual [list \
        Test != operator : $value 
     ] -body {
        $p1 != $p2
    } -result 0

}

set TestCase {}

lappend TestCase {{1 2 3} {4 5 6} {1e-4}}

foreach value $TestCase {

    lassign $value p1s p2s tol

    set p1 [mathpt3d::Point3d new $p1s]
    set p2 [mathpt3d::Point3d new $p2s]
  
    test AreEqual [list \
        Test != operator : $value 
     ] -body {
        $p1 != $p2
    } -result 1

    test AreEqual [list \
        Test not Equals $p1s $p2s
     ] -body {
         expr {![mathpt3d::Equals $p1 $p2 $tol]}
    } -result 1

}

set TestCase {}

lappend TestCase {{0 0 0} {0 0 1} {0 0 0.5}}
lappend TestCase {{0 0 1} {0 0 0} {0 0 0.5}}
lappend TestCase {{0 0 0} {0 0 0} {0 0 0}}
lappend TestCase {{1 1 1} {3 3 3} {2 2 2}}
lappend TestCase {{-3 -3 -3} {3 3 3} {0 0 0}}

foreach value $TestCase {

    lassign $value p1s p2s eps

    set p1 [mathpt3d::Point3d new $p1s]
    set p2 [mathpt3d::Point3d new $p2s]
    set ep [mathpt3d::Point3d new $eps]
    set mp [tomato::mathpt3d::MidPoint $p1 $p2]

    test AreEqual [list \
        Test MidPoint : $value
     ] -body {
        mathpt3d::Equals $ep $mp 1e-9
    } -result 1

    set centroid [tomato::mathpt3d::Centroid [list $p1 $p2]]

    test AreEqual [list \
        Test centroid : $value
     ] -body {
        mathpt3d::Equals $ep $centroid 1e-9
    } -result 1

}

set TestCase {}

lappend TestCase {{0 0 0} {0 0 1} {0 0 0} {0 1 0} {0 0 0} {1 0 0} {0 0 0}}
lappend TestCase {{0 0 5} {0 0 1} {0 4 0} {0 1 0} {3 0 0} {1 0 0} {3 4 5}}

foreach value $TestCase {

    lassign $value rootPoint1 Vector1 rootPoint2 Vector2 rootPoint3 Vector3 eps

    set plane1 [mathplane::Plane new [mathpt3d::Point3d new $rootPoint1] [mathvec3d::Vector3d new $Vector1]]
    set plane2 [mathplane::Plane new [mathpt3d::Point3d new $rootPoint2] [mathvec3d::Vector3d new $Vector2]]
    set plane3 [mathplane::Plane new [mathpt3d::Point3d new $rootPoint3] [mathvec3d::Vector3d new $Vector3]]

    lappend listpts [tomato::mathpt3d::IntersectionOf3Planes $plane1 $plane2 $plane3]
    lappend listpts [tomato::mathpt3d::IntersectionOf3Planes $plane2 $plane1 $plane3]
    lappend listpts [tomato::mathpt3d::IntersectionOf3Planes $plane2 $plane3 $plane1]
    lappend listpts [tomato::mathpt3d::IntersectionOf3Planes $plane3 $plane1 $plane2]
    lappend listpts [tomato::mathpt3d::IntersectionOf3Planes $plane3 $plane2 $plane1]

    set ep [mathpt3d::Point3d new $eps]

    foreach pt $listpts {

        test AreEqual [list \
            Test IntersectionOf3Planes : $value
        ] -body {
            mathpt3d::Equals $ep $pt 1e-9
        } -result 1

    }

    set listpts {}
}


set TestCase {}

lappend TestCase {{0 0 0} {0 0 0} {0 0 1} {0 0 0}}
lappend TestCase {{0 0 0} {0 0 0} {0 0 1} {0 0 0}}

foreach value $TestCase {

    lassign $value ps rootPoint unitVector eps

    set p [mathpt3d::Point3d new $ps]
    set p2 [mathplane::Plane new [mathpt3d::Point3d new $rootPoint] [mathvec3d::Vector3d new $unitVector]]
    set actual [$p MirrorAbout $p2]

    set ep [mathpt3d::Point3d new $eps]

    test AreEqual [list \
        Test MirrorAbout : $value
    ] -body {
        mathpt3d::Equals $ep $actual 1e-9
    } -result 1

}

set TestCase {}

lappend TestCase {{0 0 0} {0 0 0} {0 0 1} {0 0 0}}
lappend TestCase {{0 0 1} {0 0 0} {0 0 1} {0 0 0}}
lappend TestCase {{0 0 1} {0 10 0} {0 1 0} {0 10 1}}

foreach value $TestCase {

    lassign $value ps rootPoint unitVector eps

    set p [mathpt3d::Point3d new $ps]
    set p2 [mathplane::Plane new [mathpt3d::Point3d new $rootPoint] [mathvec3d::Vector3d new $unitVector]]

    set actual [$p ProjectOn $p2]

    set ep [mathpt3d::Point3d new $eps]

    test AreEqual [list \
        Test ProjectOn : $value
    ] -body {
        mathpt3d::Equals $ep $actual 1e-9
    } -result 1

}

set TestCase {}

lappend TestCase {{1 2 3} {1 0 0} {2 2 3}}
lappend TestCase {{1 2 3} {0 1 0} {1 3 3}}
lappend TestCase {{1 2 3} {0 0 1} {1 2 4}}

foreach value $TestCase {

    lassign $value ps vs eps

    set p   [mathpt3d::Point3d new $ps]
    set add [$p + [mathvec3d::Vector3d new $vs]]
    set ps  [mathpt3d::Point3d new $eps]

    test AreEqual [list \
        Test AddVector : $value
    ] -body {
        mathpt3d::Equals $ps $add 1e-9
    } -result 1

}

set TestCase {}

lappend TestCase {{1 2 3} {1 0 0} {0 2 3}}
lappend TestCase {{1 2 3} {0 1 0} {1 1 3}}
lappend TestCase {{1 2 3} {0 0 1} {1 2 2}}

foreach value $TestCase {

    lassign $value ps vs eps

    set p   [mathpt3d::Point3d new $ps]
    set sub [$p - [mathvec3d::Vector3d new $vs]]
    set ps  [mathpt3d::Point3d new $eps]

    test AreEqual [list \
        Test SubtractVector : $value
    ] -body {
        mathpt3d::Equals $ps $sub 1e-9
    } -result 1

}


set TestCase {}

lappend TestCase {{1 2 3} {4 8 16} {-3 -6 -13}}

foreach value $TestCase {

    lassign $value ps1 ps2 evs

    set p1  [mathpt3d::Point3d new $ps1]
    set p2  [mathpt3d::Point3d new $ps2]
    set pv  [mathpt3d::Point3d new $evs]
    set sub [$p1 - $p2]

    test AreEqual [list \
        Test SubtractPoint : $value
    ] -body {
        mathpt3d::Equals $pv $sub 1e-9
    } -result 1

}

set TestCase {}

lappend TestCase {{0 0 0} {1 0 0} {1}}
lappend TestCase {{1 1 1} {2 1 1} {1}}

foreach value $TestCase {

    lassign $value ps1 ps2 d

    set p1  [mathpt3d::Point3d new $ps1]
    set p2  [mathpt3d::Point3d new $ps2]

    set distance [$p1 DistanceTo $p2]

    test AreEqual [list \
        Test DistanceTo : $value
    ] -body {
        expr {$distance == $d}
    } -result 1

}

set TestCase {}

lappend TestCase {{-1 2 -3}}

foreach value $TestCase {

    lassign $value ps

    set p [mathpt3d::Point3d new $ps]

    set tovectopt [[$p ToVector3D] ToPoint3D]

    test AreEqual [list \
        Test ToVectorAndBack : $value
    ] -body {
        mathpt3d::Equals $tovectopt $p 1e-9
    } -result 1

}

cleanupTests