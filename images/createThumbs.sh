#!/bin/bash

# for every file in ./showcase, create a thumbnail in ./showcaseThumbnails
# If the file is an mp4, use the second frame

for f in ./showcase/*; do
    if [[ $f == *.mp4 ]]; then
        ffmpeg -i $f -vf "select=eq(n\,1)" -vframes 1 -q:v 2 ./showcaseThumbnails/$(basename $f .mp4).png
        convert ./showcaseThumbnails/$(basename $f .mp4).png -resize 200x200 ./showcaseThumbnails/$(basename $f .mp4).png
    else
        convert $f -resize 200x200 ./showcaseThumbnails/$(basename $f)
        # if not a png, convert
        if [[ $f != *.png ]]; then
            convert ./showcaseThumbnails/$(basename $f) ./showcaseThumbnails/$(basename $f .jpg).png
            rm ./showcaseThumbnails/$(basename $f)
        fi
    fi
done
