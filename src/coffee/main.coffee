
# -------------------

class App extends Backbone.Router
	views: {}
	models: {}
	data: {}

	routes:
		'*path': 'pageChange'

	initialize: ()->
		Backbone.history.start()
		$(window).trigger "app-ready"

	pageChange: (path)->
		console.log "page change", path

# -------------------

window.app = new App()
