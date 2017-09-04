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
	'regis.tgl_lahir': type: Date
	'regis.tmpt_lahir': type: String
	'regis.cara_bayar': type: Number, autoform: options: selects.cara_bayar, type: 'select-radio-inline'
	'regis.kelamin': type: Number, autoform: options: selects.kelamin, type: 'select-radio-inline'
	'regis.agama': type: Number, autoform: options: selects.agama, type: 'select-radio-inline'
	'regis.nikah': type: Number, autoform: options: selects.nikah, type: 'select-radio-inline'
	'regis.pendidikan': type: Number, autoform: options: selects.pendidikan, type: 'select-radio-inline'
	'regis.darah': type: Number, autoform: options: selects.darah, type: 'select-radio-inline'
	'regis.pekerjaan': type: Number, autoform: options: selects.pekerjaan, type: 'select-radio-inline'
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
	'jalan.$.idbayar':
		type: Number
		autoform: type: 'hidden'
		autoValue: -> Math.random().toString(36).slice(2)
	'jalan.$.tanggal': type: Date
	'jalan.$.cara_bayar': type: Number, autoform: options: selects.cara_bayar, type: 'select-radio-inline'
	'jalan.$.klinik': type: Number, autoform: options: selects.klinik, type: 'select-radio-inline'
	'jalan.$.diagnosa': type: String
	'jalan.$.tindakan': type: Number
	'jalan.$.dokter': type: Number
	'jalan.$.status_bayar': type: Number, optional: true, autoform: type: 'hidden'

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
	'jalan.$.total.labor': type: Number, autoform: disabled: true
	'jalan.$.total.radio': type: Number, autoform: disabled: true
	'jalan.$.total.obat': type: Number, autoform: disabled: true
	'jalan.$.total.semua': type: Number, autoform: disabled: true

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
