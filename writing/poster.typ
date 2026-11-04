#set text(font: "Arial GEO")
#set par(leading: 30pt)

#let container(content) = {
  show heading.where(level: 1): set text(weight: "bold", size: 36pt)

  set text(weight: "regular", size: 24pt)

  box(content, width: 100%, inset: 1em, stroke: 0.5em + rgb("#b9cde5"), radius: 20pt)
}

#page(paper: "a0", margin: 5pt, background: image("assets/poster_background.pdf"))[
  #place(center, dx: 1cm, dy: 5.5cm, text(size: 100pt, [2026 Thesis Project]))

  #place(center, dx: 0cm, dy: 17cm, box[
    #align(center)[
      #text(weight: "bold", size: 82pt)[Profiling IoT Devices using Power Side Channel Techniques]
      #text(size: 72pt, emph[Author: Jack Robbers]) \
      #text(size: 48pt, emph[Supervisor: Hassan Habibi Gharakheili])
    ]
  ])

  #place(center, dy: 25cm, align(left, box(inset: 2em, grid(
    columns: (1fr, 1fr),
    column-gutter: 2em,
    row-gutter: 2em,
    rows: 10,
    grid.cell(colspan: 1, container([
      = Introduction
      IoT is a
    ])),
    grid.cell(colspan: 1, container([
      = Thesis Aims
      IoT is a
    ])),
    grid.cell(colspan: 1, container([
      = Method
      IoT is a
    ])),
    grid.cell(colspan: 1, container([
      = Dataset Creation

      Created a dataset to complement and verify existing data.


    ])),
    grid.cell(colspan: 2, container([
      = Introduction
      IoT is a
    ])),
    grid.cell(colspan: 2, container([
      = Conclusion
      IoT is a
    ])),
  ))))
]
