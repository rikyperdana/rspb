if Meteor.isClient

	AutoForm.setDefaultTemplate 'materialize'
	currentRoute = -> Router.current().route.getName()

	Template.modul.onRendered ->
		if currentRoute() is 'regis' or Router.current().params.no_mr
			$('#addPasien').removeClass 'hide'

	Template.modul.helpers
		coll: -> coll
		schema: -> new SimpleSchema schema[currentRoute()]
		route: -> currentRoute()
		pasiens: -> coll.find().fetch()
		pasienData: -> coll.findOne no_mr: parseInt Router.current().params.no_mr
		addPasien: -> Session.get 'addPasien'
		formType: -> if currentRoute() is 'regis' then 'insert' else 'update-pushArray'

	Template.modul.events
		'click #addPasien': -> Session.set 'addPasien', not Session.get 'addPasien'
		'dblclick #row': -> Router.go '/' + currentRoute() + '/' + this.no_mr

	AutoForm.addHooks null,
		after:
			insert: (err, res) ->
				if res then console.log res
			'update-pushArray': (err, res) -> if res
				###
				console.log [
					currentRoute()
					this.currentDoc.no_mr
					this.insertDoc
				]
				###
				doc = this.insertDoc
				if currentRoute() is 'jalan'
					selector = coll.findOne()._id
					data = $push: bayar:
						cara_bayar: doc.cara_bayar
						status_bayar: doc.status_bayar
						tindakan: doc.tindakan
						id: doc.id
						petugas: doc.petugas
						data: doc.date
					coll.update selector, data
