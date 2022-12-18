rem using ffmpeg https://ffmpeg.org/
rem using graphicsmagic http://www.graphicsmagick.org

@cls
rem @echo off
rem set time in sec for 360 degree rotate

@set time=15

rem extract albumart
@echo extract albumart
ffmpeg -loglevel error -y -i audio.mp3 -c:v copy -an gfx/albumart.png

rem resize image

ffmpeg -loglevel error -y -i gfx/albumart.png -filter_complex scale=-2:368 -sws_flags spline gfx/cover.png

rem generate cover from metadata

rem generate video cover from albumart with music duration
@echo generate video cover
ffmpeg -loglevel error -y -loop 1 -framerate 60 -i gfx/cover.png -i audio.mp3 -c:v libx265 -x265-params lossless=1 -shortest -pix_fmt yuv420p -movflags faststart video/out.mp4

rem generate rotated cover from albumart
@echo generate rotated video
ffmpeg -loglevel error -y -i video/out.mp4  -vf "rotate=2*PI*t/%time%" -c:a copy video/out-rotated.mp4

rem -filter rotate=2*pi+5/T -vf "scale=500:500,loop=-1:1" lossless=1
rem -c:v libx265 -x265-params lossless=1 -shortest -pix_fmt yuv420p -movflags faststart