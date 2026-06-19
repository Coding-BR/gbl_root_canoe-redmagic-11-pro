::Main launcher script.

::Do not modify this startup section.
@ECHO OFF
chcp 936>nul
cd /d %~dp0
if exist bin (cd bin) else (ECHO.Cannot find bin. Check that the tool was fully extracted and the script path is correct. & goto FATAL)

::Load configuration files.
if exist conf\fixed.bat (call conf\fixed) else (ECHO.Cannot find conf\fixed.bat & goto FATAL)
if exist conf\user.bat call conf\user
if not "%product%"=="" (if exist conf\dev-%product%.bat call conf\dev-%product%.bat)

::Load theme.
if "%framework_theme%"=="" set framework_theme=default
call framework theme %framework_theme%
COLOR %c_i%

::,
TITLE Starting tool...
mode con cols=71

::Check and request administrator permission.
if not exist tool\Win\gap.exe ECHO.Cannot find gap.exe. Check that the tool was fully extracted and the script path is correct. & goto FATAL
tool\Win\gap.exe %0 || EXIT

::Run startup checks.
call framework startpre
::call framework startpre skiptoolchk

::Startup complete.
TITLE [No device selected] ZTE Family Toolbox %prog_ver% by Mouzei [Always free - resale prohibited]
CLS
if "%product%"=="" goto SELDEV
if not exist conf\dev-%product%.bat goto SELDEV
goto MENU



:MENU
TITLE [%model%] ZTE Family Toolbox %prog_ver% by Mouzei [Always free - resale prohibited]
if not exist res\%product%\bak md res\%product%\bak
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.ZTE Family Toolbox %prog_ver% by Mouzei [Always free - resale prohibited]
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.
ECHOC {%c_w%}[%model%]{%c_i%} %cpu%{%c_i%}{\n}
ECHOC {%c_we%}If the device model is incorrect, use "Select device model" first{%c_i%}{\n}
ECHO.
ECHO.
ECHO.^< Warning: Root and other unofficial firmware operations require an unlocked bootloader, otherwise the device may brick! ^>
ECHO.
ECHO.0.Unlock bootloader           000.Lock bootloader (not recommended)
ECHO.1.Get Root         111.Root boot-failure recovery
ECHO.2.9008 flash full package
ECHO.3.Flash Recovery (TWRP)
ECHO.4.Back up all partitions
ECHO.
::ECHO.10.Nubia temporary unlock  11.Send 9008 programmer
::ECHO.11.Send 9008 programmer    
ECHO.14.ADB screen mirror
ECHO.12.Flash any partition    13.Read any partition
::ECHO.         15.Temporarily enter full Fastboot
ECHO.16.View / set slot  17.Back up / restore QCN
ECHO.18.Snapdragon 8E5 bootloader-bypass + keep fingerprint  19.Clear efisp partition (remove boot text)
ECHO.20.Clear frp partition
ECHO.21.Experimental: gbl_root_canoe superfastboot payload (NX809J)
ECHO.
ECHO.A.Open backup folder
ECHO.B.Select device model
ECHO.C.Check for updates (password: ebxn)
ECHO.D.Change theme
ECHO.
ECHO.E.ZTE / Nubia / REDMAGIC support and feedback group
ECHO.F.Yinghuochong flashing resources site (download 9008 packages, TWRP and other flashing resources)
ECHO.G.About BFF
ECHO.
call input choice [0][000][1][111][2][3][4][12][13][14][16][17][18][19][20][21][A][B][C][D]#[E][F][G]
if "%choice%"=="0" goto UNLOCKBL
if "%choice%"=="000" goto LOCKBL
if "%choice%"=="1" goto ROOT
if "%choice%"=="111" goto ROOT-REC
if "%choice%"=="2" goto EDLFLASHFULL
if "%choice%"=="3" goto FLASHREC
if "%choice%"=="4" goto BAKALL
if "%choice%"=="10" goto NUBIAUNLOCK
if "%choice%"=="11" goto EDLSENDFH
if "%choice%"=="12" goto WRITEPAR
if "%choice%"=="13" goto READPAR
if "%choice%"=="14" call scrcpy ZTE Family Toolbox-ADB screen mirror
if "%choice%"=="15" goto ENTERDBGFB
if "%choice%"=="16" goto SLOT
if "%choice%"=="17" goto QCN
if "%choice%"=="18" goto 8E5CUSTOMIZEDBL
if "%choice%"=="19" goto CLEANEFISP
if "%choice%"=="20" goto CLEANFRP
if "%choice%"=="21" goto 8E5CUSTOMIZEDBL_OURS
if "%choice%"=="A" call open folder res\%product%\bak
if "%choice%"=="B" goto SELDEV
if "%choice%"=="C" call open common https://syxz.lanzoue.com/b01g0i33c
if "%choice%"=="D" goto THEME
if "%choice%"=="E" start "" "https://yhfx.jwznb.com/share?key=BBmdd7wE9CNv&ts=1707895931 "
if "%choice%"=="F" call open common https://www.yhcres.top/
if "%choice%"=="G" call open common https://gitee.com/mouzei/bff
goto MENU



:CLEANFRP
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Clear frp partition
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.-Description:
ECHO. Used to solve issues caused by not removing the Google account before flashing, which may prevent app installation (still needs testing)
ECHO.
ECHOC {%c_h%}After reading the information above, press any key to start...{%c_i%}{\n}& pause>nul
ECHOC {%c_h%}Please enter 9008 mode...{%c_i%}{\n}& call chkdev qcedl rechk 1
ECHO.Clearing frp... & call write qcedl frp tool\Other\frp_empty.img %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
ECHO.Reboot... & call reboot qcedl system
ECHOC {%c_s%}done. {%c_h%}Press any key to return...{%c_i%}{\n}& pause>nul & goto MENU


:CLEANEFISP
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Clearing efisppartition (boot)
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
if not "%blplan%"=="efisp" ECHO.%model%is not supported for this function. Press any key to return... & pause>nul & goto MENU
ECHO. [%model%]
ECHO.
ECHO.-Description:
ECHO. Small text on the first boot screen means a program is running from the efisp partition
ECHO. Most 9008 packages do not flash efisp, so this function is provided separately
ECHO. The efisp partition is normally empty; clearing it restores the original state
ECHO. Command erase may be unreliable; this writes an empty partition image to fully clear it
ECHO. Except for bypass-unlock use, efisp programs are not needed after normal unlock/lock operations; clearing is recommended
ECHO. Clear means wiping the partition contents, not deleting the partition itself
ECHO. 
ECHOC {%c_h%}After reading the information above, press any key to start...{%c_i%}{\n}& pause>nul
ECHOC {%c_h%}Please enter 9008 mode...{%c_i%}{\n}& call chkdev qcedl rechk 1
ECHO.Clearing efisp... & call write qcedl efisp tool\Other\8e5gbl\efisp_empty.img %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
ECHO.Reboot... & call reboot qcedl system
ECHOC {%c_s%}done. {%c_h%}Press any key to return...{%c_i%}{\n}& pause>nul & goto MENU


:8E5CUSTOMIZEDBL
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Snapdragon 8E5 bootloader-bypass + keep fingerprint
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
if not "%blplan%"=="efisp" ECHO.%model%is not supported for this function. Press any key to return... & pause>nul & goto MENU
ECHO. [%model%]
ECHO.
ECHO.-Notes:
ECHO. Flashes a custom bootloader that boots from efisp instead of the official abl, allowing system modification without unlocking
ECHO. Because of this mechanism, clearing efisp after using this function will disable it
ECHO. On locked devices, this allows flashing third-party partitions directly through 9008, including Root
ECHO. On unlocked devices, this may keep fingerprint working
ECHO. This function does not wipe data, but backing up important data is still recommended
ECHO. Some verification may remain, so third-party flashing without unlock is not guaranteed to boot
ECHO. If the current system has patched the efisp vulnerability, this function will not work
ECHO. To remove the bypass program, use the toolbox "Clear efisp partition" function
ECHO.
ECHOC {%c_h%}After reading the information above, press any key to start...{%c_i%}{\n}& pause>nul
ECHO.
ECHOC {%c_h%}Please enter 9008 mode...{%c_i%}{\n}& call chkdev qcedl rechk 1
ECHO.Flashing bypass program... & call write qcedl efisp tool\Other\8e5gbl\gbl_superfastboot.efi %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
ECHO.Reboot... & call reboot qcedl system
ECHOC {%c_s%}done. {%c_h%}Press any key to return...{%c_i%}{\n}& pause>nul & goto MENU


:8E5CUSTOMIZEDBL_OURS
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Experimental gbl_root_canoe superfastboot payload
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
if not "%blplan%"=="efisp" ECHO.%model%is not supported for this function. Press any key to return... & pause>nul & goto MENU
if not "%product%"=="NX809J" ECHO.This reconstructed payload was built for NX809J only. Current product: %product%. Press any key to return... & pause>nul & goto MENU
if not exist tool\Other\8e5gbl_ours\ABL_with_superfastboot_NX809J.efi ECHO.Cannot find reconstructed payload. Press any key to return... & pause>nul & goto MENU
ECHO. [%model%]
ECHO.
ECHO.-Notes:
ECHO. This flashes our reconstructed gbl_root_canoe ABL_with_superfastboot payload to efisp
ECHO. It is intended to replicate the original toolbox efisp bypass path using our build
ECHO. Built input: bin\res\NX809J\abl_unlock.img
ECHO. Output: tool\Other\8e5gbl_ours\ABL_with_superfastboot_NX809J.efi
ECHO. Use option 19 to clear efisp if the bypass must be removed
ECHO.
ECHOC {%c_h%}After reading the information above, press any key to start...{%c_i%}{\n}& pause>nul
ECHO.
ECHOC {%c_h%}Please enter 9008 mode...{%c_i%}{\n}& call chkdev qcedl rechk 1
ECHO.Flashing reconstructed bypass program... & call write qcedl efisp tool\Other\8e5gbl_ours\ABL_with_superfastboot_NX809J.efi %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
ECHO.Reboot... & call reboot qcedl system
ECHOC {%c_s%}done. {%c_h%}Press any key to return...{%c_i%}{\n}& pause>nul & goto MENU


:QCN
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Back up / restore QCN
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO. [%model%]
ECHO.
ECHO.QCN contains baseband, serial number and related device information. This is equivalent to QFIL QCN functions and requires Root.
ECHO.
ECHO.1.Back up QCN   2.Restore QCN   A.Return to main menu
ECHO.
call input choice [1][2][A]
ECHO.
if "%choice%"=="A" goto MENU
if "%choice%"=="1" goto QCN-READ
if "%choice%"=="2" goto QCN-WRITE
EXIT
:QCN-READ
ECHOC {%c_h%}Boot the device and enable USB debugging...{%c_i%}{\n}& call chkdev system rechk 1
ECHO.Opening baseband debug port... & call reboot system qcdiag rechk 1
for /f %%a in ('gettime.exe') do set baktime=%%a
ECHO.Backing up QCN to bin\res\%product%\bak\qcnbak_%baktime%.qcn . This may take a long time, please wait patiently... & call read qcdiag %chkdev__port__qcdiag% res\%product%\bak\qcnbak_%baktime%.qcn
goto QCN-DONE
:QCN-WRITE
ECHOC {%c_h%}Please select the QCN file to restore...{%c_i%}{\n}& call sel file s %framework_workspace%\res\%product%\bak [qcn]
ECHOC {%c_h%}Boot the device and enable USB debugging...{%c_i%}{\n}& call chkdev system rechk 1
ECHO.Opening baseband debug port... & call reboot system qcdiag rechk 1
ECHO.Restore QCN. This may take a long time, please wait patiently... & call write qcdiag %chkdev__port__qcdiag% %sel__file_path%
goto QCN-DONE
:QCN-DONE
ECHOC {%c_s%}done. {%c_h%}Press any key to return...{%c_i%}{\n}& pause>nul & goto MENU


