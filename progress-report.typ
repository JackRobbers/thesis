#import "@preview/callisto:0.3.0"
#import "eestyle2.typ": *


#let (source, display, result, output, outputs, render, Out) = callisto.config(
  nb: path("analysis.ipynb"),
)

#show: eestyle2

// TODO: criticise dataset, not specific on what devices
#align(center)[

  #image("assets/logo.pdf")

  #large([*SCHOOL OF ELECTRICAL ENGINEERING\
  AND TELECOMMUNICATIONS*])
  #v(1cm)
  #huge([*Progress Report*])

  #Large([by])
  #v(-0.2cm)
  #huge([Jack Robbers])
  #v(-0.2cm)
  #Large([Student ID: z5263682])
  #v(0.5cm)

  #Large([Thesis submitted as a requirement for the degree \ Bachelor of Engineering (Electrical Engineering)])
]

#align(center + bottom)[
  #Large(
    [Submitted: #datetime.today().display("[month repr:long] [day] [year]") \ Supervisor: A/Prof Hassan Habibi Gharakheili],
  )
]

#let render_table(label, item) = {
  let t = output(label, item: item, format: "text/plain").split().map(str => str.split(","))
  table(columns: t.at(0).len(), ..t.flatten())
}

#pagebreak()
#outline()
#pagebreak()

= Preliminary Results

== Results

== Discussion

== Solutions

=== Future Direction / Things to try

non rectangular windows? do end effects matter? not with simple metrics?

= Reflection

= Plan

October

Build dataset

Nov report, poster
