@selects =
	rawat: ['Rawat Jalan', 'Rawat Inap', 'IGD']
	pekerjaan: ['Pegawa Negeri', 'Karyawan Swasta', 'Wirausaha', 'Petani', 'Tidak Bekerja']
	kelamin: ['Laki-laki', 'Perempuan']
	agama: ['Islam', 'Katolik', 'Protestan', 'Buddha', 'Hindu', 'Kong Hu Chu']
	pendidikan: ['SD', 'SMP', 'SMA', 'Diploma', 'S1', 'S2', 'S3', 'Tidak Sekolah']
	darah: ['A', 'B', 'C', 'AB', 'O']
	cara_bayar: ['Umum', 'BPJS', 'Jamkesda Pekanbaru', 'Jamkesda Kampar', 'Lapas/Dinsos']
	nikah: ['Nikah', 'Belum Nikah', 'Janda', 'Duda']
	klinik: ['Penyakit Dalam', 'Gigi', 'Kebidanan', 'THT', 'Anak', 'Saraf', 'Mata', 'Bedah', 'Paru', 'Tb. Dots', 'Kulit', 'Fisioterapi', 'Gizi', 'Metadon', 'Psikologi', 'Tindakan']
	nama_rujukan: ['Datang Sendiri', 'RS Lain', 'Puskesmas', 'Faskes Lainnya']
	bentuk: ['butir', 'kapsul', 'tablet', 'sendok makan', 'sendok teh']
	tipe_dokter: ['Umum', 'Spesialis']
	keluar: ['Pulang', 'Rujuk']

_.map (_.keys selects), (i) -> selects[i] = _.map selects[i], (j, x) -> label: j, value: x+1

selects.tindakan = -> if Meteor.isClient
	sub = Meteor.subscribe 'coll', 'tarif', {}, {}
	selector = jenis: Meteor.user().roles.jalan[0]
	if sub.ready() then _.map coll.tarif.find(selector).fetch(), (i) ->
		i.label = _.startCase i.nama
		i.value = i._id
		i
selects.dokter = -> if Meteor.isClient
	sub = Meteor.subscribe 'coll', 'dokter', {}, {}
	find = _.find selects.klinik, (i) ->
		Meteor.user().roles.jalan[0] is _.snakeCase i.label
	selector = poli: find.value
	if sub.ready() then _.map coll.dokter.find(selector).fetch(), (i) ->
		i.label = i.nama
		i.value = i._id
		i
selects.gudang = -> if Meteor.isClient
	sub = Meteor.subscribe 'coll', 'gudang', {}, {}
	if sub.ready() then _.map coll.gudang.find().fetch(), (i) ->
		i.label = i.nama
		i.value = i._id
		i

_.map ['labor', 'radio'], (i) ->
	selects[i] = -> if Meteor.isClient
		sub = Meteor.subscribe 'coll', 'tarif', {}, {}
		selector = jenis: i
		if sub.ready() then _.map coll.tarif.find(selector).fetch(), (j) ->
			j.label = j.nama
			j.value = j._id
			j
