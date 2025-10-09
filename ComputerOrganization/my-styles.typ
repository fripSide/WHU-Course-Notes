#set page("a4")
#set heading(numbering: "1.")
#show heading: it => {
    block(it.body)
}

#let font = (
  main: "IBM Plex Serif",
  mono: "IBM Plex Mono",
  cjk: "Noto Serif CJK SC",
)

#let qt(body) = {
  block(
    stroke: 0.5pt,
    fill: white,
    inset: 8pt,
    width: 100%,
    [#body]
  )
}

#show link: it => {
  underline(emph(text(fill: blue, it)))
}