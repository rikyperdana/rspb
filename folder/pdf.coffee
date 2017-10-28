if Meteor.isClient

	@makePdf =
		card: ->
			doc = coll.pasien.findOne()
			pdf = pdfMake.createPdf
				content: [
					'Nama: ' + doc.regis.nama_lengkap
					'No. MR: ' + doc.no_mr
				]
				pageSize: 'B8'
				pageMargins: [110, 50, 0, 0]
				pageOrientation: 'landscape'
			pdf.download doc.no_mr + '_card.pdf'
		consent: ->
			doc = coll.pasien.findOne()
			pdf = pdfMake.createPdf
				content: [
					'PEMERINTAH PROVINSI RIAU'
					'RUMAH SAKIT UMUM DAERAH PETALA BUMI'
					'JL. DR. SOETOMO NO. 65, TELP. (0761) 23024, PEKANBARU'
					'DATA UMUM PASIEN'
					'NAMA LENGKAP : ' + doc.regis.nama_lengkap
					'TEMPAT & TANGGAL LAHIR : ' + doc.regis.tmpt_lahir + ', tanggal ' + moment(doc.regis.tgl_lahir).format('D/MMMM/YYYY')
					'GOLONGAN DARAH : ' + doc.regis.darah
					'JENIS KELAMIN : ' + doc.regis.kelamin
					'AGAMA : ' + doc.regis.agama
					'PENDIDIKAN : ' + doc.regis.pendidikan
					'PEKERJAAN : ' + doc.regis.pekerjaan
					'NAMA AYAH : ' + doc.regis.ayah
					'NAMA IBU : ' + doc.regis.ibu
					'NAMA SUAMI/ISTRI : ' + doc.regis.pasangan
					'ALAMAT : ' + doc.regis.alamat
					'NO. TELP / HP : ' + doc.regis.kontak
					'PERSETUJUAN UMUM (GENERAL CONSENT)'
					'Saya akan mentaati peraturan yang berlaku di RSUD Petala Bumi'
					'Saya memberi kuasa kepada dokter dan semua tenaga kesehatan untuk melakukan pemeriksaan / pengobatan / tindakan yang diperlakukan upaya kesembuhan saya / pasien tersebut diatas'
					'Saya memberi kuasa kepada dokter dan semua tenaga kesehatan yang ikut merawat saya untuk memberikan keterangan medis saya kepada yang bertanggung jawab atas biaya perawatan saya.'
					'Saya memberi kuasa kepada RSUD Petala Bumi untuk menginformasikan identitas sosial saya kepada keluarga / rekan / masyarakat'
					'Saya mengatakan bahwa informasi hasil pemeriksaan / rekam medis saya dapat digunakan untuk pendidikan / penelitian demi kemajuan ilmu kesehatan'
					'Petunjuk :'
					'S: Setuju'
					'TS: Tidak Setuju'
				]
			pdf.download doc.no_mr + '_consent.pdf'
