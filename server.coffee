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
								findStock = coll.gudang.findOne nama: j.nama
								for k in [1..j.jumlah]
									sorted = _.sortBy findStock.batch, (l) -> - new Date(l.masuk).getTime()
									filtered = _.filter sorted, (l) -> l.diapotik > 0
									filtered[0].diapotik -= 1
								selector = nama: findStock.nama
								modifier = $set: batch: findStock.batch
								coll.gudang.update selector, modifier

		transfer: (idbarang, idbatch, amount) ->
			selector = idbarang: idbarang, 'batch.digudang': $gt: amount
			modifier = $inc: 'batch.$.diapotik': amount, 'batch.$.digudang': -amount
			coll.gudang.update selector, modifier
