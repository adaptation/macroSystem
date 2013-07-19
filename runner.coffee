PEG = require 'pegjs'
ecg = require 'escodegen'
fs = require 'fs'
TR = require './trace.coffee'
{Preprocessor} = require './preprocessor.coffee'
source = "./input2.coffee"

csExpression = fs.readFileSync source , "utf8"
input = Preprocessor.processSync csExpression
# console.log input

parser = PEG.buildParser fs.readFileSync('scratch.pegjs').toString()

ast = parser.parse input
# console.log "\nAST:",ast#.body[0].block[0] #.body[0].block[0].expr.body.block

# test = ecg.generate (ast.toESC())
# console.log test

p = TR.trace ast
# console.log "\np:", p#.body[0].block[0].expr.body

b =  ast.toESC() #p.toESC()
# console.log "\nb:", b.body[0].body[1]#.expression#.right.callee.body.body[1].expression.left.property #.body[0].body[2].expression.right.body.body[2].consequent.body

a = ecg.generate b
console.log a

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

func = {
  type: "FunctionExpression";
  id: {type:"Identifier",name:"test"};
  params: [{type:"Identifier",name:"a"} ];
  defaults: [ ];
  rest: null;
  body: {
    type: 'BlockStatement',
    body: [cond]
  };
  generator: false;
  expression: false;
}

expr = {
  type:"ExpressionStatement",
  expression:func
}

binary = {
  type: 'BinaryExpression',
  operator: "<",
  left:{type:'Literal',value:1},
  right:{
    type: 'BinaryExpression',
    operator: "+",
    left:{type:'Literal',value:3},
    right:{type:'Literal',value:4}
  }
}
{
    type: 'BinaryExpression',
    operator: "===",
    left:{type:'Literal',value:1},
    right:{type:'Literal',value:2}
  }
logical = {
  type:"LogicalExpression",
  operator:"||",
  left:{
    type: 'BinaryExpression',
    operator: ">",
    left:{type:'Literal',value:1},
    right:{type:'Literal',value:2}
  },
  right:{
    type: 'LogicalExpression',
    operator: "&&",
    left:{type:'Literal',value:3},
    right:{type:'Literal',value:4}
  }
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
  computed: true;
}

obj = {
  type: "ObjectExpression";
  properties: [  ];
}

forin = {
  type: "ForInStatement";
  left: {
    type: "VariableDeclaration";
    declarations: [
      {
        type: "VariableDeclarator";
        id: { type: 'Identifier', name: 'key' },
        init: { type: 'Identifier', name: 'test' },
      }
    ],
    kind: "var",
  },
  right: { type: 'Identifier', name: 'parent' },
  body:{
    type: 'ExpressionStatement',
    expression: { type: 'Identifier', name: 'c' }
  },
  each: false;
}

{type:'Program',
body:[{type:'BlockStatement',
body:[{type:'ExpressionStatement',
expression:{type:'BinaryExpression',
op:'+',
left:{type:'Literal',value:1},
right:{type:'Literal',value:1}}}]}]}

{type:'Program',
body:[{type:'BlockStatement',
Block:[{type:'VariableDeclaration',
declarations:[{type:'VariableDeclarator',
id:{type:'Identifier',name:'a'},
init:null}],kind:'var'},
{type:'ExpressionStatement',
expression:{type:'AssignmentExpression',
left:{type:'Identifier',name:'a'},
right:{type:'Literal',value:1}}}]}]}

{type:'Program',body:[{type:'BlockStatement',
body:[{type:'VariableDeclaration',
declarations:[{type:'VariableDeclarator',
id:{type:'Identifier',name:'a'},
init:null}],kind:'var'},
{type:'IfStatement',
test:{type:'AssignmentExpression',
operator:'=',left:{type:'Identifier',name:'a'},
right:{type:'Literal',value:1}},
consequent:{type:'BlockStatement',
body:[{type: 'ExpressionStatement',
expression:{ type: 'BinaryExpression',
operator: '-',left:{type:'Identifier',name: 'a' },
right:{type:'Literal', value: 3}}}]},
alternate:{type:'BlockStatement',
body:[{ type: 'ExpressionStatement',
expression:{type:'BinaryExpression',
operator: '*',left: { type: 'Identifier', name: 'a' },
right: { type: 'Literal', value: 5}}}]}}]}]}

{type:'Program',body:[{type:'BlockStatement',
body:[{type:'ExpressionStatement',
expression:{type:'FunctionExpression',
id:null,params:[{type:'Identifier',name:'a'}],
defaults:[],rest:null,body:{type:'BlockStatement',
body:{type:'BlockStatement',
body:[{ type: 'ExpressionStatement',
expression:{type:'BinaryExpression',operator:'-',
left:{type:'Identifier',name:'a'},
right:{type:'Literal',value:1}}}]}},
generator:true,expression:false}}]}]}

{type:'Program',body:[{type:'BlockStatement',
body:[{type:'VariableDeclaration',
declarations:[{type:'VariableDeclarator',
id:{type:'Identifier',name:'a'},
init:null}],kind:'var'},
{type:'ExpressionStatement',
expression:{type:'AssignmentExpression',
operator: '=',left: { type: 'Identifier', name: 'A' },
right:{type:'CallExpression',
callee:{type:'FunctionExpression',
id: null,params: [],defaults: [],rest: null,
body:{type:'BlockStatement',
body:[{type:'ExpressionStatement', expression:{ type: 'AssignmentExpression',
operator: '=',left: { type: 'Identifier', name: 'A' },
right:{type:'FunctionExpression',
id: null,params:[],defaults:[],rest:null,
body:{type:'BlockStatement',body:[{ type: 'VariableDeclaration',
declarations:[ { type: 'VariableDeclarator',
id: { type: 'Identifier', name: 'a' },
init: null } ],kind: 'var' },
{ type: 'ExpressionStatement', expression:{type:'AssignmentExpression',
left:{type:'Identifier',name:'a'},
right:{type:'Literal',value:2}}}]},
generator: true,
expression: false } }},
{type:'ExpressionStatement',expression:{type:'AssignmentExpression',
operator:'=',left:{type:'MemberExpression',
object:{type:'MemberExpression',
object:{ type: 'MemberExpression',
object: { type: 'Identifier', name: 'A' },
property: { type: 'Identifier', name: 'prototype' },
computed: undefined },
property:{ type: 'Identifier', name: 'b' },
computed:undefined },property:{type:'Identifier', name:'b'},computed:false },
right: { type: 'Literal', value: 1 } }},
{type:'ReturnStatement',argument:{type:'Identifier',name:'A'}}]},
generator:true,expression:false},
arguments:[]}}}
]}]}



# a = ecg.generate b
# console.log a

#file = fs.openSync("./log.txt",'a')

#fs.writeSync(file,p[0].func.args[0].identifier)

#fs.closeSync(file)