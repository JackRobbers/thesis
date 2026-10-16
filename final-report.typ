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
    } else {
      styled_cell = align(left, styled_cell)
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
- 2d (or nD median)
- mu and std metric
- summary table with
- didn't do k means because this more for building classes
// - tried fft but with poor performance

= Questions:
- should I try a random forest classifier? / different ML techniques. Can try to replicate paper
= Results

== Idle vs Active


#figure(image("assets/confusion-matrix-idle-180-10.pdf", width: 120%), caption: [Confusion Matrix for Idle data windowed with w=180, s=10. Metric: mean and classification by median]) <idle180_10>

#figure(image("assets/confusion-matrix-active-180-10.pdf", width: 120%), caption: [Confusion Matrix for Active  data windowed with w=180, s=10. Metric: mean and classification by median]) <active180_10>

#figure(render_table(output("confusion matrix", item: 6)), caption: [Macro Average F1 Scores compared for Idle and Active datasets, windowed at w=180, s=10 and classified using mean metric and distance from median]) <macroavg>

@macroavg shows that the performance is better on the active dataset. This is due to there being more distinct levels of active power usage. In the idle dataset, the spread of power is lower so devices are more likely to overlap.

== Effect of window size and shift

== $mu$ $sigma$ by 2d median

Classify by both metrics using 2d median. 

Naive technique, feels like it introduces some error, but all the devices have it? They don't actually overlap

#figure(image("assets/confusion-matrix-idle-300-120-mean-std-Median.pdf"), caption: [Confusion Matrix for Idle  data windowed with w=300, s=120. Metric: $mu$ and $sigma$ and classification by median])

#figure(image("assets/confusion-matrix-active-300-120-mean-std-Median.pdf"), caption: [Confusion Matrix for Active  data windowed with w=300, s=120. Metric: $mu$ and $sigma$ and classification by median])

// == By first harmonic

== Centroid Classifier

== Summary Table / Problematic Devices
 
#[
  #show table.cell.where(body: [1.000]): it => {
    highlight(fill: green)[#it]
  }

   #show table.cell.where(y: 33): it => {
    [*#it*]
  }

  #figure(
    render_table(output("summary", item: 0)), caption: [Comparison of F1 scores between idle and active datasets and either $mu$ only or $mu$ and $sigma$ together. All classifications are by median and w = 300, s = 120. Sorted by the performance in Idle by $mu$] 
  )
  <comparison>
  
]

@comparison compares the performances of all devices in the both the idle and active datasets. 

- The overall performance is better in the active mode, but individual devices that perform well in idle do not necessarily perform as well in active. 

- The performance can degrade by adding the additional metric (e.g Google Nest in Idle), I need to investigate further, but this can happen.

- The worst devices are: Honeywell Thermostat, Weekett Kettle, Antella Light, Leopro Light, Echo Spot 5 Speaker
