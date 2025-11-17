package com.meditrack.dao;

import com.meditrack.model.Usuario;
import com.meditrack.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    // Crear un nuevo usuario
    public boolean createUser(Usuario usuario) {
        String sql = "INSERT INTO usuarios (nombre, apellido, email, password, rol, tipo_usuario, fecha_registro, activo) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        System.out.println("=== UserDAO.createUser ===");
        System.out.println("Nombre: " + usuario.getNombre());
        System.out.println("Apellido: " + usuario.getApellido());
        System.out.println("Email: " + usuario.getEmail());
        System.out.println("Tipo Usuario: " + usuario.getTipoUsuario());
        System.out.println("Rol: " + usuario.getRol());

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, usuario.getNombre());
            stmt.setString(2, usuario.getApellido());
            stmt.setString(3, usuario.getEmail());
            stmt.setString(4, usuario.getPassword());
            stmt.setString(5, usuario.getRol());
            stmt.setString(6, usuario.getTipoUsuario());
            stmt.setTimestamp(7, Timestamp.valueOf(usuario.getFechaRegistro()));
            stmt.setBoolean(8, usuario.isActivo());

            System.out.println("Ejecutando INSERT...");
            int rowsAffected = stmt.executeUpdate();
            System.out.println("Filas afectadas: " + rowsAffected);

            if (rowsAffected > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    usuario.setId(rs.getLong(1));
                    System.out.println("✅ Usuario creado con ID: " + usuario.getId());
                }
                return true;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error SQL en createUser: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println("========================");
        return false;
    }

    // Buscar usuario por email
    public Usuario findByEmail(String email) {
        String sql = "SELECT * FROM usuarios WHERE email = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToUsuario(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Buscar usuario por ID
    public Usuario findById(Long id) {
        String sql = "SELECT * FROM usuarios WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToUsuario(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Actualizar usuario
    public boolean updateUser(Usuario usuario) {
        String sql = "UPDATE usuarios SET nombre = ?, apellido = ?, email = ?, rol = ?, activo = ? WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, usuario.getNombre());
            stmt.setString(2, usuario.getApellido());
            stmt.setString(3, usuario.getEmail());
            stmt.setString(4, usuario.getRol());
            stmt.setBoolean(5, usuario.isActivo());
            stmt.setLong(6, usuario.getId());

            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Eliminar usuario
    public boolean deleteUser(Long id) {
        String sql = "DELETE FROM usuarios WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Listar todos los usuarios
    public List<Usuario> findAll() {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = "SELECT * FROM usuarios ORDER BY fecha_registro DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                usuarios.add(mapResultSetToUsuario(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usuarios;
    }

    // Verificar si existe un email
    public boolean emailExists(String email) {
        return findByEmail(email) != null;
    }

    // Mapear ResultSet a objeto Usuario
    private Usuario mapResultSetToUsuario(ResultSet rs) throws SQLException {
        Usuario usuario = new Usuario();
        usuario.setId(rs.getLong("id"));
        usuario.setNombre(rs.getString("nombre"));
        usuario.setApellido(rs.getString("apellido"));
        usuario.setEmail(rs.getString("email"));
        usuario.setPassword(rs.getString("password"));
        usuario.setRol(rs.getString("rol"));

        // Manejar tipo_usuario con valor por defecto si es NULL o no existe
        try {
            String tipoUsuario = rs.getString("tipo_usuario");
            usuario.setTipoUsuario(tipoUsuario != null ? tipoUsuario : "PACIENTE");
        } catch (SQLException e) {
            // Si la columna no existe, usar valor por defecto
            System.out.println("⚠️ Columna tipo_usuario no encontrada, usando PACIENTE por defecto");
            usuario.setTipoUsuario("PACIENTE");
        }

        Timestamp timestamp = rs.getTimestamp("fecha_registro");
        if (timestamp != null) {
            usuario.setFechaRegistro(timestamp.toLocalDateTime());
        }

        usuario.setActivo(rs.getBoolean("activo"));
        return usuario;
    }
}

