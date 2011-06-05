# coffee-world
Watches the current folder to compile CoffeeScript into CSS, HTML & JS

# Install
    sudo npm install coffee-world

# Usage
    coffee-world                # watches current folder
    coffee-world <path>         # watches <path>
    coffee-world --all          # compiles all files on startup
    coffee-world <path> --all

* `*.css.coffee` will be compiled with coffee-css into `*.css`.
* `*.html.coffee` will be compiled with coffeekup into `*.html`.
* All other `*.coffee` files will be compiled into `*.js`.

Enjoy!

# Thanks
* http://jashkenas.github.com/coffee-script/
* https://github.com/mauricemach/coffeekup