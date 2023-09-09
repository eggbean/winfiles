@echo off

set GIT_SSH=%USERPROFILE%\winfiles\bin\plink.exe
set GH_BROWSER="C:\\Program\ Files\\qutebrowser\\qutebrowser.exe"
set LESSHISTFILE=%APPDATA%\_lesshst
set PATH=C:\Program Files\Vim\vim90;C:\Program Files (x86)\GnuPG\bin;%USERPROFILE%\scoop\shims;%USERPROFILE%\winfiles\bin;%USERPROFILE%\winfiles\scripts;%PATH%
set EDITOR=vim
set CLINK_PATH=%USERPROFILE%\winfiles\Settings\clink-path
set CLINK_COMPLETIONS_DIR=%USERPROFILE%\winfiles\Settings\clink-completions
set KOMOREBI_CONFIG_HOME=%USERPROFILE%\.config\komorebi
set LS_COLORS=no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:ex=01;32:su=37;41:sg=30;43:tw=30;42:st=37;44:*.7z=1;31:*.ace=1;31:*.alz=1;31:*.arc=1;31:*.arj=1;31:*.bz=1;31:*.bz2=1;31:*.bz3=1;31:*.cab=1;31:*.cpio=1;31:*.deb=1;31:*.dz=1;31:*.ear=1;31:*.gz=1;31:*.jar=1;31:*.lha=1;31:*.lrz=1;31:*.lz=1;31:*.lz4=1;31:*.lzh=1;31:*.lzma=1;31:*.lzo=1;31:*.rar=1;31:*.rpm=1;31:*.rz=1;31:*.sar=1;31:*.t7z=1;31:*.tar=1;31:*.taz=1;31:*.tbz=1;31:*.tbz2=1;31:*.tgz=1;31:*.tlz=1;31:*.txz=1;31:*.tz=1;31:*.tzo=1;31:*.tzst=1;31:*.war=1;31:*.xz=1;31:*.z=1;31:*.Z=1;31:*.zip=1;31:*.zoo=1;31:*.zst=1;31:*.aac=00;36:*.au=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpa=00;36:*.mpeg=00;36:*.mpg=00;36:*.ogg=00;36:*.opus=00;36:*.ra=00;36:*.alac=00;36:*.flac=00;36:*.wav=00;36:*.doc=1;34:*.docx=1;34:*.dot=1;34:*.dvi=1;34:*.odg=1;34:*.odp=1;34:*.ods=1;34:*.odt=1;34:*.otg=1;34:*.otp=1;34:*.ots=1;34:*.ott=1;34:*.pdf=1;34:*.ppt=1;34:*.pptx=1;34:*.xls=1;34:*.xlsx=1;34:*.app=00;32:*.bat=00;32:*.btm=00;32:*.cmd=00;32:*.com=00;32:*.exe=00;32:*.reg=00;32:*.ps1=00;32:*~=1;30:*.bak=1;30:*.bak?=1;30:*.BAK=1;30:*.copy=1;30:*.log=1;30:*.LOG=1;30:*.LOG1=1;30:*.LOG2=1;30:*.LOG3=1;30:*.LOG4=1;30:*.LOG5=1;30:*.LOG6=1;30:*.LOG7=1;30:*.LOG8=1;30:*.LOG9=1;30:*.notes=1;30:*.old=1;30:*.OLD=1;30:*.orig=1;30:*.ORIG=1;30:*.swo=1;30:*.swp=1;30:*.tmp=1;30:*.1=1;30:*.2=1;30:*.3=1;30:*.4=1;30:*.5=1;30:*.vim-bookmarks=1;30:*.bmp=1;35:*.cgm=1;35:*.dl=1;35:*.emf=1;35:*.eps=1;35:*.gif=1;35:*.jpeg=1;35:*.jpg=1;35:*.JPG=1;35:*.mng=1;35:*.pbm=1;35:*.pcx=1;35:*.pgm=1;35:*.png=1;35:*.PNG=1;35:*.ppm=1;35:*.pps=1;35:*.ppsx=1;35:*.ps=1;35:*.svg=1;35:*.svgz=1;35:*.tga=1;35:*.tif=1;35:*.tiff=1;35:*.xbm=1;35:*.xcf=1;35:*.xpm=1;35:*.xwd=1;35:*.xwd=1;35:*.yuv=1;35:*.anx=00;35:*.asf=00;35:*.avi=00;35:*.axv=00;35:*.flc=00;35:*.fli=00;35:*.flv=00;35:*.gl=00;35:*.m2ts=00;35:*.m2v=00;35:*.m4v=00;35:*.mkv=00;35:*.mov=00;35:*.MOV=00;35:*.mp4=00;35:*.mpeg=00;35:*.mpg=00;35:*.nuv=00;35:*.ogm=00;35:*.ogv=00;35:*.ogx=00;35:*.qt=00;35:*.rm=00;35:*.rmvb=00;35:*.swf=00;35:*.vob=00;35:*.webm=00;35:*.wmv=00;35:*.asc=00;33:*.enc=00;33:*.gpg=00;33:*.p12=00;33:*.pfx=00;33:*.pgp=00;33:*.sig=00;33:*.signature=00;33:*.crt=00;33:*.p8=00;33:*.pem=00;33:*.cer=00;33:*.ca-bundle=00;33:*.p7b=00;33:*.p7c=00;33:*.p7r=00;33:*.p7s=00;33:*.spc=00;33:*.key=00;33:*.keystore=00;33:*.jks=00;33:*.crl=00;33:*.csr=00;33:*.der=00;33:*.kbx=00;33:*.ppk=00;33:*.backup=1;30:*.hcl=1;30:*.tfstate=1;30:*.regtrans-ms=1;30:*.blf=1;30:*.ini=1;30:*.DAT=1;30:

doskey startmenu=pushd %APPDATA%\Microsoft\Windows\Start Menu\Programs
doskey date=%USERPROFILE%\scoop\shims\date.exe $*
doskey find=%USERPROFILE%\scoop\shims\find.exe $*
doskey sudo=gsudo $*
doskey cd=cdd.cmd $*
doskey ls=exa $*
doskey ll=exa -l --git $*
doskey lla=exa -al --git $*
doskey llt=exa -l -s modified --git $*
doskey cp=cp -i $*
doskey mv=mv -i $*
doskey rm=rm -i $*
doskey vi=vim $*
doskey tree=tre.exe $*
doskey br=broot $*
doskey wol=WakeMeOnLan.exe $*
doskey vihosts=sudo gvim C:\Windows\System32\Drivers\etc\hosts

if %CD%==C:\Windows\System32 (
    cdd %USERPROFILE%
    cdd --reset >nul 2>&1
)
if %CD%==F:\Users\jason\AppData\Local\PowerToys (
    clear
    fastfetch -l Windows
    cdd %USERPROFILE%
    cdd --reset >nul 2>&1
)
