-- =====================================================================
-- SCRIPT CORREGIDO: EmpresaSQL
-- Correcciones aplicadas:
--   [C1] Puntos 8-9: FK duplicadas eliminadas del CREATE TABLE (punto 5)
--        y conservadas solo en los ALTER TABLE correspondientes.
--   [C2] Punto 40: INSERT con salario invalido envuelto en TRY/CATCH.
--   [C3] Puntos 81+: Agregado CREATE DATABASE NegocioSQL + USE antes
--        de crear TCliente y TVenta (EmpresaSQL fue eliminada en punto 80).
--   [C4] Punto 90: Creada tabla TDetalleVenta antes de usarla en el JOIN.
--   [A1] Puntos 41-42: Comentario aclaratorio sobre aumento encadenado.
--   [A2] Puntos 83-84: Completadas las 20 inserciones de clientes
--        y 50 inserciones de ventas requeridas.
-- =====================================================================


-- =====================================================================
-- 1. Crear la base de datos EmpresaSQL
-- =====================================================================
CREATE DATABASE EmpresaSQL;
GO

-- 2. Seleccionar la base de datos creada.
USE EmpresaSQL;
GO

-- =====================================================================
-- 3. Crear tabla TDepartamento
-- =====================================================================
CREATE TABLE TDepartamento (
    nDepartamentoID INT IDENTITY(1,1),
    cNombreDepartamento VARCHAR(100) NOT NULL,
    CONSTRAINT PK_TDepartamento PRIMARY KEY (nDepartamentoID),
    CONSTRAINT UQ_cNombreDepartamento UNIQUE (cNombreDepartamento)
);
GO

-- =====================================================================
-- 4. Crear tabla TCargo
-- =====================================================================
CREATE TABLE TCargo (
    nCargoID INT IDENTITY(1,1),
    cNombreCargo VARCHAR(100) NOT NULL,
    CONSTRAINT PK_TCargo PRIMARY KEY (nCargoID),
    CONSTRAINT UQ_cNombreCargo UNIQUE (cNombreCargo)
);
GO

-- =====================================================================
-- 5. Crear tabla TEmpleado
-- [C1] Se eliminaron las FK de este CREATE TABLE para evitar
--      el conflicto con los ALTER TABLE de los puntos 8 y 9,
--      que las definen con el mismo nombre de constraint.
-- =====================================================================
CREATE TABLE TEmpleado (
    nEmpleadoID INT IDENTITY(1,1),
    cNIF        VARCHAR(20)     NULL,
    cNombre     VARCHAR(50)     NOT NULL,
    cApellido   VARCHAR(50)     NOT NULL,
    nDepartamentoID INT         NULL,
    nCargoID    INT             NULL,
    dFechaContratacion DATE     NULL,
    nSalario    DECIMAL(18, 2)  NULL,
    CONSTRAINT PK_TEmpleado PRIMARY KEY (nEmpleadoID),
    CONSTRAINT UQ_cNIF      UNIQUE (cNIF)
    -- Las FK se agregan en los puntos 8 y 9 mediante ALTER TABLE
);
GO

-- =====================================================================
-- Modificaciones a TEmpleado (puntos 6 al 9)
-- =====================================================================

-- 6. CHECK: salario mayor que 300
ALTER TABLE TEmpleado
ADD CONSTRAINT CHK_nSalario_Minimo CHECK (nSalario > 300);
GO

-- 7. DEFAULT: fecha de contratacion = fecha actual
ALTER TABLE TEmpleado
ADD CONSTRAINT DF_dFechaContratacion DEFAULT GETDATE() FOR dFechaContratacion;
GO

-- 8. FK: TEmpleado -> TDepartamento
-- [C1] Ahora es la unica definicion de esta FK (no esta duplicada en el CREATE TABLE)
ALTER TABLE TEmpleado
ADD CONSTRAINT FK_TEmpleado_TDepartamento
    FOREIGN KEY (nDepartamentoID)
    REFERENCES TDepartamento(nDepartamentoID)
    ON DELETE SET NULL;
GO

-- 9. FK: TEmpleado -> TCargo
-- [C1] Idem punto 8
ALTER TABLE TEmpleado
ADD CONSTRAINT FK_TEmpleado_TCargo
    FOREIGN KEY (nCargoID)
    REFERENCES TCargo(nCargoID)
    ON DELETE SET NULL;
