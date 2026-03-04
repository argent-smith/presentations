// Rust: замыкание с явным владением
fn multiply(factor: i32) -> impl Fn(i32) -> i32 {
    move |x| factor * x
}

fn main() {
    let triple = multiply(3);
    let result: Vec<i32> = vec![1, 2, 3, 4, 5].into_iter().map(triple).collect();
    println!("{:?}", result);
    // result: [3, 6, 9, 12, 15]
}