:BAKALL
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Back up all partitions
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO. [%model%]
ECHO.
ECHO.-Notes:
ECHO. This function backs up all device partitions except userdata and last_parti, plus the partition table
ECHO. The backup does not include user data
ECHO. XML files are generated after backup and can be flashed with the "9008 flash full package" function
ECHO. Full partition backups contain serial, sensors and other device-specific partitions, so use only on the original device
ECHO. Keeping a full partition backup helps prevent unrecoverable device loss
ECHO.
ECHOC {%c_h%}After reading the information above, press any key to start...{%c_i%}{\n}& pause>nul
ECHO.
ECHOC {%c_h%}Please select a save location...{%c_i%}{\n}& call sel folder s %framework_workspace%\..
ECHOC {%c_h%}Please enter 9008 mode...{%c_i%}{\n}& call chkdev qcedl rechk 1
for /f %%a in ('gettime.exe ^| find "."') do set baktime=%%a
md %sel__folder_path%\ZTEToolBoxParBak_%baktime% 1>nul || ECHOC {%c_e%}%sel__folder_path%\ZTEToolBoxParBak_%baktime%failed{%c_i%}{\n}&& goto FATAL
start framework logviewer start %logfile%
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
ECHO.Reading all partitions through 9008... & call ztetoolbox edlreadall %chkdev__port__qcedl% %sel__folder_path%\ZTEToolBoxParBak_%baktime%
ECHO.9008 full partition read completed. rebooting phone... & call reboot qcedl system
call framework logviewer end
ECHOC {%c_s%}done. {%c_h%}Press any key to return...{%c_i%}{\n}& pause>nul & goto MENU


:SLOT
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.View / set slot
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO. [%model%]
ECHO.
if "%parlayout%"=="aonly" ECHO.%model%does not need this function. Press any key to return... & pause>nul & goto MENU
set slot__a_unbootable=& set slot__b_unbootable=
ECHOC {%c_h%}Put the device into system, Recovery, Fastboot or 9008 mode...{%c_i%}{\n}& call chkdev all
::if not "%chkdev__mode%"=="system" (if not "%chkdev__mode%"=="recovery" (if not "%chkdev__mode%"=="fastboot" ECHOC {%c_e%}Wrong mode, enter system, Recovery or Fastboot mode. {%c_h%}Press any key to retry...{%c_i%}{\n}& call log %logger% E modeerror:%chkdev__mode%.systemRecoveryFastbootmode& pause>nul & ECHO.Retry... & goto SLOT))
if "%chkdev__mode%"=="qcedl" ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port% %framework_workspace%\res\%product%\devprg %storagetype%
ECHO.Checking slot... & call slot %chkdev__mode% chk
ECHO.
    ECHOC {%c_i%}Current slot: %slot__cur%{%c_i%}
    if "%slot__cur_unbootable%"=="yes" ECHOC {%c_e%}(unbootable){%c_i%}
    ECHOC {%c_i%}   {%c_i%}
    ECHOC {%c_i%}Other slot: %slot__cur_oth%{%c_i%}
    if "%slot__cur_unbootable%"=="yes" ECHOC {%c_e%}(unbootable){%c_i%}
    ECHOC {%c_i%}{\n}
ECHO.
ECHO.A.Activate slot a   B.Activate slot b   C.Return to main menu
ECHO.
call input choice [A][B]#[C]
if "%choice%"=="A" set target=a
if "%choice%"=="B" set target=b
if "%choice%"=="C" goto MENU
ECHO.Setting slot to %target% ... & call slot %chkdev__mode% set %target%
if "%chkdev__mode%"=="qcedl" call reboot qcedl qcedl
goto SLOT


:FLASHREC
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Flash Recovery (TWRP)
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO. [%model%]  Partition layout: %parlayout%
ECHO.
ECHO.-Notes:
ECHO. This function requires an unlocked bootloader
if not "%parlayout%"=="ab" ECHO. Official boot may restore the stock recovery on boot. Rooting first can avoid this.
ECHO.
ECHO.1.flash   2.Temporary Fastboot boot   3.Inject TWRP into boot image (for devices without recovery)
ECHO.A.Download TWRP   B.Return to main menu
ECHO.
call input choice #[1][2][3][A][B]
if "%choice%"=="1" set func=flash
if "%choice%"=="2" set func=boot
if "%choice%"=="3" set func=recinst
if "%choice%"=="A" call open common https://yhcres.top/ & call open common https://twrp.me/Devices/ & goto FLASHREC
if "%choice%"=="B" goto MENU
ECHO.
goto FLASHREC-%func%
:FLASHREC-RECINST
if not "%parlayout%"=="ab" ECHO.%model% does not need this function. Press any key to return... & pause>nul & goto FLASHREC
ECHOC {%c_h%}Please select the TWRP image file...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [img]
set recpath=%sel__file_path%
ECHOC {%c_h%}Please select the boot image file...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [img]
set bootpath=%sel__file_path%
ECHOC {%c_h%}Please select where to save the new boot file...{%c_i%}{\n}& call sel folder s %framework_workspace%\..
ECHO.Injecting recovery... & call imgkit recinst %bootpath% %sel__folder_path%\boot_new.img %recpath%
ECHO.New boot image is at%sel__folder_path%\boot_new.img.
goto FLASHREC-DONE
:FLASHREC-BOOT
ECHOC {%c_h%}Please select the TWRP image file...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [img]
ECHOC {%c_h%}Please enter Fastboot...{%c_i%}{\n}& call chkdev fastboot
ECHO.Temporary boot... & call write fastbootboot %sel__file_path%
goto FLASHREC-DONE
:FLASHREC-FLASH
ECHOC {%c_h%}Please select the TWRP image file...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [img]
ECHOC {%c_h%}Boot the device and enable USB debugging...{%c_i%}{\n}& call chkdev system rechk 1
if not "%parlayout%"=="aonly" ECHO.Reading slot information... & call slot system chk
ECHO.Current slot: %slot__cur%
ECHO.Rebooting to 9008... & call reboot system qcedl rechk 1
goto FLASHREC-FLASH-%parlayout%
:FLASHREC-FLASH-AONLY
ECHO.Backing up currentrecovery...
for /f %%a in ('gettime.exe ^| find "."') do set baktime=%%a
call read qcedl recovery res\%product%\bak\recovery_%baktime%.img notice %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
ECHO.File backed up tobin\res\%product%\bak\recovery_%baktime%.img.
ECHO.Flashing recovery... & call write qcedl recovery %sel__file_path%
goto FLASHREC-FLASH-DONE
:FLASHREC-FLASH-AB_REC
ECHO.Backing up currentrecovery_%slot__cur%...
for /f %%a in ('gettime.exe ^| find "."') do set baktime=%%a
call read qcedl recovery_%slot__cur% res\%product%\bak\recovery_%slot__cur%_%baktime%.img notice %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
ECHO.File backed up tobin\res\%product%\bak\recovery_%slot__cur%_%baktime%.img.
ECHO.Flashing recovery_%slot__cur%... & call write qcedl recovery_%slot__cur% %sel__file_path%
goto FLASHREC-FLASH-DONE
:FLASHREC-FLASH-AB
ECHO.Backing up currentboot_%slot__cur%...
for /f %%a in ('gettime.exe ^| find "."') do set baktime=%%a
call read qcedl boot_%slot__cur% res\%product%\bak\boot_%slot__cur%_%baktime%.img notice %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
ECHO.File backed up tobin\res\%product%\bak\boot_%slot__cur%_%baktime%.img.
ECHO.Injecting recovery... & call imgkit recinst %framework_workspace%\res\%product%\bak\boot_%slot__cur%_%baktime%.img %tmpdir%\boot_rec.img %sel__file_path% noprompt
ECHO.flashboot_%slot__cur%... & call write qcedl boot_%slot__cur% %tmpdir%\boot_rec.img
goto FLASHREC-FLASH-DONE
:FLASHREC-FLASH-DONE
ECHO.
ECHO.1.Rebooting to Recovery   2.Do not reboot
call input choice #[1][2]
if "%choice%"=="1" ECHO.Rebooting to Recovery... & call reboot qcedl recovery
goto FLASHREC-DONE
:FLASHREC-DONE
ECHO. & ECHOC {%c_s%}done. {%c_h%}Press any key to return...{%c_i%}{\n}& pause>nul & goto FLASHREC


:NUBIAUNLOCK
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Nubia temporary unlock
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
if not "%product:~0,2%"=="NX" ECHO.%model% does not need this function. Press any key to return... & pause>nul & goto MENU
ECHOC {%c_h%}Please enter Fastboot...{%c_i%}{\n}& call chkdev fastboot
ECHO.fastboot.exe oem nubia_unlock NUBIA_%product% & ECHO.
fastboot.exe oem nubia_unlock NUBIA_%product%
ECHO. & ECHO.done. Press any key to return... & pause>nul & goto MENU


:READPAR
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Read any partition
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Can be used in system (Root required), TWRP, or 9008 mode
ECHO.Enter exit to return to the main menu
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHOC {%c_h%}Please select where to save the readback file...{%c_i%}{\n}& call sel folder s %framework_workspace%\..
ECHO.
:READPAR-1
ECHOC {%c_i%}=--------------------------------------------------------------------={%c_i%}{\n}
if not "%parname%"=="" ECHO.Last: %parname%
ECHOC {%c_h%}Partition name: {%c_i%}& set /p parname=
if "%parname%"=="" goto READPAR-1
if "%parname%"=="exit" goto MENU
:READPAR-2
call chkdev all
ECHO.Reading... & call read %chkdev__mode% %parname% %sel__folder_path%\%parname%.img notice %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
if "%chkdev__mode%"=="qcedl" call reboot qcedl qcedl
ECHOC {%c_s%}Readback completed{%c_i%}{\n}& goto READPAR-1


:WRITEPAR
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Flash any partition
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Can be used in system (Root required), TWRP, Fastboot, or 9008 mode
ECHO.Enter exit to return to the main menu
ECHO.
:WRITEPAR-1
ECHOC {%c_i%}=--------------------------------------------------------------------={%c_i%}{\n}
if not "%parname%"=="" ECHO.Last: %parname%
ECHOC {%c_h%}Partition name: {%c_i%}& set /p parname=
if "%parname%"=="" goto WRITEPAR-1
if "%parname%"=="exit" goto MENU
if "%imgfolder%"=="" set imgfolder=%framework_workspace%\..
ECHOC {%c_h%}Please select the %parname% partition file...{%c_i%}{\n}& call sel file s %imgfolder%
set imgfolder=%sel__file_folder%
:WRITEPAR-2
call chkdev all
ECHO.Flashing... & call write %chkdev__mode% %parname% %sel__file_path% %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
if "%chkdev__mode%"=="qcedl" call reboot qcedl qcedl
ECHOC {%c_s%}Flash completed{%c_i%}{\n}& goto WRITEPAR-1