GO

-- =====================================================================
-- 10-14. Crear tabla TProyecto
-- =====================================================================
CREATE TABLE TProyecto (
    nProyectoID     INT IDENTITY(1,1),
    cNombreProyecto VARCHAR(150) NOT NULL,
    dFechaInicio    DATE         NOT NULL,
    dFechaFin       DATE         NULL,
    CONSTRAINT PK_TProyecto PRIMARY KEY (nProyectoID)
);
GO

-- =====================================================================
-- 15. Crear tabla intermedia TEmpleadoProyecto (N:M)
-- =====================================================================
CREATE TABLE TEmpleadoProyecto (
    nEmpleadoID     INT  NOT NULL,
    nProyectoID     INT  NOT NULL,
    dFechaAsignacion DATE NULL CONSTRAINT DF_dFechaAsignacion DEFAULT GETDATE(),
    CONSTRAINT PK_TEmpleadoProyecto PRIMARY KEY (nEmpleadoID, nProyectoID),
    CONSTRAINT FK_TEmpleadoProyecto_TEmpleado
        FOREIGN KEY (nEmpleadoID) REFERENCES TEmpleado(nEmpleadoID) ON DELETE CASCADE,
    CONSTRAINT FK_TEmpleadoProyecto_TProyecto
        FOREIGN KEY (nProyectoID) REFERENCES TProyecto(nProyectoID) ON DELETE CASCADE
);
GO

-- =====================================================================
-- 16-17. Agregar cEmail y cTelefono
-- =====================================================================
ALTER TABLE TEmpleado
ADD cEmail    VARCHAR(150) NULL,
    cTelefono VARCHAR(15)  NULL;
GO

-- 18-19. Ampliar cNombre y cApellido a 100 caracteres
ALTER TABLE TEmpleado
ALTER COLUMN cNombre   VARCHAR(100) NOT NULL;

ALTER TABLE TEmpleado
ALTER COLUMN cApellido VARCHAR(100) NOT NULL;
GO

-- 20-21. Agregar cDireccion y nEdad
ALTER TABLE TEmpleado
ADD cDireccion VARCHAR(250) NULL,
    nEdad      INT          NULL;
GO

-- 22. CHECK: edad entre 18 y 65
ALTER TABLE TEmpleado
ADD CONSTRAINT CHK_nEdad_Rango CHECK (nEdad >= 18 AND nEdad <= 65);
GO

-- 23. UNIQUE en correo electronico
ALTER TABLE TEmpleado
ADD CONSTRAINT UQ_cEmail UNIQUE (cEmail);
GO

-- 24. Columna bActivo BIT con DEFAULT 1
ALTER TABLE TEmpleado
ADD bActivo BIT NOT NULL CONSTRAINT DF_bActivo DEFAULT 1;
GO

-- 25. Eliminar columna cDireccion
ALTER TABLE TEmpleado
DROP COLUMN cDireccion;
GO

-- 26. Ampliar cTelefono a VARCHAR(20)
ALTER TABLE TEmpleado
ALTER COLUMN cTelefono VARCHAR(20) NULL;
GO

-- 27. Agregar columna cGenero
ALTER TABLE TEmpleado
ADD cGenero CHAR(1) NULL;
GO

-- 28. CHECK: genero solo M o F
ALTER TABLE TEmpleado
ADD CONSTRAINT CHK_cGenero_Valores CHECK (cGenero IN ('M', 'F'));
GO

-- 29. Agregar dFechaNacimiento
ALTER TABLE TEmpleado
ADD dFechaNacimiento DATE NULL;
GO

-- =====================================================================
-- 30. Crear tabla TSucursal
-- =====================================================================
CREATE TABLE TSucursal (
    nSucursalID     INT IDENTITY(1,1),
    cNombreSucursal VARCHAR(100) NOT NULL,
    cCiudad         VARCHAR(100) NOT NULL,
    CONSTRAINT PK_TSucursal    PRIMARY KEY (nSucursalID),
    CONSTRAINT UQ_cNombreSucursal UNIQUE (cNombreSucursal)
);
GO

