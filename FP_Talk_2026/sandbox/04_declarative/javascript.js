// JavaScript: цепочка методов массива — декларативная идиома
const orders = [
  { price: 50 }, { price: 120 }, { price: 200 }, { price: 80 }, { price: 150 }
];

const totalDiscount = (orders) =>
  orders
    .filter(o => o.price > 100)
    .map(o => o.price * 0.1)
    .reduce((acc, d) => acc + d, 0);

console.log("сумма скидок:", totalDiscount(orders));
// ожидаемый результат: 47
