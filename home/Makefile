all: 1/main 2/main 3/main

.PHONY: report
report:
	typst compile --root .. report/main.typ

1/main: 1/main.c
	gcc -Wall 1/main.c -o 1/main

2/main: 2/main.c
	gcc -Wall 2/main.c -o 2/main

3/main: 3/main.c
	gcc -Wall 3/main.c -o 3/main

clean:
	rm -f 1/main 2/main 3/main

# Блок-схемы: gostpadi 2.0 (Rust) рисует SVG прямо из main.c в report/assets/;
# отчёт подключает их оттуда. Одна схема: gostpadi 1/main.c -o 1.svg.
# --no-split: схема одним листом (без соединителей «А», «Б»), в А4 её
# вписывает общий масштаб пачки — в отчёте каждая схема на одной странице.
.PHONY: schemes
schemes:
	gostpadi --labels=ru --no-split 1/main.c 2/main.c 3/main.c -o report/assets/ --lw=1.5
