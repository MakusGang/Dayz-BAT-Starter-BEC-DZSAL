@echo off
TITLE Server Monitor
::----------------------------------------- SETs:
::Ports Servers:
SET ServerPortS=2302, 2402

rem SET ...DayZServer_x64.exe BecPORT.exe  DZSAL_PORT.exe CMDStop(TitleCMD) CMDStart(TitleCMD) - должны соответствовать/ не менять!!!
::Переменные для поиска задачь "tasklist /v" (можно добавить атрибут если нужно отслежавать другие задачи):
::--Set n-портов "Префиксы":
SET TaskNameDayZ=port
SET TaskNameBec=Bec
SET TaskNameDZSA=DZSAL_
SET TaskNameStop=Stop_
SET TaskNameStart=Start_
Set DirStatusUpdate=C:\GameServer\TestBat\Logs\StatusUpdate.log
SET DirBatFiles=C:\GameServer\TestBat\
SET BECPath=C:\GameServer\DayzServer\bec
::----Set без порта ="TitleName":
SET TaskNameUpdater=Updater

::-----Сеты дирикторий для копирования обновлений
SET ServerPatch=C:\GameServer\DayZServer
SET TemproryServer=C:\GameServer\DayZServerTemprory
SET TemproryMODs=C:\GameServer\DayZServerTemproryMODs
SET TemproryMODsBikey=C:\GameServer\DayZServerTemproryBikey
rem оставить во временном хранилище:
Set excludeCopyFiles="%TemproryServer%\docs" "%TemproryServer%\server_manager" 
:: ------------------------------------------------------
SET logFileStatusUpdate=C:\GameServer\TestBat\Logs\StatusUpdate.log

::END Sets------------------------------------------

SETLOCAL EnableDelayedExpansion

::----------------------------------------------------------------------------
:: ---- Проверки служб сервисов задач
Set TimerCh_Status=25
Set Start=30
Set TimerCh_Bec=30
:: не менее 20 сек:
Set TimerCh_Update=2400
Set Timer_StopServer=30
::------------------------------------
::  --- Директории пакетных файлов- BAT --
SET Updater=C:\GameServer\TestBat\AutoUpdateSteam.bat

Set t_status=0

Set t_update=0
set t_StopServer=0
set t_start=%Start%
Set t_BEC=0

goto CheckProcess




:timer
::Echo start timer
rem --------------------------------Запуск обновлений TimerCh_Update создает файл StatusUpdate.log -------------
if %t_update%==%TimerCh_Update% if %StatusTaskNameUpdater%==0 if %StatusUpdate%==0 Start %Updater% &Echo. &Echo          ------***Run Updater***-----
if %t_update%==%TimerCh_Update% Set t_update=0
rem --------------------------------END-Запуск обновлений TimerCh_Update------------------------------------------------

rem --------------------------------Start Server ----------------

if %t_start%==%Start% for %%s in (%ServerPortS%) do ( 
																   if !StartServer_%%s!==1 (set t_start=0& Set StartServer_%%s=0 & Start %DirBatFiles%start%%s.bat & Echo Start Start%%s) Else (
																    if %StatusUpdate%==1  Echo Не возможно запустить сервер, имеются обновлени для порта %%s  )
																	)
rem -------------------------------- UpdateServerFiles
if %t_start%==%Start% if %StatusUpdate%==1 set t_start=0 & goto UpdateFileServer

REM --------------------------------END Start Server ----------------
rem -------------------------------------------Strat BEC-------------------

if %t_BEC%==%TimerCh_Bec% for %%s in (%ServerPortS%) do (
												if !BecStart%%s!==1 (SET BecStart%%s=0 & cd "%BECPath%" & start Bec%%s.exe -f Config_%%s.cfg --dsc)
														)					
::Set BecStart%%s=0 & cd "%BECPath%" & start Bec%%s.exe -f Config%%s.cfg --dsc														
if %t_BEC%==%TimerCh_Bec% set t_BEC=0



rem --------------------kik user, shotdown server по всем портам, при условии, что DirStatusUpdate=1, и ServerDayz, Bec, DzSAL -работают, 
:: --------------------а updater, start - не работают.
if %t_StopServer%==%Timer_StopServer% Echo       *** Start stopservr*** &for %%s in (%ServerPortS%) do ( 
																   if !StopServer_%%s!==1 (Set StopServer_%%s=0 & Start %DirBatFiles%Stop%%s.bat & Echo Start %%s_Startstop)
																	)
