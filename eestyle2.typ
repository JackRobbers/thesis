// \usepackage{xcolor}%for enabling colours in documents
// \definecolor{unswred1}{RGB}{238,49,36}
#let unswred1 = rgb(238,49,36)
// \definecolor{unswred2}{RGB}{197,40,28}
#let unswred2 = rgb(197,40,28)
// \definecolor{unswred3}{RGB}{158,28,15}
#let unswred3 = rgb(158,28,15)
// \definecolor{unswred4}{RGB}{122,12,0}
#let unswred4 = rgb(122,12,0)
// \definecolor{unswblue1}{RGB}{0,174,239}
#let unswblue1 = rgb(0,174,239)
// \definecolor{unswblue2}{RGB}{0,146,200}
#let unswblue2 = rgb(0,146,200)
// \definecolor{unswblue3}{RGB}{0,118,163}
#let unswblue3 = rgb(0,118,163)
// \definecolor{unswblue4}{RGB}{0,91,127}
#let unswblue4 = rgb(0,91,127)
// \definecolor{unswyellow}{RGB}{255,212,0}
#let unswyellow = rgb(255,212,0)

#let embiggen(content, size) = [
    #set text(size: size)
    #content
]

#let large(content) = {
    embiggen(content, 14.4pt)
}

#let Large(content) = {
    embiggen(content, 17.28pt)
}

#let huge(content) = {
    embiggen(content, 24.88pt)
}

#let eestyle2(doc) = [
// \pdfpagewidth=210 true mm%fix for pslatex
// \pdfpageheight=297 true mm%fix for pslatex
// \usepackage[margin=2.54cm]{geometry}%for setting margins correctly
    #set page(width: 210mm, height: 297mm, margin: 2.54cm)
    #set text(size: 12pt, font: "Nimbus Roman")
    #set par(leading: 1em, first-line-indent: 0em, spacing: 1.5em)
    #show heading.where(depth: 1): set text(size: 24pt)
    #show heading.where(depth: 2): set text(size: 20pt)
    #show heading.where(depth: 3): set text(size: 16pt)
    #show figure: it => (v(1em) + it + v(1em))

// \usepackage{hyperref}%for internal document links
// \hypersetup{pdfborder=0 0 0}
// \hypersetup{colorlinks=true}
// \hypersetup{allcolors=unswred2}
    #show link: set text(fill: unswred2)


// \setlength{\extrarowheight}{1pt}
// commenting this out since defaults to 5pt
    // #set table(inset: (top: 1pt))
// \chapterfont{\color{unswred2}}
// \sectionfont{\color{unswred2}}
// \subsectionfont{\color{unswred2}}
// \subsubsectionfont{\color{unswred2}}
    #show heading: set text(fill: unswred2)

    #show heading: it => {v(0.5em) + it + v(0.5em)}
    #doc

]

// \usepackage[english]{babel}%for dealing neatly with umlauts
// \usepackage{units}%for consistent use of units
// \usepackage{url}%for type setting urls


// \usepackage{graphicx}%for including graphics
// \usepackage{array}%for better table control and commands
// \usepackage{verbatim}%for typesetting code
// \usepackage{latexsym}%for a few extra symbols - alternatively use amssymb
// \usepackage{sectsty}%for nice colourful headings

// \usepackage{tocbibind}%for adding bibliography to toc

// \renewcommand{\baselinestretch}{1.5}%

#let scale-to-container(body, width: auto, height: auto) = layout(ly => {
  let body-size = measure(body)

  scale(
    x: if width == auto { auto } else { ly.width / body-size.width * width },
    y: if height == auto { auto } else { ly.height / body-size.height * height },
    body,
    reflow: true
  )
})