-- =====================================================================
-- 31. Insertar 5 departamentos
-- =====================================================================
INSERT INTO TDepartamento (cNombreDepartamento) VALUES
('Recursos Humanos'), ('Desarrollo'), ('Marketing'), ('Ventas'), ('Finanzas');
GO

-- 32. Insertar 5 cargos
INSERT INTO TCargo (cNombreCargo) VALUES
('Gerente'), ('Desarrollador'), ('Analista'), ('Disenador'), ('Soporte');
GO

-- 33. Insertar 10 empleados
INSERT INTO TEmpleado (cNIF, cNombre, cApellido, nDepartamentoID, nCargoID, nSalario, nEdad, cGenero) VALUES
('111A', 'Ana',    'Garcia', 1, 1, 2500, 30, 'F'),
('222B', 'Luis',   'Perez',  2, 2, 2200, 28, 'M'),
('333C', 'Maria',  'Lopez',  3, 3, 1800, 35, 'F'),
('444D', 'Juan',   'Diaz',   2, 2, 2200, 25, 'M'),
('555E', 'Sofia',  'Ruiz',   3, 4, 1900, 29, 'F'),
('666F', 'Carlos', 'Mora',   4, 5, 1500, 40, 'M'),
('777G', 'Elena',  'Gil',    5, 1, 3000, 45, 'F'),
('888H', 'Pedro',  'Sanz',   2, 3, 1700, 32, 'M'),
('999I', 'Lucia',  'Vega',   2, 2, 2100, 27, 'F'),
('000J', 'Diego',  'Rios',   4, 5, 1600, 31, 'M');
GO

-- 34. Insertar 3 proyectos
INSERT INTO TProyecto (cNombreProyecto, dFechaInicio) VALUES
('Migracion Nube', '2026-01-01'),
('App Movil',      '2026-02-01'),
('Rediseno Web',   '2026-03-01');
GO

-- 35. Asignar empleados a proyectos
INSERT INTO TEmpleadoProyecto (nEmpleadoID, nProyectoID) VALUES
(1, 1), (2, 2), (3, 3), (4, 1), (5, 2);
GO

-- 36. Insertar empleado usando valor por defecto de fecha
INSERT INTO TEmpleado (cNIF, cNombre, cApellido, nSalario)
VALUES ('123X', 'Laura', 'Mendieta', 2000);
GO

-- 37. Insertar empleado con correo electronico
INSERT INTO TEmpleado (cNIF, cNombre, cApellido, cEmail, nSalario)
VALUES ('456Y', 'Jorge', 'Sola', 'jorge@empresa.com', 2200);
GO

-- 38. Insertar empleado sin indicar bActivo (usara DEFAULT = 1)
INSERT INTO TEmpleado (cNIF, cNombre, cApellido, nSalario)
VALUES ('789Z', 'Clara', 'Sol', 2100);
GO

-- 39. Insertar multiples cargos en una sola sentencia
INSERT INTO TCargo (cNombreCargo) VALUES
('Becario'), ('Consultor'), ('Auditor');
GO

-- =====================================================================
-- 40. Intentar insertar salario invalido y capturar el error
-- [C2] Envuelto en TRY/CATCH para no interrumpir la ejecucion del lote.
--      El INSERT viola CHK_nSalario_Minimo (nSalario > 300).
-- =====================================================================
BEGIN TRY
    INSERT INTO TEmpleado (cNIF, cNombre, cApellido, nSalario)
    VALUES ('999X', 'Error', 'Prueba', -500);
END TRY
BEGIN CATCH
    PRINT 'Error esperado en punto 40: ' + ERROR_MESSAGE();
    -- Resultado: The INSERT statement conflicted with the CHECK constraint "CHK_nSalario_Minimo"
END CATCH;
GO

-- =====================================================================
-- 41. Incrementar 10% el salario de todos los empleados
-- [A1] NOTA: este UPDATE afecta a todos los empleados, incluidos los del
--      departamento 1. El punto 42 aplicara un 20% adicional sobre el
--      salario ya actualizado, resultando en un aumento total de 32%
--      para el departamento 1 (1.10 x 1.20 = 1.32).
--      Si se desea exactamente 10% general y 20% solo al depto 1,
--      invierta el orden o use WHERE nDepartamentoID <> 1 en este paso.
-- =====================================================================
UPDATE TEmpleado SET nSalario = nSalario * 1.10;
GO

