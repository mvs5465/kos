// -
// - Helpful collection of math functions
// -


// A lot like braking distance, but vertical
Function LM_getStoppingDistance {
  Parameter tickTime.

  //////////////////////////
  // d = (vf^2 - vi^2)/(2*a)
  // vf = final velocity (0)
  // vi = v1 = initial velocity (v1)
  // a = accel, d = distance traveled

  Set vf to 0.
  Set v0 to ship:verticalspeed.
  Wait TICK_TIME.
  Set vi to ship:verticalspeed.

  Set dist to (vf^2 - vi^2)/(2*LM_getTotalAcceleration()).

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

  Return tAcc.
}
