start = (Program _)*

Var= head:[a-zA-Z] tail:[a-zA-Z0-9_]* {
    head + tail.join('')
  }
Number = sign:("+" / "-")? _ digits:[0-9]+ {
    parseInt(digits.join(''), 10) * (if sign == '-' then -1 else 1)
  }

Whitespace = [ \t\n\r]
LineTerminator = [\\n]
_  = (Whitespace / LineTerminator)*
__ = Whitespace+

Program = AdditiveStatement
AdditiveOperator = "+" / "-"
AdditiveStatement = head:Term tail:(_ op:AdditiveOperator _ term:Term { op:op, term:term })*
  {
    root = head
    while node = tail.shift()
      root =
        left : root
        op   : node.op
        right: node.term
    root
  }
MulticativeOperator = "*" / "/"
Term
  = head:Primary tail:(_ op:MulticativeOperator _ primary:Primary { op:op, primary:primary })*
  {
    root = head
    while node = tail.shift()
      root =
        left : root
        op   : node.op
        right: node.primary
    root
  }
  / Primary

Primary
  = "(" _ statement:AdditiveStatement _ ")" { statement }
  / Value

Value
  = symbol:Var { symbol }
  / number:Number { number }
