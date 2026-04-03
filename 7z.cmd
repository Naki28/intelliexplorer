@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "archive="
set "outdir="

for %%A in (%*) do (
	set "arg=%%~A"
	if /I not "!arg!"=="x" (
		if /I "!arg:~0,2!"=="-o" (
			set "outdir=!arg:~2!"
		)
		if /I not "!arg:~0,2!"=="-o" (
			if not defined archive (
				set "archive=!arg!"
			)
		)
	)
)

if not defined archive (
	echo Missing archive path.
	exit /b 1
)

if not defined outdir (
	echo Missing output directory.
	exit /b 1
)

if not exist "%outdir%" mkdir "%outdir%"
tar -xf "%archive%" -C "%outdir%"
exit /b %ERRORLEVEL%