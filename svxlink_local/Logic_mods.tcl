###############################################################################
#
# Main program
#
#
#  Additional commands:
#   System Status: 788
#   Outside Temperature: 401
#   Cabinet Temperature: 402
#   TX Temperature: 403
#   Amp Temperature:  781
#   Link Radio Temperature: 782
#   Power Supply Temperature: 783
#   Barometric Pressure: 406
#   Fan Off: 430
#   Fan On: 431
#   Amplifier Off: 420
#   Amplifier On: 421
#
#
#  ID control
#   Disable long id during quiet hours
#   Controlled by QUIET_HOURS_END and QUIET_HOURS_START in svxlink.conf
#
#  Announce stats at specific hours - NOTE Moved to ModuleMetar.conf
#       LONG_STAT_TIME - Comma seperated list of up to six hours to
#   announce additional stats
#
#  Remove /R on long CW ID
###############################################################################
#
# This is the namespace in which all functions and variables below will exist.
#
namespace eval Logic {
    
   variable quiet_hours_end        0
   variable quiet_hours_start      25
package require Expect
#
# Contains the current state of the squelch - used to suppress the ID when
# someone is talking
variable sql_state 0;
#
# Set when we've missed an ID and one needs to be sent
# the next time the squelch closes
variable missed_id 0;

    
    proc startup {} {
        #  playSilence 1000
        #  playMsg "Core" "online"
    }
    
    #
    # Executed when a manual identification is initiated with the * DTMF code
    #
    proc manual_identification {} {
        global mycall;
        global report_ctcss;
        global active_module;
        global loaded_modules;
        variable CFG_TYPE;
        variable prev_ident;
        variable long_stat_times;
        variable long_announce_file;
        variable special_id
        
        set epoch [clock seconds];
        set hour [clock format $epoch -format "%k"];
        regexp {([1-5]?\d)$} [clock format $epoch -format "%M"] -> minute;
        set prev_ident $epoch;
        
        #playMsg "Core" :online";

        # If SPECIAL_ID defined use it as the custom message on startup
        if [ info exists special_id ] {
           playMsg "Custom" $special_id;
        } else {
           playMsg "Custom" [string tolower $mycall];
           playMsg "Core" "repeater";
        }
        #  spellWord $mycall;
        #  if {$CFG_TYPE == "Repeater"} {
        #    playMsg "Core" "repeater";
        #  }
        playSilence 250;
        playMsg "Core" "the_time_is";
        playTime $hour $minute;
        playSilence 250;
        if {$report_ctcss > 0} {
            playMsg "Core" "pl_is";
            playFrequency $report_ctcss
            playSilence 300;
        }
        if {$active_module != ""} {
            playMsg "Core" "active_module";
            playMsg $active_module "name";
            playSilence 250;
            set func "::";
            append func $active_module "::status_report";
            if {"[info procs $func]" ne ""} {
                $func;
            }
        } else {
            foreach module [split $loaded_modules " "] {
                set func "::";
                append func $module "::status_report";
                if {"[info procs $func]" ne ""} {
                    $func;
                }
            }
        }
        # Play announcement file
        puts "Playing long announce"
        if [file exist "$long_announce_file"] {
            playFile "$long_announce_file"
            playSilence 500
        }
        
        playMsg "Default" "press_0_for_help"
        playSilence 250;
    }
    
    
    #
    # Executed when a short identification should be sent
    #   hour    - The hour on which this identification occur
    #   minute  - The minute on which this identification occur
    #
    proc send_short_ident {{hour -1} {minute -1}} {
        global mycall;
        variable CFG_TYPE;
        variable short_announce_file
        variable short_announce_enable
        variable short_voice_id_enable
        variable short_cw_id_enable
        
        playSilence 500;
        # Play voice id if enabled
        if {$short_voice_id_enable} {
            puts "Playing short voice ID"
#            spellWord $mycall;
            playMsg "Custom" [string tolower $mycall];
            if {$CFG_TYPE == "Repeater"} {
                playMsg "Core" "repeater";
            }
            playSilence 500;
        }
        
        # Play announcement file if enabled
        if {$short_announce_enable} {
            puts "Playing short announce"
            if [file exist "$short_announce_file"] {
                playFile "$short_announce_file"
                playSilence 500
            }
        }
        
        # Play CW id if enabled
        if {$short_cw_id_enable} {
            puts "Playing short CW ID"
            CW::play $mycall
            playSilence 500;
        }
    }
    
    
    #
    # Executed when a long identification (e.g. hourly) should be sent
    #   hour    - The hour on which this identification occur
    #   minute  - The minute on which this identification occur
    #
    proc send_long_ident {hour minute} {
        global mycall;
        global loaded_modules;
        global active_module;
        variable CFG_TYPE;
        variable special_id; 
        variable long_announce_file
        variable long_announce_enable
        variable long_voice_id_enable
        variable long_cw_id_enable
        variable quiet_hours_end;
        variable quiet_hours_start;
        variable long_stat_times;
        
        set now [clock seconds];
        set hour [clock format $now -format "%k"];
        
        # Don't long id during Quiet hours
        if {$hour >= $quiet_hours_end && $hour <= $quiet_hours_start} {

                playSilence 500;
                playMsg "Core" "the_time_is";
                playSilence 100;
                playTime $hour $minute;
                playSilence 500;

            # Play the voice ID if enabled
            if {$long_voice_id_enable} {
                puts "Playing Long voice ID"

        # If SPEC_ID defined use it as the custom message on startup
        if [ info exists special_id ] {
           playMsg "Custom" $special_id;
        } else {
        #        spellWord $mycall;
                 playMsg "Custom" [string tolower $mycall];
                if {$CFG_TYPE == "Repeater"} {
                    playMsg "Core" "repeater";
                }
            }
                # Call the "status_report" function in all modules if no module is active
                if {$active_module == ""} {
                    foreach module [split $loaded_modules " "] {
                        set func "::";
                        append func $module "::status_report";
                        if {"[info procs $func]" ne ""} {
                            $func;
                        }
                    }
                }
            }
            if {$hour == [lindex $long_stat_times 0] || $hour == [lindex $long_stat_times 1] \
                || $hour == [lindex $long_stat_times 2] || $hour == [lindex $long_stat_times 3] \
                || $hour == [lindex $long_stat_times 4] || $hour == [lindex $long_stat_times 5] } {
                    # Play announcement file if enabled
                    if {$long_announce_enable} {
                        puts "Playing long announce"
                        if [file exist "$long_announce_file"] {
                            playFile "$long_announce_file"
                            playSilence 500
                        }   
                    }
                }
        # Play CW id if enabled
        if {$long_cw_id_enable} {
            puts "Playing long CW ID"
            CW::play $mycall
            playSilence 100
        }
	}
    }
    
