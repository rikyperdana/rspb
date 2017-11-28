@_ = lodash

Router.configure
	layoutTemplate: 'layout'
	loadingTemplate: 'loading'

Router.route '/',
	action: -> this.render 'home'

@coll = {}
@schema = {}

randomId = -> Math.random().toString(36).substring(7)

schema.regis =
	no_mr: type: Number
	regis: type: Object
	'regis.nama_lengkap': type: String
	'regis.tgl_lahir': type: Date, autoform: type: 'pickadate', pickadateOptions: selectYears: 150, selectMonths: true
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
	'regis.petugas':
		type: String
		autoform: type: 'hidden'
		autoValue: -> if Meteor.isClient then Meteor.userId()
	'regis.date':
		type: Date
		autoform: type: 'hidden'
		autoValue: -> new Date
	'regis.billCard': type: Boolean, optional: true, autoform: type: 'hidden'

schema.tindakan =
	idtindakan: type: String, optional: true, autoform: type: 'hidden'
	diagnosa: type: String
	nama: type: Number, autoform: options: selects.tindakan
	dokter: type: Number, autoform: options: selects.dokter
	harga: type: Number, optional: true, autoform: type: 'hidden'

schema.labor =
	idlabor: type: String, optional: true, autoform: type: 'hidden'
	nama: type: Number, autoform: options: selects.labor
	harga: type: Number, optional: true, autoform: type: 'hidden'
	hasil: type: String, optional: true, autoform: type: 'hidden'

schema.radio =
	idradio: type: String, optional: true, autoform: type: 'hidden'
	nama: type: Number, autoform: options: selects.radio
	harga: type: Number, optional: true, autoform: type: 'hidden'
	hasil: type: String, optional: true, autoform: type: 'hidden'

schema.obat =
	idobat: type: String, optional: true, autoform: type: 'hidden'
	nama: type: String, autoform: options: selects.obat
	aturan: type: Object
	'aturan.kali': type: Number
	'aturan.dosis': type: Number
	'aturan.bentuk': type: Number, autoform: options: selects.bentuk
	jumlah: type: Number
	harga: type: Number, optional: true, autoform: type: 'hidden'
	subtotal: type: Number, optional: true, autoform: type: 'hidden'
	hasil: type: String, optional: true, autoform: type: 'hidden'

schema.rawat =
	no_mr: type: Number
	rawat: type: Array
	'rawat.$': type: Object
	'rawat.$.tanggal': type: Date, autoform: type: 'hidden'
	'rawat.$.idbayar': type: String, optional: true, autoform: type: 'hidden'
	'rawat.$.jenis': type: String, optional: true, autoform: type: 'hidden'
	'rawat.$.cara_bayar': type: Number, autoform: options: selects.cara_bayar, type: 'select-radio-inline'
	'rawat.$.klinik': type: Number, autoform: options: selects.klinik, type: 'select-radio-inline'
	'rawat.$.billRegis': type: Boolean, optional: true, autoform: type: 'hidden'
	'rawat.$.status_bayar': type: Boolean, optional: true, autoform: type: 'hidden'
	'rawat.$.anamesa': type: String, optional: true
	'rawat.$.tindakan': type: [new SimpleSchema schema.tindakan], optional: true
	'rawat.$.labor': type: [new SimpleSchema schema.labor], optional: true
	'rawat.$.radio': type: [new SimpleSchema schema.radio], optional: true
	'rawat.$.obat': type: [new SimpleSchema schema.obat], optional: true
	'rawat.$.total': type: Object, optional: true, autoform: type: 'hidden'
	'rawat.$.total.tindakan': type: Number, optional: true
	'rawat.$.total.labor': type: Number, optional: true
	'rawat.$.total.radio': type: Number, optional: true
	'rawat.$.total.obat': type: Number, optional: true
	'rawat.$.total.semua': type: Number, optional: true

schema.jalan = Object.assign {}, schema.rawat
schema.inap = Object.assign {}, schema.rawat
schema.igd = Object.assign {}, schema.rawat

schema.gudang =
	idbarang: type: String
	jenis: type: Number
	nama: type: String
	harga: type: Number
	batch: type: Array
	'batch.$': type: Object
	'batch.$.idbatch': type: String
	'batch.$.masuk': type: Date
	'batch.$.kadaluarsa': type: Date
	'batch.$.digudang': type: Number
	'batch.$.diapotik': type: Number
	'batch.$.beli': type: Number
	'batch.$.jual': type: Number
	'batch.$.suplier': type: Number

schema.farmasi = Object.assign {}, schema.gudang

schema.dokter =
	nama:
		type: String
	tipe:
		type: Number
		autoform: options: selects.tipe_dokter
	poli:
		type: Number
		autoform: options: selects.klinik

allowAll =
	insert: -> true
	update: -> true
	remove: -> true

coll.pasien = new Meteor.Collection 'pasien'
coll.pasien.allow allowAll

coll.gudang = new Meteor.Collection 'gudang'
coll.gudang.allow allowAll

coll.dokter = new Meteor.Collection 'dokter'
coll.dokter.allow allowAll

makePasien = (modul) ->
	Router.route '/'+modul+'/:no_mr?',
		name: modul
		action: -> this.render 'pasien'

makePasien i.name for i in modules[0..9]

makeGudang = (modul) ->
	Router.route '/'+modul+'/:idbarang?',
		name: modul
		action: -> this.render 'gudang'

makeGudang i.name for i in modules[10..11]

Router.route '/manajemen',
	action: -> this.render 'manajemen'

Router.route '/login', ->
	action: -> this.render 'login'
