lappend auto_path [file dirname [file dirname [info script]]]

package require tomato
package require tcltest

namespace import ::tcltest::*
namespace path tomato

set TestCase {}

lappend TestCase {{0 0 0} {1 -1 1} {1 -1 1}}

foreach value $TestCase {

    lassign $value p1s p2s evs

    set l         [mathline3d::Line3d new [mathpt3d::Point3d new $p1s] [mathpt3d::Point3d new $p2s]]
    set expected [[mathvec3d::Vector3d new $evs] Normalized]

    test AreEqual [list \
        Test Equals expected l.Direction : $value 
    ] -body {
         mathvec3d::Equals [$l Direction] $expected 1e-9
    } -result 1

}

set TestCase {}

lappend TestCase {{0 0 0} {1 -1 1} {0 0 0} {1 0 0} {0 0 0} {0 -1 1}}

foreach value $TestCase {

    lassign $value p1s p2s rootPoint unitVector ep1s ep2s

    set line  [mathline3d::Line3d new [mathpt3d::Point3d new $p1s] [mathpt3d::Point3d new $p2s]]
    set plane [mathplane::Plane new [mathpt3d::Point3d new $rootPoint] [mathvec3d::Vector3d new $unitVector]]

    set expected [mathline3d::Line3d new [mathpt3d::Point3d new $ep1s] [mathpt3d::Point3d new $ep2s]]
    set lineproject [$line ProjectOn $plane]

    test ProjectOn [list \
        Test ProjectOn expected lineproject : $value 
    ] -body {
         mathline3d::Equals $lineproject $expected 1e-9
    } -result 1

}

set TestCase {}

lappend TestCase {{0 0 0} {1 -2 3} {3.741657}}

foreach value $TestCase {

    lassign $value p1s p2s expected

    set line  [mathline3d::Line3d new [mathpt3d::Point3d new $p1s] [mathpt3d::Point3d new $p2s]]

    test ProjectOn [list \
        Test Length line : $value 
    ] -body {
         expr {([$line Length] - $expected) < 1e-6}
    } -result 1

}

set TestCase {}

lappend TestCase {{0 0 0} {1 0 0} {0.5 1 0} True {0.5 0 0}}
lappend TestCase {{0 0 0} {1 0 0} {0.5 1 0} False {0.5 0 0}}
lappend TestCase {{0 0 0} {1 0 0} {2 1 0} True {1 0 0}}
lappend TestCase {{0 0 0} {1 0 0} {2 1 0} False {2 0 0}}
lappend TestCase {{0 0 0} {1 0 0} {-2 1 0} True {0 0 0}}
lappend TestCase {{0 0 0} {1 0 0} {-2 1 0} False {-2 0 0}}

foreach value $TestCase {

    lassign $value p1s p2s ps mustStartFromLine sps

    set l [mathline3d::Line3d new [mathpt3d::Point3d new $p1s] [mathpt3d::Point3d new $p2s]]
    set p [mathpt3d::Point3d new $ps]
    set sp [mathpt3d::Point3d new $sps]

    set actual [$l LineTo $p $mustStartFromLine]

    test LineToTest [list \
        Test LineToTest line : $value 
    ] -body {
         mathpt3d::Equals $sp [$actual StartPoint] 1e-6
    } -result 1

}


set TestCase {}

lappend TestCase {{0 0 0} {0 0 1} {0 0 0} {0 0 0}}
lappend TestCase {{0 0 0} {0 0 1} {0 0 1} {0 0 1}}
lappend TestCase {{0 0 0} {0 0 1} {1 0 0.25} {0 0 0.25}}
lappend TestCase {{0 0 0} {0 0 1} {0 0 -1} {0 0 0}}
lappend TestCase {{0 0 0} {0 0 1} {0 0 3} {0 0 1}}

