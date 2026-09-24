#import "@preview/rectangles-polylux:0.1.0": *
#import "@preview/cetz:0.4.2"
#import "@preview/callisto:0.3.0"
#import "@preview/numty:0.1.0" as nt

#let (source, display, result, output, outputs, render, Out) = callisto.config(
  nb: path("powerids analysis.ipynb"),
)


#show: rectangles-theme.with(
  aspect-ratio: "16-9",
  title: "Week 2 Progress",
  authors: "Jack Robbers",
  short-title: none, // The title that is displayed in the footer. Defaults to `[#title – #subtitle]`.
  short-authors: none, // The authors that are displayed in the footer. Defaults to authors, possibly connected with commas.
  accent-fill-color: orange, // The color of the slide decoration.
  accent-text-color: none, // The color of the text on the decoration. Defaults to black or white, depending on `accent-fill-color`.
  text-size: 20pt,
  date: "",
)

#title-slide()

#slide(title: "Work & Updates")[
        - *Budget*: \$200 Total, I've used \$33. Way cheaper in bulk, could get 5 for \$100. #underline(text(fill: blue, link("https://au.store.tapo.com/products/mini-smart-wi-fi-socket-energy-monitoring-tapo-p110")[Store]))
        - Confusion Matrix + F1 score
        - Testing different
        
]

#slide(title: "Deadlines")[
        #table(columns: 3, 
                [Thing], [When], [Notes],
                [B Report], [12:00 1st Oct], [\~10 pages],
                [Poster], [13:59 13th Nov], [at least 1 day early to print],
                [C Report], [12:00 19th Nov], [\~40 pages],
                [Executive Summary], [12:00 19th Nov], [\~5 pages ]
        )

        October to finalise work

        November to for Report + Poster
]