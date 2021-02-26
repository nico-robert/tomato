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


set TestCase {}

lappend TestCase {{1 2 3} {4 5 6} {7 8 9} {-1 -2 -3}}

foreach value $TestCase {

    lassign $value ps xs ys zs

    set origin [mathpt3d::Point3d new $ps]
    set xAxis  [mathvec3d::Vector3d new $xs]
    set yAxis  [mathvec3d::Vector3d new $ys]
    set zAxis  [mathvec3d::Vector3d new $zs]

    set css [mathcsys::Csys new $origin $xAxis $yAxis $zAxis]

    test AreEqual [list \
        Test Equals : origin  > $value
    ] -body {
        mathpt3d::Equals $origin [$css Origin] 1e-4
    } -result 1

    test AreEqual [list \
        Test Equals : xAxis  > $value
    ] -body {
        mathvec3d::Equals $xAxis [$css XAxis] 1e-4
    } -result 1

    test AreEqual [list \
        Test Equals : yAxis  > $value
    ] -body {
        mathvec3d::Equals $yAxis [$css YAxis] 1e-4
    } -result 1

    test AreEqual [list \
        Test Equals : zAxis  > $value
    ] -body {
        mathvec3d::Equals $zAxis [$css ZAxis] 1e-4
    } -result 1

}


set TestCase {}

lappend TestCase  {{1 2 3} {90}  {0 0 1}  {-2 1 3}}
lappend TestCase  {{1 2 3} {90}  {0 0 -1} {2 -1 3}}
lappend TestCase  {{1 2 3} {-90} {0 0 1}  {2 -1 3}}
lappend TestCase  {{1 2 3} {180} {0 0 1}  {-1 -2 3}}
lappend TestCase  {{1 2 3} {270} {0 0 1}  {2 -1 3}}
lappend TestCase  {{1 2 3} {90}  {1 0 0}  {1 -3 2}}
lappend TestCase  {{1 2 3} {-90} {1 0 0}  {1 3 -2}}
lappend TestCase  {{1 2 3} {90} {-1 0 0}  {1 3 -2}}
lappend TestCase  {{1 2 3} {90}  {0 1 0} {3 2 -1}}
lappend TestCase  {{1 2 3} {-90} {0 1 0}  {-3 2 1}}

foreach value $TestCase {

    lassign $value ps as vs eps

    set p [mathpt3d::Point3d new $ps]
    set angle $as

    set css [mathcsys::RotationAngleVector $angle [mathvec3d::Vector3d new $vs]]
    set expected [mathpt3d::Point3d new $eps]
    set rotatedPoint [$css Transform $p]

    test RotationAroundVector [list \
        Test Equals : rotatedPoint  > $value
    ] -body {
        mathpt3d::Equals $expected $rotatedPoint 1e-4
    } -result 1

}

set TestCase {}

lappend TestCase  {{0} {0} {0} {1 2 3} {1 2 3}}
lappend TestCase  {{90} {0} {0} {1 2 3} {-2 1 3}}
lappend TestCase  {{-90} {0} {0} {1 2 3} {2 -1 3}}
lappend TestCase  {{0} {90} {0} {1 2 3} {3 2 -1}}
lappend TestCase  {{0} {-90} {0} {1 2 3} {-3 2 1}}
lappend TestCase  {{0} {0} {90} {1 2 3} {1 -3 2}}
lappend TestCase  {{0} {0} {-90} {1 2 3} {1 3 -2}}

foreach value $TestCase {

    lassign $value yaws pitchs rolls ps eps

    set p [mathpt3d::Point3d new $ps]
    set yaw $yaws
    set pitch $pitchs
    set roll $rolls

    set css [mathcsys::RotationByAngles $yaw $pitch $roll]
    set expected [mathpt3d::Point3d new $eps]

    set rotatedPoint [$css Transform $p]

    test RotationYawPitchRoll [list \
        Test Equals : rotatedPoint  > $value
    ] -body {
        mathpt3d::Equals $expected $rotatedPoint 1e-4
    } -result 1

}


