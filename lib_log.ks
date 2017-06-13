// -
// - Logging functions
// -

Set LOG_LEVEL to 0. // default log level

Set LOG_OFF to 0.
Set LOG_V to 1.
Set LOG_VV to 2.
Set LOG_VVV to 3.

Function llog {
  Parameter logLevel.
  Parameter msg.

  if logLevel >= LOG_LEVEL {
    Print msg.
  }
}
