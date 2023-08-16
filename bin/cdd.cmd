@echo off
set dest=%*
if '%dest%'=='' goto :cdd
if qq%dest:~0,1%%dest:~-1%qq == qq""qq set dest=%dest:~1,-1%
if '%dest:~0,1%' == '~' set dest=%USERPROFILE%%dest:~1%
set dest="%dest%"
set OLDPWD="%cd%"
:cdd
set pushd_tmp=%TEMP%\pushd.tmp
set cdd_tmp_cmd=%TEMP%\cdd.tmp.cmd
pushd > %pushd_tmp%
%~dps0_cdd.exe %dest% < %pushd_tmp% > %cdd_tmp_cmd%
set dest=
%cdd_tmp_cmd%
