-- Показать самый популярный товар магазина (больше всего раз продавался)

SELECT  p.name
FROM Product p 
WHERE p.id IN (SELECT TOP 1 s.id_product
				FROM Sale s
				ORDER BY s.quantity ASC)

-- Если общее количество товаров всех категорий принять за 100%, необходимо посчитать, сколько товаров каждой категории (в процентном отношении) было продано

SELECT c.name,
COUNT(p.name) AS [количество товаров],
(SELECT COUNT(*) FROM Product) AS [общее количество всех товаров],
CAST(CAST(COUNT(p.name) AS float) / (SELECT COUNT(*) FROM Product) * 100 AS nvarchar) + '%' AS [в процентном соотношении]
FROM Category c
JOIN Product p ON p.id_category = c.id
GROUP BY c.name

-- Показать названия поставщиков, которые не поставляли йогурт

SELECT s.name
FROM Supplier s
WHERE s.id IN (SELECT d.id_supplier
				FROM Delivery d
				WHERE d.id_product IN (SELECT p.id
										FROM Product p
										WHERE p.name <> 'Йогурт'))

-- Показать на экран список производителей, которые живут в той же стране, что и фирма ООО “Зеленоглазое такси”

SELECT p.name
FROM Producer p
WHERE p.id_address IN (SELECT a.id
						FROM Address a
						WHERE a.id_city IN (SELECT c.id
											FROM City c
											WHERE c.id_region IN (SELECT r.id
																	FROM Region r
																	WHERE r.id_country IN (SELECT co.id
																							FROM Country co
																							WHERE co.id IN (SELECT r.id_country
																											FROM Region r
																											WHERE r.id IN (SELECT c.id_region
																															FROM City c
																															WHERE c.id IN (SELECT a.id_city
																																			FROM Address a
																																			WHERE a.id IN(SELECT p.id_address
																																							FROM Producer p
																																							WHERE p.name = 'ООО “Зеленоглазое такси”'))))))))

-- Показать всех производителей, количество наименований товаров которых в магазине больше, чем количество наименований всех товаров фирмы ООО «Самтаймс»

SELECT pr.name
FROM Product p
JOIN Producer pr ON p.id_producer = pr.id
GROUP BY pr.name
HAVING COUNT(p.name) > (SELECT COUNT(p.name)
						FROM Product p
						WHERE p.id_producer IN(SELECT pr.id
												FROM Product pr
												WHERE pr.name = 'ООО «Самтаймс»'))

-- Показать общее количество продаж по каждому дню, начиная от 01.01.2023, и по сей день. Отсортировать по убыванию даты

SELECT s.date_of_sale, COUNT (*) AS 'quantity'
FROM Sale s
WHERE s.date_of_sale >= '2023-01-01'
GROUP BY s.date_of_sale
ORDER BY s.date_of_sale DESC

-- Вычислить количество товаров каждой категории, которые пора списать (их количество известно, и они не продавались вот уже три месяца)

SELECT c.name, COUNT(p.name) AS 'total items to write off' 
FROM Category c JOIN Product p
ON c.id = p.id_category
WHERE p.id IN (SELECT s.id_product
				FROM Sale s
				WHERE s.date_of_sale < DATEADD(month, -3, GETDATE())) AND p.quantity IS NOT NULL
GROUP BY c.name