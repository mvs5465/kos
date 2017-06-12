
// Init and check
Set FUEL_TANK to "Size2LFB".

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
  countdown(5).

  // Launch up until alt > 1km.
  // Check if we need to do a stage:
  If stage:liquidfuel < 0.1 {
    Stage.
  }
  liftoff().

  // When stage:solidfuel < 0.1 then {
  //   Print "Detaching boosters.".
  //   Stage.
  // }

  When resourcePercent("liquidFuel") < 0.1 then {
    Print "Detaching boosters.".
    Stage.
    // When stage:liquidfuel < 0.1 then {
    //   Print "Staging!".
    //   Stage.
    // }
  }

  Wait until altitude > 1000.

  // Gravity turn proportionally until alt = 30km and ang = 10deg
  turnAndBurn().

  // Burn until apoapsis is in space
  Print "Atmospheric exit burn started.".
  Lock steering to Heading(90,10).
  Lock throttle to 1.
  Wait until apoapsis > 77000.
  Print "Atmospheric exit burn complete.".
  Lock throttle to 0.

  // Circularize orbit
  Wait until eta:apoapsis < 20.
  circularize(apoapsis*.99).
  Lock throttle to 0.
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
  Until periapsis > destPer {

    Set ap0 to eta:apoapsis.
    Wait 1.
    Set ap1 to eta:apoapsis.

    Set etaAp to eta:apoapsis.
    Print "etas:ap1:ap0 = " + floor(ap1/1000) + "km:" + floor(ap0/1000) + "km".
    If etaAp > 0 {
      If ap1 > ap0 {
        Set angle to angle - 1.
      } else {
        Set angle to angle + 1.
      }
    } else {
      If ap1 > ap0 {
        Set angle to angle + 1.
      } else {
        Set angle to angle - 1.
      }
    }
    Print angle.
    Lock steering to Heading(90, angle).
  }
}

Function turnAndBurn {

  Set destApop to 71000.

  Print "Gravity turning until " + destApop.
  Until apoapsis > destApop {
    Set angle to -sqrt(0.15*(altitude+1000))+90.
    Lock steering to Heading(90, angle).
    //Print "Locked steering to Heading(90," + floor(angle) + ").".
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

  Set resList to ship:partsdubbed(FUEL_TANK)[0]:resources.
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
