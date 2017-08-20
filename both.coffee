_ = lodash

Router.configure
	layoutTemplate: 'layout'

Router.route '/',
	action: -> this.render 'home'

Router.route '/regis',
	action: -> this.render 'modul'
	waitOn: -> Meteor.subscribe 'coll'

Router.route '/jalan',
	action: -> this.render 'modul'
	waitOn: -> Meteor.subscribe 'coll'

@schema = {}

schema.regis =
	no_mr: type: Number
	regis: type: Object
	'regis.nama_lengkap': type: String
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

schema.jalan =
	no_mr: type: Number
	jalan: type: Array
	'jalan.$': type: Object
	'jalan.$.cara_bayar': type: Number
	'jalan.$.status_bayar': type: Number
	'jalan.$.petugas': type: String
	'jalan.$.tindakan': type: Array
	'jalan.$.tindakan.$': type: Object
	'jalan.$.tindakan.$.jenis': type: Number
	'jalan.$.tindakan.$.biaya': type: Number

@coll = new Meteor.Collection 'coll'
coll.allow
	insert: -> true
	update: -> true
	remove: -> true