set TestCase {}

lappend TestCase  {{1 2 3} {0 0 1} {1 2 4}}
lappend TestCase  {{1 2 3} {0 0 -1} {1 2 2}}
lappend TestCase  {{1 2 3} {0 0 0} {1 2 3}}
lappend TestCase  {{1 2 3} {0 1 0} {1 3 3}}
lappend TestCase  {{1 2 3} {0 -1 0} {1 1 3}}
lappend TestCase  {{1 2 3} {1 0 0} {2 2 3}}
lappend TestCase  {{1 2 3} {-1 0 0} {0 2 3}}

foreach value $TestCase {

    lassign $value ps vs eps

    set p [mathpt3d::Point3d new $ps]
    set css [mathcsys::Translation [mathvec3d::Vector3d new $vs]]
    set tp [$css Transform $p]
    set expected [mathpt3d::Point3d new $eps]

    test Translation [list \
        Test Equals : tp  > $value
    ] -body {
        mathpt3d::Equals $expected $tp 1e-4
    } -result 1

}


set TestCase {}

lappend TestCase [list $X $X "null"]
lappend TestCase [list $X $X $X]
lappend TestCase [list $X $X $Y]
lappend TestCase [list $X $X $Z]
lappend TestCase [list $X $NegativeX "null"]
lappend TestCase [list $X $NegativeX $Z]
lappend TestCase [list $X $NegativeX $Y]
lappend TestCase [list $X $Y "null"]
lappend TestCase [list $X $Z "null"]
lappend TestCase [list $Y $Y "null"]
lappend TestCase [list $Y $Y $X]
lappend TestCase [list $Y $NegativeY "null"]
lappend TestCase [list $Y $NegativeY $X]
lappend TestCase [list $Y $NegativeY $Z]
lappend TestCase [list $Z $NegativeZ "null"]
lappend TestCase [list $Z $NegativeZ $X]
lappend TestCase [list $Z $NegativeZ $Y]
lappend TestCase [list {1 2 3} {-1 0 -1} "null"]

foreach value $TestCase {

    lassign $value v1s v2s as

    set axis [expr {$as eq "null" ? "null" : [[mathvec3d::Vector3d new $as] Normalized]}]

    set v1 [[mathvec3d::Vector3d new $v1s] Normalized]
    set v2 [[mathvec3d::Vector3d new $v2s] Normalized]

    set actual [mathcsys::RotateTo $v1 $v2 $axis]
    set rv [$actual Transform $v1]

    test RotateToTestV2 [list \
        Test Equals : v2 rv > $value
    ] -body {
        mathvec3d::Equals $v2 $rv 1e-10
    } -result 1

    set actual [mathcsys::RotateTo $v2 $v1 $axis]
    set rv [$actual Transform $v2]

    test RotateToTestV1 [list \
        Test Equals : v1 rv > $value
    ] -body {
        mathvec3d::Equals $v1 $rv 1e-9
    } -result 1    

}

set TestCase {}

lappend TestCase {{1 -5 3} {1 -5 3} {0 0 0} {1 0 0} {0 1 0} {0 0 1}}
lappend TestCase {{1 -5 3} {2 -4 4} {1 1 1} {1 0 0} {0 1 0} {0 0 1}}
lappend TestCase {{1 -5 3} {1 -5 4} {0 0 1} {1 0 0} {0 1 0} {0 0 1}}

foreach value $TestCase {

    lassign $value ps eps ori xaxis yaxis zaxis

    set origin [mathpt3d::Point3d new $ori]
    set xAxis  [mathvec3d::Vector3d new $xaxis]
    set yAxis  [mathvec3d::Vector3d new $yaxis]
    set zAxis  [mathvec3d::Vector3d new $zaxis]    

    set p   [mathpt3d::Point3d new $ps]
    set css [mathcsys::Csys new $origin $xAxis $yAxis $zAxis]

    set actual   [$p TransformBy $css]
    set expected [mathpt3d::Point3d new $eps]

    test TransformPoint [list \
        Test Equals : actual  > $value
    ] -body {
        mathpt3d::Equals $expected $actual 1e-9
    } -result 1    


}



