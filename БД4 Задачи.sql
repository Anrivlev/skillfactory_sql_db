-- Задача 1
-- Найти всех сотрудников, подчиняющихся Ивану Иванову (с EmployeeID = 1), 
-- включая их подчиненных и подчиненных подчиненных. 
-- Для каждого сотрудника вывести следующую информацию:
-- 
-- EmployeeID: идентификатор сотрудника.
-- Имя сотрудника.
-- ManagerID: Идентификатор менеджера.
-- Название отдела, к которому он принадлежит.
-- Название роли, которую он занимает.
-- Название проектов, к которым он относится 
-- (если есть, конкатенированные в одном столбце через запятую).
-- Название задач, назначенных этому сотруднику 
-- (если есть, конкатенированные в одном столбце через запятую).
-- Если у сотрудника нет назначенных проектов или задач, отобразить NULL.
-- Требования:
-- 
-- Рекурсивно извлечь всех подчиненных сотрудников Ивана Иванова 
-- и их подчиненных.
-- Для каждого сотрудника отобразить информацию из всех таблиц.
-- Результаты должны быть отсортированы по имени сотрудника.
-- Решение задачи должно представлять из себя один 
-- sql-запрос и задействовать ключевое слово RECURSIVE.

WITH RECURSIVE IvanSubordinates AS (
    SELECT
        E.EmployeeID,
        E.name,
        E.ManagerID 
    FROM Employees E
    WHERE ManagerID = 1  -- ID Ивана Иванова
    UNION ALL
    SELECT
        E.EmployeeID,
        E.name,
        E.ManagerID
    FROM Employees E
    JOIN IvanSubordinates "IS" ON E.ManagerID = "IS".EmployeeID
)
SELECT
    "IS".EmployeeID AS EmployeeID,
    "IS".name AS employee_name,
    "IS".ManagerID AS ManagerID,
    D.DepartmentName ,
    R.RoleName ,
    STRING_AGG(DISTINCT P.ProjectName , ', ') AS project_names,
    STRING_AGG(DISTINCT T.TaskName , ', ') AS task_names
FROM IvanSubordinates "IS"
JOIN Employees E USING (EmployeeID)
JOIN Departments D USING (DepartmentID )
JOIN Roles R USING (RoleID )
LEFT JOIN Tasks T ON E.EmployeeID = T.assignedto
LEFT JOIN Projects P USING (ProjectID )
GROUP BY "IS".EmployeeID, "IS".name, "IS".ManagerID, D.DepartmentName , R.RoleName 
ORDER BY "IS".name;

-- Задача 2
-- Найти всех сотрудников, подчиняющихся Ивану Иванову с EmployeeID = 1, 
-- включая их подчиненных и подчиненных подчиненных. 
-- Для каждого сотрудника вывести следующую информацию:

-- EmployeeID: идентификатор сотрудника.
-- Имя сотрудника.
-- Идентификатор менеджера.
-- Название отдела, к которому он принадлежит.
-- Название роли, которую он занимает.
-- Название проектов, к которым он относится 
-- (если есть, конкатенированные в одном столбце).
-- Название задач, назначенных этому сотруднику 
-- (если есть, конкатенированные в одном столбце).
-- Общее количество задач, назначенных этому сотруднику.
-- Общее количество подчиненных у каждого сотрудника 
-- (не включая подчиненных их подчиненных).
-- Если у сотрудника нет назначенных проектов или задач, отобразить NULL.

WITH RECURSIVE Subordinates AS (
    SELECT
        E.EmployeeID,
        E.name,
        E.ManagerID,
        E.DepartmentID,
        E.RoleID 
    FROM Employees E
    WHERE E.ManagerID  = 1
    UNION ALL
    SELECT
        E.EmployeeID,
        E.name,
        E.ManagerID,
        E.DepartmentID,
        E.RoleID 
    FROM Employees E
    INNER JOIN Subordinates S ON E.ManagerID  = S.EmployeeID 
)
SELECT
    S.EmployeeID  AS EmployeeID,
    S.name AS employee_name,
    S.ManagerID  AS ManagerID,
    D.DepartmentName  AS DepartmentName,
    R.RoleName  AS RoleName,
    STRING_AGG(DISTINCT P.ProjectName, ', ') AS project_names,
    STRING_AGG(DISTINCT T.TaskName, ', ') AS task_names,
    COUNT(T.TaskID ) AS total_tasks,
    (SELECT COUNT(*) FROM Employees WHERE ManagerID = S.EmployeeID ) AS total_subordinates
FROM Subordinates S
JOIN Departments D USING (DepartmentID)
JOIN Roles R USING (RoleID)
LEFT JOIN Tasks T ON S.EmployeeID  = T.assignedto
LEFT JOIN Projects P USING (ProjectID )
GROUP BY S.EmployeeID, S.name, S.ManagerID, D.DepartmentName, R.RoleName
ORDER BY S.name;

-- Задача 3
-- Найти всех сотрудников, которые занимают роль менеджера и 
-- имеют подчиненных (то есть число подчиненных больше 0). 
-- Для каждого такого сотрудника вывести следующую информацию:

-- EmployeeID: идентификатор сотрудника.
-- Имя сотрудника.
-- Идентификатор менеджера.
-- Название отдела, к которому он принадлежит.
-- Название роли, которую он занимает.
-- Название проектов, к которым он относится 
-- (если есть, конкатенированные в одном столбце).
-- Название задач, назначенных этому сотруднику 
-- (если есть, конкатенированные в одном столбце).
-- Общее количество подчиненных у каждого сотрудника 
-- (включая их подчиненных).
-- Если у сотрудника нет назначенных проектов или задач, отобразить NULL.

WITH RECURSIVE Subordinates AS (
    SELECT
        E.EmployeeID,
        E.name,
        E.ManagerID,
        E.DepartmentID,
        E.RoleID
    FROM Employees E
    WHERE ManagerID IS NULL  --Начальные значения 
    UNION ALL
    SELECT
        E.EmployeeID,
        E.name,
        E.ManagerID,
        E.DepartmentID,
        E.RoleID
    FROM Employees E
    INNER JOIN Subordinates S ON E.ManagerID = S.EmployeeID
), manager_counts AS (
  SELECT
    E.ManagerID,
    COUNT(*) as subordinate_count
  FROM Employees E
  GROUP BY ManagerID
  HAVING COUNT(*) > 0
)
SELECT
    E.EmployeeID AS EmployeeID,
    E.name AS EmployeeName,
    E.ManagerID AS ManagerID,
    D.DepartmentName AS DepartmentName,
    R.RoleName AS RoleName,
    STRING_AGG(DISTINCT P.ProjectName, ', ') AS ProjectNames,
    STRING_AGG(DISTINCT T.TaskName, ', ') AS TaskNames,
    MC.subordinate_count as TotalSubordinates
FROM Employees E
JOIN Roles R USING (RoleID)
JOIN Departments D USING (DepartmentID)
JOIN manager_counts MC ON E.EmployeeID = MC.ManagerID
LEFT JOIN Tasks T ON E.EmployeeID = T.assignedto
LEFT JOIN Projects P USING (ProjectID)
WHERE R.RoleName = 'Менеджер'
GROUP BY E.EmployeeID, E.name, E.ManagerID, D.DepartmentName, R.RoleName, MC.subordinate_count
ORDER BY E.name;