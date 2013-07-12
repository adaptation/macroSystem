_ = require 'underscore'
node = require './node.coffee'

exports.trace = (Node,env=null)->
  switch Node.type
    when "Program"
      exports.trace Node.body[0],env
      Node
    when "ExpressionStatement"
      exports.trace Node.expr,env
    when "FunctionExpression"
      exports.trace Node.body,env
    when 'BinaryExpression'
      env
    when 'IfStatement'
      exports.trace Node.body,env
      exports.trace Node.cond,env
      if Node.else
        exports.trace Node.else,env
    when 'Class'
      if Node.name?
        addVariable(Node.name.toString(),env)
        name = Node.name
      else
        name = new node.Identifier("_Class")
      top = getTopEnv(env)
      newEnv = {variable:[],parent:env,className:name,constructor:false}
      Node.env = newEnv
      top.extend = (Node.parent?) or (top.extend)
      # console.log "top:",getTopEnv env
      exports.trace Node.body,newEnv
    when "Literal","Operator", "Identifier","Bool","Member","New","String","Return","Array"
      env
    when "BlockStatement"
      if env is null
        newEnv = {variable:[],parent:null,extend:false}
      else
        newEnv = {variable:[],parent:env}
      Node.env = traceBlock Node.block,newEnv
      env
    when "AssignmentExpression"
      left = Node.left
      if left.type is "Member"
        if left.prop.length is 0 and left.obj.type is "Identifier"
          addVariable(left.obj.toString() ,env)
      exports.trace Node.right,env
      env
    when "InsAssign"
      exports.trace Node.right
      Node.className = env.parent.className
      env
    when "Constructor"
      exports.trace Node.body,env
      Node.className = env.parent.className
      env.parent.constructor = true
      env
    else
      console.log "Trace error"
      console.log Node.type
      env

traceBlock = (block,env)->
  for elem in block
    exports.trace elem,env
  env

addVariable = (v,env)->
  if !(_.find env.variable,(x)-> x is v)
    env.variable.push v

getTopEnv = (env)->
  if env.parent is null
    env
  else
    getTopEnv env.parent