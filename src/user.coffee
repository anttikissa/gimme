module.exports.f = ->
	console.log 'this is user.f'
	throw Error('This should be on line 3.')
