run lib_launch_help.
run lib_math.
run lib_log.

// Init
Set LOG_LEVEL to LOG_V.

Set TEST_LAUNCH_HEIGHT to 2000.
Set ENGINE_NAME to "engine".
Set TICK_TIME to 0.01. // global tick time (lower = more precise)
Set ENG_THROTTLEUP_TIME to 0.1. // time it takes engines to throttle 0-->100%

main().

//////////////////
////// Main //////
Function main {
  Clearscreen.
  SAS off.
  Lock throttle to 1.

  LL_countDown(3).
  LL_launchIfLanded(500).

  Wait until alt:radar < (apoapsis - 5).
  Wait 2.
  land().
}


// Mainloop
//   Set waitInterval to 30.
//   Until alt:radar < 300 {
//     Print "-- " + floor(alt:radar) + "m --".
//
//     Set vert0 to ship:verticalspeed.
//     Set timeLeft to calcBurnTime().
//     Set vert1 to ship:verticalspeed.
//     Set acc to (vert1 - vert0) / TICK_TIME.
//
//     Set waitInterval to abs(timeLeft)/3.
//
//     Print "time left: " + 0.1*floor(timeLeft*10).
//     Print "interval: " + 0.1*floor(waitInterval*10).
//
//     if waitInterval < 2 {
//       Print "lets take a guess here...".
//       Wait abs(timeLeft).
//       Print "now!".
//
//       land().
//
//       Return.
//     }.
//
//     Wait waitInterval.
//   }


Function land {

  Set stoppingHeight to 25. // (m) height to switch to static-speed descent
  Set stoppingSpeed to 2. // (m/s) target speed
  Set cutPowerHeight to 15. // (m) note the landing pad is ~12m tall

  //Print "Boostback burn starting...".
  Gear on.

  // "smart" suicide burn
  Lock throttle to 1.
  Set thr to 1.
  Until alt:radar < stoppingHeight {

    Set sDist to LM_getStoppingDistance(TICK_TIME).
    //Print "stop: " + 0.1*floor(sDist*10) + ", alt: " + 0.1*floor(alt:radar*10).

    If sDist < alt:radar*0.9 {
      Set thr to max(0, thr - 0.1).
    } else {
      Set thr to min(1, thr + 0.1).
    }
    Lock throttle to thr.
  }

  // Actually land
  //Lock throttle to 1.
  LL_lockSpeedUntilAltitude(TICK_TIME, stoppingSpeed, cutPowerHeight).
  Lock throttle to 0.
  Print "Have a nice day!".
  Set SHIP:CONTROL:PILOTMAINTHROTTLE TO 0. // hopefully stop throttle after end

}

// measure and extrapolate burn time
Function calcBurnTime {

  Set t0 to calcImpactTime().
  Print "t0: " + 0.1*floor(t0*10) + "s (free fall)".
  Lock throttle to 1.

  Wait ENG_THROTTLEUP_TIME.

  Set vZero to abs(ship:verticalspeed).
  Set t1 to calcImpactTime().
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

// calculate time to impact
Function calcImpactTime {
  Set v0 to abs(ship:verticalspeed).
  Wait TICK_TIME.
  Set v1 to abs(ship:verticalspeed).
  Set a to abs((v1 - v0)/TICK_TIME).

  // vf = impact velocity
  Set vf to sqrt(v1^2 + 2*a*alt:radar).

  Set t0 to (2*alt:radar)/(v0 + vf).

  Return t0.
}