    #
    # Executed when the squelch have just closed and the RGR_SOUND_DELAY timer has
    # expired.
    #
    proc send_rgr_sound {} {
        variable sql_rx_id
        
        playSilence 100;
        
        #  Instead of playing the RX_ID in CW
        #  Use it as an indicator for the number of tones to play
        #  for the rgr sound
        #
        #  Do 1240 tone once - 
        #  then the number of times to indicate which receiver
        #  Start RX_ID at a value of 1 
        #  this results in one beep for remote recivers (svxreflector)
        #  and a double beep for the first local receiver.
        #
        # 
        # If you forget to set the RX_ID this routine will 
        # attempt to produce "?" beeps.  To avoid this
        # the sql_rx_id is forced to "0" in this case.
        #
        if {$sql_rx_id == "?"} {
            set sql_rx_id "0"
        }
        
        # Initial high tone
        playTone 1240 50 80;
        playSilence 100;
        
        # RX_ID = 1 results in two beeps
        # and different values can be used to indicate which
        # receiver just closed (0 = linked system )
        for {set i 0} {$i <= $sql_rx_id} {incr i 1} {
            playTone 625 100 40;
            playSilence 30;
        }
        playSilence 100;
        set sql_rx_id  0;
        playSilence 100
    }
    
    #
    # Executed when a link to another logic core is activated.
    #   name  - The name of the link
    #
    proc activating_link {name} {
        if {[string length $name] > 0} {
            playMsg "Core" "activating_link_to";
            if {[string compare $name "REF"] == 0} {
                #    playSilence 250;
                #    playMsg "Core" "repeater";
                #    playMsg "Custom" "conference";
            } else {
                spellWord $name;
            }                 
        }
    }
    
    
    #
    # Executed when a link to another logic core is deactivated.
    #   name  - The name of the link
    #
    proc deactivating_link {name} {
        if {[string length $name] > 0} {
            playMsg "Core" "deactivating_link_to";
            if {[string compare $name "REF"] == 0} {
                #    playSilence 250;
                #    playMsg "Core" "repeater";
                #    playMsg "Custom" "conference";
            } else {
                spellWord $name;
            }
        }
    }
    
    
    #
    # Executed when trying to deactivate a link to another logic core but the
    # link is not currently active.
    #   name  - The name of the link
    #
    proc link_not_active {name} {
        if {[string length $name] > 0} {
            playMsg "Core" "link_not_active_to";
            if {[string compare $name "REF"] == 0} {
                #       playSilence 250;
                #       playMsg "Core" "repeater";
                #       playMsg "Custom" "conference";
            } else {
                spellWord $name;
            }
        }
    }
    
    
    #
    # Executed when trying to activate a link to another logic core but the
    # link is already active.
    #   name  - The name of the link
    #
    proc link_already_active {name} {
        if {[string length $name] > 0} {
            playMsg "Core" "link_already_active_to";
            if {[string compare $name "REF"] == 0} {
                #    playSilence 250;
                #    playMsg "Core" "repeater";
                #    playMsg "Custom" "conference";
            } else {
                spellWord $name;
            }
        }
    }
    
#
# Executed each time the squelch is opened or closed
#   rx_id   - The ID of the RX that the squelch opened/closed on
#   is_open - Set to 1 if the squelch is open or 0 if it's closed
#
proc squelch_open {rx_id is_open} {
  variable sql_rx_id;
  variable sql_state;
  variable missed_id;

  set sql_rx_id $rx_id;
  set sql_state $is_open;

  # If squelch is not open and we've missed an ID 
  if { $is_open == 0 && $missed_id == 1 } {
          set missed_id 0;
          checkPeriodicIdentify;
  }
  #puts "The squelch is $is_open on RX $rx_id";
}

#
# Executed when a DTMF command has been received
#   cmd - The command
#
# Return 1 to hide the command from further processing is SvxLink or
# return 0 to make SvxLink continue processing as normal.
#
# This function can be used to implement your own custom commands or to disable
# DTMF commands that you do not want users to execute.

