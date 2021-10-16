lappend auto_path [file dirname [file dirname [info script]]]

package require tomato
package require tcltest

namespace import ::tcltest::*
namespace path tomato


proc LogTests {} {

    set q0  [mathquat::Quaternion new {1 0 0 0}]
    set q00 [mathquat::Quaternion new {1 0 0 0}]
    set q1  [mathquat::Quaternion new {0 0 0 1}]
    set q10 [mathquat::Quaternion new [list 0 0 0 [expr {Pi() / 2.0}]]]
    set q2  [mathquat::Quaternion new {1 1 1 1}]
    set q20 [mathquat::Quaternion new [list \
                                    [expr {log(2)}] \
                                    [expr {(1 / sqrt(3)) * (Pi() / 3.0)}] \
                                    [expr {(1 / sqrt(3)) * (Pi() / 3.0)}] \
                                    [expr {(1 / sqrt(3)) * (Pi() / 3.0)}] \
                                    ]]
    lappend tests [list $q0 $q00]
    lappend tests [list $q1 $q10]
    lappend tests [list $q2 $q20]

    return $tests
    
}

proc NormTests {} {

    lappend TestCaseData {0 0 0 0 0.0}
    lappend TestCaseData {1 1 1 1 2.0}
    lappend TestCaseData [list 1 1 1 0 [expr {sqrt(3)}]]
    lappend TestCaseData [list 1 2 3 4 [expr {sqrt(30)}]]
    lappend TestCaseData [list 5 6 7 8 [expr {sqrt(174)}]]

    return $TestCaseData
    
}

proc DivisionTests {} {

    set qexpected [mathquat::Quaternion new {1 0 0 0}]

    for {set i 0} {$i < 10} {incr i} {

        set a [list [expr {rand()}] [expr {rand()}] [expr {rand()}] [expr {rand()}]]

        lassign $a a0 a1 a2 a3

        set test1 [mathquat::Quaternion new $a0 $a1 $a2 $a3]
        set test2 [mathquat::Quaternion new $a0 $a1 $a2 $a3]

        lappend TestCaseData [list $test1 $test2 $qexpected]
        
    }

    lappend TestCaseData [list [mathquat::Quaternion new 0 0 0 0] [mathquat::Quaternion new 1 1 1 1] [mathquat::Quaternion new 0 0 0 0]]
    lappend TestCaseData [list [mathquat::Quaternion new 4 4 4 4] [mathquat::Quaternion new 2 2 2 2] [mathquat::Quaternion new 2 0 0 0]]
    lappend TestCaseData [list [mathquat::Quaternion new 9 9 9 9] [mathquat::Quaternion new 3 3 3 3] [mathquat::Quaternion new 3 0 0 0]]
    lappend TestCaseData [list [mathquat::Quaternion new -1 -1 -1 -1] [mathquat::Quaternion new 0 0 0 0] [mathquat::Quaternion new "Inf" 0 0 0]]
    lappend TestCaseData [list [mathquat::Quaternion new 1 1 1 1] [mathquat::Quaternion new 0 0 0 0] [mathquat::Quaternion new "Inf" 0 0 0]]
    lappend TestCaseData [list [mathquat::Quaternion new 0 0 0 0] [mathquat::Quaternion new 0 0 0 0] [mathquat::Quaternion new "NaN" 0 0 0]]

    return $TestCaseData

}

proc CanNormalizeTests {} {

    set norm [expr {sqrt(30)}]
    lappend TestCaseData [list 1 1 1 1 [mathquat::Quaternion new [expr {1.0 / 2}] [expr {1.0 / 2}] [expr {1.0 / 2}] [expr {1.0 / 2}]]]
    lappend TestCaseData [list 1 2 3 4 [mathquat::Quaternion new [expr {1.0 / $norm}] [expr {2.0 / $norm}] [expr {3.0 / $norm}] [expr {4.0 / $norm}]]]
    lappend TestCaseData [list 0 0 0 0 [mathquat::Quaternion new 0 0 0 0]]

    return $TestCaseData
    
}

