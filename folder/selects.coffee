@selects =
	rawat: ['Rawat Jalan', 'Rawat Inap', 'IGD']
	pekerjaan: ['Pegawa Negeri', 'Karyawan Swasta', 'Wirausaha', 'Petani', 'Tidak Bekerja']
	kelamin: ['Laki-laki', 'Perempuan']
	agama: ['Islam', 'Katolik', 'Protestan', 'Buddha', 'Hindu', 'Kong Hu Chu']
	pendidikan: ['SD', 'SMP', 'SMA', 'Diploma', 'S1', 'S2', 'S3', 'Tidak Sekolah']
	darah: ['A', 'B', 'C', 'AB', 'O']
	cara_bayar: ['Umum', 'BPJS', 'Jamkesda Pekanbaru', 'Jamkesda Kampar', 'Lapas/Dinsos']
	nikah: ['Nikah', 'Belum Nikah', 'Janda', 'Duda']
	klinik: ['Penyakit Dalam', 'Gigi', 'Kebidanan', 'THT', 'Anak', 'Saraf', 'Mata', 'Bedah', 'Paru', 'Tb. Dots', 'Kulit', 'Fisioterapi', 'Gizi', 'Metadon', 'Psikologi', 'Tindakan', 'APS Labor', 'APS Radio']
	bentuk: ['butir', 'kapsul', 'tablet', 'sendok makan', 'sendok teh']
	tipe_dokter: ['Umum', 'Spesialis']
	rujukan: ['Datang Sendiri', 'RS Lain', 'Puskesmas', 'Faskes Lainnya']
	keluar: ['Pulang', 'Rujuk']
	barang: ['Obat', 'BHP']
	kabupaten: ['Pekanbaru', 'Dumai', 'Meranti', 'Kuansing', 'Kampar', 'Siak', 'Bengkalis', 'Rokan Hulu', 'Rokan Hilir', 'Indragiri Hulu', 'Indragiri Hilir']
	kecamatan: ['Bagan Sinembah, Rokan Hilir','Bagansinembah Raya, Rokan Hilir','Balai Jaya, Rokan Hilir','Bandar Petalangan, Pelalawan','Bandar Sei Kijang, Pelalawan','Bangkinang Barat, Kampar','Bangkinang Seberang, Kampar','Bangkinang, Kampar','Bangko Pusako, Rokan Hilir','Bangko, Rokan Hilir','Bangun Purba, Rokan Hulu','Bantan, Bengkalis','Batang Cenaku, Indragiri Hulu','Batang Gansal, Indragiri Hulu','Batang Peranap, Indragiri Hulu','Batang Tuaka, Indragiri Hilir','Batu Hampar, Rokan Hilir','Benai, Kuantan Singingi','Bengkalis, Bengkalis','Bintan Pesisir, Bintan','Bonai Darussalam, Rokan Hulu','Bukit Batu, Bengkalis','Bukit Raya, Pekanbaru','Bunga Raya, Siak','Bunut, Pelalawan','Cerenti, Kuantan Singingi','Concong, Indragiri Hilir','Dayun, Siak','Dumai Barat, Dumai','Dumai Barat, Siak','Dumai Kota, Dumai','Dumai Selatan, Dumai','Dumai Timur, Dumai','Dumai Timur, Siak','Enok, Indragiri Hilir','Gaung Anak Serka, Indragiri Hilir','Gaung, Indragiri Hilir','Gunung Sahilan, Kampar','Gunung Toar, Kuantan Singingi','Hulu Kuantan, Kuantan Singingi','Inuman, Kuantan Singingi','Kabun, Rokan Hulu','Kampar Kiri Hilir, Kampar','Kampar Kiri Hulu, Kampar','Kampar Kiri Tengah, Kampar','Kampar Kiri, Kampar','Kampar Timur, Kampar','Kampar Utara, Kampar','Kampar, Kampar','Kandis, Siak','Kateman, Indragiri Hilir','Kelayang, Indragiri Hulu','Kempas, Indragiri Hilir','Kemuning, Indragiri Hilir','Kepenuhan Hulu, Rokan Hulu','Kepenuhan, Rokan Hulu','Kerinci Kanan, Siak','Keritang, Indragiri Hilir','Kerumutan, Pelalawan','Koto Gasip, Siak','Koto Kampar Hulu, Kampar','Kuala Cenaku, Indragiri Hulu','Kuala Indragiri, Indragiri Hilir','Kuala Kampar, Pelalawan','Kuantan Hilir, Kuantan Singingi','Kuantan Mudik, Kuantan Singingi','Kuantan Tengah, Kuantan Singingi','Kubu Babussalam, Rokan Hilir','Kubu, Rokan Hilir','Kunto Darussalam, Rokan Hulu','Langgam, Pelalawan','Lima Puluh, Pekanbaru','Lirik, Indragiri Hulu','Logas Tanah Darat, Kuantan Singingi','Lubuk Batu Jaya, Indragiri Hulu','Lubuk Dalam, Siak','Mandah, Indragiri Hilir','Mandau, Bengkalis','Marpoyan Damai, Pekanbaru','Medang Kampai, Dumai','Medang Kampai, Siak','Mempura, Siak','Merbau, Bengkalis','Merbau, Kepulauan Meranti','Minas, Siak','Pagaran Tapah Darussalam, Rokan Hulu','Pangean, Kuantan Singingi','Pangkalan Kerinci, Pelalawan','Pangkalan Kuras, Pelalawan','Pangkalan Lesung, Pelalawan','Pasir Limau Kapas, Rokan Hilir','Pasir Penyu, Indragiri Hulu','Payung Sekaki, Pekanbaru','Pekaitan, Rokan Hilir','Pekanbaru Kota, Pekanbaru','Pelalawan, Pelalawan','Pelangiran, Indragiri Hilir','Pendalian V Koto, Rokan Hulu','Peranap, Indragiri Hulu','Perhentian Raja, Kampar','Pinggir, Bengkalis','Pujud, Rokan Hilir','Pulau Burung, Indragiri Hilir','Pulau Merbau, Kepulauan Meranti','Pusako, Siak','Putri Puyu, Kepulauan Meranti','Rakit Kulim, Indragiri Hulu','Rambah Hilir, Rokan Hulu','Rambah Samo, Rokan Hulu','Rambah, Rokan Hulu','Rangsang Barat, Bengkalis','Rangsang Barat, Kepulauan Meranti','Rangsang, Bengkalis','Rangsang, Kepulauan Meranti','Rantau Kopar, Rokan Hilir','Rengat Barat, Indragiri Hulu','Rengat, Indragiri Hulu','Reteh, Indragiri Hilir','Rimba Melintang, Rokan Hilir','Rokan IV Koto, Rokan Hulu','Rumbai Pesisir, Pekanbaru','Rumbai, Pekanbaru','Rumbio Jaya, Kampar','Rupat Utara, Bengkalis','Rupat, Bengkalis','Sabak Auh, Siak','Sail, Pekanbaru','Salo, Kampar','Seberida, Indragiri Hulu','Senapelan, Pekanbaru','Siak Hulu, Kampar','Siak Kecil, Bengkalis','Siak, Siak','Simpang Kanan, Rokan Hilir','Sinaboi, Rokan Hilir','Singingi Hilir, Kuantan Singingi','Singingi, Kuantan Singingi','Sukajadi, Pekanbaru','Sungai Apit, Siak','Sungai Batang, Indragiri Hilir','Sungai Lala, Indragiri Hulu','Sungai Sembilan, Dumai','Sungai Sembilan, Siak','Tambang, Kampar','Tambusai Utara, Rokan Hulu','Tambusai, Rokan Hulu','Tampan, Pekanbaru','Tanah Merah, Indragiri Hilir','Tanah Putih Tanjung Melawan, Rokan Hilir','Tanah Putih, Rokan Hilir','Tandun, Rokan Hulu','Tanjung Medan, Rokan Hilir','Tapung Hilir, Kampar','Tapung Hulu, Kampar','Tapung, Kampar','Tebing Tinggi Barat, Bengkalis','Tebing Tinggi Barat, Kepulauan Meranti','Tebing Tinggi Timur, Kepulauan Meranti','Tebing Tinggi, Bengkalis','Tebing Tinggi, Kepulauan Meranti','Teluk Balengkong, Indragiri Hilir','Teluk Meranti, Pelalawan','Teluk Merbau, Rokan Hilir','Tembilahan Hulu, Indragiri Hilir','Tembilahan, Indragiri Hilir','Tempuling, Indragiri Hilir','Tenayan Raya, Pekanbaru','Tualang, Siak','Ujung Batu, Rokan Hulu','Ukui, Pelalawan','XIII Koto Kampar, Kampar']

