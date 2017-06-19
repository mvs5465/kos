// -
// - Cruise control routine (for rovers)
// -

Set TICK_TIME to 0.01.

// Start
Clearscreen.
main().
// End


Function main {
  Set startSpeed to ship:velocity:surface:mag.
  Print "Cruise control activated: " + 0.1*floor(ship:velocity:surface:mag*10) + "m/s".

  Lock steering to ship:facing.

  Set stopped to false.
  Set thr to 1.
  Until stopped = true {

    If ship:velocity:surface:mag < startSpeed {
      Set thr to max(1, thr + 0.1).
    } else {
      Set thr to min(-1, thr - 0.1).
    }

    Lock wheelthrottle to thr.
    Wait TICK_TIME.
  }
}
