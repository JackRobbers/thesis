#import "@preview/rectangles-polylux:0.1.0": *
#import "@preview/cetz:0.4.2"
#import "@preview/callisto:0.3.0"
#import "@preview/numty:0.1.0" as nt

#let (source, display, result, output, outputs, render, Out) = callisto.config(
  nb: path("powerids analysis.ipynb"),
)


#show: rectangles-theme.with(
  aspect-ratio: "16-9",
  title: "Method",
  authors: "Jack Robbers",
  short-title: none, // The title that is displayed in the footer. Defaults to `[#title – #subtitle]`.
  short-authors: none, // The authors that are displayed in the footer. Defaults to authors, possibly connected with commas.
  accent-fill-color: orange, // The color of the slide decoration.
  accent-text-color: none, // The color of the text on the decoration. Defaults to black or white, depending on `accent-fill-color`.
  text-size: 20pt,
  date: "",
)

#title-slide()

#slide()[
  Bins of size $s$ samples, offset by $o$ samples from the previous bin. $o$ could be less than $s$.

  Profile the data by computing a metric on the data in each bin. Naive approach uses max and min values of each metric across the population.

  #figure(
    cetz.canvas({
      import cetz.draw: *
      let width = 25
      let height = 1
      let points = 100
      let max = 0
      for i in nt.linspace(0, 1, points) {
        let point = (calc.sin(i * 10) + calc.sin(i * 121) + calc.sin(i * 2009))
        if calc.abs(point) > max {
          max = calc.abs(point)
        }
        line((), (i * width, point * height))
      }
      let nudge = 0.2
      let window(height, offset, annot: false) = {
        rect((offset, -height), (5 + offset, height), stroke: red, name: "first")
        if annot {
          set-style(mark: (symbol: "|", scale: 2))
          line((rel: (0, -nudge), to: "first.south-west"), (rel: (0, -nudge), to: "first.south-east"), name: "annot")
          content("first.south")[#v(40pt) #text(fill: red, "s = 500")]
        }
      }

      let nice_height = max * height
      let offset = 6
      set-style(mark: (symbol: "|", scale: 2))
      line((0, nice_height + nudge), (offset, nice_height + nudge), name: "offset_annot")
      content("offset_annot.mid")[#v(-20pt) #text(fill: red, "o = 600")]

      for i in range(4) {
        let annot = false
        if i < 2 {
          annot = true
        }
        window(nice_height, i * offset, annot: annot)
      }
    }),
    caption: [Bins with $o$ = 600 and $s$ = 500],
  )
]

// #slide()[
//   The goal is to be able to uniquely distinguish each device.
//   \
//   #columns(2)[
//     #text(size: 30pt,align(center + horizon)[
//       // absolute overlap: \

//       distinguishability \
//       // $"width of overlapping regions" / "total width of values"$
//       #colbreak()


//       $"number of distinguishable devices" / "total number of devices"$
//     ])
//   ]
// ]

#slide()[
  = Method 1: by mean

  #output("profiles", item: 0)


]

#slide()[
  = Mean, zoomed in

  #output("profiles", item: 1)


]

#slide()[
  = Method 2: by std

  #output("profiles", item: 2)


]

#slide()[
  = Method 3: Both

  TODO: produce 2d graph of this
]

#slide()[
  = Evaluation:

  #text(size: 30pt, output("evaluation", item: 0, format: "text/plain"))

  Most devices are low powered, < 50 Watts


  Std overlaps more than mean, which makes sense since it doesn't carry information about the actual value, just it's spread.
]


#slide()[
  Test a range of values using colourmesh
  
]



#slide()[
  = Outlier Detection

  apply this
]



#slide()[
  = Confusion Metric
  
  table showing how it should be classified and what actually happened
]

#slide()[
  = Conformity Ttest
]



#slide()[
  Highlight some devices that are particularly bad / confusing to each other
]

#slide()[
  = Conclusions:

  Mean cannot actually fully distinguish this dataset, with the bins set at $s$ = 400 and $o$ = 10. I had a bug last week

  Std cannot, which makes sense since it only measures the spread, no the actual value of result
]

#slide()[
  = Next Steps / Limitations

  - Implement the absolute overlap metric
  
  - Implement a metric using both

  - Different values of o and s. Produce heatmap / colourmesh of this.


  - Using only the min and max of a metric means that an outlier can throw off the performance. See if a filter or taking the meidan is better

  - Explore fft?


]
