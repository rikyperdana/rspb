if Meteor.isClient

	# SimpleSchema.debug = true
	currentRoute = -> Router.current().route.getName()
	currentPar = (param) -> Router.current().params[param]
	
	@modForm = (doc, idbayar) -> if currentRoute() is 'jalan'
		randomId = -> Math.random().toString(36).slice(2)
		doc.tanggal = new Date()
		doc.idbayar = if idbayar then idbayar else randomId()
		doc.jenis = currentRoute()
		total = tindakan: 0, labor: 0, radio: 0, obat: 0
		_.map ['tindakan', 'labor', 'radio'], (i) ->
			if doc[i] then for j in doc[i]
				j['id'+i] = randomId()
				find = _.find coll.tarif.find().fetch(), (k) -> k._id is j.nama
				j.harga = find.harga
				total[i] += j.harga
		if doc.obat
			for i in doc.obat
				i.idobat = randomId()
				find = _.find coll.gudang.find().fetch(), (j) -> j._id is i.nama
				i.harga = find.batch[find.batch.length-1].jual
				i.subtotal = i.harga * i.jumlah
				total.obat += i.subtotal
		doc.total =
			tindakan: total.tindakan
			labor: total.labor
			radio: total.radio
			obat: total.obat
		doc.total.semua = doc.total.tindakan + doc.total.labor + doc.total.radio + doc.total.obat
		doc.billRegis = true if doc.total.semua > 0 or doc.cara_bayar isnt 1
		doc.status_bayar = true if doc.total.semua > 0 and doc.cara_bayar isnt 1
		doc

	closeForm = ->
		Session.set 'showForm', null
		Session.set 'formDoc', null

	AutoForm.addHooks 'formPasien',
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

