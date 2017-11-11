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
	formDoc = -> Session.get 'formDoc'

	Template.menu.helpers
		menus: ->
			keys = _.keys Meteor.user().roles
			find = _.find rights, (i) -> i.group is keys[0]
			if find then  _.map find.list, (i) -> _.find modules, (j) -> j.name is i
		navTitle: ->
			find = _.find modules, (i) -> i.name is currentRoute()
			if find then find.full else ''
		today: -> moment().format('LLL')
	Template.menu.events
		'click #logout': -> Meteor.logout()

	Template.registerHelper 'coll', -> coll
	Template.registerHelper 'schema', -> new SimpleSchema schema[currentRoute()]
	Template.registerHelper 'showForm', -> Session.get 'showForm'
	Template.registerHelper 'hari', (date) -> moment(date).format('D MMM YYYY')
	Template.registerHelper 'rupiah', (val) -> 'Rp ' + numeral(val).format('0,0')
	Template.registerHelper 'currentPar', (param) -> currentPar param
	Template.registerHelper 'stringify', (obj) -> JSON.stringify obj
	Template.registerHelper 'startCase', (val) -> _.startCase val
	Template.registerHelper 'modules', -> modules
	Template.registerHelper 'reverse', (arr) -> _.reverse arr
	Template.registerHelper 'isTrue', (a, b) -> a is b
	Template.registerHelper 'isFalse', (a, b) -> a isnt b

	Template.body.events
		'keypress #search': (event) ->
			if event.key is 'Enter'
				Session.set 'search', event.target.value

	Template.pasien.helpers
		route: -> currentRoute()
		formType: -> if currentRoute() is 'regis' then 'insert' else 'update-pushArray'
		umur: (date) -> moment().diff(date, 'years') + ' tahun'
		showButton: -> Router.current().params.no_mr or currentRoute() is 'regis'
		showButtonText: ->
			switch currentRoute()
				when 'regis' then '+ Pasien'
				when 'jalan' then '+ Rawat'
		routeIs: (name) -> currentRoute() is name
		formDoc: -> formDoc()
		preview: -> Session.get 'preview'
		omitFields: ->
			unless formDoc() and formDoc().billRegis
				['tindakan', 'labor', 'radio', 'obat']

		look: (option, value, field) ->
			find = _.find selects[option], (i) -> i.value is value
			find[field]
		isZero: (val) -> val is 0
		roleFilter: (arr) -> _.reverse _.filter arr, (i) ->
			find = _.find selects.klinik, (j) ->
				j.label is _.startCase Meteor.user().roles.jalan[0]
			i.klinik is find.value
		userPoli: -> Meteor.user().roles.jalan
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
			else if Meteor.user().roles.jalan
				sub = Meteor.subscribe 'coll', 'pasien', {}, {}
				if sub.ready()
					roleNum = _.find selects.klinik, (i) ->
						Meteor.user().roles.jalan[0] is _.snakeCase i.label
					_.filter coll.pasien.find().fetch(), (i) ->
						i.rawat[i.rawat.length-1].klinik is roleNum.value
			else
				selector = {}
				options = limit: 5, fields: no_mr: 1, regis: 1
				if currentRoute() is 'bayar' or 'jalan' or 'labor' or 'radio' or 'obat'
					options.fields.rawat = 1
				sub = Meteor.subscribe 'coll', 'pasien', selector, options
				if sub.ready() then _.reverse coll.pasien.find().fetch()

	Template.pasien.events
		'click #showForm': ->
			Session.set 'showForm', not Session.get 'showForm'
			later = ->
				$('.autoform-remove-item').trigger 'click'
				if currentRoute() is 'jalan' then _.map ['cara_bayar', 'klinik'], (i) ->
					if formDoc() then $('input[name="'+i+'"][value="'+formDoc()[i]+'"]').prop 'checked', true
					$('div[data-schema-key="'+i+'"]').prepend('<p>'+_.startCase(i)+'</p>')
				list = ['cara_bayar', 'kelamin', 'agama', 'nikah', 'pendidikan', 'darah', 'pekerjaan']
				if currentRoute() is 'regis' then _.map list, (i) ->
					$('div[data-schema-key="regis.'+i+'"]').prepend('<p>'+_.startCase(i)+'</p>')
			setTimeout later, 1000
			Meteor.subscribe 'coll', 'gudang', {}, {}
		'dblclick #row': ->
			Router.go '/' + currentRoute() + '/' + this.no_mr
		'click #close': ->
			Session.set 'showForm', false
			Session.set 'formDoc', null
			Session.set 'preview', null
			Router.go currentRoute()
		'keypress #search': (event) ->
			if event.key is 'Enter'
				Session.set 'search', event.target.value
		'click #card': ->
			Meteor.call 'billCard', currentPar('no_mr'), true
			makePdf.card()
		'click #consent': -> makePdf.consent()
		'dblclick #bill': (event) ->
			no_mr = event.target.attributes.pasien.nodeValue
			idbayar = -> event.target.attributes.idbayar.nodeValue
			dialog =
				title: 'Pembayaran Pendaftaran'
				message: 'Apakah yakin pasien sudah membayar?'
			new Confirmation dialog, (ok) -> if ok
				if event.target.attributes.idbayar
					Meteor.call 'billRegis', no_mr, idbayar(), true
					makePdf.payRegCard 30000, 'Tiga Puluh Ribu Rupiah'
				else
					Meteor.call 'billCard', no_mr, false
					makePdf.payRegCard 10000, 'Sepuluh Ribu Rupiah'
		'dblclick #bayar': (event) ->
			no_mr = event.target.attributes.pasien.nodeValue
			idbayar = event.target.attributes.idbayar.nodeValue
			dialog =
				title: 'Konfirmasi Pembayaran'
				message: 'Apakah yakin tagihan ini sudah dibayar?'
			new Confirmation dialog, (ok) -> if ok
				Meteor.call 'bayar', no_mr, idbayar
				makePdf.payRawat()
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
			if this.idbayar
				Session.set 'formDoc', this
				Session.set 'preview', modForm this, this.idbayar
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
		selRoles: -> ['petugas', 'admin']
		klinik: -> selects.klinik

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
				role = $('input[name="role"]:checked', event.target)[0].id
				group = $('input[name="group"]:checked', event.target)[0].id
				poli = $('input[name="poli"]:checked', event.target)[0]
				theRole = unless poli then role else _.snakeCase poli.id
				Meteor.call 'setRole', onUser._id, [theRole], group
		'dblclick #row': ->
			Session.set 'onUser', this
		'click #close': ->
			console.log 'tutup'

	Template.login.events
		'submit form': (event) ->
			event.preventDefault()
			username = event.target.children.username.value
			password = event.target.children.password.value
			Meteor.loginWithPassword username, password, (err) ->
				if err
					Materialize.toast 'Salah username / password', 3000
				else
					userGroups = _.keys Meteor.user().roles
					Router.go '/' + userGroups[0]