foreach value $TestCase {

    lassign $value start end point expected

    set l [mathline3d::Line3d new [mathpt3d::Point3d new $start] [mathpt3d::Point3d new $end]]
    set p [mathpt3d::Point3d new $point]
    set e [mathpt3d::Point3d new $expected]

    set closepointto [$l ClosestPointTo $p True] 

    test ClosestPointToWithinSegment [list \
        Test ClosestPointToWithinSegment line : $value 
    ] -body {
         mathpt3d::Equals $closepointto $e 1e-6
    } -result 1

}


set TestCase {}

lappend TestCase {{0 0 0} {0 0 1} {0 0 0} {0 0 0}}
lappend TestCase {{0 0 0} {0 0 1} {0 0 1} {0 0 1}}
lappend TestCase {{0 0 0} {0 0 1} {1 0 0.25} {0 0 0.25}}
lappend TestCase {{0 0 0} {0 0 1} {0 0 -1} {0 0 -1}}
lappend TestCase {{0 0 0} {0 0 1} {0 0 3} {0 0 3}}

foreach value $TestCase {

    lassign $value start end point expected

    set l [mathline3d::Line3d new [mathpt3d::Point3d new $start] [mathpt3d::Point3d new $end]]
    set p [mathpt3d::Point3d new $point]
    set e [mathpt3d::Point3d new $expected]

    set closepointto [$l ClosestPointTo $p False] 

    test ClosestPointToOutsideSegment [list \
        Test ClosestPointToOutsideSegment line : $value
    ] -body {
         mathpt3d::Equals $closepointto $e 1e-6
    } -result 1

}


set TestCase {}

lappend TestCase {{0 0 0} {0 0 1} {0 1 1} {0 1 2} 1}
lappend TestCase {{0 0 0} {0 0 -1} {0 1 1} {0 1 2} 1}
lappend TestCase {{0 0 0} {0 0.5 -1} {0 1 1} {0 1 2} 0}
lappend TestCase {{0 0 0} {0 0.00001 -1.0000} {0 1 1} {0 1 2} 0}

foreach value $TestCase {

    lassign $value s1 e1 s2 e2 expected

    set line1 [mathline3d::Line3d new [mathpt3d::Point3d new $s1] [mathpt3d::Point3d new $e1]]
    set line2 [mathline3d::Line3d new [mathpt3d::Point3d new $s2] [mathpt3d::Point3d new $e2]]

    test IsParallelToWithinDoubleTol [list \
        Test IsParallelToWithinDoubleTol line : $value
    ] -body {
        $line1 IsParallelTo $line2
    } -result $expected

}

set TestCase {}

