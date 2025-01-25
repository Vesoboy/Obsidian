### Задание 1

Есть таблица users с полями id, parent_id, name.
```
+----+------------+-----------+
| id | name       | parent_id | 
+----+------------+-----------+
| 1  | Иван       | 2         | 
| 2  | Петр       | null      |
| 3  | Анна       | 2         |
| 4  | Сергей     | 1         |
| 5  | Ольга      | null      |
| 6  | Алексей    | 2         |
| 7  | Мария      | 5         |
| 8  | Дмитрий    | 2         |
+----+------------+-----------+
```

Выведите список имен всех пользователей, не являющихся руководителями.

Ответ:

```sql
SELECT name
FROM users
WHERE id NOT IN (SELECT DISTINCT parent_id FROM users WHERE parent_id IS NOT NULL);
```

```sql
SELECT u.name
FROM users u
LEFT JOIN users m ON u.id = m.parent_id
WHERE m.parent_id IS NULL;
```

---

### Задание 2

Есть таблицы:

Orders (order_id – PK, promocode_id – FK)
Promocodes (promocode_id – PK, name – UQ, discount)

```
+----------+--------------+
| order_id | promocode_id |
|----------|--------------|
| 1        | A123         |
| 2        | B456         |
| 3        | A123         |
| 4        | NULL         |
| 5        | C789         |
+----------+--------------+
```

```
+---------------+---------------+----------+
| promocode_id  | name          | discount |
|---------------|---------------|----------|
| A123          | Скидка 10%    | 10       |
| B456          | Скидка 20%    | 20       |
| C789          | Скидка 15%    | 15       |
+---------------+---------------+----------+
```

Какой самый популярный промокод (название) и число его использований?

Ответ:

```sql
SELECT p.name, COUNT(o.order_id) AS usage_count
FROM Promocodes p
LEFT JOIN Orders o ON p.promocode_id = o.promocode_id
GROUP BY p.promocode_id, p.name
ORDER BY usage_count DESC
LIMIT 1;
```

Выведите имена всех промокодов, promocode_id которых начинается на "B"

Ответ:

```sql
SELECT name FROM Promocodes WHERE promocode_id LIKE "B%";
```

---

### Задание 3

Есть таблица users с полями user_id, name, city

Выведите названия городов, которые встречаются более чем 5 раз

Ответ:

```sql
SELECT city, COUNT(city) 
FROM users
GROUP BY city
HAVING COUNT(city) > 1;
```

Как удрать дубликаты записей с несколькими полями

Ответ:

```sql
SELECT name, user_id, COUNT(*)
FROM users
GROUP BY name, user_id
HAVING COUNT(*) > 1
```

---

### Задание 4

```sql
SELECT
customers.name,
COUNT(order_id) as Total_orders,
SUM(order_amount) as total_spent
FROM customers
JOIN orders ON customers.id = orders.customer_id
WHERE order_date >= '2023-01-01'
GROUP BY customers.name
HAVING total_spent >= 1000
ORDER BY customers.name
LIMIT 100;
```

Ответ:

1. FROM (JOIN)
2. WHERE
3. GROUP BY
4. SELECT
5. HAVING
6. ORDER BY
7. LIMIT

---

### Задание 5

user
```
+----+-----------+----------+-------------+
| id | firstname | lastname | birth       |
|---------------|-----------|-------------|
| 1  | Иван      | Иванов   | 1990-01-01  |
| 2  | Петр      | Петров   | 1995-02-02  |
| 3  | Анна      | Аннова   | 1999-03-03  |
| 4  | Сергей    | Сергеев  | 1988-04-04  |
| 5  | Ольга     | Ольгова  | 1992-05-05  |
| 6  | Алексей   | Алексеев | 1991-06-06  |
| 7  | Мария     | Мариевна | 1993-07-07  |
| 8  | Дмитрий   | Дмитриев | 1989-08-08  |
----+-----------+----------+--------------+
```

purchase
```
+-------+-------+---------+------------+
| sku   | price | user_id | date       |
________________________________________    
| 11111 | 5500  | 1       | 2021-02-15 |
| 22222 | 4000  | 1       | 2021-02-14 |
| 33333 | 8000  | 2       | 2021-03-01 |
| 44444 | 400   | 2       | 2021-03-02 |
| 55555 | 1500  | 3       | 2021-04-05 |
| 66666 | 3000  | 4       | 2021-05-06 |
| 77777 | 2000  | 5       | 2021-06-07 |
| 88888 | 2500  | 6       | 2021-07-08 |
+-------+-------+---------+------------+
```

ban_list
```
+---------+------------+
| user_id | date       | 
| 1       | 2021-03-08 |
+---------+------------+
```

