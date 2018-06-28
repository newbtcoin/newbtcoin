@@ -52,7 +52,7 @@ bool DecodeAddress(string str, CAddress& addr)
static bool Send(SOCKET hSocket, const char* pszSend)
{
    if (strstr(pszSend, "PONG") != pszSend)
        printf("SENDING: %s\n", pszSend);
        printf("IRC SENDING: %s\n", pszSend);
    const char* psz = pszSend;
    const char* pszEnd = psz + strlen(psz);
    while (psz < pszEnd)
@@ -145,7 +145,7 @@ bool Wait(int nSeconds)
{
    if (fShutdown)
        return false;
    printf("Waiting %d seconds to reconnect to IRC\n", nSeconds);
    printf("IRC waiting %d seconds to reconnect\n", nSeconds);
    for (int i = 0; i < nSeconds; i++)
    {
        if (fShutdown)
@@ -220,7 +220,6 @@ void ThreadIRCSeed(void* parg)
        {
            if (strLine.empty() || strLine.size() > 900 || strLine[0] != ':')
                continue;
            printf("IRC %s\n", strLine.c_str());

            vector<string> vWords;
            ParseString(strLine, ' ', vWords);
@@ -235,7 +234,7 @@ void ThreadIRCSeed(void* parg)
                // index 7 is limited to 16 characters
                // could get full length name at index 10, but would be different from join messages
                strcpy(pszName, vWords[7].c_str());
                printf("GOT WHO: [%s]  ", pszName);
                printf("IRC got who\n");
            }

            if (vWords[1] == "JOIN" && vWords[0].size() > 1)
@@ -244,7 +243,7 @@ void ThreadIRCSeed(void* parg)
                strcpy(pszName, vWords[0].c_str() + 1);
                if (strchr(pszName, '!'))
                    *strchr(pszName, '!') = '\0';
                printf("GOT JOIN: [%s]  ", pszName);
                printf("IRC got join\n");
            }

            if (pszName[0] == 'u')
@@ -254,7 +253,7 @@ void ThreadIRCSeed(void* parg)
                {
                    CAddrDB addrdb;
                    if (AddAddress(addrdb, addr))
                        printf("new  ");
                        printf("IRC got new address\n");
                    else
                    {
                        // make it try connecting again
@@ -262,14 +261,13 @@ void ThreadIRCSeed(void* parg)
                            if (mapAddresses.count(addr.GetKey()))
                                mapAddresses[addr.GetKey()].nLastFailed = 0;
                    }
                    addr.print();

                    CRITICAL_BLOCK(cs_mapIRCAddresses)
                        mapIRCAddresses.insert(make_pair(addr.GetKey(), addr));
                }
                else
                {
                    printf("decode failed\n");
                    printf("IRC decode failed\n");
                }
            }
        }
