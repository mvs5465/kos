run lib_launch_help.
run lib_math.
run lib_log.

// -
// - all in one launch, gravity turn, and circularize script
// -


Set LOG_LEVEL to LOG_VV.

Set TARGET_APOAPSIS to 75000.
Set TICK_TIME to 0.001.

// -
// - begin
main().
// - end
// -



//////////////////
////// Main //////
Function main {
  Clearscreen.
  SAS off.
  Lock throttle to 0.

  LL_countdown(4).
  Lock steering to Heading(90, 90).
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

  turnAndBurn().

  LL_circularize().
  llog(LOG_V, "Have a nice day!").
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
