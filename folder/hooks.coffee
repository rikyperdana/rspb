if Meteor.isClient

	@modForm = (doc, idbayar) -> if currentRoute() is 'jalan'
		doc.tanggal = new Date()
		doc.idbayar = if idbayar then idbayar else randomId()
		doc.jenis = currentRoute()
		doc.total = tindakan: 0, labor: 0, radio: 0, obat: 0
		_.map ['tindakan', 'labor', 'radio'], (i) ->
			if doc[i] then for j in doc[i]
				j['id'+i] = randomId()
				find = _.find coll.tarif.find().fetch(), (k) -> k._id is j.nama
				j.harga = find.harga
				doc.total[i] += j.harga
		for i in doc.obat?
			i.idobat = randomId()
			find = _.find coll.gudang.find().fetch(), (k) -> k._id is i.nama
			i.harga = 0 # find.batch[find.batch.length-1].jual
			i.subtotal = i.harga * i.jumlah
			doc.total.obat += i.subtotal
		doc.total.semua = _.reduce _.values(doc.total), (acc, val) -> acc + val
		doc.billRegis = true if doc.anamesa_perawat or doc.anamesa_dokter
		doc.billRegis = true if doc.total.semua > 0 or doc.cara_bayar isnt 1
		doc.status_bayar = true if doc.total.semua > 0 and doc.cara_bayar isnt 1
		if doc.obat and 0 is doc.total.semua
			doc.billRegis = true
			doc.status_bayar = true
		begin = Session.get 'begin'; stop = moment()
		doc.spm = stop.diff begin, 'minutes'
		doc.petugas = Meteor.userId()
		doc.nobill = parseInt _.toString(Date.now()).substr 7, 13
		doc

	AutoForm.addHooks 'formPasien',
		before:
			'update-pushArray': (doc) ->
				formDoc = Session.get 'formDoc'
				if formDoc then Meteor.call 'rmRawat', currentPar('no_mr'), formDoc.idbayar
				this.result modForm doc
		after:
			insert: -> sessNull()
			'update-pushArray': (err, res) ->
				sessNull()
				if res then Meteor.call 'pindah', currentPar 'no_mr'
		formToDoc: (doc) ->
			Session.set 'preview', modForm doc
			if currentRoute() is 'regis'
				Meteor.call 'patientExist', doc.no_mr, (err, res) -> if res
					Materialize.toast 'No MR sudah dipakai pasien yang lain', 3000
					$('input[name="no_mr"]').val ''
			doc

	AutoForm.addHooks 'formGudang',
		before:
			insert: (doc) ->
				doc.idbarang = randomId()
				doc.batch[0].idbatch = randomId()
				this.result doc
			'update-pushArray': (doc) ->
				this.result _.assign doc, idbatch: randomId()

	AutoForm.addHooks 'formAmprah',
		before: 'update-pushArray': (doc) ->
			this.result _.assign doc,
				peminta: Meteor.userId()
				tanggal: new Date()
				ruangan: (_.keys roles())[0]
