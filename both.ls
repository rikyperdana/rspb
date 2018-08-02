Router.configure do
	layoutTemplate: \layout
	loadingTemplate: \loading

Router.route \/,
	action: -> @render \home

schema.regis =
	no_mr: type: Number, max: 999999
	regis: type: Object
	'regis.alias': type: Number, optional: true, autoform: options: selects.alias
	'regis.nama_lengkap': type: String
	'regis.tgl_lahir': type: Date, autoform: type: \pickadate, pickadateOptions: selectYears: 150, selectMonths: true
	'regis.tmpt_lahir': type: String, optional: true
	'regis.cara_bayar': type: Number, autoform: options: selects.cara_bayar
	'regis.kelamin': type: Number, autoform: options: selects.kelamin
	'regis.agama': type: Number, autoform: options: selects.agama
	'regis.nikah': type: Number, autoform: options: selects.nikah
	'regis.pendidikan': type: Number, optional: true, autoform: options: selects.pendidikan
	'regis.darah': type: Number, optional: true, autoform: options: selects.darah
	'regis.pekerjaan': type: Number, optional: true, autoform: options: selects.pekerjaan
	'regis.kabupaten': type: String, optional: true
	'regis.kecamatan': type: String, optional: true
	'regis.kelurahan': type: String, optional: true
	'regis.alamat': type: String
	'regis.kontak': type: String, optional: true
	'regis.ayah': type: String, optional: true
	'regis.ibu': type: String, optional: true
	'regis.pasangan': type: String, optional: true
	'regis.petugas':
		type: String
		autoform: type: \hidden
		autoValue: -> if Meteor.isClient then Meteor.userId!
	'regis.date':
		type: Date
		autoform: type: \hidden
		autoValue: -> new Date
	'regis.billCard': type: Boolean, optional: true, autoform: type: \hidden

schema.fisik =
	tekanan_darah: type: String, optional: true
	nadi: type: Number, optional: true
	suhu: type: Number, decimal: true, optional: true
	pernapasan: type: Number, optional: true
	berat: type: Number, optional: true
	tinggi: type: Number, optional: true
	lila: type: Number, optional: true

schema.tindakan =
	idtindakan:
		type: String, optional: true,
		autoform: type: \hidden
		autoValue: -> randomId!
	nama: type: String, autoform: options: selects.tindakan, type: \universe-select
	dokter: type: String, autoform: options: selects.dokter

schema.labor =
	idlabor:
		type: String, optional: true,
		autoform: type: \hidden
		autoValue: -> randomId!
	nama: type: String, autoform: options: selects.labor
	harga: type: Number, optional: true, autoform: type: \hidden
	hasil: type: String, optional: true, autoform: type: \hidden

schema.radio =
	idradio:
		type: String, optional: true,
		autoform: type: \hidden
		autoValue: -> randomId!
	nama: type: String, autoform: options: selects.radio
	harga: type: Number, optional: true, autoform: type: \hidden
	hasil: type: String, optional: true, autoform: type: \hidden

schema.obat =
	idobat:
		type: String, optional: true,
		autoform: type: \hidden
		autoValue: -> randomId!
	nama: type: String, autoform: options: selects.obat
	puyer: type: String, optional: true
	aturan: type: Object
	'aturan.kali': type: Number
	'aturan.dosis': type: Number
	'aturan.bentuk': type: Number, autoform: options: selects.bentuk
	jumlah: type: Number
	harga: type: Number, optional: true, autoform: type: \hidden
	subtotal: type: Number, optional: true, autoform: type: \hidden
	hasil: type: String, optional: true, autoform: type: \hidden

