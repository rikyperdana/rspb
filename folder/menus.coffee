if Meteor.isClient

	@rights = [
		group: 'regis'
		list: ['regis', 'jalan']
	,
		group: 'bayar'
		list: ['bayar']
	,
		group: 'jalan'
		list: ['jalan', 'obat']
	,
		group: 'inap'
		list: ['inap', 'obat']
	,
		group: 'labor'
		list: ['labor']
	,
		group: 'radio'
		list: ['radio']
	,
		group: 'obat'
		list: ['obat', 'farmasi']
	,
		group: 'rekam'
		list: ['rekam', 'regis']
	,
		group: 'admisi'
		list: ['admisi']
	]
