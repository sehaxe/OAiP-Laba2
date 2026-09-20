#include <stdio.h>

//Задача 2. Вариант 5
//Вычислить число Пи по формуле Грегори, взяв 500 членов ряда:
//П/4 = 1 - 1/3 + 1/5 - 1/7 + ...

int main(void) {
    double sum = 0;
    double denominator = 1;
    double sign = 1;

    for (int i = 0; i < 500; i++){
        sum = sum + sign / denominator;

        denominator = denominator + 2;
        sign = sign * (-1);
    }

    double pi = sum * 4;

    printf("Число Пи равно: %lf", pi);

    return 0;
}