-- 42. Incrementar 20% adicional al departamento 1
UPDATE TEmpleado SET nSalario = nSalario * 1.20 WHERE nDepartamentoID = 1;
GO

-- 43. Actualizar correo de un empleado
UPDATE TEmpleado SET cEmail = 'nuevo.email@empresa.com' WHERE nEmpleadoID = 1;
GO

-- 44. Modificar cargo de un empleado
UPDATE TEmpleado SET nCargoID = 2 WHERE nEmpleadoID = 1;
GO

-- 45. Cambiar departamento de dos empleados
UPDATE TEmpleado SET nDepartamentoID = 3 WHERE nEmpleadoID IN (2, 3);
GO

-- 46. Marcar como inactivos los empleados con salario < 500
UPDATE TEmpleado SET bActivo = 0 WHERE nSalario < 500;
GO

-- 47. Actualizar fecha de fin de un proyecto
UPDATE TProyecto SET dFechaFin = '2026-12-31' WHERE nProyectoID = 1;
GO

-- 48. Asignar empleado 1 al proyecto 3
-- Nota: al eliminar el empleado 1 en el punto 49, el ON DELETE CASCADE
-- de TEmpleadoProyecto eliminara esta asignacion automaticamente.
INSERT INTO TEmpleadoProyecto (nEmpleadoID, nProyectoID) VALUES (1, 3);
GO

-- =====================================================================
-- 49. Eliminar empleado por NIF
-- =====================================================================
DELETE FROM TEmpleado WHERE cNIF = '111A';
GO

-- 50. Eliminar empleados inactivos
DELETE FROM TEmpleado WHERE bActivo = 0;
GO

-- 51. Eliminar proyecto
DELETE FROM TProyecto WHERE nProyectoID = 3;
GO

-- 52. Eliminar asignaciones de un empleado
DELETE FROM TEmpleadoProyecto WHERE nEmpleadoID = 1;
GO

-- 53. Eliminar departamentos sin empleados asignados
DELETE FROM TDepartamento
WHERE nDepartamentoID NOT IN (
    SELECT DISTINCT nDepartamentoID
    FROM TEmpleado
    WHERE nDepartamentoID IS NOT NULL
);
GO

-- =====================================================================
-- Consultas SELECT (puntos 54-70)
-- =====================================================================

-- 54. Todos los empleados ordenados por apellido
SELECT * FROM TEmpleado ORDER BY cApellido;

-- 55. Empleados con salario mayor a 1000
SELECT * FROM TEmpleado WHERE nSalario > 1000;

-- 56. Empleados activos
SELECT * FROM TEmpleado WHERE bActivo = 1;

-- 57. Empleados contratados en el anio actual
SELECT * FROM TEmpleado WHERE YEAR(dFechaContratacion) = 2026;

-- 58. Empleados con su departamento
SELECT E.cNombre, D.cNombreDepartamento
FROM TEmpleado E
JOIN TDepartamento D ON E.nDepartamentoID = D.nDepartamentoID;

-- 59. Empleados con su cargo
SELECT E.cNombre, C.cNombreCargo
FROM TEmpleado E
JOIN TCargo C ON E.nCargoID = C.nCargoID;

-- 60. Empleados asignados a al menos un proyecto
SELECT DISTINCT E.cNombre
FROM TEmpleado E
JOIN TEmpleadoProyecto EP ON E.nEmpleadoID = EP.nEmpleadoID;

-- 61. Cantidad de empleados por departamento
SELECT nDepartamentoID, COUNT(*) AS Total
FROM TEmpleado
GROUP BY nDepartamentoID;

-- 62. Promedio de salario por departamento
SELECT nDepartamentoID, AVG(nSalario) AS Promedio
FROM TEmpleado
GROUP BY nDepartamentoID;

-- 63. Salario maximo y minimo por departamento
SELECT nDepartamentoID, MAX(nSalario) AS Maximo, MIN(nSalario) AS Minimo
FROM TEmpleado
GROUP BY nDepartamentoID;

-- 64. Proyectos con mas de 2 empleados asignados
SELECT nProyectoID, COUNT(nEmpleadoID) AS TotalEmpleados
FROM TEmpleadoProyecto
GROUP BY nProyectoID
HAVING COUNT(nEmpleadoID) > 2;