set TestCase {}

lappend TestCase {{1 2 3} {1 2 3} {0 0 0} {1 0 0} {0 1 0} {0 0 1}}
lappend TestCase {{1 2 3} {1 2 3} {3 4 5} {1 0 0} {0 1 0} {0 0 1}}

foreach value $TestCase {

    lassign $value vs evs ori xaxis yaxis zaxis

    set origin [mathpt3d::Point3d new $ori]
    set xAxis  [mathvec3d::Vector3d new $xaxis]
    set yAxis  [mathvec3d::Vector3d new $yaxis]
    set zAxis  [mathvec3d::Vector3d new $zaxis]    

    set v   [mathvec3d::Vector3d new $vs]
    set css [mathcsys::Csys new $origin $xAxis $yAxis $zAxis]

    set actual   [$css Transform $v]
    set expected [mathvec3d::Vector3d new $evs]

    test TransformVector [list \
        Test Equals : actual  > $value
    ] -body {
        mathvec3d::Equals $expected $actual 1e-9
    } -result 1    

}


set css    [mathcsys::RotationAngleVector 90 [mathvec3d::UnitZ]]
set uv     [mathvec3d::UnitX]
set actual [$css Transform $uv]

test TransformUnitVector [list \
    Test Equals : actual  > $value
] -body {
    mathvec3d::Equals [mathvec3d::UnitY] $actual 1e-9
} -result 1


set TestCase {}

lappend TestCase {{0 0 0} {1 0 0} {0 1 0} {0 0 1} {0 0 0} {1 0 0} {0 1 0} {0 0 1}}
lappend TestCase {{0 0 0} {10 0 0} {0 1 0} {0 0 1} {0.1 0 0} {1 0 0} {0 1 0} {0 0 1}}
lappend TestCase {{0 0 0} {10 0 0} {0 1 0} {0 0 1} {1 0 0} {1 0 0} {0 1 0} {0 0 1}}
lappend TestCase {{1 2 -7} {10 0 0} {0 1 0} {0 0 1} {0 0 0} {1 0 0} {0 1 0} {0 0 1}}
lappend TestCase {{1 2 -7} {10 0.1 0} {0 1.2 0.1} {0.1 0 1} {2 5 1} {0.1 2 0} {0.2 -1 0} {0 0.4 1}}

foreach value $TestCase {

    lassign $value fcsso fcssxaxis fcssyaxis fcsszaxis tcsso tcssxaxis tcssyaxis tcsszaxis

    set forigin [mathpt3d::Point3d new $fcsso]
    set fxAxis  [mathvec3d::Vector3d new $fcssxaxis]
    set fyAxis  [mathvec3d::Vector3d new $fcssyaxis]
    set fzAxis  [mathvec3d::Vector3d new $fcsszaxis]

    set torigin [mathpt3d::Point3d new $tcsso]
    set txAxis  [mathvec3d::Vector3d new $tcssxaxis]
    set tyAxis  [mathvec3d::Vector3d new $tcssyaxis]
    set tzAxis  [mathvec3d::Vector3d new $tcsszaxis]

    set fcss [mathcsys::Csys new $forigin $fxAxis $fyAxis $fzAxis]
    set tcss [mathcsys::Csys new $torigin $txAxis $tyAxis $tzAxis]

    set coordinateSystems {}

    lappend coordinateSystems [mathcsys::SetToAlignCoordinateSystems [$fcss Origin] [$fcss XAxis] [$fcss YAxis] [$fcss ZAxis] \
                                                                 [$tcss Origin] [$tcss XAxis] [$tcss YAxis] [$tcss ZAxis]]

    lappend coordinateSystems [mathcsys::CreateMappingCoordinateSystem $fcss $tcss]


    foreach cs $coordinateSystems {

        set aligned [$cs Transform $fcss]

        test SetToAlignCoordinateSystemsTest_Origin [list \
            Test Equals : aligned.Origin  > $value
        ] -body {
            mathpt3d::Equals [$aligned Origin] [$tcss Origin] 1e-9
        } -result 1

        test SetToAlignCoordinateSystemsTest_XAxis [list \
            Test Equals : aligned.XAxis  > $value
        ] -body {
            mathvec3d::Equals [$aligned XAxis] [$tcss XAxis] 1e-9
        } -result 1

        test SetToAlignCoordinateSystemsTest_YAxis [list \
            Test Equals : aligned.YAxis  > $value
        ] -body {
            mathvec3d::Equals [$aligned YAxis] [$tcss YAxis] 1e-9
        } -result 1

        test SetToAlignCoordinateSystemsTest_ZAxis [list \
            Test Equals : aligned.ZAxis  > $value
        ] -body {
            mathvec3d::Equals [$aligned ZAxis] [$tcss ZAxis] 1e-9
        } -result 1
        
    }

}

