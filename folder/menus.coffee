if Meteor.isClient

	@rights = [
		group: 'pendaftaran'
		list: ['regis', 'jalan']
	,
		group: 'pembayaran'
		list: ['bayar']
	,
		group: 'rawat_jalan'
		list: ['rawat', 'apotek']
	,
		group: 'rawat_inap'
		list: ['rawat', 'apotek']
	,
		group: 'laboratorium'
		list: ['labor']
	,
		group: 'radiologi'
		list: ['radio']
	,
		group: 'apotek'
		list: ['apotek', 'farmasi']
	,
		group: 'rekam_medik'
		list: ['rekam', 'pendaftaran']
	,
		group: 'admisi'
		list: ['admisi']
	]
