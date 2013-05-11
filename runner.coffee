PEG = require './node_modules/pegjs/lib/peg'
ecg = require 'escodegen'
fs = require 'fs'
TR = require './trace.coffee'
{Preprocessor} = require './node_modules/preprocessor.js'
source = "./input.coffee"

csExpression = fs.readFileSync source , "utf8"
input = Preprocessor.processSync csExpression

console.log input

parser = PEG.buildParser fs.readFileSync('scratch.pegjs').toString()

ast = parser.parse input

console.log ast

p =  TR.trace ast

b = p.toESC()

console.log p.body[0].env
console.log b.body[0]



a = ecg.generate b
console.log a

#file = fs.openSync("./log.txt",'a')

#fs.writeSync(file,p[0].func.args[0].identifier)

#fs.closeSync(file)