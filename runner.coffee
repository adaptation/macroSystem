PEG = require './node_modules/pegjs/lib/peg'
ecg = require 'escodegen'
fs = require 'fs'
TR = require './trace.coffee'
{Preprocessor} = require './preprocessor.js'
source = "./input.coffee"

csExpression = fs.readFileSync source , "utf8"
input = Preprocessor.processSync csExpression

console.log input

parser = PEG.buildParser fs.readFileSync('scratch.pegjs').toString()

ast = parser.parse input

#console.log ast

p = TR.trace ast
#console.log p

b = p.toESC()

#console.log b.body[0].body[0].expression.body.body[0]

func = {
  type: "FunctionExpression";
  id: {type:"Identifier",name:"test"};
  params: [{type:"Identifier",name:"a"} ];
  defaults: [ ];
  rest: null;
  body: {
    type: 'BlockStatement',
    body: [{type:"EmptyStatement"}]
  };
  generator: true;
  expression: false;
}

a = ecg.generate b
#console.log a

#file = fs.openSync("./log.txt",'a')

#fs.writeSync(file,p[0].func.args[0].identifier)

#fs.closeSync(file)