:EDLFLASHFULL
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.9008 flash full package
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO. [%model%]  Partition layout: %parlayout%   Storage type: %storagetype%
ECHO.
if not exist %framework_workspace%\res\%product%\devprg\prog_firehose_ddr.elf ECHO.Tip: This function is no longer maintained. The graphical GeekFlashTool is recommended for 9008 unbrick flashing. & ECHO.Download: gitee.com/geekflashtool & ECHO.
ECHO.-Notes
ECHO. This function is equivalent to QFIL 9008 flashing
ECHO. Extract the 9008 package before use
ECHO. Back up all personal data before flashing
ECHO. Before flashing, disable Find Device, remove fingerprints, remove lock-screen password, and sign out of accounts
ECHO. If an official 9008 package fails, try deleting userdata.img from it, reopen the tool, and try again
ECHO. If it does not boot after flashing, try a factory reset
ECHO.
ECHOC {%c_h%}Press any key to start...{%c_i%}{\n}& pause>nul
ECHO.
set alreadypreedl=n
:EDLFLASHFULL-1
ECHOC {%c_h%}Please select the folder containing 9008 partition images and XML files...{%c_i%}{\n}& call sel folder s %framework_workspace%\..
if "%alreadypreedl%"=="y" goto EDLFLASHFULL-3
set fhpath=%framework_workspace%\res\%product%\devprg
if not exist %framework_workspace%\res\%product%\devprg ECHOC {%c_h%}Please select the programmer file...{%c_i%}{\n}& call sel file s %sel__folder_path% [elf][mbn]
if not exist %framework_workspace%\res\%product%\devprg set fhpath=%sel__file_path%
ECHOC {%c_h%}Please enter 9008 mode. If the last flash failed, close the script, re-enter 9008, then start flashing again...{%c_i%}{\n}& call chkdev qcedl rechk 1
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %fhpath% %storagetype%
set alreadypreedl=y
:EDLFLASHFULL-3
ECHO.Checking files...
goto EDLFLASHFULL-%storagetype%
:EDLFLASHFULL-UFS
    if exist %sel__folder_path%\rawprogram0.xml (set xmls=rawprogram0.xml) else (goto EDLFLASHFULL-FILENOTFOUND)
    if exist %sel__folder_path%\patch0.xml set xmls=%xmls%/patch0.xml
    if exist %sel__folder_path%\rawprogram1.xml (set xmls=%xmls%/rawprogram1.xml) else (goto EDLFLASHFULL-FILENOTFOUND)
    if exist %sel__folder_path%\patch1.xml set xmls=%xmls%/patch1.xml
    if exist %sel__folder_path%\rawprogram2.xml (set xmls=%xmls%/rawprogram2.xml) else (goto EDLFLASHFULL-FILENOTFOUND)
    if exist %sel__folder_path%\patch2.xml set xmls=%xmls%/patch2.xml
    if exist %sel__folder_path%\rawprogram3.xml (set xmls=%xmls%/rawprogram3.xml) else (goto EDLFLASHFULL-FILENOTFOUND)
    if exist %sel__folder_path%\patch3.xml set xmls=%xmls%/patch3.xml
    if exist %sel__folder_path%\rawprogram4.xml (set xmls=%xmls%/rawprogram4.xml) else (goto EDLFLASHFULL-FILENOTFOUND)
    if exist %sel__folder_path%\patch4.xml set xmls=%xmls%/patch4.xml
    if exist %sel__folder_path%\rawprogram5.xml (set xmls=%xmls%/rawprogram5.xml) else (goto EDLFLASHFULL-FILENOTFOUND)
    if exist %sel__folder_path%\patch5.xml set xmls=%xmls%/patch5.xml
goto EDLFLASHFULL-2
:EDLFLASHFULL-EMMC
    if not exist %sel__folder_path%\rawprogram0.xml goto EDLFLASHFULL-FILENOTFOUND
    set xmls=rawprogram0.xml
    if exist %sel__folder_path%\patch0.xml set xmls=%xmls%/patch0.xml
goto EDLFLASHFULL-2
:EDLFLASHFULL-2
ECHO.The following XML files will be used: & ECHOC {%c_we%}%xmls%{%c_i%}{\n}
start framework logviewer start %logfile%
ECHO.Starting 9008 flashing... & call write qcedlxml %chkdev__port__qcedl% %storagetype% %sel__folder_path% %xmls%
ECHO.setbootablestoragedrive... & call ztetoolbox edlsetbootablestoragedrive %chkdev__port__qcedl% %storagetype%
ECHO.done.
call framework logviewer end
ECHO.
ECHO.1.Reboot to system()   2.Wipe data and boot
call input choice #[1][2]
ECHO.
if "%choice%"=="2" ECHO.flashmisc... & call write qcedl misc tool\Android\misc_wipedata.img %chkdev__port__qcedl%
ECHO.Reboot... & call reboot qcedl system
ECHO.
ECHOC {%c_s%}All done. {%c_i%}If the device does not boot or the system is abnormal, try entering official Recovery and wipe data manually. {%c_h%}Press any key to return...{%c_i%}{\n}& pause>nul & goto MENU
:EDLFLASHFULL-FILENOTFOUND
ECHOC {%c_e%}The selected folder lacks required files such as rawprogram0.xml. Check that the folder is correct. {%c_h%}Keep the device connected and press any key to select again...{%c_i%}{\n}& pause>nul & goto EDLFLASHFULL-1


:ROOT-REC
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Root boot-failure recovery
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO. [%model%]   Recovery plan: restore%bootpar%
ECHO.
ECHO.-Notes
ECHO. Use this to restore the automatically backed-up %bootpar% if the device fails to boot after rooting with this toolbox.
if "%parlayout:~0,2%"=="ab" ECHO. The backup file will be flashed to both A/B slots.
ECHO.
ECHOC {%c_h%}Press any key to start...{%c_i%}{\n}& pause>nul
ECHO.
ECHOC {%c_h%}Please select the %bootpar% backup file to restore...{%c_i%}{\n}& call sel file s %framework_workspace%\res\%product%\bak [img]
ECHOC {%c_h%}Please manually enter 9008 mode...{%c_i%}{\n}& call chkdev qcedl rechk 1
if "%parlayout:~0,2%"=="ab" (
    ECHO.flash%bootpar%_a... & call write qcedl %bootpar%_a %sel__file_path% %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
    ECHO.flash%bootpar%_b... & call write qcedl %bootpar%_b %sel__file_path% %chkdev__port__qcedl%)
if not "%parlayout:~0,2%"=="ab" ECHO.flash%bootpar%... & call write qcedl %bootpar% %sel__file_path% %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
ECHO.Reboot... & call reboot qcedl system
ECHO.
ECHOC {%c_s%}All done. {%c_h%}Press any key to return...{%c_i%}{\n}& pause>nul & goto MENU


:ROOT
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Get Root
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO. [%model%]   Root method: Magisk patch%bootpar%
ECHO.
ECHO.-Notes
ECHO. Unlock the bootloader before Root
ECHO. This function currently only supports Magisk patching
ECHO. This function does not wipe data and is system-version independent
ECHO. Use carefully on already-rooted devices to avoid Magisk version conflicts causing boot failure
ECHO. To flash another Magisk version, restore the official %bootpar% partition first
ECHO. If the device does not boot after Root, use Root boot-failure recovery
ECHO.
ECHO.
ECHO.1.[Recommended] Use the toolbox built-in Magisk patch
ECHO.A.Choose Magisk package manually
ECHO.B.First-time Magisk install FAQ
ECHO.C.Return to main menu
ECHO.
call input choice #[1][A][B][C]
ECHO.
if "%choice%"=="1" set zippath=..\Magisk29.0.apk
if "%choice%"=="A" ECHOC {%c_h%}Please select a Magisk ZIP or APK...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [zip][apk]
if "%choice%"=="A" set zippath=%sel__file_path%
if "%choice%"=="B" call open pic pic\magiskqa.jpg & goto ROOT
if "%choice%"=="C" goto MENU
ECHOC {%c_h%}Boot the device, connect it to the PC, and enable USB debugging...{%c_i%}{\n}& call chkdev system rechk 1
start framework logviewer start %logfile%
ECHO.Reading device information...
call info adb
call ztetoolbox chkproduct %info__adb__product%
if "%parlayout:~0,2%"=="ab" call slot system chk
if "%parlayout:~0,2%"=="ab" (set targetpar=%bootpar%_%slot__cur%) else (set targetpar=%bootpar%)
ECHOC {%c_we%}Device codename: %info__adb__product%{%c_i%}{\n}
ECHOC {%c_we%}Android version: %info__adb__androidver%{%c_i%}{\n}
ECHOC {%c_we%}Target partition: %targetpar%{%c_i%}{\n}
ECHO.Rebooting to 9008... & call reboot system qcedl rechk 1
ECHO.backup%targetpar%...
for /f %%a in ('gettime.exe ^| find "."') do set baktime=%%a
call read qcedl %targetpar% res\%product%\bak\%targetpar%_%baktime%.img notice %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
ECHO.File backed up tobin\res\%product%\bak.
ECHO.Magisk patch... & call imgkit magiskpatch %framework_workspace%\res\%product%\bak\%targetpar%_%baktime%.img %tmpdir%\boot_patched.img %zippath% noprompt
ECHO.flash%targetpar%... & call write qcedl %targetpar% %tmpdir%\boot_patched.img %chkdev__port__qcedl%
ECHO.Reboot... & call reboot qcedl system
call framework logviewer end
ECHO.
ECHOC {%c_s%}All done. {%c_h%}After booting, install
if "%zippath%"=="..\Magisk29.0.apk" (ECHOC {%c_h%}Magisk29.0.apk from the toolbox folder. ) else (ECHOC {%c_h%}the appropriate Magisk app. )
ECHOC {%c_h%}Press any key to return...{%c_i%}{\n}& pause>nul & goto MENU


