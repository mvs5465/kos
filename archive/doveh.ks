// Init
Clearscreen.
SAS off.
Lock steering to Heading(90,0).

Lock vertSpeed to ship:verticalspeed.

// Turn on active control engines
Print "Activating major engine.".
FOR eng IN SHIP:PARTSDUBBED("liquidEngine") {
    print "An engine exists with ISP = " + eng:isp.
    eng:activate().
    Set eng:thrustlimit to 100.
}.

// Begin Hover routine.
Set stopped to False.
Set increment to 1.
Print "Attempting to stabilize flight...".
Gear off.

Set vel0 to vertSpeed.
Wait 0.1.
Set vel1 to vertSpeed.

Until stopped = True {

  // Capture sequential current position, velocity, and acceleration values.
  Set pos0 to alt:radar.
  Set vel0 to vertSpeed.
  Set acc0 to (vel1 - vel0)/(0.1).
  Set lat0 to ship:latitude.
  Set lon0 to ship:longitude.
  Wait 0.1.
  Set pos1 to alt:radar.
  Set vel1 to (pos1-pos0)/0.1.
  Set acc1 to (vel1 - vel0)/(0.1).
  Set lat1 to ship:latitude.
  Set lon1 to ship:longitude.

  Set northv to lat1-lat0.
  Set eastv to lon1-lon0.

  Set jerk to acc1 - acc0.

  // Increment thrust by the rate of change of acceleration.
  If vertSpeed > 0 {
    incrementMinorThrottle(-abs(acc1)).
  } else {
    incrementMinorThrottle(abs(acc1)).
  }

  If resourcePercent("liquidfuel") < 75 {
    Print "Landing...".
    Land().
    Set stopped to True.
  }
}

Lock throttle to 0.
Set endt to 10.
Until endt < 1 {
  Print "Program ending in " + endt.
  Wait 1.
  Set endt to endt - 1.
}
////// End ///////
//////////////////


/////////////////////////////
///////// Functions /////////

////////////////////////////////////
// Returns 'resName' as %.
Function resourcePercent {
  Parameter resName.

  Set resList to ship:resources.
  For res in resList {
    If res:name = resName {
      Set resCur to res:amount.
      Set resMax to res:capacity.
    }
  }
  return (resCur/ResMax)*100.
}

////////////////////////////////////
// Adds 'incr to current thrustlimit.
Function incrementMinorThrottle {
  Parameter incr.

  For eng in ship:partsdubbed("liquidEngine") {
      Set eng:thrustlimit to eng:thrustlimit + incr.
  }.
}

////////////////////////////////////
// Decreases thrust until landed
Function land {

  Lock steering to srfretrograde.
  Lock throttle to 1.

  For eng in ship:partsdubbed("miniJetEngine") {
      Set eng:thrustlimit to 0.
  }.
  For eng in ship:partsdubbed("liquidEngine") {
      Set eng:thrustlimit to 0.
  }.

  Brakes on.
  Until (alt:radar < 5000) {
    Print "Locking speed-to-altitude: " + floor(-sqrt(alt:radar)*5) + ":" + floor(alt:radar*0.67).
    lockSpeedUntilAltitude(-sqrt(alt:radar)*5, alt:radar*0.67).
  }

  Until (alt:radar < 2000) {
    Print "Locking speed-to-altitude: " + floor(-sqrt(alt:radar)*2.5) + ":" + floor(alt:radar*0.67).
    lockSpeedUntilAltitude(-sqrt(alt:radar)*2.5, alt:radar*0.67).
  }
  Gear on.

  Until (alt:radar < 10) {
    Print "Locking speed-to-altitude: " + floor(-sqrt(alt:radar)) + ":" + floor(alt:radar/2).
    lockSpeedUntilAltitude(-sqrt(alt:radar), alt:radar/2).
  }

  Lock steering to Up.

  Lock throttle to 0.
  Set SHIP:CONTROL:MAINTHROTTLE TO 0.
  Print "Landed.".
}

//////////////////////////////
// For descent
Function lockSpeedUntilAltitude {
  Parameter targetSpeed.
  Parameter destAlt.

  Until alt:radar < destAlt {
    Set thrustIncr to magicTorque().
    Set a0 to alt:radar.
    Wait 0.01.
    Set a1 to alt:radar.
    If -ship:velocity:surface:mag > -abs(targetSpeed) {
      incrementMinorThrottle(-thrustIncr).
    } else {
      incrementMinorThrottle(thrustIncr).
    }
  }
}

////////////////////////////////////
// Good number for thrust increment.
Function magicTorque {
  Set pos0 to alt:radar.
  Set vel0 to vertSpeed.
  Set acc0 to (vel1 - vel0)/(0.01).
  Wait 0.01.
  Set pos1 to alt:radar.
  Set vel1 to (pos1-pos0)/0.01.
  Set acc1 to (vel1 - vel0)/(0.01).
  return abs(acc1).
}

////////////////////////////////////
// Kills lateral movement via GPS
Function slowLat {
  Set lat0 to ship:latitude.
  Set lon0 to ship:longitude.
  Wait 0.1.
  Set lat1 to ship:latitude.
  Set lon1 to ship:longitude.
  Set northv to lat1-lat0.
  Set eastv to lon1-lon0.
  Lock steering to Up + R(1000*northv, 1000*eastv, 0).
  Print (1000*northv) + ":" + (1000*eastv).
}
