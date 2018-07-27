if Meteor.isClient

	@modForm = (doc, idbayar) -> if currentRoute! is \jalan then _.assign doc,
		tanggal: new Date!
		idbayar: idbayar or randomId!
		jenis: currentRoute!
		karcis: if doc.klinik
			val = +(.label) _.find selects.karcis, -> it.value is doc.klinik
			val -= 10 if coll.pasien.findOne!rawat?0? unless val is 0
			val * 1000
		billRegis: do ->
			a = -> doc.anamesa_perawat? or doc.anamesa_dokter?
			b = -> doc.total?semua > 0 and doc.cara_bayar isnt 1
			c = -> doc.obat? and 0 is doc.total?semua
			doc.billRegis or a! or b! or c!
		status_bayar: do ->
			a = -> doc.total?semua > 0 and doc.cara_bayar isnt 1
			b = -> doc.obat and 0 is doc.total?semua
			doc.status_bayar or a! or b!
		spm: do ->
			begin = Session.get \begin; stop = moment!
			stop.diff begin, \minutes
		petugas: Meteor.userId!
		nobill: +(_.toString Date.now! .substr 7, 13)
		total: do ->
			arr = <[ tindakan labor radio ]>
			tlr = _.zipObject arr, _.map arr, (i) -> if doc[i]
				_.sum _.map that, (j) -> (.harga) _.find coll.tarif.find!fetch!,
				(k) -> k._id is j.nama
			obt = if doc.obat then obat: _.sum _.map that, (i) ->
				0 # (.harga) _.find coll.gudang.find!fetch!, (j) -> j._id is i.nama
			_.merge tlr, obt


	AutoForm.addHooks \formPasien,
		before:
			'update-pushArray': (doc) ->
				formDoc = Session.get \formDoc
				if formDoc then Meteor.call \rmRawat, currentPar(\no_mr), formDoc.idbayar
				@result modForm doc
		after:
			insert: -> sessNull!
			'update-pushArray': (err, res) ->
				sessNull! and res and Meteor.call \pindah, currentPar \no_mr
		formToDoc: (doc) ->
			Session.set \preview, modForm doc
			if currentRoute(\regis)
				Meteor.call \patientExist, doc.no_mr, (err, res) -> if res
					Materialize.toast 'No MR sudah dipakai pasien yang lain', 3000
					$ 'input[name="no_mr"]' .val ''
			doc

	AutoForm.addHooks \formGudang,
		before:
			insert: (doc) -> @result _.assign doc,
				idbarang: randomId!
			'update-pushArray': (doc) ->
				@result _.assign doc, idbatch: randomId!

	AutoForm.addHooks \formAmprah,
		before: 'update-pushArray': (doc) ->
			@result _.assign doc,
				idamprah: randomId!
				peminta: Meteor.userId!
				tanggal: new Date!
				ruangan: _.keys roles! .0