:LOCKBL
set lockbl_chk=n
set lockbl_autoerase=n
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Lock bootloader
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
if "%blplan%"=="n" ECHO.%model%is not supported yetLock bootloader. Press any key to return... & pause>nul & goto MENU
if "%blplan%"=="special__P636A01" ECHO.%model%is not supported yetLock bootloader. Press any key to return... & pause>nul & goto MENU
ECHO. [%model%]   lock: %blplan%
ECHO.
if "%blplan%"=="avb" (
    set set unlockbl_avb_cpu=& set unlockbl_avb_uefisource=
    if "%product%"=="NP02J" set unlockbl_avb_cpu=8gen2& set unlockbl_avb_uefisource=Littlenine
    if "%product%"=="NX779J" set unlockbl_avb_cpu=8gen3& set unlockbl_avb_uefisource=Littlenine
    if "%product%"=="NX789J" set unlockbl_avb_cpu=8e& set unlockbl_avb_uefisource=anonymous1
    if "%product%"=="NX737J" set unlockbl_avb_cpu=8e& set unlockbl_avb_uefisource=anonymous1
    if "%product%"=="NP05J" set unlockbl_avb_cpu=8e& set unlockbl_avb_uefisource=anonymous1
)
if "%blplan%"=="avb" (
    if not exist tool\Other\avbexploit\%unlockbl_avb_uefisource%\uefi_unlock_%unlockbl_avb_cpu%.img goto FATAL
    set unlockbl_avb_uefipath=tool\Other\avbexploit\%unlockbl_avb_uefisource%\uefi_unlock_%unlockbl_avb_cpu%.img
    if "%unlockbl_avb_uefisource%"=="Littlenine" ECHO.%model%is not supported yetLock bootloader. Press any key to return... & pause>nul & goto MENU
)
ECHO.-Lock bootloader:
ECHO. dataall
ECHO. boot
ECHO. ...
ECHO.
ECHO.-Lock bootloader ():
ECHO. systemrestoreofficial
ECHO. installflash
ECHO. dataconnectstable
ECHO. deletepassword, closedevice, Exitofficialaccountaccount
ECHO. backuppersonaldatadevice
ECHO. PCExitflash
ECHO. 9008
ECHO.
ECHO.-Lock bootloader, Lock bootloader. lock, .
ECHO.
ECHO.
ECHOC {%c_h%}After reading the information above, press any key to startlock...{%c_i%}{\n}& pause>nul
ECHO.
:LOCKBL-1
ECHOC {%c_h%}Boot the device, connect it to the PC, and enable USB debugging...{%c_i%}{\n}& call chkdev all rechk 1
if "%chkdev__mode%"=="system" goto LOCKBL-2
if "%blplan%"=="direct" (if not "%chkdev__mode%"=="fastboot" ECHOC {%c_e%}devicemodeerror. {%c_h%}Press any key to retry...{%c_i%}{\n}& pause>nul & goto LOCKBL-1)
if "%blplan%"=="flashabl" (if not "%chkdev__mode%"=="qcedl" ECHOC {%c_e%}devicemodeerror. {%c_h%}Press any key to retry...{%c_i%}{\n}& pause>nul & goto LOCKBL-1)
if "%blplan%"=="efisp" (if not "%chkdev__mode%"=="qcedl" ECHOC {%c_e%}devicemodeerror. {%c_h%}Press any key to retry...{%c_i%}{\n}& pause>nul & goto UNLOCKBL-1)
if "%blplan%"=="special__ailsa_ii" (if not "%chkdev__mode%"=="qcedl" ECHOC {%c_e%}devicemodeerror. {%c_h%}Press any key to retry...{%c_i%}{\n}& pause>nul & goto LOCKBL-1)
ECHOC {%c_w%}%chkdev__mode%. %chkdev__mode%tooldeviceinformation. Please manualbootconnectPC, USB, EnterContinue.{%c_i%}{\n}
ECHO.1.[recommended]system   2.%chkdev__mode%
call input choice #[1][2]
if "%choice%"=="1" goto LOCKBL-1
if "%parlayout:~0,2%"=="ab" set slot__cur=unknown
goto LOCKBL-%blplan%-START
goto FATAL
:LOCKBL-2
ECHO.Reading device information...
call info adb
call ztetoolbox chkproduct %info__adb__product%
if "%parlayout:~0,2%"=="ab" call slot system chk
ECHOC {%c_we%}Device codename: %info__adb__product%{%c_i%}{\n}
ECHOC {%c_we%}Android version: %info__adb__androidver%{%c_i%}{\n}
if "%parlayout:~0,2%"=="ab" ECHOC {%c_we%}Current slot: %slot__cur%{%c_i%}{\n}
goto LOCKBL-%blplan%
goto FATAL
:LOCKBL-AVB
if "%presskeytoedl%"=="y" (goto LOCKBL-AVB-PRESSKEYTOEDL) else (goto LOCKBL-AVB-CMDTOEDL)
:LOCKBL-AVB-PRESSKEYTOEDL
ECHOC {%c_h%}Please device, , PCanyContinue. scriptPlease ...{%c_i%}{\n}& pause>nul
ECHO.Reboot... & adb.exe reboot 1>>%logfile% 2>&1 || ECHOC {%c_e%}Rebootfailed. Please deviceconnectstable. {%c_h%}Press any key to retry...{%c_i%}{\n}&& pause>nul && goto LOCKBL
ECHO.note: device. failed, Please data, closescript, .
ECHOC {%c_h%}Please ...{%c_i%}{\n}
call chkdev qcedl rechk 1
ECHOC {%c_h%}{%c_i%}{\n}
goto LOCKBL-AVB-START
:LOCKBL-AVB-CMDTOEDL
ECHO.Rebooting to 9008... & call reboot system qcedl rechk 1
goto LOCKBL-AVB-START
:LOCKBL-AVB-START
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
if "%parlayout:~0,2%"=="ab" (if "%slot__cur%"=="unknown" ECHO.CheckCurrent slot... & call slot qcedl chk)
for /f %%a in ('gettime.exe ^| find "."') do set baktime=%%a
if "%blplan_frp%"=="y" ECHO.backupfrp... & call read qcedl frp res\%product%\bak\frp_%baktime%.img notice %chkdev__port__qcedl%
if "%storagetype%"=="ufs" (set targetlun=4) else (set targetlun=0)
if "%parlayout:~0,2%"=="ab" (set targetbootpar=boot_%slot__cur%& set targetvbmetapar=vbmeta_a& set targetpvmfwpar=pvmfw_%slot__cur%) else (set targetbootpar=boot& set targetvbmetapar=vbmeta& set targetpvmfwpar=pvmfw)
ECHO.backupgpt_main%targetlun%...
call partable readgpt qcedl %storagetype% %targetlun% gptmain res\%product%\bak\gpt_main%targetlun%.bin noprompt %chkdev__port__qcedl%
copy /Y res\%product%\bak\gpt_main%targetlun%.bin res\%product%\bak\gpt_main%targetlun%_%baktime%.bin 1>>%logfile% 2>&1 || goto FATAL
ECHO.backup%targetbootpar%...
call read qcedl %targetbootpar% res\%product%\bak\%targetbootpar%.img noprompt %chkdev__port__qcedl%
copy /Y res\%product%\bak\%targetbootpar%.img res\%product%\bak\%targetbootpar%_%baktime%.img 1>>%logfile% 2>&1 || goto FATAL
ECHO.File backed up tobin\res\%product%\bak.
ECHO.gpt_main%targetlun%...
copy /Y res\%product%\bak\gpt_main%targetlun%.bin %tmpdir%\tmp.bin 1>>%logfile% 2>&1 || goto FATAL
gpttool.exe -p %tmpdir%\tmp.bin -f rmpar:name:%targetvbmetapar% 1>>%logfile% 2>&1 || goto FATAL
gpttool.exe -p %tmpdir%\tmp.bin -f rmpar:name:%targetpvmfwpar%  1>>%logfile% 2>&1 || ECHOC {%c_we%}delete%targetpvmfwpar%partition...{%c_i%}{\n}&& call log %logger% W delete%targetpvmfwpar%partition
ECHO.flashgpt_main%targetlun%... & call partable writegpt qcedl %storagetype% %targetlun% %tmpdir%\tmp.bin %chkdev__port__qcedl%
ECHO.flashunlockuefi... & call write qcedl %targetbootpar% %unlockbl_avb_uefipath% %chkdev__port__qcedl%
if "%blplan_frp%"=="y" ECHO.flashunlockfrp... & call write qcedl frp tool\Android\frp_unlock.img %chkdev__port__qcedl%
ECHO.Reboot... & call reboot qcedl system
if "%unlockbl_avb_uefisource%"=="anonymous1" goto LOCKBL-AVB-FBLOCK
goto FATAL
:LOCKBL-AVB-FBLOCK
ECHO.deviceFastboot. ifautomatic, Please manual. Please manualselectCheckFastboot connection. Checkconnect, Please closescript, Please Continue.
:LOCKBL-AVB-FBLOCK-1
ECHO.1.CheckFastboot connection   2.CheckCheck   3.Fastboot
call input choice #[1][2][3]
if "%choice%"=="2" ECHOC {%c_e%}lockfailed. Please feedback.{%c_i%}{\n}& goto LOCKBL-AVB-RESTORE
if "%choice%"=="3" call open pic pic\fastboot.jpg & goto LOCKBL-AVB-FBLOCK-1
fastboot.exe devices -l 2>&1 | find "fastboot" 1>nul 2>nul || ECHOC {%c_e%}deviceconnect. {%c_i%}Please device, deviceCheckinstall.{%c_i%}{\n}&& goto LOCKBL-AVB-FBLOCK-1
call chkdev fastboot
ECHO.Reading device information... & call info fastboot
if "%info__fastboot__unlocked%"=="no" ECHOC {%c_s%}devicelock. {%c_i%}{\n}& set lockbl_chk=y& goto LOCKBL-AVB-RESTORE
ECHO.executelockcommand. ifdevicelock, Please select"LOCK THE BOOTLOADER"(select), . deviceautomaticReboot, boot, Please closescript, Please Continue.
fastboot.exe flashing lock 1>>%logfile% 2>&1 || ECHOC {%c_e%}executelockcommandfailed. Please log.{%c_i%}{\n}
:LOCKBL-AVB-FBLOCK-2
ECHO.1.lock   2.lock
call input choice [1][2]
if "%choice%"=="1" set lockbl_autoerase=y
if "%choice%"=="2" ECHOC {%c_e%}lockfailed. Please feedback.{%c_i%}{\n}
goto LOCKBL-AVB-RESTORE
:LOCKBL-AVB-RESTORE
ECHOC {%c_w%}tool @ , , {%c_i%}{\n}
ECHOC {%c_i%}device, restoredevice. Please closescript, Please Continuemanual, otherwise. {%c_h%}Waitingboot, deviceboot, Please manual9008 (Please tooldirectory"mode")...{%c_i%}{\n}& call chkdev qcedl rechk 1
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
if "%blplan_frp%"=="y" ECHO.restorefrp... & call write qcedl frp res\%product%\bak\frp_%baktime%.img %chkdev__port__qcedl%
ECHO.restoregpt_main%targetlun%... & call partable writegpt qcedl %storagetype% %targetlun% res\%product%\bak\gpt_main%targetlun%.bin %chkdev__port__qcedl%
ECHO.restore%targetbootpar%... & call write qcedl %targetbootpar% res\%product%\bak\%targetbootpar%.img %chkdev__port__qcedl%
if "%parlayout:~0,2%"=="ab" ECHO.%slot__cur%slot... & call slot qcedl set %slot__cur%
if "%lockbl_autoerase%"=="y" ECHO.automaticrestore... & call write qcedl misc tool\Android\misc_wipedata.img %chkdev__port__qcedl%
ECHO.Reboot... & call reboot qcedl system
goto LOCKBL-DONE
:LOCKBL-EFISP
if "%presskeytoedl%"=="y" (goto LOCKBL-EFISP-PRESSKEYTOEDL) else (goto LOCKBL-EFISP-CMDTOEDL)
:LOCKBL-EFISP-PRESSKEYTOEDL
ECHOC {%c_h%}Please device, , PCanyContinue. scriptPlease ...{%c_i%}{\n}& pause>nul
ECHO.Reboot... & adb.exe reboot 1>>%logfile% 2>&1 || ECHOC {%c_e%}Rebootfailed. Please deviceconnectstable. {%c_h%}Press any key to retry...{%c_i%}{\n}&& pause>nul && goto LOCKBL
ECHO.note: device. failed, Please data, closescript, .
ECHOC {%c_h%}Please ...{%c_i%}{\n}
call chkdev qcedl rechk 1
ECHOC {%c_h%}{%c_i%}{\n}
goto LOCKBL-EFISP-START
:LOCKBL-EFISP-CMDTOEDL
ECHO.Rebooting to 9008... & call reboot system qcedl rechk 1
goto LOCKBL-EFISP-START
:LOCKBL-EFISP-START
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
if "%parlayout:~0,2%"=="ab" (if "%slot__cur%"=="unknown" ECHO.CheckCurrent slot... & call slot qcedl chk)
for /f %%a in ('gettime.exe ^| find "."') do set baktime=%%a
::if "%blplan_frp%"=="y" ECHO.backupfrp... & call read qcedl frp res\%product%\bak\frp_%baktime%.img notice %chkdev__port__qcedl%
ECHO.backupabl_%slot__cur%... & call read qcedl abl_%slot__cur% res\%product%\bak\abl_%slot__cur%_%baktime%.img notice %chkdev__port__qcedl%
ECHO.backupefisp... & call read qcedl efisp res\%product%\bak\efisp_%baktime%.img notice %chkdev__port__qcedl%
ECHO.File backed up tobin\res\%product%\bak.
ECHO.flashabl... & call write qcedl abl_%slot__cur% res\%product%\abl_unlock.img %chkdev__port__qcedl%
ECHO.flashlock... & call write qcedl efisp tool\Other\8e5gbl\gbl_lock.efi %chkdev__port__qcedl%
::if "%blplan_frp%"=="y" ECHO.flashunlockfrp... & call write qcedl frp tool\Android\frp_unlock.img %chkdev__port__qcedl%
ECHO.Reboot(iffailedPlease select2)... & call reboot qcedl system
ECHO.devicebootunlockwarning, locksuccess. otherwisePlease feedback. Waiting5... & TIMEOUT /T 5 /NOBREAK>nul
set unlockbl_autoerase=y
ECHOC {%c_w%}tool @ , , {%c_i%}{\n}
ECHOC {%c_i%}device, restoredevice. Please closescript, Please Continuemanual, otherwise. {%c_h%}Waitingboot, deviceboot, Please manual9008 (Please tooldirectory"mode")...{%c_i%}{\n}& call chkdev qcedl rechk 1
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
::if "%blplan_frp%"=="y" ECHO.restorefrp... & call write qcedl frp res\%product%\bak\frp_%baktime%.img %chkdev__port__qcedl%
ECHO.restoreabl_%slot__cur%... & call write qcedl abl_%slot__cur% res\%product%\bak\abl_%slot__cur%_%baktime%.img %chkdev__port__qcedl%
ECHO.Clearing efisp... & call write qcedl efisp tool\Other\8e5gbl\efisp_empty.img %chkdev__port__qcedl%
if "%unlockbl_autoerase%"=="y" ECHO.automaticrestore... & call write qcedl misc tool\Android\misc_wipedata.img %chkdev__port__qcedl%
ECHO.Reboot... & call reboot qcedl system
goto LOCKBL-DONE
:LOCKBL-special__ailsa_ii
ECHO.Rebooting to 9008... & call reboot system qcedl rechk 1
goto LOCKBL-special__ailsa_ii-START
:LOCKBL-special__ailsa_ii-START
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
for /f %%a in ('gettime.exe ^| find "."') do set baktime=%%a
ECHO.backupaboot... & call read qcedl aboot res\%product%\bak\aboot_%baktime%.mbn notice %chkdev__port__qcedl%
ECHO.backupfbop...  & call read qcedl fbop  res\%product%\bak\fbop_%baktime%.img  notice %chkdev__port__qcedl%
::ECHO.backupfrp...   & call read qcedl frp   res\%product%\bak\frp_%baktime%.img   notice %chkdev__port__qcedl%
::ECHO.patchfrpOEMunlock... & call imgkit patchfrp res\%product%\bak\frp_%baktime%.img %tmpdir%\frp_oemunlockon.img oemunlockon noprompt
ECHO.flashunlockaboot... & call write qcedl aboot res\%product%\aboot_unlock.mbn %chkdev__port__qcedl%
ECHO.flashunlockfbop...  & call write qcedl fbop  res\%product%\fbop_unlock.img  %chkdev__port__qcedl%
::ECHO.flashunlockfrp...   & call write qcedl frp   %tmpdir%\frp_oemunlockon.img        %chkdev__port__qcedl%
ECHO.Reboot to system... & call reboot qcedl system
ECHO.deviceautomaticReboot to system. bootifUSB, Please USB. ifboot, Please feedback.
call chkdev system rechk 1
ECHO.RebootFastboot... & call reboot system fastboot rechk 1
ECHO.executelockcommand...
fastboot.exe oem lock 1>%tmpdir%\output.txt 2>&1 || ECHOC {%c_e%}executelockcommandfailed. Please log.{%c_i%}{\n}
type %tmpdir%\output.txt>>%logfile%
find "Device already : locked!" "%tmpdir%\output.txt" 1>nul 2>nul && ECHOC {%c_s%}devicelock.{%c_i%}{\n}&& set lockbl_chk=y&& goto LOCKBL-DONE
goto LOCKBL-DONE
:LOCKBL-FLASHABL
if "%presskeytoedl%"=="y" (goto LOCKBL-FLASHABL-PRESSKEYTOEDL) else (goto LOCKBL-FLASHABL-CMDTOEDL)
:LOCKBL-FLASHABL-PRESSKEYTOEDL
ECHOC {%c_h%}Please device, , PCanyContinue. scriptPlease ...{%c_i%}{\n}& pause>nul
ECHO.Reboot... & adb.exe reboot bootloader 1>>%logfile% 2>&1 || ECHOC {%c_e%}Rebootfailed. Please deviceconnectstable. {%c_h%}Press any key to retry...{%c_i%}{\n}&& pause>nul && goto LOCKBL
ECHO.note: device. failed, Please data, closescript, .
ECHOC {%c_h%}Please ...{%c_i%}{\n}
call chkdev qcedl rechk 1
ECHOC {%c_h%}{%c_i%}{\n}
goto LOCKBL-FLASHABL-START
:LOCKBL-FLASHABL-CMDTOEDL
ECHO.Rebooting to 9008... & call reboot system qcedl rechk 1
goto LOCKBL-FLASHABL-START
:LOCKBL-FLASHABL-START
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
for /f %%a in ('gettime.exe ^| find "."') do set baktime=%%a
if "%blplan_frp%"=="y" ECHO.backupfrp... & call read qcedl frp res\%product%\bak\frp_%baktime%.img notice %chkdev__port__qcedl%
if not "%parlayout:~0,2%"=="ab" (
    ECHO.backupabl... & call read qcedl abl res\%product%\bak\abl_%baktime%.elf notice %chkdev__port__qcedl%
    ECHO.File backed up tobin\res\%product%\bak.
    ECHO.flashunlockabl... & call write qcedl abl res\%product%\abl_unlock.elf %chkdev__port__qcedl%)
