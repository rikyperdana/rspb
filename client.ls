if Meteor.isClient

	Router.onBeforeAction ->
		unless Meteor.userId! then @render \login else @next!
	Router.onAfterAction ->
		sessNull!
		Router.go \/ unless currentRoute! in
			_.uniq _.flatMap roles!, (i, j) ->
				(.list) _.find rights, (k) -> k.group is j

	globalHelpers =
		coll: -> coll
		schema: -> new SimpleSchema schema[currentRoute!]
		zeros: (num) -> zeros num
		showForm: -> Session.get \showForm
		hari: (date) -> date and moment date .format 'D MMM YYYY'
		rupiah: (val) -> 'Rp ' + numeral val .format '0,0'
		currentRoute: (name) -> unless name then currentRoute! else currentRoute! is name
		currentPar: (param) -> currentPar param
		stringify: (obj) -> JSON.stringify obj
		startCase: (val) -> _.startCase val
		modules: -> modules
		reverse: (arr) -> _.reverse arr
		sortBy: (arr, sel, sort) -> _.sortBy arr, -> -it.tanggal.getTime!
		isTrue: (a, b) -> a is b
		isFalse: (a, b) -> a isnt b
		look: (option, value, field) -> look(option, value)?[field]
		look2: (option, value, field) -> look2(option, value)?[field]
		userGroup: (name) -> userGroup name
		userRole: (name) -> userRole name
		userName: (id) -> _.startCase userName id
	_.map globalHelpers, (val, key) -> Template.registerHelper key, val

	Template.body.events do
		'keypress #search': (event) ->
			if event.key is \Enter
				term = event.target.value
				if term.length > 2
					Session.set \search, term

	Template.layout.onRendered ->
		Session.set \limit, 10
		Session.set \page, 0

	Template.menu.helpers do
		menus: ->			
			_.flatMap roles!, (i, j) ->
				find = _.find rights, (k) -> k.group is j
				_.initial _.map find.list, (k) ->
					_.find modules, (l) -> l.name is k
		navTitle: ->
			find = _.find modules, (i) -> i.name is currentRoute!
			find?full or _.startCase currentRoute!
		today: -> moment!format \LLL

	Template.menu.events do
		'click #logout': -> Meteor.logout!

	Template.pasien.helpers do
		heads: ->
			pasien: <[ no_mr nama orang_tua alamat jenis_kelamin tgl_lahir ]>
			bayar: <[ no_mr nama tanggal total_biaya cara_bayar klinik aksi ]>
			labor: <[ no_mr pasien grup order aksi ]>
			radio: <[ no_mr pasien order aksi ]>
			obat: <[ tanggal no_mr pasien dokter klinik nama_obat aturan jumlah serah ]>
			rawat: <[ tanggal klinik cara_bayar bayar_pendaftaran bayar_tindakan cek ]>
			fisik: <[ tekanan_darah nadi suhu pernapasan berat tinggi lila ]>
			previewDokter: <[ Tindakan Dokter Harga ]>
			previewLabor: <[ Grup Order Hasil ]>
			previewRadio: <[ Order Arsip ]>
			previewObat: <[ Nama Dosis Bentuk Kali Jumlah ]>
		route: -> currentRoute!
		formType: ->
			if currentRoute! is \regis
				if currentPar \no_mr then \update else \insert
			else
				\update-pushArray
		umur: (date) -> moment!diff(date, \years) + ' tahun'
		showButton: -> Router.current!params.no_mr or currentRoute! is \regis
		showButtonText: ->
			switch currentRoute!
				when \regis then '+ Pasien'
				when \jalan then '+ Rawat'
		formDoc: -> formDoc!
		preview: -> Session.get \preview
		omitFields: ->
			arr = <[ anamesa_perawat fisik anamesa_dokter diagnosa planning tindakan labor radio obat spm keluar pindah ]>
			unless formDoc!?billRegis then arr
			else unless \dr is _.first _.split Meteor.user!username, \.
				arr[2 to arr.length]
		roleFilter: (arr) -> _.reverse _.filter arr, (i) ->
			i.klinik is (.value) _.find selects.klinik, (j) ->
				j.label is _.startCase roles!jalan.0
		userPoli: -> roles!jalan
		insurance: (val) -> 'Rp ' + numeral val+30000 .format '0,0'
		selPol: -> _.map roles!?jalan, (i) ->
			_.find selects.klinik, (j) -> i is _.snakeCase j.label
		pasiens: ->
			if currentPar \no_mr
				selector = no_mr: parseInt currentPar \no_mr
				options = fields: no_mr: 1, regis: 1
				arr = <[ bayar jalan labor radio obat ]>
				options.fields.rawat = 1 if currentRoute! in arr
				Meteor.subscribe \coll, \pasien, selector, options
				.ready! and coll.pasien.findOne!
			else if search!
				byName = 'regis.nama_lengkap': $options: \-i, $regex: '.*'+search!+'.*'
				byNoMR = no_mr: parseInt search!
				selector = $or: [byName, byNoMR]
				options = fields: no_mr: 1, regis: 1
				Meteor.subscribe \coll, \pasien, selector, options
				.ready! and coll.pasien.find!fetch!
			else if roles!?jalan
				kliniks = _.map roles!jalan, (i) ->
					(.value) _.find selects.klinik, (j) -> i is _.snakeCase j.label
				selector = rawat: $elemMatch:
					klinik: $in: kliniks
					tanggal: $gt: new Date (new Date!).getDate!-2
				Meteor.subscribe \coll, \pasien, selector, {} .ready! and do ->
					filter = _.filter coll.pasien.find!fetch!, (i) ->
						a = -> i.rawat[i.rawat.length-1]klinik in kliniks
						b = -> not i.rawat[i.rawat.length-1]total.semua
						selPol = Session.get \selPol
						c = -> i.rawat[i.rawat.length-1]klinik is selPol
						if selPol then b! and c! else a! and b!
					_.sortBy filter, (i) -> i.rawat[i.rawat.length-1].tanggal
			else if currentRoute! is \bayar
				selector = rawat: $elemMatch: $or: ['status_bayar': $ne: true]
				Meteor.subscribe \coll, \pasien, selector, {}
				.ready! and coll.pasien.find!fetch!
			else if currentRoute! in <[ labor radio obat ]>
				elem = 'status_bayar': true
				elem[currentRoute!] = $exists: true, $elemMatch: hasil: $exists: false
				selSub = rawat: $elemMatch: elem
				Meteor.subscribe \coll, \pasien, selSub, {}
				.ready! and coll.pasien.find!fetch!

	Template.pasien.events do
		'click #showForm': ->
			unless userGroup \jalan and not Session.get \formDoc
				Session.set \showForm, not Session.get \showForm
				if userGroup \regis then Session.set \formDoc, null
				Meteor.subscribe \coll, \gudang, {}, {}
				Session.set \begin, new Date!
				(Meteor.setTimeout _, 1000) later = ->
					$ \.autoform-remove-item .trigger \click
					if currentRoute! is \jalan
						_.map <[ cara_bayar klinik karcis rujukan ]>, (i) ->
							$ 'div[data-schema-key="'+i+'"]' .prepend tag \p, _.startCase i
							if formDoc!
								$ 'input[name="'+i+'"][value="'+formDoc![i]+'"]' .attr checked: true
								$ 'input[name="'+i+'"]' .attr disabled: \disabled
						_.map [\anamesa_perawat], (i) ->
							$ 'textarea[name="'+i+'"]' .val formDoc!?[i]
					list = <[ cara_bayar kelamin agama nikah pendidikan darah pekerjaan ]>
					if currentRoute! is \regis
						_.map list, (i) ->
							$ 'div[data-schema-key="regis.'+i+'"]' .prepend tag \p, _.startCase i
						arr = _.compact _.map schema.regis, (i, j) -> (.1) _.split j, \.
						_.map arr, (i) ->
							$ '[name="regis.'+i+'"]' .parents \div.row .removeClass \row .addClass 'col m6'
						$ '.card-content' .addClass \row
		'dblclick #row': ->
			Router.go \/ + currentRoute! + \/ + @no_mr
		'click #close': -> sessNull!; Router.go currentRoute!
		'click #card': ->
			dialog = title: 'Cetak Kartu', message: 'Yakin untuk cetak kartu ini?'
			new Confirmation dialog, (ok) -> if ok
				# Meteor.call \billCard, currentPar(\no_mr), true
				makePdf.card!
		'click #consent': ->
			dialog = title: 'General Consent', message: 'Yakin untuk dicetak?'
			new Confirmation dialog, (ok) -> makePdf.consent! if ok
		'dblclick #bill': (event) ->
			nodes = _.map <[ pasien idbayar karcis ]>, (i) ->
				event.target.attributes[i]nodeValue
			dialog =
				title: 'Pembayaran Pendaftaran'
				message: 'Apakah yakin pasien sudah membayar?'
			new Confirmation dialog, (ok) -> if ok
				if nodes.1
					Meteor.call \billRegis, ...nodes[0 to 1], true
					makePdf.payRegCard ...nodes[0 to 2], \...
				else
					Meteor.call \billCard, nodes.0, false
					makePdf.payRegCard 10000, 'Sepuluh Ribu Rupiah'
		'dblclick #bayar': (event) ->
			nodes = _.map <[ pasien idbayar ]>, (i) ->
				event.target.attributes[i]nodeValue
			dialog =
				title: 'Konfirmasi Pembayaran'
				message: 'Apakah yakin tagihan ini sudah dibayar?'
			new Confirmation dialog, (ok) -> if ok
				Meteor.call \bayar, ...nodes
				pasien = coll.pasien.findOne no_mr: parseInt nodes.1
				doc = _.find pasien.rawat, (i) -> i.idbayar is nodes.1
				makePdf.payRawat nodes.0, doc
		'dblclick #request': (event) ->
			nodes = _.map <[ pasien idbayar jenis idjenis ]>, (i) ->
				event.target.attributes[i].nodeValue
			MaterializeModal.prompt do
				message: 'Isikan data requestnya'
				callback: (err, res) -> if res.submit
					params = [\request, ...nodes, res.value]
					Meteor.call ...params, (err, res) -> if res
						MaterializeModal.message do
							title: 'Penyerahan Obat'
							message: (.join '') _.map res, (val , key) -> tag \p, "#key: #val"
						rekap = Session.get \rekap or []
						flat = _.flatten _.toPairs res
						Session.set \rekap, [...rekap, [...nodes, ...flat]]
		'dblclick #rekap': ->
			headers = <[ psaien id_bayar jenis id_request no_batch jumlah ]>
			makePdf.rekap [headers, ...Session.get \rekap]
			Session.set \rekap, null
		'click .modal-trigger': (event) ->
			if @idbayar
				Session.set \formDoc, @
				Session.set \preview, modForm @, @idbayar
			$ '#preview' .modal \open
		'click #rmRawat': ->
			self = @
			dialog =
				title: 'Konfirmasi Hapus'
				message: 'Apakah yakin hapus data rawat pasien ini?'
			new Confirmation dialog, (ok) -> if ok
				Meteor.call \rmRawat, currentPar(\no_mr), self.idbayar
		'change #selPol': (event) ->
			Session.set \selPol, parseInt event.target.id
		'click #rmPasien': ->
			dialog =
				title: 'Hapus Pasien'
				message: 'Apakah yakin untuk menghapus pasien?'
			new Confirmation dialog, (ok) -> if ok
				Meteor.call \rmPasien, currentPar \no_mr
				Router.go \/ + currentRoute!

	Template.import.events do
		'change :file': (event, template) ->
			Papa.parse event.target.files.0, header: true, step: (result) ->
				data = result.data.0
				if currentRoute! is \regis
					selector = no_mr: parseInt data.no_mr
					modifier = regis:
						nama_lengkap: _.startCase data.nama_lengkap
						alamat: _.startCase data.alamat if data.alamat
						agama: parseInt data.agama if data.agama
						ayah: _.startCase data.ayah if data.ayah
						nikah: parseInt data.nikah if data.nikah
						pekerjaan: parseInt data.pekerjaan if data.pekerjaan
						pendidikan: parseInt data.pendidikan if data.pendidikan
						tgl_lahir: new Date data.tgl_lahir if Date.parse data.tgl_lahir
						tmpt_kelahiran: _.startCase data.tmpt_kelahiran if data.tmpt_kelahiran
					Meteor.call \import, \pasien, selector, modifier
				else if currentRoute! is \manajemen
					if data.tipe
						selector = nama: data.nama
						modifier =
							tipe: parseInt data.tipe
							poli: parseInt data.poli
							active: true
						Meteor.call \import, \dokter, selector, modifier
					else if data.harga
						selector = nama: _.snakeCase data.nama
						modifier =
							harga: parseInt data.harga
							jenis: _.snakeCase data.jenis
							active: true
						data.grup and modifier.grup = _.startCase data.grup
						Meteor.call \import, \tarif, selector, modifier
					else if data.password
						Meteor.call \newUser, data
						Meteor.call \addRole, data.username, [data.role], data.group
				else if currentRoute! is \farmasi
					selector = nama: data.nama
					modifier =
						jenis: parseInt data.jenis
						idbarang: randomId!
						batch: [
							idbatch: randomId!
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
					data.nama and Meteor.call \import, \gudang, selector, modifier, \batch

	Template.export.onRendered ->
		$ 'select#export' .material_select!

	Template.export.events do
		'click #export': ->
			select = $ 'select#export' .val!
			Meteor.call \export, select, (err, content) -> if content
				blob = new Blob [content], type: 'text/plain;charset=utf-8'
				saveAs blob, "#select.csv"

	Template.gudang.helpers do
		heads: ->
			barang: <[ jenis_barang nama_barang stok_gudang stok_diapotik ]>
			batch: <[ no_batch masuk kadaluarsa beli jual di_gudang di_apotik suplier ]>
			amprah: <[ ruangan peminta meminta penyerah menyerahkan tanggal ]>
			latestAmprah: <[ nama ruangan peminta diminta tanggal ]>
		formType: -> if currentPar \idbarang then \update-pushArray else \insert
		warning: (date) -> switch
			when monthDiff(date) < 2 then \red
			when monthDiff(date) < 7 then \orange
			when monthDiff(date) < 13 then \yellow
			else \green
		gudangs: ->
			aggr = (i) -> _.map i, (j) ->
				reduced = (name) -> _.reduce j.batch, ((sum, n) -> sum + n[name]), 0
				_.assign j, akumulasi:
					digudang: reduced \digudang
					diapotik: reduced \diapotik
			if currentPar \idbarang
				selector = idbarang: currentPar \idbarang
				Meteor.subscribe \coll, \gudang, selector, {}
				.ready! and coll.gudang.findOne!
			else if search!
				byName = nama: $options: '-i', $regex: '.*'+search!+'.*'
				byBatch = idbatch: search!
				selector = $or: [byName, byBatch]
				Meteor.subscribe \coll, \gudang, selector, {}
				.ready! and aggr coll.gudang.find!fetch!
			else
				Meteor.subscribe \coll, \gudang, {}, {}
				.ready! and aggr coll.gudang.find!fetch!
		nearEds: -> Session.get \nearEds
		addAmprah: -> Session.get \addAmprah
		schemaAmprah: -> new SimpleSchema schema.amprah
		latestAmprah: -> Session.get \latestAmprah

	Template.gudang.events do
		'click #showForm': ->
			Session.set \showForm, not Session.get \showForm
		'dblclick #row': -> Router.go \/ + currentRoute! + \/ + @idbarang
		'dblclick #transfer': ->
			self = this
			if roles!farmasi
				MaterializeModal.prompt do
					message: 'Transfer Gudang > Apotek'
					callback: (err, res) -> if res.submit
						Meteor.call \transfer, currentPar(\idbarang), self.idbatch, parseInt res.value
		'click #rmBarang': ->
			self = this
			dialog =
				title: 'Hapus Jenis Obat'
				message: 'Apakah yakin untuk hapus jenis obat ini dari sistem?'
			new Confirmation dialog, (ok) -> if ok
				Meteor.call \rmBarang, self.idbarang
		'click #rmBatch': ->
			self = this
			dialog = title: 'Yakin?', message: 'Hapus 1 batch ini'
			new Confirmation dialog, (ok) -> if ok
				Meteor.call \rmBatch, currentPar(\idbarang), self.idbatch
		'click #nearEds': ->
			Session.set \nearEds, null
			returnable = $ \#returnable .is \:checked
			Meteor.call 'nearEds', returnable, (err, res) ->
				Session.set \nearEds, res if res
		'click #latestAmprah': ->
			Meteor.call \latestAmprah, (err, res) ->
				Session.set \latestAmprah, res if res
		'dblclick #nearEd': ->
			self = this
			dialog = title: 'Karantina?', message: 'Pindahkan ke karantina'
			new Confirmation dialog, (ok) -> if ok
				Meteor.call \returBatch, self
		'click #addAmprah': ->
			unless userGroup \farmasi
				Session.set \addAmprah, not Session.get \addAmprah
		'dblclick #amprah': ->
			if userGroup \farmasi and not @diserah
				self = this
				MaterializeModal.prompt do
					message: 'Jumlah diserahkan'
					callback: (err, res) -> if res.submit
						Meteor.call \amprah, currentPar(\idbarang), self.idamprah, parseInt res.value

	Template.manajemen.helpers do
		users: -> Meteor.users.find!fetch!
		onUser: -> Session.get \onUser
		selRoles: -> <[ petugas admin ]>
		klinik: -> selects.klinik
		schemadokter: -> new SimpleSchema schema.dokter
		schematarif: -> new SimpleSchema schema.tarif
		dokters: ->
			selector = active: true
			options = limit: limit!, skip: page! * limit!
			coll.dokter.find selector, options .fetch!
		tarifs: ->
			selector = active: true
			options = limit: limit!, skip: page! * limit!
			coll.tarif.find selector, options .fetch!

	Template.manajemen.events do
		'submit #userForm': (event) ->
			event.preventDefault!
			onUser = Session.get \onUser
			unless onUser
				doc =
					username: event.target.children.username.value
					password: event.target.children.password.value
				repeat = event.target.children.repeat.value
				if doc.password is repeat
					Meteor.call \newUser, doc
					$ \input .val ''
				else Materialize.toast 'Password tidak mirip', 3000
			else
				role = $ 'input[name="role"]:checked', event.target .0.id
				group = $ 'input[name="group"]:checked', event.target .0.id
				poli = $ 'input[name="poli"]:checked', event.target .0
				theRole = unless poli then role else _.snakeCase poli.id
				Meteor.call \addRole, onUser._id, [theRole], group
		'dblclick #row': -> Session.set \onUser, @
		'dblclick #reset': ->
			self = this
			dialog =
				title: 'Reset Peranan'
				message: 'Anda yakin untuk menghapus semua perannya?'
			new Confirmation dialog, (ok) -> if ok
				Meteor.call \rmRole, self._id
		'click #close': -> sessNull!
		'dblclick #baris': (event) ->
			jenis = event.currentTarget.className
			dialog =
				title: 'Hapus ' + _.startCase jenis
				message: "Yakin untuk menghapus #jenis dari daftar?"
			self = this
			new Confirmation dialog, (ok) -> if ok
				Meteor.call \inactive, jenis, self._id

	Template.login.onRendered ->
		$ \.slider .slider!

	Template.login.events do
		'submit form': (event) ->
			event.preventDefault!
			username = event.target.children.username.value
			password = event.target.children.password.value
			Meteor.loginWithPassword username, password, (err) ->
				if err
					Materialize.toast 'Salah username / password', 3000
				else
					Router.go \/ + (_.keys roles!).0

	Template.pagination.helpers do
		pagins: (name) ->
			limit = Session.get \limit
			length = coll[name].find!fetch!length
			end = (length - (length % limit)) / limit
			[1 to end]

	Template.pagination.events do
		'click #next': -> Session.set \page, 1 + page!
		'click #prev': -> Session.set \page, -1 + page!
		'click #num': (event) ->
			Session.set \page, parseInt event.target.innerText

	Template.report.helpers do
		datas: -> Session.get \laporan

	Template.report.events do
		'click .datepicker': (event, template) ->
			type = event.target.attributes.date.nodeValue
			$ '#'+type .pickadate onSet: (data) ->
				Session.set type+'Date', data.select
				start = Session.get \startDate
				end = Session.get \endDate
				if start and end
					Meteor.call \report, template.data.jenis, start, end, (err, res) ->
						res and Session.set \laporan, res
		'click #export': (event, template) ->
			content = exportcsv.exportToCSV Session.get(\laporan).csv, true, \;
			blob = new Blob [content], type: 'text/plain;charset=utf-8'
			saveAs blob, template.data.jenis+'.csv'
