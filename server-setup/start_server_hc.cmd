@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
SET me=%~n0

SET moddir=mods_cnto

REM for cycles are not parsed in the first parser run, so they need
REM all variables escaped ... and if you need variables dynamically
REM expanded, you need to do it in the second pass (delayed expansion)
REM and use !var! instead of %var%

SET "mods="
FOR /D %%I IN (%moddir%\*) DO (
	SET name=%%~nI
	IF "!name:~0,1!"=="@" SET "mods=!mods!%moddir%\!name!;"
)

@ECHO ON

:restart

START arma3server.exe -client ^
	-connect=127.0.0.1 -port=2302 -password=cnto ^
	-profiles=profiles ^
	-nosplash ^
	-nologs ^
	-world=empty ^
	-mod=%mods%

START /W arma3server.exe ^
	-port=2302 ^
	-config=server.cfg ^
	-profiles=profiles -name=server ^
	-nosplash ^
	-world=empty ^
	-filePatching ^
	-mod=%mods% ^
	-serverMod=servermods_cnto\@ocap

TASKKILL /F /IM arma3server.exe

TIMEOUT /T 60 /NOBREAK > NUL

GOTO restart
