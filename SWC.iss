#define MyAppName "Software Carpentry Windows Installer"
#define MyAppVersion "0.4"
#define MyAppPublisher "Software Carpentry"
#define MyAppURL "https://software-carpentry.org"
#define MyAppContact "https://software-carpentry.org"

#define MyGroupName "Software Carpentry Windows Installer"

#ifndef Arch
  #define Arch "x86_64"
#endif

#ifndef Compression
  #define Compression "lzma"
#endif

#ifndef EnvsDir
  #define EnvsDir "envs"
#endif

#ifndef OutputDir
  #define OutputDir "dist"
#endif

#ifndef DiskSpanning
  #if Compression == "none"
    #define DiskSpanning="yes"
  #else
    #define DiskSpanning="no"
  #endif
#endif

#define Runtime     "{app}"
#define Bin         Runtime + "\bin"

[Setup]
AppCopyright={#MyAppPublisher}
AppId={#MyAppName}
AppContact={#MyAppContact}
AppComments={#MyAppURL}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
DefaultDirName={userappdata}\{#MyGroupName}
DefaultGroupName={#MyGroupName}
DisableProgramGroupPage=yes
DisableWelcomePage=no
DiskSpanning={#DiskSpanning}
OutputDir={#OutputDir}
OutputBaseFilename={#MyAppName}-{#MyAppVersion}
Compression={#Compression}
SolidCompression=yes
WizardImageStretch=yes
UninstallDisplayIcon={app}\unins000.exe
SetupIconFile=resources\software-carpentry-logo.ico
ChangesEnvironment=true
SetupLogging=yes
PrivilegesRequired=lowest

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: startmenu; Description: "Create &start menu icons"; GroupDescription: "Additional icons"
Name: desktop; Description: "Create &desktop icons"; GroupDescription: "Additional icons"

[Files]
Source: "{#EnvsDir}\runtime-{#Arch}\*"; DestDir: "{#Runtime}"; Flags: recursesubdirs ignoreversion
Source: "resources\software-carpentry-logo.ico"; DestDir: "{app}"; Flags: ignoreversion; AfterInstall: FixupSymlinks

; InnoSetup will not create empty directories found when including files
; recursively in the [Files] section, so any directories that must exist
; (but start out empty) in the cygwin distribution must be created
;
; /etc/fstab.d is where user-specific mount tables go
;
; /dev/shm and /dev/mqueue are used by the system for POSIX semaphores, shared
; memory, and message queues and must be created world-writeable
[Dirs]
Name: "{#Runtime}\etc\fstab.d"; Permissions: users-modify
Name: "{#Runtime}\dev\shm"; Permissions: users-modify
Name: "{#Runtime}\dev\mqueue"; Permissions: users-modify

[UninstallDelete]
Type: filesandordirs; Name: "{#Runtime}\etc\fstab.d"
Type: filesandordirs; Name: "{#Runtime}\dev\shm"
Type: filesandordirs; Name: "{#Runtime}\dev\mqueue"

#define RunSh "/bin/bash --login"
#define RunShTitle "Terminal"
#define RunShDoc "UNIX terminal"
#define RunShIconFilename Bin + "\mintty.exe"


[Icons]
Name: "{app}\Terminal"; Filename: "{#Bin}\mintty.exe"; Parameters: "-t '{#RunShTitle}' {#RunSh}"; WorkingDir: "{app}"; Comment: "{#RunShDoc}"; IconFilename: "{#RunShIconFilename}"
Name: "{group}\Terminal"; Filename: "{#Bin}\mintty.exe"; Parameters: "-t '{#RunShTitle}' {#RunSh}"; WorkingDir: "{app}"; Comment: "{#RunShDoc}"; IconFilename: "{#RunShIconFilename}"; Tasks: startmenu
Name: "{commondesktop}\Terminal"; Filename: "{#Bin}\mintty.exe"; Parameters: "-t '{#RunShTitle}' {#RunSh}"; WorkingDir: "{app}"; Comment: "{#RunShDoc}"; IconFilename: "{#RunShIconFilename}"; Tasks: desktop


[Code]
procedure FixupSymlinks();
var
    n: Integer;
    i: Integer;
    resultCode: Integer;
    filenames: TArrayOfString;
    filenam: String;
begin
    LoadStringsFromFile(ExpandConstant('{app}\etc\symlinks.lst'), filenames);
    n := GetArrayLength(filenames);
    WizardForm.ProgressGauge.Min := 0;
    WizardForm.ProgressGauge.Max := n - 1;
    WizardForm.ProgressGauge.Position := 0;
    WizardForm.StatusLabel.Caption := 'Fixing up symlinks...';
    for i := 0 to n - 1 do
    begin
        filenam := filenames[i];
        WizardForm.FilenameLabel.Caption := Copy(filenam, 2, Length(filenam));
        WizardForm.ProgressGauge.Position := i;
        Exec(ExpandConstant('{sys}\attrib.exe'), '+S ' + filenam,
                            ExpandConstant('{app}'), SW_HIDE,
                            ewNoWait, resultCode);
    end;
end;
