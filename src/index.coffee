express = require 'express'

user = require './user'

app = express()

app.get '/', (req, res) ->
	res.end 'Maximum awesome'

port = 3000

process.on 'uncaughtException', (err) ->
	if err.code == 'EADDRINUSE'
		console.log "Port #{3000} already in use."
	else
		console.log "Error: #{err}"

app.listen port, (err, result) ->
	console.log "Listening to http://localhost:#{port}/"

# test stack trace
user.f()
