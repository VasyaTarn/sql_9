-- �������� ����� ���������� ����� �������� (������ ����� ��� ����������)

SELECT  p.name
FROM Product p 
WHERE p.id IN (SELECT TOP 1 s.id_product
				FROM Sale s
				ORDER BY s.quantity ASC)

-- ���� ����� ���������� ������� ���� ��������� ������� �� 100%, ���������� ���������, ������� ������� ������ ��������� (� ���������� ���������) ���� �������

SELECT c.name,
COUNT(p.name) AS [���������� �������],
(SELECT COUNT(*) FROM Product) AS [����� ���������� ���� �������],
CAST(CAST(COUNT(p.name) AS float) / (SELECT COUNT(*) FROM Product) * 100 AS nvarchar) + '%' AS [� ���������� �����������]
FROM Category c
JOIN Product p ON p.id_category = c.id
GROUP BY c.name

-- �������� �������� �����������, ������� �� ���������� ������

SELECT s.name
FROM Supplier s
WHERE s.id IN (SELECT d.id_supplier
				FROM Delivery d
				WHERE d.id_product IN (SELECT p.id
										FROM Product p
										WHERE p.name <> '������'))

-- �������� �� ����� ������ ��������������, ������� ����� � ��� �� ������, ��� � ����� ��� ������������� �����

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
																																							WHERE p.name = '��� ������������� �����'))))))))

-- �������� ���� ��������������, ���������� ������������ ������� ������� � �������� ������, ��� ���������� ������������ ���� ������� ����� ��� ���������

SELECT pr.name
FROM Product p
JOIN Producer pr ON p.id_producer = pr.id
GROUP BY pr.name
HAVING COUNT(p.name) > (SELECT COUNT(p.name)
						FROM Product p
						WHERE p.id_producer IN(SELECT pr.id
												FROM Product pr
												WHERE pr.name = '��� ���������'))

-- �������� ����� ���������� ������ �� ������� ���, ������� �� 01.01.2023, � �� ��� ����. ������������� �� �������� ����

SELECT s.date_of_sale, COUNT (*) AS 'quantity'
FROM Sale s
WHERE s.date_of_sale >= '2023-01-01'
GROUP BY s.date_of_sale
ORDER BY s.date_of_sale DESC

-- ��������� ���������� ������� ������ ���������, ������� ���� ������� (�� ���������� ��������, � ��� �� ����������� ��� ��� ��� ������)

SELECT c.name, COUNT(p.name) AS 'total items to write off' 
FROM Category c JOIN Product p
ON c.id = p.id_category
WHERE p.id IN (SELECT s.id_product
				FROM Sale s
				WHERE s.date_of_sale < DATEADD(month, -3, GETDATE())) AND p.quantity IS NOT NULL
GROUP BY c.name