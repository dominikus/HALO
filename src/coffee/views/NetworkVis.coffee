# vis
$(window).on "graph-created", () ->
	[svg, viewport, force, nodes, links, vnodes, vlinks, width, height, tooltip, offset, timescale, lineGenerator] = [undefined]

	cfg = {
		COLLISION_DISTANCE: 5
		COLLISION_FORCE: 0.5
	}

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
			.gravity(0)
			.friction(0.9)

		# tooltip
		tooltip = d3.select("#vis").append("div")
			.classed("ttip", true)

		lineGenerator = d3.svg.diagonal()
			.source((d) -> nodes[d.source])
			.target((d) -> nodes[d.target])

		render()

	collide = (node) ->
		r = node.radius + cfg.COLLISION_DISTANCE
		nx1 = node.x - r
		nx2 = node.x + r
		ny1 = node.y - r
		ny2 = node.y + r
		return (quad, x1, y1, x2, y2) ->
			if not node.fixed and quad.point and (quad.point != node)
				x = node.x - quad.point.x
				y = node.y - quad.point.y
				l = Math.sqrt(x * x + y * y)
				r = node.radius + quad.point.radius
				if l < r
					l = (l - r) / l * cfg.COLLISION_FORCE
					node.x -= x *= l
					node.y -= y *= l
					quad.point.x += x
					quad.point.y += y
			return x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1

	tick = (e, visible = true) ->
		k = .1 * e.alpha

		# collision detection
		q = d3.geom.quadtree(nodes)

		for i in [1...nodes.length]
			q.visit(collide(nodes[i]))

		# push nodes toward timeline position
		nodes.forEach (o,i) ->
			yr = +o.year
			o.y += ((height/2) - o.y) * k
			o.x += (timescale(yr) - o.x) * k

		if visible
			# update graphics
			vnodes
				.transition()
					.style("transform", (d,i) =>
						"translate(#{Math.round(d.x)}px, #{Math.round(d.y)}px)"
					)

			vlinks
				.transition()
					.attr("d", (d) ->
						return lineGenerator(d)
					)

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
			"type": d.get("Type")
			"year": d.get("Year")
			"label": d.get("label")
			})

		links = window.app.models.links.map(
			(d) ->
				sType = nodes[d.get("source")].type
				tType = nodes[d.get("target")].type
				return undefined if sType != "base" or tType != "base"
				return {
				"source": d.get("source")
				"target": d.get("target")
				"type": d.get("Type")
				}
			)


		# filter for base nodes
		nodes = _.filter(nodes, (d) ->
			d.type == "base"
		)
		links = _.filter(links, (d) -> d?)

		# create the timescale
		timescale = d3.scale.linear()
			.domain(d3.extent(nodes.map((d) -> +d.year)))
			.range([0, width])

		# graphical elements:

		# scale
		scale = viewport.selectAll(".scale").data(timescale.ticks())
		scaleEnter = scale.enter().append("g")
			.classed("scale", true)
		scaleEnter.append("line")
			.attr("x1", (d) -> timescale(d))
			.attr("x2", (d) -> timescale(d))
			.attr("y1", width / 2 -5)
			.attr("y2", width / 2 +5)
		scaleEnter.append("svg:text")
			.attr("x", (d) -> timescale(d))
			.attr("y", width / 2 + 20)
			.text((d) -> d)

		vlinks = viewport.selectAll(".link").data(links)
		vlinksEnter = vlinks.enter()
		vlinksEnter.append("path")
			.classed("link", true)

		vnodes = viewport.selectAll(".node").data(nodes)
		vnodesEnter = vnodes.enter()
		vnodesEnter = vnodesEnter.append("g")
			.classed("node", true)
			.attr("title", (d) -> d.title)
			.on("mouseover", (d) ->
				showTooltip(d.authors + "(#{+d.year})" + ": " + d.title)
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
		#force.links(links)

		force.on "tick", tick

		force.start()
		# for i in [0..100]
		# 	console.log "tick"
		# 	force.tick()
		# force.stop()

		#force.resume()

		console.log "done rendering"

		svg.call(d3.behavior.zoom().on("zoom", redraw))

	# show the graph model
	setup()
