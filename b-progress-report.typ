#import "@preview/callisto:0.3.0"

#let (source, display, result, output, outputs, render, Out) = callisto.config(
  nb: path("analysis.ipynb"),
)

// TODO: criticise dataset, not specific on what devices


#let render_table(label, item) = {
  // table(..output(label, item: item).split(", "))
  output(label, item: item, format: "text/plain")
}

Helloaaa

#render_table("tables", 0)

test
// #(..output("tables", item: 0).split(", "))

// #table(..output("tables", item: 0).split(", "))