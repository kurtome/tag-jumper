class ElementArticulator
	articulateElement: (element) =>
		if not this.isValid element
			return false

		if Math.random() < .9
			return false


		tjump.createPlatform element
		return true


	isValid: (element) =>
		if not element.offsetWidth
			return false

		if element.offsetWidth > tjump.canvas.offsetWidth / 2
			return false

		if element.offsetHeight > tjump.canvas.offsetHeight / 2
			return false
		
		if element.offsetWidth < 5
			return false
		
		if element.offsetHeight < 5
			return false

		return true


