if Meteor.isServer

	Meteor.publish 'coll', (selector, options) ->
		coll.find selector, options

	Meteor.methods
		'import': (selector, modifier) ->
			coll.upsert selector, $set: modifier
		'bayar': (modul, no_mr, idbayar) ->
			selector = no_mr: parseInt no_mr
			selector[modul + '.idbayar'] = idbayar
			modifier = {}
			modifier[modul + '.$.status_bayar'] = 1
			coll.update selector, $set: modifier