-- 65. Empleados cuyo apellido empieza con G
SELECT * FROM TEmpleado WHERE cApellido LIKE 'G%';

-- 66. Empleados ordenados por salario descendente
SELECT * FROM TEmpleado ORDER BY nSalario DESC;

-- 67. Top 3 empleados con mayor salario
SELECT TOP 3 * FROM TEmpleado ORDER BY nSalario DESC;

-- 68. Empleados con edad entre 25 y 40 anios
SELECT * FROM TEmpleado WHERE nEdad BETWEEN 25 AND 40;

-- 69. Total de empleados activos
SELECT COUNT(*) AS TotalActivos FROM TEmpleado WHERE bActivo = 1;

-- 70. Total de proyectos registrados
SELECT COUNT(*) AS TotalProyectos FROM TProyecto;

-- =====================================================================
-- 71-73. Gestion de restricciones CHECK y UNIQUE
-- =====================================================================

-- 71. Eliminar CHECK de edad
ALTER TABLE TEmpleado DROP CONSTRAINT CHK_nEdad_Rango;
GO

-- 72. Eliminar UNIQUE de email
ALTER TABLE TEmpleado DROP CONSTRAINT UQ_cEmail;
GO

-- 73. Re-agregar ambas restricciones
ALTER TABLE TEmpleado ADD CONSTRAINT CHK_nEdad_Rango CHECK (nEdad >= 18 AND nEdad <= 65);
ALTER TABLE TEmpleado ADD CONSTRAINT UQ_cEmail UNIQUE (cEmail);
GO

-- =====================================================================
-- 74-79. Eliminar tablas en orden correcto (respetando FK)
-- =====================================================================
DROP TABLE TEmpleadoProyecto;  -- primero: tiene FK a TEmpleado y TProyecto
DROP TABLE TProyecto;
DROP TABLE TEmpleado;          -- despues: ya no tiene dependientes
DROP TABLE TCargo;
DROP TABLE TDepartamento;
DROP TABLE TSucursal;
GO

-- =====================================================================
-- 80. Eliminar la base de datos
-- =====================================================================
USE master;
GO
DROP DATABASE EmpresaSQL;
GO

-- =====================================================================
-- [C3] Crear nueva base de datos para el modulo de clientes y ventas.
--      EmpresaSQL fue eliminada en el punto 80; se necesita un nuevo
--      contexto antes de crear TCliente y TVenta.
-- =====================================================================
CREATE DATABASE NegocioSQL;
GO
USE NegocioSQL;
GO

-- =====================================================================
-- 81. Crear tabla TCliente
-- =====================================================================
CREATE TABLE TCliente (
    nClienteID    INT IDENTITY(1,1) PRIMARY KEY,
    cNombre       VARCHAR(100) NOT NULL,
    cApellido     VARCHAR(100) NOT NULL,
    cEmail        VARCHAR(150) UNIQUE,
    cTelefono     VARCHAR(20),
    cDireccion    VARCHAR(250),
    dFechaRegistro DATE DEFAULT GETDATE(),
    bActivo       BIT  DEFAULT 1,
    CONSTRAINT CHK_Email CHECK (cEmail LIKE '%@%.%')
);
GO

-- =====================================================================
-- 82. Crear tabla TVenta
-- =====================================================================
CREATE TABLE TVenta (
    nVentaID      INT IDENTITY(1,1) PRIMARY KEY,
    nClienteID    INT,
    dFechaVenta   DATE           DEFAULT GETDATE(),
    nTotal        DECIMAL(18, 2) NOT NULL,
    cMetodoPago   VARCHAR(50),
    CONSTRAINT FK_Venta_Cliente FOREIGN KEY (nClienteID)
        REFERENCES TCliente(nClienteID)
);
GO

-- =====================================================================
-- [C4] Crear tabla TDetalleVenta antes de usarla en el JOIN del punto 90
-- =====================================================================
CREATE TABLE TDetalleVenta (
    nDetalleID    INT IDENTITY(1,1) PRIMARY KEY,
    nVentaID      INT            NOT NULL,
    cProducto     VARCHAR(150)   NOT NULL,
    nCantidad     INT            NOT NULL DEFAULT 1,
    nPrecioUnitario DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_Detalle_Venta FOREIGN KEY (nVentaID)
        REFERENCES TVenta(nVentaID) ON DELETE CASCADE
);
GO

