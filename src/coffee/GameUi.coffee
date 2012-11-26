class GameUi
	constructor: (canvas, @world, loopCallback) ->
		width = canvas.offsetWidth
		height = canvas.offsetHeight
		@director = new CAAT.Director().initialize(width, height, canvas)
		@scene = @director.createScene()

		CAAT.PMR = tjump.SCALE
		CAAT.enableBox2DDebug(true, @director, @world)

		@scene.onRenderStart = loopCallback

		# Begin animating fps
		CAAT.loop tjump.FRAME_RATE

	getDefaultBodyDef : (actor) ->
		def = {
				x:                      actor.x,
				y:                      actor.y,
				bodyType:               Box2D.Dynamics.b2Body.b2_staticBody,
				density:                1,
				restitution:            1,
				friction:               1,
				image:                  null,
				polygonType:            CAAT.B2DPolygonBody.Type.BOX,
				bodyDef:                [
					{ x: actor.x,               y: actor.y },
					{ x: actor.x + actor.width, y: actor.y + actor.height }
				],
				bodyDefScale:           1,
				bodyDefScaleTolerance:  0,
				userData:               {}
			}
		return def


	bodyFromActor : (actor, bodyDef) => 
		body = CAAT.B2DPolygonBody.createPolygonBody(
			@world,
			bodyDef
		)
		return body

	rectBodyFromActor : (actor) => 
		body = CAAT.B2DPolygonBody.createPolygonBody(
			@world,
			this.getDefaultBodyDef(actor)
		)
		return body

	createRectActorWithBody: (def, @world) =>
		actor = new CAAT.Actor()
			.setLocation(def.left, def.top)
			.setSize(def.width, def.height)
			.setFillStyle('orange')
			.setAlpha(.6)

		@scene.addChild(actor)
		return actor

	createTextActor: (def) =>
		actor = new CAAT.TextActor()
			.setLocation(def.left, def.top)
			.setText(def.text)
			.setFillStyle('black')

		@scene.addChild(actor)
		return actor
		

