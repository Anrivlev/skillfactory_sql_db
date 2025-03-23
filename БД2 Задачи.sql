-- Задача 1
-- Определить, какие автомобили из каждого класса имеют наименьшую 
-- среднюю позицию в гонках, и вывести информацию о каждом 
-- таком автомобиле для данного класса, включая его класс, 
-- среднюю позицию и количество гонок, в которых он участвовал. 
-- Также отсортировать результаты по средней позиции.

drop view if exists average_positions cascade;
create view average_positions as (
	select 
		r.car as name,
		c.class as class,
		sum(r.position)/count(*) as average_position, 
		count(*) as race_count
	from cars as c
	join results as r on r.car = c.name  
	group by c.class, r.car 
);

drop view if exists minimum_average_positions cascade;
create view minimum_average_positions as (
	select 
		class, 
		min(average_position) as minimum_average_position
	from average_positions
	group by class
);

select a.name as car_name, 
	a.class as car_class, 
	a.average_position, 
	a.race_count
from average_positions as a
join minimum_average_positions as m on m.class = a.class
where a.average_position = m.minimum_average_position
order by a.average_position asc;

-- Задача 2
-- Определить автомобиль, который имеет наименьшую 
-- среднюю позицию в гонках среди всех автомобилей, 
-- и вывести информацию об этом автомобиле, включая его 
-- класс, среднюю позицию, количество гонок, в которых он участвовал, 
-- и страну производства класса автомобиля. Если несколько автомобилей 
-- имеют одинаковую наименьшую среднюю позицию, выбрать один из них по 
-- алфавиту (по имени автомобиля).

select a.name as car_name, 
	a.class as car_class, 
	a.average_position, 
	a.race_count,
	c.country
from average_positions as a
join classes as c on c.class = a.class
where a.average_position = (
	select min(minimum_average_position)
	from minimum_average_positions
)
order by a.name asc
limit 1;

-- Задача 3
-- Определить классы автомобилей, которые имеют наименьшую среднюю позицию 
-- в гонках, и вывести информацию о каждом автомобиле из этих классов, 
-- включая его имя, среднюю позицию, количество гонок, в которых он участвовал, 
-- страну производства класса автомобиля, а также общее количество гонок, 
-- в которых участвовали автомобили этих классов. Если несколько классов 
-- имеют одинаковую среднюю позицию, выбрать все из них.

drop view if exists total_races cascade;
create view total_races as (
	select 
		c.class as class,
		sum(r.position)/count(*) as average_position, 
		count(*) as total_race_count
	from cars as c
	join results as r on r.car = c.name  
	group by c.class
);

select a.name as car_name, 
	a.class as car_class, 
	a.average_position, 
	a.race_count,
	c.country,
	t.total_race_count as total_races
from average_positions as a
join classes as c on c.class = a.class
join total_races as t on c.class = t.class
where a.average_position = (
	select min(minimum_average_position)
	from minimum_average_positions
);

-- Задача 4
-- Определить, какие автомобили имеют среднюю позицию лучше 
-- (меньше) средней позиции всех автомобилей в своем классе 
-- (то есть автомобилей в классе должно быть минимум два, чтобы выбрать один из них). 
-- Вывести информацию об этих автомобилях, включая их имя, класс, среднюю позицию, 
-- количество гонок, в которых они участвовали, и страну производства класса 
-- автомобиля. Также отсортировать результаты по классу и затем по средней 
-- позиции в порядке возрастания.

drop view if exists average_positions_by_class cascade;
create view average_positions_by_class as (
	select 
		c.class as class,
		cast( sum(r.position) as float)/count(*) as average_position, 
		count(*) as race_count
	from cars as c
	join results as r on r.car = c.name  
	group by c.class 
);

select c.name as car_name,
	c.class as car_class,
	a.average_position as average_position,
	a.race_count as race_count,
	cl.country as car_country
from cars as c
join average_positions as a on c.name = a.name
join average_positions_by_class as acl on c.class = acl.class
join classes as cl on c.class = cl.class
where a.average_position < acl.average_position
order by c.class asc, a.average_position asc;

-- Задача 5
-- Определить, какие классы автомобилей имеют наибольшее количество 
-- автомобилей с низкой средней позицией (больше 3.0) и вывести информацию 
-- о каждом автомобиле из этих классов, включая его имя, класс, среднюю позицию, 
-- количество гонок, в которых он участвовал, страну производства класса автомобиля, 
-- а также общее количество гонок для каждого класса. Отсортировать результаты по 
-- количеству автомобилей с низкой средней позицией.

drop view if exists low_positions cascade;
create view low_positions as (
	select 
		c.class as car_class,
		count(*) as low_position_count
	from cars as c
	join results as r on r.car = c.name
	where r.position >= 3.0
	group by c.class
);

select c.name as car_name,
	c.class as car_class,
	a.average_position as average_position,
	a.race_count as race_count,
	cl.country as car_country,
	acl.race_count as total_races,
	lp.low_position_count as low_position_count
from cars as c
join average_positions as a on c.name = a.name
join average_positions_by_class as acl on c.class = acl.class
join classes as cl on c.class = cl.class
join low_positions as lp on lp.car_class = c.class
where a.average_position > 3.0
order by lp.low_position_count desc;