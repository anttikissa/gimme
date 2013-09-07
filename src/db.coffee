sqlite = require('sqlite3').verbose()
db = new sqlite.Database('gimme.db')
log = require 'basic-log'

db.serialize()

module.exports =
	ignoreErrors: (sql, args, cb) ->
		if args?
			log.d "db.ignoreErrors:", sql, args
		else
			log.d "db.ignoreErrors:", sql
		db.run sql, args, (err, result) ->
			if err
				log.d "db.ignoreErrors: ignoring harmless error " + err

			if cb
				cb null, result

	run: (sql, args, cb) ->
		if args?
			log.d "db.run:", sql, args
		else
			log.d "db.run:", sql
		db.run sql, args, cb
		
	queryRow: (sql, args, cb) ->
		if args?
			log.d "db.queryRow:", sql, args
		else
			log.d "db.queryRow:", sql
		db.get sql, args, cb

	queryRows: (sql, args, cb) ->
		if args?
			log.d "db.queryRows:", sql, args
		else
			log.d "db.queryRows:", sql
		db.all sql, args, cb

	# Create tables and inject some test data.
	# Will spew errors if they're already there - ignore them
	init: ->
		this.ignoreErrors """
			create table users (
				id varchar(64) primary key not null,
				pass varchar(64),
				balance integer
			)"""
		this.ignoreErrors "insert into users values ('test1', 'pass1', 5)"
		this.ignoreErrors "insert into users values ('test2', 'test2', 10)"
		this.ignoreErrors """
			create table donates (
				url varchar(256) not null,
				user_id varchar(64),
				donates integer,
				primary key(url, user_id),
				foreign key(user_id) references user(id)
			)"""
		this.ignoreErrors "insert into donates values ('http://google.fi/', 'test1', 5)"
		this.ignoreErrors "insert into donates values ('http://google.fi/', 'test2', 4)"
		this.ignoreErrors "insert into donates values ('http://cats.sykari.net/', 'test1', 6)"


