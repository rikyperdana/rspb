_ = lodash

Router.configure
	layoutTemplate: 'layout'
	loadingTemplate: 'loading'

Router.route '/',
	action: -> this.render 'home'

@schema = {}

schema.regis =
	no_mr: type: Number
	regis: type: Object
	'regis.nama_lengkap': type: String
	'regis.cara_bayar': type: Number
	'regis.tgl_lahir': type: Date
	'regis.tmpt_lahir': type: String
	'regis.kelamin': type: Number
	'regis.agama': type: Number
	'regis.nikah': type: Number
	'regis.edukasi': type: Number
	'regis.darah': type: Number
	'regis.kerja': type: Number
	'regis.alamat': type: String
	'regis.kelurahan': type: String
	'regis.kecamatan': type: String
	'regis.kabupaten': type: String
	'regis.kontak': type: String
	'regis.ayah': type: String
	'regis.ibu': type: String
	'regis.pasangan': type: String
	'regis.petugas': type: String
	'regis.date': type: Date

schema.jalan =
	no_mr: type: Number
	jalan: type: Array
	'jalan.$': type: Object
	'jalan.$.tanggal': type: Date
	'jalan.$.klinik': type: Number
	'jalan.$.diagnosa': type: String
	'jalan.$.tindakan': type: Number
	'jalan.$.dokter': type: Number
	'jalan.$.cara_bayar': type: Number
	'jalan.$.status_bayar': type: Number

	'jalan.$.labor': type: Array
	'jalan.$.labor.$': type: Object
	'jalan.$.labor.$.tanggal': type: Date
	'jalan.$.labor.$.order': type: Number
	'jalan.$.labor.$.jenis': type: Number
	'jalan.$.labor.$.nilai': type: Number
	'jalan.$.labor.$.satuan': type: Number
	'jalan.$.labor.$.hasil': type: String
	'jalan.$.labor.$.harga': type: Number

	'jalan.$.radio': type: Array
	'jalan.$.radio.$': type: Object
	'jalan.$.radio.$.tanggal': type: Date
	'jalan.$.radio.$.order': type: Number
	'jalan.$.radio.$.jenis': type: Number
	'jalan.$.radio.$.hasil': type: String
	'jalan.$.radio.$.harga': type: Number

	'jalan.$.obat': type: Array
	'jalan.$.obat.$': type: Object
	'jalan.$.obat.$.tanggal': type: Date
	'jalan.$.obat.$.nama': type: Number
	'jalan.$.obat.$.satuan': type: Number
	'jalan.$.obat.$.aturan': type: Object
	'jalan.$.obat.$.aturan.kali': type: Number
	'jalan.$.obat.$.aturan.dosis': type: Number
	'jalan.$.obat.$.aturan.bentuk': type: Number
	'jalan.$.obat.$.jumlah': type: Number
	'jalan.$.obat.$.harga': type: Number
	'jalan.$.obat.$.subtotal': type: Number

	'jalan.$.total': type: Object
	'jalan.$.total.labor': type: Number
	'jalan.$.total.radio': type: Number
	'jalan.$.total.obat': type: Number
	'jalan.$.total.semua': type: Number

@coll = new Meteor.Collection 'coll'
coll.allow
	insert: -> true
	update: -> true
	remove: -> true

makeRoute = (modul) ->
	Router.route '/'+modul+'/:no_mr?',
		name: modul
		action: -> this.render 'modul'

makeRoute key for key, val of schema

Router.route '/bayar',
	action: -> this.render 'modul'
