run lib_launch_help.
run lib_math.
run lib_log.

// -
// - circularize
// -


Set LOG_LEVEL to LOG_VV.

Set TICK_TIME to 0.001.

// -
// - begin
main().
// - end
// -



//////////////////
////// Main //////
Function main {
  Clearscreen.
  llog(LOG_V, "Preparing circularize routine...").
  SAS off.
  Lock throttle to 0.
  LL_circularize().
  llog(LOG_V, "Have a nice day!").
  Lock throttle to 0.
  Set SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
  SAS on.
}
