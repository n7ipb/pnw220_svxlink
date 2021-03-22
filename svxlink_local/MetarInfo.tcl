###############################################################################
#
# MetarInfo module event handlers
#
###############################################################################

#
# This is the namespace in which all functions and variables below will exist.
# The name must match the configuration variable "NAME" in the
# [ModuleMetarInfo] section in the configuration file. The name may be changed
# but it must be changed in both places.
#
namespace eval MetarInfo {
    
    
    #
    # Executed when the state of this module should be reported on the radio
    # channel. Typically this is done when a manual identification has been
    # triggered by the user by sending a "*".
    # This function will only be called if this module is active.
    #
    proc status_report {} {
        printInfo "status_report called...";
#        site_temps ; #Commented out for systems without temperture probes
    }
    
    proc site_temps {} {
        set now [clock seconds];
        set hour [clock format $now -format "%k"];
        global ::Logic::long_stat_times;	

        if {$hour == [lindex $long_stat_times 0] || $hour == [lindex $long_stat_times 1]  || $hour == [lindex $long_stat_times 2] || $hour == [lindex $long_stat_times 3]  || $hour == [lindex $long_stat_times 4] || $hour == [lindex $long_stat_times 5] } {
            set currentTemp [exec hacktemp]
            temperature $currentTemp;
            set maxTemp [exec temp_max]
            set minTemp [exec temp_min]
            rmk_minmaxtemp $maxTemp $minTemp;
        } else {
            set currentTemp [exec hacktemp];
            temperature $currentTemp;
        }
    }
    
    # temperature
    proc temperature {temp} {
	playSilence 500;
        playMsg "temperature";
        playSilence 100;
        if {$temp == "not"} {
            playMsg "not";
            playMsg "reported";
        } else {
            if { int($temp) < 0} {
                playMsg "minus";
                set temp [string trimleft $temp "-"];
             }
            playNumber [string trimright [format "%.3f" $temp] ".0"]
            if {int($temp) == 1} {
                playMsg "unit_degree";
            } else {
                playMsg "unit_degrees";
            }
            playSilence 100;
        }
        playSilence 200;
    }
    
    # daytime minimal/maximal temperature
    proc rmk_minmaxtemp {max min} {
        playMsg "daytime";
        playMsg "temperature";
        playMsg "maximum";
        if { $max < 0} {
            playMsg "minus";
            set max [string trimleft $max "-"];
        }
        playNumber [string trimright [format "%.3f" $max] ".0"]
        playMsg "unit_degrees";
        playSilence 500;   
        playMsg "minimum";
        if { $min < 0} {
            playMsg "minus";
            set min [string trimleft $min "-"];
        }
        playNumber [string trimright [format "%.3f" $min] ".0"]
        playMsg "unit_degrees";
        playSilence 200;
    }
        
    # end of namespace
}

#
# This file has not been truncated
#
