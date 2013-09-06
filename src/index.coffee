express = require 'express'
log = require 'basic-log'

user = require './user'
config = require './config'
parseArgs = require('./args').parseArgs

args = parseArgs()

app = express()

app.set 'view engine', 'ejs'

# sessions
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session secret: config.sessionSecret
app.use express.static './static'

# auth middleware
checkAuth = (req, res, next) ->
	if !req.session.user?
		res.render 'index',
			messages: getMessages(req)
			loggedIn: false
	else
		next()

pushMessage = (req, msg) ->
	req.session.messages ||= []
	req.session.messages.push msg

getMessages = (req) ->
	result = req.session.messages || []
	req.session.messages = []
	result


app.get '/', checkAuth, (req, res) ->
	res.render 'index',
		loggedIn: true
		messages: getMessages(req)
		user: req.session.user

app.get '/button', (req, res) ->
	res.render 'button',
		loggedIn: true
		messages: getMessages(req)
		user: req.session.user

app.get '/new', (req, res) ->
	res.render 'new',
		loggedIn: false
		messages: getMessages(req)

app.post '/new', (req, res) ->
	body = req.body
	fail = false
	whoops = (msg) ->
		fail = true

	fail = false
	if !body.user?
		pushMessage req, "Username missing"
		fail = true
	if !body.password?
		pushMessage req, "Password missing"
		fail = true
	
	if fail
		res.render 'new',
			loggedIn: false,
			messages: getMessages(req)
	else
		pushMessage(req, "Account #{body.user} created. You can now log in.")
		res.redirect '/'

app.post '/login', (req, res) ->
	body = req.body
	if body.user == 'test' && body.password = 'pass'
		req.session.user =
			id: 'test'
		res.redirect '/'
	else
		pushMessage req, 'Invalid username or password.'
		res.redirect '/'

app.get '/logout', (req, res) ->
	delete req.session.user
	res.redirect '/'

port = 3000

process.on 'uncaughtException', (err) ->
	if err.code == 'EADDRINUSE'
		log "Port #{3000} already in use."
		process.exit(1)

	throw err

# Catch CTRL-C
process.on 'SIGINT', ->
	log 'quit'
	process.exit()

app.listen port, (err, result) ->
	log "Listening to http://localhost:#{port}/"

	if args.console
		repl = require 'repl'

		r = repl.start
			prompt: '> '
			eval: (cmd, c, f, cb) ->
				cmd = cmd.replace(/^\(/, '')
				cmd = cmd.replace(/\n\)$/, '')
				help = """
					q, quit:   quit
					<enter>:   restart (terminate with code 100)
				"""

				resp = switch cmd
					when 'q', 'quit', 'exit' then process.exit(0)
					when '' then process.exit(100)
					when 'h', 'help' then help
					else "Unknown command #{cmd}\n\n" + help

				cb(resp)
		r.on 'exit', -> process.exit(100)