if "%parlayout:~0,2%"=="ab" (if "%slot__cur%"=="unknown" ECHO.CheckCurrent slot... & call slot qcedl chk)
if "%parlayout:~0,2%"=="ab" (
    ECHO.backupabl_%slot__cur%... & call read qcedl abl_%slot__cur% res\%product%\bak\abl_%slot__cur%_%baktime%.elf notice %chkdev__port__qcedl%
    ECHO.File backed up tobin\res\%product%\bak.
    ECHO.flashunlockabl_%slot__cur%... & call write qcedl abl_%slot__cur% res\%product%\abl_unlock.elf %chkdev__port__qcedl%)
if "%blplan_frp%"=="y" ECHO.flashunlockfrp... & call write qcedl frp tool\Android\frp_unlock.img %chkdev__port__qcedl%
ECHO.Reboot... & call reboot qcedl system
ECHO.deviceFastboot. ifautomatic, Please manual. Please manualselectCheckFastboot connection. Checkconnect, Please closescript, Please Continue.
:LOCKBL-FLASHABL-4
ECHO.1.CheckFastboot connection   2.CheckCheck   3.Fastboot
call input choice #[1][2][3]
if "%choice%"=="2" ECHOC {%c_e%}unlockfailed. Please feedback.{%c_i%}{\n}& goto LOCKBL-FLASHABL-1
if "%choice%"=="3" call open pic pic\fastboot.jpg & goto LOCKBL-FLASHABL-4
fastboot.exe devices -l 2>&1 | find "fastboot" 1>nul 2>nul || ECHOC {%c_e%}deviceconnect. {%c_i%}Please device, device, data, Checkinstall.{%c_i%}{\n}&& goto LOCKBL-FLASHABL-4
call chkdev fastboot
ECHO.Reading device information... & call info fastboot
if "%info__fastboot__unlocked%"=="no" ECHOC {%c_s%}devicelock. {%c_i%}{\n}& set lockbl_chk=y& goto LOCKBL-FLASHABL-1
ECHO.executelockcommand. ifdevicelock, Please select"LOCK THE BOOTLOADER", . deviceautomaticReboot, boot, Please closescript, Please Continue.
fastboot.exe flashing lock 1>>%logfile% 2>&1 || ECHOC {%c_e%}executelockcommandfailed. Please log.{%c_i%}{\n}
:LOCKBL-FLASHABL-2
ECHO.1.lock   2.lock
call input choice [1][2]
::if "%choice%"=="3" call open pic pic\lockbl.jpg & goto LOCKBL-FLASHABL-2
if "%choice%"=="1" set lockbl_autoerase=y
if "%choice%"=="2" ECHOC {%c_e%}lockfailed. Please feedback.{%c_i%}{\n}
goto LOCKBL-FLASHABL-1
:LOCKBL-FLASHABL-1
ECHOC {%c_w%}tool @ , , {%c_i%}{\n}
ECHOC {%c_i%}device, restoredevice. Please closescript, Please Continue, otherwise. {%c_h%}Waitingboot, deviceboot, Please manual9008 (Please tooldirectory"mode")...{%c_i%}{\n}& call chkdev qcedl rechk 1
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
if "%blplan_frp%"=="y" ECHO.restorefrp... & call write qcedl frp res\%product%\bak\frp_%baktime%.img %chkdev__port__qcedl%
if not "%parlayout:~0,2%"=="ab" (
    ECHO.restoreabl... & call write qcedl abl res\%product%\bak\abl_%baktime%.elf %chkdev__port__qcedl%)
if "%parlayout:~0,2%"=="ab" (
    ECHO.restoreabl_%slot__cur%... & call write qcedl abl_%slot__cur% res\%product%\bak\abl_%slot__cur%_%baktime%.elf %chkdev__port__qcedl%
    ECHO.%slot__cur%slot... & call slot qcedl set %slot__cur%)
