# BananaSplit86
Based upon [pathartl/banana-split](https://github.com/pathartl/banana-split) with a few modifications and as a native Windows application.

## About
The program is designed split a single TV episode file into multiple videos. This is a common issue with older TV cartoons such as:
 * Dexter's Laboratory
 * The Grim Adventures of Billy & Mandy
 * Invader Zim
 * Ed, Edd, & Eddy

For instance, one might have a 30 minute episode of:
```
"The Grim Adventures of Billy & Mandy - S01E01 - Meet the Reaper ~ Skeletons in the Water Closet"
```
However TheTVDB treats this as 2 separate episodes.
```
"The Grim Adventures of Billy & Mandy - S01E01 - Meet the Reaper"
"The Grim Adventures of Billy & Mandy - S01E02 - Skeletons in the Water Closet"
```

Similar to [pathartl/banana-split](https://github.com/pathartl/banana-split), this version performs the following using ffmpeg
 * Black Screen Detection
 * Tries to improve cut accuracy with Silence Detection (New)
 * Thumbnail Previews of Pre/Post Cuts
 * Job Logging to a Batch file, to run the conversions to h.264 Matroska (attempting to cut by frame/timecode without reencode appears to be inaccurate and causes some problems).
 
## Installation
###### Prerequisite: [ffmpeg.exe](https://ffmpeg.zeranoe.com/builds/) (I used 3.3.3 Static)
 * Run the Executable. (First run will error, asking for the path to FFmpeg to be added to the ini file (it will create this).)
 * Open a video file, preview & select cut points, and add to the Job List.
 * Cut Points will start appearing in a list. Preview each one by clicking on it. If you wish to use that cut, click the checkbox. Cut Points with an asterisk (*) have been adjusted to compensate for audio silence.
 
## Known/Possible ffmpeg issues 
 * I'm not confident in my use control of DOSCommand's Thread. You might have to spam "STOP" multiple times to make the program to stop it's current ffmpeg activity.
 * Silence detection helps for milisecond accuracy for the cut point, however there are cases where 1.5ms silence isn't found in the appropriate cut (I'm not an expert at FFmpeg's massive toolkit, I welcome feedback on a better setting). As a result the 2nd half of the cut may have a < 1 second audio churp at the start.
##### (per [pathartl](https://github.com/pathartl))
 * AVI doesn't play well with ffmpeg's video splitting, thus the video is automatically encoded to h.264 using libx264
 * Splitting AVI's may cause a weird starting time for audio/video. This is a limitation of AVI in general.
 * No errors are thrown for permission issues. Make sure you can write to the same folder as the source video.

## Compiled with (all free):
 * [Delphi 10.1 Berlin Starter](https://www.embarcadero.com/products/delphi/starter)
 * [TurboPack DosCommand](https://github.com/TurboPack/DOSCommand)
 * [JediVCL Snapshot 10.1 Berlin](http://cc.embarcadero.com/Author/54776)