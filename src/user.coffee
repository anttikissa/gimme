db = require './db'

module.exports =
	# List all users
	list: (cb) ->
		cb null, [{ id: 'foo', balance: 123 }]

	# User details
	getData: (id, cb) ->
		cb null, { id: id, balance: 15 }

	# List of all donates
	getDonates: (id, cb) ->
		{ id: id, donates: [
			{ url: 'http://google.fi/', donates: 1 },
			{ url: 'http://yahoo.com/', donates: 2 },
			{ url: 'http://microsoft.com/', donates: 3 }
		] }

	# Is user-password combination ok?
	checkPassword: (id, pass, cb) ->
		cb null, true

	# Create new user, return false if already exists
	newUser: (id, pass, cb) ->
		cb null, true

