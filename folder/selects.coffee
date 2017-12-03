@selects =
	rawat: [
		label: 'Rawat Jalan'
		value: 1
	,
		label: 'Rawat Inap'
		value: 2
	,
		label: 'IGD'
		value: 3
	]
	pekerjaan: [
		label: 'Pegawai Negeri'
		value: 1
	,
		label: 'Karyawan Swasta'
		value: 2
	,
		label: 'Wirausaha'
		value: 3
	,
		label: 'Petani'
		value: 4
	,
		label: 'Tidak Bekerja'
		value: 5
	]
	kelamin: [
		label: 'Laki-laki'
		value: 1
	,
		label: 'Perempuan'
		value: 2
	]
	agama: [
		label: 'Islam'
		value: 1
	,
		label: 'Katolik'
		value: 2
	,
		label: 'Protestan'
		value: 3
	,
		label: 'Budha'
		value: 4
	,
		label: 'Hindu'
		value: 5
	,
		label: 'Kong Hu Chu'
		value: 6
	]
	pendidikan: [
		label: 'Sekolah Dasar'
		value: 1
	,
		label: 'Sekolah Menengah'
		value: 2
	,
		label: 'Sekolah Atas'
		value: 3
	,
		label: 'Strata 1'
		value: 4
	,
		label: 'Strata 2'
		value: 5
	,
		label: 'Tidak Sekolah'
		value: 6
	]
	darah: [
		label: 'A'
		value: 1
	,
		label: 'B'
		value: 2
	,
		label: 'AB'
		value: 3
	,
		label: 'O'
		value: 4
	]
	cara_bayar: [
		label: 'Umum'
		value: 1
	,
		label: 'BPJS'
		value: 2
	,
		label: 'Jamkesda Pekanbaru'
		value: 3
	,
		label: 'Jamkesda Kampar'
		value: 4
	,
		label: 'Lapas/Dinsos'
		value: 5
	]
	nikah: [
		label: 'Nikah'
		value: 1
	,
		label: 'Belum Nikah'
		value: 2
	,
		label: 'Janda'
		value: 3
	,
		label: 'Duda'
		value: 4
	]
	klinik: [
		label: 'Penyakit Dalam'
		value: 1
	,
		label: 'Gigi'
		value: 2
	,
		label: 'Kebidanan'
		value: 3
	,
		label: 'THT'
		value: 4
	,
		label: 'Anak'
		value: 5
	,
		label: 'Saraf'
		value: 6
	,
		label: 'Mata'
		value: 7
	,
		label: 'Bedah'
		value: 8
	,
		label: 'Paru'
		value: 9
	,
		label: 'Tb. Dots'
		value: 10
	,
		label: 'Kulit'
		value: 11
	,
		label: 'Fisioterapi'
		value: 12
	]
	nama_rujukan: [
		label: 'Datang Sendiri'
		value: 1
	,
		label: 'RS Lain'
		value: 2
	,
		label: 'Puskesmas'
		value: 3
	,
		label: 'Faskes Lainnya'
		value: 4
	]
	bentuk: [
		value: 1
		label: 'butir'
	,
		value: 2
		label: 'kapsul'
	,
		value: 3
		label: 'tablet'
	,
		value: 4
		label: 'sendok makan'
	,
		value: 5
		label: 'sendok teh'
	]
	tipe_dokter: [
		label: 'Umum'
		value: 1
	,
		label: 'Spesialis'
		value: 2
	]
	tindakan: -> if Meteor.isClient
		sub = Meteor.subscribe 'coll', 'tarif', {}, {}
		selector = jenis: Meteor.user().roles.jalan[0]
		if sub.ready() then _.map coll.tarif.find(selector).fetch(), (i) ->
			i.label = _.startCase i.nama
			i.value = i.idtarif
			i

_.map ['gudang', 'dokter'], (i) ->
	selects[i] = -> if Meteor.isClient
		sub = Meteor.subscribe 'coll', i, {}, {}
		if sub.ready() then _.map coll[i].find().fetch(), (j) ->
			j.label = j.nama
			j.value = j._id
			j

_.map ['labor', 'radio'], (i) ->
	selects[i] = -> if Meteor.isClient
		sub = Meteor.subscribe 'coll', 'tarif', {}, {}
		selector = jenis: i
		if sub.ready() then _.map coll.tarif.find(selector).fetch(), (j) ->
			j.label = j.nama
			j.value = j.idtarif
			j
