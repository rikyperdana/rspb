if Meteor.isClient

	AutoForm.setDefaultTemplate 'materialize'
	currentRoute = -> Router.current().route.getName()

	Template.modul.helpers
		coll: -> coll
		schema: -> new SimpleSchema schema[currentRoute()]
		route: -> currentRoute()
		datas: -> coll.find().fetch()
		updateData: -> Session.get 'updateData'
		newPasien: -> Session.get 'newPasien'
		pasienData: -> Session.get 'pasienData'
		moduleList: -> Session.get('pasienData')[currentRoute()]
		moduleTable: ->
			columns = []
			for key, val of Session.get('pasienData')[currentRoute()][1]
				columns.push key
			rows = []
			for i in Session.get('pasienData')[currentRoute()]
				list = []
				for key, val of i
					list.push val
				rows.push list
			columns: columns, rows: rows

	Template.modul.events
		'click #newPasien': -> Session.set 'newPasien', not Session.get 'newPasien'
		'dblclick #row': -> Session.set 'pasienData', this
		'click #close': -> Session.set 'pasienData', null
