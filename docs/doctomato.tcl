# Copyright (c) 2021-2023 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package require ruff 2.5
package require tomato

# Note : modification 'ruff! package' 
#        file : formatter.tcl (switch the order of class and command [line file :991 >= 999])

::ruff::document [namespace children ::tomato] \
                 -title "tomato $::tomato::version Reference Manual" \
                 -sortnamespaces false \
                 -compact false \
                 -excludeprocs {^_} \
                 -pagesplit namespace \
                 -navigation sticky \
                 -includesource true \
                 -preamble $::tomato::_Intro \
                 -outdir [file dirname [info script]]  \
                 -outfile "tomato.html"


# Syntax highlight.
foreach nameFile {
    tomato.html tomato-tomato-mathmatrix.html tomato-tomato-helper.html
    tomato-tomato-mathplane.html tomato-tomato-mathmatrix3d.html tomato-tomato-mathray3d.html
    tomato-tomato-mathcsys.html tomato-tomato-mathline3d.html tomato-tomato-mathpt3d.html
    tomato-tomato-mathquat.html tomato-tomato-mathtriangle.html tomato-tomato-mathvec3d.html
} {
    set fp [open [file join [file dirname [info script]] $nameFile] r]
    set html [split [read $fp] \n]
    close $fp

    set fp [open [file join [file dirname [info script]] $nameFile] w+]

    set figure 0
    foreach line $html {
        if {[string match "*<figure*>" $line] || [string match "*ruff_dyn_src*" $line]} {set figure 1}
        if {[string match "*</figure>*" $line] || [string match "*\}</pre></div>*" $line]} {set figure 0}

        if {$figure} {
            if {[string match "set *" $line] || [string match "* set *" $line]} {
                set l {}
                foreach word [split $line " "] {
                    if {$word eq "set"} {
                        set word "<span style=\"color: hsl(206, 98.02%, 29.04%);font-weight: 550;\">set</span>"
                    }
                    append l "$word "
                }
                set line [string trimright $l]
            }
            if {[string match "package *" $line]} {
                set line [string map {package {<span style="color: hsl(206, 98.02%, 29.04%);font-weight: 550;">package</span>}} $line]
            }
            if {[string match "puts *" $line] || [string match "* puts *" $line]} {
                set line [string map {puts {<span style="color: hsl(206, 98.02%, 29.04%);font-weight: 550;">puts</span>}} $line]
            }
            if {[string match "foreach *" $line]} {
                set line [string map {foreach {<span style="color: hsl(206, 98.02%, 29.04%);font-weight: 550;">foreach</span>}} $line]
            }
            if {[string match "*>method *" $line]} {
                set line [string map {method {<span style="color: rgba(241, 8, 218, 1);font-weight: 550;">method</span>}} $line]
            }
            if {[string match "*return *" $line]} {
                set line [string map {return {<span style="color: rgba(8, 23, 241, 1);font-weight: 550;">return</span>}} $line]
            }
            if {[string match "*error *" $line]} {
                set line [string map {error {<span style="color: rgba(8, 23, 241, 1);font-weight: 550;">error</span>}} $line]
            }
            if {[string match "*&quot;*" $line]} {
                regexp {&quot;(.+)&quot;} $line -> match
                set line [string map [list "&quot;$match&quot;" "<span style=\"color: hsl(120, 71%, 16%);\">&quot;$match&quot;</span>"] $line]
            }
            if {[string match "*# *" $line] || [regexp {\s#$} $line]} {
                set line "<span style=\"color: hsl(218, 8%, 43.5%);font-weight: 500;\">$line</span>"
            }

            if {[string match {*$*} $line]} {
                set l {}
                foreach word [split $line " "] {
                    if {[regexp {(\$[a-z0-9A-Z_:]+)} $word -> match]} {
                        set word [string map [list $match "<span style=\"color: rgb(233, 98, 98);\">$match</span>"] $word]
                    }
                    append l "$word "
                }
                set line [string trimright $l]
            }
        }
        puts $fp $line
    }
    close $fp
}

puts "dir     : [file dirname [info script]]"
puts "file    : tomato.html"
puts "version : $::tomato::version"
puts done!
exit 0