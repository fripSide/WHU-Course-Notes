#set page("a4")
#set heading(numbering: "1.")
#show heading: it => {
    if (it.level <= 1){
        block(it.body)
    } else if (it.level == 2) {
        block(counter(heading).display() + " " + it.body)
    } else {
        block(it.body)
    }
}

#let font = (
  main: "IBM Plex Serif",
  mono: "IBM Plex Mono",
  cjk: "Noto Serif CJK SC",
)

#show link: underline

#let qt(body) = {
  block(
    stroke: 0.5pt,
    fill: white,
    inset: 8pt,
    width: 100%,
    [#body]
  )
}
