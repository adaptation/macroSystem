// Generated by CoffeeScript 1.4.0
(function() {
  var EventEmitter, Preprocessor, StringScanner, pointToErrorLocation,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  EventEmitter = require('events').EventEmitter;

  pointToErrorLocation = require('./helpers').pointToErrorLocation;

  StringScanner = require('StringScanner');

  this.Preprocessor = Preprocessor = (function(_super) {
    var DEDENT, INDENT, TERM, processInput, ws;

    __extends(Preprocessor, _super);

    ws = '\\t\\x0B\\f\\r \\xA0\\u1680\\u180E\\u2000-\\u200A\\u202F\\u205F\\u3000\\uFEFF';

    INDENT = '\uEFEF';

    DEDENT = '\uEFFE';

    TERM = '\uEFFF';

    function Preprocessor() {
      this.base = null;
      this.indents = [];
      this.context = [];
      this.ss = new StringScanner('');
    }

    Preprocessor.prototype.err = function(c) {
      var columns, context, lines, token;
      token = (function() {
        switch (c) {
          case INDENT:
            return 'INDENT';
          case DEDENT:
            return 'DEDENT';
          case TERM:
            return 'TERM';
          default:
            return "\"" + (c.replace(/"/g, '\\"')) + "\"";
        }
      })();
      lines = this.ss.str.substr(0, this.ss.pos).split(/\n/) || [''];
      columns = lines[lines.length - 1] != null ? lines[lines.length - 1].length : 0;
      context = pointToErrorLocation(this.ss.str, lines.length, columns);
      throw new Error("Unexpected " + token + "\n" + context);
    };

    Preprocessor.prototype.peek = function() {
      if (this.context.length) {
        return this.context[this.context.length - 1];
      } else {
        return null;
      }
    };

    Preprocessor.prototype.observe = function(c) {
      var top;
      top = this.peek();
      switch (c) {
        case '"""':
        case '\'\'\'':
        case '"':
        case '\'':
        case '###':
        case '`':
        case '///':
        case '/':
          if (top === c) {
            this.context.pop();
          } else {
            this.context.push(c);
          }
          break;
        case INDENT:
        case '#':
        case '#{':
        case '[':
        case '(':
        case '{':
        case '\\':
        case 'regexp-[':
        case 'regexp-(':
        case 'regexp-{':
        case 'heregexp-#':
        case 'heregexp-[':
        case 'heregexp-(':
        case 'heregexp-{':
          this.context.push(c);
          break;
        case DEDENT:
          if (top !== INDENT) {
            this.err(c);
          }
          this.context.pop();
          break;
        case '\n':
          if (top !== '#' && top !== 'heregexp-#') {
            this.err(c);
          }
          this.context.pop();
          break;
        case ']':
          if (top !== '[' && top !== 'regexp-[' && top !== 'heregexp-[') {
            this.err(c);
          }
          this.context.pop();
          break;
        case ')':
          if (top !== '(' && top !== 'regexp-(' && top !== 'heregexp-(') {
            this.err(c);
          }
          this.context.pop();
          break;
        case '}':
          if (top !== '#{' && top !== '{' && top !== 'regexp-{' && top !== 'heregexp-{') {
            this.err(c);
          }
          this.context.pop();
          break;
        case 'end-\\':
          if (top !== '\\') {
            this.err(c);
          }
          this.context.pop();
          break;
        default:
          throw new Error("undefined token observed: " + c);
      }
      return this.context;
    };

    Preprocessor.prototype.p = function(s) {
      if (s != null) {
        this.emit('data', s);
      }
      return s;
    };

    Preprocessor.prototype.scan = function(r) {
      console.log(r);
      return this.p(this.ss.scan(r));
    };

    processInput = function(isEnd) {
      return function(data) {
        var context, indent, indentIndex, lastChar, lineLen, lines, message, nonIdentifierBefore, pos, spaceBefore, tbase, tok;
        if (!isEnd) {
          this.ss.concat(data);
        }
        console.log(this.ss.str.length);
        while (!this.ss.eos()) {
          console.log("ss:", this.ss);
          console.log('context:', this.context);
          console.log("peek:", this.peek());
          switch (this.peek()) {
            case null:
            case INDENT:
            case '#{':
            case '[':
            case '(':
            case '{':
              if (this.ss.bol() || this.scan(RegExp("(?:[" + ws + "]*\\n)+"))) {
                this.scan(RegExp("(?:[" + ws + "]*(\\#\\#?(?!\\#)[^\\n]*)?\\n)+"));
                if (!isEnd && ((this.ss.check(RegExp("[" + ws + "\\n]*$"))) != null)) {
                  return;
                }
                if (this.base != null) {
                  if ((this.scan(this.base)) == null) {
                    throw new Error("inconsistent base indentation");
                  }
                } else {
                  tbase = this.scan(RegExp("[" + ws + "]*"));
                  this.base = RegExp("" + tbase);
                }
                indentIndex = 0;
                while (indentIndex < this.indents.length) {
                  indent = this.indents[indentIndex];
                  if (this.ss.check(RegExp("" + indent))) {
                    this.scan(RegExp("" + indent));
                  } else if (this.ss.check(RegExp("[^" + ws + "]"))) {
                    this.indents.splice(indentIndex, 1);
                    --indentIndex;
                    this.observe(DEDENT);
                    this.p("" + DEDENT + TERM);
                  } else {
                    lines = this.ss.str.substr(0, this.ss.pos).split(/\n/) || [''];
                    message = "Syntax error on line " + lines.length + ": indention is ambiguous";
                    lineLen = this.indents.reduce((function(l, r) {
                      return l + r.length;
                    }), 0);
                    context = pointToErrorLocation(this.ss.str, lines.length, lineLen);
                    throw new Error("" + message + "\n" + context);
                  }
                  ++indentIndex;
                }
                if (this.ss.check(RegExp("[" + ws + "]+[^" + ws + "#]"))) {
                  this.indents.push(this.scan(RegExp("[" + ws + "]+")));
                  this.observe(INDENT);
                  this.p(INDENT);
                }
              }
              tok = (function() {
                switch (this.peek()) {
                  case '[':
                    this.scan(/[^\n'"\\\/#`[({\]]+/);
                    return this.scan(/\]/);
                  case '(':
                    this.scan(/[^\n'"\\\/#`[({)]+/);
                    return this.scan(/\)/);
                  case '#{':
                  case '{':
                    this.scan(/[^\n'"\\\/#`[({}]+/);
                    return this.scan(/\}/);
                  default:
                    this.scan(/[^\n'"\\\/#`[({]+/);
                    return null;
                }
              }).call(this);
              if (tok) {
                this.observe(tok);
                continue;
              }
              if (tok = this.scan(/"""|'''|\/\/\/|###|["'`#[({\\]/)) {
                this.observe(tok);
              } else if (tok = this.scan(/\//)) {
                pos = this.ss.position();
                if (pos > 1) {
                  lastChar = this.ss.string()[pos - 2];
                  spaceBefore = RegExp("[" + ws + "]").test(lastChar);
                  nonIdentifierBefore = /[\W_$]/.test(lastChar);
                }
                if (pos === 1 || (spaceBefore ? !this.ss.check(RegExp("[" + ws + "=]")) : nonIdentifierBefore)) {
                  this.observe('/');
                }
              }
              break;
            case '\\':
              if (this.scan(/[\s\S]/)) {
                this.observe('end-\\');
              }
              break;
            case '"""':
              this.scan(/(?:[^"#\\]+|""?(?!")|#(?!{)|\\.)+/);
              this.ss.scan(/\\\n/);
              if (tok = this.scan(/#{|"""/)) {
                this.observe(tok);
              } else if (tok = this.scan(/#{|"""/)) {
                this.observe(tok);
              }
              break;
            case '"':
              this.scan(/(?:[^"#\\]+|#(?!{)|\\.)+/);
              this.ss.scan(/\\\n/);
              if (tok = this.scan(/#{|"/)) {
                this.observe(tok);
              }
              break;
            case '\'\'\'':
              this.scan(/(?:[^'\\]+|''?(?!')|\\.)+/);
              this.ss.scan(/\\\n/);
              if (tok = this.scan(/'''/)) {
                this.observe(tok);
              }
              break;
            case '\'':
              this.scan(/(?:[^'\\]+|\\.)+/);
              this.ss.scan(/\\\n/);
              if (tok = this.scan(/'/)) {
                this.observe(tok);
              }
              break;
            case '###':
              this.scan(/(?:[^#]+|##?(?!#))+/);
              if (tok = this.scan(/###/)) {
                this.observe(tok);
              }
              break;
            case '#':
              this.scan(/[^\n]+/);
              if (tok = this.scan(/\n/)) {
                this.observe(tok);
              }
              break;
            case '`':
              this.scan(/[^`]+/);
              if (tok = this.scan(/`/)) {
                this.observe(tok);
              }
              break;
            case '///':
              this.scan(/(?:[^[/#\\]+|\/\/?(?!\/)|\\.)+/);
              if (tok = this.scan(/#{|\/\/\/|\\/)) {
                this.observe(tok);
              } else if (this.ss.scan(/#/)) {
                this.observe('heregexp-#');
              } else if (tok = this.scan(/[\[]/)) {
                this.observe("heregexp-" + tok);
              }
              break;
            case 'heregexp-[':
              this.scan(/(?:[^\]\/\\]+|\/\/?(?!\/))+/);
              if (tok = this.scan(/[\]\\]|#{|\/\/\//)) {
                this.observe(tok);
              }
              break;
            case 'heregexp-#':
              this.ss.scan(/(?:[^\n/]+|\/\/?(?!\/))+/);
              if (tok = this.scan(/\n|\/\/\//)) {
                this.observe(tok);
              }
              break;
            case '/':
              this.scan(/[^[/\\]+/);
              if (tok = this.scan(/[\/\\]/)) {
                this.observe(tok);
              } else if (tok = this.scan(/\[/)) {
                this.observe("regexp-" + tok);
              }
              break;
            case 'regexp-[':
              this.scan(/[^\]\\]+/);
              if (tok = this.scan(/[\]\\]/)) {
                this.observe(tok);
              }
          }
        }
        if (isEnd) {
          this.scan(RegExp("[" + ws + "\\n]*$"));
          while (this.context.length) {
            switch (this.peek()) {
              case INDENT:
                this.observe(DEDENT);
                this.p("" + DEDENT + TERM);
                break;
              case '#':
                this.observe('\n');
                this.p('\n');
                break;
              default:
                throw new Error("Unclosed \"" + (this.peek().replace(/"/g, '\\"')) + "\" at EOF");
            }
          }
          this.emit('end');
          return;
        }
      };
    };

    Preprocessor.prototype.processData = processInput(false);

    Preprocessor.prototype.processEnd = processInput(true);

    Preprocessor.processSync = function(input) {
      var output, pre;
      pre = new Preprocessor;
      output = '';
      pre.emit = function(type, data) {
        if (type === 'data') {
          output += data;
        }
        console.log("output:", output);
        return output;
      };
      pre.processData(input);
      pre.processEnd();
      return output;
    };

    return Preprocessor;

  })(EventEmitter);

}).call(this);
