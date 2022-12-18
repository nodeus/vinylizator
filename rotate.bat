rem using ffmpeg https://ffmpeg.org/
rem using graphicsmagic http://www.graphicsmagick.org

@cls
rem @echo off
rem set time in sec for 360 degree rotate
chcp 65001
set name=audio/audio.mp3
@set time=15
for /f "tokens=1 delims=x" %%b in ('"ffprobe -v error -show_entries format_tags=artist -of csv=s=x:p=0 "%name%""') do set artist=%%b
for /f "tokens=1 delims=x" %%c in ('"ffprobe -v error -show_entries format_tags=title -of csv=s=x:p=0 "%name%""') do set title=%%c

rem extract albumart
@echo extract albumart
ffmpeg -y -i %name% -c:v copy -an gfx/albumart.png

rem resize image

ffmpeg -y -i gfx/albumart.png -filter_complex scale=-2:368 -sws_flags spline gfx/cover.png

rem composite cover and clear vinyl mockup

gm composite -compose multiply -geometry +356+356 gfx/cover.png gfx/vinyl-mock-clear.png gfx/covernew.png

rem generate video cover from albumart with music duration
@echo generate video cover
ffmpeg -y -loop 1 -framerate 60 -i gfx/covernew.png -i audio.mp3 -c:v libx265 -x265-params lossless=1  -shortest -pix_fmt yuv420p -movflags faststart video/out.mp4

@echo generate text metadata

rem generate rotated cover from albumart
@echo generate rotated video
ffmpeg -y -i video/out.mp4  -vf "rotate=2*PI*t/%time%" -c:a copy video/out-rotated.mp4


rem -filter_complex "[0:v][1:v]blend=all_mode=softlight[v],[v]drawtext=fontfile=PTM75F.ttf:text='%artist%':fontcolor=black:fontsize=20:x=(w-text_w)/2:y=((h-text_h)/2)-75,drawtext=fontfile=PTM55F.ttf:text='%title%':fontcolor=black:fontsize=20:y=((h-text_h)/2)+75:x=(w-text_w)/2 [v2],[v2]scale=-2:1080[v3]"
rem -filter rotate=2*pi+5/T -vf "scale=500:500,loop=-1:1" lossless=1
rem -c:v libx265 -x265-params lossless=1 -shortest -pix_fmt yuv420p -movflags faststart