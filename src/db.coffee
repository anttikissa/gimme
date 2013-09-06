sqlite = require('sqlite3').verbose()
db = new sqlite.Database('gimme.db')
log = require 'basic-log'

db.serialize()

module.exports =
	ignoreErrors: (sql, args, cb) ->
		if args?
			log "db.ignoreErrors:", sql, args
		else
			log "db.ignoreErrors:", sql
		db.run sql, args, (err, result) ->
			if err
				log "db.ignoreErrors: ignoring harmless error " + err

			if cb
				cb null, result

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


