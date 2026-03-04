(* OCaml: record — иммутабелен по умолчанию *)
type user = { name: string; age: int }

let user = { name = "Alice"; age = 30 }
let older_user = { user with age = 31 }

let () =
  Printf.printf "original: %s, age %d\n" user.name user.age;
  Printf.printf "updated:  %s, age %d\n" older_user.name older_user.age
  (* user не изменился; older_user — новое значение *)
