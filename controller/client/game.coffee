canvas = null
filterID = 0

colorToStrong = (d) ->
	c = Number(d).toString(16);
	return "#" + ( "000000".substr( 0, 6 - c.length ) + c.toUpperCase() )

############
## Filter ##
############
class Filter
	#@color: 0x000
	@line: null
	@id: 0
	@noCollision: false

	constructor: (begin, end, color) ->
		@color = color
		@line = canvas.display.line({
			start: begin,
			end: end,
			stroke: "5px "+colorToStrong(color),
			cap: "round"
		})

		@id = filterID++

		point1 = canvas.display.arc({
			x: begin.x, y: begin.y,
			start: 1, end: 0,
			radius: 1,
			stroke: "15px "+colorToStrong(color),
			filter: this
		})

		point2 = canvas.display.arc({
			x: end.x, y: end.y,
			start: 1, end: 0,
			radius: 1,
			stroke: "15px "+colorToStrong(color),
			filter: this
		})


		# Add to canvas
		canvas.addChild(@line)
		canvas.addChild(point1)
		canvas.addChild(point2)

		# Set drag and drop actions
		point1.dragAndDrop({
				start: -> @filter.noCollision = true
				move: -> @filter.line.start = {x: @x, y: @y}
				end: -> @filter.noCollision = false
			})
		point2.dragAndDrop({
				start: -> @filter.noCollision = true
				move: -> @filter.line.end = {x: @x, y: @y}
				end: -> @filter.noCollision = false
			})

	testCollision: (rayClass) ->
		if @noCollision
			return null

		for ray in rayClass.raySegments

			z1 = @line.start.x - @line.end.x
			z2 = ray.start.x - ray.end.x
			z3 = @line.start.y - @line.end.y
			z4 = ray.start.y - ray.end.y

			d  = z1 * z4 - z3 * z2;
			 
			# If d is zero, there is no intersection
			if d != 0
				# Get the x and y
				pre  = (@line.start.x * @line.end.y - @line.start.y * @line.end.x)
				post = (ray.start.x * ray.end.y - ray.start.y * ray.end.x)
				x = ( pre * z2 - z1 * post ) / d;
				y = ( pre * z4 - z3 * post ) / d;
				 
				# Check if the x and y coordinates are within both lines
				if x < Math.min(@line.start.x, @line.end.x) ||
				   x > Math.max(@line.start.x, @line.end.x) ||
				   x < Math.min(ray.start.x, ray.end.x) ||
				   x > Math.max(ray.start.x, ray.end.x) ||
				   y < Math.min(@line.start.y, @line.end.y) || 
				   y > Math.max(@line.start.y, @line.end.y) ||
				   y < Math.min(ray.start.y, ray.end.y) ||
				   y > Math.max(ray.start.y, ray.end.y) 
					true
				else
					pos = {x: x, y: y}

					newColor = ray.color - @color
					rayClass.cut(@id, ray, pos, newColor)

					# Return the point of intersection
					return pos


#########
## Ray ##
#########
class Ray
	raySegments: []
	direction: { x: 0, y: 0 }
	isActive: true
	lastCut: {}

	constructor: (begin, direction, color) ->
		@direction = direction
		newSeg = @newSegment(begin, color, true)
		newSeg.first = true


	newSegment: (begin, color, isSource) ->
		ray = canvas.display.line({
			start: begin,
			end: {x: begin.x+@direction.x, y: begin.y+@direction.y},
			stroke: "2px "+colorToStrong(color),
			color: color,
			cap: "round"
		})
		canvas.addChild(ray)

		ray.spread = true
		ray.isSource = isSource
		@raySegments.push(ray)

		ray.cutBy = []

		return ray


	step: () ->
		for ray in @raySegments
			if ray.spread == true
				ray.end = {x: ray.end.x+@direction.x, y: ray.end.y+@direction.y}
			if @isActive == false || ray.isSource == false
				ray.start = {x: ray.start.x+@direction.x, y: ray.start.y+@direction.y}

			if !ray.first
				ray.isSource = false

			ray.spread = true
				

	cut: (filterId, segment, pos, color) ->
		console.log "Cut? "
		# Stop here, if ...
		if segment.cutBy[filterId] == true # that segment is already filtered or
			segment.spread = true
			return null

		if (@lastCut[filterId] && # ... or the same filter does not have changed its position
		   Math.round(pos.x) == Math.round(@lastCut[filterId].x) &&
		   Math.round(pos.y) == Math.round(@lastCut[filterId].y))
		    
			segment.spread = false
			if segment.next != undefined #&& segment.next.next == undefined
				segment.next.isSource = true

			return null


		@lastCut[filterId] = pos

		console.log "Cut!"

		# New segment, beginning after the filter with new color
		newSeg = @newSegment(pos, color, true)
		newSeg.cutBy[filterId] = true

		# And a "new" one, for the rest of the ray
		if Math.ceil(pos.x) != Math.ceil(segment.end.x) || 
		   Math.ceil(pos.y) != Math.ceil(segment.end.y)
			newSeg2 = @newSegment(pos, segment.color, false)
			newSeg2.end = segment.end
			newSeg2.stroke = segment.stroke

		# Stop spreading the old segment
		segment.spread = false
		segment.end = pos

		segment.next = newSeg


##########
## Game ##
##########
class Game
	rays: []
	filters: []

	constructor: () ->
		canvas = oCanvas.create({
			canvas: "#canvas",
			background: "#222",
			fps: 60
		})


	##
	# Add a new color "filter" line into the game 
	##
	addFilter: (begin, end, color) ->
		filter = new Filter(begin, end, color)
		@filters.push( filter )


	##
	# Add a new "ray"
	##
	addRay: (begin, direction, color) ->
		ray = new Ray(begin, direction, color)
		@rays.push(ray)

	run: () ->
		canvas.setLoop( =>
				for ray in @rays
					ray.step()

					for filter in @filters
						filter.testCollision(ray)
			).start()


game = new Game()

game.addFilter({ x: 80, y: 160 }, { x: 280, y: 170 }, 0x00aa00)
game.addFilter({ x: 180, y: 60 }, { x: 80, y: 70 }, 0x0000aa)

game.addRay({ x: 20, y: 60 }, { x: 0.1, y: .2 }, 0x00aaaa)


game.run()
