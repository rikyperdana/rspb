if Meteor.isClient

	@modForm = (doc, idbayar) -> (currentRoute! is \jalan) and _.assign doc,
		tanggal: new Date!
		idbayar: idbayar or randomId!
		jenis: currentRoute!
		karcis: if doc.klinik
			val = +(.label) _.find selects.karcis, -> it.value is doc.klinik
			val -= 10 if coll.pasien.findOne!rawat?0? unless val is 0
			val * 1000
		billRegis: (or false) ors arr =
			doc.anamesa_perawat? or doc.anamesa_dokter?
			doc.cara_bayar isnt 1
			doc.obat? and 0 is doc.total?semua
			doc.billRegis
		status_bayar: (or false) ors arr =
			doc.obat? and (0 is doc.total?semua)
			(doc.total?semua > 0) and (doc.cara_bayar isnt 1)
			doc.status_bayar
		spm: moment!diff (Session.get \begin), \minutes
		petugas: Meteor.userId!
		nobill: +(_.toString Date.now! .substr 7, 13)
		total: do ->
			arr = <[ tindakan labor radio ]>
			tlr = _.zipObject arr, arr.map (i) -> if doc[i]
				_.sum _.map that, (j) ->
					(?harga) coll.tarif.find!fetch!find (k) ->
						k._id is j.nama
			obt = if doc.obat then obat: _.sum _.map that, -> 0
			_.merge tlr, obt, semua: _.sum _.values _.merge tlr, obt

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

	AutoForm.addHooks \formAmprah,
		before: insert: (doc) -> @result _.assign doc,
			peminta: Meteor.userId!
			tanggal_minta: new Date!
