coffeeWorld = require '../lib/coffee-world'
fs = require 'fs'
should = require 'should'

exports.testCompileCoffee = ->
    coffeeFile = __dirname + '/testCoffee.coffee'
    jsFile = __dirname + '/testCoffee.js'
    fs.writeFile coffeeFile, "console.log 'Hello World!'", (err) ->
        coffeeWorld.compile coffeeFile, ->
            fs.readFile jsFile, (err, data) ->
                data.toString().should.be.equal """
                    (function() {
                      console.log('Hello World!');
                    }).call(this);
                    
                    """
                fs.unlink coffeeFile
                fs.unlink jsFile

exports.testCompileCoffeeCss = ->
    coffeeCssFile = __dirname + '/test.css.coffee'
    cssFile = __dirname + '/test.css'
    data = """
        exports.css =
            'a':
                textDecoration: 'none'
            'a:hover':
                textDecoration: 'underline'
        """

    fs.writeFile coffeeCssFile, data, (err) ->
        coffeeWorld.compile coffeeCssFile, ->
            fs.readFile cssFile, (err, data) ->
                data.toString().should.equal """
                    a {
                        text-decoration: none;
                    }
                    a:hover {
                        text-decoration: underline;
                    }
                    """
                fs.unlink coffeeCssFile
                fs.unlink cssFile

exports.testCompileCoffeekup = ->
    coffeekupFile = __dirname + '/test.html.coffee'
    htmlFile = __dirname + '/test.html'
    data = """
        html ->
            head ->
                meta charset: 'utf-8'
                title "My awesome website"
            body ->
                h1 'Heading 1'
                ul ->
                    li -> a href: '/', -> 'Home'
                    li -> a href: '/about-us', -> 'About Us'
                p 'Bye!'
        """

    fs.writeFile coffeekupFile, data, (err) ->
        coffeeWorld.compile coffeekupFile, ->
            fs.readFile htmlFile, (err, data) ->
                data.toString().should.equal """
                    <html>
                      <head>
                        <meta charset="utf-8" />
                        <title>My awesome website</title>
                      </head>
                      <body>
                        <h1>Heading 1</h1>
                        <ul>
                          <li>
                            <a href="/">
                              Home
                            </a>
                          </li>
                          <li>
                            <a href="/about-us">
                              About Us
                            </a>
                          </li>
                        </ul>
                        <p>Bye!</p>
                      </body>
                    </html>
                    
                    """
                fs.unlink coffeekupFile
                fs.unlink htmlFile