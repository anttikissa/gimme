express = require 'express'

app = express()

app.get '/', (req, res) ->
	res.end 'Maximum awesome'

port = 3000
app.listen(port)
console.log "Listening to http://localhost:#{port}/"
