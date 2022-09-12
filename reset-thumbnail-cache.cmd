taskkill /f /im explorer.exe
pushd "%userprofile%\AppData\Local"
del IconCache.db
start explorer.exe
popd
