db = require './db'
log = require 'basic-log'

module.exports =
	# List all users
	list: (cb) ->
		db.queryRows 'select id, balance from users', [], (err, rows) ->
			cb null, rows

	# Return user details, undefined if user doesn't exist
	getUser: (id, cb) ->
		db.queryRow "select id, balance from users where id=?",
			[id],
			(err, result) ->
				cb null, result

	# List of all donates
	getDonates: (id, cb) ->
		{ id: id, donates: [
			{ url: 'http://google.fi/', donates: 1 },
			{ url: 'http://yahoo.com/', donates: 2 },
			{ url: 'http://microsoft.com/', donates: 3 }
		] }

	# Is user-password combination ok?
	checkPassword: (id, pass, cb) ->
		db.queryRow "select pass from users where id=?", [id], (err, result) ->
			if !result
				cb null, false
			else if result.pass != pass
				cb null, false
			else
				cb null, true

	# Change password.
	# Return true if change was successful. 
	changePassword: (id, oldPass, newPass, cb) ->
		throw "TODO"

	# Create new user, return false if already exists
	newUser: (id, pass, cb) ->
		this.getUser id, (err, existingUser) ->
			if existingUser?
				cb null, false
			else
				db.run 'insert into users (id, pass, balance) values (?, ?, 0)',
					[id, pass],
					# This will never fail (of course!)
					(err, result) ->
						cb null, true

	deposit: (id, amount, cb) ->
		db.run 'update users set balance = balance + ? where id = ?', [amount, id],
			(err, result) ->
				cb null, result

