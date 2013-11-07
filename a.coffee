us = require('lodash')
a = [12,3,4,5]
b = (a,b)->
	switch a
		when 2
			"ok?"
		else
			a + b
c = us.foldl(a,b,2)
console.log a.join('')+"w"