class Set
	constructor:(a...)->
		console.log a
		@member = a

test = new Set(1,2,3,4)
console.log test