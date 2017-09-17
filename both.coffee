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
	'jalan.$.idbayar': type: String, autoform: type: 'hidden'
	'jalan.$.tanggal': type: Date
	'jalan.$.cara_bayar': type: Number, autoform: options: selects.cara_bayar, type: 'select-radio-inline'
	'jalan.$.klinik': type: Number, autoform: options: selects.klinik, type: 'select-radio-inline'
	'jalan.$.diagnosa': type: String
	'jalan.$.tindakan': type: Number
	'jalan.$.dokter': type: Number
	'jalan.$.status_bayar': type: Number, optional: true, autoform: type: 'hidden'

	'jalan.$.labor': type: Array, optional: true
	'jalan.$.labor.$': type: Object
	'jalan.$.labor.$.order': type: Number, autoform: options: selects.orders, type: 'universe-select'
	'jalan.$.labor.$.normal': type: Number, optional: true, autoform: type: 'hidden'
	'jalan.$.labor.$.satuan': type: Number, optional: true, autoform: type: 'hidden'
	'jalan.$.labor.$.hasil': type: Number, decimal: true, optional: true, autoform: type: 'hidden'
	'jalan.$.labor.$.harga': type: Number, optional: true, autoform: type: 'hidden'

	'jalan.$.radio': type: Array, optional: true
	'jalan.$.radio.$': type: Object
	'jalan.$.radio.$.order': type: Number
	'jalan.$.radio.$.hasil': type: String, optional: true, autoform: type: 'hidden'
	'jalan.$.radio.$.harga': type: Number, optional: true, autoform: type: 'hidden'

	'jalan.$.obat': type: Array, optional: true
	'jalan.$.obat.$': type: Object
	'jalan.$.obat.$.nama': type: Number
	'jalan.$.obat.$.satuan': type: Number
	'jalan.$.obat.$.aturan': type: Object
	'jalan.$.obat.$.aturan.kali': type: Number
	'jalan.$.obat.$.aturan.dosis': type: Number
	'jalan.$.obat.$.aturan.bentuk': type: Number
	'jalan.$.obat.$.jumlah': type: Number
	'jalan.$.obat.$.harga': type: Number, optional: true, autoform: type: 'hidden'
	'jalan.$.obat.$.subtotal': type: Number, optional: true, autoform: type: 'hidden'

	'jalan.$.total': type: Object, optional: true, autoform: type: 'hidden'
	'jalan.$.total.labor': type: Number, optional: true
	'jalan.$.total.radio': type: Number, optional: true
	'jalan.$.total.obat': type: Number, optional: true
	'jalan.$.total.semua': type: Number, optional: true

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
makeRoute i for i in ['bayar', 'labor']

###
Router.route '/bayar',
	action: -> this.render 'modul'
###