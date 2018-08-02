if Meteor.isServer

	Meteor.startup ->
		coll.pasien._ensureIndex 'regis.nama_lengkap': 1

	Meteor.publish \coll, (name, selector, options) ->
		coll[name]find selector, options

	Meteor.publish \users, (selector, options) ->
		Meteor.users.find selector, options

	Meteor.methods do
		import: (name, selector, modifier, arrName) ->
			unless arrName
				coll[name]insert _.assign selector, modifier
			else
				unless coll[name]findOne(selector)
					coll[name]insert _.assign selector, modifier
				else
					sel = _id: find._id
					obj = "#arrName": modifier[arrName]0
					coll[name]update sel, $push: obj

		export: (jenis) ->
			if jenis is \regis
				arr = coll.pasien.find!fetch!map ->
					no_mr: it.no_mr
					nama_lengkap: it.regis.nama_lengkap
			else if jenis is \jalan
				arr = _.flatMap coll.pasien.find!fetch!, (i) ->
					if i.rawat then that.map (j) ->
						no_mr: i.no_mr
						nama_lengkap: i.regis.nama_lengkap
						idbayar: j.idbayar
						cara_bayar: look \cara_bayar, j.cara_bayar .label
						klinik: find \klinik, j.klinik
			else if jenis is \farmasi
				arr = _.flatMap coll.gudang.find!fetch!, (i) ->
					i.batch.map (j) ->
						head = <[ jenis nama ]>
						head = _.zipObject head, _.map head, (k) -> i[k]
						body = <[ nobatch merek satuan masuk kadaluarsa digudang diapotik beli jual suplier anggaran pengadaan ]>
						body = _.zipObject body, _.map body, (k) -> j[k]
						_.assign head, body
			exportcsv.exportToCSV arr, true, \;

		billCard: (no_mr, state) ->
			selector = no_mr: +no_mr
			modifier = $set: 'regis.billCard': state
			coll.pasien.update selector, modifier

		billRegis: (no_mr, idbayar, state) ->
			selector = 'rawat.idbayar': idbayar, no_mr: +no_mr
			modifier = $set: 'rawat.$.billRegis': state
			coll.pasien.update selector, modifier

		bayar: (no_mr, idbayar) ->
			selector = 'rawat.idbayar': idbayar, no_mr: +no_mr
			modifier = 'rawat.$.status_bayar': true
			coll.pasien.update selector, $set: modifier

		request: (no_mr, idbayar, jenis, idjenis, hasil) ->
			selector = no_mr: +no_mr
			findPasien = coll.pasien.findOne selector
			for i in findPasien.rawat
				if i.idbayar is idbayar then if i[jenis] then for j in i[jenis]
					if j["id#jenis"] is idjenis then j.hasil = hasil
			modifier = rawat: findPasien.rawat
			coll.pasien.update selector, $set: modifier
			give = {}
			if jenis is \obat then for i in findPasien.rawat
				if i.idbayar is idbayar then if i.obat then for j in i.obat
					if j.idobat is idjenis
						findStock = coll.gudang.findOne _id: j.nama
						for k in [1 to j.jumlah]
							filtered = _.filter findStock.batch, (l) -> l.diapotik > 0
							sortedIn = _.sortBy filtered, (l) -> new Date l.masuk .getTime!
							sortedEd = _.sortBy sortedIn, (l) -> new Date l.kadaluarsa .getTime!
							sortedEd.0.diapotik -= 1
							key = "#{findStock.nama};#{sortedEd.0.nobatch}"
							give[key] or= 0; give[key] += 1
						selector = _id: findStock._id
						modifier = $set: batch: findStock.batch
						coll.gudang.update selector, modifier
			give if jenis is \obat

		transfer: (idbarang, amount) ->
			findStock = coll.gudang.findOne {idbarang}
			give = {}
			for i in [1 to amount]
				findBatch = findStock.batch.find (j) -> ands do
					[j.digudang > 0, 0 < monthDiff j.kadaluarsa]
				findBatch.digudang -= 1
				findBatch.diapotik += 1
				key = findBatch.nobatch
				give[key] or= 0; give[key] += 1
			coll.gudang.update findStock._id, findStock
			give

		rmPasien: (no_mr) ->
			coll.pasien.remove no_mr: +no_mr

		rmRawat: (no_mr, idbayar) ->
			selector = no_mr: +no_mr
			modifier = $pull: rawat: {idbayar}
			coll.pasien.update selector, modifier

		addRole: (id, roles, group, poli) ->
			Roles.addUsersToRoles id, (poli or roles), group

		rmRole: (id) ->
			selector = _id: id
			modifier = $set: roles: {}
			Meteor.users.update selector, modifier

		newUser: (doc) ->
			if Accounts.findUserByUsername(doc.username)
				for i in <[ username password ]>
					Accounts["set#{_.startCase i}"] that._id, doc[i]
			else Accounts.createUser doc

		rmBarang: (idbarang) ->
			coll.gudang.remove {idbarang}

		rmBatch: (idbarang, idbatch) ->
			findStock = coll.gudang.findOne {idbarang}
			coll.gudang.update {_id: findStock._id}, $set: batch: _.without do
				findStock.batch, findStock.batch.find -> it.idbatch is idbatch

		inactive: (name, id) ->
			sel = _id: id; mod = $set: active: false
			coll[name]update sel, mod

		pindah: (no_mr) ->
			find = coll.pasien.findOne no_mr: +no_mr
			[..., last] = find.rawat
			if last.pindah
				selector = _id: find._id
				modifier = $push: rawat:
					idbayar: randomId!
					tanggal: new Date!
					cara_bayar: last.cara_bayar
					klinik: last.pindah
					billRegis: true
					total: semua: 0
				coll.pasien.update selector, modifier

		report: (jenis, start, end) ->
			filter = -> it.filter (i) ->
				new Date(start) < new Date(i.tanggal) < new Date(end)
			docs = _.flatMap coll.pasien.find!fetch!, (i) -> filter(i.rawat)map (j) ->
				obj =
					no_mr: i.no_mr
					nama_lengkap: _.startCase i.regis.nama_lengkap
					tanggal: j.tanggal
					no_bill: j.nobill
					cara_bayar: look \cara_bayar, j.cara_bayar .label
					rujukan: if j.rujukan then look \rujukan, j.rujukan .label else ''
					klinik: look \klinik, j.klinik .label
					diagnosa: j.diagnosa or \-
					tindakan: _.flatMap <[ tindakan labor radio ]>, (k) ->
						saring = _.filter j[k], (l) -> l
						_.map saring, (l) -> \/ + _.startCase look2 \tarif, l.nama .nama
					harga: 'Rp ' + j.total.semua
					petugas: Meteor.users.findOne _id: j.petugas .username
					keluar: if j.keluar then look \keluar, j.keluar .label else \-
					baru_lama: if i.rawat.length > 1 then \Lama else \Baru
				if jenis is \pendaftaran
					_.pick obj, <[ tanggal no_mr nama_lengkap cara_bayar rujukan klinik diagnosa baru_lama ]>
				else if jenis is \pembayaran
					_.pick obj, <[ tanggal no_bill no_mr nama_lengkap klinik diagnosa tindakan harga petugas ]>
				else if jenis is \rawat_jalan
					_.pick obj, <[ tanggal no_mr nama_lengkap keluar umur cara_bayar diagnosa tindakan petugas keluar rujukan ]>
			headers: _.map docs.0, (val, key) -> _.startCase key
			rows: docs.map -> _.values it
			csv: docs

		patientExist: (no_mr) ->
			true if coll.pasien.findOne no_mr: +no_mr

		nearEds: (returnable) ->
			sel = 'digudang': {$gt: 0}, 'diretur': {$ne: true}
			source = coll.gudang.find batch: $elemMatch: sel .fetch!
			assign = source.map (i) -> i.batch.map (j) -> _.assign j,
				idbarang: i.idbarang, nama: i.nama
			batch = _.flatMap source, -> it.batch
			diffed = batch.filter (i) ->
				a = -> 6 > monthDiff i.kadaluarsa
				b = -> i.returnable
				if returnable then a! and b! else a!

		returBatch: (doc) ->
			findStock = coll.gudang.findOne idbarang: doc.idbarang
			for i in findStock.batch
				if i.idbatch is doc.idbatch
					i.diretur = true
			sel = _id: findStock._id; mod = batch: findStock.batch
			coll.gudang.update sel, $set: mod

		amprah: (idbarang, idamprah, diserah) ->
			barang = coll.gudang.findOne {idbarang}
			for i in barang.amprah
				if i.idamprah is idamprah
					i.penyerah = @userId
					i.diserah = diserah
			coll.gudang.update barang._id, barang

		latestAmprah: ->
			coll.gudang.find!fetch!map (i) -> if i.amprah
				_.assign i, amprah: that.filter (j) ->
					not j.penyerah
