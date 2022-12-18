rem ffmpeg -y -i rot.png -t 10 out.mp4
SET time=15
ffmpeg -framerate 60 -i rot.png -i audio.mp3 -c:v libx265 -x265-params lossless=1 -loop 1 -pix_fmt yuv420p -movflags faststart out.mp4
ffmpeg -y -i out.mp4 -vf "rotate=2*PI*t/%time%" -c:a copy out2.mp4
pause
rem -filter rotate=2*pi+5/T -vf "scale=500:500,loop=-1:1"