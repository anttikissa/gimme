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



