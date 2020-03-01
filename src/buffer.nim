import illwill, pos, consts

proc exitProc*(msg = "") =
  illwillDeinit()
  showCursor()
  quit(0)

proc headerMessage*(tb: var TerminalBuffer, w, h: Natural): (Pos, Pos) =
  ## returns playground's Pos for upleft and downright.

  let
    # playground is surrounded by a border which requires a space.
    pgUpleft = (Natural(1), Natural(2))
    pgWidth = w - 2
    pgHeight = h - 2
  var pgDownright: Pos
  try:
    pgDownright = (
      Natural(pgWidth - pgWidth mod dx),
      Natural(pgHeight - pgHeight mod dy)
    )
  except RangeError:
    exitProc(
      "Current window size is too small." &
      "Expand and rerun."
    )
  tb.write(2, 0,
           fgWhite, "Press",
           fgYellow, " ESC",
           fgWhite, " or",
           fgYellow, " Q",
           fgWhite, " to quit")
  tb.setForegroundColor(fgBlack, true)
  tb.drawRect(
    pgUpleft[0] - 1, pgUpleft[1] - 1,
    pgDownright[0] + 1, pgDownright[1] + 1
  )
  return (pgUpleft, pgDownright)

proc waitToQuit() =
  while true:
    case getKey()
    of Key.Escape, Key.Q: exitProc()
    else: discard

proc showMsg(tb: var TerminalBuffer, msg: string, upleft, downright: Pos) =
  tb.setForegroundColor(fgNone)
  tb.setBackgroundColor(bgWhite)
  tb.fill(upleft[0], upleft[1],
          downright[0] + downright[0] mod dx,
          downright[1] + downright[1] mod dy
  )

  tb.setForegroundColor(fgBlack)
  tb.write(
    (downright[0] + upleft[0]) div 2 - msg.len() div 2,
    (downright[1] + upleft[1]) div 2
    , msg)
  tb.display()


proc gameOver*(tb: var TerminalBuffer, upleft, downright: Pos) =
  tb.showMsg("Game Over", upleft, downright)
  waitToQuit()

proc gameClear*(tb: var TerminalBuffer, upleft, downright: Pos) =
  tb.showMsg("Congratulations!!", upleft, downright)
  waitToQuit()
