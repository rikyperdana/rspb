if Meteor.isClient

	Router.onBeforeAction ->
		unless Meteor.userId! then @render \login else @next!
	Router.onAfterAction ->
		sessNull! and Router.go \/ unless currentRoute! in
			_.uniq _.flatMap roles!, (i, j) ->
				(.list) _.find rights, -> it.group is j

	globalHelpers =
		rupiah: rupiah
		zeros: zeros
		userRole: userRole
		userGroup: userGroup
		currentPar: currentPar
		coll: -> coll
		modules: -> modules
		reverse: _.reverse
		stringify: JSON.stringify
		startCase: _.startCase
		userName: _.startCase userName
		showForm: -> Session.get \showForm
		schema: -> new SimpleSchema schema[currentRoute!]
		hari: -> it and moment it .format 'D MMM YYYY'
		currentRoute: (name) -> unless name then currentRoute! else currentRoute! is name
		sortBy: (arr, sel, sort) -> _.sortBy arr, -> -it.tanggal.getTime!
		isTrue: (a, b) -> a is b
		isFalse: (a, b) -> a isnt b
		look: (option, value, field) -> _.startCase look(option, value)?[field]
		look2: (option, value, field) -> _.startCase look2(option, value)?[field]
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
				find = rights.find -> it.group is j
				_.initial find.list.map (k) ->
					modules.find -> it.name is k
		navTitle: ->
			find = modules.find -> it.name is currentRoute!
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
			rawat: <[ tanggal klinik cara_bayar bayar_pendaftaran status_bayar cek ]>
			fisik: <[ tekanan_darah nadi suhu pernapasan berat tinggi lila ]>
			previewDokter: <[ Tindakan Dokter Harga ]>
			previewLabor: <[ Grup Order Hasil ]>
			previewRadio: <[ Order Arsip ]>
			previewObat: <[ Nama Dosis Bentuk Kali Jumlah ]>
		formType: ->
			if currentRoute! is \regis
				if currentPar \no_mr then \update else \insert
			else \update-pushArray
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
			else unless (_.first _.split Meteor.user!username, \.) in <[ dr drg ]>
				arr[2 to arr.length]
		roleFilter: (arr) -> _.reverse arr.filter ->
			it.klinik is (.value) selects.klinik.find ->
				it.label is _.startCase roles!jalan.0
		userPoli: -> roles!jalan
		selPol: -> roles!?jalan.map (i) ->
			selects.klinik.find (j) -> i is _.snakeCase j.label
		pasiens: ->
			if currentPar \no_mr
				selector = no_mr: +that
				options = fields: no_mr: 1, regis: 1
				options.fields.rawat = 1 if currentRoute! in
					<[ bayar jalan labor radio obat ]>
				Meteor.subscribe \coll, \pasien, selector, options
				.ready! and coll.pasien.findOne!
			else if search!
				byName = 'regis.nama_lengkap': $options: \-i, $regex: '.*'+search!+'.*'
				byNoMR = no_mr: +search!
				selector = $or: [byName, byNoMR], no_mr: $ne: NaN
				options = fields: no_mr: 1, regis: 1
				Meteor.subscribe \coll, \pasien, selector, options
				.ready! and coll.pasien.find!fetch!
			else if roles!?jalan
				kliniks = roles!jalan.map (i) ->
					(.value) _.find selects.klinik, (j) -> i is _.snakeCase j.label
				selector = rawat: $elemMatch:
					klinik: $in: kliniks
					tanggal: $gt: new Date (new Date!)getDate!-2
				Meteor.subscribe \coll, \pasien, selector, {} .ready! and do ->
					filter = _.filter coll.pasien.find!fetch!, (i) ->
						selPol = Session.get \selPol
						a = -> i.rawat[i.rawat.length-1]klinik in kliniks
						b = -> not i.rawat[i.rawat.length-1]total?semua
						c = -> i.rawat[i.rawat.length-1]klinik is selPol
						if selPol then b! and c! else a! and b!
					_.sortBy filter, -> it.rawat[it.rawat.length-1]tanggal
			else if currentRoute! is \bayar
				selector = rawat: $elemMatch: $or: ['status_bayar': $ne: true]
				Meteor.subscribe \coll, \pasien, selector, {}
				.ready! and coll.pasien.find!fetch!
			else if currentRoute! in <[ labor radio obat ]>
				selSub = rawat: $elemMatch:
					'status_bayar': true, "#{currentRoute!}":
						$exists: true, $elemMatch: hasil: $exists: false
				Meteor.subscribe \coll, \pasien, selSub, {}
				.ready! and coll.pasien.find!fetch!

	Template.pasien.events do
		'click #showForm': ->
			unless userGroup \jalan and not Session.get \formDoc
				Session.set \showForm, not Session.get \showForm
				if userGroup \regis then Session.set \formDoc, null
				Meteor.subscribe \coll, \gudang, {}, {}
				Session.set \begin, new Date!
				(Meteor.setTimeout _, 3000) later = ->
					$ \.autoform-remove-item .trigger \click
					if currentRoute! is \jalan
						for i in <[ cara_bayar klinik rujukan ]>
							$ 'div[data-schema-key="'+i+'"]' .prepend tag \p, _.startCase i
							if formDoc!
								$ 'select[name="'+i+'"]'
								.val that[i] .material_select!
						for i in [\anamesa_perawat]
							$ 'textarea[name="'+i+'"]' .val formDoc!?[i]
					list = <[ cara_bayar kelamin agama nikah pendidikan darah pekerjaan ]>
					if currentRoute! is \regis
						for i in list
							$ 'div[data-schema-key="regis.'+i+'"]' .prepend tag \p, _.startCase i
						arr = _.compact _.map schema.regis, (i, j) -> (.1) _.split j, \.
						for i in arr
							$ '[name="regis.'+i+'"]' .parents \div.row .removeClass \row .addClass 'col m6'
						$ '.card-content' .addClass \row
		'dblclick #row': ->
			Router.go "/#{currentRoute!}/#{@no_mr}"
		'click #close': -> sessNull!; Router.go currentRoute!
		'click #card': ->
			dialog = title: 'Cetak Kartu', message: 'Yakin untuk cetak kartu ini?'
			new Confirmation dialog, -> it and makePdf.card!
		'click #consent': ->
			dialog = title: 'General Consent', message: 'Yakin untuk dicetak?'
			new Confirmation dialog, -> it and makePdf.consent!
		'dblclick #bill': (event) ->
			nodes = <[ pasien idbayar karcis ]>map ->
				event.target.attributes[it]nodeValue
			dialog =
				title: 'Pembayaran Pendaftaran'
				message: 'Apakah yakin pasien sudah membayar?'
			new Confirmation dialog, -> if it
				if nodes.1
					Meteor.call \billRegis, ...nodes[0 to 1], true
					makePdf.payRegCard ...nodes[0 to 2], \...
				else
					Meteor.call \billCard, nodes.0, false
					makePdf.payRegCard 10000, 'Sepuluh Ribu Rupiah'
		'dblclick #bayar': (event) ->
			[no_mr, idbayar] = <[ pasien idbayar ]>map ->
				event.target.attributes[it]nodeValue
			dialog =
				title: 'Konfirmasi Pembayaran'
				message: 'Apakah yakin tagihan ini sudah dibayar?'
			new Confirmation dialog, -> if it
				Meteor.call \bayar, no_mr, idbayar
				pasien = coll.pasien.findOne no_mr: +no_mr
				doc = pasien.rawat.find -> it.idbayar is idbayar
				makePdf.payRawat no_mr, doc
		'dblclick #request': (event) ->
			nodes = <[ pasien idbayar jenis idjenis ]>map ->
				event.target.attributes[it]nodeValue
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
			headers = <[ pasien id_bayar jenis id_request no_batch jumlah ]>
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
			new Confirmation dialog, -> if it
				Meteor.call \rmRawat, currentPar(\no_mr), self.idbayar
		'change #selPol': (event) ->
			Session.set \selPol, +event.target.id
		'click #rmPasien': ->
			dialog =
				title: 'Hapus Pasien'
				message: 'Apakah yakin untuk menghapus pasien?'
			new Confirmation dialog, -> if it
				Meteor.call \rmPasien, currentPar \no_mr
				Router.go \/ + currentRoute!

	Template.import.events do
		'change :file': (event, template) ->
			Papa.parse event.target.files.0, header: true, step: (result) ->
				data = result.data.0
				if currentRoute! is \regis
					selector = no_mr: +data.no_mr
					modifier = regis:
						nama_lengkap: _.startCase data.nama_lengkap
						alamat: _.startCase data.alamat if data.alamat
						agama: +that if data.agama
						ayah: _.startCase that if data.ayah
						nikah: +that if data.nikah
						pekerjaan: +that if data.pekerjaan
						pendidikan: +that if data.pendidikan
						tgl_lahir: new Date that if Date.parse data.tgl_lahir
						tmpt_kelahiran: _.startCase that if data.tmpt_kelahiran
					Meteor.call \import, \pasien, selector, modifier
				else if currentRoute! is \manajemen
					if data.tipe
						selector = nama: data.nama
						modifier =
							tipe: +data.tipe
							poli: +data.poli
							active: true
						Meteor.call \import, \dokter, selector, modifier
					else if data.harga
						selector = nama: _.snakeCase data.nama
						modifier =
							harga: +data.harga
							jenis: _.snakeCase data.jenis
							grup: _.startCase that if data.grup
							active: true
						Meteor.call \import, \tarif, selector, modifier
					else if data.password
						Meteor.call \newUser, data
						Meteor.call \addRole, data.username, [data.role], data.group
				else if currentRoute! is \farmasi
					selector = nama: data.nama
					modifier =
						idbarang: randomId!
						jenis: +that if data.jenis
						satuan: +that if data.satuan
						batch: [
							idbatch: randomId!
							nobatch: that if data.nobatch
							digudang: +data.digudang or 0
							diapotik: +data.diapotik or 0
							beli: +data.beli or 0
							jual: +data.jual or 0
							masuk: new Date that if Date.parse data.masuk
							kadaluarsa: new Date that if Date.parse data.kadaluarsa
							merek: that if data.merek
							suplier: that if data.suplier
							pengadaan: +that if data.pengadaan
							anggaran: that if data.anggaran
						]
					data.nama and Meteor.call \import, \gudang, selector, modifier, \batch

	Template.export.onRendered ->
		$ 'select#export' .material_select!

	Template.export.events do
		'click #export': ->
			select = $ 'select#export' .val!
			Meteor.call \export, select, (err, content) -> if content
				blob = new Blob [content], type: 'text/plain;charset=utf-8'
				saveAs blob, \#select.csv

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
			aggr = -> it.map (i) ->
				reduced = (name) -> i.batch.reduce ((sum, n) -> sum + n[name]), 0
				_.assign i, akumulasi:
					digudang: reduced \digudang
					diapotik: reduced \diapotik
			if currentPar \idbarang
				selector = idbarang: that
				Meteor.subscribe \coll, \gudang, selector, {}
				.ready! and coll.gudang.findOne!
			else if search!
				selector = $or: arr =
					idbatch: that
					nama: $options: '-i', $regex: ".*#{that}.*"
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
		'dblclick #row': -> Router.go "/#{currentRoute!}/#{@idbarang}"
		'click #rmBarang': ->
			self = this
			dialog =
				title: 'Hapus Jenis Obat'
				message: 'Apakah yakin untuk hapus jenis obat ini dari sistem?'
			new Confirmation dialog, -> if it
				Meteor.call \rmBarang, self.idbarang
		'click #rmBatch': ->
			self = this
			dialog = title: 'Yakin?', message: 'Hapus 1 batch ini'
			new Confirmation dialog, -> if it
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
			new Confirmation dialog, -> it and Meteor.call \returBatch, self
		'click #addAmprah': ->
			Session.set \addAmprah, not Session.get \addAmprah
		'dblclick #amprah': ->
			if userGroup \farmasi and not @diserah
				self = this
				MaterializeModal.prompt do
					message: 'Jumlah diserahkan'
					callback: (err, res) -> if res.submit
						Meteor.call \amprah, currentPar(\idbarang), self.idamprah, +res.value, (err2, res2) ->
							res2 and Meteor.call \transfer, currentPar(\idbarang), +res.value, (err3, res3) ->
								res3 and MaterializeModal.message title: 'Transferkan Barang', message: JSON.stringify res3

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
			unless Session.get(\onUser)
				doc =
					username: event.target.children.username.value
					password: event.target.children.password.value
				repeat = event.target.children.repeat.value
				if doc.password is repeat
					Meteor.call \newUser, doc
					$ \input .val ''
				else Materialize.toast 'Password tidak mirip', 3000
			else
				[role, group, poli] = <[ role group poli ]>map (i) ->
					$ "input[name=#i]:checked", event.target .0.id
				theRole = unless poli then role else _.snakeCase poli.id
				Meteor.call \addRole, onUser._id, [theRole], group
		'dblclick #row': -> Session.set \onUser, @
		'dblclick #reset': ->
			self = this
			dialog =
				title: 'Reset Peranan'
				message: 'Anda yakin untuk menghapus semua perannya?'
			new Confirmation dialog, -> if it
				Meteor.call \rmRole, self._id
		'click #close': -> sessNull!
		'dblclick #baris': (event) ->
			jenis = event.currentTarget.className
			dialog =
				title: 'Hapus ' + _.startCase jenis
				message: "Yakin untuk menghapus #jenis dari daftar?"
			self = this
			new Confirmation dialog, -> if it
				Meteor.call \inactive, jenis, self._id

	Template.login.onRendered ->
		$ \.slider .slider!

	Template.login.events do
		'submit form': (event) ->
			event.preventDefault!
			username = event.target.children.username.value
			password = event.target.children.password.value
			Meteor.loginWithPassword username, password, (err) ->
				if err then Materialize.toast 'Salah username / password', 3000
				else Router.go \/ + (_.keys roles!)0

	Template.pagination.helpers do
		pagins: (name) ->
			limit = Session.get \limit
			length = coll[name]find!fetch!length
			end = (length - (length % limit)) / limit
			[1 to end]

	Template.pagination.events do
		'click #next': -> Session.set \page, 1 + page!
		'click #prev': -> Session.set \page, -1 + page!
		'click #num': (event) ->
			Session.set \page, +event.target.innerText

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
