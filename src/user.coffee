module.exports.f = ->
	console.log 'this is user.f'
	for i in [1..100]
		console.log i
	throw Error('This should be on line 5.')
