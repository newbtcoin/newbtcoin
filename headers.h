@@ -10,11 +10,11 @@
#ifdef _WIN32_WINNT
#undef _WIN32_WINNT
#endif
#define _WIN32_WINNT 0x0500
#define _WIN32_WINNT 0x0400
#ifdef _WIN32_IE
#undef _WIN32_IE
#endif
#define _WIN32_IE 0x0500
#define _WIN32_IE 0x0400
#define WIN32_LEAN_AND_MEAN 1
#include <wx/wx.h>
#include <wx/clipbrd.h>
@@ -28,6 +28,8 @@
#include <windows.h>
#include <winsock2.h>
#include <mswsock.h>
#include <shlobj.h>
#include <shlwapi.h>
#include <stdio.h>
#include <stdlib.h>
#include <io.h>
