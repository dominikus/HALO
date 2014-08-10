# DataController.coffee

dataPath = 'data'

$(window).on "app-ready", () ->
	problem = (error) ->
		console.log 'error loading data:'
		console.log error

	q = queue()
	q
		.defer(d3.json, dataPath + '/network.json')

	q.awaitAll(
		(error, results) ->
			if error?
				problem(error)

			# parse results:
			[
				graph
			] = results

			window.app.data.graph = graph

			$(window).trigger "data-loaded"
	)



