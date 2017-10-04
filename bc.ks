// bc - batcar routine (balances a motorcycle)
Set TICK_TIME to 0.01.

// Start
Clearscreen.
Print "Running bc.ks".
main().
// End


Function main {

  Lock steering to ship:facing.

  Set stopped to false.
  Set thr to 1.
  Until stopped = true {

    If (ship:control:pilotroll = 0) = false {
      Set rol to -max(-30, min(30, rol + 20*ship:control:pilotroll)).
    } else {
      If vang(ship:facing:starvector, up:vector) < 90 {
        Set rol to -min(30, abs(90 - vang(ship:facing:starvector, up:vector))).
      } else {
        Set rol to min(30, abs(90 - vang(ship:facing:starvector, up:vector))).
      }
    }

    Lock steering to ship:facing + R(0,0,rol).

    Wait TICK_TIME.
  }
}
