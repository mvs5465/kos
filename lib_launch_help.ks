// -
// - Helpful collection of functions relevant to launching
// -

// Alternative to adjusting throttle
Function LL_setThrustLimit {
  Parameter ename.
  Parameter limit.

  For eng in ship:partsdubbed(ename) {
    Set eng:thrustlimit to limit.
  }
}

// A hacky-but-decent method for controlling descent speed
Function LL_lockSpeedUntilAltitude {
  Parameter timeTick.
  Parameter targetSpeed.
  Parameter destAlt.

  Lock throttle to 0.
  Set thr to 1.

  Until alt:radar < destAlt {
    If ship:velocity:surface:mag < abs(targetSpeed) {
      Set thr to max(0, thr - 0.1).
    } else {
      Set thr to min(1, thr + 0.1).
    }
    Lock throttle to thr.
    Wait timeTick.
  }
}

// Launches to parameter height
Function LL_launchIfLanded {
  Parameter desiredHeight.
  
  if (alt:radar < 30) {
    Lock throttle to 1.
    Stage.
    Wait until apoapsis > desiredHeight.
    Lock throttle to 0.
  }
}

// Prints a countdown
Function LL_countDown {
  Parameter count.

  Until count <= 0 {
    Set count to count - 1.
    Print "T - " + count + "s".
    Wait 1.
  }
}
