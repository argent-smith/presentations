// JavaScript: чистота не гарантируется — только дисциплина

// Нечистая: замыкание захватывает внешнее состояние
let taxRate = 0.2;
const priceWithTax = (price) => price * (1 + taxRate);

// Чистая: результат определяется только аргументами
const applyDiscount = (rate) => (price) => price * (1 - rate);

console.log("нечистая:", priceWithTax(100));  // 120

taxRate = 0.5;
console.log("нечистая после изменения taxRate:", priceWithTax(100));  // 150!

console.log("чистая первый раз: ", applyDiscount(0.2)(100));  // 80 всегда
console.log("чистая второй раз:", applyDiscount(0.2)(100));  // 80 всегда
