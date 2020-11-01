Name "VHF Helper $%TAG% ($%COMMIT_HASH%)"
RequestExecutionLevel admin
Unicode True
InstallDir "C:\X-Plane Folder"

Page directory
Page components
Page instfiles

Section "VHF Helper Main Script (required)"
	SectionIn RO
	SetOutPath $INSTDIR\Resources\plugins\FlyWithLua\Scripts
	
	File ..\scripts\vhf_helper.lua  
SectionEnd

Section "VHF Helper Dependencies"
	SetOutPath $INSTDIR\Resources\plugins\FlyWithLua\Modules
	
	File ..\modules\LIP.lua
	File ..\modules\eventbus.lua
SectionEnd
