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
	'jalan.$.cara_bayar': type: Number
	'jalan.$.status_bayar': type: Number
	'jalan.$.tindakan': type: Array
	'jalan.$.tindakan.$': type: Object
	'jalan.$.tindakan.$.jenis': type: Number
	'jalan.$.tindakan.$.biaya': type: Number
	'jalan.$.id': type: Number
	'jalan.$.petugas': type: String
	'jalan.$.date': type: Date

schema.bayar =
	no_mr: type: Number
	bayar: type: Array
	'bayar.$': type: Object
	'bayar.$.cara_bayar': type: Number
	'bayar.$.status_bayar': type: Number
	'bayar.$.tindakan': type: Array
	'bayar.$.tindakan.$': type: Object
	'bayar.$.tindakan.$.jenis': type: Number
	'bayar.$.tindakan.$.biaya': type: Number
	'bayar.$.id': type: Number
	'bayar.$.petugas': type: String
	'bayar.$.date': type: Date

@coll = new Meteor.Collection 'coll'
coll.allow
	insert: -> true
	update: -> true
	remove: -> true

makeRoute = (modul) ->
	Router.route '/'+modul+'/:no_mr?',
		name: modul
		action: -> this.render 'modul'
		waitOn: ->
			no_mr = this.params.no_mr
			if no_mr
				Meteor.subscribe 'coll', no_mr, modul
			else
				Meteor.subscribe 'coll'

makeRoute key for key, val of schema
