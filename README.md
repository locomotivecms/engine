Successful enviroment on Ubunutu using Orcal Virtual Box:

Download Orcal VirtualBox on your actual machine: https://www.virtualbox.org/wiki/Downloads

Download the Ubuntu ISO file: https://www.ubuntu.com/download/desktop

Start Orcal Vitual Box. Make a 64 bit Ubuntu VM and then when it starts up give it the iso file.

Find the Terminal. Get ready :/


Install mongodb: 
Intall PhantomJS: https://gist.github.com/julionc/7476620
________

for each commit rm -rf /engine

then

start mongodb:
:~$ sudo service mongod start 

reclone the repo:
:~$ git clone git@github.com:GP4-Team3/engine.git

:~$ cd engine/

:~$ bundle install 
#Should run perfectly, if it stops at capybara-webkit then comment out the line:~$ Sudo vi Gemfile

:~$ bundle exec rails server

Then go to http://localhost:3000/locomotive To see the application running! :)





