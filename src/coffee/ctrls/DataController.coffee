# DataController.coffee

dataPath = 'data'

$(window).on "app-ready", () ->
	problem = (error) ->
		console.log 'error loading data:'
		console.log error

	q = queue()

	q
		#.defer(d3.json, dataPath + '/network.json')
		.defer(d3.json, "http://dominiku.indus.uberspace.de/cgi-bin/proxy.php?link=" +"https://dl.dropboxusercontent.com/u/12216985/network.json")

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