schema.rawat =
	no_mr: type: Number
	rawat: type: Array
	'rawat.$': type: Object
	'rawat.$.tanggal': type: Date, autoform: type: \hidden
	'rawat.$.idbayar': type: String, optional: true, autoform: type: \hidden
	'rawat.$.jenis': type: String, optional: true, autoform: type: \hidden
	'rawat.$.cara_bayar': type: Number, autoform: options: selects.cara_bayar
	'rawat.$.klinik': type: Number, autoform: options: selects.klinik
	'rawat.$.karcis': type: Number, autoform: type: \hidden
	'rawat.$.rujukan': type: Number, optional: true, autoform: options: selects.rujukan
	'rawat.$.billRegis': type: Boolean, optional: true, autoform: type: \hidden
	'rawat.$.nobill': type: Number, autoform: type: \hidden
	'rawat.$.status_bayar': type: Boolean, optional: true, autoform: type: \hidden
	'rawat.$.anamesa_perawat': type: String, optional: true, autoform: afFieldInput: type: \textarea, rows: 6
	'rawat.$.fisik': optional: true, type: [new SimpleSchema schema.fisik]
	'rawat.$.anamesa_dokter': type: String, optional: true, autoform: afFieldInput: type: \textarea, rows: 6
	'rawat.$.diagnosa': type: String, optional: true, autoform: afFieldInput: type: \textarea, rows: 6
	'rawat.$.planning': type: String, optional: true, autoform: afFieldInput: type: \textarea, rows: 6
	'rawat.$.tindakan': type: [new SimpleSchema schema.tindakan], optional: true
	'rawat.$.labor': type: [new SimpleSchema schema.labor], optional: true
	'rawat.$.radio': type: [new SimpleSchema schema.radio], optional: true
	'rawat.$.obat': type: [new SimpleSchema schema.obat], optional: true
	'rawat.$.total': type: Object, optional: true, autoform: type: \hidden
	'rawat.$.total.tindakan': type: Number, optional: true
	'rawat.$.total.labor': type: Number, optional: true
	'rawat.$.total.radio': type: Number, optional: true
	'rawat.$.total.obat': type: Number, optional: true
	'rawat.$.total.semua': type: Number, optional: true
	'rawat.$.spm': type: Number, optional: true, autoform: type: \hidden
	'rawat.$.pindah': type: Number, optional: true, autoform: options: selects.klinik
	'rawat.$.keluar': type: Number, optional: true, autoform: options: selects.keluar
	'rawat.$.petugas': type: String, autoform: type: \hidden

schema.jalan = _.assign {}, schema.rawat, {}
schema.inap = _.assign {}, schema.rawat, {}
schema.igd = _.assign {}, schema.rawat, {}

schema.gudang =
	idbarang:
		type: String
		autoform: type: \hidden
		autoValue: -> randomId!
	jenis: type: Number, autoform: options: selects.barang
	nama: type: String

schema.farmasi = _.assign {}, schema.gudang,
	kandungan: type: String
	satuan: type: Number, autoform: options: selects.satuan
	batch: type: Array
	'batch.$': type: Object
	'batch.$.idbatch':
		type: String
		autoform: type: \hidden
		autoValue: -> randomId!
	'batch.$.nobatch': type: String
	'batch.$.merek': type: String
	'batch.$.masuk': type: Date, autoform: type: \pickadate, pickadateOptions: selectYears: 150, selectMonths: true
	'batch.$.kadaluarsa': type: Date, autoform: type: \pickadate, pickadateOptions: selectYears: 150, selectMonths: true
	'batch.$.digudang': type: Number
	'batch.$.diapotik': type: Number
	'batch.$.diretur': type: Boolean, optional: true, autoform: type: \hidden
	'batch.$.beli': type: Number, decimal: true
	'batch.$.jual': type: Number, decimal: true
	'batch.$.suplier': type: String
	'batch.$.returnable': type: Boolean, optional: true
	'batch.$.anggaran': type: Number, autoform: options: selects.anggaran
	'batch.$.pengadaan': type: Number

schema.amprah = _.assign {}, schema.gudang,
	amprah: type: Array
	'amprah.$': type: Object
	'amprah.$.diminta': type: Number

schema.logistik = _.assign {}, schema.gudang, {}

schema.dokter =
	nama: type: String
	tipe: type: Number, autoform: options: selects.tipe_dokter
	poli: type: Number, autoform: options: selects.klinik

schema.tarif =
	jenis: type: String
	nama: type: String
	harga: type: Number
	grup: type: String, optional: true

<[ dokter tarif ]>map (i) ->
	_.assign schema[i], active:
		type: Boolean
		autoform: type: \hidden
		autoValue: -> true

<[ pasien gudang dokter tarif ]>map (i) ->
	coll[i] = new Meteor.Collection i
	arr = <[ insert update remove ]>
	coll[i]allow _.zipObject arr, arr.map -> -> true

modules[0 to 9]map ({name}) ->
	Router.route "/#name/:no_mr?",
		name: name
		action: -> @render \pasien
		waitOn: ->
			<[ dokter tarif gudang ]>map (i) ->
				Meteor.subscribe \coll, i, {}, {}

modules[10 to 11]map ({name}) ->
	Router.route "/#name/:idbarang?",
		name: name
		action: -> @render \gudang
		waitOn: -> Meteor.subscribe \users, {}, fields: username: 1

<[ panduan ]>map (i) ->
	Router.route "/#i",
		action: -> @render i

Router.route \/manajemen,
	action: -> @render \manajemen
	waitOn: -> [
		Meteor.subscribe \users, {}, {}
		Meteor.subscribe \coll, \dokter, {}, {}
		Meteor.subscribe \coll, \tarif, {}, {}
	]

Router.route \/login, ->
	action: -> @render \login