lappend TestCase {{0 0 0} {1 0 0} {1 1 1} {2 1 1} {0 0 0} {0 1 1}}
lappend TestCase {{0 0 0} {1 0 0} {2 -1 1} {2 0 0} {2 0 0} {2 0 0}}
lappend TestCase [list "0.3097538 3.0725982 3.9317042"  "1.3945620 6.4927958 2.1094821"  "2.4486204 5.1947760 6.3369721"  "8.4010954 9.5691708 5.1665254"  "-0.1891954 1.4995044 4.7698213"  "-0.7471721 2.8462306 6.9653670"]
lappend TestCase [list "6.7042836 5.1490163 0.3655590"  "7.6915457 0.8511235 0.8627290"  "0.6890053 6.6207933 3.4147472"  "5.6116149 1.7160727 5.4461589"  "7.5505158 1.4650754 0.7917085"  "5.7356234 1.5925149 5.4973334"]
lappend TestCase [list "2.9663973 7.1338954 9.7732130"  "6.4625826 8.7716408 3.7015737"  "1.8924447 4.9060507 1.8755412"  "1.9542505 5.8440396 8.2251863"  "1.8254726 6.5994432 11.7545962"  "1.9889190 6.3701828 11.7868723"]
lappend TestCase [list "7.3107741 0.0835261 3.0516366"  "1.0013621 9.6730070 3.6824080"  "3.2195097 0.8726049 1.0448256"  "4.5620367 8.6714351 3.3311693"  "3.7856774 5.4412119 3.4040514"  "4.0462563 5.6752319 2.4527875"]
lappend TestCase [list "6.8171425 2.0728553 1.9235196"  "3.0360117 0.0371047 0.5410118"  "0.4798755 2.8536110 0.4402877"  "9.4038162 7.5597521 0.3068954"  "2.9867513 0.0105830 0.5230005"  "1.2671009 3.2687632 0.4285205"]
lappend TestCase [list "0.9826196 9.8736629 3.7966845"  "3.9607685 8.7036678 0.3921888"  "0.2333178 4.9282166 5.6478261"  "5.8182917 0.7224496 6.8152397"  "-0.7871493 10.5689341 5.8198105"  "-3.0149659 7.3743380 4.9688451"]
lappend TestCase [list "3.1369768 8.4887731 0.1371429"  "4.9427402 3.5584831 9.4250139"  "1.0628142 7.4582519 3.7246752"  "3.7045709 0.1811190 4.7211734"  "3.8813087 6.4565178 3.9655839"  "1.7121301 5.6696095 3.9696039"]
lappend TestCase [list "8.7598151 0.2378638 3.0353259"  "0.5266014 9.6548588 2.7893143"  "1.8918146 3.4742242 7.0646539"  "7.3796941 7.0882850 4.4899767"  "4.5791946 5.0195789 2.9104073"  "5.3106500 5.7257093 5.4606833"]
lappend TestCase [list "7.6132801 6.8593303 3.7729401"  "7.7434088 2.0184714 6.0037938"  "4.1910423 0.6022826 6.7846734"  "1.6554785 3.0341358 8.7351072"  "7.8041730 -0.2419887 7.0455007"  "5.8721457 -1.0100597 5.4915169"]
lappend TestCase [list "0.3818483 0.4893437 8.1438438"  "4.6619509 7.8881811 4.7600744"  "0.7792658 4.6454081 8.3927247"  "0.2002105 7.4120903 3.5542593"  "2.2611504 3.7380159 6.6581026"  "0.6866122 5.0880999 7.6185307"]

foreach value $TestCase {

    lassign $value s1 e1 s2 e2 cp1 cp2

    set line1 [mathline3d::Line3d new [mathpt3d::Point3d new $s1] [mathpt3d::Point3d new $e1]]
    set line2 [mathline3d::Line3d new [mathpt3d::Point3d new $s2] [mathpt3d::Point3d new $e2]]

    set result [$line1 ClosestPointsBetween $line2]

    lassign $result Item1 Item2

    test ClosestPointsBetween1 [list \
        Test ClosestPointsBetween 1 line : $value
    ] -body {
         mathpt3d::Equals [mathpt3d::Point3d new $cp1] $Item1 1e-6
    } -result 1

    test ClosestPointsBetween2 [list \
        Test ClosestPointsBetween 2 line : $value
    ] -body {
         mathpt3d::Equals [mathpt3d::Point3d new $cp2] $Item2 1e-6
    } -result 1

}


set TestCase {}

