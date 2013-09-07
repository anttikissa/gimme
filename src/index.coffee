express = require 'express'
log = require 'basic-log'
db = require './db'

user = require './user'
config = require './config'
parseArgs = require('./args').parseArgs

args = parseArgs()

log.setLevel 'info'

app = express()

app.set 'view engine', 'ejs'

# sessions
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session secret: config.sessionSecret
app.use express.static './static'

isLoggedIn = (req) ->
	req.session.user?

# auth middleware
checkAuth = (req, res, next) ->
	if !isLoggedIn(req)
		res.render 'index',
			messages: getMessages(req)
			loggedIn: false
	else
		next()
        
userDonatedCount = (user, url, cb) ->
	db.queryRow 'select * from donates where url = ? and user_id = ?',
		[ url, user ], (err, result) ->
			log "query donates err", err, result, "result"
			if !result
				cb null, 0
			else
				cb null, result.donates

donate = (user, url, cb) ->
	# TODO deduct balance
	sql = 'update donates set donates = donates + 1 where user_id = ? and url = ?'
	db.run sql, [ user, url ], (err, result) ->
		cb null, 'ok'

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
	url = req.headers['referer']
	url = 'http://google.fi/'
	log "url is #{url}"

	log "req.session.user", req.session.user

	if !isLoggedIn(req)
		res.render 'button',
			donateCount: 0
			loggedIn: false
			user: req.session.user
			url: url
	else
		userDonatedCount req.session.user.id, url, (err, count) ->
			if count > 0
				res.render 'button',
					donateCount: count
					loggedIn: true
					user: req.session.user
					url: url
			else
				res.render 'button',
					donateCount: count
					loggedIn: false
					user: req.session.user
					url: url
					
app.post '/button', (req, res) ->
	url = req.body.url;
	log "url is #{url}"

	log "req.session.user", req.session.user

	if !isLoggedIn(req)
		res.render 'index',
			loggedIn: false
			messages: getMessages(req)
	else
		donate req.session.user.id, url, (err, msg) ->
			if msg == 'ok'
				userDonatedCount req.session.user.id, url, (err, count) ->
					res.render 'button',
						donateCount: count
						loggedIn: true
						user: req.session.user
						url: url
			else
				res.render 'button',
						error: 'Could not donate'
						loggedIn: true
						messages: getMessages(req)
						url: url

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
		user.newUser body.user, body.password, (err, result) ->
			if result
				pushMessage(req, "Account #{body.user} created. You can now log in.")
				res.redirect '/'
			else
				pushMessage(req, "Username already exists.")
				res.render 'new',
					loggedIn: false,
					messages: getMessages(req)

app.post '/login', (req, res) ->
	body = req.body
	user.checkPassword body.user, body.password, (err, result) ->
		if result
			log "RESULT TRUE"
			req.session.user =
				id: body.user
			res.redirect '/'
		else
			pushMessage req, 'Invalid username or password.'
			log "RESULT UNTRUE"
			res.redirect '/'

app.get '/logout', (req, res) ->
	delete req.session.user
	res.redirect '/'

db.init()

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
		require('./console').start()

