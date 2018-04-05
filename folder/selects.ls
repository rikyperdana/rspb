@selects =
	rawat: ['Rawat Jalan', 'Rawat Inap', 'IGD']
	pekerjaan: ['PNS', 'BUMN/BUMD', 'TNI/Polri', 'Dokter', 'Karyawan Swasta', 'Wirausaha', 'Honorer', 'Pensiun', 'Petani', 'Buruh', 'Tidak Bekerja', 'Dan Lain-lain']
	kelamin: ['Laki-laki', 'Perempuan']
	agama: ['Islam', 'Katolik', 'Protestan', 'Buddha', 'Hindu', 'Kong Hu Chu']
	pendidikan: ['SD', 'SMP', 'SMA', 'Diploma', 'S1', 'S2', 'S3', 'Tidak Sekolah']
	darah: ['A', 'B', 'C', 'AB', 'O']
	cara_bayar: ['Umum', 'BPJS', 'Jamkesda Pekanbaru', 'Jamkesda Kampar', 'Lapas/Dinsos', 'Free']
	nikah: ['Nikah', 'Belum Nikah', 'Janda', 'Duda']
	klinik: ['Penyakit Dalam', 'Gigi', 'Kebidanan', 'THT', 'Anak', 'Saraf', 'Mata', 'Bedah', 'Paru', 'Tb. Dots', 'Kulit', 'Fisioterapi', 'Gizi', 'Metadon', 'Psikologi', 'Tindakan', 'APS Labor', 'APS Radio']
	bentuk: ['butir', 'kapsul', 'tablet', 'sendok makan', 'sendok teh']
	tipe_dokter: ['Umum', 'Spesialis']
	rujukan: ['Datang Sendiri', 'RS Lain', 'Puskesmas', 'Faskes Lainnya']
	keluar: ['Pulang', 'Rujuk']
	barang: ['Generik', 'Non-Generik', 'Obat Narkotika', 'BHP']
	satuan: ['Botol', 'Vial', 'Ampul', 'Pcs', 'Sachet', 'Tube', 'Supp', 'Tablet', 'Minidose', 'Pot', 'Turbuhaler', 'Kaplet']
	anggaran: ['BLUD', 'APBD', 'Kemenkes', 'Dinkes']
	alias: ['Tn.', 'Ny.', 'Nn.', 'An.', 'By.']

_.map (_.keys selects), (i) -> selects[i] = _.map selects[i], (j, x) -> label: j, value: x+1

selects.karcis = _.map [15000 20000 25000 30000 40000], (i) -> value: i, label: 'Rp ' + i

selects.tindakan = -> if Meteor.isClient
	selector = jenis: Meteor.user!roles.jalan.0
	Meteor.subscribe \coll, \tarif, {}, {}
		.ready! and _.map coll.tarif.find(selector).fetch!, (i) ->
			value: i._id, label: _.startCase i.nama

selects.dokter = -> if Meteor.isClient
	selector = poli: (.value) _.find selects.klinik, (i) ->
		Meteor.user!roles.jalan.0 is _.snakeCase i.label
	Meteor.subscribe \coll, \dokter, {}, {}
		.ready! and _.map coll.dokter.find(selector).fetch!, (i) ->
			value: i._id, label: i.nama

selects.obat = -> if Meteor.isClient
	filter = (arr) -> _.filter arr, (i) -> i.jenis is 1
	Meteor.subscribe \coll, \gudang, {}, {}
		.ready! and _.map filter(coll.gudang.find!fetch!), (i) ->
			value: i._id, label: i.nama

_.map <[ labor radio ]>, (i) ->
	selects[i] = -> if Meteor.isClient
		Meteor.subscribe \coll, \tarif, {}, {}
			.ready! and _.map coll.tarif.find(jenis: i).fetch!, (j) ->
				value: j._id, label: _.startCase j.nama
