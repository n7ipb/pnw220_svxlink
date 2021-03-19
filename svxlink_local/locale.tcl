###############################################################################
#
# Locale specific functions for playing back time, numbers and spelling words.
# Often, the functions in this file are the only ones that have to be
# reimplemented for a new language pack.
#
###############################################################################
# Modified for 'hundred' after hour - N7IPB
#
# Say the time specified by function arguments "hour" and "minute".
#
proc playTime {hour minute} {
  variable Logic::CFG_TIME_FORMAT

  # Strip white space and leading zeros. Check ranges.
  if {[scan $hour "%d" hour] != 1 || $hour < 0 || $hour > 23} {
    error "playTime: Non digit hour or value out of range: $hour"
  }
  if {[scan $minute "%d" minute] != 1 || $minute < 0 || $minute > 59} {
    error "playTime: Non digit minute or value out of range: $hour"
  }

  if {[info exists CFG_TIME_FORMAT] && ($CFG_TIME_FORMAT == 24)} {
    if {$hour == 0} {
      set hour "00"
    } elseif {[string length $hour] == 1} {
      set hour "o$hour";
    }
    playTwoDigitNumber $hour;
    # 
    # Add 'hundred' to hour announcement
    #
    playMsg "Custom" "hundred";
    if {$minute != 0} {
      if {[string length $minute] == 1} {
        set minute "o$minute";
      }
      playTwoDigitNumber $minute;
    }
    playMsg "Default" "hours";
    playSilence 100;
  } else {
    # Anything not 24 will fail back to 12 hour default
    if {$hour < 12} {
      set ampm "AM";
      if {$hour == 0} {
        set hour 12;
      }
    } else {
      set ampm "PM";
      if {$hour > 12} {
        set hour [expr $hour - 12];
      }
    }
  
    playMsg "Default" [expr $hour];
    if {$minute != 0} {
      if {[string length $minute] == 1} {
        set minute "o$minute";
      }
      playTwoDigitNumber $minute;
    }
    playSilence 100;
    playMsg "Core" $ampm;
  }
}


#
# This file has not been truncated
#
