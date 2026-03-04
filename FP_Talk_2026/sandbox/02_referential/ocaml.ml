(* OCaml: чистая функция — результат определяется только аргументами *)
let apply_discount rate price =
  price *. (1.0 -. rate)

let () =
  let d1 = apply_discount 0.1 100.0 in
  let d2 = apply_discount 0.1 100.0 in
  Printf.printf "первый вызов:  %.1f\n" d1;
  Printf.printf "второй вызов: %.1f\n" d2;
  Printf.printf "всегда одно и то же: %b\n" (d1 = d2)
