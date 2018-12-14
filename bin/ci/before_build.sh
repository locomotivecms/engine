#!/bin/sh
wget http://chromedriver.storage.googleapis.com/2.35/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
rm chromedriver_linux64.zip
# sudo apt-get install libnss3
# sudo apt-get --only-upgrade install google-chrome-stable
sudo cp chromedriver /usr/local/bin/.
sudo chmod +x /usr/local/bin/chromedriver
whereis chromedriver
chromedriver --version

whereis google-chrome-stable
google-chrome-stable --version
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
whereis google-chrome-stable
google-chrome-stable --version

google-chrome-stable --headless --no-sandbox
export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start
export TZ=America/Chicago
sleep 3
date
