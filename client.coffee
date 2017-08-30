if Meteor.isClient

	AutoForm.setDefaultTemplate 'materialize'
	currentRoute = -> Router.current().route.getName()
	currentMR = -> parseInt Router.current().params.no_mr
	search = -> Session.get 'search'

	Template.menu.helpers
		menus: -> modules

	Template.modul.helpers
		coll: -> coll
		schema: -> new SimpleSchema schema[currentRoute()]
		route: -> currentRoute()
		pasienData: -> coll.findOne no_mr: currentMR()
		addPasien: -> Session.get 'addPasien'
		formType: -> if currentRoute() is 'regis' then 'insert' else 'update-pushArray'
		hari: (date) -> moment(date).format('D MMM YYYY')
		umur: (date) -> moment().diff(date, 'years') + ' tahun'
		showButton: -> Router.current().params.no_mr or currentRoute() is 'regis'
		look: (option, value) ->
			find = _.find selects[option], (i) -> i.value is value
			find.label
		pasiens: ->
			# coll.find().fetch()
			selector = {}
			options = {}
			options.fields = no_mr: 1, regis: 1
			if currentMR()
				selector.no_mr = currentMR()
				options.fields[currentRoute()] = 1
			else if search()
				selector.nama_lengkap =
					$regex: '.*'+search()+'.*'
					$options: '-i'
			###
			else
				options = limit: 5
			###
			sub = Meteor.subscribe 'coll', selector, options
			if sub.ready()
				coll.find().fetch()

	Template.modul.events
		'click #addPasien': -> Session.set 'addPasien', not Session.get 'addPasien'
		'dblclick #row': -> Router.go '/' + currentRoute() + '/' + this.no_mr
		'click #close': -> Router.go currentRoute()
		'keyup #search': (event) -> Session.set 'search', event.target.value
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
