
import
  os, illwill, options,
  consts, buffer, playground, buffer, pos

var timerChannel: Channel[bool]

proc withTimer(p: proc()) =
  timerChannel.open()
  defer: timerChannel.close()
  var worker: Thread[void]
  createThread(worker, proc() =
    while true:
      timerChannel.send(true)
      sleep(1000)
  )
  p()

func key2direction(k: Key, default = Direction.left): Direction =
  case k
  of Key.Left, Key.H: Direction.left
  of Key.Right, Key.L: Direction.right
  of Key.Up, Key.K: Direction.up
  of Key.Down, Key.J: Direction.down
  else: default

proc updateInputKey(default: Key): Key =
  let k = getKey()
  if k == Key.Escape or k == Key.Q:
    exitProc()
  if k != Key.None:
    return k
  return default

proc mainLoop(tb: var TerminalBuffer, upleft, downright: Pos) =
  var key = Key.Left
  var playground = newPlayground(upleft, downright)
  playground.drawInitPos(tb)
  playground.putFeed(tb)
  while true:
    key = updateInputKey(key)
    if not timerChannel.tryRecv().dataAvailable:
      continue

    case playground.moveSnake(tb, key2direction(key)):
      of Status.keepGoing:
        tb.display()
        sleep(frameMilliSec)
      of Status.gameClear:
        tb.gameClear(upleft, downright)
      of Status.gameOver:
        tb.gameOver(upleft, downright)

when isMainModule:
  illwillInit(fullScreen = true)
  setControlCHook(proc() {.noconv.} = exitProc())
  hideCursor()

  let
    w = terminalWidth()
    h = terminalHeight()
  var tb = newTerminalBuffer(w, h)
  let (upleft, downright) = tb.headerMessage(w, h)

  withTimer(
    proc() = mainLoop(tb, upleft, downright)
  )
