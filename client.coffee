if Meteor.isClient

	Router.onBeforeAction ->
		unless Meteor.userId()
			this.render 'login'
		else
			this.next()

	AutoForm.setDefaultTemplate 'materialize'
	currentRoute = -> Router.current().route.getName()
	currentPar = (param) -> Router.current().params[param]
	search = -> Session.get 'search'

	Template.menu.helpers
		menus: ->
			if Roles.userIsInRole Meteor.userId(), 'admin', 'pendaftaran'
				_.map ['regis', 'jalan'], (i) -> _.find modules, (j) -> j.name is i
			else if Roles.userIsInRole Meteor.userId(), 'admin', 'pembayaran'
				_.map ['bayar'], (i) -> _.find modules, (j) -> j.name is i
	Template.menu.events
		'click #logout': -> Meteor.logout()

	Template.registerHelper 'coll', -> coll
	Template.registerHelper 'schema', -> new SimpleSchema schema[currentRoute()]
	Template.registerHelper 'showForm', -> Session.get 'showForm'
	Template.registerHelper 'hari', (date) -> moment(date).format('D MMM YYYY')
	Template.registerHelper 'rupiah', (val) -> 'Rp ' + val
	Template.registerHelper 'currentPar', (param) -> currentPar param
	Template.registerHelper 'stringify', (obj) -> JSON.stringify obj

	Template.body.events
		'keypress #search': (event) ->
			if event.key is 'Enter'
				Session.set 'search', event.target.value

	Template.pasien.helpers
		route: -> currentRoute()
		formType: -> if currentRoute() is 'regis' then 'insert' else 'update-pushArray'
		umur: (date) -> moment().diff(date, 'years') + ' tahun'
		showButton: -> Router.current().params.no_mr or currentRoute() is 'regis'
		routeIs: (name) -> currentRoute() is name
		formDoc: -> Session.get 'formDoc'
		# omitFields: -> ['tindakan', 'labor', 'radio', 'obat']
		look: (option, value, field) ->
			find = _.find selects[option], (i) -> i.value is value
			find[field]
		pasiens: ->
			if currentPar 'no_mr'
				selector = no_mr: parseInt currentPar 'no_mr'
				options = fields: no_mr: 1, regis: 1
				if currentRoute() is 'bayar' or 'jalan' or 'labor' or 'radio' or 'obat'
					options.fields.rawat = 1
				sub = Meteor.subscribe 'coll', 'pasien', selector, options
				if sub.ready() then coll.pasien.findOne()
			else if search()
				byName = 'regis.nama_lengkap': $options: '-i', $regex: '.*'+search()+'.*'
				byNoMR = no_mr: parseInt search()
				selector = $or: [byName, byNoMR]
				options = fields: no_mr: 1, regis: 1
				sub = Meteor.subscribe 'coll', 'pasien', selector, options
				if sub.ready() then coll.pasien.find().fetch()
			else
				selector = {}
				options = limit: 5, fields: no_mr: 1, regis: 1
				if currentRoute() is 'bayar' or 'jalan' or 'labor' or 'radio' or 'obat'
					options.fields.rawat = 1
				sub = Meteor.subscribe 'coll', 'pasien', selector, options
				if sub.ready() then coll.pasien.find().fetch()

	Template.pasien.events
		'click #showForm': ->
			Session.set 'showForm', not Session.get 'showForm'
			later = ->
				$('.autoform-remove-item').trigger 'click'
				formDoc = Session.get 'formDoc'
				if formDoc then _.map ['jenis', 'cara_bayar', 'klinik'], (i) ->
					$('input[name="'+i+'"][value="'+formDoc[i]+'"]').prop 'checked', true
			setTimeout later, 1000
			Meteor.subscribe 'coll', 'gudang', {}, {}
		'dblclick #row': -> Router.go '/' + currentRoute() + '/' + this.no_mr
		'click #close': ->
			Session.set 'showForm', false
			Router.go currentRoute()
		'keypress #search': (event) ->
			if event.key is 'Enter'
				Session.set 'search', event.target.value
		'click #card': ->
			pdf = pdfMake.createPdf
				content: [
					'Nama: ' + coll.pasien.findOne().regis.nama_lengkap
					'No. MR: ' + coll.pasien.findOne().no_mr
				]
				pageSize: 'B8'
				pageMargins: [110, 50, 0, 0]
				pageOrientation: 'landscape'
			pdf.download coll.pasien.findOne().regis.nama_lengkap + '.pdf'
		'dblclick #payRegis': (event) ->
			no_mr = event.target.attributes.pasien.nodeValue
			dialog =
				title: 'Pembayaran Pendaftaran'
				message: 'Apakah yakin pasien sudah membayar?'
			new Confirmation dialog, (ok) ->
				if ok then Meteor.call 'payRegis', no_mr
		'dblclick #bayar': (event) ->
			no_mr = event.target.attributes.pasien.nodeValue
			idbayar = event.target.attributes.idbayar.nodeValue
			dialog =
				title: 'Konfirmasi Pembayaran'
				message: 'Apakah yakin tagihan ini sudah dibayar?'
			new Confirmation dialog, (ok) ->
				if ok then Meteor.call 'bayar', no_mr, idbayar
		'dblclick #request': (event) ->
			no_mr = event.target.attributes.pasien.nodeValue
			idbayar = event.target.attributes.idbayar.nodeValue
			jenis = event.target.attributes.jenis.nodeValue
			idjenis = event.target.attributes.idjenis.nodeValue
			MaterializeModal.prompt
				message: 'Isikan data requestnya'
				callback: (err, res) -> if res.submit
					Meteor.call 'request', no_mr, idbayar, jenis, idjenis, res.value
		'click .modal-trigger': (event) ->
			if this.idbayar then Session.set 'formDoc', this
			$('#preview').modal 'open'

	Template.import.events
		'change :file': (event, template) ->
			Papa.parse event.target.files[0],
				header: true
				step: (result) ->
					data = result.data[0]
					selector = no_mr: parseInt data.no_mr
					modifier = regis:
						nama_lengkap: _.startCase data.nama_lengkap
						alamat: _.startCase data.alamat
						agama: parseInt data.agama
						ayah: _.startCase data.ayah
						nikah: parseInt data.nikah
						pekerjaan: parseInt data.pekerjaan
						pendidikan: parseInt data.pendidikan
						tgl_lahir: new Date data.tgl_lahir
						tmpt_kelahiran: _.startCase data.tmpt_kelahiran
					Meteor.call 'import', selector, modifier

	Template.gudang.helpers
		gudangs: ->
			if currentPar 'idbarang'
				selector = idbarang: currentPar 'idbarang'
				sub = Meteor.subscribe 'coll', 'gudang', selector, {}
				if sub.ready() then coll.gudang.findOne()
			else if search()
				byName = nama: $options: '-i', $regex: '.*'+search()+'.*'
				byBatch = idbatch: search()
				selector = $or: [byName, byBatch]
				sub = Meteor.subscribe 'coll', 'gudang', selector, {}
				if sub.ready() then coll.gudang.find().fetch()
			else
				sub = Meteor.subscribe 'coll', 'gudang', {}, {}
				if sub.ready() then coll.gudang.find().fetch()

	Template.gudang.events
		'click #showForm': ->
			Session.set 'showForm', not Session.get 'showForm'
		'dblclick #row': -> Router.go '/' + currentRoute() + '/' + this.idbarang
		'dblclick #transfer': ->
			data = this
			MaterializeModal.prompt
				message: 'Transfer Gudang > Apotek'
				callback: (err, res) -> if res.submit
					Meteor.call 'transfer', currentPar('idbarang'), data.idbatch, parseInt res.value

	Template.users.onRendered ->
		Meteor.subscribe 'users'
	
	Template.users.helpers
		users: -> Meteor.users.find().fetch()
		onUser: -> Session.get 'onUser'

	Template.users.events
		'submit form': (event) ->
			event.preventDefault()
			onUser = Session.get 'onUser'
			unless onUser
				doc =
					username: event.target.children.username.value
					password: event.target.children.password.value
				repeat = event.target.children.repeat.value
				if doc.password is repeat
					Accounts.createUser doc
					$('input').val ''
				else
					Materialize.toast 'Password tidak mirip', 3000
			else
				split = _.split event.target.children.roles.value, ','
				roles = _.map split, (i) -> _.snakeCase i
				group = event.target.children.group.value
				Meteor.call 'setRole', Meteor.userId(), roles, group
				Session.set 'onUser', null
		'dblclick #row': ->
			Session.set 'onUser', this

	Template.login.events
		'submit form': (event) ->
			event.preventDefault()
			username = event.target.children.username.value
			password = event.target.children.password.value
			Meteor.loginWithPassword username, password