if "%lockbl_autoerase%"=="y" ECHO.automaticrestore... & call write qcedl misc tool\Android\misc_wipedata.img %chkdev__port__qcedl%
ECHO.Reboot... & call reboot qcedl system
goto LOCKBL-DONE
:LOCKBL-DIRECT
ECHO.Rebootfastboot... & call reboot system fastboot rechk 1
:LOCKBL-DIRECT-START
ECHO.Reading device information... & call info fastboot
if "%info__fastboot__unlocked%"=="no" ECHOC {%c_s%}devicelock. {%c_i%}{\n}& set lockbl_chk=y& goto LOCKBL-DONE
ECHO.executelockcommand. ifdevicelock, Please select"LOCK THE BOOTLOADER", . if, descriptionlockfailed.
fastboot.exe flashing lock 1>>%logfile% 2>&1 || ECHOC {%c_e%}executelockcommandfailed. Please log.{%c_i%}{\n}
ECHO.1.lock   2.lock
call input choice [1][2]
if "%choice%"=="2" ECHOC {%c_e%}lockfailed. Please feedback.{%c_i%}{\n}
goto LOCKBL-DONE
:LOCKBL-DONE
if "%lockbl_chk%"=="y" goto LOCKBL-DONE-1
::ECHO.
::ECHO.1.Checklocksuccess
::ECHO.2.locksuccess
::call input choice #[1][2]
::ECHO.
::if "%choice%"=="1" goto LOCKBL-1
:LOCKBL-DONE-1
ECHO. & ECHOC {%c_s%}All done. {%c_i%}lockifboot, Please Recoverydatarestore. restoreboot, Please Waiting. {%c_h%}Press any key to return...{%c_i%}{\n}& pause>nul & goto MENU


