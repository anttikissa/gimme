express = require 'express'

user = require './user'

app = express()

app.get '/', (req, res) ->
	res.end 'Maximum awesome'

port = 3000

process.on 'uncaughtException', (err) ->
	if err.code == 'EADDRINUSE'
		console.log "Port #{3000} already in use."
	throw err

# Catch CTRL-C
process.on 'SIGINT', ->
	console.log 'quit'
	process.exit()

app.listen port, (err, result) ->
	console.log "Listening to http://localhost:#{port}/"

