if Meteor.isClient

	# SimpleSchema.debug = true
	currentRoute = -> Router.current().route.getName()
	currentPar = (param) -> Router.current().params[param]
	
	@modForm = (doc, idbayar) -> if currentRoute() is 'jalan'
		randomId = -> Math.random().toString(36).slice(2)
		doc.tanggal = new Date()
		doc.idbayar = if idbayar then idbayar else randomId()
		doc.jenis = currentRoute()
		totalTindakan = 0; totalLabor = 0; totalObat = 0; totalRadio = 0;
		if doc.tindakan
			for i in doc.tindakan
				i.idtindakan = randomId()
				i.harga = (_.find selects.tindakan, (j) -> j.value is i.nama).harga
				totalTindakan += i.harga
		if doc.labor
			for i in doc.labor
				i.idlabor = randomId()
				i.harga = (_.find selects.labor, (j) -> j.value is i.nama).harga
				totalLabor += i.harga
		if doc.obat
			for i in doc.obat
				i.idobat = randomId()
				i.harga = (_.find coll.gudang.find().fetch(), (j) -> j.nama is i.nama).harga
				i.subtotal = i.harga * i.jumlah
				totalObat += i.subtotal
		if doc.radio
			for i in doc.radio
				i.idradio = randomId()
				i.harga = (_.find selects.radio, (j) -> j.value is i.nama).harga
				totalRadio += i.harga
		doc.total =
			tindakan: totalTindakan
			labor: totalLabor
			obat: totalObat
			radio: totalRadio
			# semua: totalTindakan + totalLabor + totalObat + totalRadio
		if doc.cara_bayar isnt 1 then doc.total.tindakan += 30000
		doc.total.semua = totalTindakan + totalLabor + totalObat + totalRadio
		doc.billRegis = true if doc.total.semua > 0 or doc.cara_bayar isnt 1
		doc.status_bayar = true if doc.total.semua > 0 and doc.cara_bayar isnt 1
		# if doc.cara_bayar isnt 1 then doc.total.semua += 30000
		doc

	closeForm = ->
		Session.set 'showForm', null
		Session.set 'formDoc', null

	AutoForm.addHooks null,
		before:
			'update-pushArray': (doc) ->
				formDoc = Session.get 'formDoc'
				if formDoc then Meteor.call 'rmRawat', currentPar('no_mr'), formDoc.idbayar
				this.result modForm doc
		after:
			insert: -> closeForm()
			'update-pushArray': -> closeForm()
		formToDoc: (doc) ->
			Session.set 'preview', modForm doc
			doc