Составить запрос выводящий список уникальных клиентов и купленных ими товаров в марте

Ответ:

```sql
SELECT DISTINCT u.first_name, u.last_name, p.sku
FROM user u
INNER JOIN purchase p ON u.id = p.user_id
WHERE p.date >= '2021-03-01' AND p.date < '2021-04-01'
```

Составить запрос выводящий список уникальных клиентов, совершивших покупку товаров на сумму больше 5000 и не имеющих бана

Ответ:

```sql
SELECT u.first_name, u.last_name, p.price
FROM user u
INNER JOIN purchase p ON u.id = p.user_id
LEFT JOIN ban_list bl ON u.id = bl.user_id
WHERE p.price > 5000 AND bl.user_id IS NULL;
```

---

### Задание 6

Authors
```
+----+------------+
| id | firstname  |
+----+------------+
| 1  | Иван       |
| 2  | Петр       |
| 3  | Анна       |
| 4  | Сергей     |
| 5  | Ольга      |
| 6  | Алексей    |
| 7  | Мария      |
| 8  | Дмитрий    |
+----+------------+
```

Authors-Books
```
+---------+-----------+
| id_book | id_author |
+---------+-----------+
| 1       | 2         | -- Петр
| 2       | 1         | -- Иван
+---------+-----------+
```

Books
```
+----+------------+-----------+
| id | name       | id_reader |
+----+------------+-----------+
| 1  | Природа    | 3         |
| 2  | Работа     | 1         |
+----+------------+-----------+
```

Readers
```
+----+------------+
| id | name       |
+----+------------+
| 1  | UserAn     |
| 2  | Napa       |
| 3  | Tare       |
+----+------------+
```

Составить запрос выводящий список названий всех книг в библиотеке у которых больше 3 авторов

Ответ:

```sql
SELECT b.name, COUNT(id_author) as auth
FROM Books AS b
INNER JOIN Authors-Books AS ab ON ab.id_author = b.id
GROUP BY b.name
HAVING auth > 3
```

---

### Задача 7
Задача:
Вывести города по пользователям
Вывести города с пользователями и без
Вывести города с пользователями и без с сортировкой
Вывести города с пользователями и без и заменить 0 на Null
Вывести города с пользователями и без и заменить 0 на Null и сортировать по имени
Вывести города с пользователями и без и заменить 0 на Null и сортировать по имени и вывести номер строки

Дано:
```sql
CREATE TABLE cities
(
    id   serial PRIMARY KEY,
    name text NOT NULL
);

INSERT INTO cities (name)
VALUES ('Москва'),
       ('Санкт-Петербург'),
       ('Краснодар');

CREATE TABLE users
(
    id      serial PRIMARY KEY,
    name    text NOT NULL,
    city_id int  NOT NULL REFERENCES cities (id)
);

INSERT INTO users (name, city_id)
VALUES ('Иван', 1),
       ('Анна', 1),
       ('Олег', 2);
```

Ответ:

```sql
-- Города с пользователями и без
SELECT cities.name, users.name
FROM cities
LEFT JOIN users ON users.city_id = cities.id;
```

```sql
-- Города с пользователями и без с сортировкой по возрастанию и номеру строки по убыванию
SELECT c.name, NULLIF(COUNT(u.id), 0) AS users_count, @row_number() OVER (ORDER BY COUNT(u.id) DESC)
FROM cities c
LEFT JOIN users u ON u.city_id = c.id
GROUP BY c.name
ORDER BY COUNT(users.id);
```

---

### Задача 8

Есть две таблицы users, user_cars. У одного пользователя может быть неограниченное количество машин.
Необходимо написать запрос, который вернет 10 пользователей, у которых нет авто с car_id = 1

```
+------------------+
|users             |
+------------------+
|id uint           | - PK
|name string       |
+------------------+
```

```
+------------------+
|user_cars         | - uniq index (user_id, car_id)
+------------------+
|user_id uint      |
|car_id uint       |
+------------------+
```

Ответ:

Использование LEFT JOIN

```sql
SELECT u.*
FROM users u
LEFT JOIN user_cars uc ON u.id = uc.user_id AND uc.car_id = 1
WHERE uc.user_id IS NULL
LIMIT 10;
```

Использование подзапроса

```sql
SELECT *
FROM users u
WHERE u.id NOT IN (
    SELECT user_id
    FROM user_cars
    WHERE car_id = 1
)
LIMIT 10;
```

---

### Задание 9
MySQL
DevOps говорит, что в slowlog есть запрос, который выполняется дольше 10 секунд. Он отдал вам запрос и вы вызвали explain
О чем вам говорит вывод explain?
разобрать explain

