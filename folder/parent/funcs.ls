@_ = lodash
@coll = {}; @schema = {}
@look = (list, val) -> selects[list]find -> it.value is val
@look2 = (list, id) -> coll[list]find!fetch!find -> it._id is id
@randomId = -> Math.random!toString 36 .slice 2
@zeros = -> \0 * (6 - it.toString!length) + it
@ors = -> it.find -> it
@ands = -> _.last it if _.every it
@monthDiff = (date) ->
	diff = date.getTime! - (new Date!)getTime!
	diff /= 1000ms * 60sec * 60min * 24hour * 7day * 4week
	Math.round diff

if Meteor.isClient

	SimpleSchema.debug = true
	AutoForm.setDefaultTemplate \materialize
	@currentRoute = -> Router.current!route.getName!
	@currentPar = -> Router.current!params[it]
	@search = -> Session.get \search
	@formDoc = -> Session.get \formDoc
	@limit = -> Session.get \limit
	@page = -> Session.get \page
	@tag = (tag, val) -> "<#tag>#val</#tag>"
	@userName = -> Meteor.users.findOne _id: it ?username
	@roles = -> Meteor.user!?roles
	@rupiah = -> "Rp #{numeral(+it or 0)format '0,0'}"
	@userGroup = ->
		if it then roles!?[that]
		else (.0) _.keys roles!
	@userRole = ->
		if it then roles!?[currentRoute!]?0 is that
		else (.0.0) _.values roles!
	@sessNull = -> _.map Session.keys, (i, j) ->
		Session.set j, null unless j in <[ page limit ]>
