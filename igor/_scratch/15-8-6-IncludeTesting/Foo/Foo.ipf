// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModFoo
// Scratch file on how to include stuff in an OS-independent manner.
#include "::Bar:Bar"
// The following line works on (both?):
//#include "::Bar:Bar"
// The following line does *not* work (on Mac for sure, don't know about windows):
//#include ":..:Bar:Bar"
// The following line does *not* work on Windows, does on mac
// #include "..\Bar\Bar