set TestCase {}

lappend TestCase [list $X $Y $Z]
lappend TestCase [list $NegativeX $Y $Z]
lappend TestCase [list $NegativeX $Y "null"]
lappend TestCase [list $X $Y "null"]
lappend TestCase [list $X $Y {0 0 1}]
lappend TestCase [list {1 -1 1} {0 1 1} "null"]
lappend TestCase [list $X $Z $Y]

foreach value $TestCase {

    lassign $value vs vts axisString

    set v  [[mathvec3d::Vector3d new $vs] Normalized]
    set vt [[mathvec3d::Vector3d new $vts] Normalized]

    set axis "null"

    if {$axisString ne "null"} {
         set axis [[mathvec3d::Vector3d new $axisString] Normalized]
    }

    set cs [mathcsys::RotateTo $v $vt $axis]
    set rv [$cs Transform $v]


    test SetToRotateToTest [list \
        Test Equals : rv  > $value
    ] -body {
        mathvec3d::Equals $vt $rv 1e-9
    } -result 1    

    set invert [$cs Invert]
    set rotateBack [$invert Transform $rv]


    test SetToRotateToTestBack [list \
        Test Equals : v rotateBack  > $value
    ] -body {
        mathvec3d::Equals $v $rotateBack 1e-9
    } -result 1

    set cs [mathcsys::RotateTo $vt $v $axis]
    set rotateBack [$cs Transform $rv]

    test SetToRotateToReTestBack [list \
        Test Equals : v re rotateBack  > $value
    ] -body {
        mathvec3d::Equals $v $rotateBack 1e-9
    } -result 1

}


set TestCase {}

lappend TestCase {{1 2 -7} {10 0 0} {0 1 0} {0 0 1} {0 0 0} {1 0 0} {0 1 0} {0 0 1}}

foreach value $TestCase {

    lassign $value fcsso fcssxaxis fcssyaxis fcsszaxis tcsso tcssxaxis tcssyaxis tcsszaxis

    set forigin [mathpt3d::Point3d new $fcsso]
    set fxAxis  [mathvec3d::Vector3d new $fcssxaxis]
    set fyAxis  [mathvec3d::Vector3d new $fcssyaxis]
    set fzAxis  [mathvec3d::Vector3d new $fcsszaxis]

    set torigin [mathpt3d::Point3d new $tcsso]
    set txAxis  [mathvec3d::Vector3d new $tcssxaxis]
    set tyAxis  [mathvec3d::Vector3d new $tcssyaxis]
    set tzAxis  [mathvec3d::Vector3d new $tcsszaxis]

    set cs1 [mathcsys::Csys new $forigin $fxAxis $fyAxis $fzAxis]
    set cs2 [mathcsys::Csys new $torigin $txAxis $tyAxis $tzAxis]

    set actual [$cs1 Transform $cs2]
    set expected [tomato::mathcsys::Csys new [[$cs1 BaseClass] Multiply [$cs2 BaseClass]]]

    test Transform [list \
        Test Equals : actual expected Transform  > $value
    ] -body {
        mathcsys::Equals $actual $expected 1e-9
    } -result 1

}


cleanupTests