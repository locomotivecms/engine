#!/bin/sh
wget http://chromedriver.storage.googleapis.com/2.9/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
rm chromedriver_linux64.zip
# sudo apt-get install libnss3
# sudo apt-get --only-upgrade install google-chrome-stable
sudo cp chromedriver /usr/local/bin/.
sudo chmod +x /usr/local/bin/chromedriver
export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start
export TZ=America/Chicago
sleep 3
date
whereis google-chrome-stable
whereis chromedriver
google-chrome-stable --headless --no-sandbox
