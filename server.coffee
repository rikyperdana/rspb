if Meteor.isServer

	Meteor.publish 'coll', (selector, options) ->
		coll.find selector, options

	Meteor.methods
		'import': (selector, modifier) ->
			coll.upsert selector, $set: modifier