_.map (_.keys selects), (i) -> selects[i] = _.map selects[i], (j, x) -> label: j, value: x+1

selects.tindakan = -> if Meteor.isClient
	sub = Meteor.subscribe 'coll', 'tarif', {}, {}
	selector = jenis: Meteor.user().roles.jalan[0]
	if sub.ready() then _.map coll.tarif.find(selector).fetch(), (i) ->
		value: i._id, label: _.startCase i.nama

selects.dokter = -> if Meteor.isClient
	sub = Meteor.subscribe 'coll', 'dokter', {}, {}
	find = _.find selects.klinik, (i) ->
		Meteor.user().roles.jalan[0] is _.snakeCase i.label
	selector = poli: find.value
	if sub.ready() then _.map coll.dokter.find(selector).fetch(), (i) ->
		value: i._id, label: i.nama

selects.obat = -> if Meteor.isClient
	sub = Meteor.subscribe 'coll', 'gudang', {}, {}
	filter = (arr) -> _.filter arr, (i) -> i.jenis is 1
	if sub.ready() then _.map filter(coll.gudang.find().fetch()), (i) ->
		value: i._id, label: i.nama

_.map ['labor', 'radio'], (i) ->
	selects[i] = -> if Meteor.isClient
		sub = Meteor.subscribe 'coll', 'tarif', {}, {}
		selector = jenis: i
		if sub.ready() then _.map coll.tarif.find(selector).fetch(), (j) ->
			value: j._id, label: _.startCase j.nama
