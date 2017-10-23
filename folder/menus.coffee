if Meteor.isClient

	@rights = [
		group: 'pendaftaran'
		list: ['regis', 'jalan']
	,
		group: 'pembayaran'
		list: ['bayar']
	]
