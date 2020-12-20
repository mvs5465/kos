// -
// - Helpful collection of functions relevant to general maneuvering
// -


// Returns ship total quantity of a resource
Function resourcePercent {
  Parameter resName.

  For res in ship:parts {
    If res:name = resName {
      Set resCur to res:amount.
      Set resMax to res:capacity.
    }
  }
  return (resCur/ResMax)*100.
}

// Circularizes at closer of periapsis or apoapsis
Function LL_circularize {
  Parameter destHeading.
  // 1 Detect if we are closer to periapsis or apoapsis
  // 2 Wait until closer ETA = 0
  // 3 Burn while keeping closer one at current height (point up/down)
  //   until orbits are within 1%.

  Lock throttle to 0.

  Set apCloserNode to true.

  // TODO duplicate code
  If eta:apoapsis < eta:periapsis {
    Set apCloserNode to true.
    Lock steering to prograde.
    llog(LOG_V, "LL_circularize(Waiting for apoapsis...)").
    Wait until eta:apoapsis < 10.
  } else {
    Set apCloserNode to false.
    Lock steering to retrograde.
    llog(LOG_V, "LL_circularize(Waiting for periapsis...)").
    Wait until eta:periapsis < 10.
  }

  llog(LOG_V, "LL_circularize(Circularizing...)").
  Lock throttle to 1.

  Set startAp to apoapsis.
  Set strAng to 0.
  Set thr to 1.
  Set cutOffTime to 5. // seconds
  Set incr to 1.
  Set cutOffTimePrecise to 3. // seconds
  Set incrPrecise to 0.1.

  Set criticalAngle to 0.

  Set vel0 to ship:verticalspeed.
  Wait TICK_TIME.
  Set vel1 to ship:verticalspeed.
  Set acc to (vel1 - vel0)/TICK_TIME.
  Set apOld to apoapsis.
  Set perOld to periapsis.
  Wait TICK_TIME.
  Set startAp to apoapsis.

  Set startAP to apoapsis.

  Set nodesSwitched to false.

  Until nodesSwitched = true {



    // If ship:verticalspeed > 0 {
    //   If apCloserNode {
    //     Set strAng to max(-20, strAng - 0.1).
    //   } else {
    //     Set strAng to min(20, strAng + 0.1).
    //   }
    // } else {
    //   If apCloserNode {
    //     Set strAng to min(20, strAng + 0.1).
    //   } else {
    //     Set strAng to max(-20, strAng - 0.1).
    //   }
    // }

    // If periapsis > 0 {
    //   Set cutOffTime to cutOffTimePrecise.
    //   Set incr to incrPrecise.
    // }

    // keep apoapsis steady and raise periapsis



    Set vel1 to ship:verticalspeed.
    Set accOld to acc.
    Set acc to (vel1 - vel0)/TICK_TIME.



    // Measure apoapsis acceleration and use that to adjust pitch
    Set apsPos0 to startAp.

    Set apsPos1 to apoapsis.
    Set apsVel0 to apoapsis - startAp.

    Set apsPos2 to apoapsis.
    Set apsVel1 to apoapsis - apsPos2.

    Set apsVertAcc to apsVel1 - apsVel0.



    // Use change in altitude (verticalspeed) to adjust throttle
    // Use change in verticalspeed (acceleration) to adjust pitch
    //If ship:verticalspeed > 0 {
    // If abs(accOld) > abs(acc) {
    //     Set thr to max(0, thr - abs(abs(accOld) - abs(acc)*0.1)).
    // } else {
    //     Set thr to min(1, thr + abs(abs(accOld) - abs(acc)*0.1)).
    // }

    // Old attempt at handling all cases (suffer from locking at some positive speed problem)
    // If apsVel1 > 0  AND apsVertAcc > -0.3 {
    //   Set strAng to max(-10, strAng - 0.1).
    // } else if apsVel1 > 0  AND apsVertAcc < -0.3 {
    //   Set strAng to min(10, strAng + 0.1).
    // } else if apsVel1 < 0  AND apsVertAcc < -0.3 {
    //   Set strAng to max(-10, strAng - 0.1).
    // } else {
    //   Set strAng to min(10, strAng + 0.1).
    // }

    // If apsVel1 > 0 {
    //   Set strAng to max(-10, strAng - 0.1).
    // } else {
    //   Set strAng to min(10, strAng + 0.1).
    // }

    // Commented 10/4/18
    // If acc > 0 {
    //   Set strAng to max(-20, strAng - 0.1).
    // } else {
    //   Set strAng to min(30, strAng + 0.1).
    // }

    // If ship:verticalspeed > 0 {
    //   Set thr to max(0.1, thr - 0.5).
    // } else {
    //   Set thr to min(1, thr + 0.5).
    // }

    // 10/5/18
    // If ship:verticalspeed > 0 {
    //   Set strAng to max(-20, -(abs(ship:verticalspeed)/10)).
    // } else {
    //   Set strAng to min(20, (abs(ship:verticalspeed)/10)).
    // }

    // Make time to apoapsis get closer to 0 as periapsis approaches apoapsis

    // Hold eta:apoapsis to 5 seconds
    If (eta:apoapsis > 5) AND (eta:apoapsis < eta:periapsis) {
      Set strAng to max(-1, strAng-sqrt(abs(0.1*floor((eta:apoapsis - 5)*10)))).
    } else {
      Set strAng to min(20, strAng+sqrt(abs(0.1*floor((eta:apoapsis - 5)*10)))).
    }

    // Old attempt at handling all cases (suffer from locking at some positive speed problem)
    // If ship:verticalspeed > -0.3 AND acc > 0 {
    //   Set thr to max(0.1, thr - abs(abs(accOld) - abs(acc)*0.1)).
    // } else if ship:verticalspeed > -0.3 and acc < 0 {
    //   Set thr to min(1, thr + abs(abs(accOld) - abs(acc)*0.1)).
    // } else if ship:verticalspeed < -0.3 and acc < 0 {
    //   Set thr to max(0.1, thr - abs(abs(accOld) - abs(acc)*0.1)).
    // } else {
    //   Set thr to min(1, thr + abs(abs(accOld) - abs(acc)*0.1)).
    // }
    //Lock throttle to thr.
    Lock steering to Heading(destHeading, strAng).

    llog(LOG_VVV, "LL_circularize(strAng: " + 0.1*floor(strAng*10) + ")").
    llog(LOG_VVV, "LL_circularize(thr: " + 0.1*floor(thr*10) + ")").


    Wait TICK_TIME.
    Set dApoapsis to abs(apOld - apoapsis)/TICK_TIME.
    Set dPeriapsis to abs(perOld - periapsis)/TICK_TIME.
    Set apOld to apoapsis.
    Set perOld to periapsis.

    If ((dApoapsis > dPeriapsis) AND (periapsis > apoapsis*.9)) OR (apoapsis > startAP*1.1) {
      Set nodesSwitched to true.
    }
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

  if (alt:radar < 100) {
    llog(LOG_V, "LL_launchIfLanded(Launching!)").
    Lock throttle to 0.
    If stage:liquidfuel < 0.1 {
      llog(LOG_V, "LL_launchIfLanded(Staging.)").
      Stage.
    }

    Lock throttle to 2.5/(LM_maxThrustWeightRatio()).

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
    llog(LOG_V, "LL_launchIfLanded(Skipping launch.)").
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
