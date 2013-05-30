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
  toESC:()-> return makeExpr @expr.toESC()

makeExpr = (expr)->
  return {
    type:"ExpressionStatement",
    expression:expr
  }

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
      params = []
    return makeFunc null,params,@body.toESC(),false

makeFunc = (id,params,body,ex)->
  return {
      type: "FunctionExpression",
      id: id,
      params: params,
      defaults: [ ],
      rest: null,
      body: body,
      generator: true,
      expression: ex
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
    dec = (setVar @env).concat(setExtends @env)
    if dec.length > 0
      declarations = makeVarDeclaration (dec)
      # console.log "Decs:",declarations
      block.unshift(declarations)
    return makeBlock block

makeBlock = (body)->
  return {
    type:"BlockStatement",
    body:body
  }

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
    return vars
  else
    return []

exports.Assign = class Assign
  constructor:(@left,@right)->
    @type = "AssignmentExpression"
  toString:()->
    return @left.toString() + "=" + @right.toString()
  toESC:()->
    return makeAssign @left.toESC(), @right.toESC()

makeAssign = (left,right)->
  return {
    type:"AssignmentExpression",
    operator:"=",
    left:left,
    right:right
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
    return makeIf @cond.toESC(), @body.toESC(), alternate

makeIf = (test,consequent,alter)->
  return {
    type:"IfStatement",
    test:test,
    consequent:consequent,
    alternate:alter
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
    name = @env.className.toESC()
    if @body.expr?
      body = makeBlock [ @body.toESC() ]
    else
      body = @body.toESC()
    args = []
    if @parent?
      parent = @parent.toESC()
      if !@env.constructor
        body.body.unshift (makeExpr (makeFunc name,[],(makeReturn ( makeCall (makeMember (makeMember (makeMember name,(makeId "__super__"),false),(makeId "constructor"),false),(makeId "apply"),false),[makeThis(),(makeId "arguments")])),false))
      body.body.unshift (makeExpr makeCall( (makeId "__extends"), [ (name) ,(makeId "_super")] ))
      args.push parent
    body.body.push (makeReturn name)
    r = makeCall (makeFunc null,[],body,false), args
    if @name?
      return {
        type:"AssignmentExpression",
        operator:"=",
        left:@name.toESC(),
        right: r
      }
    else
      return r

makeCall = (callee,args)->
  return {
    type: "CallExpression",
    callee:callee,
    arguments:args
  }

@InsAssign = class InsAssign
  constructor:(@left,@right)->
    @type="InsAssign"
  toString:()->
    return @left.toString() + ":" + @right.toString()
  toESC:()->
    return makeAssign makeMember(makeMember(@className.toESC(),makeId("prototype")), @left.toESC(),false), @right.toESC()



makeObj = (properties)->
  return {
    type:"ObjectExpression",
    properties:properties
  }

makeMember = (obj,prop,cmp)->
  return {
    type: "MemberExpression",
    object:obj,
    property:prop,
    computed:cmp
  }

makeReturn = (arg)->
  return {
    type:"ReturnStatement",
    argument: arg
  }

makeForIn = (left,right,body)->
  return {
    type:"ForInStatement",
    left:left,
    right:right,
    body:body,
    each:false
    }

makeThis = ()->
  return {
    type:"ThisExpression"
  }

makeNew = (call,args)->
  return {
    type:"NewExpression",
    callee:call,
    arguments:args
  }



setExtends = (env)->
  extend = []
  if env.extend
    extend.push makeVarDeclarator "__hasProp", makeMember(makeObj([]), makeId("hasOwnProperty"),false)
    ex =  makeVarDeclarator "__extends",
      makeFunc(null,[(makeId "child"), (makeId "parent")],
        (makeBlock [
          makeForIn(
            (makeVarDeclaration [ makeVarDeclarator("key",null) ]) ,
            (makeId "parent"),
            (makeIf (makeCall (makeMember (makeId "__hasProp"),(makeId "call" ),false), [(makeId "parent"), (makeId "key")] ),
              makeExpr makeAssign (makeMember (makeId "child"),(makeId "key"),true ),
                (makeMember (makeId "parent"),(makeId "key"),true ) ,
              null)
          ),
          (makeExpr makeFunc(
            (makeId "ctor"),
            [],
            (makeAssign (makeMember makeThis(),(makeId "constructor"),false),(makeId "child")),
            true)),
          (makeExpr makeAssign(
            (makeMember (makeId "ctor"),(makeId "prototype")),
            (makeMember (makeId "parent"),(makeId "prototype")))),
          (makeExpr makeAssign(
            (makeMember (makeId "child"),(makeId "prototype")),
            (makeNew (makeId "ctor"),[]))),
          (makeExpr makeAssign(
            (makeMember (makeId "child"),(makeId "__super__")),
            (makeMember (makeId "parent"),(makeId "prototype")))),
          (makeReturn (makeId "child"))
        ]),false)
    extend.push ex
    # console.log "Test:",test.init.body.body[1].expression.body
    return extend
  else
    return extend

@Constructor = class Constructor
  constructor:(@body)->
    @type = "Constructor"
  toString:()->
    "constructor:"+@body.toString()
  toESC:()->
    return (makeFunc @className.toESC(),[],@body.toESC(),true)
