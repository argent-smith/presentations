// JavaScript: spread-оператор; Object.freeze — поверхностное
const user = Object.freeze({ name: "Alice", age: 30 });
const olderUser = { ...user, age: 31 };

console.log("original:", user);
console.log("updated: ", olderUser);

// Object.freeze — только первый уровень вложенности
user.age = 99;  // молча игнорируется в non-strict mode
console.log("после попытки мутации user.age:", user.age);  // 30

// Вложенные объекты НЕ заморожены:
const nested = Object.freeze({ user: { name: "Bob", age: 25 } });
nested.user.age = 99;  // сработает!
console.log("вложенный объект после мутации:", nested.user.age);  // 99
