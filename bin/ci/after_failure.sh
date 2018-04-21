#!/bin/sh
for f in spec/dummy/tmp/screenshots/*.png ; do
  ls -la "$f"
  curl -F "file=@${f}" https://file.io ;
done

