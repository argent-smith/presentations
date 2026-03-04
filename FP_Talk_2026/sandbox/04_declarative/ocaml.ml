(* OCaml: pipeline с |> — намерение как цепочка шагов *)
type order = { price: float }

let orders = [
  { price = 50.0 };
  { price = 120.0 };
  { price = 200.0 };
  { price = 80.0 };
  { price = 150.0 };
]

let total_discount orders =
  orders
  |> List.filter (fun o -> o.price > 100.0)
  |> List.map (fun o -> o.price *. 0.1)
  |> List.fold_left ( +. ) 0.0

let () =
  Printf.printf "сумма скидок: %.1f\n" (total_discount orders)
(* ожидаемый результат: 47.0 *)
