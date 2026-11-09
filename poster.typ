#import "assets/diagrams.typ": *
#import "assets/eestyle2.typ": *
#show: eestyle2
#import "assets/common.typ": *

#let config = yaml("common.yaml")

// TODO figure instead of table for dataset
// TODO

#set text(font: "Arial GEO")
#set par(leading: 16pt)

// #show math.equation: set text(font: "math", size: 35pt)

#let bold(content) = {
  set text(weight: "bold", font: "Arial GEO")
  content
}

#let container(content) = {
  show heading.where(level: 1): set text(weight: "bold", size: 36pt, font: "Arial GEO")

  set text(weight: "regular", size: 24pt, font: "Arial")
  box(content, width: 100%, height: 100%, inset: 1em, stroke: 0.5em + rgb("#b9cde5"), radius: 20pt)
  // box(content, inset: 1em, stroke: 0.5em + rgb("#b9cde5"), radius: 20pt)
  // content
}

#let contribution(content) = { box(stroke: 3pt + unswred2, inset: 0.2em, content) }

#page(paper: "a0", margin: 5pt, background: image("assets/poster_background.pdf"))[
  #place(center, dx: 1cm, dy: 5.5cm, text(size: 100pt, [2026 Thesis Project]))

  #place(center, dx: 0cm, dy: 17cm, box[
    #set par(leading: 30pt)
    #align(center)[
      #text(weight: "bold", size: 82pt)[#config.title] \
      #text(size: 72pt, emph[#config.author]) \
      #text(size: 48pt, emph[Supervisor: #config.supervisor])
    ]
  ])

  #place(center, dy: 25cm, align(left, box(inset: 2em, height: 79%, grid(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    column-gutter: 2em,
    row-gutter: 2em,
    rows: (1fr, 1fr, 1fr, 1fr),
    grid.cell(colspan: 3, container([
      = Problem Statement
      To create a method to efficiently

      = Background
      Complex networks include thousands of devices that operators need to keep track of. Knowing more about the network improves security.

      Existing literature focuses on network traffic, but this struggles with "quiet" devices.

      Power is a constant signal that can provide. Research in fields
    ])),

    grid.cell(colspan: 3, rowspan: 2, container([
      = Method to Classify Power Data by Device #contribution([1])

      // #figure(
      //   [#scale-to-container(process) #v(25pt)],
      //   // [#process #v(25pt)],
      // )


      #figure(
        scale-to-container(distance),
        // distance,
        // []
      )

    ])),
    grid.cell(colspan: 3, rowspan: 2, container([
      = Data #contribution([2.1])


      #figure(
        caption: [Comparison between the existing SafeNetIoT dataset and my dataset. My dataset covers a lot less devices but has more data to make more confident conclusion from.],
        [
          #table(
            columns: 3,
            bold[Property], bold[SafeNetIoT], bold[My Dataset],
            [Devices], [32], [6],
            [Trace length], [\~40 minutes], [78 hours],
            [Scenarios], [10], [1],
          )1
        ],
      )
    ])),
    grid.cell(colspan: 3, rowspan: 2, container([
      = Evaluation

      #align(center)[
        #table_image("evaluation", width: 100%)
        // #scale-to-container(image("generated/confusion-matrix-idle-150-100-mean-std-Median.pdf"), width: 100%)
      ]
    ])),
    grid.cell(colspan: 3, container([
      = Conclusion
    ])),
  ))))
]

