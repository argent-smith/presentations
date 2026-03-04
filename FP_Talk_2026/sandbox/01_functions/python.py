# Python: замыкание явное, каррирование через functools
from functools import partial

def multiply(factor, x):
    return factor * x

triple = partial(multiply, 3)
result = list(map(triple, [1, 2, 3, 4, 5]))
print(result)
# result: [3, 6, 9, 12, 15]
