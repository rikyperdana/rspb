if Meteor.isServer

	Meteor.publish 'coll', (selector, options) ->
		coll.find selector, options
