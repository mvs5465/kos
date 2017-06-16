// all in one launch, gravity turn, and circularize script


run lib_launch_help.
run lib_math.
run lib_log.

// Init and check
Set LOG_LEVEL to LOG_VV.
Set LAUNCH_STEEPNESS to 0.13.
Set TARGET_APOAPSIS to 75000.
Set ETA_MARGIN to 15. // seconds to eta to fire (stronger engines get closer)
Set TICK_TIME to 0.01.
main().


//////////////////
////// Main //////
Function main {
  Clearscreen.
  SAS off.
  Lock throttle to 0.
  Lock steering to Heading(90, 90).

  LL_countdown(4).
  Gear off.
  LL_launchIfLanded(1000, FALSE).
  Lock throttle to 1.

  // Only stage if we previously had fuel
  // If stage:solidfuel > 100 {
  //   When stage:solidfuel < 0.1 then {
  //     Print "Detaching boosters.".
  //     Stage.
  //   }
  // }
  //
  // When resourcePercent("liquidFuel") < 0.1 then {
  //   Print "Detaching boosters.".
  //   Stage.
  //   When stage:liquidfuel < 0.1 then {
  //     Print "Staging!".
  //     Stage.
  //   }
  // }

  // Gravity turn proportionally until alt = 30km and ang = 10deg
  turnAndBurn().

  // Burn until apoapsis is in space
  llog(LOG_V, "main: atmospheric exit burn started.").
  Lock steering to Heading(90,5).
  Lock throttle to 1.
  Wait until apoapsis > TARGET_APOAPSIS.
  LL_circularize().
  llog(LOG_V, "main: Atmospheric exit burn complete.").
  Lock throttle to 0.

  LL_circularize().
  Lock throttle to 0.
  Set SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
  SAS on.
}

//////////////////
/// Functions ///
Function turnAndBurn {

  //// Ideal angle formula:
  // A = sqrt(C*(TA + 1000) + 90)
  // Cideal = (0^2 - 90)/(TA + 1000)
  // Cideal = (-90)/(TA + 1000)
  /// then
  // A = sqrt(Cideal*(TA + 1000) + 90)

  llog(LOG_V,"turnAndBurn: Gravity turning until " + TARGET_APOAPSIS/1000 + "km").

  Set cIdeal to abs((8100)/(TARGET_APOAPSIS + 1000)).
  llog(LOG_VV,"turnAndBurn: cIdeal " + 0.1*floor(cIdeal*10)).

  Set curAng to -sqrt(cIdeal*(altitude + 1000)) + 90.
  Until apoapsis > TARGET_APOAPSIS {
    llog(LOG_VVV,"turnAndBurn: curAng " + 0.1*floor(curAng*10)).
    Set curAng to -sqrt(cIdeal*(altitude + 1000)) + 90.
    Lock steering to Heading(90, curAng).
    Wait TICK_TIME.
  }
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
