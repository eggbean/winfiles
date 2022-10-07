@echo off

doskey hosts=gvim.exe C:\Windows\System32\drivers\etc\hosts
doskey aliases=gvim.exe %LOCALAPPDATA%\clink\clink_start.cmd
doskey date=%USERPROFILE%\scoop\shims\date.exe $*
doskey realpath=%USERPROFILE%\winfiles\bin\realpath.cmd $*
doskey cd=cdd.cmd $*
doskey ls=ls --color=always $*
doskey ll=ls -l --color=always $*
doskey lla=ls -Al --color=always $*
doskey sudo=gsudo $*
doskey vi=vim $*
doskey tree=tre.exe $*

set PATH=C:\Program Files (x86)\Vim\vim90;%USERPROFILE%\winfiles\bin;%PATH%

set LS_COLORS=no=00:rs=0:fi=00:di=01;34:ln=38;5;123:mh=04;36:pi=33:so=01;38;5;64:do=04;01;36:bd=01;33:cd=33:or=31:ex=01;32:su=01;04;37:sg=01;04;37:ca=01;37:tw=01;37;44:ow=01;04;34:st=04;37;44:*.7z=31:*.ace=31:*.alz=31:*.arc=31:*.arj=31:*.bz=31:*.bz2=31:*.cab=31:*.cpio=31:*.deb=31:*.dz=31:*.ear=31:*.gz=31:*.jar=31:*.lha=31:*.lrz=31:*.lz=31:*.lz4=31:*.lzh=31:*.lzma=31:*.lzo=31:*.rar=31:*.rpm=31:*.rz=31:*.sar=31:*.t7z=31:*.tar=31:*.taz=31:*.tbz=31:*.tbz2=31:*.tgz=31:*.tlz=31:*.txz=31:*.tz=31:*.tzo=31:*.tzst=31:*.war=31:*.xz=31:*.z=31:*.Z=31:*.zip=31:*.zoo=31:*.zst=31:*.aac=38;5;92:*.au=38;5;92:*.m4a=38;5;92:*.mid=38;5;92:*.midi=38;5;92:*.mka=38;5;92:*.mp3=38;5;92:*.mpa=38;5;92:*.mpeg=38;5;92:*.mpg=38;5;92:*.ogg=38;5;92:*.opus=38;5;92:*.ra=38;5;92:*.alac=38;5;93:*.flac=38;5;93:*.wav=38;5;93:*.doc=38;5;105:*.docx=38;5;105:*.dot=38;5;105:*.dvi=38;5;105:*.odg=38;5;105:*.odp=38;5;105:*.ods=38;5;105:*.odt=38;5;105:*.otg=38;5;105:*.otp=38;5;105:*.ots=38;5;105:*.ott=38;5;105:*.pdf=38;5;105:*.ppt=38;5;105:*.pptx=38;5;105:*.xls=38;5;105:*.xlsx=38;5;105:*.app=01;32:*.bat=01;32:*.btm=01;32:*.cmd=01;32:*.com=01;32:*.exe=01;32:*.reg=01;32:*~=38;5;244:*.bak=38;5;244:*.bak?=38;5;244:*.BAK=38;5;244:*.copy=38;5;244:*.log=38;5;244:*.LOG=38;5;244:*.LOG1=38;5;244:*.LOG2=38;5;244:*.LOG3=38;5;244:*.LOG4=38;5;244:*.LOG5=38;5;244:*.LOG6=38;5;244:*.LOG7=38;5;244:*.LOG8=38;5;244:*.LOG9=38;5;244:*.notes=38;5;244:*.old=38;5;244:*.OLD=38;5;244:*.orig=38;5;244:*.ORIG=38;5;244:*.swo=38;5;244:*.swp=38;5;244:*.tmp=38;5;244:*.1=38;5;244:*.2=38;5;244:*.3=38;5;244:*.4=38;5;244:*.5=38;5;244:*.vim-bookmarks=38;5;244:*.bmp=38;5;170:*.cgm=38;5;170:*.dl=38;5;170:*.emf=38;5;170:*.eps=38;5;170:*.gif=38;5;170:*.jpeg=38;5;170:*.jpg=38;5;170:*.JPG=38;5;170:*.mng=38;5;170:*.pbm=38;5;170:*.pcx=38;5;170:*.pgm=38;5;170:*.png=38;5;170:*.PNG=38;5;170:*.ppm=38;5;170:*.pps=38;5;170:*.ppsx=38;5;170:*.ps=38;5;170:*.svg=38;5;170:*.svgz=38;5;170:*.tga=38;5;170:*.tif=38;5;170:*.tiff=38;5;170:*.xbm=38;5;170:*.xcf=38;5;170:*.xpm=38;5;170:*.xwd=38;5;170:*.xwd=38;5;170:*.yuv=38;5;170:*.anx=38;5;135:*.asf=38;5;135:*.avi=38;5;135:*.axv=38;5;135:*.flc=38;5;135:*.fli=38;5;135:*.flv=38;5;135:*.gl=38;5;135:*.m2ts=38;5;135:*.m2v=38;5;135:*.m4v=38;5;135:*.mkv=38;5;135:*.mov=38;5;135:*.MOV=38;5;135:*.mp4=38;5;135:*.mpeg=38;5;135:*.mpg=38;5;135:*.nuv=38;5;135:*.ogm=38;5;135:*.ogv=38;5;135:*.ogx=38;5;135:*.qt=38;5;135:*.rm=38;5;135:*.rmvb=38;5;135:*.swf=38;5;135:*.vob=38;5;135:*.webm=38;5;135:*.wmv=38;5;135:*.asc=38;5;109:*.enc=38;5;109:*.gpg=38;5;109:*.p12=38;5;109:*.pfx=38;5;109:*.pgp=38;5;109:*.sig=38;5;109:*.signature=38;5;109:*.crt=38;5;109:*.p8=38;5;109:*.pem=38;5;109:*.cer=38;5;109:*.ca-bundle=38;5;109:*.p7b=38;5;109:*.p7c=38;5;109:*.p7r=38;5;109:*.p7s=38;5;109:*.spc=38;5;109:*.key=38;5;109:*.keystore=38;5;109:*.jks=38;5;109:*.crl=38;5;109:*.csr=38;5;109:*.der=38;5;109:*.kbx=38;5;109:*.backup=38;5;244:*.hcl=38;5;244:*.tfstate=38;5;244:*.regtrans-ms=38;5;244:*.blf=38;5;244:*.ini=38;5;244:*.DAT=38;5;244:

pushd .
