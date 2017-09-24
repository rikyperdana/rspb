if Meteor.isServer

	Meteor.publish 'coll', (name, selector, options) ->
		coll[name].find selector, options

	Meteor.methods
		import: (selector, modifier) ->
			coll.pasien.upsert selector, $set: modifier
		bayar: (no_mr, idbayar) ->
			selector = 'rawat.idbayar': idbayar, no_mr: parseInt no_mr
			modifier = 'rawat.$.status_bayar': true
			coll.pasien.update selector, $set: modifier
		request: (no_mr, idbayar, jenis, idjenis, hasil) ->
			selector = no_mr: parseInt no_mr
			findPasien = coll.pasien.findOne selector
			for i in findPasien.rawat
				if i[jenis]
					for j in i[jenis]
						if j['id'+jenis] is idjenis
							j.hasil = hasil
			modifier = rawat: findPasien.rawat
			coll.pasien.update selector, $set: modifier