proc CanInverseTests {} {

    lappend TestCaseData [list 0 0 0 0 [mathquat::Quaternion new 0 0 0 0]]
    lappend TestCaseData [list 1 2 3 4 [mathquat::Quaternion new [expr {1.0 / 30}] [expr {-2.0 / 30}] [expr {-3.0 / 30}] [expr {-4.0 / 30}]]]
    lappend TestCaseData [list 1 1 0 0 [mathquat::Quaternion new {0.5 -0.5 0 0}]]

    return $TestCaseData
    
}

proc CanCalculateDistance {} {

    set q1 [mathquat::Quaternion new {0 0 0 1}]
    set q2 [mathquat::Quaternion new {1 1 1 0}]
    set q3 [mathquat::Quaternion new {0 0 0 0}]
    set q4 [mathquat::Quaternion new {9 9 9 1}]
    set q5 [mathquat::Quaternion new {2 3 4 5}]


    lappend tests [list $q1 $q2 2]
    lappend tests [list $q2 $q1 2]
    lappend tests [list $q3 $q1 [$q1 Norm]]
    lappend tests [list $q3 $q2 [$q2 Norm]]
    lappend tests [list $q4 $q2 [expr {sqrt((8 * 8) + (8 * 8) + (8 * 8) + 1)}]]
    lappend tests [list $q5 $q2 [expr {sqrt(1 + (2 * 2) + (3 * 3) + (5 * 5))}]]

    return $tests
    
}

proc CanCalculatePower {} {

    set q0  [mathquat::Quaternion new {0 0 0 0}]
    set q00 [mathquat::Quaternion new {0 0 0 0}]

    lappend TestCaseData [list $q0 3.981 $q00]

    set q1  [mathquat::Quaternion new {1 0 0 0}]
    set q11 [mathquat::Quaternion new {1 0 0 0}]

    lappend TestCaseData [list $q1 3.981 $q11]

    set q2  [[mathquat::Quaternion new {1 1 1 1}] Normalized]

    set q29 [[[[[[[[$q2 * $q2] * $q2] * $q2] * $q2] * $q2] * $q2] * $q2] * $q2]
    set q23 [[$q2 * $q2] * $q2]

    lappend TestCaseData [list $q2 9.0 $q29]
    lappend TestCaseData [list $q2 3.0 $q23]

    set q3  [[mathquat::Quaternion new {2 2 2 2}] Normalized]
    set q39 [[[[[[[[$q3 * $q3] * $q3] * $q3] * $q3] * $q3] * $q3] * $q3] * $q3]

    lappend TestCaseData [list $q3 9.0 $q39]


    return $TestCaseData
    
}

proc CanCalculatePowerInt {} {

    set q0 [mathquat::Quaternion new {0 0 0 0}]
    set q1 [mathquat::Quaternion new {1 0 0 0}]
    set q2 [mathquat::Quaternion new {1 1 1 1}]
    set q3 [mathquat::Quaternion new {2 2 2 2}]
    set q4 [mathquat::Quaternion new {1 2 3 4}]
    set q5 [mathquat::Quaternion new {3 2 1 0}]

    set q20 [[[[[[[[$q2 * $q2] * $q2] * $q2] * $q2] * $q2] * $q2] * $q2] * $q2]
    set q21 [[$q2 * $q2] * $q2]
    set q23 [[[[[[[[$q3 * $q3] * $q3] * $q3] * $q3] * $q3] * $q3] * $q3] * $q3]
    set q24 [[[[[[[[$q4 * $q4] * $q4] * $q4] * $q4] * $q4] * $q4] * $q4] * $q4]
    set q25 [[[[[[[[$q5 * $q5] * $q5] * $q5] * $q5] * $q5] * $q5] * $q5] * $q5]

    lappend TestCaseData [list $q0 9 $q0]
    lappend TestCaseData [list $q1 9 $q1]
    lappend TestCaseData [list $q2 9 $q20]
    lappend TestCaseData [list $q2 3 $q21]
    lappend TestCaseData [list $q3 9 $q23]
    lappend TestCaseData [list $q4 9 $q24]
    lappend TestCaseData [list $q5 9 $q25]

    return $TestCaseData
    
}


