Annemo
======

A simplistic web app for annotating emotions in human speech video recordings.

![annemo screenshot](https://github.com/ilyabo/annemo/raw/master/doc/screenshot.png)


Installation
======
Install [Node.js 0.6.x](http://nodejs.org/dist/v0.6.16/docs/#)

Then, install CoffeeScript:

    npm install -g coffee-script


To download the project dependencies in the project directory run: 

    npm install


Then, configure the videos and the allowed user ids in [config.coffee](https://github.com/ilyabo/annemo/blob/master/config.coffee)


To start the server run:

    cake forever-start

and open http://localhost:3001 in your browser.


To restart the server:

    cake forever-restart

To stop:

    cake forever-stop
 
