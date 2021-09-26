lappend auto_path [file dirname [file dirname [info script]]]

package require tomato
package require tcltest

namespace import ::tcltest::*
namespace path tomato


# Triangle Equal Test
set p1 [mathpt3d::Point3d new {-3 0 4}]
set p2 [mathpt3d::Point3d new {4 0 5}]
set p3 [mathpt3d::Point3d new {1 0 -4}]

set t1 [mathtriangle::Triangle new $p1 $p2 $p3]
set t2 [mathtriangle::Triangle new $p1 $p3 $p2]
set t3 [mathtriangle::Triangle new $p3 $p2 $p1]

test AreEqual {
    Test Equals t1 == t2
} -body {
     mathtriangle::Equals $t1 $t2 1e-9
} -result 1

test AreEqual {
    Test Equals t1 == t3
} -body {
     mathtriangle::Equals $t1 $t3 1e-9
} -result 1

test AreEqual {
    Test Equals t3 == t2
} -body {
     mathtriangle::Equals $t3 $t2 1e-9
} -result 1


# Triangle Area Test
set p1 [mathpt3d::Point3d new {0 0 0}]
set p2 [mathpt3d::Point3d new {1 0 0}]
set p3 [mathpt3d::Point3d new {0 1 0}]

set t [mathtriangle::Triangle new $p1 $p2 $p3]

test AreEqual {
    Test Aera
} -body {
     expr {[$t Aera] == 0.5}
} -result 1



# Triangle Bisector Test
set p1 [mathpt3d::Point3d new {0 0 0}]
set p2 [mathpt3d::Point3d new {1 0 0}]
set p3 [mathpt3d::Point3d new {0 1 0}]

set t [mathtriangle::Triangle new $p1 $p2 $p3]
set line1 [mathline3d::Line3d new [mathpt3d::Point3d new $p1] [mathpt3d::Point3d new {0.5 0.5 0}]]

test AreEqual {
    Test BisectorA
} -body {
     tomato::mathline3d::Equals [$t BisectorA] $line1 1e-9
} -result 1

set t [mathtriangle::Triangle new $p2 $p3 $p1]

test AreEqual {
    Test BisectorC
} -body {
     tomato::mathline3d::Equals [$t BisectorC] $line1 1e-4
} -result 1

set t [mathtriangle::Triangle new $p3 $p1 $p2]

test AreEqual {
    Test BisectorB
} -body {
     tomato::mathline3d::Equals [$t BisectorB] $line1 1e-9
} -result 1


# Triangle Centroid Test
set p1 [mathpt3d::Point3d new {0 0 0}]
set p2 [mathpt3d::Point3d new {14 0 0}]
set p3 [mathpt3d::Point3d new {4 12 0}]

set t [mathtriangle::Triangle new $p1 $p2 $p3]
set p [mathpt3d::Point3d new {6 4 0}]

test AreEqual {
    Test Centroid
} -body {
    mathpt3d::Equals [$t Centroid] $p 1e-9
} -result 1


# Triangle Intersection With Line / Ray Test
set p1 [mathpt3d::Point3d new {0 0 0}]
set p2 [mathpt3d::Point3d new {6 0 0}]
set p3 [mathpt3d::Point3d new {0 6 0}]

set t [mathtriangle::Triangle new $p1 $p2 $p3]
set line1 [mathline3d::Line3d new [mathpt3d::Point3d new] [mathpt3d::Point3d new {1 0 0}]]

test AreEqual {
    Test Line coincides with one side
} -body {
    $t IntersectionWith $line1
} -returnCodes {error} -result "Line lies in the plane"

set ray [mathray3d::Ray3d new [mathpt3d::Point3d new {-10 -10 1}] [mathvec3d::Vector3d new {0 0 1}]]

test AreEqual {
    Test Ray triangle
} -body {
    $t IntersectionWith $ray
} -result ""

set ray [mathray3d::Ray3d new [mathpt3d::Point3d new {1 1 1}] [mathvec3d::Vector3d new {0 0 1}]]
set p [mathpt3d::Point3d new {1 1 0}]

test AreEqual {
    Test IntersectionWith Ray Triangle
} -body {
    mathpt3d::Equals [$t IntersectionWith $ray] $p 1e-9
} -result 1

cleanupTests