set TestTolerance 0.000001

set a1 [mathquat::Quaternion new 1 2 3 4]

test AreEqual [list \
    Test == a1.Real
] -body {
    expr {[$a1 Real] == 1}
} -result 1

test AreEqual [list \
    Test == a1.ImagX
] -body {
    expr {[$a1 ImagX] == 2}
} -result 1

test AreEqual [list \
    Test == a1.ImagY
] -body {
    expr {[$a1 ImagY] == 3}
} -result 1

test AreEqual [list \
    Test == a1.ImagZ
] -body {
    expr {[$a1 ImagZ] == 4}
} -result 1

set v1 [mathquat::Quaternion new {1 2 3 4}]

test AreEqual [list \
    Test == v1.Real
] -body {
    expr {[$v1 Real] == 1}
} -result 1

test AreEqual [list \
    Test == v1.ImagX
] -body {
    expr {[$v1 ImagX] == 2}
} -result 1

test AreEqual [list \
    Test == v1.ImagY
] -body {
    expr {[$v1 ImagY] == 3}
} -result 1

test AreEqual [list \
    Test == v1.ImagZ
] -body {
    expr {[$v1 ImagZ] == 4}
} -result 1


set norm [expr {sqrt(1 + (2 * 2) + (3 * 3) + (4 * 4))}]

test AreEqual [list \
    Test == a1.Norm
] -body {
    expr {([$a1 Norm] - $norm) < $TestTolerance}
} -result 1

test AreEqual [list \
    Test == a1.NormSquared
] -body {
    expr {(($norm * $norm) - [$a1 NormSquared]) < $TestTolerance}
} -result 1


test AreEqual [list \
    quaternion == a1 Vector
] -body {
    mathquat::Equals [mathquat::Quaternion new {0 2 3 4}] [$a1 Vector] $TestTolerance
} -result 1

test AreEqual [list \
    quaternion == a1 Scalar
] -body {
    mathquat::Equals [mathquat::Quaternion new {1 0 0 0}] [$a1 Scalar] $TestTolerance
} -result 1

set norm2 [expr {sqrt((2 * 2) + (3 * 3) + (4 * 4))}]

test AreEqual [list \
    quaternion norm == a1 Normalized
] -body {
    mathquat::Equals [mathquat::Quaternion new [list [expr {1 / $norm}] \
                                                     [expr {2 / $norm}] \
                                                     [expr {3 / $norm}] \
                                                     [expr {4 / $norm}]]] [$a1 Normalized] $TestTolerance
} -result 1

test AreEqual [list \
    quaternion norm2 == a1 NormalizedVector
] -body {
    mathquat::Equals [mathquat::Quaternion new [list [expr {0}] \
                                                     [expr {2 / $norm2}] \
                                                     [expr {3 / $norm2}] \
                                                     [expr {4 / $norm2}]]] [$a1 NormalizedVector] $TestTolerance
} -result 1


set arg [expr {acos([$a1 Real] / [$a1 Norm])}]

test AreEqual [list \
    arg == a1 Arg
] -body {
    expr {($arg - [$a1 Arg]) < $TestTolerance}
} -result 1


test AreEqual [list \
    IsUnitQuaternion
] -body {
    expr {[[mathquat::Quaternion new {0.5 0.5 0.5 0.5}] IsUnitQuaternion]}
} -result 1


test AreEqual [list \
    Add
] -body {
    mathquat::Equals [[mathquat::Quaternion new {1 2 3 4}] + [mathquat::Quaternion new {1 2 3 4}]] \
                     [mathquat::Quaternion new {2 4 6 8}] \
                     $TestTolerance
} -result 1

test AreEqual [list \
    Add1
] -body {
    mathquat::Equals [[mathquat::Quaternion new {1 2 3 4}] + 1] \
                     [mathquat::Quaternion new {2 2 3 4}] \
                     $TestTolerance
} -result 1

