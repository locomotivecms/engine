Following are instruction on how to set up a development enviroment on an Ubunutu Operating System using Oracle Virtual Box:

## VM Setup

* Download [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads) on your host machine

* Download the [Ubuntu ISO file](https://www.ubuntu.com/download/desktop)

* Start Oracle Virtual Box. Make a 64 bit Ubuntu VM and then when it starts up give it the iso file.

## Project setup

* Use search and find the Terminal. Get ready :/

* Install Ruby on Rails: https://gorails.com/setup/ubuntu/16.04
(I found PostgreSQL to be easier than mySQL when you get to that step)

* Install [mongodb](https://www.digitalocean.com/community/tutorials/how-to-install-mongodb-on-ubuntu-16-04)

* Install [PhantomJS](https://gist.github.com/julionc/7476620)

________

## To initalize...

start mongodb (Do this every time you start the enviorment back up!):

`~$ sudo service mongod start`

clone the repo:

`~$ git clone https://github.com/GP4-Team3/engine.git`

`
_Note_ using `git clone git@github.com:GP4-Team3/engine.git` will sometimes deny you permission from cloning the repo due to public key issues. Using `git clone https://github.com/GP4-Team3/engine.git` is more reliable.
OR
if you forked it and want to make changes on your own git, replace GP4-Team3 with your username (If you are an outside organization, put your organizations name there, wherever your repo is.)
`

Move into the directory containing the repo:

`~$ cd engine/`

Install the dependencies:

`~$ bundle install`

(Should run perfectly, unless you are an outside group who has forked it from the locomotive repo. If it stops at capybara-webkit then comment out the line containing the capybara-webkit in the Gemfile. Do so with..

`~$ sudo vi Gemfile`

)

(If you are unfamiliar with unix text editors, you may edit the Gemfile within your repo on github, but you will have to follow the steps below for re-cloning, seen after the line, then re-run the bundle install command)

Start the application!:

`~$ bundle exec rails server`

Then go to http://localhost:3000/locomotive To see the application running! :) Note the webpage takes a few minutes to load when you first run the server.

________

Pull your teammates changes:

`~$ git pull origin master`

Restart the server

`~$ bundle exec rails server`

Then go to http://localhost:3000/locomotive To see the you changes! :) Once again note the webpage takes a few minutes to load when you first run the server.


________

If you have any problems, contact Brandon Pruett!

Pro tip: A good place to start looking for files to change are:

`engine/app/assets/images/locomotive/`  (Delete and reupload images but keep the names the same!)

and

`engine/app/assets/stylesheets/locomotive/new/`
