// -
// - Logging functions
// -

Set LOG_LEVEL to 0. // default log level (override this)

Set LOG_OFF to 0.
Set LOG_V to 1.   // people friendly knowledge
Set LOG_VV to 2.  // debugging
Set LOG_VVV to 3.  // stable functions' verbose logging

Function llog {
  Parameter logLevel.
  Parameter msg.

  if logLevel <= LOG_LEVEL {
    Print msg.
  }
}
