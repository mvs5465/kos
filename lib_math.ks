// -
// - Helpful collection of math functions
// -

// Theoretical braking altitude
Function LM_totalBoostbackDistance {

  //////////////////////////
  // d = (vf^2 - vi^2)/(2*a)
  // vf = final velocity (0)
  // vi = initial velocity
  // a = accel, d = distance traveled

  Set vf to 0.
  Set vi to ship:velocity:surface:mag.

  Set dist to (vf^2 - vi^2)/(2*LM_getMaxVerticalAcceleration()).

  llog(LOG_VVV, "LM_getStoppingDistance(dist)[" + 0.1*floor(dist*10) + "m]").
  Return abs(dist).
}

// Returns max vertical component of theoretical acceleration under full thrust
// (factors in angle of descent)
Function LM_getMaxVerticalAcceleration {

  // since the ship is likely to not be facing straight down,
  // consider only the vertical component of thrust

  // θ = degrees from straight down = vang(ship:facing:forevector, up)
  // Aa = adjacent acceleration (vertical component)
  // Am = total acceleration (ship:thrust)
  // cos(θ) = Aa/Am
  // Aa = (ship:thrust)*vang(ship:facing:forevector, up)

  llog(LOG_VVV, "LM_getVerticalAcceleration(vang)[" + 0.1*floor(vang(ship:facing:forevector, up:forevector)*10) + "deg]").
  Set vertTotalAccel to (ship:maxthrust)*cos(vang(ship:facing:forevector, up:forevector)).

  // F = M * A
  // A = Fnet/M
  // A = (Fup - Fdown) / M
  // Accel = (Thrust - (mass*gravity)) / Mass
  Set tAcc to (vertTotalAccel - (ship:mass*ship:sensors:grav:mag))/ship:mass.

  llog(LOG_VVV, "LM_getVerticalAcceleration(vert acc)[" + 0.1*floor(tAcc*10) + "m/s^2]").
  llog(LOG_VVV, "LM_getVerticalAcceleration(full acc)[" + 0.1*floor(LM_getMaxTotalAcceleration()*10) + "m/s^2]").
  Return tAcc.
}


// Returns max theoretical acceleration under full thrust
// (assumes pointing straight down)
Function LM_getMaxTotalAcceleration {

  // F = M * A
  // A = Fnet/M
  // A = (Fup - Fdown) / M
  // ...
  // Acceleration = (Thrust - (mass*gravity)) / Mass

  Set tAcc to (ship:maxthrust - (ship:mass*ship:sensors:grav:mag))/ship:mass.

  llog(LOG_VVV, "LM_getTotalAcceleration(net acc)[" + 0.1*floor(tAcc*10) + "m/s^2]").
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

  llog(LOG_VVV, "LM_calcImpactTime(impact velocity)[" + 0.1*floor(vf*10) + "m/s]").
  llog(LOG_VVV, "LM_calcImpactTime(impact time)[" + 0.1*floor(t0*10) + "s]").
  Return t0.
}
