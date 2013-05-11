exports.Program = class Program
  constructor:(@body)->
    @type = "Program"
  toString:()->
    @body.map((x)->x.toString())
  toESC:()->
    return {type:@type, body: @body.map((x)-> return x.toESC());}

exports.Expr = class Expr
  constructor:(@expr)->
    @type = "ExpressionStatement"
  toString:()-> return @expr.toString()
  toESC:()-> return {type:@type,expression:@expr.toESC()}

exports.Function = class Function
  constructor:(@args,@body)->
    @type = "FunctionExpression"
  toString:()->
    if @args
      return "("+@args.toString()+")->{\n"+@body.toString()+"}"
    else
      return "->{\n"+@body.toString()+"}"

exports.FourArthmeticOperation = class FourArthmeticOperation
  constructor:(@left,@op,@right)->
    @type = 'BinaryExpression'
  toString:()->
    return "("+@left.toString()+" "+@op.toString()+" "+@right.toString()+")"
  toESC:()->
    return {type: @type,
    operator: @op.toESC();
    left:@left.toESC();
    right:@right.toESC()
    }

#console.log new Function(1,2).toString()

exports.Literal = class Literal
  constructor:(@literal)->
    @type = "Literal"
  toString:()-> return @literal.toString()
  toESC:()-> return {type: @type, value: @literal}

exports.Int = class Int extends Literal

exports.Identifier = class Identifier
  constructor:(@identifier)->
    @type = "Identifier"
  toString:()->
    return @identifier
  toESC:()->
    return {type: @type,name: @identifier.toString()}

exports.Operator = class Operator
  constructor:(@op)->
    @type = "Operator"
  toString:()->
    return @op
  toESC:()->
    return @op

exports.Block = class Block
  constructor:(@block)->
    @type = "BlockStatement"
  toString:()->
    return @block.map((x)-> return x.toString())
  toESC:()->
    block = @block.map((x)-> return x.toESC())
    console.log setVar @env
    block.unshift setVar @env
    return{type:@type, body: block}

makeVarDeclarator = (id)->
  {
    type:"VariableDeclarator",
    id: {type: "Identifier",name: id.toString()},
    init:null
  }

setVar = (env)->
  vars = env.variable.map (x)-> return makeVarDeclarator x
  {
    type:"VariableDeclaration";
    declarations:vars
    kind:"var";
  }

exports.Assign = class Assign
  constructor:(@left,@right)->
    @type = "AssignmentExpression"
  toString:()->
    return @left.toString() + "=" + @right.toString()
  toESC:()->
    return {
      type:@type;
      operator:"=";
      left:@left.toESC();
      right:@right.toESC()
      }