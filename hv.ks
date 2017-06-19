// -
// - Hover & stabilize but allow pilot input
// -

Set TICK_TIME to 0.01.
Set headAng to 90.

main().

Function main {
  Set startAlt to alt:radar.

  Set stopped to false.
  Set ca to 0.001. // thrust factor
  Set cv to 0.0005.
  Set thr to 0.5.

  Set pit to 0.
  Set rol to 0.
  Set yaw to 0.
  Until stopped = true {

    Set v0 to ship:verticalspeed.
    Wait TICK_TIME.
    Set v1 to ship:verticalspeed.
    Set acc to abs((v1 - v0)/TICK_TIME).

    //Print "pilo pitch: " + pit.
    //Print "pilo roll: " + rol.
    Print "pilo yaw: " + yaw.

    If (ship:control:pilotpitch = 0) = false {
      Set pit to pit + ship:control:pilotpitch.
    } else {
      If vang(ship:facing:forevector, up:forevector) < 90 {
        Set pit to -min(30, abs(90 - vang(ship:facing:forevector, up:forevector))).
      } else {
        Set pit to min(30, abs(90 - vang(ship:facing:forevector, up:forevector))).
      }
    }

    If (ship:control:pilotroll = 0) = false {
      Set rol to rol - ship:control:pilotroll.
    } else {
      If vang(ship:facing:topvector, up:topvector) < 90 {
        Set rol to -min(30, abs(90 - vang(ship:facing:topvector, up:topvector))).
      } else {
        Set rol to min(30, abs(90 - vang(ship:facing:topvector, up:topvector))).
      }
    }

    If (ship:control:pilotyaw = 0) = false {
      Set yaw to -max(-89, min(89, yaw - ship:control:pilotyaw)).
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

    Set incr to cv*abs(vertVel-ship:verticalspeed+acc)+ca*acc.
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
