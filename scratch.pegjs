{
var node= require('../../../node.js');
var us = require('underscore');

}
start
  = program

program = leader:TERMINATOR? _ b:toplevelBlock {return new node.Program([b])}

toplevelBlock
  = s:toplevelStatement ss:(_ TERMINATOR _ toplevelStatement)* TERMINATOR? {
  return new node.Block([s].concat(ss.map(function(s){ return s[3]; })));
    }
toplevelStatement = s:statement { return s; }

block = s:statement ss:(_ TERMINATOR _ statement)* TERMINATOR? {
if( ss != null ){
return new node.Block(us.foldl(ss.map(function(as){ return as[3]; }) , function(ary, elem){ ary.push(elem); return ary; }, [s]));}
}


statement = ex:(assign / expr) {return new node.Expr(ex);}

expr = ex:(additive / func) {return ex;}

literal = integer

whiteSpace = [\u0009\u000B\u000C\u0020\u00A0\uFEFF\u1680\u180E\u2000-\u200A\u202F\u205F\u3000]
  / "\r" / s:("\\" "\r"? "\n") {return s.join("");}

_  = __?
__ = ws:whiteSpace+ {return ws.join("");}

INDENT = ws:__ "\uEFEF" {return ws; }
DEDENT = ws:(TERMINATOR? _) "\uEFFE" { return ws.join(""); }
TERM = n:("\r"? "\n"){return n.join("");} / "\uEFFF" { return ''; }
TERMINATOR = t:(_ TERM)+ {return t.join("");}
TERMINDENT = t:(TERMINATOR INDENT) {return t.join("");}


identifier =  head:[a-zA-Z] tail:[a-zA-Z0-9]* {
   tail.unshift(head);
   return new node.Identifier(tail.join(""));
}

args = a:identifier as:(_ ("," TERMINATOR? / TERMINATOR) _ identifier ){
     return [a].concat(as.map(function(x){return x[3]}));
}

funcBody = _ TERMINDENT b:block DEDENT {return new node.Block(b); }
    / _ s:statement {return new node.Block([s]); }

func = params:("(" _ (TERMINDENT p:args DEDENT TERMINATOR {return p;} / args)? _ ")" _ )? "->" body:funcBody? {

}

//func = "(" args:args ")" "->" body:funcBody {
//     return new node.Function(args ,body);
//}




assign = left:identifier _ "=" !"=" right:(TERMINDENT e:expr DEDENT { return e; } / TERMINATOR? _ e:expr   { return e; }){  
       return new node.Assign(left,right);
      }

addOperator = "+" / "-"

additive
  = left:multiplicative _ op:addOperator _ right:additive { return new node.FourArthmeticOperation(left,new node.Operator(op),right); }
  / multiplicative

multiOperator = "*"/ "/"

multiplicative
  = left:primary _ op:multiOperator _ right:multiplicative { return new node.FourArthmeticOperation(left,new node.Operator(op),right); }
  / primary

primary
  = (literal / identifier)
  / "(" _ additive:additive _ ")" { return additive; }

integer "integer"
  = digits:[0-9]+ { return new node.Int(parseInt(digits.join(""), 10)); }
