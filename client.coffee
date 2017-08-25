if Meteor.isClient

	AutoForm.setDefaultTemplate 'materialize'
	currentRoute = -> Router.current().route.path()

	Template.modul.helpers
		coll: -> coll
		schema: -> new SimpleSchema schema[currentRoute()]
		route: -> currentRoute()
		pasiens: -> coll.find().fetch()
		pasienData: -> coll.findOne no_mr: parseInt Router.current().params.no_mr

	Template.modul.events
		'click #newPasien': -> Session.set 'newPasien', not Session.get 'newPasien'
		'click #close': -> Session.set 'pasienData', null
		'dblclick #row': -> Router.go currentRoute() + '/' + this.no_mr