-- =====================================================================
-- 83. Insertar 20 clientes
-- [A2] Completadas las 20 inserciones requeridas por el enunciado
-- =====================================================================
INSERT INTO TCliente (cNombre, cApellido, cEmail, cTelefono, cDireccion) VALUES
('Juan',      'Perez',     'j.perez@email.com',      '5551001', 'Calle 1 #10'),
('Ana',       'Gomez',     'a.gomez@email.com',       '5551002', 'Av. 2 #20'),
('Carlos',    'Lopez',     'c.lopez@email.com',       '5551003', 'Blvd. 3 #30'),
('Maria',     'Torres',    'm.torres@email.com',      '5551004', 'Calle 4 #40'),
('Luis',      'Ramirez',   'l.ramirez@email.com',     '5551005', 'Av. 5 #50'),
('Sofia',     'Herrera',   's.herrera@email.com',     '5551006', 'Calle 6 #60'),
('Pedro',     'Diaz',      'p.diaz@email.com',        '5551007', 'Blvd. 7 #70'),
('Elena',     'Morales',   'e.morales@email.com',     '5551008', 'Av. 8 #80'),
('Diego',     'Jimenez',   'd.jimenez@email.com',     '5551009', 'Calle 9 #90'),
('Laura',     'Mendez',    'l.mendez@email.com',      '5551010', 'Blvd. 10 #100'),
('Roberto',   'Castillo',  'r.castillo@email.com',    '5551011', 'Calle 11 #110'),
('Patricia',  'Vargas',    'p.vargas@email.com',      '5551012', 'Av. 12 #120'),
('Miguel',    'Reyes',     'm.reyes@email.com',       '5551013', 'Calle 13 #130'),
('Carmen',    'Flores',    'c.flores@email.com',      '5551014', 'Blvd. 14 #140'),
('Fernando',  'Romero',    'f.romero@email.com',      '5551015', 'Av. 15 #150'),
('Lucia',     'Vega',      'l.vega@email.com',        '5551016', 'Calle 16 #160'),
('Jorge',     'Cruz',      'j.cruz@email.com',        '5551017', 'Blvd. 17 #170'),
('Adriana',   'Ortega',    'a.ortega@email.com',      '5551018', 'Av. 18 #180'),
('Ricardo',   'Navarro',   'r.navarro@email.com',     '5551019', 'Calle 19 #190'),
('Valentina', 'Rojas',     'v.rojas@email.com',       '5551020', 'Blvd. 20 #200');
GO