    proc dtmf_cmd_received {cmd} {
        global active_module
        
            if {$cmd == "788"} {
            set upsbatt [exec get_batt]
            set supply [exec get_12v]
            set rpiv [exec get_5v]
            set gputemp [exec temp_gpu]
            set cputemp [exec temp_rpi]
            puts "System Status: Supply: $supply V, Ups $upsbatt V, RPi $rpiv V, Gpu temp $gputemp F, CPU temp $cputemp F"
            playSilence 1000
            
            playMsg "Custom" "supply_voltage_is"
            playNumber $supply
            playMsg "Custom" "volts"
            playSilence 100
            
            playMsg "Custom" "ups_voltage_is"
            playNumber $upsbatt
            playMsg "Custom" "volts"
            playSilence 100
            
            playMsg "Custom" "raspberry_pi_voltage_is"
            playNumber $rpiv
            playMsg "Custom" "volts"
            playSilence 100
            
            playMsg "Custom" "gpu_temperature_is"
            playNumber $gputemp
            playMsg "MetarInfo" "unit_degrees"
            playSilence 100
            
            playMsg "Custom" "cpu_temperature_is"
            playNumber $cputemp
            playMsg "MetarInfo" "unit_degrees"
            
            return 1
        }
        
        if {$cmd == "8911"} {
            set return [spawn /home/svx_admin/bin/switch_ctcss &]
        }

	if {$cmd == "8910"} {
	    set return [spawn /home/svx_admin/bin/restore_ctcss &]
	}

        if {$cmd == "403"} {
            set temp [exec read_probe transmitter]
            puts "$temp Reading Transmitter temperature"
            playSilence 1000
            playMsg "Custom" "transmitter_temp_is"
            playNumber $temp
            playMsg "MetarInfo" "unit_degrees"
            return 1
        }
        
        if {$cmd == "781"} {
            set temp [exec read_probe amplifier]
            puts "Amplifier temperature is $temp"
            playSilence 1000
            playMsg "Custom" "amplifier_temp_is"
            playNumber $temp
            playMsg "MetarInfo" "unit_degrees"
            return 1
        }
        
        if {$cmd == "782"} {
            set temp [exec read_probe link]
            puts "Link temperature is $temp"
            playSilence 1000
            playMsg "Custom" "link_temp_is"
            playNumber $temp
            playMsg "MetarInfo" "unit_degrees"
            return 1
        }
        
        if {$cmd == "783"} {
            set temp [exec read_probe power_supply]
            puts "Power Supply temperature is $temp"
            playSilence 1000
            playMsg "Custom" "power_supply_temp_is"
            playNumber $temp
            playMsg "MetarInfo" "unit_degrees"
            return 1
        }
        
        if {$cmd == "401"} {
            set temp [exec read_probe outside]
            puts "Outside temperature is $temp"
            playSilence 1000
            playMsg "Custom" "outside_temp_is"
            playNumber $temp
            playMsg "MetarInfo" "unit_degrees"
            return 1
        }
        
        if {$cmd == "402"} {
            set temp [exec read_probe cabinet]
            puts "Cabinet temperature is $temp"
            playSilence 1000
            playMsg "Custom" "cabinet_temp_is"
            playNumber $temp
            playMsg "MetarInfo" "unit_degrees"
            return 1
        }
        
        if {$cmd == "420"} {
            set temp [exec /usr/bin/amp_off]
            puts "Turning Amplifier off"
            playSilence 1000
            playMsg "Default" "deactivating"
            spellWord "PA"
            return 1
        }
        
        if {$cmd == "421"} {
            set temp [exec /usr/bin/amp_on ]
            puts "Turning Amplifier on"
            playSilence 1000
            playMsg "Default" "activating"
            spellWord "PA"
            return 1
        }
        
        # Example: Custom command executed when DTMF 430 is received
        if {$cmd == "430"} {
            puts "Fan Off";
            exec fan_off;
            playSilence 1000
            playMsg "Custom" "fan_off"
            return 1
        }
        
        # Example: Custom command executed when DTMF 431 is received
        if {$cmd == "431"} {
            puts "Fan On";
            exec fan_on;
            playSilence 1000
            playMsg "Custom" "fan_on";
            return 1
        }
        
        if {$cmd == "406"} {
            set temp [exec get_pressure]
            puts "Barometric pressure is $temp"
            playSilence 1000
            playMsg "MetarInfo" "pressure"
            playNumber $temp
            playMsg "MetarInfo" "unit_mbs"
            return 1
        }
        
        return 0
    }
    
