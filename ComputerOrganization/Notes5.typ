
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


updated: 2025-09-22

= 第三章-2

