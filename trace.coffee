_ = require 'underscore'

exports.trace = (Node,env=null)->
  switch Node.type
    when "Program"
      exports.trace Node.body[0],env
      Node
    when "ExpressionStatement"
      exports.trace Node.expr,env
    when "FunctionExpression"
      env
    when 'BinaryExpression'
      env
#    when "Literal"
#    when "Rankentifier"
#    when "Operator"
    when "BlockStatement"
      if env is null
        newEnv = {variable:[],parent:null}
      else
        newEnv = {variable:[],parent:env}
      Node.env = traceBlock Node.block,newEnv
      env
    when "AssignmentExpression"
      left = Node.left.toString()
      if !(_.find env.variable,(x)-> x is left)
        env.variable.push left
      env
    else
      console.log "Trace error"
      env

traceBlock = (block,env)->
  for  elem in block
    exports.trace elem,env
  env