    #
    # Should be executed once every whole minute to check if it is time to
    # identify. Not exactly an event function. This function handle the
    # identification logic and call the send_short_ident or send_long_ident
    # functions when it is time to identify.
    #
    proc checkPeriodicIdentify {} {
        variable prev_ident;
        variable short_ident_interval;
        variable long_ident_interval;
        variable min_time_between_ident;
        variable ident_only_after_tx;
        variable need_ident;
        variable quiet_hours_end 0;
        variable quiet_hours_start 24;
        variable sql_state;
        variable missed_id;

        global logic_name;
        
        if {$short_ident_interval == 0} {
            return;
        }
        
        set now [clock seconds];
        set hour [clock format $now -format "%k"];
        regexp {([1-5]?\d)$} [clock format $now -format "%M"] -> minute;
        
        set short_ident_now \
        [expr {($hour * 60 + $minute) % $short_ident_interval == 0}];
        set long_ident_now 0;
        if {$long_ident_interval != 0} {
            set long_ident_now \
            [expr {($hour * 60 + $minute) % $long_ident_interval == 0}];
        }
        
        if {$long_ident_now} {
            if {$sql_state == 1} {
                set missed_id 1;
                return;
            }

            if {$hour >= $quiet_hours_end && $hour <= $quiet_hours_start} {
                puts "$logic_name: Sending long identification...";
                send_long_ident $hour $minute;
	    }
            set prev_ident $now;
            set need_ident 0;
        } else {
            if {$now - $prev_ident < $min_time_between_ident} {
                return;
            }
            if {$ident_only_after_tx && !$need_ident} {
                return;
            }
            
            if {$short_ident_now} {
                if {$sql_state == 1} {
                    set missed_id 1;
                    return;
                }
                puts "$logic_name: Sending short identification...";
                send_short_ident $hour $minute;
                set prev_ident $now;
                set need_ident 0;
            }
        }
    }
    
    
    # Pick up needed config variables
    if [info exists CFG_QUIET_HOURS_START] {
        set quiet_hours_start $CFG_QUIET_HOURS_START
    }
    
    if [info exists CFG_QUIET_HOURS_END] {
        set quiet_hours_end $CFG_QUIET_HOURS_END
    }
    
    if [info exists CFG_LONG_STAT_TIMES] {
        set long_stat_times [split $CFG_LONG_STAT_TIMES ","]
    }
    
       if [info exists CFG_SPECIAL_ID] {
        set special_id $CFG_SPECIAL_ID
    }

    # end of namespace
}

#
# This file has not been truncated
#

