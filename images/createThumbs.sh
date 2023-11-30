#!/bin/bash

# for every file in ./showcase, create a thumbnail in ./showcaseThumbnails
# If the file is an mp4, use the second frame

# prompt user to overwrite thumbnails if they exist

for f in ./showcase/*; do

    # check if thumbnail already exists and prompt to overwrite
    # This prevents clogging the git history
    
    # strip the extension from the filename
    fext=${f##*/}
    fname=${fext%.*}

    if [[ -f ./showcaseThumbnails/$fname.png ]]; then
        read -p "Overwrite ./showcaseThumbnails/$(basename $f)? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm ./showcaseThumbnails/$(basename $f)
        else
            continue
        fi
    fi

    if [[ $f == *.mp4 ]]; then
        # use a frame near the end of the video
        frameIndex=$(ffprobe -v error -select_streams v:0 -show_entries stream=nb_frames -of default=noprint_wrappers=1:nokey=1 $f | awk '{print int($0 - 2)}')
        ffmpeg -i $f -vf "select=eq(n\,$frameIndex)" -vframes 1 -q:v 2 ./showcaseThumbnails/$(basename $f .mp4).png
        convert ./showcaseThumbnails/$(basename $f .mp4).png -resize 400x400 ./showcaseThumbnails/$(basename $f .mp4).png
    else
        convert $f -resize 400x400 ./showcaseThumbnails/$(basename $f)
        # if not a png, convert
        if [[ $f != *.png ]]; then
            convert ./showcaseThumbnails/$(basename $f) ./showcaseThumbnails/$(basename $f .jpg).png
            rm ./showcaseThumbnails/$(basename $f)
        fi
    fi
done
