import illwill, random, options, sets, algorithm, sequtils, options,
  pos, consts

randomize()

type Playground* = ref object
  origin: Pos
  width, height: Natural
  allCells: HashSet[Pos]
  snakeBodyq: seq[Pos]
  feed: Option[Pos]

type Status* = enum keepGoing, gameClear, gameOver
type Direction* = enum up, down, left, right

func direction2vector(d: Direction): (int, int) =
  case d:
    of up: (0, -1)
    of down: (0, 1)
    of left: (-1, 0)
    of right: (1, 0)

proc newPlayground*(upleft, downright: Pos): Playground =
  let width = (downright[0] - upleft[0]) div dx + 1
  let height = (downright[1] - upleft[1]) div dy + 1
  let allCells = (product(@[
    (0..<width).toSeq(),
    (0..<height).toSeq()
  ])).map(
    proc(x: seq[int]): Pos = (Natural(x[0]), Natural(x[1]))
  ).toHashSet()
  Playground(
    origin: upleft,
    width: width, height: height,
    allCells: allCells,
    snakeBodyq: @[]
  )

func isGameClear(pg: Playground): bool =
  pg.snakeBodyq.len() == pg.width * pg.height

proc draw(
  pg: Playground, tb: var TerminalBuffer,
  xyi: Pos,
  fg: ForegroundColor, bg: BackgroundColor
) =
  let
    x = Natural(pg.origin[0] + xyi[0] * dx)
    y = Natural(pg.origin[1] + xyi[1] * dy)
  tb.setForegroundColor(fg)
  tb.setBackgroundColor(bg)
  tb.fill(x, y, x+(dx-1), y)

proc drawSnake(pg: Playground, tb: var TerminalBuffer, xyi: Pos) =
  pg.draw(tb, xyi, fgNone, bgWhite)

proc eraceSnake(pg: Playground, tb: var TerminalBuffer, xyi: Pos) =
  pg.draw(tb, xyi, fgNone, bgNone)


func inbound(pg: Playground, pos: Pos): bool =
  pos[0] < pg.width and
  pos[1] < pg.height

proc putFeed*(pg: Playground, tb: var TerminalBuffer) =
  let feed = (pg.allCells - toHashSet(pg.snakeBodyq)).toSeq().sample()
  pg.feed = some(feed)
  pg.draw(tb, feed, fgNone, bgRed)

proc moveSnake*(pg: Playground, tb: var TerminalBuffer,
                direction: Direction): Status =
  let maybeNextHead = pg.snakeBodyq[0] + direction2vector(direction)
  if maybeNextHead.isNone:
    return gameOver

  let nextHead = maybeNextHead.get
  if not pg.inbound(nextHead) or
    pg.snakeBodyq.contains(nextHead):
    return gameOver

  pg.snakeBodyq.insert(nextHead)
  if pg.isGameClear():
    return gameClear

  pg.drawSnake(tb, nextHead)
  if pg.feed.isSome and nextHead == pg.feed.get:
    pg.putFeed(tb)
  else:
    pg.eraceSnake(tb, pg.snakeBodyq.pop())
  return keepGoing

proc drawInitPos*(pg: Playground, tb: var TerminalBuffer) =
  let
    x = Natural(pg.width div 2)
    y = Natural(pg.height div 2)
  pg.snakeBodyq.add( (x, y))
  pg.drawSnake(tb, (x, y))
