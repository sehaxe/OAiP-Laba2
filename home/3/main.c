#include <stdio.h>

//Задача 3. Вариант 5
//Даны целые положительные числа A и B. Найти их наибольший общий
//делитель (НОД), используя алгоритм Евклида.

int main(void) {
    unsigned int a, b, c;

    printf("Введите числа a и b: ");

    if (scanf("%u %u", &a, &b) == 2 && a > 0 && b > 0){
        while (b != 0){
            c = a % b;
            a = b;
            b = c;
        }
        printf("НОД: %u\n", a);
    } else {
        printf("Ошибка\n");
    }

    return 0;
}
