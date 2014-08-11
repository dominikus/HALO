# vis
$(window).on "graph-created", () ->
	[svg, viewport, force, nodes, links, vnodes, vlinks, width, height, tooltip, offset] = [undefined]

	setup = () ->
		width = $("#vis").width()
		height = $("#vis").height()

		svg = d3.select("#vis").append("svg")
			.attr({
				"width": width
				"height": height
				})
		viewport = svg.append("g").attr("id", "viewport")

		offset = $("#vis").offset()

		# force-directed layout
		force = d3.layout.force()
			.size([width, height])

		render()

		# tooltip
		tooltip = d3.select("#vis").append("div")
			.classed("ttip", true)

	tick = (e, visible = false) ->
		if visible
			# update graphics
			vnodes
				.transition()
					.style("transform", (d,i) =>
						"translate(#{Math.round(d.x)}px, #{Math.round(d.y)}px)"
					)
			vlinks
				.transition()
					.attr("x1", (d) -> d.source.x)
					.attr("y1", (d) -> d.source.y)
					.attr("x2", (d) -> d.target.x)
					.attr("y2", (d) -> d.target.y)

	redraw = () ->
		d3.select("#viewport").attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")")

	showTooltip = (s) ->
		e = d3.event
		tooltip.text(s)

		tooltip.style({
			"left": e.pageX - offset.left + "px"
			"top": e.pageY - offset.top + "px"
			"display": "block"
			})

	hideTooltip = () ->
		#tooltip.style("display", "none")

	render = () ->
		nodes = window.app.models.nodes.map((d) -> {
			"abstract": d.get("Abstract")
			"authors": d.get("Authors")
			"journal": d.get("Journal")
			"keywords": d.get("Keywords")
			"title": d.get("Title")
			"type": d.get("Base")
			"year": d.get("Year")
			"label": d.get("label")
			})
		links = window.app.models.links.map((d) -> {
			"source": d.get("source")
			"target": d.get("target")
			"type": d.get("Type")
			})

		# graphical elements:
		vlinks = viewport.selectAll(".link").data(links)
		vlinksEnter = vlinks.enter()
		vlinksEnter.append("line")
			.classed("link", true)

		vnodes = viewport.selectAll(".node").data(nodes)
		vnodesEnter = vnodes.enter()
		vnodesEnter = vnodesEnter.append("g")
			.classed("node", true)
			.attr("title", (d) -> d.title)
			.on("mouseover", (d) ->
				showTooltip(d.authors + ": " + d.title)
				d3.select(@).style("fill", "red")
			)
			.on("mouseout", (d) ->
				hideTooltip()
				d3.select(@).style("fill", "black")
			)

		vnodesEnter.append("circle")
			.attr("r", 2)
		vnodesExit = vnodes.exit()
		vnodesExit.remove()

		# layout:
		force.nodes(nodes)
		force.links(links)

		force.on "tick", tick

		force.start()
		for i in [0..10]
			force.tick()
		force.stop()

		tick({}, true)

		console.log "done rendering"

		svg.call(d3.behavior.zoom().on("zoom", redraw))

	# show the graph model
	setup()
