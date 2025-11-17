-- Script de Verificación de Base de Datos MediTrack
-- Ejecutar en H2 Console: http://localhost:8080/h2-console

-- ============================================
-- 1. VERIFICAR QUE LAS TABLAS EXISTEN
-- ============================================

SHOW TABLES;

-- ============================================
-- 2. VERIFICAR ESTRUCTURA DE TABLA USUARIOS
-- ============================================

SHOW COLUMNS FROM usuarios;

-- Debe mostrar:
-- id BIGINT
-- nombre VARCHAR(100)
-- apellido VARCHAR(100)
-- email VARCHAR(150)
-- password VARCHAR(255)
-- rol VARCHAR(50)
-- tipo_usuario VARCHAR(20)  <-- IMPORTANTE!
-- fecha_registro TIMESTAMP
-- activo BOOLEAN

-- ============================================
-- 3. VERIFICAR USUARIOS REGISTRADOS
-- ============================================

SELECT id, nombre, apellido, email, tipo_usuario, fecha_registro, activo
FROM usuarios
ORDER BY fecha_registro DESC;

-- ============================================
-- 4. CONTAR USUARIOS POR TIPO
-- ============================================

SELECT tipo_usuario, COUNT(*) as cantidad
FROM usuarios
GROUP BY tipo_usuario;

-- ============================================
-- 5. VERIFICAR ESTRUCTURA DE TABLA RECETAS
-- ============================================

SHOW COLUMNS FROM recetas;

-- ============================================
-- 6. VERIFICAR ESTRUCTURA DE TABLA CITAS
-- ============================================

SHOW COLUMNS FROM citas;

-- ============================================
-- 7. SI LA TABLA USUARIOS NO TIENE tipo_usuario
--    EJECUTAR ESTE ALTER TABLE:
-- ============================================

-- ⚠️ SOLO SI ES NECESARIO:
-- ALTER TABLE usuarios ADD COLUMN tipo_usuario VARCHAR(20) DEFAULT 'PACIENTE';

-- ============================================
-- 8. LIMPIAR DATOS DE PRUEBA (OPCIONAL)
-- ============================================

-- ⚠️ CUIDADO: Esto borra TODOS los usuarios
-- DELETE FROM recetas;
-- DELETE FROM citas;
-- DELETE FROM usuarios;

-- ============================================
-- 9. INSERTAR USUARIO DE PRUEBA
-- ============================================

-- Email: test@meditrack.com
-- Password: test123 (hasheado con BCrypt)

INSERT INTO usuarios (nombre, apellido, email, password, rol, tipo_usuario, fecha_registro, activo)
VALUES (
    'Test',
    'Usuario',
    'test@meditrack.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'USUARIO',
    'PACIENTE',
    CURRENT_TIMESTAMP,
    TRUE
);

-- Para verificar:
SELECT * FROM usuarios WHERE email = 'test@meditrack.com';

-- ============================================
-- 10. BUSCAR EMAILS DUPLICADOS
-- ============================================

SELECT email, COUNT(*) as cantidad
FROM usuarios
GROUP BY email
HAVING COUNT(*) > 1;

-- Si hay resultados, hay emails duplicados que causan problemas

-- ============================================
-- 11. VER ÚLTIMO USUARIO REGISTRADO
-- ============================================

SELECT * FROM usuarios
ORDER BY id DESC
LIMIT 1;

-- ============================================
-- 12. VERIFICAR ÍNDICES
-- ============================================

SHOW INDEXES FROM usuarios;

-- Debe existir índice en email

-- ============================================
-- 13. ESTADÍSTICAS GENERALES
-- ============================================

SELECT
    (SELECT COUNT(*) FROM usuarios) as total_usuarios,
    (SELECT COUNT(*) FROM usuarios WHERE tipo_usuario = 'MEDICO') as medicos,
    (SELECT COUNT(*) FROM usuarios WHERE tipo_usuario = 'PACIENTE') as pacientes,
    (SELECT COUNT(*) FROM usuarios WHERE tipo_usuario = 'ASISTENTE') as asistentes,
    (SELECT COUNT(*) FROM recetas) as total_recetas,
    (SELECT COUNT(*) FROM citas) as total_citas;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================

-- NOTAS:
-- 1. Si tipo_usuario es NULL en todos los registros,
--    hay un problema con el INSERT
-- 2. Si la columna tipo_usuario no existe,
--    ejecutar el ALTER TABLE del punto 7
-- 3. Password hasheado es para 'test123'

