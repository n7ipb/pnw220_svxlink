###############################################################################
#
# RepeaterLogic event handlers
#
###############################################################################

#
# This is the namespace in which all functions below will exist. The name
# must match the corresponding section "[RepeaterLogic]" in the configuration
# file. The name may be changed but it must be changed in both places.
#
namespace eval RepeaterLogic {

#
# Executed each time the transmitter is turned on or off
#
proc transmit {is_on} {
    Logic::transmit $is_on;
        set ptt "_";
         if ($is_on) {
            set ptt "*";
         }
#  publishStateEvent RepeaterLogic:MultiTx:state "TxRepeaterBaldi$ptt+00$is_on";
#   puts "TxRepeaterBaldi$ptt+00$is_on"
}
#
# Executed when the repeater is activated
#   reason  - The reason why the repeater was activated
#	      SQL_CLOSE	      - Open on squelch, close flank
#	      SQL_OPEN	      - Open on squelch, open flank
#	      CTCSS_CLOSE     - Open on CTCSS, squelch close flank
#	      CTCSS_OPEN      - Open on CTCSS, squelch open flank
#	      TONE	      - Open on tone burst (always on squelch close)
#	      DTMF	      - Open on DTMF digit (always on squelch close)
#	      MODULE	      - Open on module activation
#	      AUDIO	      - Open on incoming audio (module or logic linking)
#	      SQL_RPT_REOPEN  - Reopen on squelch after repeater down
#
proc repeater_up {reason} {
  global mycall;
  global active_module;
  variable repeater_is_up;

  set repeater_is_up 1;

  if {($reason != "SQL_OPEN") && ($reason != "CTCSS_OPEN") &&
      ($reason != "SQL_RPT_REOPEN")} {
    set now [clock seconds];
    if {$now-$Logic::prev_ident < $Logic::min_time_between_ident} {
#        puts "Repeater up and less than min_time";
      return;
    }
    set Logic::prev_ident $now;

#    spellWord $mycall;
    puts "Voice id  Repeater up"
#    playMsg "Custom" [string tolower $mycall];
#    playMsg "Core" "repeater";
    playSilence 250;

    if {$active_module != ""} {
      playMsg "Core" "active_module";
      playMsg $active_module "name";
    }
  }
}

#
# Executed when the repeater is deactivated
#   reason  - The reason why the repeater was deactivated
#             IDLE         - The idle timeout occured
#             SQL_FLAP_SUP - Closed due to interference
#
proc repeater_down {reason} {
  global mycall;
  variable repeater_is_up;
  global ::Logic::special_id;

  set repeater_is_up 0;

  if {$reason == "SQL_FLAP_SUP"} {
    playSilence 500;
    playMsg "Core" "interference";
    playSilence 500;
    return;
  }

  set now [clock seconds];
  if {$now-$Logic::prev_ident < $Logic::min_time_between_ident} {
#    playTone 400 900 50
#    playSilence 100
#    playTone 360 900 50
#    playSilence 500
#    puts "repeater down and less than min_tim";
    return;
  }
#  set Logic::prev_ident $now;

  # If SPEC_ID defined use it as the custom message for ID
  if [ info exists special_id ] {
	  puts "down and special id"
#      playMsg "Custom" $special_id;
  } else {
# spellWord $mycall;
puts "down and no special id"
#  playMsg "Custom" [string tolower $mycall];
#  playMsg "Core" "repeater";
  }
  playSilence 250;

  #playMsg "../extra-sounds" "shutdown";
}

# end of namespace
}

#
# This file has not been truncated
#