if %t_StopServer%==%Timer_StopServer% set t_StopServer=0												
Rem --- END  -----------Kis? stop server



rem ---------------------------------*** ОПРОС СТАТУСОВ! ***
if %t_status%==%TimerCh_Status% Set t_status=0 &goto CheckProcess
rem ----------------------------------------------------------------------------------------------------------


::if %t2%==%TimerCh_Bec% Set t2=0 &Echo TimerCh_Bec :***%TimerCh_Bec%***

::timeout %TimeOutStep% >nul
timeout 1 >nul
::cls
Set /a t_status=%t_status%+1
Set /a Timeout_status=%TimerCh_Status%-%t_status%
Set /a t_start=%t_start%+1
Set /a t_update=%t_update%+1
Set /a timeout_update=%TimerCh_Update%-%t_update%
Set /a t_StopServer=%t_StopServer%+1
Set /a Timeout_StopServer=%Timer_StopServer%-%t_StopServer%
Set /a t_BEC=%t_BEC%+1

cls
Echo %0                                                              Код итерации:%RANDOM%
Echo.
Echo       Сервер активен %t_start% сек. 
Echo       - Проверка работы сервера каждые %Start% сек.                                   
ECHO       - Проверка BEC.................... каждые %TimerCh_Bec% сек..  - %t_BEC% - сек                                             
Echo       - Проверка обновлений стим репо... каждые %TimerCh_Update% сек. - %timeout_update% - сек.                          
if %StatusUpdate%==1 (
Echo       - Найдены обновления!
Echo       - Остановка сервера для обновления....................
) Else (
Echo       - Обновления отсутствуют.
Echo       Остоновка сервера не требуется. Следующая проверка через %Timeout_StopServer% сек.
)
Echo.
::прим.. !TaskNameDayZ_%%s! = TaskNameDayZ_2302(2302,2402...) = 1 или 0
Echo       Проверка статусов задач: %Timeout_status% сек.:
Echo       Имя задачи:    порт:    Статус: 
Echo.
for %%s in (%ServerPortS%) do (Echo       TaskNameDayZ   %%s            !TaskNameDayZ_%%s!)
for %%s in (%ServerPortS%) do (Echo       TaskNameBec    %%s            !TaskNameBec_%%s!)
for %%s in (%ServerPortS%) do (Echo       TaskNameDZSA   %%s            !TaskNameDZSA_%%s!)
for %%s in (%ServerPortS%) do (Echo       TaskNameStop   %%s            !TaskNameStop%%s!)
for %%s in (%ServerPortS%) do (Echo       TaskNameStart  %%s            !TaskNameStart%%s!)
Echo       TaskNameUpdater                %StatusTaskNameUpdater%
Echo       DirStatusUpdate                %StatusUpdate%
Echo.
if %t_status%==%TimerCh_Status% Echo       Опрос статусов: time***%TimerCh_Status%***
goto timer





::----------------------------------------------- Опрос работы сервисов, служб или задач  CheckProcess -----
:CheckProcess
::echo ----------------------------------------------- Ищим DayZServer_x64 по всем портам:
for %%d in (%TaskNameDayZ%) do (
		for  %%p in (%ServerPortS%) do (
			tasklist /v | find /i "%%d %%p" >nul
			if !ERRORLEVEL!==0 Set TaskNameDayZ_%%p=1
			if !ERRORLEVEL!==1 Set TaskNameDayZ_%%p=0& Set t_start=%start%&
	    )
)
::echo ----------------------------------------------- Ищим Bec___ по всем портам:
for %%d in (%TaskNameBec%) do (
		for  %%p in (%ServerPortS%) do (
			tasklist /v | find /i "%%d%%p" >nul
			if !ERRORLEVEL!==0 Set TaskNameBec_%%p=1
			if !ERRORLEVEL!==1 Set TaskNameBec_%%p=0
	    )		 
)
::echo ----------------------------------------------- Ищим DZSAL_ по всем портам:
for %%d in (%TaskNameDZSA%) do (
		for  %%p in (%ServerPortS%) do (
			tasklist /v | find /i "%%d%%p" >nul
			if !ERRORLEVEL!==0 Set TaskNameDZSA_%%p=1
			if !ERRORLEVEL!==1 Set TaskNameDZSA_%%p=0
	    )		 
)
::echo ----------------------------------------------- Ищим Stop по всем портам:
for %%d in (%TaskNameStop%) do (
		for  %%p in (%ServerPortS%) do (
			tasklist /v | find /i "%%d%%p" >nul
			if !ERRORLEVEL!==0 Set TaskNameStop%%p=1
			if !ERRORLEVEL!==1 Set TaskNameStop%%p=0
	    )
)
::echo ----------------------------------------------- Ищим Start по всем портам:
for %%d in (%TaskNameStart%) do (
		for  %%p in (%ServerPortS%) do (
			tasklist /v | find /i "%%d%%p" >nul
			if !ERRORLEVEL!==0 Set TaskNameStart%%p=1
			if !ERRORLEVEL!==1 Set TaskNameStart%%p=0
	    )		 
)
::echo ----------------------------------------------- Ищим TaskNameUpdater:
tasklist /v | find /i "Администратор:  %TaskNameUpdater%" >nul
			if !ERRORLEVEL!==0 Set StatusTaskNameUpdater=1
			if !ERRORLEVEL!==1 Set StatusTaskNameUpdater=0
