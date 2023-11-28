// General template made for labs
// Tries to mimic GOST 7.32-2017

#let lab(
    n: none,
    body
) = {
    set document(title: "TK LAB" + str(n), author: "Сорочан Илья")

    set text(
        font: "Times New Roman", 
        size: 14pt,
        lang: "ru"
    )

    set page(
        margin: (
            left: 3cm,
            right: 1.5cm,
            y: 2cm
        )
    )

    line(length: 100%)
    grid(
        columns: (24%, auto),
        rows: (12%),
        gutter: 20pt,
        image("logo.png", fit: "stretch"),
        align(center, text(17pt)[
            *
            ИНСТИТУТ ИНТЕЛЛЕКТУАЛЬНЫХ КИБЕРНЕТИЧЕСКИХ СИСТЕМ \
            #v(5%)
            Кафедра \
            «Криптология и кибербезопасность»
            *
            ]
        )
    )
    line(length: 100%)

    v(15%)

    align(center)[ 
        #text(24pt)[
            *Лабораторная работа №#n*
        ]

        #text(18pt)[
            по предмету "Технологии контейнеризации"
        ]

        #v(1%)

        #text(16pt)[
            Выполнил студент группы Б20-505
        
            *Сорочан Илья*
        ]

        #align(bottom)[
            #line(length: 100%)

            *Москва – 2023*

            #line(length: 100%)
        ]
    ]

    pagebreak()
    set page(numbering: "1")

    outline()
    
    pagebreak()

    set par(
        // Word and Typst seems to differ
        // Word 7.32 - 1.5em
        leading: 1em, 
        justify: true, 
        first-line-indent: 1.25cm
    )

    set heading(numbering: "1.")

    show heading: it => block[
        #h(1.25cm)
        #counter(heading).display()
        #it.body
    ]

    // Hack: https://github.com/typst/typst/issues/311
    show heading: it => {
        it
        par()[#text(size:0.5em)[#h(0.0em)]]
    }

    // Same hack as above for figures
    show figure: it =>  {
        it
        par()[#text(size:0.5em)[#h(0.0em)]]
    }

    // Code show rules
    // With hack as above
    show raw.where(block: true): it => {
        block(
            fill: rgb("#f0f0f0"),
            inset: 6pt,
            radius: 2pt,
            text(fill: rgb("#202020"), it)
        )
        par()[#text(size:0.5em)[#h(0.0em)]]
    }

    body
}

#let pic(
    img: none,
    body
) = {
    figure(
        image(img, fit: "contain"),
        caption: [#body]
    )
}