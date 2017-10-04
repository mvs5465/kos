// -
// - Hover & stabilize but allow pilot input
// -

Set TICK_TIME to 0.001.
Set headAng to 90.
Set hRol to 0.
Set hPit to 0.
Set hYaw to 0.

main().

Function main {
  Set startAlt to alt:radar.

  Set stopped to false.

  Set ca to 0.5.
  Set cb to 0.0.
  Set cc to 0.0.

  Set thr to 0.005.

  Set pit to 0.
  Set rol to 0.
  Set yaw to 0.
  Until stopped = true {

    Set v0 to ship:verticalspeed.
    Wait TICK_TIME.
    Set v1 to ship:verticalspeed.
    Set acc0 to abs((v1 - v0)/TICK_TIME).
    Wait TICK_TIME.
    Set v2 to ship:verticalspeed.
    Set acc1 to abs((v2 - v1)/TICK_TIME).
    Set jerk to abs((acc1 - acc0)/TICK_TIME).

    //Print "pilo pitch: " + pit.
     Print "pilo roll: " + 0.1*floor(vang(ship:facing:starvector, up:vector)*10).
    // Print "pilo yaw: " + yaw.

    If (ship:control:pilotpitch = 0) = false {
      Set pit to max(-30, min(30, pit + 20*ship:control:pilotpitch)).
    } else {
      If vang(ship:facing:forevector, up:forevector) < 90 {
        Set pit to -min(30, abs(90 - vang(ship:facing:forevector, up:vector))).
      } else {
        Set pit to min(30, abs(90 - vang(ship:facing:forevector, up:vector))).
      }
    }

    If (ship:control:pilotroll = 0) = false {
      Set rol to -max(-30, min(30, rol + 20*ship:control:pilotroll)).
    } else {
      If vang(ship:facing:starvector, up:vector) < 90 {
        Set rol to -min(30, abs(90 - vang(ship:facing:starvector, up:vector))).
      } else {
        Set rol to min(30, abs(90 - vang(ship:facing:starvector, up:vector))).
      }
    }

    If (ship:control:pilotyaw = 0) = false {
      Set yaw to -max(-89, min(89, yaw - 30*ship:control:pilotyaw)).
    } else {
      Set yaw to 0.
    }

    Lock steering to ship:facing + R(yaw,pit,rol).

    Set vertVel to 0.
    If ag1 {
      Set vertVel to -7.
    } else if ag2 {
      Set vertVel to 7.
    } else {
      Set vertVel to 0.
    }

    Set incr to ca*abs(vertVel-v2)+cb*(abs(v2-v1)/TICK_TIME)+cc*(abs(v2-v1)*TICK_TIME).
    //Print "incr: " + incr.
    If ship:verticalspeed < vertVel {
      Set thr to min(1, thr + incr).
    } else {
      Set thr to max(0, thr - incr).
    }

    Lock throttle to thr.

  }
}

Function checkPitch {

}

////////////////////////////////////
// Adds 'incr to current thrustlimit.
Function incrementMinorThrottle {
  Parameter incr.

  For eng in ship:partsdubbed("toroidalAerospike") {
      Set eng:thrustlimit to eng:thrustlimit + incr.
  }.
}