::echo ----------------------------------------------- Ищим log файл наличия обновлений:

if not exist %DirStatusUpdate% Set StatusUpdate=0
if exist %DirStatusUpdate% Set StatusUpdate=1

::echo --------------------------------------------------------------------------

Echo.
Echo           Статусы для kik user, shotdown server:
rem -----------------------------------------------Status Kill - Stop Server
rem DirStatusUpdate=1, и ServerDayz, Bec, DzSAL :1   &  updater, start, stop :0.
for %%s in (%ServerPortS%) do ( Set S_port=%%s
    if %StatusUpdate%==1 if !TaskNameDayZ_%%s!==1 if !TaskNameBec_%%s!==1 if !TaskNameDZSA_%%s!==1 if %StatusTaskNameUpdater%==0 if !TaskNameStart%%s! ==0 if !TaskNameStop%%s!==0 (Set StopServer_%%s=1& Echo    %%s StfileUpdate, DayZ+, Bec+, DZSA+, TaskUpdater-, TaskStop-, TaskStart-  ***OK Kill and Shotdown***) 
)
rem -------------------------------------------END StatusStop: 0|1

rem -----------------------------------------------Status Start server-------------

for %%s in (%ServerPortS%) do (
    if %StatusUpdate%==0 if !TaskNameDayZ_%%s!==0 if !TaskNameBec_%%s!==0 if !TaskNameDZSA_%%s!==0 if !TaskNameStart%%s!==0 if !TaskNameStop%%s!==0 (Set StartServer_%%s=1& Echo %%s DayZ-, Bec-, DZSA-, TaskStop-, TaskStart-  ***OK Start Server*** & Echo     ***OK Start Server*** & Echo        ***OK Start Server***) 
)
Rem ----------------------------------------------END Status Start server----------

REM -------------------------------Stert BEC---------------
for %%s in (%ServerPortS%) do (
    if !TaskNameDayZ_%%s!==1 if !TaskNameBec_%%s!==0 if !TaskNameStart%%s!==0 if !TaskNameStop%%s!==0 (Set BecStart%%s=1& Echo %%s DayZ+, Bec-, TaskStop-, TaskStart-  ***OK Sart BEC) 
)



goto timer
::--------------------------------------------------------------------------------------------------------
::----------------------------UpdateFileServer----------
:UpdateFileServer

Echo           Обновляем файлы сервера!!

timeout 5 >nul
rem ------------ Копируем серверные файлы:
robocopy "%TemproryServer%" "%ServerPatch%" *.* /xd %excludeCopyFiles% /E /TEE /LOG+:%LogDirRobocopy%%date%LogSRV.log
robocopy "%TemproryMODs%" "%ServerPatch%" *.* /E /TEE /LOG+:%LogDirRobocopy%%date%LogSRV.log
robocopy "%TemproryMODsBikey%" "%ServerPatch%" *.* /E /TEE /LOG+:%LogDirRobocopy%%date%LogSRV.log

:: В цикле подставить номер порта
For %%s in (%ServerPortS%) do (xcopy %TemproryServer%\battleye\*.* %ServerPatch%\battleye_%%s\ /f /s /e /y
									copy %TemproryServer%\DayZServer_x64.exe %ServerPatch%\DayZ_%%s.exe /v /y
									)
del %logFileStatusUpdate%
Set StatusUpdate=0

goto timer
endlocal


