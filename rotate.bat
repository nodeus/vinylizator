rem Vinilyzator — script to convert mp3 file to video of a rotating vinyl record
rem Track cover from mp3 file becomes a disc cover, metadata of the title and author of the track are superimposed on the disc cover
rem If an mp3 file has no built in track cover, the disc cover is set by default
rem 
rem using ffmpeg https://ffmpeg.org/
rem using imagemagick https://imagemagick.org/
rem
rem nodeus^lightfuture 2022

@echo off
@chcp 65001
@set audio=audio/audio.mp3

rem set time in sec for 360 degree rotate
@set time=36

rem set some vars for fontsize and fontfile
@set fontsize=16
@set fontfile=font/PTM55F.ttf

rem nvidia hevc — set codec for nvidia hardware rendering (-qp 22 — constant quality parameter)
@set codec=-c:v hevc_nvenc -profile:v main10 -pix_fmt yuv420p -preset fast -rc constqp -qp 22 -init_qpB 2 -movflags +faststart -flags +cgop -framerate 60 -r 60

rem amd hevc — set codec for AMD hardware rendering
rem @set codec=-c:v hevc_amf -rc cqp -qp_p 22 -qp_i 22 -movflags +faststart -flags +cgop -framerate 60 -r 60

rem set codec for software render
rem @set codec=-c:v libx264 -crf 22 -movflags +faststart -flags +cgop -framerate 60 -r 60

@copy /y %CD%\gfx\default\albumart.png %CD%\gfx\albumart.png
@cls

echo [1/7] generate text metadata
@for /f "tokens=1 delims=x" %%b in ('"ffprobe -v error -show_entries format_tags=artist -of csv=s=x:p=0 "%audio%""') do set artist=%%b
@for /f "tokens=1 delims=x" %%c in ('"ffprobe -v error -show_entries format_tags=title -of csv=s=x:p=0 "%audio%""') do set title=%%c
@set textmeta="%artist% — %title%"
@set filename="%artist%-%title%"
@set filename=%filename: =_%

rem extract albumart
echo [2/7] extract albumart
@ffmpeg -loglevel error -hide_banner -y -i %audio% -c:v copy -an gfx/albumart.png

rem resize albumart for vinyl cover
echo [3/7] resize albumart
@magick gfx/albumart.png -resize 1096x1096 -scale 1146 -gravity center -extent 1096x1096^ -unsharp 0x1 gfx/cover.png

rem combine cover and blanc vinyl mockup
echo [4/7] composite cover and empty vinyl mockup
@magick gfx/cover.png -gravity center gfx/default/label-clear-mask.png -alpha Off -compose CopyOpacity -composite gfx/covercrop.png

rem generate text label from meta and combine all images
@magick -background none -fill black -font PT-Mono -size 600x200 -gravity center label:%textmeta% gfx/meta.png
@magick composite -gravity center -compose Multiply gfx/covercrop.png gfx/default/vinyl-mock-clear.png gfx/covernew.png
@magick composite -compose Over -gravity center -geometry +0+250 gfx/meta.png gfx/covernew.png gfx/covertext.png 

rem generate rotated video
echo [5/7] generate rotated video cover
@ffmpeg -loglevel error -hide_banner -y -loop 1 -i gfx/covertext.png -t %time% %codec% -vf "rotate=2*PI*t/%time%" video/out.mp4

rem connect rotated cover and music track
echo [6/7] generate video with audio
@ffmpeg -loglevel error -hide_banner -y -stream_loop -1 -i video/out.mp4 -i %audio% -shortest -map 0:v:0 -map 1:a:0 %codec% video/%filename%_VinylVideo_HEVC-FHD.mp4

echo [7/7] done

rem delete temporary files
echo delete temporary files
@del %CD%\gfx\*.png
@del %CD%\video\out.mp4