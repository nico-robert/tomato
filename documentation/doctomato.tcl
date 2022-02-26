# Copyright (c) 2021-2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package require ruff
package require tomato

::ruff::document [namespace children ::tomato] \
                 -sortnamespaces false \
                 -compact true \
                 -excludeprocs {^_} \
                 -pagesplit namespace \
                 -includesource true \
                 -preamble $::tomato::_Intro \
                 -output [file join [file dirname [info script]] "tomato.html"]