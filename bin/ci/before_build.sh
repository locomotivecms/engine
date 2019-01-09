#!/bin/sh

# wget http://chromedriver.storage.googleapis.com/2.35/chromedriver_linux64.zip
# unzip chromedriver_linux64.zip
# rm chromedriver_linux64.zip

# sudo apt-get install libnss3
# sudo apt-get --only-upgrade install google-chrome-stable
# sudo cp chromedriver /usr/local/bin/.
# sudo chmod +x /usr/local/bin/chromedriver
# google-chrome-stable --headless --no-sandbox

# curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
# echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
# sudo apt-get update && sudo apt-get install yarn


sleep 3
export DISPLAY=:99.0
# sh -e /etc/init.d/xvfb start
/sbin/start-stop-daemon --start --quiet --pidfile /tmp/custom_xvfb_99.pid --make-pidfile --background --exec /usr/bin/Xvfb -- :99 -ac -screen 0 1600x768x24
export TZ=America/Chicago
sleep 3
date

# whereis google-chrome-stable
# whereis chromedriver
