// Rust: ленивые итераторы — декларативно и без промежуточных аллокаций
struct Order {
    price: f64,
}

fn total_discount(orders: &[Order]) -> f64 {
    orders.iter()
        .filter(|o| o.price > 100.0)
        .map(|o| o.price * 0.1)
        .sum()
}

fn main() {
    let orders = vec![
        Order { price: 50.0 },
        Order { price: 120.0 },
        Order { price: 200.0 },
        Order { price: 80.0 },
        Order { price: 150.0 },
    ];
    println!("сумма скидок: {:.1}", total_discount(&orders));
    // ожидаемый результат: 47.0
}
