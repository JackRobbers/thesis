#import "@preview/callisto:0.3.0"
#let (source, display, result, output, outputs, render, Out) = callisto.config(
  nb: path("../src/analysis.ipynb"),
)

#let todo(content) = {
  [TODO: *#content*]
}

#let table_image(path, width: auto, caption: none) = {
  figure(image("../generated/table_" + path + ".pdf", width: width), caption: caption, kind: table)
}
