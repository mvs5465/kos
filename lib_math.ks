// -
// - Helpful collection of math functions
// -

// Get absolute distance
Function LM_absDist {
  Parameter a.
  Parameter b.

  Return abs(a-b).


}


// A lot like braking distance, but vertical
Function LM_getStoppingDistance {
  Parameter tickTime.

  //////////////////////////
  // d = (vf^2 - vi^2)/(2*a)
  // vf = final velocity (0)
  // vi = v1 = initial velocity (v1)
  // a = accel, d = distance traveled

  Set vf to 0.
  Set v0 to ship:velocity:surface:mag.
  Wait TICK_TIME.
  Set vi to ship:velocity:surface:mag.

  Set dist to (vf^2 - vi^2)/(2*LM_getTotalAcceleration()).

  llog(LOG_VV, "LM_getStoppingDistance(dist)[" + 0.1*floor(dist*10) + "m]").
  Return abs(dist).
}


// Returns the net upwards acceleration of the ship engines blazing
Function LM_getTotalAcceleration {

  // F = M * A
  // A = Fnet/M
  // A = (Fup - Fdown) / M
  // ...
  // Acceleration = (Thrust - (mass*gravity)) / Mass

  Set tAcc to (ship:maxthrust - (ship:mass*ship:sensors:grav:mag))/ship:mass.

  llog(LOG_VV, "LM_getTotalAcceleration(net acc)[" + 0.1*floor(tAcc*10) + "m/s^2]").
  Return tAcc.
}


// calculate time to impact
Function LM_calcImpactTime {
  Set v0 to abs(ship:velocity:surface:mag).
  Wait TICK_TIME.
  Set v1 to abs(ship:velocity:surface:mag).
  Set a to abs((v1 - v0)/TICK_TIME).

  // vf = impact velocity
  Set vf to sqrt(v1^2 + 2*a*alt:radar).

  Set t0 to (2*alt:radar)/(v0 + vf).

  llog(LOG_VV, "LM_calcImpactTime(impact velocity)[" + 0.1*floor(vf*10) + "m/s]").
  llog(LOG_VV, "LM_calcImpactTime(impact time)[" + 0.1*floor(t0*10) + "s]").
  Return t0.
}
