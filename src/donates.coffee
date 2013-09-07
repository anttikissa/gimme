log = require 'basic-log'

db = require './db'

module.exports =
	getDonates: (url, cb) ->
		log "donates, url", url
		db.queryRow 'select sum(donates) as sum from donates where url = ?',
			[url], (err, result) ->
				cb null, result.sum || 0

	# TODO other accessors
	# similar sites, etc.
	
