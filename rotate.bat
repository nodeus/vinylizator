rem set time in sec for 360 degree rotate

set time=60

rem ffmpeg -y -i rot.png -t 10 out.mp4

rem extract albumart

ffmpeg -y -i audio.mp3 -c:v copy -an gfx/cover.png

rem generate cover from metadata

rem generate video cover from albumart with music duration

ffmpeg -loop 1 -framerate 60 -i gfx/cover.png -i audio.mp3 -c:v libx265 -x265-params lossless=1 -shortest -pix_fmt yuv420p -movflags faststart video/out.mp4

rem generate rotated cover from albumart

rem ffmpeg -y -i out.mp4 -vf "rotate=2*PI*t/%time%" -c:a copy out2.mp4

rem -filter rotate=2*pi+5/T -vf "scale=500:500,loop=-1:1"