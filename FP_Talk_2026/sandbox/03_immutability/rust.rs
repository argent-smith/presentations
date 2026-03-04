// Rust: struct update syntax; let без mut — иммутабельно
#[derive(Debug, Clone)]
struct User {
    name: String,
    age: u32,
}

fn main() {
    let user = User { name: String::from("Alice"), age: 30 };
    let older_user = User { age: 31, ..user.clone() };

    println!("original: name={}, age={}", user.name, user.age);
    println!("updated:  name={}, age={}", older_user.name, older_user.age);
    // let mut нужен явно для мутации — компилятор не даст забыть
}