```
+--+------------------+-----+----------+------+-------------------------------------------+-------------------------------------------+-------+-----------------+------+--------+------------------------+
|id|select_type       |table|partitions|type  |possible_keys                              |key                                        |key_len|ref              |rows  |filtered|Extra                   |
+--+------------------+-----+----------+------+-------------------------------------------+-------------------------------------------+-------+-----------------+------+--------+------------------------+
|1 |PRIMARY           |mc   |NULL      |ref   |idx_manager_id_client_id_uindex            |idx_manager_id_client_id_uindex            |1023   |const            |1     |100     |Using where; Using index|
|1 |PRIMARY           |m    |NULL      |eq_ref|idx_user_id                                |idx_user_id                                |1022   |bind.mc.client_id|1     |100     |Using where             |
|2 |DEPENDENT SUBQUERY|cdp  |NULL      |index |idx_client_id                              |idx_client_id                              |1022   |NULL             |189480|20.61   |Using where             |
+--+------------------+-----+----------+------+-------------------------------------------+-------------------------------------------+-------+-----------------+------+--------+------------------------+
```

оптимизировать запрос
Это сам запрос, что можно сделать, чтобы он работал максимально быстро?
Задача запроса выбрать клиентов определенного менеджера, у которых указано два этапа сделки

```sql
SELECT m.*
FROM members m
LEFT JOIN manager_clients mc on m.user_id = mc.client_id
WHERE mc.manager_id = '152734'
  AND m.user_id IN (SELECT client_id
                    FROM client_deal_phases cdp
                    WHERE cdp.phase_id IN (45, 47)
                    GROUP BY client_id
                    HAVING count(client_id) = 2
);
```

Ответ:

#### Анализ вывода EXPLAIN

1. Типы операций:

   • PRIMARY: Это основной запрос, который извлекает данные из таблицы members (m) и соединяет их с таблицей manager_clients (mc).

   • DEPENDENT SUBQUERY: Это подзапрос, который выполняется для каждой строки основного запроса. Он извлекает данные из таблицы client_deal_phases (cdp).

2. Тип соединения:

   • ref: Указывает на использование индекса для поиска строк в таблице. Это хороший знак, так как это означает, что запрос использует индексы.

   • eq_ref: Указывает на то, что для каждой строки из первой таблицы (в данном случае mc) будет найдена ровно одна строка из второй таблицы (m). Это также хороший знак.

3. Индексы:

   • Запрос использует индекс idx_manager_id_client_id_uindex для таблицы manager_clients и индекс idx_user_id для таблицы members. Также используется индекс idx_client_id в подзапросе.

   • Однако, подзапрос возвращает 189480 строк, что может быть причиной долгого выполнения запроса.

4. Количество строк:

   • В выводе указано, что для таблицы cdp будет обработано 189480 строк, и фильтрация в этом случае составляет 20.61%.
Это означает, что подзапрос может быть узким местом, так как он обрабатывает много строк.

---

#### Оптимизация запроса

Чтобы оптимизировать запрос и сделать его выполнение более быстрым, можно рассмотреть следующие рекомендации:

1. Индексы:

   • Убедитесь, что на колонках phase_id и client_id в таблице client_deal_phases есть соответствующие индексы. Это поможет ускорить выполнение подзапроса.

   • Также стоит проверить наличие индекса на колонне manager_id в таблице manager_clients.

2. Избегание подзапросов:

   • Вместо использования подзапроса можно попробовать использовать JOIN, что может быть более эффективно:

```sql
SELECT m.*
FROM members m
JOIN manager_clients mc ON m.user_id = mc.client_id
JOIN client_deal_phases cdp ON m.user_id = cdp.client_id
WHERE mc.manager_id = '152734'
AND cdp.phase_id IN (45, 47)
GROUP BY m.user_id
HAVING COUNT(DISTINCT cdp.phase_id) = 2;
```

3. Использование EXISTS:

   • Использование EXISTS вместо IN может улучшить производительность, так как MySQL может остановить выполнение, как только найдет первое совпадение:

```sql
SELECT m.*
FROM members m
LEFT JOIN manager_clients mc ON m.user_id = mc.client_id
WHERE mc.manager_id = '152734'
AND EXISTS (
SELECT 1
FROM client_deal_phases cdp
WHERE cdp.client_id = m.user_id
AND cdp.phase_id IN (45, 47)
GROUP BY cdp.client_id
HAVING COUNT(DISTINCT cdp.phase_id) = 2
);
```

4. Проверка статистики
   
   • Убедитесь, что статистика таблиц актуальна. Если данные изменялись, рекомендуется выполнить команду ANALYZE TABLE.

Для MySQL:
5 Профилирование запроса:

   • Используйте инструменты профилирования MySQL (например, SHOW PROFILE) для анализа выполнения запроса и выявления узких мест.

