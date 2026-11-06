#import "assets/diagrams.typ": *
#import "assets/eestyle2.typ": *
#show: eestyle2
#import "assets/common.typ": *

// TODO figure instead of table for dataset
// TODO

#set text(font: "Arial GEO")
#set par(leading: 16pt)

#show math.equation: set text(font: "Arial", size: 35pt)

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
      #text(weight: "bold", size: 82pt)[Profiling IoT Devices using Power Consumption] \
      #text(size: 72pt, emph[Author: Jack Robbers]) \
      #text(size: 48pt, emph[Supervisor: Hassan Habibi Gharakheili])
    ]
  ])

  #place(center, dy: 25cm, align(left, box(inset: 2em, height: 79%, grid(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    column-gutter: 2em,
    row-gutter: 2em,
    rows: (1.8fr, 3fr, 1fr, 2fr),
    grid.cell(colspan: 2, container([
      = Problem Statement

      The majority of existing work on IoT Profiling focuses on the network, but this can't provide insight when nothing is being transmitted but something is happening in the background, can't know if it's fully idle or at full power.

      Power is an accessible.

      This thesis focuses on a non machine learning approach in order to more fully understand the problem and see how far it can go. Also would be more performance on edge-computing devices.
    ])),
    grid.cell(colspan: 4, container([
      = Background

      #grid(
        columns: 3,
        gutter: 1em,
        // TODO align all the figures?
        [#bold[Internet of Things (IoT):] Any networked sensor or small appliance is part of the Internet of Things. There are around 24 billion active devices and the market is valued at 860 billion \$USD.
          #figure(
            block(inset: (top: -4.5em, bottom: -5em), clip: true, image("assets/image-4.png")),
            caption: [IoT devices in the UNSW EET Lab],
          )],
        [
          #bold[Side-channel:] Any channel that information "leaks" out of a device. Can be used to defeat encryption and air-gaps.
          #v(-30pt)
          #figure(
            align(center, scale-to-container(side-channels, width: 80%)),
            // align(center, side-channels),
            caption: [Side-channels of a networked device, the main channel is network.],
          ),],
        [

          #bold[F1 score:] Measures the performance of a class, the harmonic mean of recall and precision. The arithmetic mean of the F1 scores in a model gives overall performance.
          // #align(center + horizon, [
          //   $ "F1"_x = (2"TP") / (2"TP" + "FP" + "FN") $
          // ])
          // #align(center + horizon, [
          //   $overline("F1") = sum^(n)_(x = 1) "F1"_x / n$
          // ])
          #figure(
            [
              #align(center, [
                $"recall" = "TP" / ("TP" + "FN")$
              ])
              #align(center, [
                $"precision" = "TP" / ("TP" + "FP")$
              ])
              #v(25pt)
            ],
            caption: [Formulas for components of F1. TP = True Positive, FP = False Positive, FN = False Negative],
          )
        ],
      )])),

    grid.cell(colspan: 3, rowspan: 2, container([
      = Method to Classify Power Data by Device #contribution([1])

      #figure(
        [#scale-to-container(process) #v(25pt)],
        // [#process #v(25pt)],
        caption: [
          Process of producing a model. The initial input is time-series data, which is windowed. One or more metrics is then applied to each window, which forms the model.
        ],
      )


      #figure(
        scale-to-container(distance, width: 90%),
        caption: [Unseen training data is classified by minimising the distance to. The pictured data falls within the green class],
      )

    ])),
    grid.cell(colspan: 3, container([
      = Dataset #contribution([2.1])

      Created an extensible dataset.

      #figure(
        align(center, scale-to-container(data-collection, width: 90%)),
        caption: [Data collection process, scalable to any number of devices, all 6 devices were recorded at once],
      )

      #figure(
        caption: [Comparison between the existing SafeNetIoT dataset and my dataset. My dataset covers a lot less devices but has more data to make more confident conclusion from.],
        [
          #scale-to-container(width: 95%, table(
            columns: 3,
            bold[Property], bold[SafeNetIoT], bold[My Dataset],
            [Devices], [32], [6],
            [Trace length], [\~40 minutes], [78 hours],
            [Scenarios], [10], [1],
          ))
        ],
      )


    ])),
    grid.cell(colspan: 2, rowspan: 1, container([
      = SafeNetIoT Dataset
    ])),
    grid.cell(colspan: 1, container([
      = Repo
      Set of scripts to
    ])),
    grid.cell(colspan: 6, rowspan: 1, container([
      = Evaluation
      #grid(
        columns: (2fr, 1fr),
        [
          #table_image(
            "table_mini.pdf",
            width: 90%,
            caption: [) Performance across all classes #contribution[= 1.1], #contribution[= 1.2]],
          )

        ],
        [
          #table_image(
            "table_both.pdf",
            width: 90%,
            caption: [) Macro average F1 classifying by state. #contribution[= 1.3]],
          )
        ],
      )
    ])),
  ))))
]

