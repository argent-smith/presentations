(* OCaml: каррирование по умолчанию *)
let multiply factor x = x * factor
let triple = multiply 3
let result = List.map triple [1; 2; 3; 4; 5]

let () =
  List.iter (fun x -> Printf.printf "%d " x) result;
  print_newline ()
(* result: [3; 6; 9; 12; 15] *)
