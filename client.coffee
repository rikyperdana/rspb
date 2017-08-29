if Meteor.isClient

	AutoForm.setDefaultTemplate 'materialize'
	currentRoute = -> Router.current().route.getName()

	Template.menu.helpers
		menus: -> modules

	Template.modul.helpers
		coll: -> coll
		schema: -> new SimpleSchema schema[currentRoute()]
		route: -> currentRoute()
		pasiens: -> coll.find().fetch()
		pasienData: -> coll.findOne no_mr: parseInt Router.current().params.no_mr
		addPasien: -> Session.get 'addPasien'
		formType: -> if currentRoute() is 'regis' then 'insert' else 'update-pushArray'
		hari: (date) -> moment(date).format('D MMM YYYY')
		umur: (date) -> moment().diff(date, 'years') + ' tahun'
		showButton: -> Router.current().params.no_mr or currentRoute() is 'regis'

	Template.modul.events
		'click #addPasien': -> Session.set 'addPasien', not Session.get 'addPasien'
		'dblclick #row': -> Router.go '/' + currentRoute() + '/' + this.no_mr
		'click #close': -> Router.go currentRoute()
		'click #card': ->
			pdf = pdfMake.createPdf
				content: [
					'Nama: ' + coll.findOne().regis.nama_lengkap
					'No. MR: ' + coll.findOne().no_mr
				]
				pageSize: 'B8'
				pageMargins: [110, 50, 0, 0]
				pageOrientation: 'landscape'
			pdf.open()

	AutoForm.addHooks null,
		after:
			insert: (err, res) ->
				if res then console.log res
			'update-pushArray': (err, res) -> if res
				# console.log currentRoute(), this.currentDoc.no_mr, this.insertDoc
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
