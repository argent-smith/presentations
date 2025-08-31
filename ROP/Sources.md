# Рекомендации для дальнейшего изучения

## Учебные ресурсы по функциональному программированию

### Академические курсы
- [CS 3110: Data Structures and Functional Programming (Cornell University)](https://cs3110.github.io/textbook/) - отличный учебник по функциональному программированию с примерами на OCaml
- [Learn You a Haskell for Great Good](http://learnyouahaskell.com/) - доступное введение в Haskell и монады
- [Real World OCaml](https://dev.realworldocaml.org/) - практическое руководство по OCaml

### Функциональное программирование на "мейнстримных" языках
- [Functional Programming in Scala](https://www.manning.com/books/functional-programming-in-scala) - классический учебник
- [Scala with Cats](https://underscore.io/books/scala-with-cats/) - практическое применение функциональных паттернов
- [Functional Programming in JavaScript](https://mostly-adequate.gitbook.io/mostly-adequate-guide/) - FP концепции в JavaScript
- [Functional Programming in Python](https://docs.python.org/3/howto/functional.html) - официальная документация Python по FP
- [dry-rb](https://dry-rb.org/) - функциональные паттерны в Ruby

### Специфичные материалы по Railway-Oriented Programming
- [F# for Fun and Profit - Railway Oriented Programming](https://fsharpforfunandprofit.com/rop/) - оригинальная статья Scott Wlaschin
- [Railway Oriented Programming in Scala](https://blog.pjam.me/posts/railway-oriented-programming-scala/)
- [Functional Error Handling with Monads, Monad Transformers and Kleisli Arrows](https://www.47deg.com/blog/fp-error-handling/)

## Теория категорий и монады

### Введение в теорию
- [Category Theory for Programmers](https://bartoszmilewski.com/2014/10/28/category-theory-for-programmers-the-preface/) - Bartosz Milewski
- [Монады для программистов](https://habr.com/ru/articles/183150/) - статья на Хабре
- [Understanding Monads](https://en.wikibooks.org/wiki/Haskell/Understanding_monads) - Wikibooks

## FP- и монадные библиотеки в популярных языках программирования

### JavaScript / TypeScript
- [NeverThrow](https://github.com/supermacro/neverthrow) - Railway-Oriented Programming
- [fp-ts](https://gcanti.github.io/fp-ts/) - функциональное программирование для TypeScript
- [ts-railway](https://www.npmjs.com/package/ts-railway) - Railway-oriented programming
- [Ramda](https://ramdajs.com/) - функциональные утилиты
- [Sanctuary](https://sanctuary.js.org/) - типобезопасная FP библиотека

### Python
- [returns](https://github.com/dry-python/returns) - типобезопасные монады
- [toolz](https://toolz.readthedocs.io/) - функциональная стандартная библиотека
- [funcy](https://github.com/Suor/funcy) - практичные функциональные утилиты
- [PyMonad](https://github.com/jasondelaat/pymonad) - монады для Python
- [PyFunctional](https://github.com/EntilZha/PyFunctional) - функциональное программирование с коллекциями

### Ruby
- [dry-monads](https://dry-rb.org/gems/dry-monads/) - монады для Ruby
- [dry-rb](https://dry-rb.org/) - экосистема функциональных гемов

### Java
- [Vavr](https://vavr.io/) - функциональная библиотека для Java
- [RxJava](https://github.com/ReactiveX/RxJava) - реактивное программирование
- [Cyclops](https://github.com/aol/cyclops) - интеграция FP библиотек
- [FunctionalJava](https://www.functionaljava.org/) - классические FP конструкции

### C#
- [LanguageExt](https://github.com/louthy/language-ext) - функциональное программирование для C#
- [Functional.Maybe](https://github.com/nlkl/Optional) - Option monad
- [OneOf](https://github.com/mcintyre321/OneOf) - дискриминированные объединения
- [CSharpFunctionalExtensions](https://github.com/vkhorikov/CSharpFunctionalExtensions) - Result и Option типы

### Rust
- Встроенная поддержка: `Result<T, E>` и `Option<T>`
- [anyhow](https://github.com/dtolnay/anyhow) - улучшенная обработка ошибок
- [thiserror](https://github.com/dtolnay/thiserror) - производные для типов ошибок
- [itertools](https://github.com/rust-itertools/itertools) - расширенная работа с итераторами

### Scala
- [Cats](https://typelevel.org/cats/) - функциональное программирование
- [Cats Effect](https://typelevel.org/cats-effect/) - система эффектов
- [ZIO](https://zio.dev/) - современная библиотека эффектов
- [Scalaz](https://github.com/scalaz/scalaz) - функциональное программирование для Scala

### C++
- Встроенная поддержка: `std::optional` и `std::expected` (C++23)
- [range-v3](https://github.com/ericniebler/range-v3) - функциональное программирование с диапазонами
- [boost::outcome](https://github.com/ned14/outcome) - обработка ошибок в стиле Result
- [tl::expected](https://github.com/TartanLlama/expected) - C++11/14/17 реализация expected

### OCaml
- Встроенная поддержка: `Result.t` и монадические операции
- [ppx_let](https://github.com/janestreet/ppx_let) - синтаксис для монадических операций
- [lwt](https://github.com/ocsigen/lwt) - асинхронное программирование с монадами
- [Base](https://github.com/janestreet/base) - альтернативная стандартная библиотека с функциональными конструкциями

### F#
- Встроенная поддержка: `Result<'T, 'TError>` и computation expressions
- [FSharpPlus](https://github.com/fsprojects/FSharpPlus) - расширения для функционального программирования
- [Chessie](https://github.com/fsprojects/Chessie) - Railway Oriented Programming библиотека
- [FsToolkit.ErrorHandling](https://github.com/demystifyfp/FsToolkit.ErrorHandling) - утилиты для обработки ошибок
