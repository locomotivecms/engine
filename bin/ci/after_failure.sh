#!/bin/sh
for f in spec/dummy/tmp/screenshots/*.png ; do
  curl -F "file=@${f}" https://file.io ;
done