:UNLOCKBL
set unlockbl_chk=n
set unlockbl_autoerase=n
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Unlock bootloader
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
if "%blplan%"=="n" ECHO.%model%is not supported yetUnlock bootloader. Press any key to return... & pause>nul & goto MENU
if "%blplan%"=="special__P636A01" ECHO.%model%Unlock bootloader. ifRoot, Please yhcres.topdownload, 9008flash, restoreboot. & ECHO. & ECHOC {%c_h%}Press any key to return...{%c_i%}{\n}& pause>nul & goto MENU
ECHO. [%model%]   unlock: %blplan%
ECHO.
if "%blplan%"=="avb" (
    set set unlockbl_avb_cpu=& set unlockbl_avb_uefisource=
    if "%product%"=="NP02J" set unlockbl_avb_cpu=8gen2& set unlockbl_avb_uefisource=Littlenine
    if "%product%"=="NX779J" set unlockbl_avb_cpu=8gen3& set unlockbl_avb_uefisource=Littlenine
    if "%product%"=="NX789J" set unlockbl_avb_cpu=8e& set unlockbl_avb_uefisource=anonymous1
    if "%product%"=="NX737J" set unlockbl_avb_cpu=8e& set unlockbl_avb_uefisource=anonymous1
    if "%product%"=="NP05J" set unlockbl_avb_cpu=8e& set unlockbl_avb_uefisource=anonymous1
)
if "%blplan%"=="avb" (
    if not exist tool\Other\avbexploit\%unlockbl_avb_uefisource%\uefi_unlock_%unlockbl_avb_cpu%.img goto FATAL
    set unlockbl_avb_uefipath=tool\Other\avbexploit\%unlockbl_avb_uefisource%\uefi_unlock_%unlockbl_avb_cpu%.img
    if "%unlockbl_avb_uefisource%"=="Littlenine" ECHO.unlockfile@Littlenine. & ECHOC {%c_w%}supportLock bootloader, unlocklock, Please !{%c_i%}{\n}& ECHO.
)
ECHO.-Unlock bootloader:
ECHO. systemfingerprintunavailable(Lock bootloader,fingerprinttool)
ECHO. TEE
ECHO. dataall
ECHO. officialsystemupdateunavailable
ECHO. 
ECHO. bootunlockwarning
ECHO. unlocklock
ECHO. ...
ECHO.
ECHO.-Unlock bootloader ():
ECHO. installflash
ECHO. dataconnectstable
if "%product%"=="NX563J" ECHO. yhcres.topdownloadV6.28version9008flash& ECHO. (: flash--Z17-NubiaUI-9008)
if "%blplan_frp%"=="n" ECHO. developerOEMunlock
ECHO. deletepassword, closedevice, Exitofficialaccountaccount
ECHO. backuppersonaldatadevice
ECHO. PCExitflash
ECHO. 9008
ECHO. backuppartition
ECHO.
ECHO.-Please , problemclose, Please support / feedback groupfeedback.
ECHO.
ECHO.
ECHOC {%c_h%}After reading the information above, press any key to startunlock...{%c_i%}{\n}& pause>nul
ECHO.
:UNLOCKBL-1
ECHOC {%c_h%}Boot the device, connect it to the PC, and enable USB debugging...{%c_i%}{\n}& call chkdev all rechk 1
if "%chkdev__mode%"=="system" goto UNLOCKBL-2
if "%blplan%"=="direct" (if not "%chkdev__mode%"=="fastboot" ECHOC {%c_e%}devicemodeerror. {%c_h%}Press any key to retry...{%c_i%}{\n}& pause>nul & goto UNLOCKBL-1)
if "%blplan%"=="flashabl" (if not "%chkdev__mode%"=="qcedl" ECHOC {%c_e%}devicemodeerror. {%c_h%}Press any key to retry...{%c_i%}{\n}& pause>nul & goto UNLOCKBL-1)
if "%blplan%"=="efisp" (if not "%chkdev__mode%"=="qcedl" ECHOC {%c_e%}devicemodeerror. {%c_h%}Press any key to retry...{%c_i%}{\n}& pause>nul & goto UNLOCKBL-1)
if "%blplan%"=="avb" (if not "%chkdev__mode%"=="qcedl" ECHOC {%c_e%}devicemodeerror. {%c_h%}Press any key to retry...{%c_i%}{\n}& pause>nul & goto UNLOCKBL-1)
if "%blplan%"=="special__ailsa_ii" (if not "%chkdev__mode%"=="qcedl" ECHOC {%c_e%}devicemodeerror. {%c_h%}Press any key to retry...{%c_i%}{\n}& pause>nul & goto UNLOCKBL-1)
ECHOC {%c_w%}%chkdev__mode%. %chkdev__mode%tooldeviceinformation. Please manualbootconnectPC, USB, EnterContinue.{%c_i%}{\n}
ECHO.1.[recommended]system   2.%chkdev__mode%
call input choice #[1][2]
if "%choice%"=="1" goto UNLOCKBL-1
if "%parlayout:~0,2%"=="ab" set slot__cur=unknown
goto UNLOCKBL-%blplan%-START
goto FATAL
:UNLOCKBL-2
ECHO.Reading device information...
call info adb
call ztetoolbox chkproduct %info__adb__product%
if "%parlayout:~0,2%"=="ab" call slot system chk
ECHOC {%c_we%}Device codename: %info__adb__product%{%c_i%}{\n}
ECHOC {%c_we%}Android version: %info__adb__androidver%{%c_i%}{\n}
if "%parlayout:~0,2%"=="ab" ECHOC {%c_we%}Current slot: %slot__cur%{%c_i%}{\n}
goto UNLOCKBL-%blplan%
goto FATAL
:UNLOCKBL-AVB
if "%presskeytoedl%"=="y" (goto UNLOCKBL-AVB-PRESSKEYTOEDL) else (goto UNLOCKBL-AVB-CMDTOEDL)
:UNLOCKBL-AVB-PRESSKEYTOEDL
ECHOC {%c_h%}Please device, , PCanyContinue. scriptPlease ...{%c_i%}{\n}& pause>nul
ECHO.Reboot... & adb.exe reboot 1>>%logfile% 2>&1 || ECHOC {%c_e%}Rebootfailed. Please deviceconnectstable. {%c_h%}Press any key to retry...{%c_i%}{\n}&& pause>nul && goto UNLOCKBL
ECHO.note: device. failed, Please data, closescript, .
ECHOC {%c_h%}Please ...{%c_i%}{\n}
call chkdev qcedl rechk 1
ECHOC {%c_h%}{%c_i%}{\n}
goto UNLOCKBL-AVB-START
:UNLOCKBL-AVB-CMDTOEDL
ECHO.Rebooting to 9008... & call reboot system qcedl rechk 1
goto UNLOCKBL-AVB-START
:UNLOCKBL-AVB-START
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
if "%parlayout:~0,2%"=="ab" (if "%slot__cur%"=="unknown" ECHO.CheckCurrent slot... & call slot qcedl chk)
for /f %%a in ('gettime.exe ^| find "."') do set baktime=%%a
if "%blplan_frp%"=="y" ECHO.backupfrp... & call read qcedl frp res\%product%\bak\frp_%baktime%.img notice %chkdev__port__qcedl%
if "%storagetype%"=="ufs" (set targetlun=4) else (set targetlun=0)
if "%parlayout:~0,2%"=="ab" (set targetbootpar=boot_%slot__cur%& set targetvbmetapar=vbmeta_a& set targetpvmfwpar=pvmfw_%slot__cur%) else (set targetbootpar=boot& set targetvbmetapar=vbmeta& set targetpvmfwpar=pvmfw)
ECHO.backupgpt_main%targetlun%...
call partable readgpt qcedl %storagetype% %targetlun% gptmain res\%product%\bak\gpt_main%targetlun%.bin noprompt %chkdev__port__qcedl%
copy /Y res\%product%\bak\gpt_main%targetlun%.bin res\%product%\bak\gpt_main%targetlun%_%baktime%.bin 1>>%logfile% 2>&1 || goto FATAL
ECHO.backup%targetbootpar%...
call read qcedl %targetbootpar% res\%product%\bak\%targetbootpar%.img noprompt %chkdev__port__qcedl%
copy /Y res\%product%\bak\%targetbootpar%.img res\%product%\bak\%targetbootpar%_%baktime%.img 1>>%logfile% 2>&1 || goto FATAL
ECHO.File backed up tobin\res\%product%\bak.
ECHO.gpt_main%targetlun%...
copy /Y res\%product%\bak\gpt_main%targetlun%.bin %tmpdir%\tmp.bin 1>>%logfile% 2>&1 || goto FATAL
gpttool.exe -p %tmpdir%\tmp.bin -f rmpar:name:%targetvbmetapar% 1>>%logfile% 2>&1 || goto FATAL
gpttool.exe -p %tmpdir%\tmp.bin -f rmpar:name:%targetpvmfwpar%  1>>%logfile% 2>&1 || ECHOC {%c_we%}delete%targetpvmfwpar%partition...{%c_i%}{\n}&& call log %logger% W delete%targetpvmfwpar%partition
ECHO.flashgpt_main%targetlun%... & call partable writegpt qcedl %storagetype% %targetlun% %tmpdir%\tmp.bin %chkdev__port__qcedl%
ECHO.flashunlockuefi... & call write qcedl %targetbootpar% %unlockbl_avb_uefipath% %chkdev__port__qcedl%
if "%blplan_frp%"=="y" ECHO.flashunlockfrp... & call write qcedl frp tool\Android\frp_unlock.img %chkdev__port__qcedl%
ECHO.Reboot... & call reboot qcedl system
if "%unlockbl_avb_uefisource%"=="anonymous1" goto UNLOCKBL-AVB-FBUNLOCK
if "%unlockbl_avb_uefisource%"=="Littlenine" goto UNLOCKBL-AVB-AUTOUNLOCK
goto FATAL
:UNLOCKBL-AVB-FBUNLOCK
ECHO.deviceFastboot. ifautomatic, Please manual. Please manualselectCheckFastboot connection. Checkconnect, Please closescript, Please Continue.
:UNLOCKBL-AVB-FBUNLOCK-1
ECHO.1.CheckFastboot connection   2.CheckCheck   3.Fastboot
call input choice #[1][2][3]
if "%choice%"=="2" ECHOC {%c_e%}unlockfailed. Please feedback.{%c_i%}{\n}& goto UNLOCKBL-AVB-RESTORE
if "%choice%"=="3" call open pic pic\fastboot.jpg & goto UNLOCKBL-AVB-FBUNLOCK-1
fastboot.exe devices -l 2>&1 | find "fastboot" 1>nul 2>nul || ECHOC {%c_e%}deviceconnect. {%c_i%}Please device, device, data, Checkinstall.{%c_i%}{\n}&& goto UNLOCKBL-AVB-FBUNLOCK-1
call chkdev fastboot
ECHO.Reading device information... & call info fastboot
if "%info__fastboot__unlocked%"=="yes" ECHOC {%c_s%}deviceunlock. {%c_i%}{\n}& set unlockbl_chk=y& goto UNLOCKBL-AVB-RESTORE
ECHO.executeunlockcommand. ifdeviceunlock, Please select"UNLOCK THE BOOTLOADER"(select), . deviceautomaticReboot, boot, Please closescript, Please Continue.
fastboot.exe flashing unlock 1>>%logfile% 2>&1 || ECHOC {%c_e%}executeunlockcommandfailed. Please log.{%c_i%}{\n}
:UNLOCKBL-AVB-FBUNLOCK-2
ECHO.1.unlock   2.unlock   3.unlock
call input choice [1][2][3]
if "%choice%"=="3" call open pic pic\unlockbl.jpg & goto UNLOCKBL-AVB-FBUNLOCK-2
if "%choice%"=="1" set unlockbl_autoerase=y
if "%choice%"=="2" ECHOC {%c_e%}unlockfailed. Please feedback.{%c_i%}{\n}
goto UNLOCKBL-AVB-RESTORE
:UNLOCKBL-AVB-AUTOUNLOCK
ECHO.Please Waiting15, unlockexecutedone. device (Reboot).
ECHO.bootPlease unlockwarning, unlocksuccess. problemPlease feedback.
set num=1
:UNLOCKBL-AVB-AUTOUNLOCK-1
TIMEOUT /T 1 /NOBREAK>nul& ECHOC {%c_i%}%num% 
if "%num%"=="15" ECHO.& goto UNLOCKBL-AVB-RESTORE
set /a num+=1& goto UNLOCKBL-AVB-AUTOUNLOCK-1
:UNLOCKBL-AVB-RESTORE
ECHOC {%c_w%}tool @ , , {%c_i%}{\n}
ECHOC {%c_i%}device, restoredevice. Please closescript, Please Continuemanual, otherwise. {%c_h%}Waitingboot, deviceboot, Please manual9008 (Please tooldirectory"mode")...{%c_i%}{\n}& call chkdev qcedl rechk 1
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
if "%blplan_frp%"=="y" ECHO.restorefrp... & call write qcedl frp res\%product%\bak\frp_%baktime%.img %chkdev__port__qcedl%
ECHO.restoregpt_main%targetlun%... & call partable writegpt qcedl %storagetype% %targetlun% res\%product%\bak\gpt_main%targetlun%.bin %chkdev__port__qcedl%
ECHO.restore%targetbootpar%... & call write qcedl %targetbootpar% res\%product%\bak\%targetbootpar%.img %chkdev__port__qcedl%
if "%parlayout:~0,2%"=="ab" ECHO.%slot__cur%slot... & call slot qcedl set %slot__cur%
if "%unlockbl_autoerase%"=="y" ECHO.automaticrestore... & call write qcedl misc tool\Android\misc_wipedata.img %chkdev__port__qcedl%
ECHO.Reboot... & call reboot qcedl system
goto UNLOCKBL-DONE
:UNLOCKBL-EFISP
if "%presskeytoedl%"=="y" (goto UNLOCKBL-EFISP-PRESSKEYTOEDL) else (goto UNLOCKBL-EFISP-CMDTOEDL)
:UNLOCKBL-EFISP-PRESSKEYTOEDL
ECHOC {%c_h%}Please device, , PCanyContinue. scriptPlease ...{%c_i%}{\n}& pause>nul
ECHO.Reboot... & adb.exe reboot 1>>%logfile% 2>&1 || ECHOC {%c_e%}Rebootfailed. Please deviceconnectstable. {%c_h%}Press any key to retry...{%c_i%}{\n}&& pause>nul && goto UNLOCKBL
ECHO.note: device. failed, Please data, closescript, .
ECHOC {%c_h%}Please ...{%c_i%}{\n}
call chkdev qcedl rechk 1
ECHOC {%c_h%}{%c_i%}{\n}
goto UNLOCKBL-EFISP-START
:UNLOCKBL-EFISP-CMDTOEDL
ECHO.Rebooting to 9008... & call reboot system qcedl rechk 1
goto UNLOCKBL-EFISP-START
:UNLOCKBL-EFISP-START
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
if "%parlayout:~0,2%"=="ab" (if "%slot__cur%"=="unknown" ECHO.CheckCurrent slot... & call slot qcedl chk)
for /f %%a in ('gettime.exe ^| find "."') do set baktime=%%a
::if "%blplan_frp%"=="y" ECHO.backupfrp... & call read qcedl frp res\%product%\bak\frp_%baktime%.img notice %chkdev__port__qcedl%
ECHO.backupabl_%slot__cur%... & call read qcedl abl_%slot__cur% res\%product%\bak\abl_%slot__cur%_%baktime%.img notice %chkdev__port__qcedl%
ECHO.backupefisp... & call read qcedl efisp res\%product%\bak\efisp_%baktime%.img notice %chkdev__port__qcedl%
ECHO.File backed up tobin\res\%product%\bak.
ECHO.flashabl... & call write qcedl abl_%slot__cur% res\%product%\abl_unlock.img %chkdev__port__qcedl%
ECHO.flashunlock... & call write qcedl efisp tool\Other\8e5gbl\gbl_unlock.efi %chkdev__port__qcedl%
::if "%blplan_frp%"=="y" ECHO.flashunlockfrp... & call write qcedl frp tool\Android\frp_unlock.img %chkdev__port__qcedl%
ECHO.Reboot(iffailedPlease select2)... & call reboot qcedl system
ECHOC {%c_i%}devicebootunlockwarning. {%c_i%}Please scriptselect, Please closescript.{%c_i%}{\n}
:UNLOCKBL-EFISP-4
ECHO.1.unlockwarning   2.unlockwarning   3.
call input choice [1][2]#[3]
if "%choice%"=="3" call open pic pic\blunlockedfeatures.jpg & goto UNLOCKBL-EFISP-4
if "%choice%"=="1" set unlockbl_autoerase=y
if "%choice%"=="2" ECHOC {%c_e%}unlockfailed. Please feedback.{%c_i%}{\n}
:UNLOCKBL-EFISP-1
ECHOC {%c_w%}tool @ , , {%c_i%}{\n}
ECHOC {%c_i%}device, restoredevice. Please closescript, Please Continuemanual, otherwise. {%c_h%}Waitingboot, deviceboot, Please manual9008 (Please tooldirectory"mode")...{%c_i%}{\n}& call chkdev qcedl rechk 1
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
::if "%blplan_frp%"=="y" ECHO.restorefrp... & call write qcedl frp res\%product%\bak\frp_%baktime%.img %chkdev__port__qcedl%
ECHO.restoreabl_%slot__cur%... & call write qcedl abl_%slot__cur% res\%product%\bak\abl_%slot__cur%_%baktime%.img %chkdev__port__qcedl%
ECHO.Clearing efisp... & call write qcedl efisp tool\Other\8e5gbl\efisp_empty.img %chkdev__port__qcedl%
if "%unlockbl_autoerase%"=="y" ECHO.automaticrestore... & call write qcedl misc tool\Android\misc_wipedata.img %chkdev__port__qcedl%
ECHO.Reboot... & call reboot qcedl system
goto UNLOCKBL-DONE
:UNLOCKBL-FLASHABL
if "%presskeytoedl%"=="y" (goto UNLOCKBL-FLASHABL-PRESSKEYTOEDL) else (goto UNLOCKBL-FLASHABL-CMDTOEDL)
:UNLOCKBL-FLASHABL-PRESSKEYTOEDL
ECHOC {%c_h%}Please device, , PCanyContinue. scriptPlease ...{%c_i%}{\n}& pause>nul
ECHO.Reboot... & adb.exe reboot bootloader 1>>%logfile% 2>&1 || ECHOC {%c_e%}Rebootfailed. Please deviceconnectstable. {%c_h%}Press any key to retry...{%c_i%}{\n}&& pause>nul && goto UNLOCKBL
ECHO.note: device. failed, Please data, closescript, .
ECHOC {%c_h%}Please ...{%c_i%}{\n}
call chkdev qcedl rechk 1
ECHOC {%c_h%}{%c_i%}{\n}
goto UNLOCKBL-FLASHABL-START
:UNLOCKBL-FLASHABL-CMDTOEDL
ECHO.Rebooting to 9008... & call reboot system qcedl rechk 1
goto UNLOCKBL-FLASHABL-START
:UNLOCKBL-FLASHABL-START
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
for /f %%a in ('gettime.exe ^| find "."') do set baktime=%%a
if "%blplan_frp%"=="y" ECHO.backupfrp... & call read qcedl frp res\%product%\bak\frp_%baktime%.img notice %chkdev__port__qcedl%
if not "%parlayout:~0,2%"=="ab" (
    ECHO.backupabl... & call read qcedl abl res\%product%\bak\abl_%baktime%.elf notice %chkdev__port__qcedl%
    ECHO.File backed up tobin\res\%product%\bak.
    ECHO.flashunlockabl... & call write qcedl abl res\%product%\abl_unlock.elf %chkdev__port__qcedl%)
if "%parlayout:~0,2%"=="ab" (if "%slot__cur%"=="unknown" ECHO.CheckCurrent slot... & call slot qcedl chk)
if "%parlayout:~0,2%"=="ab" (
    ECHO.backupabl_%slot__cur%... & call read qcedl abl_%slot__cur% res\%product%\bak\abl_%slot__cur%_%baktime%.elf notice %chkdev__port__qcedl%
    ECHO.File backed up tobin\res\%product%\bak.
    ECHO.flashunlockabl_%slot__cur%... & call write qcedl abl_%slot__cur% res\%product%\abl_unlock.elf %chkdev__port__qcedl%)
