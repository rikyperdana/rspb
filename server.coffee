if Meteor.isServer

	Meteor.publish 'coll', (selector, options) ->
		coll.find selector, options

	Meteor.methods
		import: (selector, modifier) ->
			coll.upsert selector, $set: modifier
		bayar: (modul, no_mr, idbayar) ->
			selector = no_mr: parseInt no_mr
			selector[modul + '.idbayar'] = idbayar
			modifier = {}
			modifier[modul + '.$.status_bayar'] = 1
			coll.update selector, $set: modifier
		request: (no_mr, idbayar, jenis, idjenis, hasil) ->
			selector = no_mr: parseInt no_mr
			findPasien = coll.findOne selector
			for i in findPasien.jalan
				if i[jenis]
					for j in i[jenis]
						if j['id'+jenis] is idjenis
							j.hasil = hasil
			modifier = jalan: findPasien.jalan
			coll.update selector, $set: modifier