@selects =
	rawat: <[ rawat_jalan rawat_inap igd ]>
	pekerjaan: <[ pns swasta wiraswasta tni polri pensiunan lainnya ]>
	kelamin: <[ laki_laki perempuan ]>
	agama: <[ islam katolik protestan buddha hindu kong_hu_chu ]>
	pendidikan: <[ sd smp sma diploma s1 s2 s3 tidak_sekolah ]>
	darah: <[ a b ab o ]>
	cara_bayar: <[ umum bpjs jamkesda_pekanbaru jamkesda_kampar lapas_dinsos free ]>
	nikah: <[ nikah belum_nikah janda duda ]>
	klinik: <[ penyakit_dalam gigi kebidanan tht anak saraf mata bedah paru tb_dots kulit fisioterapi gizi metadon psikologi tindakan aps_labor aps_radio ]>
	karcis: [ 40 30 40 40 40 40 40 40 40 40 40 0 25 30 25 0 0 0 ]
	bentuk: <[ butir kapsul tablet sendok_makan sendok_teh ]>
	tipe_dokter: <[ umum spesialis ]>
	rujukan: <[ datang_sendiri rs_lain puskesmas faskes_lainnya ]>
	keluar: <[ pulang rujuk ]>
	barang: <[ generik non_generik obat_narkotika bhp ]>
	satuan: <[ botol vial ampul pcs sachet tube supp tablet minidose pot turbuhaler kaplet kapsul bag pen rectal flash cream nebu ]>
	anggaran: <[ blud apbd kemenkes dinkes ]>
	alias: <[ tn ny nn an by ]>

_.map selects, (i, j) -> selects[j] = _.map selects[j], (m, n) -> value: n+1, label: _.startCase m

selects.tindakan = -> if Meteor.isClient
	selector = jenis: Meteor.user!roles.jalan.0
	Meteor.subscribe \coll, \tarif, {}, {}
	.ready! and coll.tarif.find(selector)fetch!map ->
		value: it._id, label: _.startCase it.nama

selects.dokter = -> if Meteor.isClient
	selector = poli: (.value) selects.klinik.find ->
		Meteor.user!roles.jalan.0 is _.snakeCase it.label
	Meteor.subscribe \coll, \dokter, {}, {}
	.ready! and coll.dokter.find(selector)fetch!map ->
		value: it._id, label: it.nama

selects.obat = -> if Meteor.isClient
	filtered = -> it.filter -> it.jenis is 1
	Meteor.subscribe \coll, \gudang, {}, {}
	.ready! and filtered(coll.gudang.find!fetch!)map ->
		value: it._id, label: it.nama

for i in <[ labor radio ]>
	selects[i] = -> if Meteor.isClient
		Meteor.subscribe \coll, \tarif, {}, {}
		.ready! and coll.tarif.find(jenis: i)fetch!map ->
			value: it._id, label: _.startCase it.nama
