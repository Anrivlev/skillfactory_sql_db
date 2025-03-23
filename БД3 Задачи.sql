-- Задача 1
-- Определить, какие клиенты сделали более двух бронирований 
-- в разных отелях, и вывести информацию о каждом таком клиенте, 
-- включая его имя, электронную почту, телефон, общее количество 
-- бронирований, а также список отелей, в которых они бронировали 
-- номера (объединенные в одно поле через запятую с помощью CONCAT). 
-- Также подсчитать среднюю длительность их пребывания (в днях) по всем 
-- бронированиям. Отсортировать результаты по количеству бронирований в 
-- порядке убывания.

 SELECT
        C.name AS customer_name,
        C.email,
        C.phone,
        COUNT(*) AS total_bookings,
        STRING_AGG(DISTINCT h.name, ', ') AS hotels_booked,
        AVG(CAST(B.check_out_date - b.check_in_date AS INTEGER)) AS avg_stay_days
    FROM Customer C
    JOIN Booking B USING (id_customer)
    JOIN Room R USING (id_room)
    JOIN Hotel H USING (id_hotel)
    GROUP BY C.name, C.email, C.phone
    HAVING COUNT(DISTINCT H.id_hotel) > 1 AND COUNT(*) > 2
	ORDER BY total_bookings DESC;

-- Задача 2
-- Необходимо провести анализ клиентов, которые сделали более 
-- двух бронирований в разных отелях и потратили более 500 долларов 
-- на свои бронирования. Для этого:

-- Определить клиентов, которые сделали более двух бронирований и 
-- забронировали номера в более чем одном отеле. Вывести для каждого 
-- такого клиента следующие данные: ID_customer, имя, общее количество 
-- бронирований, общее количество уникальных отелей, в которых они 
-- бронировали номера, и общую сумму, потраченную на бронирования.
-- 
-- Также определить клиентов, которые потратили более 500 долларов на 
-- бронирования, и вывести для них ID_customer, имя, общую сумму, 
-- потраченную на бронирования, и общее количество бронирований.
--
-- В результате объединить данные из первых двух пунктов, чтобы 
-- получить список клиентов, которые соответствуют условиям обоих запросов. 
-- Отобразить поля: ID_customer, имя, общее количество бронирований, 
-- общую сумму, потраченную на бронирования, и общее количество 
-- уникальных отелей.
-- Результаты отсортировать по общей сумме, потраченной клиентами, 
-- в порядке возрастания.

WITH CustomerBookings AS (
    SELECT
        C.id_customer,
        C.name,
        COUNT(*) AS total_bookings,
        COUNT(DISTINCT H.id_hotel) AS unique_hotels,
        SUM(R.price) AS total_spent
    FROM Customer C
    JOIN Booking B USING (id_customer)
    JOIN Room R USING (id_room)
    JOIN Hotel H USING (id_hotel)
    GROUP BY C.id_customer, C.name
    HAVING COUNT(*) > 2 AND COUNT(DISTINCT H.id_hotel) > 1
),
HighSpenders AS (
    SELECT
        C.id_customer,
        C.name,
        SUM(r.price) AS total_spent,
        COUNT(*) AS total_bookings
    FROM Customer C
    JOIN Booking B USING (id_customer)
    JOIN Room R USING (id_room)
    GROUP BY C.id_customer, C.name
    HAVING SUM(R.price) > 500
)
SELECT
    CB.id_customer,
    CB.name,
    CB.total_bookings,
    CB.total_spent,
    CB.unique_hotels
FROM CustomerBookings CB
WHERE CB.id_customer IN (SELECT id_customer FROM HighSpenders);

-- Задача 3
-- Вам необходимо провести анализ данных о бронированиях в отелях 
-- и определить предпочтения клиентов по типу отелей. 
-- Для этого выполните следующие шаги:

-- Категоризация отелей.
-- Определите категорию каждого отеля на основе средней стоимости номера:

-- «Дешевый»: средняя стоимость менее 175 долларов.
-- «Средний»: средняя стоимость от 175 до 300 долларов.
-- «Дорогой»: средняя стоимость более 300 долларов.
-- Анализ предпочтений клиентов.
-- Для каждого клиента определите предпочитаемый тип отеля
-- на основании условия ниже:

-- Если у клиента есть хотя бы один «дорогой» отель, присвойте 
-- ему категорию «дорогой».
-- Если у клиента нет «дорогих» отелей, но есть хотя бы один 
-- «средний», присвойте ему категорию «средний».
-- Если у клиента нет «дорогих» и «средних» отелей, но есть 
-- «дешевые», присвойте ему категорию предпочитаемых отелей «дешевый».
-- Вывод информации.
-- Выведите для каждого клиента следующую информацию:

-- ID_customer: уникальный идентификатор клиента.
-- name: имя клиента.
-- preferred_hotel_type: предпочитаемый тип отеля.
-- visited_hotels: список уникальных отелей, которые посетил клиент.
-- Сортировка результатов.
-- Отсортируйте клиентов так, чтобы сначала шли клиенты с 
-- «дешевыми» отелями, затем со «средними» и в конце — с «дорогими».

WITH HotelCategories AS (
    SELECT
        H.id_hotel,
        H.name as hotel_name,
        CASE
            WHEN AVG(R.price) < 175 THEN 'Дешевый'
            WHEN AVG(R.price) BETWEEN 175 AND 300 THEN 'Средний'
            ELSE 'Дорогой'
        END AS hotel_category
    FROM Hotel H
    JOIN Room R USING (id_hotel)
    GROUP BY H.id_hotel, H.name
),
CustomerHotelPreferences AS (
    SELECT
        C.id_customer,
        C.name,
        MAX(CASE WHEN HC.hotel_category = 'Дорогой' THEN 'Дорогой'
                 WHEN HC.hotel_category = 'Средний' THEN 'Средний'
                 ELSE 'Дешевый' END) AS preferred_hotel_type,
        array_to_string(ARRAY_AGG(DISTINCT HC.hotel_name), ', ') AS visited_hotels
    FROM Customer C
    JOIN Booking B USING (id_customer)
    JOIN Room R USING (id_room)
    JOIN Hotel H USING (id_hotel)
    JOIN HotelCategories HC USING (id_hotel)
    GROUP BY C.id_customer, C.name
)
SELECT
    id_customer,
    name,
    preferred_hotel_type,
    visited_hotels
FROM CustomerHotelPreferences
ORDER BY 
    CASE preferred_hotel_type
        WHEN 'Дешевый' THEN 1
        WHEN 'Средний' THEN 2
        ELSE 3
    END, id_customer;