-- =====================================================================
-- 84. Registrar 50 ventas
-- [A2] Completadas las 50 inserciones requeridas por el enunciado
-- =====================================================================
INSERT INTO TVenta (nClienteID, dFechaVenta, nTotal, cMetodoPago) VALUES
( 1, '2026-01-05', 150.50, 'Tarjeta'),
( 2, '2026-01-08', 220.00, 'Efectivo'),
( 3, '2026-01-12', 310.75, 'Tarjeta'),
( 4, '2026-01-15', 180.00, 'Transferencia'),
( 5, '2026-01-20', 95.25,  'Efectivo'),
( 6, '2026-01-22', 430.00, 'Tarjeta'),
( 7, '2026-02-01', 275.50, 'Efectivo'),
( 8, '2026-02-03', 120.00, 'Tarjeta'),
( 9, '2026-02-07', 550.00, 'Transferencia'),
(10, '2026-02-10', 200.75, 'Tarjeta'),
(11, '2026-02-14', 340.00, 'Efectivo'),
(12, '2026-02-18', 89.99,  'Tarjeta'),
(13, '2026-02-21', 410.50, 'Efectivo'),
(14, '2026-02-25', 175.00, 'Transferencia'),
(15, '2026-03-01', 260.00, 'Tarjeta'),
(16, '2026-03-04', 130.25, 'Efectivo'),
(17, '2026-03-07', 480.00, 'Tarjeta'),
(18, '2026-03-10', 315.75, 'Transferencia'),
(19, '2026-03-13', 225.00, 'Efectivo'),
(20, '2026-03-16', 390.50, 'Tarjeta'),
( 1, '2026-03-19', 145.00, 'Efectivo'),
( 2, '2026-03-22', 280.00, 'Tarjeta'),
( 3, '2026-03-25', 195.50, 'Transferencia'),
( 4, '2026-03-28', 460.00, 'Tarjeta'),
( 5, '2026-04-01', 320.25, 'Efectivo'),
( 6, '2026-04-04', 115.00, 'Tarjeta'),
( 7, '2026-04-07', 510.75, 'Efectivo'),
( 8, '2026-04-10', 230.00, 'Transferencia'),
( 9, '2026-04-13', 175.50, 'Tarjeta'),
(10, '2026-04-16', 395.00, 'Efectivo'),
(11, '2026-04-19', 445.25, 'Tarjeta'),
(12, '2026-04-22', 160.00, 'Efectivo'),
(13, '2026-04-25', 285.75, 'Transferencia'),
(14, '2026-04-28', 220.50, 'Tarjeta'),
(15, '2026-05-01', 530.00, 'Efectivo'),
(16, '2026-05-04', 305.00, 'Tarjeta'),
(17, '2026-05-07', 140.25, 'Efectivo'),
(18, '2026-05-10', 475.00, 'Transferencia'),
(19, '2026-05-13', 190.50, 'Tarjeta'),
(20, '2026-05-16', 360.75, 'Efectivo'),
( 1, '2026-05-19', 245.00, 'Tarjeta'),
( 3, '2026-05-22', 415.00, 'Efectivo'),
( 5, '2026-05-25', 155.50, 'Transferencia'),
( 7, '2026-05-28', 500.25, 'Tarjeta'),
( 9, '2026-06-01', 270.00, 'Efectivo'),
(11, '2026-06-04', 330.75, 'Tarjeta'),
(13, '2026-06-07', 185.00, 'Efectivo'),
(15, '2026-06-08', 440.50, 'Transferencia'),
(17, '2026-06-09', 210.25, 'Tarjeta'),
(19, '2026-06-10', 375.00, 'Efectivo');
GO

-- Insertar algunos detalles de venta para que el JOIN del punto 90 retorne datos
INSERT INTO TDetalleVenta (nVentaID, cProducto, nCantidad, nPrecioUnitario) VALUES
(1, 'Laptop',    1, 150.50),
(2, 'Mouse',     2,  55.00),
(3, 'Teclado',   1, 310.75),
(4, 'Monitor',   1, 180.00),
(5, 'Auriculares', 1, 95.25);
GO

-- =====================================================================
-- 85. Aplicar 10% de descuento a ventas pagadas en Efectivo
-- =====================================================================
UPDATE TVenta SET nTotal = nTotal * 0.90 WHERE cMetodoPago = 'Efectivo';
GO

-- 86. Eliminar clientes sin ninguna venta registrada
DELETE FROM TCliente
WHERE nClienteID NOT IN (SELECT DISTINCT nClienteID FROM TVenta);
GO

-- 87. Top 5 clientes con mayores compras totales
SELECT TOP 5
    C.cNombre,
    C.cApellido,
    SUM(V.nTotal) AS TotalComprado
FROM TCliente C
JOIN TVenta V ON C.nClienteID = V.nClienteID
GROUP BY C.cNombre, C.cApellido
ORDER BY TotalComprado DESC;

-- 88. Ventas totales agrupadas por mes
SELECT
    MONTH(dFechaVenta) AS Mes,
    SUM(nTotal)        AS VentasTotales
FROM TVenta
GROUP BY MONTH(dFechaVenta)
ORDER BY Mes;

-- 89. Promedio de ventas por cliente
SELECT
    nClienteID,
    AVG(nTotal) AS PromedioVenta
FROM TVenta
GROUP BY nClienteID;

-- =====================================================================
-- 90. Reporte consolidado: Cliente + Venta + Detalle
-- [C4] TDetalleVenta ya fue creada antes (ver arriba), el JOIN es valido.
-- =====================================================================
SELECT
    C.cNombre,
    C.cApellido,
    V.nVentaID,
    V.nTotal,
    V.dFechaVenta,
    DV.cProducto,
    DV.nCantidad,
    DV.nPrecioUnitario
FROM TCliente C
INNER JOIN TVenta        V  ON C.nClienteID = V.nClienteID
INNER JOIN TDetalleVenta DV ON V.nVentaID   = DV.nVentaID;
GO