test AreEqual [list \
    Add2
] -body {
    mathquat::Equals [[mathquat::Quaternion new {0 0 0 0}] + $::tomato::mathquat::Zero] \
                     $::tomato::mathquat::Zero \
                     $TestTolerance
} -result 1


test AreEqual [list \
    Sub
] -body {
    mathquat::Equals [[mathquat::Quaternion new {1 2 3 4}] - [mathquat::Quaternion new {1 2 3 4}]] \
                     $::tomato::mathquat::Zero \
                     $TestTolerance
} -result 1


test AreEqual [list \
    Sub1
] -body {
    mathquat::Equals [[mathquat::Quaternion new {0 0 0 0}] - [mathquat::Quaternion new {1 2 3 4}]] \
                     [mathquat::Quaternion new {-1 -2 -3 -4}] \
                     $TestTolerance
} -result 1

test AreEqual [list \
    Sub2
] -body {
    mathquat::Equals [[mathquat::Quaternion new {1 2 3 4}] - 1] \
                     [mathquat::Quaternion new {0 2 3 4}] \
                     $TestTolerance
} -result 1


test AreEqual [list \
    Mul
] -body {
    mathquat::Equals [[mathquat::Quaternion new {3 1 -2 1}] * [mathquat::Quaternion new {2 -1 2 3}]] \
                     [mathquat::Quaternion new {8 -9 -2 11}] \
                     $TestTolerance
} -result 1

test AreEqual [list \
    Mul1
] -body {
    mathquat::Equals [[mathquat::Quaternion new {3 1 -2 1}] * 1] \
                     [mathquat::Quaternion new {3 1 -2 1}] \
                     $TestTolerance
} -result 1

test AreEqual [list \
    Div
] -body {
    mathquat::Equals [[mathquat::Quaternion new {2 2 2 2}] / 2] \
                     [mathquat::Quaternion new {1 1 1 1}] \
                     $TestTolerance
} -result 1

test AreEqual [list \
    Div1
] -body {
    mathquat::Equals [[mathquat::Quaternion new {0 0 0 0}] / 2] \
                     [mathquat::Quaternion new {0 0 0 0}] \
                     $TestTolerance
} -result 1


test AreEqual [list \
    Negate
] -body {
    mathquat::Equals [[mathquat::Quaternion new {1 2 3 4}] Negate] \
                     [mathquat::Quaternion new {-1 -2 -3 -4}] \
                     $TestTolerance
} -result 1

test AreEqual [list \
    Negate1
] -body {
    mathquat::Equals [[mathquat::Quaternion new {0 0 0 0}] Negate] \
                     [mathquat::Quaternion new {0 0 0 0}] \
                     $TestTolerance
} -result 1

test AreEqual [list \
    ==
] -body {
    [mathquat::Quaternion new {1 0 0 0}] == 1 $TestTolerance
} -result 1

test AreEqual [list \
    !=
] -body {
    [mathquat::Quaternion new {1 0 0 1}] != 1 $TestTolerance
} -result 1


foreach quat [LogTests] {

    lassign $quat q expected

    set log [$q Log]

    test AreEqual [list \
        Log[incr l]
    ] -body {
        mathquat::Equals $log $expected $TestTolerance
    } -result 1

}

foreach values [NormTests] {

    lassign $values real x y z expected

    set quat [mathquat::Quaternion new $real $x $y $z]

    test AreEqual [list \
        Norm[incr n]
    ] -body {
        expr {abs([$quat Norm] - $expected) <  $TestTolerance}
    } -result 1

}

foreach values [DivisionTests] {

    lassign $values q1 q2 expected

    set result [$q1 / $q2]

    test AreEqual [list \
        Div[incr d]
    ] -body {
        mathquat::Equals $result $expected $TestTolerance
    } -result 1

}

foreach values [CanNormalizeTests] {

    lassign $values a b c d expected

    set quat [mathquat::Quaternion new $a $b $c $d]

    test AreEqual [list \
        Normalize[incr nr]
    ] -body {
        mathquat::Equals [$quat Normalized] $expected $TestTolerance
    } -result 1

}


