// -
// - Autopilot routine (for planes)
// -

Set TICK_TIME to 0.01.

// Start
Clearscreen.
main().
// End


Function main {
  Set startSpeed to ship:velocity:surface:mag.

  Set stopped to false.
  Set thr to 1.
  Until stopped = true {

    If ship:velocity:surface:mag < startSpeed {
      Set thr to thr + 0.1.
    } else {
      Set thr to thr - 0.1.
    }

    If (90 - VANG(SHIP:SRFPROGRADE:FOREVECTOR, UP:FOREVECTOR)) < 0 {
      Lock steering to ship:facing + R(0,1,0).
    }  else {
      Lock steering to ship:facing + R(0,-1,0).
    }

    Lock throttle to thr.
  }
}
