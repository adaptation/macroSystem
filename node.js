// Generated by CoffeeScript 1.4.0
(function() {
  var Assign, Block, Expr, FourArthmeticOperation, Function, Identifier, Int, Literal, Operator, Program, makeVarDeclarator, setVar,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  exports.Program = Program = (function() {

    function Program(body) {
      this.body = body;
      this.type = "Program";
    }

    Program.prototype.toString = function() {
      return this.body.map(function(x) {
        return x.toString();
      });
    };

    Program.prototype.toESC = function() {
      return {
        type: this.type,
        body: this.body.map(function(x) {
          return x.toESC();
        })
      };
    };

    return Program;

  })();

  exports.Expr = Expr = (function() {

    function Expr(expr) {
      this.expr = expr;
      this.type = "ExpressionStatement";
    }

    Expr.prototype.toString = function() {
      return this.expr.toString();
    };

    Expr.prototype.toESC = function() {
      return {
        type: this.type,
        expression: this.expr.toESC()
      };
    };

    return Expr;

  })();

  exports.Function = Function = (function() {

    function Function(args, body) {
      this.args = args;
      this.body = body;
      this.type = "FunctionExpression";
    }

    Function.prototype.toString = function() {
      if (this.args) {
        return "(" + this.args.toString() + ")->{" + this.body.toString() + "}";
      } else {
        return "->{" + this.body.toString() + "}";
      }
    };

    Function.prototype.toESC = function() {
      var params;
      if (this.args) {
        params = this.args.map(function(x) {
          return x.toESC();
        });
      } else {
        params = null;
      }
      return {
        type: "FunctionExpression",
        id: null,
        params: params,
        defaults: [],
        rest: null,
        body: this.body.toESC(),
        generator: true,
        expression: false
      };
    };

    return Function;

  })();

  exports.FourArthmeticOperation = FourArthmeticOperation = (function() {

    function FourArthmeticOperation(left, op, right) {
      this.left = left;
      this.op = op;
      this.right = right;
      this.type = 'BinaryExpression';
    }

    FourArthmeticOperation.prototype.toString = function() {
      return "(" + this.left.toString() + " " + this.op.toString() + " " + this.right.toString() + ")";
    };

    FourArthmeticOperation.prototype.toESC = function() {
      return {
        type: this.type,
        operator: this.op.toESC(),
        left: this.left.toESC(),
        right: this.right.toESC()
      };
    };

    return FourArthmeticOperation;

  })();

  exports.Literal = Literal = (function() {

    function Literal(literal) {
      this.literal = literal;
      this.type = "Literal";
    }

    Literal.prototype.toString = function() {
      return this.literal.toString();
    };

    Literal.prototype.toESC = function() {
      return {
        type: this.type,
        value: this.literal
      };
    };

    return Literal;

  })();

  exports.Int = Int = (function(_super) {

    __extends(Int, _super);

    function Int() {
      return Int.__super__.constructor.apply(this, arguments);
    }

    return Int;

  })(Literal);

  exports.Identifier = Identifier = (function() {

    function Identifier(identifier) {
      this.identifier = identifier;
      this.type = "Identifier";
    }

    Identifier.prototype.toString = function() {
      return this.identifier;
    };

    Identifier.prototype.toESC = function() {
      return {
        type: this.type,
        name: this.identifier.toString()
      };
    };

    return Identifier;

  })();

  exports.Operator = Operator = (function() {

    function Operator(op) {
      this.op = op;
      this.type = "Operator";
    }

    Operator.prototype.toString = function() {
      return this.op;
    };

    Operator.prototype.toESC = function() {
      return this.op;
    };

    return Operator;

  })();

  exports.Block = Block = (function() {

    function Block(block) {
      this.block = block;
      this.type = "BlockStatement";
    }

    Block.prototype.toString = function() {
      return this.block.map(function(x) {
        return x.toString();
      });
    };

    Block.prototype.toESC = function() {
      var block;
      block = this.block.map(function(x) {
        return x.toESC();
      });
      block = (setVar(this.env)).concat(block);
      return {
        type: this.type,
        body: block
      };
    };

    return Block;

  })();

  makeVarDeclarator = function(id) {
    return {
      type: "VariableDeclarator",
      id: {
        type: "Identifier",
        name: id.toString()
      },
      init: null
    };
  };

  setVar = function(env) {
    var vars;
    if (env.variable.length > 0) {
      vars = env.variable.map(function(x) {
        return makeVarDeclarator(x);
      });
      return [
        {
          type: "VariableDeclaration",
          declarations: vars,
          kind: "var"
        }
      ];
    } else {
      return [];
    }
  };

  exports.Assign = Assign = (function() {

    function Assign(left, right) {
      this.left = left;
      this.right = right;
      this.type = "AssignmentExpression";
    }

    Assign.prototype.toString = function() {
      return this.left.toString() + "=" + this.right.toString();
    };

    Assign.prototype.toESC = function() {
      return {
        type: this.type,
        operator: "=",
        left: this.left.toESC(),
        right: this.right.toESC()
      };
    };

    return Assign;

  })();

}).call(this);
