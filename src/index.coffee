express = require 'express'

user = require './user'
config = require './config'

app = express()

app.set 'view engine', 'ejs'

# sessions
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session secret: config.sessionSecret

# auth middleware
checkAuth = (req, res, next) ->
	if !req.session.userId
		res.render 'index'
	else
		next()

app.get '/', checkAuth, (req, res) ->
	res.end 'Maximum awesome'

app.post '/login', (req, res) ->
	body = req.body
	if body.user == 'test' && body.password = 'pass'
		req.session.userId = 'test'
		res.redirect '/'
	else
		res.end 'Invalid username/password'

app.get '/logout', (req, res) ->
	delete req.session.userId
	res.redirect '/'

port = 3000

process.on 'uncaughtException', (err) ->
	if err.code == 'EADDRINUSE'
		console.log "Port #{3000} already in use."
		process.exit(1)

	throw err

# Catch CTRL-C
process.on 'SIGINT', ->
	console.log 'quit'
	process.exit()

app.listen port, (err, result) ->
	console.log "Listening to http://localhost:#{port}/"
