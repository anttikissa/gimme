sqlite = require('sqlite3').verbose()
db = new sqlite.Database(':memory:')
log = require 'basic-log'

db.serialize()

module.exports =
	run: (sql, args, cb) ->
		if args?
			log "db.run:", sql, args
		else
			log "db.run:", sql
		db.run sql, args, cb
		
	queryRow: (sql, args, cb) ->
		if args?
			log "db.queryRow:", sql, args
		else
			log "db.queryRow:", sql
		db.get sql, args, cb

	queryRows: (sql, args, cb) ->
		if args?
			log "db.queryRows:", sql, args
		else
			log "db.queryRows:", sql
		db.all sql, args, cb


