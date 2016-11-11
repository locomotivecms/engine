Following are instruction on how to set up a development enviroment on an Ubunutu Operating System using Orcal Virtual Box:

Download Orcal VirtualBox on your actual machine: https://www.virtualbox.org/wiki/Downloads

Download the Ubuntu ISO file: https://www.ubuntu.com/download/desktop

Start Orcal Vitual Box. Make a 64 bit Ubuntu VM and then when it starts up give it the iso file.

Use search and find the Terminal. Get ready :/

Install Ruby on Rails: https://gorails.com/setup/ubuntu/16.04 
(I found PostgreSQL to be easier the mySQL when you get to that step)

Install mongodb: https://www.digitalocean.com/community/tutorials/how-to-install-mongodb-on-ubuntu-16-04

Intall PhantomJS: https://gist.github.com/julionc/7476620

________

To initalize...

start mongodb (Do this every time you start the enviorment back up!):

:~$ sudo service mongod start 

clone the repo:

:~$ git clone https://github.com/GP4-Team3/engine.git

*Note* using [git clone git@github.com:GP4-Team3/engine.git] will sometimes deny you permission from cloning the repo due to public key issues. Using [git clone https://github.com/GP4-Team3/engine.git] is more reliable.

(OR if you forked it and want to make changes on your own git, replace GP4-Team3 with your username)

Move into the directory containing the repo:

:~$ cd engine/

Install the dependencies:

:~$ bundle install 

(Should run perfectly, if it stops at capybara-webkit then comment out the line:~$ Sudo vi Gemfile)

Start the application!:

:~$ bundle exec rails server

Then go to http://localhost:3000/locomotive To see the application running! :)

________

For each commit that you want to see the change, remove the current repo's directory:

:~$ cd

:~$ rm -rf /engine

then

reclone the repo:

:~$ git clone https://github.com/GP4-Team3/engine.git

Move into the directory containing the repo:

:~$ cd engine/

:~$ bundle exec rails server

Then go to http://localhost:3000/locomotive To see the you changes! :)

________

If you have any problems, contact Brandon Pruett!


