// JavaScript: if — инструкция, тернар — выражение
// Нет проверки полноты перебора; switch тоже инструкция
const classify = (n) =>
  n < 0 ? "negative" : n === 0 ? "zero" : "positive";

[-3, 0, 5].forEach(n => console.log(`${n} → ${classify(n)}`));
