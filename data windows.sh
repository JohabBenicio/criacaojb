ECHO TIME IS %TIME%
ECHO DATE IS %DATE%

set hour=%time:~0,2%
set mn=%TIME:~3,2%
set sc=%TIME:~6,2%
set msec=%TIME:~9,2%
if %hour% equ 0: set hour=00
echo.
set day=%date:~0,2%
set mth=%DATE:~3,2%
set yr=%DATE:~6,4%
echo.
set datefolder=%day%-%mth%-%yr%_%hour%-%mn%-%sc%

echo %datefolder%
