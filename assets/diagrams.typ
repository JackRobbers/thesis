#import "@preview/cetz:0.5.2"
#import "@preview/numty:0.1.0" as nt
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

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
#let process = diagram(
  label-size: 1em,
  node-defocus: 0,
  spacing: (3em, 2em),
  // cell-size: 50pt,
  node-outset: 10pt,
  node-inset: 5pt,
  node((0, 0), [P(t)], name: <time-series>),
  edge("->"),
  node((0.7, 0), rect(), name: <window>),
  node((0.8, 0.05), rect(), name: <window2>),
  // edge("ur", "->", snap-to: (<window2.east>, <metric1>), extrude: 20),
  edge("->", snap-to: (<window2>, <metrics.east>), vertices: ((1.0, 0), (1.15, 0))),
  node(stroke: 1pt + black, name: <metrics_box>, enclose: (<metric1>, <metric2>)),
  edge("r", "->", snap-to: (<metrics_box>, <model_node>)),
  node((1.75, -0.5), [$"median"(m_1)$], name: <metric1>),
  node((1.75, 0.5), [$"median"(m_2)$], name: <metric2>),
  node((3, 0), [$M_(m_1, m_2)$], name: <model_node>),

  node((0, 1), [Time-series]),
  node((0.75, 1), [Windowing]),

  node((1.75, 1), [Metrics]),

  node((3, 1), [Model]),
)

#let distance = {
  set text(size: 30pt)
  cetz.canvas({
    import cetz.draw: *

    let distro(x1, y1, x2, y2, xrate, yrate, color) = {
      for i in range(10) {
        circle((x1 + i / xrate, y1), fill: color, stroke: none, radius: 0.1)
        circle((x2, y2 + i / yrate), fill: color, stroke: none, radius: 0.1)
        // line()
      }
    }

    line((0, 0), (10, 0), name: "x")
    content("x.mid", [$m_1$], anchor: "north", padding: 0.1)
    line((0, 0), (0, 9), name: "y")
    content("y.mid", [$m_2$], anchor: "east", padding: 0.2)

    distro(1, 1, 1, 1, 2, 4, red)
    distro(4, 3, 6, 2, 2, 4, orange)
    distro(8, 7, 9, 5, 7, 2.6, green)

    circle((8.2, 6), radius: 0.2, fill: black, name: "new")

    circle((3.4, 2.1), radius: 0.2, fill: red, stroke: 2pt + black, name: "red")
    circle((6, 3), radius: 0.2, fill: orange, stroke: 2pt + black, name: "orange")
    circle((8.5, 7), radius: 0.2, fill: green, stroke: 2pt + black, name: "green")

    // line("new", "red", stroke: (thickness: 2pt, dash: "dashed"))
    line("new", "orange", stroke: (thickness: 2pt, dash: "dashed"))

    line("new", "green", stroke: (thickness: 2pt, dash: "dashed"))
  })
}

// #let process = {
//   set text(size: 15pt)
//   show math.equation: set text(font: "Latin Modern Math", size: 30pt)

//   cetz.canvas({
//     import cetz.draw: *

//     let box(i) = {
//       let gap = 3 * i
//       rect((gap, 0), (gap + 2, 2), name: str(i))
//     }
//     let names = ("Time-series", "Windowing", "Metrics", "Model")
//     let n = names.len()
//     for i in range(n) {
//       let gap = i * 3
//       hide(box(i))
//       if i == 0 {
//         hide(line("0.west", "0.west", stroke: red))
//         // for j in nt.linspace(0, 2, 100) {
//         //   let point = (calc.sin(j * 10000) + calc.sin(j * 121) + calc.sin(j * 2009) + 2)
//         //   line((), (j, point / 2))
//         // }
//         content("0.center")[$P(t)$]
//       } else if i == 1 {
//         for j in range(2) {
//           rect((3 + j / 2, 0 + j / 8), (4.5 + j / 2, 1.8 + j / 8))
//         }
//       } else if i == 2 {
//         content("2.center")[$||$]
//       } else if i == 3 {
//         content("3.center")[$M_"m1, m2"^"S"$]
//       } else {
//         // hide(line((gap, 0), (gap, 2)))
//       }
//       content((rel: (0, -.4), to: str(i) + ".south"), names.at(i))
//       if i < n - 1 {
//         line((gap + 2.2, 1), (gap + 2.9, 1), mark: (end: ">", scale: 1.2, fill: black))
//       }
//     }
//     //  rect((3, 0), (5, 2), name: "window")
//     //  content((rel: (0, -.4), to: "window.south"), [Window])
//   })
// }

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

  scale(
    x: if width == auto { auto } else { ly.width / body-size.width * width },
    y: if height == auto { auto } else { ly.height / body-size.height * height },
    reflow: true,
    body,
  )
})

#let training = diagram($P(t) edge("->") & W(t)_(s=100)^(w=150) edge("->") & m(W)$)

// #for diagram in (side-channels, measurement, process, flow, model) {
//   diagram
// }
//
#distance
