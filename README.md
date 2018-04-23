# RSPB Hospital Information System
Open Source Hospital Information System for Indonesian

## Quick Start
I assume you've installed MeteorJS on your machine, execute these
```
git pull https://github.com/rikyperdana/rspb
cd rspb
meteor npm install --save
meteor
```
Access http://localhost:3000 from your browser
Ctrl+Shift+i to open browser console and execute these:
```
Accounts.createUser({username: 'yourName', password: 'yourPassword'})
Meteor.call('addRole', Meteor.userId(), 'manajemen', 'admin')
```
Then you can get access to management page which can be used to register other accounts

## Specification
For the language itself I prefer to use LiveScript instead of native Javascript for the sake of less typing, conciseness, and readibility
You can see yourself how heavy I use LS features on this project, and for those who haven't get used to LS yet, I'm sure you can still follow
I chose Meteor for building Hospital Information System because I believe MeteorJS is mature enough to handle such critical business system
For the frontend side, I prefer to use Blaze which is built-in by MeteorJS, rather than the latest stack around
For collections handling, I adopt lots of aldeed packages such as collection2, simple-schema, and autoform. This app built around them
There are several schema defined from patients to medical-stocks, and autoform auto-generate the forms to CRUD them
This is how the patient collection store the information of each patient in mongodb:
```
_id: random-thing
no_mr: patient-record-number (provided by mgt)
regis:
	nama_lengkap: patient-full-name
	tgl_lahir: date-of-birth
	tmpt_lahir: place-of-birth
	kelamin: patient-gender
	agama: religion
	nikah: marital-status
	pendidikan: patient-latest-education
	darah: patient-blood-type
	pekerjaan: patient-occupation
	location-related-infos ...
	date: date-of-entry
	petugas: entrying-employee
rawat: [ #it's an array of outpatient datas
	tanggal: date-of-entry
	idbayar: id-of-payment auto-generated
	jenis: type-of-care outpatient/inpatient
	cara_bayar: method-of-payment cash/insurance/others
	klinik: choice-of-clinics speciality-doctor
	karcis: amount-of-money-billed-for-registration
	billRegis: karcis-payment-status unpaid/paid
	rujukan: reference-from-other-hospital
	nobill: queu-number-for-lining-patients
	status_bayar: total-payment-bill-status unpaid/paid
	anamesa_perawat: nurse-anamnese
	fisik: patient-health-check-infos
	anamesa_dokter: doctor-anamnese
	diagnosa: doctor-diagnosis
	planning: what-the-doctor-about-to-do-later
	tindakan: array-of-doctor's-actions
	radio: array-of-prescribed-radiology-check
	labor: array-of-prescribed-laboratory-checkf
	obat: array-of-medicines-prescribed
	total: total-amount-of-money-billed-for-assigned-services
	spm: amount-of-time-the-doctor-handle-the-patient timer-count-by-code
	pindah: other-clinic-the-doctor-assigned-the-patient-to
	keluar: exit-status-after-taken-care
	petugas: entrying-employee-Meteor.userId
]
```

## Tech Detail
This project consist as minimal number of files as it could be, and I divided all codes to these files :
client.ls
both.ls
server.ls
view.jade
style.styl
folder
public

## Known Issues

## Further Dev
