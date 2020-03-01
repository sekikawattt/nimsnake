import options

type Pos* = (Natural, Natural)

func `+`*(self: Pos, v: Pos): Pos =
    (Natural(self[0] + v[0]),
    Natural(self[1] + v[1]))

func `+`*(self: Pos, v: (int, int)): Option[Pos] =
    try:
        return some((
            Natural(self[0] + v[0]),
            Natural(self[1] + v[1])
        ))
    except RangeError:
        discard