lappend TestCase [list "0 0 0"  "1 0 0"  "0.5 1 0"  "1.5 1 0"  "1 0 0"  "1 1 0"] ; # Parallel case
lappend TestCase [list "0 0 0"  "1 0 0"  "3 1 0"  "3 2 0"  "1 0 0"  "3 1 0"] ; # Endpoint Case
lappend TestCase [list "1 0 0"  "0 0 0"  "3 1 0"  "3 2 0"  "1 0 0"  "3 1 0"] ; # Endpoint Case
lappend TestCase [list "0 0 0"  "1 0 0"  "3 2 0"  "3 1 0"  "1 0 0"  "3 1 0"] ; # Endpoint Case
lappend TestCase [list "1 0 0"  "0 0 0"  "3 2 0"  "3 1 0"  "1 0 0"  "3 1 0"] ; # Endpoint Case
lappend TestCase [list "5.6925969 1.3884847 7.1713834"  "5.1573193 9.7184415 0.8644498"  "0.6567836 8.3850115 1.5273528"  "7.1182449 9.0049546 9.1872098"  "5.3056396 7.4102899 2.6120410"  "3.0759605 8.6171187 4.3952101"]
lappend TestCase [list "3.0803549 8.1101503 4.2072541"  "0.9167489 5.4057168 0.0942629"  "3.6443155 1.9841677 2.1280020"  "4.0865344 8.8738039 9.2944797"  "3.0803549 8.1101503 4.2072541"  "3.8982350 5.9401568 6.2429519"]
lappend TestCase [list "2.0809966 9.3100446 9.4661138"  "6.0883386 5.5240161 2.7490910"  "8.4523738 2.6004881 8.8473518"  "5.5868380 5.4932213 1.1649868"  "6.0883386 5.5240161 2.7490910"  "6.0992239 4.9759722 2.5386692"]
lappend TestCase [list "6.6149320 7.8081445 4.6267089"  "5.3733678 7.5372568 0.4121304"  "7.9879025 7.5486791 5.8931379"  "1.4971100 6.2860737 3.2138409"  "6.6149320 7.8081445 4.6267089"  "6.4606595 7.2515959 5.2627161"]
lappend TestCase [list "4.7238306 4.7424963 7.9590086"  "9.2276709 8.3299427 1.0349775"  "7.3828132 6.3559129 8.7078245"  "4.6487651 2.8181310 8.5972384"  "4.7238306 4.7424963 7.9590086"  "5.5976910 4.0460147 8.6356203"]
lappend TestCase [list "7.1035997 1.9299120 3.4688193"  "8.5433252 5.8883905 9.7941707"  "3.3053692 6.3729100 3.5626868"  "8.4883669 8.1557493 7.2000211"  "8.3560381 5.3734507 8.9713356"  "8.4883669 8.1557493 7.2000211"]
lappend TestCase [list "7.4520661 5.7569419 4.1686608"  "4.2367431 3.5840889 2.7405165"  "1.3188110 5.7542366 2.7702002"  "7.7144529 5.0792324 0.2292819"  "4.7448074 3.9274289 2.9661826"  "4.3479012 5.4345425 1.5667759"]
lappend TestCase [list "7.5543831 9.7934598 9.5348209"  "6.5205418 0.3092162 8.7907210"  "0.4877286 0.3419443 2.5644342"  "8.6578287 6.1098998 5.8827401"  "7.1211660 5.8192172 9.2230160"  "8.4262398 5.9464019 5.7886797"]
lappend TestCase [list "6.0543887 5.4347267 4.3429352"  "4.2117265 4.7630853 1.3218313"  "8.9537706 1.5933994 0.6307145"  "2.7936886 7.2837201 1.8965656"  "4.5061578 4.8704041 1.8045609"  "4.8831652 5.3535848 1.4671937"]
lappend TestCase [list "6.5771629 2.8557455 9.8087521"  "5.4359776 8.6172816 5.7508093"  "7.8904712 4.3099454 2.4107493"  "8.1402295 0.9894932 3.8694855"  "5.7508984 7.0273316 6.8706367"  "7.8904712 4.3099454 2.4107493"]
lappend TestCase [list "1.1294829 5.4847586 8.1420946"  "7.2489863 0.3206420 0.8259188"  "5.8457205 6.7040761 3.0411085"  "8.9017428 0.9704561 3.8471667"  "5.7071649 1.6217517 2.6692442"  "7.8717570 2.9028855 3.5754970"]
lappend TestCase [list "0.3580051 9.3271145 8.5768069"  "2.3779489 4.3772771 1.6443451"  "1.0661185 9.0362165 3.9415240"  "7.6388414 1.7341324 0.4120660"  "1.8279811 5.7249636 3.5318384"  "2.9136360 6.9836839 2.9494336"]
lappend TestCase [list "6.1264627 6.5812576 3.9222538"  "1.5068838 5.6589456 0.0446154"  "0.8368111 1.7808290 7.1053143"  "8.6670395 3.8812950 1.4077528"  "5.4376749 6.4437392 3.3440907"  "6.1998837 3.2194782 3.2029458"]
lappend TestCase [list "5.2548631 0.4534686 7.9484333"  "2.8554822 5.3465480 5.8755276"  "0.3950940 1.3010814 5.5699850"  "6.0302455 6.0816738 9.9995164"  "3.7687405 3.4841320 6.6645221"  "2.9986425 3.5098071 7.6165137"]
lappend TestCase [list "4.7098248 1.2821556 4.9827025"  "6.4808992 9.9281018 2.2789106"  "9.6036733 2.5927984 2.8488436"  "7.2373861 1.4947206 2.8305463"  "4.9620442 2.5134284 4.5976544"  "7.2373861 1.4947206 2.8305463"]
lappend TestCase [list "0.5036993 0.6001582 2.2439019"  "9.0252221 6.6637385 5.1333177"  "6.9023714 0.8286511 9.3846113"  "7.8635188 7.6077266 0.1778680"  "6.9835948 5.2109969 4.4410576"  "7.4521485 4.7062875 4.1183470"]
lappend TestCase [list "4.1414680 4.8821393 2.4051430"  "2.1773492 6.4060895 2.8305709"  "0.5806575 3.1182178 9.4735442"  "9.3828570 0.6330684 7.6857961"  "4.1414680 4.8821393 2.4051430"  "4.5936441 1.9852201 8.6584969"]
lappend TestCase [list "3.6062333 0.6118218 5.2241603"  "0.7544416 1.5864715 8.4712397"  "2.3437474 4.9755332 1.7418572"  "9.8825574 1.3070092 8.6204338"  "3.6062333 0.6118218 5.2241603"  "5.5154683 3.4321153 4.6358053"]
lappend TestCase [list "2.2607133 8.3082403 6.7904628"  "5.0325175 8.7431170 3.9781037"  "6.4334028 4.8699270 1.1961501"  "1.7809363 2.4707254 6.2966301"  "5.0325175 8.7431170 3.9781037"  "5.4392405 4.3572536 2.2860462"]
lappend TestCase [list "6.1786725 3.6854264 9.2902405"  "2.6667579 9.5505050 9.5018463"  "2.0599944 1.6033445 0.6954832"  "3.1884883 6.4163288 9.0715930"  "4.1912356 7.0045487 9.4099909"  "3.1884883 6.4163288 9.0715930"]
lappend TestCase [list "8.8292667 0.7124560 8.2423649"  "0.3649094 7.1453826 3.0669636"  "2.5889872 1.1761708 7.2524548"  "5.4661666 6.7986776 4.9964301"  "4.3314255 4.1308233 5.4922289"  "4.2263025 4.3757686 5.9686197"]
lappend TestCase [list "6.0241017 5.1715162 5.7250655"  "5.6868388 6.0031583 1.2902594"  "3.4800129 9.7922534 2.4761596"  "0.0589551 3.4081038 0.9383102"  "5.6945715 5.9840905 1.3919397"  "2.3316866 7.6493234 1.9599588"]


foreach value $TestCase {

    lassign $value s1 e1 s2 e2 cp1 cp2

    set line1 [mathline3d::Line3d new [mathpt3d::Point3d new $s1] [mathpt3d::Point3d new $e1]]
    set line2 [mathline3d::Line3d new [mathpt3d::Point3d new $s2] [mathpt3d::Point3d new $e2]]

    set result [$line1 ClosestPointsBetween $line2 True]

    lassign $result Item1 Item2

    test ClosestPointsBetweenOnSegment1 [list \
        Test ClosestPointsBetweenOnSegment 1 line : $value
    ] -body {
         mathpt3d::Equals [mathpt3d::Point3d new $cp1] $Item1 1e-6
    } -result 1

    test ClosestPointsBetweenOnSegment2 [list \
        Test ClosestPointsBetweenOnSegment 2 line : $value
    ] -body {
         mathpt3d::Equals [mathpt3d::Point3d new $cp2] $Item2 1e-6
    } -result 1

}

cleanupTests