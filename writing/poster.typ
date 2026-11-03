#set text(font: "Arial")
#set par(leading: 30pt)

#let container(content) = {
    show heading.where(level: 1): set text(weight: "bold", size: 36pt)

    set text(size: 24pt)
    
    box(content, width: 100%, inset: 1em, stroke: 0.5em + rgb("#b9cde5"), radius: 20pt)
}

#page(paper: "a0", margin: 5pt, background: image("assets/poster_background.pdf"))[
    #place(left,  box(stroke: red)[

    #align(center)[
        #text(weight: "bold", size: 82pt)[Profiling IoT Devices using Power \ Side Channel Techniques] \
        #text(size: 72pt, emph[Author: Jack Robbers]) \
        #text(size: 48pt, emph[Supervisor: Hassan Habibi Gharakheili])
        ]
        ], dx: 25cm, dy: 1.5cm)
        #v(16cm)
        #box(inset: 2em, grid(columns: (1fr, 1fr, 1fr,1fr, 1fr), column-gutter: 2em, row-gutter: 2em, rows: 10, 
        grid.cell(colspan: 3, 
            container([
                = Thesis Aim
                == 
            ])
        ), container([
            = Thesis Aim
        ]), container([
            = Thesis Aim
        ])))
    ]
