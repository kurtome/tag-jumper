class GameUi:
	constructor: (canvas, world, loopCallback) ->
		@director = new CAAT.Director().initialize(width, height, canvas)
		@scene = @director.createScene()


		CAAT.PMR = @director.width / 10
		CAAT.enableBox2DDebug( true, director, this.world );


		@scene.onRenderStart = loopCallback

		# Begin animating fps
		fps = 45
		CAAT.loop fps

	bodyFromActor : (actor, world) => 
		CAAT.B2DPolygonBody.createPolygonBody(
			world,
			{
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
		)

	createRectActorWithBody: (def) =>
		actor = new CAAT.Actor()
			.setLocation(def.top, def.left)
			.setSize(def.width, def.height)
			.setFillStyle('orange')

		body = this.bodyFromActor actor
		return body
		

