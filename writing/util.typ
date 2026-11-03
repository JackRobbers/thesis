#let diagbox(text_left, text_right, start: "top", ..kwargs) = {
  let content = context {

    let stroke = kwargs.at("stroke", default: 1pt + black)
    let inset = kwargs.at("inset", default: 0% + 5pt)
    
    let padded_right = pad(text_right, inset)
    let padded_left = pad(text_left, inset)

    let measure_right = measure(padded_right)
    let measure_left = measure(padded_left)

    // Used to account for big differences between text widths
    let width_diff = calc.abs(measure_right.width - measure_left.width)

    let inner_height = measure_right.height + measure_left.height + width_diff / 10
    let inner_width = measure_right.width + measure_left.width

    box(width: inner_width, height: inner_height) // Empty box to ensure minimal size

    if start == "bottom" {
      place(bottom + right, padded_right)
      place(top + left, line(start: (0%, 100%), end: (100%, 0%), stroke: stroke))
      place(top + left, padded_left)
    }
    else if start == "top" {
      place(top + right, padded_right)
      place(top + left, line(end: (100%, 100%), stroke: stroke))
      place(bottom + left, padded_left)
    }
    else {
      panic("Unhandled value '" + start + "' for start parameter, expected 'top' or 'bottom'")
    }
  }
  table.cell(content, ..kwargs, inset: 0pt, breakable: false)
}

#let render_table(output) = {
  // typst gives us a string starting with a #, remove that and slash it off
    // output

  eval(output.slice(2, -1), scope:(diagbox: diagbox))
}

// #figure(
//     cetz.canvas({
//       import cetz.draw: *
//       let width = 15
//       let height = 1
//       let points = 100
//       let max = 0
//       for i in nt.linspace(0, 0.45, points) {
//         let point = (calc.sin(i * 100000) + calc.sin(i * 121) + calc.sin(i * 2009))
//         if calc.abs(point) > max {
//           max = calc.abs(point)
//         }
//         line((), (i * width, point * height))
//       }
//       // let nudge = 0.2
//       let width = 5
//       let window(height, start) = {
//           set-style(mark: (symbol: "|", scale: 5))
//           line((start, height), (start + width, height), name: "annot", stroke: red+5pt)
    
//       }

//       let offset = 0.50
//       for i in range(5) {
//         let annot = false
//         window(-2+calc.rem(i,15), i * offset)
//       }
//     }),
//     caption: [Windows with $w$ = 180 and $s$ = 10],
//   )