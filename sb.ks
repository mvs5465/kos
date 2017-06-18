run lib_launch_help.
run lib_math.
run lib_log.

// -
// - boostback burn script
// - requires grav sensor (TODO - measure acc?)
// -

Set LOG_LEVEL to LOG_V.
Set CONTROLLER_HEIGHT_OFFSET to 5.06. // height of ship
Set DO_LOOP to false.
Set LAUNCH_ANGLE to 35. // degrees
Set TEST_LAUNCH_HEIGHT to 5800. // (m)
Set ENGINE_NAME to "engine". // deprecated, prefer throttle control
Set TICK_TIME to 0.001. // global tick time (lower = more precise)
Set ENG_THROTTLEUP_TIME to 0.1. // time it takes engines to throttle 0-->100%

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

  LL_countDown(3).


  Gear off.
  Lock steering to UP + R(0,LAUNCH_ANGLE,0).
  LL_launchIfLanded(TEST_LAUNCH_HEIGHT, DO_LOOP).

  Wait until ship:verticalspeed < 10.
  Lock steering to SRFRETROGRADE.
  Wait until ship:verticalspeed < -1.
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

  Set stoppingHeight to 35 + CONTROLLER_HEIGHT_OFFSET. // (m) height to switch to static-speed descent
  Set cutPowerHeight to 1 + CONTROLLER_HEIGHT_OFFSET. // (m) note the landing pad is ~12m tall
  Set stoppingSpeed to 1. // (m/s) target speed


  llog(LOG_V, "Boostback burn...").
  Gear on.
  Lights on.

  // Boostback loop
  // Basically, brake so that you hit the ground the same time your speed = 0
  Lock throttle to 0.
  Set thr to 0.
  Set sDist to LM_totalBoostbackDistance().
  Set adjustedDistance to dist.
  Wait TICK_TIME.
  Until alt:radar < stoppingHeight {

     // try to determine and factor in error margin
    Set sDistOld to sDist.
    Set sDist to LM_totalBoostbackDistance().
    Set errMgn to abs(sDist - sDistOld).
    Set adjustedDistance to (LM_totalBoostbackDistance() + errMgn + CONTROLLER_HEIGHT_OFFSET).

    llog(LOG_VV, "Stop dist:    " + 0.01*floor(sDist*100) + "m").
    llog(LOG_VV, "Error margin: " + 0.01*floor(errMgn*100) + "m").
    llog(LOG_VV, "Alt:          " + 0.01*floor(alt:radar*100) + "m").

     // TODO - replace with pidloop
    If  alt:radar < adjustedDistance {
      Set thr to max(1, thr + thr*1.33).
    } else {
      Set sDist to min(alt:radar, sDist).
      Set thr to min(0.01, thr - thr*1.33).
    }

    Lock throttle to thr.
    Wait TICK_TIME.
  }
  llog(LOG_V, "Missed by "
    + 0.1*abs(floor((adjustedDistance - alt:radar)*10)) + "m").

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