if "%blplan_frp%"=="y" ECHO.flashunlockfrp... & call write qcedl frp tool\Android\frp_unlock.img %chkdev__port__qcedl%
ECHO.Reboot... & call reboot qcedl system
ECHO.deviceFastboot. ifautomatic, Please manual. Please manualselectCheckFastboot connection. Checkconnect, Please closescript, Please Continue.
:UNLOCKBL-FLASHABL-4
ECHO.1.CheckFastboot connection   2.CheckCheck   3.Fastboot
call input choice #[1][2][3]
if "%choice%"=="2" ECHOC {%c_e%}unlockfailed. Please feedback.{%c_i%}{\n}& goto UNLOCKBL-FLASHABL-1
if "%choice%"=="3" call open pic pic\fastboot.jpg & goto UNLOCKBL-FLASHABL-4
fastboot.exe devices -l 2>&1 | find "fastboot" 1>nul 2>nul || ECHOC {%c_e%}deviceconnect. {%c_i%}Please device, deviceCheckinstall.{%c_i%}{\n}&& goto UNLOCKBL-FLASHABL-4
call chkdev fastboot
ECHO.Reading device information... & call info fastboot
if "%info__fastboot__unlocked%"=="yes" ECHOC {%c_s%}deviceunlock. {%c_i%}{\n}& set unlockbl_chk=y& goto UNLOCKBL-FLASHABL-1
ECHO.executeunlockcommand. ifdeviceunlock, Please select"UNLOCK THE BOOTLOADER", . deviceautomaticReboot, boot, Please closescript, Please Continue.
fastboot.exe flashing unlock 1>>%logfile% 2>&1 || ECHOC {%c_e%}executeunlockcommandfailed. Please log.{%c_i%}{\n}
:UNLOCKBL-FLASHABL-2
ECHO.1.unlock   2.unlock   3.unlock
call input choice [1][2][3]
if "%choice%"=="3" call open pic pic\unlockbl.jpg & goto UNLOCKBL-FLASHABL-2
if "%choice%"=="1" set unlockbl_autoerase=y
if "%choice%"=="2" ECHOC {%c_e%}unlockfailed. Please feedback.{%c_i%}{\n}
goto UNLOCKBL-FLASHABL-1
:UNLOCKBL-FLASHABL-1
ECHOC {%c_w%}tool @ , , {%c_i%}{\n}
ECHOC {%c_i%}device, restoredevice. Please closescript, Please Continuemanual, otherwise. {%c_h%}Waitingboot, deviceboot, Please manual9008 (Please tooldirectory"mode")...{%c_i%}{\n}& call chkdev qcedl rechk 1
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
if "%blplan_frp%"=="y" ECHO.restorefrp... & call write qcedl frp res\%product%\bak\frp_%baktime%.img %chkdev__port__qcedl%
if not "%parlayout:~0,2%"=="ab" (
    ECHO.restoreabl... & call write qcedl abl res\%product%\bak\abl_%baktime%.elf %chkdev__port__qcedl%)
if "%parlayout:~0,2%"=="ab" (
    ECHO.restoreabl_%slot__cur%... & call write qcedl abl_%slot__cur% res\%product%\bak\abl_%slot__cur%_%baktime%.elf %chkdev__port__qcedl%
    ECHO.%slot__cur%slot... & call slot qcedl set %slot__cur%)
if "%unlockbl_autoerase%"=="y" ECHO.automaticrestore... & call write qcedl misc tool\Android\misc_wipedata.img %chkdev__port__qcedl%
ECHO.Reboot... & call reboot qcedl system
goto UNLOCKBL-DONE
:UNLOCKBL-special__ailsa_ii
ECHO.Rebooting to 9008... & call reboot system qcedl rechk 1
goto UNLOCKBL-special__ailsa_ii-START
:UNLOCKBL-special__ailsa_ii-START
ECHO.Sending programmer... & call write qcedlsendfh %chkdev__port__qcedl% %framework_workspace%\res\%product%\devprg
for /f %%a in ('gettime.exe ^| find "."') do set baktime=%%a
ECHO.backupaboot... & call read qcedl aboot res\%product%\bak\aboot_%baktime%.mbn notice %chkdev__port__qcedl%
ECHO.backupfbop...  & call read qcedl fbop  res\%product%\bak\fbop_%baktime%.img  notice %chkdev__port__qcedl%
::ECHO.backupfrp...   & call read qcedl frp   res\%product%\bak\frp_%baktime%.img   notice %chkdev__port__qcedl%
::ECHO.patchfrpOEMunlock... & call imgkit patchfrp res\%product%\bak\frp_%baktime%.img %tmpdir%\frp_oemunlockon.img oemunlockon noprompt
ECHO.flashunlockaboot... & call write qcedl aboot res\%product%\aboot_unlock.mbn %chkdev__port__qcedl%
ECHO.flashunlockfbop...  & call write qcedl fbop  res\%product%\fbop_unlock.img  %chkdev__port__qcedl%
::ECHO.flashunlockfrp...   & call write qcedl frp   %tmpdir%\frp_oemunlockon.img        %chkdev__port__qcedl%
ECHO.Reboot to system... & call reboot qcedl system
ECHO.deviceautomaticReboot to system. bootifUSB, Please USB. ifboot, Please feedback.
call chkdev system rechk 1
ECHO.RebootFastboot... & call reboot system fastboot rechk 1
ECHO.executeunlockcommand...
fastboot.exe oem unlock 1>%tmpdir%\output.txt 2>&1 || ECHOC {%c_e%}executeunlockcommandfailed. Please log.{%c_i%}{\n}
type %tmpdir%\output.txt>>%logfile%
find "Device already : unlocked!" "%tmpdir%\output.txt" 1>nul 2>nul && ECHOC {%c_s%}deviceunlock.{%c_i%}{\n}&& set unlockbl_chk=y&& goto UNLOCKBL-DONE
ECHO.ifdeviceunlock, Please select"Yes", . deviceautomaticRebootrestore.
ECHO.1.unlock   2.unlock
call input choice [1][2]
if "%choice%"=="2" ECHOC {%c_e%}unlockfailed. Please feedback.{%c_i%}{\n}
goto UNLOCKBL-DONE
:UNLOCKBL-DIRECT
ECHO.Rebootfastboot... & call reboot system fastboot rechk 1
:UNLOCKBL-DIRECT-START
ECHO.Reading device information... & call info fastboot
if "%info__fastboot__unlocked%"=="yes" ECHOC {%c_s%}deviceunlock. {%c_i%}{\n}& set unlockbl_chk=y& goto UNLOCKBL-DONE
ECHO.executeunlockcommand. ifdeviceunlock, Please select"UNLOCK THE BOOTLOADER", . if, descriptionunlockfailed.
fastboot.exe flashing unlock 1>>%logfile% 2>&1 || ECHOC {%c_e%}executeunlockcommandfailed. Please log.{%c_i%}{\n}
ECHO.1.unlock   2.unlock
call input choice [1][2]
if "%choice%"=="2" ECHOC {%c_e%}unlockfailed. Please feedback.{%c_i%}{\n}
goto UNLOCKBL-DONE
:UNLOCKBL-DONE
if "%unlockbl_chk%"=="y" goto UNLOCKBL-DONE-1
ECHO.
::ECHO.1.[recommended]Checkunlocksuccess
ECHO.1.Unlock bootloader
ECHO.2.Continue
call input choice #[1][2]
ECHO.
::if "%choice%"=="1" goto UNLOCKBL-1
if "%choice%"=="1" call open pic pic\blunlockedfeatures.jpg & goto UNLOCKBL-DONE
:UNLOCKBL-DONE-1
ECHO. & ECHOC {%c_s%}All done. {%c_i%}Unlock finished. If the device does not boot, enter Recovery and wipe data, then wait for boot. {%c_h%}Press any key to return...{%c_i%}{\n}& pause>nul & goto MENU


:SELDEV
type conf\dev.csv | find /v "[product]" | find "[" | find /N "]" 1>%tmpdir%\dev.txt
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.Select device model
ECHO.
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.
ECHO.If your device is not listed or the information is wrong, please send feedback.
ECHO.
ECHO.
for /f "tokens=1,3,4 delims=[]," %%a in (%tmpdir%\dev.txt) do (ECHO.[%%a] %%c  %%b& ECHO.)
ECHO.
call input choice
if "%choice%"=="" goto SELDEV
find "[%choice%][" "%tmpdir%\dev.txt" 1>nul 2>nul || goto SELDEV
ECHO.Device model saved. Please wait...
for /f "tokens=2 delims=[]," %%a in ('type %tmpdir%\dev.txt ^| find "[%choice%]["') do set product=%%a
call ztetoolbox confdevpre
call framework conf user.bat product %product%
call conf\dev-%product%.bat
goto MENU


:THEME
CLS
ECHOC {%c_a%}=--------------------------------------------------------------------={%c_i%}{\n}
ECHO.
ECHO.Script theme
ECHO.
ECHOC {%c_a%}=--------------------------------------------------------------------={%c_i%}{\n}
ECHO.
ECHO.
ECHO.Note: changing the theme requires restarting the script.
ECHO.
ECHO.
ECHO.1.Default
ECHO.2.Classic
ECHO.3.Ubuntu
ECHO.4.Douyin Hacker
ECHO.5.Gold
ECHO.6.DOS
ECHO.7.Chinese New Year
ECHO.
call input choice [1][2][3][4][5][6][7]
if "%choice%"=="1" set target=default
if "%choice%"=="2" set target=classic
if "%choice%"=="3" set target=ubuntu
if "%choice%"=="4" set target=douyinhacker
if "%choice%"=="5" set target=gold
if "%choice%"=="6" set target=dos
if "%choice%"=="7" set target=ChineseNewYear
::
call framework theme %target%
echo.@ECHO OFF>%tmpdir%\theme.bat
echo.mode con cols=50 lines=17 >>%tmpdir%\theme.bat
echo.cd ..>>%tmpdir%\theme.bat
echo.set path=%framework_workspace%;%framework_workspace%\tool\Win;%framework_workspace%\tool\Android;%path% >>%tmpdir%\theme.bat
echo.COLOR %c_i% >>%tmpdir%\theme.bat
echo.TITLE theme: %target% >>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.ECHOC {%c_i%}information{%c_i%}{\n}>>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.ECHOC {%c_w%}warning information{%c_i%}{\n}>>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.ECHOC {%c_e%}error information{%c_i%}{\n}>>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.ECHOC {%c_s%}success information{%c_i%}{\n}>>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.ECHOC {%c_h%}manual{%c_i%}{\n}>>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.ECHOC {%c_a%}{%c_i%}{\n}>>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.ECHOC {%c_we%}{%c_i%}{\n}>>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.pause^>nul>>%tmpdir%\theme.bat
echo.EXIT>>%tmpdir%\theme.bat
call framework theme
start %tmpdir%\theme.bat
::done
ECHO.
ECHO.Apply this theme?
ECHO.1.Save and restart   2.Back
call input choice #[1][2]
if "%choice%"=="1" call framework conf user.bat framework_theme %target%& ECHOC {%c_i%}Theme changed. Restart the script to apply it. {%c_h%}Press any key to close...{%c_i%}{\n}& call log %logger% I Change theme%target%& pause>nul & EXIT
if "%choice%"=="2" goto THEME






:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}Sorry, the script encountered a problem and cannot continue. Please check the log. {%c_h%}Press any key to exit...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.Sorry, the script encountered a problem and cannot continue. Press any key to exit...& pause>nul & EXIT)
