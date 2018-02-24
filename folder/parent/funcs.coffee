@_ = lodash
@coll = {}; @schema = {}
@look = (list, val) -> _.find selects[list], (i) -> i.value is val
@look2 = (list, id) -> _.find coll[list].find().fetch(), (i) -> i._id is id
@randomId = -> Math.random().toString(36).slice(2)
@zeros = (num) ->
	size = _.size _.toString num
	if size < 7 then '0'.repeat(6-size) + _.toString num

if Meteor.isClient

	# SimpleSchema.debug = true
	AutoForm.setDefaultTemplate 'materialize'
	@currentRoute = -> Router.current().route.getName()
	@currentPar = (param) -> Router.current().params[param]
	@search = -> Session.get 'search'
	@formDoc = -> Session.get 'formDoc'
	@limit = -> Session.get 'limit'
	@page = -> Session.get 'page'
	@roles = -> Meteor.user().roles
	@tag = (tag, val) -> '<'+tag+'>'+val+'</'+tag+'>'
	@sessNull = -> _.map (_.tail _.keys Session.keys), (i) ->
		Session.set i, null
	@groupIs = (name) -> _.includes (_.keys Meteor.user().roles), name
	@roleIs = (name) -> _.includes (_.flatMap Meteor.user().roles), name
