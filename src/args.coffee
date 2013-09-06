process.argv.shift()
process.argv.shift()

module.exports.parseArgs = ->
	args =
		console: false
		help: false

	for arg in process.argv
		switch arg
			when '-h' then args.help = true
			when '-c', '--console' then args.console = true
			else console.log "Illegal option #{arg}\n"; args.help = true

	if args.help
		console.log "Options:"
		console.log ""
		console.log "-c, --console: enable dev console"
		console.log "-h, --help:    help"
		console.log ""
		process.exit(0)

	args
