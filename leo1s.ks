run lib_launch_help.

// Init and check
Set LAUNCH_STEEPNESS to 0.13.
Set TARGET_APOPSIS to 75000.
Set ETA_MARGIN to 15. // seconds to eta to fire (stronger engines get closer)
main().


//////////////////
////// Main //////
Function main {
  Clearscreen.
  SAS off.
  Lock throttle to 0.
  Lock steering to Up.

  // Activate engines but set thrustlimit to 0.
  //prepEngines().

  // Countdown
  LL_countdown(5).

  // Launch up until alt > 1km.
  // Check if we need to do a stage:
  If stage:liquidfuel < 0.1 {
    Stage.
  }
  liftoff().

  // Only stage if we previously had fuel
  If stage:solidfuel > 100 {
    When stage:solidfuel < 0.1 then {
      Print "Detaching boosters.".
      Stage.
    }
  }

  // When resourcePercent("liquidFuel") < 0.1 then {
  //   Print "Detaching boosters.".
  //   Stage.
  //   When stage:liquidfuel < 0.1 then {
  //     Print "Staging!".
  //     Stage.
  //   }
  // }

  Wait until altitude > 1000.

  // Gravity turn proportionally until alt = 30km and ang = 10deg
  turnAndBurn().

  // Burn until apoapsis is in space
  Print "Atmospheric exit burn started.".
  Lock steering to Heading(90,10).
  Lock throttle to 1.
  Wait until apoapsis > TARGET_APOPSIS.
  Print "Atmospheric exit burn complete.".
  Lock throttle to 0.

  // Circularize orbit
  Wait until eta:apoapsis < ETA_MARGIN.
  circularize(apoapsis*.995).
  Lock throttle to 0.
  Set SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
  countdown(10).
}
////// End ///////
//////////////////

//////////////////
/// Functions ///
/////////////////
Function circularize {
  Parameter destPer.

  Lock throttle to 1.
  Print "Curcularizing orbit.".
  Set angle to 0.
  Set ttick to 0.1.

  Set ap0 to eta:apoapsis.
  Wait ttick.
  Until periapsis > destPer {

    Set ap1 to eta:apoapsis.
    Set etaAp to eta:apoapsis.
    If etaAp > 0 {
      If ap1 > ap0 {
        Set angle to angle - ttick.
      } else {
        Set angle to angle + ttick.
      }
    } else {
      If ap1 > ap0 {
        Set angle to angle + ttick.
      } else {
        Set angle to angle - ttick.
      }
    }
    Lock steering to Heading(90, angle).
    Set ap0 to eta:apoapsis.
    Wait ttick.
  }
}

Function turnAndBurn {

  Set destApop to 71000.

  Print "Gravity turning until " + destApop.
  Until apoapsis > destApop {
    Set angle to -sqrt(LAUNCH_STEEPNESS*(altitude+1000))+90.
    Lock steering to Heading(90, angle).
    Wait 1.
  }
}

Function liftoff {
  Print "Liftoff.".
  Lock throttle to 1.
  setThrustLimit(100).
  Lock steering to Heading(90, 90).
}

Function setThrustLimit {
  Parameter lim.

  Lock throttle to lim/100.
  // For eng in ship:partsdubbed("skipperEngine") {
  //     Set eng:thrustlimit to lim.
  // }.
}

Function prepEngines {
  Print "Preparing for engines...".
  For eng in ship:partsdubbed("skipperEngine") {
      print "Preparing engine " + eng:isp.
      Set eng:thrustlimit to 0.
      eng:activate().
  }.
}

Function resourcePercent {
  Parameter resName.

  Set resList to ship:parts. //partsdubbed(resName)[0]:resources.
  For res in resList {
    If res:name = resName {
      Set resCur to res:amount.
      Set resMax to res:capacity.
    }
  }
  return (resCur/ResMax)*100.
}

Function countdown {
  Parameter t.
  Until t < 1 {
    Print "T-" + t.
    Wait 1.
    Set t to t-1.
  }
}
