package com.meditrack.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class DatabaseConnection {
    // H2 Database en modo embedded (archivo local)
    private static final String URL = "jdbc:h2:~/meditrack;AUTO_SERVER=TRUE";
    private static final String USER = "sa";
    private static final String PASSWORD = "";

    static {
        try {
            Class.forName("org.h2.Driver");
            // Crear las tablas al iniciar
            initializeDatabase();
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Error al cargar el driver de H2", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Inicializa la base de datos creando las tablas necesarias
     */
    private static void initializeDatabase() {
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {

            System.out.println("🔧 Inicializando base de datos...");

            // Crear tabla usuarios si no existe
            String createTableSQL = """
                CREATE TABLE IF NOT EXISTS usuarios (
                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                    nombre VARCHAR(100) NOT NULL,
                    apellido VARCHAR(100) NOT NULL,
                    email VARCHAR(150) NOT NULL UNIQUE,
                    password VARCHAR(255) NOT NULL,
                    rol VARCHAR(50) DEFAULT 'USUARIO',
                    tipo_usuario VARCHAR(20) DEFAULT 'PACIENTE',
                    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    activo BOOLEAN DEFAULT TRUE
                )
            """;

            stmt.execute(createTableSQL);
            System.out.println("✅ Tabla usuarios verificada");

            // Verificar si la columna tipo_usuario existe, si no, agregarla
            try {
                String checkColumnSQL = "SELECT tipo_usuario FROM usuarios LIMIT 1";
                stmt.executeQuery(checkColumnSQL);
                System.out.println("✅ Columna tipo_usuario existe");
            } catch (SQLException e) {
                // La columna no existe, agregarla
                System.out.println("⚠️ Columna tipo_usuario no existe, agregándola...");
                String alterTableSQL = "ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS tipo_usuario VARCHAR(20) DEFAULT 'PACIENTE'";
                stmt.execute(alterTableSQL);
                System.out.println("✅ Columna tipo_usuario agregada exitosamente");

                // Actualizar registros existentes sin tipo_usuario
                String updateSQL = "UPDATE usuarios SET tipo_usuario = 'PACIENTE' WHERE tipo_usuario IS NULL";
                int updated = stmt.executeUpdate(updateSQL);
                if (updated > 0) {
                    System.out.println("✅ " + updated + " usuarios actualizados con tipo PACIENTE por defecto");
                }
            }

            // Crear tabla recetas
            String createRecetasSQL = """
                CREATE TABLE IF NOT EXISTS recetas (
                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                    medico_id BIGINT NOT NULL,
                    medico_nombre VARCHAR(200),
                    paciente_id BIGINT NOT NULL,
                    paciente_nombre VARCHAR(200),
                    diagnostico VARCHAR(500),
                    medicamento VARCHAR(300) NOT NULL,
                    dosis VARCHAR(200),
                    indicaciones TEXT,
                    fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    estado VARCHAR(20) DEFAULT 'ACTIVA'
                )
            """;

            stmt.execute(createRecetasSQL);

            // Crear tabla citas
            String createCitasSQL = """
                CREATE TABLE IF NOT EXISTS citas (
                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                    paciente_id BIGINT NOT NULL,
                    paciente_nombre VARCHAR(200),
                    medico_id BIGINT,
                    medico_nombre VARCHAR(200),
                    fecha_cita TIMESTAMP NOT NULL,
                    motivo VARCHAR(500),
                    estado VARCHAR(20) DEFAULT 'PROGRAMADA',
                    notas TEXT,
                    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """;

            stmt.execute(createCitasSQL);

            // Crear índice en email
            String createIndexSQL = """
                CREATE INDEX IF NOT EXISTS idx_email ON usuarios(email)
            """;

            stmt.execute(createIndexSQL);

            // Insertar usuario admin si no existe
            String checkAdminSQL = "SELECT COUNT(*) FROM usuarios WHERE email = 'admin@meditrack.com'";
            var rs = stmt.executeQuery(checkAdminSQL);
            rs.next();

            if (rs.getInt(1) == 0) {
                String insertAdminSQL = """
                    INSERT INTO usuarios (nombre, apellido, email, password, rol, activo) 
                    VALUES ('Admin', 'Sistema', 'admin@meditrack.com', 
                            '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 
                            'ADMIN', TRUE)
                """;
                stmt.execute(insertAdminSQL);
                System.out.println("✅ Base de datos H2 inicializada correctamente");
                System.out.println("✅ Usuario admin creado: admin@meditrack.com / admin123");
            }

        } catch (SQLException e) {
            System.err.println("⚠️ Error al inicializar la base de datos: " + e.getMessage());
        }
    }
}

