if Meteor.isServer

	Meteor.startup ->
		coll.pasien._ensureIndex 'regis.nama_lengkap': 1

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
			
			if jenis is 'obat'
				for i in findPasien.rawat
					if i.obat
						for j in i.obat
							if j.idobat is idjenis
								for k in [1..j.jumlah]
									select = nama: j.nama, kuantitas: $gt: 0
									options = sort: masuk: 1
									findStock = coll.gudang.findOne select, options
									selector = idbatch: findStock.idbatch
									modifier = $inc: kuantitas: -1
									coll.gudang.update selector, modifier
