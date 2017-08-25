if Meteor.isClient

	AutoForm.setDefaultTemplate 'materialize'
	currentRoute = -> Router.current().route

	Template.modul.helpers
		coll: -> coll
		schema: -> new SimpleSchema schema[currentRoute().getName()]
		route: -> currentRoute().getName()
		pasiens: -> coll.find().fetch()
		pasienData: -> coll.findOne no_mr: parseInt Router.current().params.no_mr
		addPasien: -> Session.get 'addPasien'

	Template.modul.events
		'click #addPasien': -> Session.set 'addPasien', not Session.get 'addPasien'
		'dblclick #row': -> Router.go currentRoute().path() + '/' + this.no_mr
