// JavaScript: замыкание — родная идиома
const multiply = factor => x => factor * x;
const triple = multiply(3);
const result = [1, 2, 3, 4, 5].map(triple);
console.log(result);
// result: [3, 6, 9, 12, 15]
