// -
// - Helpful collection of functions relevant to launching
// -

// Circularizes at closer of periapsis or apoapsis
Function LL_circularize {
  // 1 Detect if we are closer to periapsis or apoapsis
  // 2 Wait until closer ETA = 0
  // 3 Burn while keeping closer one at current height (point up/down)
  //   until orbits are within 1%.

  llog(LOG_V, "LL_circularize(W...)").

  Lock throttle to 0.

  Set apCloserNode to true.

  // TODO duplicate code
  If eta:apoapsis < eta:periapsis {
    Set apCloserNode to true.
    Lock steering to prograde.
    llog(LOG_V, "LL_circularize(Waiting for apoapsis...)").
    Wait until eta:apoapsis < 1.
  } else {
    Set apCloserNode to false.
    Lock steering to retrograde.
    llog(LOG_V, "LL_circularize(Waiting for periapsis...)").
    Wait until eta:periapsis < 1.
  }


  llog(LOG_V, "LL_circularize(Circularizing...)").
  Lock throttle to 1.

  Set strAng to 0.
  Set a0 to apoapsis.
  Wait TICK_TIME.
  Set a1 to apoapsis.

  Set startAp to apoapsis.

  Until periapsis >= startAp*.99 {
    If a1 > a0 {
      If apCloserNode {
        Set strAng to max(-10, strAng - 0.1).
      } else {
        Set strAng to min(10, strAng + 0.1).
      }
    } else {
      If apCloserNode {
        Set strAng to min(10, strAng + 0.1).
      } else {
        Set strAng to max(-10, strAng - 0.1).
      }
    }
    llog(LOG_V, "LL_circularize(strAng: " + 0.1*floor(strAng*10) + ")").
    Lock steering to Heading(90, strAng).
    Set a0 to apoapsis.
    Wait TICK_TIME.
    Set a1 to apoapsis.
  }
  Lock throttle to 0.
  llog(LOG_V, "LL_circularize(Done.)").
}

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
  Parameter startThr.
  Parameter targetSpeed.
  Parameter destAlt.

  If alt:radar < destAlt {
    llog(LOG_V, "LL_lockSpeedUntilAltitude(Already below dest alt!)[").
    Return.
  }

  llog(LOG_V, "LL_lockSpeedUntilAltitude(Speed: " + 0.1*floor(targetSpeed*10) + "m/s Alt: " + 0.1*floor(destAlt*10) + "m").
  Lock throttle to startThr.
  Set thr to startThr.
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
    llog(LOG_VVV, "LL_lockSpeedUntilAltitude(throttle)[" + floor(thr*100) + "%]").
    llog(LOG_VVV, "LL_lockSpeedUntilAltitude(vel)[" + 0.1*floor(ship:velocity:surface:mag*10) + "m/s]").
    llog(LOG_VVV, "LL_lockSpeedUntilAltitude(dest vel)[" + 0.1*floor(targetSpeed*10) + "m/s]").
    llog(LOG_VVV, "LL_lockSpeedUntilAltitude(vert vel)[" + 0.1*floor(ship:verticalspeed*10) + "m/s]").
    llog(LOG_VVV, "LL_lockSpeedUntilAltitude(thrust incr)[" + 0.1*floor(thrustIncr*1000) + "%]").

  }

}

// Launches to parameter height
Function LL_launchIfLanded {
  Parameter desiredHeight.
  Parameter doLoop.

  if (alt:radar < 30) {
    llog(LOG_V, "LL_launchIfLanded(Launching!)").
    Lock throttle to 1.
    If stage:liquidfuel < 0.1 {
      llog(LOG_V, "LL_launchIfLanded(Staging.)").
      Stage.
    }

    Wait 4.
    If doLoop {
      llog(LOG_V, "LL_launchIfLanded(A loop?.)").
      Lock steering to UP + R(0,45,0).
      Wait 1.
      Lock steering to UP + R(0,135,0).
      Wait 1.
      Lock steering to UP + R(0,225,0).
      Wait 1.
      Lock steering to UP + R(0,315,0).
      Wait 1.
      Lock steering to UP + R(0,45,0).
      Wait 1.
      Lock steering to UP + R(0,0,0).
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
