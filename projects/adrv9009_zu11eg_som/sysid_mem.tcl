proc chars2hexlist {string} {
  binary scan $string c* ints
  set list {}
  foreach i $ints {
    lappend list [format %0.2X [expr {$i & 0xFF}]]
  }
  set list;
}

###
# time and date
set thetime [clock seconds]
set timedate_string "time and date : [clock format $thetime -format %H:%M:%S] - [clock format $thetime -format %D]"

set timedate_list [chars2hexlist $timedate_string]

while {[llength $timedate_list] < 64} {
  lappend timedate_list 00
}

# proj name
set projname_list [chars2hexlist [current_project]]

while {[llength $projname_list] < 64} {
  lappend projname_list 00
}

# magic/custom
set custom_string "Analog Devices was here"
set custom_list [chars2hexlist $custom_string]

while {[llength $custom_list] < 64} {
  lappend custom_list 00
}

# git sha
set gitsha_string [exec git rev-parse HEAD]
set gitsha_list [chars2hexlist $gitsha_string]

while {[llength $gitsha_list] < 64} {
  lappend gitsha_list 00
}

# merge lists
set mem_list [list {*}$timedate_list {*}$projname_list {*}$custom_list {*}$gitsha_list]
set mem_file [open "mem_init.txt" "w"]

for {set i 0} {$i < [llength $mem_list]} {incr i} {
  if { ($i+1) % 4 == 0} {
    puts $mem_file [lindex $mem_list $i]
  } else {
    puts -nonewline $mem_file [lindex $mem_list $i]
  }
}
close $mem_file
