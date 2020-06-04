# Convert.sh

Convert a `mkv` file to a `mp4` one to be able to stream it, using ffmpeg.
We need to have a h264 encoded video with AAC encoded sound

## Usage
```bash
convert.sh [-s|--status] [-a|--audio] [-v|--video] files
convert.sh -h|--help
Arguments:
    -h|--help      display this help
    -s|--status    display each files encoding
    -a|--audio     Convert each files's audio to a proper encoding
    -v|--video     Convert each files's video to a proper encoding
    -b|--both      Convert each files's audio and video to a proper encoding
```

## ffmpeg usage
`ffmpeg -i file.mkv -c:v libx264 -c:a aac -map 0 -threads 8 file.mkv.mp4`
 - `-c:v libx264` convert the video encoding
 - `-c:a aac` convert the audio encoding
 - `-map 0` keep all stream like auther audio and subtitles
 - `-threads n` set thread count to `n`

## comkvmerge usage
`comkvmerge --identify file.{mkv|mp4}`
To findout both encodings

## TODO
 - [ ] Keep embeded subtitles
