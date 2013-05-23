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
      exports.trace Node.body
      if Node.else
        exports.trace Node.else
    when 'Class'
      if Node.name?
        addVariable(Node.name.toString(),env)
        env.className = Node.name
      else
        env.className = new node.Identifier("_Class")
      exports.trace Node.body,env
    when "Literal","Operator", "Indentifier"
      env
    when "BlockStatement"
      if env is null
        newEnv = {variable:[],parent:null}
      else
        newEnv = {variable:[],parent:env}
      Node.env = traceBlock Node.block,newEnv
      env
    when "AssignmentExpression"
      left = Node.left.toString()
      addVariable(left,env)
      exports.trace Node.right,env
      env
    when "InsAssign"
      exports.trace Node.right
      Node.className = env.parent.className
      env
    else
      console.log "Trace error"
      env

traceBlock = (block,env)->
  for elem in block
    exports.trace elem,env
  env

addVariable = (v,env)->
  if !(_.find env.variable,(x)-> x is v)
    env.variable.push v