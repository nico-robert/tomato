# Copyright (c) 2021-2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package require ruff 2.0
package require tomato

# Note : modification 'ruff! package' 
#        file : formatter.tcl (switch the order of class and command [line file :991 >= 999])

::ruff::document [namespace children ::tomato] \
                 -title "tomato $::tomato::version Reference Manual" \
                 -sortnamespaces false \
                 -compact false \
                 -excludeprocs {^_} \
                 -pagesplit namespace \
                 -includesource true \
                 -preamble $::tomato::_Intro \
                 -outdir [file dirname [info script]]  \
                 -outfile "tomato.html"

puts "done..."