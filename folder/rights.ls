if Meteor.isClient

	@rights = [
		group: \regis
		list: <[ regis jalan ]>
	,
		group: \bayar
		list: [\bayar]
	,
		group: \jalan
		list: <[ jalan farmasi amprah ]>
	,
		group: \inap
		list: <[ inap farmasi ]>
	,
		group: \labor
		list: [\labor]
	,
		group: \radio
		list: [\radio]
	,
		group: \obat
		list: <[ obat farmasi ]>
	,
		group: \rekam
		list: <[ rekam regis ]>
	,
		group: \admisi
		list: [\admisi]
	,
		group: \manajemen
		list: [\manajemen]
	,
		group: \farmasi
		list: [\farmasi]
	]

	_.map rights, (i) -> _.assign i,
		list: [...i.list, \panduan]
