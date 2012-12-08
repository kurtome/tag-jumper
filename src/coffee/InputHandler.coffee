class InputHandler
	keysDown: {}

	# Listen for keys being presses and being released. As this happens
	# add and remove them from the key store.
	constructor: (@player) ->
		$("body").keydown (e) => @keysDown[e.keyCode] = true
		$("body").keyup (e)   => delete @keysDown[e.keyCode]

	# Every time update is called from the game loop act on the currently
	# pressed keys by passing the events on to the world.
	update: () ->
		@player.up()    if 38 of @keysDown
		@player.down()  if 40 of @keysDown
		@player.left()  if 37 of @keysDown
		@player.right() if 39 of @keysDown

