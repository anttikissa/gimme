log = require 'basic-log'
db = require './db'
_ = require 'underscore'

sum = (list) -> list.reduce ((a, b) -> a + b), 0

module.exports.start = ->
	repl = require 'repl'

	r = repl.start
		prompt: '> '
		eval: (cmd, c, f, cb) ->
			cmd = cmd.replace(/^\(/, '')
			cmd = cmd.replace(/\n\)$/, '')
			help = """
				q, quit:   quit
				u, users:  list users
				<enter>:   restart (terminate with code 100)
			"""

			users = (cb) ->
				db.queryRows 'select * from users', [], (err, rows) ->
					totalBalance = sum(_.pluck rows, 'balance')
					log totalBalance
					cb err,
						users: rows
						totalBalance: totalBalance

			resp = switch cmd
				when 'q', 'quit', 'exit' then process.exit(0)
				when 'u', 'users' then users
				when '' then process.exit(100)
				when 'h', 'help' then help
				else "Unknown command #{cmd}\n\n" + help

			if typeof resp == 'function'
				log "call fun"
				resp(cb)
			else
				cb(resp)
	r.on 'exit', -> process.exit(100)
