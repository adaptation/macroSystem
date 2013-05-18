@pointToErrorLocation = pointToErrorLocation = (source, line, column, numLinesOfContext = 3) ->
  lines = source.split '\n'
  # figure out which lines are needed for context
  currentLineOffset = line - 1
  startLine = currentLineOffset - numLinesOfContext
  if startLine < 0 then startLine = 0
  # get the context lines
  preLines = lines[startLine..currentLineOffset]
  postLines = lines[currentLineOffset + 1 .. currentLineOffset + numLinesOfContext]
  numberedLines = (numberLines (cleanMarkers [preLines..., postLines...].join '\n'), startLine + 1).split '\n'
  preLines = numberedLines[0...preLines.length]
  postLines = numberedLines[preLines.length...]
  # set the column number to the position of the error in the cleaned string
  column = (cleanMarkers "#{lines[currentLineOffset]}\n"[...column]).length
  padSize = ((currentLineOffset + 1 + postLines.length).toString 10).length
  [
    preLines...
    "#{(Array padSize + 1).join '^'} :~#{(Array column).join '~'}^"
    postLines...
  ].join '\n'