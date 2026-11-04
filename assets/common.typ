#import "@preview/callisto:0.3.0"
#let (source, display, result, output, outputs, render, Out) = callisto.config(
  nb: path("../src/analysis.ipynb"),
)

#let todo(content) = {
  [TODO: *#content*]
}

#show figure: set figure.caption(position: bottom)


#show figure.where(
  kind: table,
): set figure.caption(position: top)

#show outline.entry: it => link(
  it.element.location(),
  it.indented(it.prefix(), it.inner()),
)

// Bold all table titles and right align non index
#show table.cell: cell => {
  let styled_cell = cell
  if cell.x != 0 {
    styled_cell = align(right, styled_cell)
  } else {
    styled_cell = align(left, styled_cell)
  }
  if cell.y == 0 {
    styled_cell = [*#styled_cell*]
  }
  styled_cell
}

#let table_image(path, width: 100%, caption: "") = {
  figure(image(path, width: 100%), caption: caption, kind: table)
}
