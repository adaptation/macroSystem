{EventEmitter} = require 'events'
{pointToErrorLocation} = require './helpers'
StringScanner = require 'StringScanner'


# TODO: better comments
# TODO: support win32-style line endings

@Preprocessor = class Preprocessor extends EventEmitter

  ws = '\\t\\x0B\\f\\r \\xA0\\u1680\\u180E\\u2000-\\u200A\\u202F\\u205F\\u3000\\uFEFF'
  INDENT = '\uEFEF'
  DEDENT = '\uEFFE'
  TERM   = '\uEFFF'

  constructor: ->
    # `base` is either `null` or a regexp that matches the base indentation
    @base = null
    # `indents` is an array of successive indentation characters.
    @indents = []
    @context = []
    @ss = new StringScanner ''

  err: (c) ->
    token =
      switch c
        when INDENT
          'INDENT'
        when DEDENT
          'DEDENT'
        when TERM
          'TERM'
        else
          "\"#{c.replace /"/g, '\\"'}\""
    # This isn't perfect for error location tracking, but since we normally call this after a scan, it tends to work well.
    lines = @ss.str.substr(0, @ss.pos).split(/\n/) || ['']
    columns = if lines[lines.length-1]? then lines[lines.length-1].length else 0
    context = pointToErrorLocation @ss.str, lines.length, columns
    throw new Error "Unexpected #{token}\n#{context}"

  # return last of context
  peek: -> if @context.length then @context[@context.length - 1] else null

  # contextを観察する関数
  observe: (c) ->
    top = @peek()
    switch c
      # opening token is closing token
      when '"""', '\'\'\'', '"', '\'', '###', '`', '///', '/'
        # if last of context is c ,
        if top is c then do @context.pop
        else @context.push c
      # strictly opening tokens
      when INDENT, '#', '#{', '[', '(', '{', '\\', 'regexp-[', 'regexp-(', 'regexp-{', 'heregexp-#', 'heregexp-[', 'heregexp-(', 'heregexp-{'
        @context.push c
      # strictly closing tokens
      when DEDENT
        (@err c) unless top is INDENT
        do @context.pop
      when '\n'
        (@err c) unless top in ['#', 'heregexp-#']
        do @context.pop
      when ']'
        (@err c) unless top in ['[', 'regexp-[', 'heregexp-[']
        do @context.pop
      when ')'
        (@err c) unless top in ['(', 'regexp-(', 'heregexp-(']
        do @context.pop
      when '}'
        (@err c) unless top in ['#{', '{', 'regexp-{', 'heregexp-{']
        do @context.pop
      when 'end-\\'
        (@err c) unless top is '\\'
        do @context.pop
      else throw new Error "undefined token observed: " + c
    @context

  # s= if scan sucseed then string else null
  p: (s) ->
    #emit = (type, data) -> output += data if type is 'data'
    console.log "p s:", s
    if s? then @emit 'data', s
    console.log "rest string:",@ss.string().slice(@ss.pos)
    s

  scan: (r) ->
    console.log  "scan r:", r
    @p @ss.scan r

  processInput = (isEnd) -> (data) ->
    # if !isEnd then data else undefined
    # ss.concat data => add data to scan string
    @ss.concat data unless isEnd
    console.log @ss.str.length

    #do until end of scan
    until @ss.eos()
      console.log "\n-----------------\nss:",@ss
      console.log 'context:',@context
      console.log "peek:", @peek()
      console.log "base:",@base
      console.log "indents:", @indents
      switch @peek()
        when null, INDENT, '#{', '[', '(', '{'
          # bol() isi Begining Of Line=>Returns true if the scan pointer is at the beginning of a line (right after \n) or the beginning of the string
          if @ss.bol() or @scan /// (?:[#{ws}]* \n)+ ///
            @scan /// (?: [#{ws}]* (\#\#?(?!\#)[^\n]*)? \n )+ ///
            # we might require more input to determine indentation
            return if not isEnd and (@ss.check /// [#{ws}\n]* $ ///)?
            # `base` is either `null` or a regexp that matches the base indentation
            # consume base indentation
            if @base?
              unless (@scan @base)?
                throw new Error "inconsistent base indentation"
            else
              tbase = @scan /// [#{ws}]* ///
              console.log "tbase:",tbase
              # if tbase="",@base=/(?:)/
              @base = /// #{  tbase } ///
              console.log "base:",@base
              # @base = /// #{@scan /// [#{ws}]* ///} ///

            # move through each level of indentation
            indentIndex = 0
            while indentIndex < @indents.length
              console.log "Indent comming!"
              indent = @indents[indentIndex]
              if @ss.check /// #{indent} ///
                # an existing indent
                @scan /// #{indent} ///
              else if @ss.check /// [^#{ws}] ///
                # we lost an indent
                @indents.splice indentIndex, 1
                --indentIndex
                @observe DEDENT
                @p "#{DEDENT}#{TERM}"
              else
                # Some ambiguous dedent
                lines = @ss.str.substr(0, @ss.pos).split(/\n/) || ['']
                message = "Syntax error on line #{lines.length}: indention is ambiguous"
                lineLen = @indents.reduce ((l, r) -> l + r.length), 0
                context = pointToErrorLocation @ss.str, lines.length, lineLen
                throw new Error "#{message}\n#{context}"
              ++indentIndex
            # while end

            if @ss.check /// [#{ws}]+ [^#{ws}#] ///
              # an indent
              @indents.push @scan /// [#{ws}]+ ///
              @observe INDENT
              @p INDENT

          tok = switch @peek()
            when '['
              # safe things, but not closing bracket
              @scan /[^\n'"\\\/#`[({\]]+/
              @scan /\]/
            when '('
              # safe things, but not closing paren
              @scan /[^\n'"\\\/#`[({)]+/
              @scan /\)/
            when '#{', '{'
              # safe things, but not closing brace
              @scan /[^\n'"\\\/#`[({}]+/
              @scan /\}/
            else
              # scan safe characters (anything that doesn't *introduce* context)
              @scan /[^\n'"\\\/#`[({]+/
              null
          if tok
            @observe tok
            continue

          # strictly opening tokens
          if tok = @scan /"""|'''|\/\/\/|###|["'`#[({\\]/
            @observe tok
          else if tok = @scan /\//
            # unfortunately, we must look behind us to determine if this is a regexp or division
            pos = @ss.position()
            if pos > 1
              lastChar = @ss.string()[pos - 2]
              spaceBefore = ///[#{ws}]///.test lastChar
              nonIdentifierBefore = /[\W_$]/.test lastChar # TODO: this should perform a real test
            if pos is 1 or (if spaceBefore then not @ss.check /// [#{ws}=] /// else nonIdentifierBefore)
              @observe '/'
        # end when null, INDENT, '#{', '[', '(', '{'
        when '\\'
          if (@scan /[\s\S]/) then @observe 'end-\\'
          # TODO: somehow prevent indent tokens from being inserted after these newlines
        when '"""'
          @scan /(?:[^"#\\]+|""?(?!")|#(?!{)|\\.)+/
          @ss.scan /\\\n/
          if tok = @scan /#{|"""/ then @observe tok
          else if tok = @scan /#{|"""/ then @observe tok
        when '"'
          @scan /(?:[^"#\\]+|#(?!{)|\\.)+/
          @ss.scan /\\\n/
          if tok = @scan /#{|"/ then @observe tok
        when '\'\'\''
          @scan /(?:[^'\\]+|''?(?!')|\\.)+/
          @ss.scan /\\\n/
          if tok = @scan /'''/ then @observe tok
        when '\''
          @scan /(?:[^'\\]+|\\.)+/
          @ss.scan /\\\n/
          if tok = @scan /'/ then @observe tok
        when '###'
          @scan /(?:[^#]+|##?(?!#))+/
          if tok = @scan /###/ then @observe tok
        when '#'
          @scan /[^\n]+/
          if tok = @scan /\n/ then @observe tok
        when '`'
          @scan /[^`]+/
          if tok = @scan /`/ then @observe tok
        when '///'
          @scan /(?:[^[/#\\]+|\/\/?(?!\/)|\\.)+/
          if tok = @scan /#{|\/\/\/|\\/ then @observe tok
          else if @ss.scan /#/ then @observe 'heregexp-#'
          else if tok = @scan /[\[]/ then @observe "heregexp-#{tok}"
        when 'heregexp-['
          @scan /(?:[^\]\/\\]+|\/\/?(?!\/))+/
          if tok = @scan /[\]\\]|#{|\/\/\// then @observe tok
        when 'heregexp-#'
          @ss.scan /(?:[^\n/]+|\/\/?(?!\/))+/
          if tok = @scan /\n|\/\/\// then @observe tok
        #when 'heregexp-('
        #  @scan /(?:[^)/[({#\\]+|\/\/?(?!\/))+/
        #  if tok = @ss.scan /#(?!{)/ then @observe 'heregexp-#'
        #  else if tok = @scan /[)\\]|#{|\/\/\// then @observe tok
        #  else if tok = @scan /[[({]/ then @observe "heregexp-#{tok}"
        #when 'heregexp-{'
        #  @scan /(?:[^}/[({#\\]+|\/\/?(?!\/))+/
        #  if tok = @ss.scan /#(?!{)/ then @observe 'heregexp-#'
        #  else if tok = @scan /[}/\\]|#{|\/\/\// then @observe tok
        #  else if tok = @scan /[[({]/ then @observe "heregexp-#{tok}"
        when '/'
          @scan /[^[/\\]+/
          if tok = @scan /[\/\\]/ then @observe tok
          else if tok = @scan /\[/ then @observe "regexp-#{tok}"
        when 'regexp-['
          @scan /[^\]\\]+/
          if tok = @scan /[\]\\]/ then @observe tok
        #when 'regexp-('
        #  @scan /[^)/[({\\]+/
        #  if tok = @scan /[)/\\]/ then @observe tok
        #  else if tok = @scan /[[({]/ then @observe "regexp-#{tok}"
        #when 'regexp-{'
        #  @scan /[^}/[({\\]+/
        #  if tok = @scan /[}/\\]/ then @observe tok
        #  else if tok = @scan /[[({]/ then @observe "regexp-#{tok}"

    # end until

    # reached the end of the file
    if isEnd
      @scan /// [#{ws}\n]* $ ///
      while @context.length
        switch @peek()
          when INDENT
            @observe DEDENT
            @p "#{DEDENT}#{TERM}"
          when '#'
            @observe '\n'
            @p '\n'
          else
            # TODO: store offsets of tokens when inserted and report position of unclosed starting token
            throw new Error "Unclosed \"#{@peek().replace /"/g, '\\"'}\" at EOF"
      @emit 'end'
      return

    return
  # processInput = (isEnd) -> (data) ->
  processData: processInput no
  processEnd: processInput yes
  @processSync = (input) ->
    pre = new Preprocessor
    output = ''
    pre.emit = (type, data) ->
      if type is 'data'
        output += data
        console.log "output:" ,output
      output
    pre.processData input
    do pre.processEnd
    output
