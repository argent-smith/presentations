// Rust: &mut сигнализирует о мутации в сигнатуре;
// чистая функция — без &mut, без глобального состояния
fn apply_discount(rate: f64, price: f64) -> f64 {
    price * (1.0 - rate)
}

fn main() {
    let d1 = apply_discount(0.1, 100.0);
    let d2 = apply_discount(0.1, 100.0);
    println!("первый вызов:  {:.1}", d1);
    println!("второй вызов: {:.1}", d2);
    println!("всегда одно и то же: {}", d1 == d2);
}
