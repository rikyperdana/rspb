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
		formDoc: -> Session.get 'formDoc'
		rupiah: (val) -> 'Rp ' + val
		look: (option, value, field) ->
			find = _.find selects[option], (i) -> i.value is value
			find[field]
		pasiens: ->
			if currentMR()
				selector = no_mr: currentMR()
				options = fields: no_mr: 1, regis: 1
				if currentRoute() is 'bayar' or 'jalan' or 'labor' or 'radio' or 'obat'
					options.fields.jalan = 1
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
				if currentRoute() is 'bayar' or 'jalan' or 'labor' or 'radio' or 'obat'
					options.fields.jalan = 1
				sub = Meteor.subscribe 'coll', selector, options
				if sub.ready() then coll.find().fetch()

	Template.modul.events
		'click #addPasien': ->
			Session.set 'addPasien', not Session.get 'addPasien'
			if Session.get('formDoc') then Session.set 'formDoc', null
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
			dialog =
				title: 'Konfirmasi Pembayaran'
				message: 'Apakah yakin tagihan ini sudah dibayar?'
			new Confirmation dialog, (ok) ->
				if ok then Meteor.call 'bayar', 'jalan', no_mr, idbayar
		'dblclick #labor': (event) ->
			no_mr = event.target.attributes.pasien.nodeValue
			idbayar = event.target.attributes.idbayar.nodeValue
			idlabor = event.target.attributes.idlabor.nodeValue
			hasil = prompt 'Berapa nilai nya?'
			if hasil then Meteor.call 'labor', no_mr, idbayar, idlabor, hasil
		'dblclick #obat': (event) ->
			no_mr = event.target.attributes.pasien.nodeValue
			idbayar = event.target.attributes.idbayar.nodeValue
			idobat = event.target.attributes.idobat.nodeValue
			serah = confirm 'Serahkan obat?'
			if serah then Meteor.call 'obat', no_mr, idbayar, idobat, true
		'dblclick #radio': (event) ->
			no_mr = event.target.attributes.pasien.nodeValue
			idbayar = event.target.attributes.idbayar.nodeValue
			idradio = event.target.attributes.idradio.nodeValue
			arsip = prompt 'Kode arsip radiologi?'
			if arsip then Meteor.call 'radio', no_mr, idbayar, idradio, arsip
		'click .modal-trigger': (event) ->
			if this.idbayar then Session.set 'formDoc', this
			$('#preview').modal 'open'

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

	modForm = (doc) -> if currentRoute() is 'jalan'
		randomId = -> Math.random().toString(36).slice(2)
		doc.idbayar = randomId()
		totalLabor = 0; totalObat = 0; totalRadio = 0;
		if doc.labor
			for i in doc.labor
				i.idlabor = randomId()
				i.harga = (_.find selects.orders, (j) -> j.value is i.order).harga
				totalLabor += i.harga
		if doc.obat
			for i in doc.obat
				i.idobat = randomId()
				i.harga = (_.find selects.obats, (j) -> j.value is i.nama).harga
				i.subtotal = i.harga * i.jumlah
				totalObat += i.subtotal
		if doc.radio
			for i in doc.radio
				i.idradio = randomId()
				i.harga = (_.find selects.orders_rad, (j) -> j.value is i.order).harga
				totalRadio += i.harga
		doc.total =
			labor: totalLabor
			obat: totalObat
			radio: totalRadio
			semua: totalLabor + totalObat + totalRadio
		doc

	AutoForm.addHooks 'formPasien',
		before:
			'update-pushArray': (doc) ->
				ask = confirm 'Tambah data'
				if ask is true
					this.result modForm doc
				else
					this.result false
		formToDoc: (doc) ->
			Session.set 'formDoc', modForm doc
			doc
