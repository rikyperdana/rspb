@_ = lodash
@coll = {}; @schema = {}
@look = (list, val) -> _.find selects[list], (i) -> i.value is val
@look2 = (list, id) -> _.find coll[list]find!fetch!, (i) -> i._id is id
@randomId = -> Math.random!toString 36 .slice 2
@zeros = (num) -> \0 * (6 - num.toString!length) + num
@monthDiff = (date) ->
	diff = date.getTime! - (new Date!)getTime!
	diff /= 1000ms * 60sec * 60min * 24hour * 7day * 4week
	Math.round diff

if Meteor.isClient

	# SimpleSchema.debug = true
	AutoForm.setDefaultTemplate \materialize
	@currentRoute = -> Router.current!route.getName!
	@currentPar = (param) -> Router.current!params[param]
	@search = -> Session.get \search
	@formDoc = -> Session.get \formDoc
	@limit = -> Session.get \limit
	@page = -> Session.get \page
	@roles = -> Meteor.user!?roles
	@userGroup = (name) -> roles![name]
	@userRole = (name) -> roles!?[currentRoute!]?0 is name
	@tag = (tag, val) -> "<#tag>#val</#tag>"
	@userName = (id) -> Meteor.users.findOne(_id: id)?username
	@show = console.log
	@sessNull = -> _.map (_.tail _.keys Session.keys), (i) ->
		Session.set i, null
	
