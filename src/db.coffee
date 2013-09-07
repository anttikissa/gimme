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

	# Create tables and inject some test data.
	# Will spew errors if they're already there - ignore them
	init: ->
		this.ignoreErrors """
			create table users (
				id varchar(64) primary key,
				pass varchar(64),
				balance integer
			)"""
		this.ignoreErrors "insert into users values ('test1', 'pass1', 5)"
		this.ignoreErrors "insert into users values ('test2', 'test2', 10)"
		this.ignoreErrors """
			create table donates (
				url varchar(256) primary key,
				user_id varchar(64),
				donates integer,
				foreign key(user_id) references user(id)
			)"""
		this.ignoreErrors """
			insert into donates values (
				'http://google.fi/',
				'test',
				0
			)"""


