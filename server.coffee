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
		labor: (no_mr, idbayar, idlabor, hasil) ->
			select = no_mr: parseInt no_mr
			option = fields: no_mr: 1, jalan: 1
			findPasien = coll.findOne select, option
			for i in findPasien.jalan
				if i.labor
					for j in i.labor
						if j.idlabor is idlabor
							j.hasil = hasil
			selector = no_mr: parseInt no_mr
			modifier = jalan: findPasien.jalan
			coll.update selector, $set: modifier
		obat: (no_mr, idbayar, idobat, serah) ->
			select = no_mr: parseInt no_mr
			option = fields: no_mr: 1, jalan: 1
			findPasien = coll.findOne select, option
			for i in findPasien.jalan
				if i.obat
					for j in i.obat
						if j.idobat is idobat
							j.serah = true
			selector = no_mr: parseInt no_mr
			modifier = jalan: findPasien.jalan
			coll.update selector, $set: modifier
		radio: (no_mr, idbayar, idradio, arsip) ->
			select = no_mr: parseInt no_mr
			option = fields: no_mr: 1, jalan: 1
			findPasien = coll.findOne select, option
			for i in findPasien.jalan
				if i.radio
					for j in i.radio
						if j.idradio is idradio
							j.arsip = arsip
			selector = no_mr: parseInt no_mr
			modifier = jalan: findPasien.jalan
			coll.update selector, $set: modifier