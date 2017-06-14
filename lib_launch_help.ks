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

  If alt:radar < destAlt {
    Return.
  }

  Lock throttle to 0.5.
  Set thr to 0.5.
  Set thrustIncr to 0.1.

  Set altReached to False.
  Until alt:radar < destAlt {

    // TODO - this method causes bouncing at low velocities
    //        since it has poor accuracy
    // essentially, increase thrust increment the further we are from desired speed

    // Determine if we're getting closer or further from our target speed
    Set s0 to abs(ship:velocity:surface:mag - abs(targetSpeed)).
    Wait timeTick.
    Set s1 to abs(ship:velocity:surface:mag - abs(targetSpeed)).

    If s1 > s0 {
      Set thrustIncr to max(0.2, thrustIncr * 1.33).
    } else {
      Set thrustIncr to min(0.001, thrustIncr * 0.5).
    }

    If (ship:velocity:surface:mag > abs(targetSpeed)) AND (ship:verticalspeed < -abs(targetSpeed)) {// TODO - this is bad code
      Set thr to max(1, thr + thrustIncr).
    } else {
      Set thr to min(0, thr - thrustIncr).
    }
    Lock throttle to thr.

    llog(LOG_VVV, "LL_lockSpeedUntilAltitude(alt:radar)[" + 0.1*floor(alt:radar*10) + "m]").
    llog(LOG_VVV, "LL_lockSpeedUntilAltitude(dest alt)[" + 0.1*floor(destAlt*10) + "m]").
    llog(LOG_VV, "LL_lockSpeedUntilAltitude(throttle)[" + floor(thr*100) + "%]").
    llog(LOG_VV, "LL_lockSpeedUntilAltitude(vel)[" + 0.1*floor(ship:velocity:surface:mag*10) + "m/s]").
    llog(LOG_VV, "LL_lockSpeedUntilAltitude(dest vel)[" + 0.1*floor(targetSpeed*10) + "m/s]").
    llog(LOG_VV, "LL_lockSpeedUntilAltitude(vert vel)[" + 0.1*floor(ship:verticalspeed*10) + "m/s]").
    llog(LOG_VV, "LL_lockSpeedUntilAltitude(thrust incr)[" + 0.1*floor(thrustIncr*1000) + "%]").

  }

}

// Launches to parameter height
Function LL_launchIfLanded {
  Parameter desiredHeight.

  if (alt:radar < 30) {
    llog(LOG_V, "LL_launchIfLanded(Launching!)").
    Lock throttle to 1.
    If stage:liquidfuel < 0.1 {
      llog(LOG_V, "LL_launchIfLanded(Staging.)").
      Stage.
    }
    Wait until apoapsis > desiredHeight.
    Lock throttle to 0.
    llog(LOG_V, "LL_launchIfLanded(End.)").
  } else {
    llog(LOG_V, "LL_launchIfLanded(Low altitude, not launching.)").
  }

}

// Prints a countdown
Function LL_countDown {
  Parameter count.

  llog(LOG_V, "LL_countDown(Starting countdown...)").
  Until count <= 0 {
    Print "T - " + count + "s".
    Set count to count - 1.
    Wait 1.
  }
}
