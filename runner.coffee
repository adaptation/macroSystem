PEG = require 'pegjs'
ecg = require 'escodegen'
fs = require 'fs'
TR = require './trace.coffee'
{Preprocessor} = require './preprocessor.coffee'
source = "./input.coffee"

csExpression = fs.readFileSync source , "utf8"
input = Preprocessor.processSync csExpression

# console.log input

parser = PEG.buildParser fs.readFileSync('scratch.pegjs').toString()

ast = parser.parse input

# console.log "\nAST:",ast.body[0].block[0].expr.body.block

p = TR.trace ast
# console.log "\np:", p.body[0].block[0].expr.body.block[0]

b = p.toESC()

# console.log "\nb:", b.body[0].body[2].expression.right.body.body[2].consequent.body

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

cond = {
  type: 'IfStatement',
  test: {
    type: 'AssignmentExpression',
    operator: '=',
    left: { type: 'Identifier', name: 'a' },
    right: { type: 'Identifier', name: 'b' } },
  consequent: {
    type: 'BlockStatement',
    body: [ { type: 'ExpressionStatement',
    expression: { type: 'Identifier', name: 'c' }
      }  ] },
  alternate: null
}


call= {
  type: "CallExpression";
  callee:{
    type: "MemberExpression";
    object: {type:"Identifier",name:"A"};
    property:{type:"Identifier",name:"a"}
    computed:false
  };
  arguments: [  ];
}

member= {
  type: "MemberExpression";
  object: {
    type: "CallExpression";
    callee: {type:"Identifier",name:"test"};
    arguments: [  ];
  };
  property:{type:"Identifier",name:"A"};
  computed: false;
}

obj = {
  type: "ObjectExpression";
  properties: [  ];
}



a = ecg.generate b
console.log a

#file = fs.openSync("./log.txt",'a')

#fs.writeSync(file,p[0].func.args[0].identifier)

#fs.closeSync(file)