#import "@preview/callisto:0.3.0"

#let (source, display, result, output, outputs, render, Out) = callisto.config(
  nb: path("analysis.ipynb"),
)

// TODO: criticise dataset, not specific on what devices


#let render_table(label, item) = {
  // Render a table from the notebook, requires a corresponding python function to put in to the correct format
  let t = output(label, item: item, format: "text/plain").split().map(str => str.split(","))
  table(columns: t.at(0).len(), ..t.flatten())
}

Helloaaa

#render_table("tables", 0)

testaaaa
// #(..output("tables", item: 0).split(", "))

// #table(..output("tables", item: 0).split(", "))