rem using ffmpeg https://ffmpeg.org/
rem using graphicsmagic http://www.graphicsmagick.org
@echo off
chcp 65001
set audio=audio/audio.mp3
set codec=-c:v hevc_nvenc -profile:v main10 -pix_fmt yuv420p -preset fast -rc constqp -qp 15 -init_qpB 2 -movflags +faststart -flags +cgop -framerate 60 -r 60
copy /y %CD%\gfx\default\albumart.png %CD%\gfx\albumart.png
@cls

rem set time in sec for 360 degree rotate
set time=15
rem set some vars
set fontsize=16
set fontfile=font/PTM55F.ttf

echo [1/7] generate text metadata
for /f "tokens=1 delims=x" %%b in ('"ffprobe -v error -show_entries format_tags=artist -of csv=s=x:p=0 "%audio%""') do set artist=%%b
for /f "tokens=1 delims=x" %%c in ('"ffprobe -v error -show_entries format_tags=title -of csv=s=x:p=0 "%audio%""') do set title=%%c
set textmeta="%artist%-%title%"
set filename="%artist%-%title%"
set filename=%filename: =_%

rem extract albumart
echo [2/7] extract albumart
ffmpeg -loglevel error -hide_banner -y -i %audio% -c:v copy -an gfx/albumart.png

rem resize image
echo [3/7] resize albumart
magick gfx/albumart.png -resize 368x368\^ gfx/cover.png

rem composite cover and clear vinyl mockup
echo [4/7] composite cover and empty vinyl mockup
magick gfx/cover.png -gravity center gfx/default/label-clear-mask.png -alpha Off -compose CopyOpacity -composite gfx/covercrop.png
magick composite -gravity center -compose Multiply gfx/covercrop.png gfx/default/vinyl-mock-clear.png gfx/covernew.png

rem generate video cover from albumart with music duration
echo [5/7] generate video cover
ffmpeg -loglevel error -hide_banner -y -loop 1 -i gfx/covernew.png -i %audio% -shortest -filter_complex "drawtext=fontsize=%fontsize%:fontfile=%fontfile%:fontcolor=white:text='"—%textmeta%—"':x=(w-text_w)/2:y=(h-text_h)/2+75, drawtext=%fontsize%:fontfile=font/PTM55F.ttf:fontcolor=black:text='"—%textmeta%—"':x=(w-text_w)/2-1:y=(h-text_h)/2+74" %codec% video/out.mp4

rem generate rotated cover from albumart
echo [6/7] generate rotated video
ffmpeg -loglevel error -hide_banner -y -i video/out.mp4  %codec% -vf "rotate=2*PI*t/%time%" -c:a copy video/%filename%_VinylVideo_HEVC-FHD.mp4

echo [7/7] delete temporary files
del %CD%\gfx\*.png
del %CD%\video\out.mp4