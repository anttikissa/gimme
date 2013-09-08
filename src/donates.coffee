log = require 'basic-log'

db = require './db'

module.exports =
	# How many donates has this url received?
	getDonates: (url, cb) ->
		log "donates, url", url
		db.queryRow 'select sum(donates) as sum from donates where url = ?',
			[url], (err, result) ->
				cb null, result.sum || 0

	# How many donates has this user donated to this url?
	getDonateCount: (userId, url, cb) ->
		db.queryRow 'select * from donates where url = ? and user_id = ?',
			[ url, userId ], (err, result) ->
				#	log "query donates err", err, result, "result"
				if !result
					cb null, 0
				else
					cb null, result.donates

	# This userId donates one unit to this url.
	donate: (userId, url, cb) ->
		that = this

		sqlTake = 'update users set balance = balance - 1 where id = ?'

		db.run sqlTake, [ userId ], (err, result) ->
			if err
				cb null, 'insufficient balance'
			else
				that.getDonateCount userId, url, (err, alreadyDonated) ->
					log "getDonateCount(#{userId}, #{url}): #{alreadyDonated}"
					if alreadyDonated > 0

						sqlGive = 'update donates set donates = donates + 1 where user_id = ? and url = ?'
						db.run sqlGive, [ userId, url ], (err, result) ->
							cb null, 'ok'
					else
						sqlGive = 'insert into donates (url, user_id, donates) values (?, ?, ?)'
						db.run sqlGive, [ url, userId, 1 ], (err, result) ->
							if err
								cb err, 'error: ' + err
							else
								cb null, 'ok'

	# TODO other accessors
	# similar sites, etc.
	
