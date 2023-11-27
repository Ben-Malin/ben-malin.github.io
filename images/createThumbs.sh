#!/bin/bash

# for every file in ./showcase, create a thumbnail in ./showcaseThumbnails
# If the file is an mp4, use the second frame

for f in ./showcase/*; do
    if [[ $f == *.mp4 ]]; then
        ffmpeg -i $f -vf "select=eq(n\,1)" -vframes 1 -q:v 2 ./showcaseThumbnails/$(basename $f .mp4).jpg
        # make it 200x200
        convert ./showcaseThumbnails/$(basename $f .mp4).jpg -resize 200x200 ./showcaseThumbnails/$(basename $f .mp4).jpg
    else
        convert $f -resize 200x200 ./showcaseThumbnails/$(basename $f)
    fi
done
