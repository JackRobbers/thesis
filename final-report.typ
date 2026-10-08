// Style: 
// training -> model
// long captions, can be used isolated
// RQ in text

#import "@preview/callisto:0.3.0"
#import "eestyle2.typ": *
#import "util.typ": *


#let (source, display, result, output, outputs, render, Out) = callisto.config(
  nb: path("analysis.ipynb"),
)

#show figure: set figure.caption(position: bottom)


#show figure.where(
  kind: table
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
    }
    if cell.y == 0 {
        styled_cell = [*#styled_cell*]
    }
    styled_cell
  }

#let look-at-in-meeting(h) = {
    heading(level: 1)[$arrow$ #h]
}

#show: eestyle2


#outline()
#set heading(numbering: "1.")

= Work done this week:
- Finished the idle vs active
- 90% done on 2d median. need to squash a bug
- 25% done on k-means
- Got tapos, updated measurement scripts. 
- Updated repo for use as contribution, doctests, parametric

= Questions:

-Need access to computer

- Dr Nurdin email, B capped to 50% and 10% reduction on C

#look-at-in-meeting[Idle vs Average]


#figure(image("assets/confusion-matrix-idle-180-10.pdf", width: 120%), caption: [Confusion Matrix for Idle data windowed with w=180, s=10. Metric: mean and classification by median]) <idle180_10>

#figure(image("assets/confusion-matrix-active-180-10.pdf", width: 120%), caption: [Confusion Matrix for Active  data windowed with w=180, s=10. Metric: mean and classification by median]) <active180_10>

#figure(render_table(output("confusion matrix", item: 6)), caption: [Macro Average F1 Scores compared for Idle and Active datasets, windowed at w=180, s=10 and classified using mean metric and distance from median]) <macroavg>

@macroavg shows that the performance is better on the active dataset. This is due to there being more distinct levels of active power usage. In the idle dataset, the spread of power is lower so devices are more likely to overlap.

#look-at-in-meeting[$mu$ $sigma$ by 2d median]

Classify by both metrics using 2d median. 

Naive technique, feels like it introduces some error, but all the devices have it? They don't actually overlap

#figure(image("assets/PXL_20261007_224643298.jpg"), caption: [Rough diagram of method])


