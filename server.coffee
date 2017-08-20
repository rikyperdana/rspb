if Meteor.isServer

	Meteor.publish 'coll', -> coll.find {}
