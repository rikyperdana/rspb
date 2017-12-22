if Meteor.isServer

	Meteor.startup ->
		coll.pasien._ensureIndex 'regis.nama_lengkap': 1

	Meteor.publish 'coll', (name, selector, options) ->
		coll[name].find selector, options

	Meteor.publish 'users', ->
		Meteor.users.find({})

	Meteor.methods
		import: (name, selector, modifier) ->
			coll[name].upsert selector, $set: modifier

		billCard: (no_mr, state) ->
			selector = no_mr: parseInt no_mr
			modifier = $set: 'regis.billCard': state
			coll.pasien.update selector, modifier

		billRegis: (no_mr, idbayar, state) ->
			selector = 'rawat.idbayar': idbayar, no_mr: parseInt no_mr
			modifier = $set: 'rawat.$.billRegis': state
			coll.pasien.update selector, modifier

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
			give = {}
			if jenis is 'obat' then for i in findPasien.rawat
				if i.obat then for j in i.obat
					if j.idobat is idjenis
						findStock = coll.gudang.findOne _id: j.nama
						for k in [1..j.jumlah]
							filtered = _.filter findStock.batch, (l) -> l.diapotik > 0
							sortedIn = _.sortBy filtered, (l) -> new Date(l.masuk).getTime()
							sortedEd = _.sortBy sortedIn, (l) -> new Date(l.kadaluarsa).getTime()
							sortedEd[0].diapotik -= 1
							unless give[sortedEd[0].idbatch] then give[sortedEd[0].idbatch] = 0
							give[sortedEd[0].idbatch] += 1
						selector = _id: findStock._id
						modifier = $set: batch: findStock.batch
						coll.gudang.update selector, modifier
			give

		transfer: (idbarang, idbatch, amount) ->
			selector = idbarang: idbarang, 'batch.digudang': $gt: amount
			modifier = $inc: 'batch.$.diapotik': amount, 'batch.$.digudang': -amount
			coll.gudang.update selector, modifier

		rmRawat: (no_mr, idbayar) ->
			selector = no_mr: parseInt no_mr
			modifier = $pull: rawat: idbayar: idbayar
			coll.pasien.update selector, modifier

		addRole: (id, roles, group, poli) ->
			role = poli or roles
			Roles.addUsersToRoles id, role, group

		rmRole: (id) ->
			selector = _id: id
			modifier = $set: roles: {}
			Meteor.users.update selector, modifier

		newUser: (doc) ->
			find = Accounts.findUserByUsername doc.username
			if find
				Accounts.setUsername find._id, doc.username
				Accounts.setPassword find._id, doc.password
			else
				Accounts.createUser doc

		rmBarang: (idbarang) ->
			coll.gudang.remove idbarang: idbarang
		
		pindah: (no_mr) ->
			find = coll.pasien.findOne 'no_mr': parseInt no_mr
			if find.rawat[find.rawat.length-1].pindah
				selector = _id: find._id
				modifier = $push: rawat:
					idbayar: Math.random().toString(36).slice(2)
					tanggal: new Date()
					cara_bayar: find.rawat[find.rawat.length-1].cara_bayar
					klinik: find.rawat[find.rawat.length-1].pindah
					billRegis: true
					total: semua: 0
				coll.pasien.update selector, modifier

		report: (jenis) ->
			if jenis is 'pasien'
				selector = {}
				modifier = {}
				headers: ['Nama', 'Cara Bayar', 'Klinik']
				rows: _.flatten _.map coll.pasien.find().fetch(), (i) ->
					_.map i.rawat, (j) -> [i.regis.nama_lengkap, j.cara_bayar, j.klinik]
			else if jenis is 'gudang'
				headers: [], rows: []
