if Meteor.isClient

	@makePdf =
		card: ->
			doc = coll.pasien.findOne()
			pdf = pdfMake.createPdf
				content: [
					'Nama: ' + doc.regis.nama_lengkap
					'No. MR: ' + zeros doc.no_mr
				]
				pageSize: 'B8'
				pageMargins: [110, 50, 0, 0]
				pageOrientation: 'landscape'
			pdf.download zeros(doc.no_mr) + '_card.pdf'
		consent: ->
			doc = coll.pasien.findOne()
			pdf = pdfMake.createPdf
				content: [
					{text: 'PEMERINTAH PROVINSI RIAU\nRUMAH SAKIT UMUM DAERAH PETALA BUMI\nJL. Dr. Soetomo No. 65, Telp. (0761) 23024', alignment: 'center'}
					'\nDATA UMUM PASIEN'
					'\nNAMA LENGKAP : ' + doc.regis.nama_lengkap
					'TEMPAT & TANGGAL LAHIR : ' + doc.regis.tmpt_lahir + ', tanggal ' + moment(doc.regis.tgl_lahir).format('D/MMMM/YYYY')
					'GOLONGAN DARAH : ' + look('darah', doc.regis.darah).label
					'JENIS KELAMIN : ' + look('kelamin', doc.regis.kelamin).label
					'AGAMA : ' + look('agama', doc.regis.agama).label
					'PENDIDIKAN : ' + look('pendidikan', doc.regis.pendidikan).label
					'PEKERJAAN : ' + look('pekerjaan', doc.regis.pekerjaan).label
					'NAMA AYAH : ' + doc.regis.ayah
					'NAMA IBU : ' + doc.regis.ibu
					'NAMA SUAMI/ISTRI : ' + doc.regis.pasangan
					'ALAMAT : ' + doc.regis.alamat
					'NO. TELP / HP : ' + doc.regis.kontak
					'\nPERSETUJUAN UMUM (GENERAL CONSENT)'
					'\nSaya akan mentaati peraturan yang berlaku di RSUD Petala Bumi'
					'Saya memberi kuasa kepada dokter dan semua tenaga kesehatan untuk melakukan pemeriksaan / pengobatan / tindakan yang diperlakukan upaya kesembuhan saya / pasien tersebut diatas'
					'Saya memberi kuasa kepada dokter dan semua tenaga kesehatan yang ikut merawat saya untuk memberikan keterangan medis saya kepada yang bertanggung jawab atas biaya perawatan saya.'
					'Saya memberi kuasa kepada RSUD Petala Bumi untuk menginformasikan identitas sosial saya kepada keluarga / rekan / masyarakat'
					'Saya mengatakan bahwa informasi hasil pemeriksaan / rekam medis saya dapat digunakan untuk pendidikan / penelitian demi kemajuan ilmu kesehatan'
					'\nPetunjuk :'
					'S: Setuju'
					'TS: Tidak Setuju'
					{text: 'Pekanbaru,                        .\n\n\n__________________', alignment: 'right'}
				]
			pdf.download zeros(doc.no_mr) + '_consent.pdf'
		payRawat: (doc) ->
			pasien = coll.pasien.findOne()
			rows = _.map ['tindakan', 'labor', 'radio'], (i) -> doc[i] and _.map doc[i], (j) ->
				find = _.find coll.tarif.find().fetch(), (k) -> k._id is j.nama
				[_.startCase(find.nama), _.toString(j.harga)]
			table = table: widths: [400, 100], body: [['Uraian', 'Harga'], rows...]
			pdf = pdfMake.createPdf
				content: [
					{text: 'PEMERINTAH PROVINSI RIAU\nRUMAH SAKIT UMUM DAERAH PETALA BUMI\nJL. DR. SOETOMO NO. 65, TELP. (0761) 23024, PEKANBARU', alignment: 'center'}
					'\nRINCIAN BIAYA RAWAT JALAN'
					'IDENTITAS PASIEN'
					'NO. MR' + zeros pasien.no_mr
					'NAMA PASIEN' + pasien.regis.nama_lengkap
					'JENIS KELAMIN' + look('kelamin', pasien.regis.kelamin).label
					'TANGGAL LAHIR' + moment(pasien.regis.tgl_lahir).format('D MM YYYY')
					'UMUR' + _.toString moment().diff(pasien.regis.tgl_lahir, 'years')
					'KLINIK'
					'\n\nRINCIAN PEMBAYARAN'
					table
					'TOTAL BIAYA' + 'Rp ' + _.toString numeral(doc.total.semua).format('0,0')
					'\nPEKANBARU, ' + moment().format('DD MM YYYY')
					'PETUGAS'
				]
			pdf.download zeros(pasien.no_mr) + '_payRawat.pdf'
		payRegCard: (amount, words) ->
			doc = coll.pasien.findOne()
			pdf = pdfMake.createPdf
				content: [
					text: 'PEMERINTAH PROVINSI RIAU\nRUMAH SAKIT UMUM DAERAH PETALA BUMI\nJL. DR. SOETOMO NO. 65, TELP. (0761) 23024, PEKANBARU', alignment: 'center'
				,
					'\nKARCIS'
					'TANGGAL : ' + moment().format('DD MM YYYY')
					'NO. MR : ' + _.toString zeros doc.no_mr
					'NAMA PASIEN : ' + doc.regis.nama_lengkap
					'\nTARIF : Rp ' + _.toString amount
				,
					text: '(' + words + ')', italics: true
				]
			pdf.download zeros(doc.no_mr) + '_payRegCard.pdf'
		rekap: (rows) ->
			strings = _.map rows, (i) -> _.map i, (j) -> _.toString j
			pdf = pdfMake.createPdf content: [table: body: strings]
			pdf.download 'rekap.pdf'
			
