if Meteor.isServer

	Meteor.publish 'coll', (no_mr, modul) ->
		if no_mr and modul
			selector =
				no_mr: parseInt no_mr
			options = {}
			options.fields = no_mr: 1, regis: 1
			options.fields[modul] = 1
			coll.find selector, options
		else
			coll.find {}, limit: 5
