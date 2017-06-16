run lib_launch_help.
run lib_math.
run lib_log.

Set LOG_LEVEL to LOG_VV.

Set TEST_LAUNCH_HEIGHT to 527. // (m)
Set ENGINE_NAME to "engine". // deprecated, prefer throttle control
Set TICK_TIME to 0.001. // global tick time (lower = more precise)
Set ENG_THROTTLEUP_TIME to 0.1. // time it takes engines to throttle 0-->100%

// requires grav sensor (TODO - measure acc?)

main().

/// End ///
///////////

// Functions

//////////////////
////// Main //////
Function main {
  Clearscreen.
  SAS off.
  Lock throttle to 0.

  LL_countDown(3).


  Gear off.
  Lock steering to up.
  LL_launchIfLanded(TEST_LAUNCH_HEIGHT, True).  // flip = true!

  Wait until alt:radar < (apoapsis - 5).
  Wait 2.
  land().
  llog(LOG_V, "Have a nice day!").
  Set SHIP:CONTROL:PILOTMAINTHROTTLE TO 0. // hopefully stop throttle after end
  SAS on.
}


// all-in-one landing boostback (suicide) burn "perfectly" into the ground
// no measure-burns required
// ~works half the time, all the time~
Function land {

  Set stoppingHeight to 35. // (m) height to switch to static-speed descent
  Set cutPowerHeight to 5. // (m) note the landing pad is ~12m tall
  Set stoppingSpeed to 2. // (m/s) target speed


  llog(LOG_V, "Boostback burn...").
  Gear on.
  Lights on.
  Lock steering to SRFRETROGRADE.

  // Boostback loop
  // Basically, brake so that you hit the ground the same time your speed = 0
  Lock throttle to 0.
  Set thr to 0.
  Until alt:radar < stoppingHeight {

    // TODO - this coefficient is a 10% error margin (lets get this lower)
    Set sDist to 1.1*LM_getStoppingDistance(TICK_TIME).

    // TODO - optimize this by adding dynamic thrust increments
    If sDist < alt:radar {
      Set thr to max(0, thr - 0.1). // TODO - remove this constant
    } else {
      Set thr to min(1, thr + 0.1). // TODO - remove this constant
    }
    Lock throttle to thr.
  }

  // Regain control and land
  LL_lockSpeedUntilAltitude(TICK_TIME, thr, stoppingSpeed, cutPowerHeight).
  Lock throttle to 0.
  llog(LOG_V, "Landed!").
}




////////////////////
// TODO - deprecated, prefer math
// measure and extrapolate burn time
Function measureBurnTime {

  llog(LOG_OFF, "Error: measureBurnTime parakeet").
  Return.

  //////////////
  Set t0 to LM_calcImpactTime().
  Print "t0: " + 0.1*floor(t0*10) + "s (free fall)".
  Lock throttle to 1.

  Wait ENG_THROTTLEUP_TIME.

  Set vZero to abs(ship:verticalspeed).
  Set t1 to LM_calcImpactTime().
  Set vInitial to abs(ship:verticalspeed).
  Set acc to abs(vInitial - vZero)/TICK_TIME.
  Set peakEngineAcceleration to min(peakEngineAcceleration, acc).

  Set tBurn to vInitial/acc.
  Set tDiff to (tBurn - t0).

  Print "t1: " + 0.1*floor(t1*10) + "s (engines firing)".
  Lock throttle to 0.

  Print "b-t: " + 0.1*floor(tBurn*10).
  Print "(diff): " + 0.1*floor(tDiff*10).

  //Set burnTime to t0/(t1 - t0).
  //Print "est burn time: " + burnTime.

  Return tDiff.
}
