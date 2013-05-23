exports.Program = class Program
  constructor:(@body)->
    @type = "Program"
  toString:()->
    @body.map((x)->x.toString())
  toESC:()->
    return {type:@type, body: @body.map((x)-> return x.toESC())}

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
      return "("+@args.toString()+")->"+@body.toString()
    else
      return "->"+@body.toString()
  toESC:()->
    if @args
      params = @args.map((x)-> return x.toESC())
    else
      params = null
    return {
      type: "FunctionExpression",
      id: null,
      params: params,
      defaults: [ ],
      rest: null,
      body: @body.toESC(),
      generator: true,
      expression: false
    }

exports.FourArthmeticOperation = class FourArthmeticOperation
  constructor:(@left,@op,@right)->
    @type = 'BinaryExpression'
  toString:()->
    return "("+@left.toString()+" "+@op.toString()+" "+@right.toString()+")"
  toESC:()->
    return {type: @type,
    operator: @op.toESC(),
    left:@left.toESC(),
    right:@right.toESC()
    }

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
    return "{" + @block.map((x)-> return x.toString()) + "}"
  toESC:()->
    block = @block.map((x)-> return x.toESC())
    block = (setVar @env).concat block
    return{type:@type, body: block}

makeId = (id)->
  return {type: "Identifier",name: id.toString()}

makeVarDeclarator = (id,init)->
  {
    type:"VariableDeclarator",
    id: makeId(id) ,
    init:init
  }

makeVarDeclaration = (vars)->
  return {
      type:"VariableDeclaration",
      declarations:vars,
      kind:"var"
    }

setVar = (env)->
  if env.variable.length > 0
    vars = env.variable.map (x)-> return makeVarDeclarator x,null
    return [ makeVarDeclaration vars ]
  else
    return []

exports.Assign = class Assign
  constructor:(@left,@right)->
    @type = "AssignmentExpression"
  toString:()->
    return @left.toString() + "=" + @right.toString()
  toESC:()->
    return {
      type:@type,
      operator:"=",
      left:@left.toESC(),
      right:@right.toESC()
      }

@Conditional = class Conditional
  constructor:(@cond,@body,@else)->
    @type = "IfStatement"
  toString:()->
    if @else?
      return " if " + @cond.toString() + " \n " + @body.toString() + " \n else " + @else.toString()
    else
      return " if " + @cond.toString() + " \n " + @body.toString() + " \n"
  toESC:()->
    if @else
      alternate = @else.toESC()
    else
      alternate = null
    return {
      type:@type,
      test:@cond.toESC(),
      consequent:@body.toESC(),
      alternate:alternate
    }

@Class = class Class
  constructor:(@name,@parent,@body)->
    @type = 'Class'
  toString:()->
    if @parent
      p = "extends "+@parent.toString()
    else
      p = ""
    "class "+@name.toString()+p+"\n"+@body.toString()
  toESC:()->
    console.log "Class body",@body
    r = {
        type: "CallExpression";
        callee:{
            type: "FunctionExpression",
            id: null,
            params: [],
            defaults: [ ],
            rest: null,
            body: @body.toESC(),
            generator: true,
            expression: false
        },
        arguments: [  ]
    }
    console.log @name
    if @name?
      return {
        type:"AssignmentExpression",
        operator:"=",
        left:@name.toESC(),
        right: r
      }
    else
      return r

@InsAssign = class InsAssign
  constructor:(@left,@right)->
    @type="InsAssign"
  toString:()->
    return @left.toString() + ":" + @right.toString()
  toESC:()->
    console.log "class Name", @className
    return {
      type:"AssignmentExpression",
      operator:"=",
      left: makeMember(makeMember(@className.toESC(),makeId("prototype")), @left.toESC()),
      right:@right.toESC()
      }

makeObj = (properties)->
  return {
    type:"ObjectExpression",
    properties:properties
  }

makeMember = (obj,prop)->
  return {
    type: "MemberExpression",
    object:obj,
    property:prop,
    computed:false
  }

setExtends = (ex)->
  extend = []
  extend.push makeVarDeclarator("__hasProp",makeMember(makeObj([]), makeId("hasOwnProperty")))
  return [ makeVarDeclaration extend ]
