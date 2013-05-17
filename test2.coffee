SS = require 'StringScanner'

ss = new SS "(a,b)->\n  c = a + 1\n  d = b+ 2\n  c + d\n"
a = []

b = if 0 then "a" else "b"
ws = '\\t\\x0B\\f\\r \\xA0\\u1680\\u180E\\u2000-\\u200A\\u202F\\u205F\\u3000\\uFEFF'
c = ""
# d = / a /
console.log ss.scan /// #{c} ///
console.log if null then "a"
x = (a)->
	console.log a
	return if yes
	console.log "end"

x 2