@_ = lodash
@coll = {}; @schema = {}
@look = (list, val) -> selects[list]find -> it.value is val
@look2 = (list, id) -> coll[list]find!fetch!find -> it._id is id
@randomId = -> Math.random!toString 36 .slice 2
@zeros = (num) -> \0 * (6 - num.toString!length) + num
@ors = -> it.find -> it
@ands = (exprs) -> _.last exprs if _.every exprs
@monthDiff = (date) ->
	diff = date.getTime! - (new Date!)getTime!
	diff /= 1000ms * 60sec * 60min * 24hour * 7day * 4week
	Math.round diff

if Meteor.isClient

	SimpleSchema.debug = true
	AutoForm.setDefaultTemplate \materialize
	@currentRoute = -> Router.current!route.getName!
	@currentPar = (param) -> Router.current!params[param]
	@search = -> Session.get \search
	@formDoc = -> Session.get \formDoc
	@limit = -> Session.get \limit
	@page = -> Session.get \page
	@tag = (tag, val) -> "<#tag>#val</#tag>"
	@userName = (id) -> Meteor.users.findOne(_id: id)?username
	@roles = -> Meteor.user!?roles
	@userGroup = ->
		if it then roles!?[that]
		else (.0) _.keys roles!
	@userRole = ->
		if it then roles!?[currentRoute!]?0 is that
		else (.0.0) _.values roles!
	@sessNull = -> _.map Session.keys, (i, j) ->
		Session.set j, null unless j in <[ page limit ]>