foreach values [CanInverseTests] {

    lassign $values a b c d expected

    set quat [mathquat::Quaternion new $a $b $c $d]

    test AreEqual [list \
        Inverse[incr in]
    ] -body {
        mathquat::Equals [$quat Inversed] $expected $TestTolerance
    } -result 1

}

foreach values [CanCalculateDistance] {

    lassign $values q1 q2 expected

    test AreEqual [list \
        Distance[incr dis]
    ] -body {
        expr {abs([$q1 Distance $q2] - $expected) < $TestTolerance}
    } -result 1

}


foreach values [CanCalculatePower] {

    lassign $values q1 double expected

    set result [$q1 ^ $double]

    test AreEqual [list \
        DoublePower[incr dp]
    ] -body {
        mathquat::Equals $result $expected $TestTolerance
    } -result 1

}

foreach values [CanCalculatePowerInt] {

    lassign $values q1 int expected

    set result [$q1 ^ $int]

    test AreEqual [list \
        InfPower[incr ip]
    ] -body {
        mathquat::Equals $result $expected $TestTolerance
    } -result 1

}

lappend TestCase {1 1 1 1}
lappend TestCase {1 2 3 4}
lappend TestCase {0 0 0 0}
lappend TestCase {1 0 0 0}
lappend TestCase {0 1 0 0}
lappend TestCase {0 0 1 0}
lappend TestCase {0 0 0 1}

foreach values $TestCase {

    lassign $values a b c d

    set quat        [mathquat::Quaternion new $a $b $c $d]
    set quat180     [mathquat::Quaternion new {0 0 1 0}]
    set nonrotation [mathquat::Quaternion new {0 0 0 0}]
    set onerotation [mathquat::Quaternion new {1 0 0 0}]

    test AreEqual [list \
        Rotate[incr r]
    ] -body {
        mathquat::Equals [$quat180 * $quat] [$quat RotateRotationQuaternion $quat180] $TestTolerance
    } -result 1

    test AreEqual [list \
        Rotate[incr r]
    ] -body {
        mathquat::Equals [$onerotation * $quat] [$quat RotateRotationQuaternion $onerotation] $TestTolerance
    } -result 1

    if {[$quat IsUnitQuaternion]} {

        test AreEqual [list \
            Rotate[incr r]
        ] -body {
            mathquat::Equals [[$quat * $quat180] * [$quat Conjugate]] [$quat RotateUnitQuaternion $quat180] $TestTolerance
        } -result 1

        test AreEqual [list \
            Rotate[incr r]
        ] -body {
            mathquat::Equals [[$quat * $onerotation] * [$quat Conjugate]] [$quat RotateUnitQuaternion $onerotation] $TestTolerance
        } -result 1

    } else {
        
        test Exception [list \
            Rotate[incr r]
        ] -body {
            catch {$quat RotateUnitQuaternion $quat180}
        } -result 1

        test Exception [list \
            Rotate[incr r]
        ] -body {
            catch {$quat RotateUnitQuaternion $onerotation}
        } -result 1

        test Exception [list \
            Rotate[incr r]
        ] -body {
            catch {$quat RotateUnitQuaternion $nonrotation}
        } -result 1

    }

}

set TestCase {}

set q  [mathquat::Quaternion new -axis {1 1 1} -angle 120]
set q2 [mathquat::Quaternion new -axis {1 0 0} -angle -180]
set q3 [mathquat::Quaternion new -axis {1 0 0} -angle 180]

foreach value {1 3.5 -12 -0.0005} {

    set mypoint [ mathpt3d::Point3d new $value 0 0]
    set rp       [$q Rotate $mypoint]
    set expected [mathpt3d::Point3d new 0 $value 0]

    test AreEqual [list \
        Test Rotate : $value
    ] -body {
        mathpt3d::Equals $rp $expected 1e-9
    } -result 1

    test AreEqual [list \
        Test Rotate1 : $value
    ] -body {
        mathpt3d::Equals [$q2 Rotate $mypoint] [$q3 Rotate $mypoint] 1e-9
    } -result 1
    
}

cleanupTests

