start = Program
Symbol = symbol:([a-zA-Z] [a-zA-Z0-9]*) {symbol.join("")}
Number = num:(("+" / "-")? _ [1-9] [0-9]* ("." [0-9]+)? ) {num.join("")}
Whitespace = [\t\v\f \u00A0\uFEFF]
LineTerminator = [\n\r\u2028\u2029]
_  = (Whitespace / LineTerminator)*
__ = Whitespace+

Program = AdditiveStatement
AdditiveOperator = "+" / "-"
AdditiveStatement = head:Term tail:(_ op:AdditiveOperator _ term:Term { op:op, term:term })*
  {
root = head;

while (node = tail.shift()) {
  root = {
    left: root,
    op: node.op,
    right: node.term
  };
}
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
  = symbol:Symbol { identifier:symbol }
  / number:Number { {number} }