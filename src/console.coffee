log = require 'basic-log'
db = require './db'
_ = require 'underscore'
user = require './user'

sum = (list) -> list.reduce ((a, b) -> a + b), 0

# Commands
users = (cb) ->
	user.list (err, rows) ->
		totalBalance = sum(_.pluck rows, 'balance')
		cb err,
			users: rows
			totalBalance: totalBalance

deposit = (args, cb) ->
	[id, amount] = args
	if !id?
		cb 'usage: deposit <userId> <amount>'
	else if !amount?
		cb 'amount missing'
	else
		user.deposit id, Number(amount), (err, result) ->
			cb null, 'ok'

module.exports.start = ->
	repl = require 'repl'

	r = repl.start
		prompt: '> '
		eval: (cmd, c, f, cb) ->
			cmd = cmd.replace(/^\(/, '')
			cmd = cmd.replace(/\n\)$/, '')
			help = """
				q, quit:    quit
				u, users:   list users
				d, deposit <userId> <amount>
				            give user <userId> <amount> donation units
				<enter>:    restart (terminate with code 100)
			"""

			[cmd, args...] = cmd.split ' '
			resp = switch cmd
				when 'q', 'quit', 'exit' then process.exit(0)
				when 'u', 'users' then users
				when 'd', 'deposit' then (cb) -> deposit(args, cb)
				when '' then process.exit(100)
				when 'h', 'help' then help
				else "Unknown command #{cmd}\n\n" + help

			if typeof resp == 'function'
				resp(cb)
			else
				cb(resp)
	r.on 'exit', -> process.exit(100)
