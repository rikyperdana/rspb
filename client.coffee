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
		addPasien: -> Session.get 'addPasien'
		formType: -> if currentRoute() is 'regis' then 'insert' else 'update-pushArray'
		hari: (date) -> moment(date).format('D MMM YYYY')
		umur: (date) -> moment().diff(date, 'years') + ' tahun'
		showButton: -> Router.current().params.no_mr or currentRoute() is 'regis'
		currentMR: -> currentMR()
		routeIs: (name) -> currentRoute() is name
		look: (option, value) ->
			find = _.find selects[option], (i) -> i.value is value
			find.label
		pasiens: ->
			if currentMR()
				selector = no_mr: currentMR()
				options = fields: no_mr: 1, regis: 1
				options.fields[currentRoute()] = 1
				sub = Meteor.subscribe 'coll', selector, options
				if sub.ready() then coll.findOne()
			else if search()
				byName = 'regis.nama_lengkap': $options: '-i', $regex: '.*'+search()+'.*'
				byNoMR = no_mr: parseInt search()
				selector = $or: [byName, byNoMR]
				options = fields: no_mr: 1, regis: 1
				sub = Meteor.subscribe 'coll', selector, options
				if sub.ready() then coll.find().fetch()
			else
				selector = {}
				options = limit: 5, fields: no_mr: 1, regis: 1
				if currentRoute() is 'bayar' then options.fields.jalan = 1
				sub = Meteor.subscribe 'coll', selector, options
				if sub.ready() then coll.find().fetch()

	Template.modul.events
		'click #addPasien': ->
			Session.set 'addPasien', not Session.get 'addPasien'
			unexpand = -> $('.autoform-remove-item').trigger 'click'
			setTimeout unexpand, 1000
		'dblclick #row': -> Router.go '/' + currentRoute() + '/' + this.no_mr
		'click #close': ->
			Session.set 'addPasien', false
			Router.go currentRoute()
		'keypress #search': (event) ->
			if event.key is 'Enter'
				Session.set 'search', event.target.value
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
		'dblclick #bayar': (event) ->
			no_mr = event.target.attributes.pasien.nodeValue
			idbayar = event.target.attributes.idbayar.nodeValue
			console.log no_mr, idbayar

	Template.import.events
		'change :file': (event, template) ->
			Papa.parse event.target.files[0],
				header: true
				step: (result) ->
					data = result.data[0]
					selector =
						no_mr: parseInt data.no_mr
					modifier =
						regis:
							nama_lengkap: data.nama_lengkap
							tmpt_kelahiran: data.tmpt_kelahiran
							alamat: data.alamat
					Meteor.call 'import', selector, modifier

	AutoForm.addHooks null,
		after:
			insert: (err, res) ->
				if res then console.log res
			'update-pushArray': (err, res) -> if res
				console.log currentRoute(), this.currentDoc.no_mr, this.insertDoc
