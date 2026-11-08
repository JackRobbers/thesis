#import "@preview/cetz:0.5.2"
#import "@preview/numty:0.1.0" as nt
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/suiji:0.5.1": *
#import "@preview/statastic:1.0.0": arrayMedian

#set text(font: "Arial")
#let side-channels = {
  set text(size: 18pt)
  cetz.canvas({
    import cetz.draw: *
    set-style(stroke: 3pt)
    content((0, 0), [Device], name: "dev")
    rect-around("dev", padding: 0.3, radius: 0.1)
    let channels = ("Network", "Heat", "Sound", "EM", "Time", "Power")
    let n = channels.len()
    for p in range(0, n) {
      let move = 3.9
      let a = 360deg / n * (p)
      let radius = 2.8
      if channels.at(p) == "Network" {
        line((angle: a, radius: 1.5), (angle: a, radius: radius - 0.2), mark: (end: ">"), name: "0")
      } else {
        cetz.decorations.wave(
          line((angle: a, radius: 1.5), (angle: a, radius: radius), mark: (end: ">"), name: "0"),
          segments: 4,
          amplitude: 0.2,
        )
        move = 3.1
      }
      line((), (angle: a, radius: move), stroke: white, name: str(p))
      content((name: str(p), anchor: 100%), [#channels.at(p)])
    }
  })
}

#let measurement = cetz.canvas({
  import cetz.draw: *
  let n = 3
  for (x, i) in range(-int(n / 2), int(n / 2) + 1).enumerate() {
    let y = i * 5
    circle((0, y), radius: 2)
    content((0, y), { align(center, text(size: 20pt)[ Device \ #(n - x)]) })
    line((2.5, y), (4.5, y))
    circle((7, y), radius: 2)
    content((7, y), { align(center, text(size: 20pt)[ Plug \ #(n - x)]) })
    cetz.decorations.wave(line((9.5, y), (15, y / 5)), amplitude: 0.2)

    circle((19, 0), radius: 3)
    content((), {
      set text(size: 30pt)
      [Server]
    })

    line((23, 0), (25, 0), mark: (end: ">", fill: black))

    content((34, 0), [#set text(size: 20pt); 2026-10-22T10:14:04.15.csv #v(-10pt) #table(
        columns: 2,
        [Timestamp], [Power (mW)],
        [2026-10-22T10:14:04.15], [1004],
        [2026-10-22T10:14:04.16], [1050],
        [...], [...],
      )])
  }
})

#let blob(pos, label, tint: white, ..args) = node(
  pos,
  align(center, label),
  // fill: tint.lighten(60%),
  stroke: 2pt + black,
  corner-radius: 5pt,
  shape: rect,
  ..args,
)

#let up = 0.4
#let data-collection = diagram(
  blob((0, -up), [Device 1]),
  edge(),
  blob((1, -up), [Plug A], name: <plugA>),
  blob((0, up), [Device 2]),
  edge(),
  blob((1, up), [Plug B], name: <plugB>),
  blob(
    (2, 0),
    [Server],
    name: <server>,
  ),
  edge(<plugA.east>, <server.west>),
  edge(<plugB.east>, <server.west>),
)

// TODO node groups for metrics
#set text(size: 70pt)
#let process = {
  diagram(
    label-size: 1em,
    node-defocus: 0,
    spacing: (3em, 2em),
    node-outset: 10pt,
    node-inset: 5pt,
    node((0, 0), [P(t)], name: <time-series>),
    edge("->"),
    node(stroke: 1pt + black, name: <metrics_box>, enclose: (<metric1>, <metric2>)),
    edge("r", "->", snap-to: (<metrics_box>, <model_node>)),
    node((1, -0.5), [$"median"(m_1)$], name: <metric1>),
    node((1, 0.5), [$"median"(m_2)$], name: <metric2>),
    node((2, 0), [$M_(m_1, m_2)$], name: <model_node>),
    node((0, 1), [Time-series]),
    node((1, 1), [Metrics]),
    node((2, 1), [Model]),
  )
}

#let distance = {
  set text(size: 20pt)
  cetz.canvas({
    import cetz.draw: *

    let big_circle = 0.2

    let class(center, scale_x, scale_y, colour) = {
      let n = 20
      let rng = gen-rng-f(42)

      let class_stats(rng, n, center, s) = {
        let vs = ()
        let vs2 = ()
        // clusters with outliers
        let half = calc.floor(n / 2)
        (rng, vs) = random-f(rng, size: n)
        (rng, vs2) = normal-f(rng, size: n, scale: 0.2, loc: 0.5)
        vs = vs + vs2
        vs = vs.map(v => (center + v * s))
        return (
          rng,
          vs,
          calc.min(..vs),
          arrayMedian(vs),
          calc.max(..vs),
        )
      }

      let x_stats = class_stats(rng, n, center.at(0), scale_x)
      rng = x_stats.at(0)
      let (_, xs, x_min, x_med, x_max) = x_stats
      let y_stats = class_stats(rng, n, center.at(1), scale_y)
      rng = y_stats.at(0)
      let (_, ys, y_min, y_med, y_max) = y_stats

      set-style(stroke: (dash: "dashed", paint: black.lighten(50%)))
      rect((x_min, y_min), (x_max, y_max), name: "rect")
      set-style(stroke: none)
      // line((x_med, y_min), (x_med, y_max))
      // line((x_min, y_med), (x_max, y_med))
      for i in range(n) {
        circle(
          (xs.at(i), ys.at(i)),
          radius: .1,
          fill: eval(colour).lighten(50%),
        )
      }
      content((rel: (0, 0.3), to: "rect.north"), text(size: 0.5em, [device]))
      circle((x_med, y_med), name: str(colour), radius: big_circle, fill: eval(colour), stroke: 1pt + white)
    }

    class((3.2, 3), 3, 1.5, "red")
    class((2, 0.1), 3, 1.1, "orange")
    class((0.1, 2), 3, 3, "fuchsia")

    circle((2.5, 3), radius: big_circle, fill: black, name: "new")
    set-style(stroke: (dash: "solid"))
    line((0, 0), (6, 0), name: "x")
    content("x.mid", [$mu$], anchor: "north", padding: 0.1)
    line((0, 0), (0, 6), name: "y")
    content("y.mid", [$sigma$], anchor: "east", padding: 0.2)

    set-style(stroke: (paint: black, thickness: 1pt))
    line("new", "red")
    line("new", "fuchsia")
  })
}

#let flow = figure(
  diagram(
    $P(t)_I edge(->) & M^1_I edge(->) & C_x$,
  ),
  caption: [Every Idle power trace is passed to the model, which outputs a predicted class],
)

#let model = cetz.canvas({
  import cetz.draw: *

  let class(center, width) = {
    let height = 1
    move-to((rel: (-width / 2, height / 2), to: center))
    line((), (rel: (0, height)))
  }

  class((0, 0), 2)
})

#let scale-to-container(body, width: 100%, height: auto) = layout(ly => {
  let body-size = measure(body)
  if body-size.width > 0pt and width > 0% {
    scale(
      x: if width == auto { auto } else { ly.width / body-size.width * width },
      y: if height == auto { auto } else { ly.height / body-size.height * height },
      reflow: true,
      body,
    )
  }
})

#let training = diagram($P(t) edge("->") & W(t)_(s=100)^(w=150) edge("->") & m(W)$)

// #for diagram in (side-channels, measurement, process, flow, model) {
//   diagram
// }
//
#distance
