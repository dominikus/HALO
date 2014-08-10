# graph model

class window.Node extends Backbone.Model
	defaults: ->
		#

	# overwrite server syncing
	url: ""
	sync: ->
		@

class window.Link extends Backbone.Model
	defaults: ->
		#

	# overwrite server syncing
	url: ""
	sync: ->
		@

class window.Nodes extends Backbone.Collection
	model: Node

class window.Links extends Backbone.Collection
	model: Link


$(window).on "data-loaded", () ->
	window.app.models.nodes = new Nodes()
	window.app.models.links = Links()

	for p, i in window.app.data.graph.nodes
		t = window.app.models.graph.create(p)
	for p, i in window.app.data.graph.links
		l = window.app.models.links.create(p)

	$(window).trigger "graph-created"

