-- Задача 1
-- Найдите производителей (maker) и модели всех мотоциклов, 
-- которые имеют мощность более 150 лошадиных сил, 
-- стоят менее 20 тысяч долларов и являются спортивными (тип Sport). 
-- Также отсортируйте результаты по мощности в порядке убывания.

select v.maker, v.model
from Vehicle as v
join Motorcycle as m on m.model = v.model
where horsepower > 150 and
price < 20000 and
m.type = 'Sport'
order by horsepower desc;

-- Задача 2
-- Найти информацию о производителях и моделях различных типов 
-- транспортных средств (автомобили, мотоциклы и велосипеды), 
-- которые соответствуют заданным критериям.

-- 1. Автомобили:
-- Извлечь данные о всех автомобилях, которые имеют:
-- Мощность двигателя более 150 лошадиных сил.
-- Объем двигателя менее 3 литров.
-- Цену менее 35 тысяч долларов.
-- В выводе должны быть указаны производитель (maker), 
-- номер модели (model), мощность (horsepower), 
-- объем двигателя (engine_capacity) и тип транспортного средства, 
-- который будет обозначен как Car.

select v.maker, v.model, c.horsepower, c.engine_capacity, v.type
from Car as c
join Vehicle as v on c.model = v.model
where c.horsepower > 150 and
c.engine_capacity < 3 and
c.price < 35000;

-- 2. Мотоциклы:
-- Извлечь данные о всех мотоциклах, которые имеют:
-- Мощность двигателя более 150 лошадиных сил.
-- Объем двигателя менее 1,5 литров.
-- Цену менее 20 тысяч долларов.
-- В выводе должны быть указаны производитель (maker), 
-- номер модели (model), мощность (horsepower), 
-- объем двигателя (engine_capacity) и тип транспортного средства, 
-- который будет обозначен как Motorcycle.

select v.maker, v.model, m.horsepower, m.engine_capacity, v.type
from Motorcycle as m
join vehicle as v on m.model = v.model
where m.horsepower > 150 and
m.engine_capacity < 1.5 and
m.price < 20000;

-- 3. Велосипеды:
-- Извлечь данные обо всех велосипедах, которые имеют:
-- Количество передач больше 18.
-- Цену менее 4 тысяч долларов.
-- В выводе должны быть указаны производитель (maker), 
-- номер модели (model), а также NULL для мощности 
-- и объема двигателя, так как эти характеристики 
-- не применимы для велосипедов. Тип транспортного средства 
-- будет обозначен как Bicycle.

select v.maker, v.model, null as horsepower, null as engine_capacity, v.type
from Bicycle as b
join Vehicle as v on b.model = v.model
where b.gear_count > 18 and
b.price < 4000;

-- 4. Сортировка:
-- Результаты должны быть объединены в один набор данных 
-- и отсортированы по мощности в порядке убывания. 
-- Для велосипедов, у которых нет значения мощности, 
-- они будут располагаться внизу списка.

select v.maker, v.model, c.horsepower, c.engine_capacity, v.type
from Car as c
join Vehicle as v on c.model = v.model
where c.horsepower > 150 and
c.engine_capacity < 3 and
c.price < 35000

union 
select v.maker, v.model, m.horsepower, m.engine_capacity, v.type
from Motorcycle as m
join vehicle as v on m.model = v.model
where m.horsepower > 150 and
m.engine_capacity < 1.5 and
m.price < 20000

union
select v.maker, v.model, null as horsepower, null as engine_capacity, v.type
from Bicycle as b
join Vehicle as v on b.model = v.model
where b.gear_count > 18 and
b.price < 4000
order by horsepower desc nulls last