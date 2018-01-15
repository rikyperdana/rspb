if Meteor.isClient

	AutoForm.setDefaultTemplate 'materialize'
	currentRoute = -> Router.current().route.getName()
	currentPar = (param) -> Router.current().params[param]
	search = -> Session.get 'search'
	formDoc = -> Session.get 'formDoc'
	@limit = -> Session.get 'limit'
	@page = -> Session.get 'page'
	roles = -> Meteor.user().roles

	Router.onBeforeAction ->
		unless Meteor.userId() then this.render 'login' else this.next()
	Router.onAfterAction ->
		own = ->
			flat = _.uniq _.flatMap _.keys(roles()), (i) ->
				_.find(rights, (j) -> j.group is i).list
			_.includes flat, Router.current().route.getName()
		Router.go '/' unless own()

	Template.registerHelper 'coll', -> coll
	Template.registerHelper 'schema', -> new SimpleSchema schema[currentRoute()]
	Template.registerHelper 'zeros', (num) ->
		size = _.size _.toString num
		if size < 7 then '0'.repeat(6-size) + _.toString num
	Template.registerHelper 'showForm', -> Session.get 'showForm'
	Template.registerHelper 'hari', (date) -> moment(date).format('D MMM YYYY')
	Template.registerHelper 'rupiah', (val) -> 'Rp ' + numeral(val).format('0,0')
	Template.registerHelper 'currentPar', (param) -> currentPar param
	Template.registerHelper 'stringify', (obj) -> JSON.stringify obj
	Template.registerHelper 'startCase', (val) -> _.startCase val
	Template.registerHelper 'modules', -> modules
	Template.registerHelper 'reverse', (arr) -> _.reverse arr
	Template.registerHelper 'sortBy', (arr, sel, sort) -> _.sortBy arr, (i) -> -i.tanggal.getTime()
	Template.registerHelper 'isTrue', (a, b) -> a is b
	Template.registerHelper 'isFalse', (a, b) -> a isnt b
	Template.registerHelper 'look', (option, value, field) ->
		find = _.find selects[option], (i) -> i.value is value
		find[field]
	Template.registerHelper 'look2', (option, value, field) ->
		find = _.find coll[option].find().fetch(), (i) -> i._id is value
		_.startCase find[field]
	Template.registerHelper 'routeIs', (name) ->
		currentRoute() is name
	Template.registerHelper 'userGroup', (name) ->
		roles()[name]
	Template.registerHelper 'userRole', (name) ->
		roles()[currentRoute()][0] is name
	Template.registerHelper 'pagins', (name) ->
		limit = Session.get 'limit'
		length = coll[name].find().fetch().length
		end = (length - (length % limit)) / limit
		[1..end]

	Template.body.events
		'keypress #search': (event) ->
			if event.key is 'Enter'
				term = event.target.value
				if term.length > 2
					Session.set 'search', term

	Template.layout.onRendered ->
		Session.set 'limit', 10
		Session.set 'page', 0

	Template.menu.helpers
		menus: ->			
			_.flatMap _.keys(roles()), (i) ->
				find = _.find rights, (j) -> j.group is i
				_.map find.list, (j) -> _.find modules, (k) -> k.name is j
		navTitle: ->
			find = _.find modules, (i) -> i.name is currentRoute()
			if find then find.full else _.startCase currentRoute()
		today: -> moment().format('LLL')
	Template.menu.events
		'click #logout': -> Meteor.logout()
		'click #refresh': -> document.location.reload()

	Template.pasien.helpers
		route: -> currentRoute()
		formType: ->
			if currentRoute() is 'regis'
				if currentPar 'no_mr' then 'update' else 'insert'
			else
				'update-pushArray'
		umur: (date) -> moment().diff(date, 'years') + ' tahun'
		showButton: -> Router.current().params.no_mr or currentRoute() is 'regis'
		showButtonText: ->
			switch currentRoute()
				when 'regis' then '+ Pasien'
				when 'jalan' then '+ Rawat'
		formDoc: -> formDoc()
		preview: -> Session.get 'preview'
		omitFields: ->
			unless formDoc() and formDoc().billRegis
				['anamesa', 'diagnosa', 'tindakan', 'labor', 'radio', 'obat', 'spm', 'keluar', 'pindah']
		roleFilter: (arr) -> _.reverse _.filter arr, (i) ->
			find = _.find selects.klinik, (j) ->
				j.label is _.startCase roles().jalan[0]
			i.klinik is find.value
		userPoli: -> roles().jalan
		insurance: (val) -> 'Rp ' + numeral(val+30000).format('0,0')
		selPol: -> _.map roles().jalan, (i) ->
			_.find selects.klinik, (j) -> i is _.snakeCase j.label
		pasiens: ->
			if currentPar 'no_mr'
				selector = no_mr: parseInt currentPar 'no_mr'
				options = fields: no_mr: 1, regis: 1
				arr = ['bayar', 'jalan', 'labor', 'radio', 'obat']
				options.fields.rawat = 1 if _.includes arr, currentRoute()
				sub = Meteor.subscribe 'coll', 'pasien', selector, options
				if sub.ready() then coll.pasien.findOne()
			else if search()
				byName = 'regis.nama_lengkap': $options: '-i', $regex: '.*'+search()+'.*'
				byNoMR = no_mr: parseInt search()
				selector = $or: [byName, byNoMR]
				options = fields: no_mr: 1, regis: 1
				sub = Meteor.subscribe 'coll', 'pasien', selector, options
				if sub.ready() then coll.pasien.find().fetch()
			else if roles().jalan
				now = new Date(); past = new Date now.getDate()-2
				kliniks = _.map roles().jalan, (i) ->
					find = _.find selects.klinik, (j) -> i is _.snakeCase j.label
					find.value
				selector = rawat: $elemMatch:
					klinik: $in: kliniks
					tanggal: $gt: past
				sub = Meteor.subscribe 'coll', 'pasien', selector, {}
				if sub.ready()
					filter = _.filter coll.pasien.find().fetch(), (i) ->
						a = -> _.includes kliniks, i.rawat[i.rawat.length-1].klinik
						b = -> not i.rawat[i.rawat.length-1].total.semua
						selPol = Session.get 'selPol'
						c = -> i.rawat[i.rawat.length-1].klinik is selPol
						if selPol then b() and c() else a() and b()
					_.sortBy filter, (i) -> i.rawat[i.rawat.length-1].tanggal
			else if currentRoute() is 'bayar'
				selector = rawat: $elemMatch: $or: ['total.semua': 0, 'status_bayar': $ne: true]
				sub = Meteor.subscribe 'coll', 'pasien', selector, {}
				if sub.ready() then coll.pasien.find().fetch()
			else if _.includes(['labor', 'radio', 'obat'], currentRoute())
				elem = 'status_bayar': true
				elem[currentRoute()] = $exists: true, $elemMatch: hasil: $exists: false
				selSub = rawat: $elemMatch: elem
				sub = Meteor.subscribe 'coll', 'pasien', selSub, {}
				if sub.ready() then coll.pasien.find().fetch()

	Template.pasien.events
		'click #showForm': ->
			Session.set 'showForm', not Session.get 'showForm'
			later = ->
				$('.autoform-remove-item').trigger 'click'
				if currentRoute() is 'jalan' then _.map ['cara_bayar', 'klinik', 'rujukan'], (i) ->
					if formDoc() then $('input[name="'+i+'"][value="'+formDoc()[i]+'"]').prop 'checked', true
					$('div[data-schema-key="'+i+'"]').prepend('<p>'+_.startCase(i)+'</p>')
				list = ['cara_bayar', 'kelamin', 'agama', 'nikah', 'pendidikan', 'darah', 'pekerjaan']
				if currentRoute() is 'regis' then _.map list, (i) ->
					$('div[data-schema-key="regis.'+i+'"]').prepend('<p>'+_.startCase(i)+'</p>')
			setTimeout later, 1000
			Meteor.subscribe 'coll', 'gudang', {}, {}
			Session.set 'begin', moment()
		'dblclick #row': ->
			Router.go '/' + currentRoute() + '/' + this.no_mr
		'click #close': ->
			_.map ['showForm', 'formDoc', 'preview', 'search'], (i) ->
				Session.set i, null
			Router.go currentRoute()
		'click #card': ->
			dialog =
				title: 'Cetak Kartu'
				message: 'Yakin untuk cetak kartu ini?'
			new Confirmation dialog, (ok) -> if ok
				Meteor.call 'billCard', currentPar('no_mr'), true
				makePdf.card()
		'click #consent': ->
			dialog =
				title: 'Cetak General Consent'
				message: 'Yakin untuk cetak persetujuan pasien?'
			new Confirmation dialog, (ok) -> makePdf.consent() if ok
		'dblclick #bill': (event) ->
			nodes = _.map ['pasien', 'idbayar'], (i) ->
				event.target.attributes[i].nodeValue
			dialog =
				title: 'Pembayaran Pendaftaran'
				message: 'Apakah yakin pasien sudah membayar?'
			new Confirmation dialog, (ok) -> if ok
				if nodes[1]
					Meteor.call 'billRegis', nodes..., true
					makePdf.payRegCard 30000, 'Tiga Puluh Ribu Rupiah'
				else
					Meteor.call 'billCard', nodes[0], false
					makePdf.payRegCard 10000, 'Sepuluh Ribu Rupiah'
		'dblclick #bayar': (event) ->
			nodes = _.map ['pasien', 'idbayar'], (i) ->
				event.target.attributes[i].nodeValue
			dialog =
				title: 'Konfirmasi Pembayaran'
				message: 'Apakah yakin tagihan ini sudah dibayar?'
			new Confirmation dialog, (ok) -> if ok
				Meteor.call 'bayar', nodes...
				pasien = coll.pasien.findOne no_mr: parseInt nodes[0]
				doc = _.find pasien.rawat, (i) -> i.idbayar is nodes[1]
				makePdf.payRawat doc
		'dblclick #request': (event) ->
			nodes = _.map ['pasien', 'idbayar', 'jenis', 'idjenis'], (i) ->
				event.target.attributes[i].nodeValue
			MaterializeModal.prompt
				message: 'Isikan data requestnya'
				callback: (err, res) -> if res.submit
					params = ['request', nodes..., res.value]
					Meteor.call params..., (err, res) -> if res
						message = ''
						for key, val of res
							message += '</p>'+key+': '+val+'</p>'
						MaterializeModal.message
							title: 'Penyerahan Obat'
							message: message
						rekap = Session.get('rekap') or []
						flat = _.flatten _.toPairs res
						Session.set 'rekap', [rekap..., [nodes..., flat...]]
		'dblclick #rekap': ->
			headers = ['Pasien', 'ID Bayar', 'Jenis', 'ID Request', 'No Batch', 'Jumlah']
			makePdf.rekap [headers, Session.get('rekap')...]
			Session.set 'rekap', null
		'click .modal-trigger': (event) ->
			if this.idbayar
				Session.set 'formDoc', this
				Session.set 'preview', modForm this, this.idbayar
			$('#preview').modal 'open'
		'click #rmRawat': ->
			self = this
			dialog =
				title: 'Konfirmasi Hapus'
				message: 'Apakah yakin hapus data rawat pasien ini?'
			new Confirmation dialog, (ok) -> if ok
				Meteor.call 'rmRawat', currentPar('no_mr'), self.idbayar
		'change #selPol': (event) ->
			Session.set 'selPol', parseInt event.target.id
		'click #rmPasien': ->
			dialog =
				title: 'Hapus Pasien'
				message: 'Apakah yakin untuk menghapus pasien?'
			new Confirmation dialog, (ok) -> if ok
				Meteor.call 'rmPasien', currentPar 'no_mr'
				Router.go '/' + currentRoute()

	Template.import.events
		'change :file': (event, template) ->
			Papa.parse event.target.files[0],
				header: true
				step: (result) ->
					data = result.data[0]
					if currentRoute() is 'regis'
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
						Meteor.call 'import', 'pasien', selector, modifier
					else if currentRoute() is 'manajemen'
						if data.tipe
							selector = nama: data.nama
							modifier =
								tipe: parseInt data.tipe
								poli: parseInt data.poli
								active: true
							Meteor.call 'import', 'dokter', selector, modifier
						else if data.harga
							selector = nama: _.snakeCase data.nama
							modifier =
								harga: parseInt data.harga
								jenis: _.snakeCase data.jenis
								active: true
							data.grup and modifier.grup = _.startCase data.grup
							Meteor.call 'import', 'tarif', selector, modifier
						else if data.password
							Meteor.call 'newUser', data
							Meteor.call 'addRole', data.username, [data.role], data.group
					else if currentRoute() is 'farmasi'
						selector = nama: data.nama
						modifier =
							jenis: parseInt data.jenis
							idbarang: randomId()
							batch: [
								idbatch: randomId()
								anggaran: data.anggaran
								beli: parseInt data.beli
								diapotik: parseInt data.diapotik
								digudang: parseInt data.digudang
								jenis: parseInt data.jenis
								jual: parseInt data.jual
								kadaluarsa: new Date data.kadaluarsa
								masuk: new Date data.masuk
								merek: data.merek or ''
								nobatch: data.nobatch
								pengadaan: parseInt data.pengadaan
								satuan: parseInt data.satuan
								suplier: data.suplier
							]
						data.nama and Meteor.call 'import', 'gudang', selector, modifier, 'batch'

	Template.gudang.helpers
		schemagudang: -> new SimpleSchema schema.gudang
		formType: -> if currentPar('idbarang') then 'update-pushArray' else 'insert'
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
				sub.ready() and coll.gudang.find().fetch()
			else
				sub = Meteor.subscribe 'coll', 'gudang', {}, {}
				sub.ready() and coll.gudang.find().fetch()

	Template.gudang.events
		'click #showForm': ->
			Session.set 'showForm', not Session.get 'showForm'
		'dblclick #row': -> Router.go '/' + currentRoute() + '/' + this.idbarang
		'dblclick #transfer': ->
			data = this
			if roles().farmasi
				MaterializeModal.prompt
					message: 'Transfer Gudang > Apotek'
					callback: (err, res) -> if res.submit
						Meteor.call 'transfer', currentPar('idbarang'), data.idbatch, parseInt res.value
		'click #rmBarang': ->
			self = this
			dialog =
				title: 'Hapus Jenis Obat'
				message: 'Apakah yakin untuk hapus jenis obat ini dari sistem?'
			new Confirmation dialog, (ok) -> if ok
				Meteor.call 'rmBarang', self.idbarang

	Template.manajemen.onRendered ->
		$('select#export').material_select()

	Template.manajemen.helpers
		users: -> Meteor.users.find().fetch()
		onUser: -> Session.get 'onUser'
		selRoles: -> ['petugas', 'admin']
		klinik: -> selects.klinik
		schemadokter: -> new SimpleSchema schema.dokter
		schematarif: -> new SimpleSchema schema.tarif
		dokters: ->
			selector = active: true
			options = limit: limit(), skip: page() * limit()
			coll.dokter.find(selector, options).fetch()
		tarifs: ->
			selector = active: true
			options = limit: limit(), skip: page() * limit()
			coll.tarif.find(selector, options).fetch()

	Template.manajemen.events
		'submit #userForm': (event) ->
			event.preventDefault()
			onUser = Session.get 'onUser'
			unless onUser
				doc =
					username: event.target.children.username.value
					password: event.target.children.password.value
				repeat = event.target.children.repeat.value
				if doc.password is repeat
					Meteor.call 'newUser', doc
					$('input').val ''
				else
					Materialize.toast 'Password tidak mirip', 3000
			else
				role = $('input[name="role"]:checked', event.target)[0].id
				group = $('input[name="group"]:checked', event.target)[0].id
				poli = $('input[name="poli"]:checked', event.target)[0]
				theRole = unless poli then role else _.snakeCase poli.id
				Meteor.call 'addRole', onUser._id, [theRole], group
		'dblclick #row': -> Session.set 'onUser', this
		'dblclick #reset': ->
			self = this
			dialog =
				title: 'Reset Peranan'
				message: 'Anda yakin untuk menghapus semua perannya?'
			new Confirmation dialog, (ok) -> if ok
				Meteor.call 'rmRole', self._id
		'click #close': -> console.log 'tutup'
		'click #export': ->
			select = $('select#export').val()
			Meteor.call 'export', select, (err, content) -> if content
				blob = new Blob [content], type: 'text/plain;charset=utf-8'
				saveAs blob, select+'.csv'
		'dblclick #baris': (event) ->
			jenis = event.currentTarget.className
			dialog =
				title: 'Hapus ' + _.startCase jenis
				message: 'Yakin untuk menghapus '+jenis+' dari daftar?'
			self = this
			new Confirmation dialog, (ok) -> if ok
				Meteor.call 'inactive', jenis, self._id

	Template.login.onRendered ->
		$('.slider').slider()

	Template.login.events
		'submit form': (event) ->
			event.preventDefault()
			username = event.target.children.username.value
			password = event.target.children.password.value
			Meteor.loginWithPassword username, password, (err) ->
				if err
					Materialize.toast 'Salah username / password', 3000
				else
					Router.go '/' + _.keys(roles())[0]

	Template.pagination.events
		'click #next': -> Session.set 'page', 1 + page()
		'click #prev': -> Session.set 'page', -1 + page()
		'click #num': (event) ->
			Session.set 'page', parseInt event.target.innerText

	Template.report.helpers
		datas: -> Session.get 'laporan'

	Template.report.events
		'click .datepicker': (event, template) ->
			type = event.target.attributes.date.nodeValue
			$('#'+type).pickadate onSet: (data) ->
				Session.set type+'Date', data.select
				start = Session.get 'startDate'
				end = Session.get 'endDate'
				if start and end
					Meteor.call 'report', template.data.jenis, start, end, (err, res) ->
						res and Session.set 'laporan', res
		'click #export': (event, template) ->
			content = exportcsv.exportToCSV Session.get('laporan').csv, true, ';'
			blob = new Blob [content], type: 'text/plain;charset=utf-8'
			saveAs blob, template.data.jenis+'.csv'
