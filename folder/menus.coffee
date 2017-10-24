if Meteor.isClient

	@rights = [
		group: 'pendaftaran'
		list: ['regis', 'jalan']
	,
		group: 'pembayaran'
		list: ['bayar']
	,
		group: 'rawat_jalan'
		list: ['jalan', 'obat']
	,
		group: 'rawat_inap'
		list: ['rawat', 'obat']
	,
		group: 'laboratorium'
		list: ['labor']
	,
		group: 'radiologi'
		list: ['radio']
	,
		group: 'obat'
		list: ['obat', 'farmasi']
	,
		group: 'rekam_medik'
		list: ['rekam', 'pendaftaran']
	,
		group: 'admisi'
		list: ['admisi']
	]
