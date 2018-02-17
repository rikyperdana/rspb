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
					{text: '\nDATA UMUM PASIEN', alignment: 'center'}
					{columns: [
						['NAMA LENGKAP', 'TEMPAT & TANGGAL LAHIR', 'GOLONGAN DARAH', 'JENIS KELAMIN', 'AGAMA', 'PENDIDIKAN', 'PEKERJAAN', 'NAMA AYAH', 'NAMA IBU', 'NAMA SUAMI / ISTRI', 'ALAMAT', 'NO. TELP / HP']
						[
							': ' + doc.regis.nama_lengkap
							': ' + doc.regis.tmpt_lahir + ', ' + moment(doc.regis.tgl_lahir).format('D/MM/YYYY')
							(_.map ['darah', 'kelamin', 'agama', 'pendidikan', 'pekerjaan'], (i) ->
								': ' + look(i, doc.regis[i]).label)...
							(_.map ['ayah', 'ibu', 'pasangan', 'alamat', 'kontak'], (i) ->
								': ' + doc.regis[i])...
						]
					]}
					{text: '\nPERSETUJUAN UMUM (GENERAL CONSENT)', alignment: 'center'}
					{table: body: [
						['Cek', {text: 'Keterangan', alignment: 'center'}]
						[' ', 'Saya akan mentaati peraturan yang berlaku di RSUD Petala Bumi']
						[' ', 'Saya memberi kuasa kepada dokter dan semua tenaga kesehatan untuk melakukan pemeriksaan / pengobatan / tindakan yang diperlakukan upaya kesembuhan saya / pasien tersebut diatas']
						[' ', 'Saya memberi kuasa kepada dokter dan semua tenaga kesehatan yang ikut merawat saya untuk memberikan keterangan medis saya kepada yang bertanggung jawab atas biaya perawatan saya.']
						[' ', 'Saya memberi kuasa kepada RSUD Petala Bumi untuk menginformasikan identitas sosial saya kepada keluarga / rekan / masyarakat']
						[' ', 'Saya mengatakan bahwa informasi hasil pemeriksaan / rekam medis saya dapat digunakan untuk pendidikan / penelitian demi kemajuan ilmu kesehatan']
					]}
					'\nPetunjuk :'
					'S: Setuju'
					'TS: Tidak Setuju'
					{alignment: 'justify', columns: [
						{text: '\n\n\n\n__________________\n'+(_.startCase Meteor.user().username), alignment: 'center'}
						{text: 'Pekanbaru, '+moment().format('DD/MM/YYYY')+'\n\n\n\n__________________', alignment: 'center'}
					]}
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
			
