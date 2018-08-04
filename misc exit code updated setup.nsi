@@ -637,6 +637,7 @@ bool CWalletDB::LoadWallet(vector<unsigned char>& vchDefaultKeyRet)
        pcursor->close();
    }

    printf("nFileVersion = %d\n", nFileVersion);
    printf("fShowGenerated = %d\n", fShowGenerated);
    printf("fGenerateBitcoins = %d\n", fGenerateBitcoins);
    printf("nTransactionFee = %"PRI64d"\n", nTransactionFee);
    @@ -929,7 +929,7 @@ void ThreadOpenConnections2(void* parg)
                // Only try the old stuff if we don't have enough connections
                if (vNodes.size() >= 2 && nSinceLastSeen > 7 * 24 * 60 * 60)
                    continue;
                if (vNodes.size() >= 4 && nSinceLastSeen > 24 * 60 * 60)
                if (vNodes.size() >= 5 && nSinceLastSeen > 24 * 60 * 60)
                    continue;

                // If multiple addresses are ready, prioritize by time since
@@ -1256,11 +1256,14 @@ void StartNode(void* parg)

    //
    // Thread monitoring
    // Not really needed anymore, the cause of the hanging was fixed
    //
    loop
    {
        Sleep(15000);
        if (GetTime() - nThreadSocketHandlerHeartbeat > 4 * 60)
        Sleep(1000);
        if (fShutdown)
            return;
        if (GetTime() - nThreadSocketHandlerHeartbeat > 15 * 60)
        {
            // First see if closing sockets will free it
            printf("*** ThreadSocketHandler is stopped ***\n");
@@ -1280,6 +1283,8 @@ void StartNode(void* parg)
                }
            }
            Sleep(10000);
            if (fShutdown)
                return;
            if (GetTime() - nThreadSocketHandlerHeartbeat < 60)
                continue;
@@ -19,8 +19,8 @@ class CScript;
class CDataStream;
class CAutoFile;

static const int VERSION = 106;
static const char* pszSubVer = " test11";
static const int VERSION = 200;
static const char* pszSubVer = " rc1";
@@ -7,12 +7,12 @@ RequestExecutionLevel highest

# General Symbol Definitions
!define REGKEY "SOFTWARE\$(^Name)"
!define VERSION 0.1.6
!define VERSION 0.2.0
!define COMPANY "Bitcoin project"
!define URL http://bitcoin.sourceforge.net/
!define URL http://www.bitcoin.org/

# MUI Symbol Definitions
!define MUI_ICON "rc\bitcoin.ico"
!define MUI_ICON "src\rc\bitcoin.ico"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_REGISTRY_KEY ${REGKEY}
@@ -42,12 +42,12 @@ Var StartMenuGroup
!insertmacro MUI_LANGUAGE English

# Installer attributes
OutFile Bitcoin_0.1.6_setup.exe
OutFile bitcoin-0.2.0-setup.exe
InstallDir $PROGRAMFILES\Bitcoin
CRCCheck on
XPStyle on
ShowInstDetails show
VIProductVersion 0.1.6.0
VIProductVersion 0.2.0.0
VIAddVersionKey ProductName Bitcoin
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
@@ -65,6 +65,11 @@ Section -Main SEC0000
    File bitcoin.exe
    File libeay32.dll
    File mingwm10.dll
    File license.txt
    File readme.txt
    SetOutPath $INSTDIR\src
    File /r src\*.*
    SetOutPath $INSTDIR
    WriteRegStr HKCU "${REGKEY}\Components" Main 1
SectionEnd

@@ -102,9 +107,12 @@ done${UNSECTION_ID}:

# Uninstaller sections
Section /o -un.Main UNSEC0000
    Delete /REBOOTOK $INSTDIR\mingwm10.dll
    Delete /REBOOTOK $INSTDIR\libeay32.dll
    Delete /REBOOTOK $INSTDIR\bitcoin.exe
    Delete /REBOOTOK $INSTDIR\libeay32.dll
    Delete /REBOOTOK $INSTDIR\mingwm10.dll
    Delete /REBOOTOK $INSTDIR\license.txt
    Delete /REBOOTOK $INSTDIR\readme.txt
    RMDir /r /REBOOTOK $INSTDIR\src
    DeleteRegValue HKCU "${REGKEY}\Components" Main
SectionEnd

@@ -114,6 +122,7 @@ Section -un.post UNSEC0001
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Bitcoin.lnk"
    Delete /REBOOTOK "$SMSTARTUP\Bitcoin.lnk"
    Delete /REBOOTOK $INSTDIR\uninstall.exe
    Delete /REBOOTOK $INSTDIR\debug.log
    Delete /REBOOTOK $INSTDIR\db.log
    DeleteRegValue HKCU "${REGKEY}" StartMenuGroup
    DeleteRegValue HKCU "${REGKEY}" Path
@@ -139,4 +148,3 @@ Function un.onInit
    !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuGroup
    !insertmacro SELECT_UNSECTION Main ${UNSEC0000}
FunctionEnd

@@ -394,6 +394,14 @@ CMainFrame::~CMainFrame()
    ptaskbaricon = NULL;
}

void ExitTimeout(void* parg)
{
#ifdef __WXMSW__
    Sleep(5000);
    ExitProcess(0);
#endif
}

void Shutdown(void* parg)
{
    static CCriticalSection cs_Shutdown;
@@ -404,6 +412,7 @@ void Shutdown(void* parg)
        fFirstThread = !fTaken;
        fTaken = true;
    }
    static bool fExit;
    if (fFirstThread)
    {
        fShutdown = true;
@@ -411,13 +420,18 @@ void Shutdown(void* parg)
        DBFlush(false);
        StopNode();
        DBFlush(true);
        CreateThread(ExitTimeout, NULL);
        Sleep(10);
        printf("Bitcoin exiting\n\n");
        fExit = true;
        exit(0);
    }
    else
    {
        loop
            Sleep(100000);
        while (!fExit)
            Sleep(500);
        Sleep(100);
        ExitThread(0);
    }
}

