if Meteor.isClient

	@makePdf =
		card: ->
			doc = coll.pasien.findOne()
			pdf = pdfMake.createPdf
				content: [
					'Nama  : ' + doc.regis.nama_lengkap
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
						['NO. MR', 'NAMA LENGKAP', 'TEMPAT & TANGGAL LAHIR', 'GOLONGAN DARAH', 'JENIS KELAMIN', 'AGAMA', 'PENDIDIKAN', 'PEKERJAAN', 'NAMA AYAH', 'NAMA IBU', 'NAMA SUAMI / ISTRI', 'ALAMAT', 'NO. TELP / HP']
						_.map [
							zeros doc.no_mr
							doc.regis.nama_lengkap
							(doc.regis.tmpt_lahir or '-') + ', ' + moment(doc.regis.tgl_lahir).format('D/MM/YYYY')
							(_.map ['darah', 'kelamin', 'agama', 'pendidikan', 'pekerjaan'], (i) ->
								(look(i, doc.regis[i])?.label or '-'))...
							(_.map ['ayah', 'ibu', 'pasangan', 'alamat', 'kontak'], (i) ->
								(doc.regis[i] or '-'))...
						], (i) -> ': ' + i
					]}
					{text: '\nPERSETUJUAN UMUM (GENERAL CONSENT)', alignment: 'center'}
					{table: body: [
						['S', 'TS', {text: 'Keterangan', alignment: 'center'}]
						(_.map [
							['Saya akan mentaati peraturan yang berlaku di RSUD Petala Bumi']
							['Saya memberi kuasa kepada dokter dan semua tenaga kesehatan untuk melakukan pemeriksaan / pengobatan / tindakan yang diperlakukan upaya kesembuhan saya / pasien tersebut diatas']
							['Saya memberi kuasa kepada dokter dan semua tenaga kesehatan yang ikut merawat saya untuk memberikan keterangan medis saya kepada yang bertanggung jawab atas biaya perawatan saya.']
							['Saya memberi kuasa kepada RSUD Petala Bumi untuk menginformasikan identitas sosial saya kepada keluarga / rekan / masyarakat']
							['Saya mengatakan bahwa informasi hasil pemeriksaan / rekam medis saya dapat digunakan untuk pendidikan / penelitian demi kemajuan ilmu kesehatan']
						], (i) -> [' ', ' ', i...])...
					]}
					'\nPetunjuk :'
					'S: Setuju'
					'TS: Tidak Setuju'
					{alignment: 'justify', columns: [
						{text: '\n\n\n\n__________________\n'+(_.startCase Meteor.user().username), alignment: 'center'}
						{text: 'Pekanbaru, '+moment().format('DD/MM/YYYY')+'\n\n\n\n__________________\n'+(_.startCase doc.regis.nama_lengkap), alignment: 'center'}
					]}
				]
			pdf.download zeros(doc.no_mr) + '_consent.pdf'
		payRawat: (doc) ->
			pasien = coll.pasien.findOne()
			rows = [['Uraian', 'Harga']]
			for i in ['tindakan', 'labor', 'radio']
				if doc[i] then for j in doc[i]
					find = _.find coll.tarif.find().fetch(), (k) -> k._id is j.nama
					rows.push [_.startCase(find.nama), _.toString(j.harga)]
			table = table: widths: ['*', 'auto'], body: rows
			pdf = pdfMake.createPdf
				content: [
					{text: 'PEMERINTAH PROVINSI RIAU\nRUMAH SAKIT UMUM DAERAH PETALA BUMI\nJL. DR. SOETOMO NO. 65, TELP. (0761) 23024, PEKANBARU', alignment: 'center'}
					{text: '\nRINCIAN BIAYA RAWAT JALAN\n', alignment: 'center'}
					{columns: [
						['NO. MR', 'NAMA PASIEN', 'JENIS KELAMIN', 'TANGGAL LAHIR', 'UMUR', 'KLINIK']
						_.map [
							zeros pasien.no_mr
							_.startCase pasien.regis.nama_lengkap
							(look('kelamin', pasien.regis.kelamin)?.label or '-')
							moment().format('D/MM/YYYY')
							moment().diff(pasien.regis.tgl_lahir, 'years') + ' tahun'
							(look('klinik', doc.klinik)?.label or '-')
						], (i) -> ': ' + i
					]}
					{text: '\n\nRINCIAN PEMBAYARAN', alignment: 'center'}
					table
					'\nTOTAL BIAYA' + 'Rp ' + _.toString numeral(doc.total.semua).format('0,0')
					{text: '\nPEKANBARU, ' + moment().format('D/MM/YYYY') +
					'\n\n\n\n\n' + (_.startCase Meteor.user().username), alignment: 'right'}
				]
			pdf.download zeros(pasien.no_mr) + '_payRawat.pdf'
		payRegCard: (amount, words) ->
			doc = coll.pasien.findOne()
			pdf = pdfMake.createPdf
				content: [
					{text: 'PEMERINTAH PROVINSI RIAU\nRUMAH SAKIT UMUM DAERAH PETALA BUMI\nJL. DR. SOETOMO NO. 65, TELP. (0761) 23024, PEKANBARU', alignment: 'center'}
					{text: '\n\nKARCIS', alignment: 'center'}
					{columns: [
						['TANGGAL', 'NO. MR', 'NAMA PASIEN', 'TARIF', '\n\nPETUGAS']
						_.map [
							moment().format('DD/MM/YYYY')
							_.toString zeros doc.no_mr
							_.startCase doc.regis.nama_lengkap
							'Rp ' + _.toString amount
							'\n\n' + _.startCase Meteor.user().username
						], (i) -> ': ' + i
					]}
				]
			pdf.download zeros(doc.no_mr) + '_payRegCard.pdf'
		rekap: (rows) ->
			strings = _.map rows, (i) -> _.map i, (j) -> _.toString j
			pdf = pdfMake.createPdf content: [table: body: strings]
			pdf.download 'rekap.pdf'
