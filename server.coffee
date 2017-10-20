if Meteor.isServer

	Meteor.startup ->
		coll.pasien._ensureIndex 'regis.nama_lengkap': 1

	Meteor.publish 'coll', (name, selector, options) ->
		coll[name].find selector, options

	Meteor.methods
		import: (selector, modifier) ->
			coll.pasien.upsert selector, $set: modifier

		payRegis: (no_mr) ->
			selector = no_mr: parseInt no_mr
			modifier = 'regis.paidRegis': true
			coll.pasien.update selector, $set: modifier

		bayar: (no_mr, idbayar) ->
			selector = 'rawat.idbayar': idbayar, no_mr: parseInt no_mr
			modifier = 'rawat.$.status_bayar': true
			coll.pasien.update selector, $set: modifier

		request: (no_mr, idbayar, jenis, idjenis, hasil) ->
			selector = no_mr: parseInt no_mr
			findPasien = coll.pasien.findOne selector
			for i in findPasien.rawat
				if i[jenis] then for j in i[jenis]
					if j['id'+jenis] is idjenis then j.hasil = hasil
			modifier = rawat: findPasien.rawat
			coll.pasien.update selector, $set: modifier
			if jenis is 'obat' then for i in findPasien.rawat
				if i.obat then for j in i.obat
					if j.idobat is idjenis
						findStock = coll.gudang.findOne nama: j.nama
						for k in [1..j.jumlah]
							filtered = _.filter findStock.batch, (l) -> l.diapotik > 0
							sorted = _.sortBy filtered, (l) -> - new Date(l.masuk).getTime()
							sorted[0].diapotik -= 1
						selector = nama: findStock.nama
						modifier = $set: batch: findStock.batch
						coll.gudang.update selector, modifier

		transfer: (idbarang, idbatch, amount) ->
			selector = idbarang: idbarang, 'batch.digudang': $gt: amount
			modifier = $inc: 'batch.$.diapotik': amount, 'batch.$.digudang': -amount
			coll.gudang.update selector, modifier

		rmRawat: (no_mr, idbayar) ->
			selector = no_mr: parseInt no_mr
			modifier = $pull: rawat: idbayar: idbayar
			coll.pasien.update selector, modifier
