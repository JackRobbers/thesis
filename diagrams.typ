#import "@preview/cetz:0.5.2"
#import "@preview/numty:0.1.0" as nt

#let side-channels = cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 3pt)
  circle((0, 0), radius: 1)
  content((0, 0), [Device])
  let channels = ("Network", "Heat", "Sound", "EM", "Time", "Power")
  let n = channels.len()
  for p in range(0, n) {
    let move = 3.9
    let a = 360deg / n * (p)
    if channels.at(p) == "Network" {
      line((angle: a, radius: 1.5), (angle: a, radius: 3), mark: (end: ">"), name: "0")
    } else {
      cetz.decorations.wave(
        line((angle: a, radius: 1.5), (angle: a, radius: 3), mark: (end: ">"), name: "0"),
        segments: 4,
        amplitude: 0.2,
      )
      move = 3.1
    }
    line((), (angle: a, radius: move), stroke: white, name: str(p))
    content((name: str(p), anchor: 100%), [#channels.at(p)])
  }
})

#let measurement = cetz.canvas({
  import cetz.draw: *
  let n = 3
  for i in range(- int(n / 2), int(n / 2) + 1) {
    let y = i * 5
    circle((0, y), radius: 2)
    content((0, y), {set text(size: 30pt); [ Device ]})
    line((2.5, y), (4.5, y))
    circle((7, y), radius: 2)
    content((7, y),  {set text(size: 30pt); [ Plug ]})
    cetz.decorations.wave(line((9.5, y), (15, y / 5)), amplitude: 0.2)

    circle((19, 0), radius: 3)
    content((), {set text(size: 50pt); [ Laptop ]})
  }
})

#let process = cetz.canvas({
      import cetz.draw: *

      let box(i) = {
        let gap = 3 * i
        rect((gap, 0), (gap + 2, 2), name: str(i))
      }
      let names = ("Raw Data", "Windowing", "Apply Metric", "Classification")
      let n = names.len()
      for i in range(n) {
        let gap = i * 3
        hide(box(i))
        if i == 0 {
         
          hide(line(("0.west"), ("0.west"), stroke: red))
          for j in nt.linspace(0, 2, 100) {
            let point = (calc.sin(j * 10000) + calc.sin(j * 121) + calc.sin(j * 2009) + 2)
            line((), (j, point / 2))
          }
        } else if i == 1 {
     
          for j in range(2) {
            rect((3 + j / 2, 0 + j / 8), (4.5 + j / 2, 1.8 + j / 8))
          }
        } else if i == 2 {
          
          content("2.center", text(size: 20pt, [$mu$]))
        } else {
          // hide(line((gap, 0), (gap, 2)))
          for (row, x) in nt.linspace(0, 2, 7).enumerate() {
            for (col, y) in nt.linspace(0, 2, 7).enumerate() {
              fill(white)
            
              if col != 2 {
                if (x == y) {
                  fill(black)
                }
              } else if (row == 2 or row == 3 or row == 6) {
                fill(black.lighten(50%))
              }
              rect((gap + x, 2.3 - y), (gap + x + 2/7 + 0.05, 2.3 - (y + 2/7 + 0.05)), stroke: 1pt)
            }

          }
        }
        content((rel: (0, -.4), to: str(i) + ".south"), names.at(i))
        if i < n - 1 {
          line((gap + 2.2, 1), (gap + 2.9, 1), mark: (end: ">", scale: 1.2, fill: black))
        }
      }
      //  rect((3, 0), (5, 2), name: "window")
      //  content((rel: (0, -.4), to: "window.south"), [Window])
    })