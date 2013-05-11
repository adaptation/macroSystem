{
console.log("OK!");
}

start
  = expr
//  =test
test = "abc" ![x]

expr = (additive / func)*

literal = integer / identifier

space = [\t\v\f \u00A0\uFEFF]
lineTerminator = [\n\r\u2028\u2029]
_  = (space / lineTerminator)*
__ = space+

identifier =  head:[a-zA-Z] tail:[a-zA-Z0-9]* {
	   tail.unshift(head);
	   return "{identifier : "+tail.join("")+"}";
}

args = (head:identifier tail:(__ a:identifier _ {return a} )* {tail.unshift(head); return tail})

func = "(" args:args ")" _ "->"_ body:expr {
     return "func:{args : ["+args+"] ,body : {"+body+"  }}";
}

addOperator = "+" / "-"

additive
  = left:multiplicative _ op:addOperator _ right:additive { return "{left : "+left+", op : "+op+" , right : "+right+"}"; }
  / multiplicative

multiOperator = "*"/ "/"

multiplicative
  = left:primary _ op:multiOperator _ right:multiplicative { return "{left : "+left+", op : "+op+", right : "+right+"}"; }
  / primary

primary
  = literal
  / "(" _ additive:additive _ ")" { return additive; }

integer "integer"
  = digits:[0-9]+ { return "{int : "+digits.join("")+"}"; }
