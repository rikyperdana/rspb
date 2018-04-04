if Meteor.isClient

	Template.login.onRendered ->
		$('.slider').slider()

	Template.login.events
		'submit form': (event) ->
			event.preventDefault()
			username = event.target.children.username.value
			password = event.target.children.password.value
			Meteor.loginWithPassword username, password, (err) ->
				if err
					Materialize.toast 'Salah username / password', 3000
				else
					Router.go '/' + _.keys(roles())[0]

	Template.pagination.helpers
		pagins: (name) ->
			limit = Session.get 'limit'
			length = coll[name].find().fetch().length
			end = (length - (length % limit)) / limit
			[1..end]

	Template.pagination.events
		'click #next': -> Session.set 'page', 1 + page()
		'click #prev': -> Session.set 'page', -1 + page()
		'click #num': (event) ->
			Session.set 'page', parseInt event.target.innerText

	Template.report.helpers
		datas: -> Session.get 'laporan'

	Template.report.events
		'click .datepicker': (event, template) ->
			type = event.target.attributes.date.nodeValue
			$('#'+type).pickadate onSet: (data) ->
				Session.set type+'Date', data.select
				start = Session.get 'startDate'
				end = Session.get 'endDate'
				if start and end
					Meteor.call 'report', template.data.jenis, start, end, (err, res) ->
						res and Session.set 'laporan', res
		'click #export': (event, template) ->
			content = exportcsv.exportToCSV Session.get('laporan').csv, true, ';'
			blob = new Blob [content], type: 'text/plain;charset=utf-8'
			saveAs blob, template.data.jenis+'.csv'
