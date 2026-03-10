(* OCaml: match — выражение, if — выражение, нет return *)
(* Компилятор проверяет полноту перебора — забытая ветка = ошибка *)
let classify n =
  match n with
  | n when n < 0 -> "negative"
  | 0            -> "zero"
  | _            -> "positive"

let () =
  List.iter (fun n ->
    Printf.printf "%d → %s\n" n (classify n)
  ) [-3; 0; 5]
