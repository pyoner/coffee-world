# coffee-world
Watches the current folder to compile CoffeeScript into CSS, HTML & JS (+ uglify)

# Install
    sudo npm install coffee-world

# Usage
    coffee-world
    coffee-world all   # to compile all files on startup

* `*.css.coffee` will be compiled with coffee-css into `*.css`.
* `*.html.coffee` will be compiled with coffeekup into `*.html`.
* All other `*.coffee` files will be compiled into `*.js` with CoffeeScript.
* `*.js` will be uglified into `*.min.js`.

Enjoy!

# Thanks
* http://jashkenas.github.com/coffee-script/
* https://github.com/mauricemach/coffeekup
* https://github.com/mishoo/UglifyJS