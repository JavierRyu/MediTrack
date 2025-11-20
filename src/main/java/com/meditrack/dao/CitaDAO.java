package com.meditrack.dao;

import com.meditrack.model.Cita;
import com.meditrack.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CitaDAO {

    public boolean createCita(Cita cita) {
        String sql = "INSERT INTO citas (paciente_id, paciente_nombre, medico_id, medico_nombre, " +
                     "fecha_cita, motivo, estado, notas, fecha_creacion) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setLong(1, cita.getPacienteId());
            stmt.setString(2, cita.getPacienteNombre());
            stmt.setObject(3, cita.getMedicoId());
            stmt.setString(4, cita.getMedicoNombre());
            stmt.setTimestamp(5, Timestamp.valueOf(cita.getFechaCita()));
            stmt.setString(6, cita.getMotivo());
            stmt.setString(7, cita.getEstado());
            stmt.setString(8, cita.getNotas());
            stmt.setTimestamp(9, Timestamp.valueOf(cita.getFechaCreacion()));

            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    cita.setId(rs.getLong(1));
                }
                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCita(Cita cita) {
        String sql = "UPDATE citas SET fecha_cita = ?, motivo = ?, estado = ?, notas = ?, " +
                     "medico_id = ?, medico_nombre = ? WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setTimestamp(1, Timestamp.valueOf(cita.getFechaCita()));
            stmt.setString(2, cita.getMotivo());
            stmt.setString(3, cita.getEstado());
            stmt.setString(4, cita.getNotas());
            stmt.setObject(5, cita.getMedicoId());
            stmt.setString(6, cita.getMedicoNombre());
            stmt.setLong(7, cita.getId());

            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean cancelarCita(Long id) {
        String sql = "UPDATE citas SET estado = 'CANCELADA' WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Cita> findAll() {
        List<Cita> citas = new ArrayList<>();
        String sql = "SELECT * FROM citas ORDER BY fecha_cita DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                citas.add(mapResultSetToCita(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return citas;
    }

    public List<Cita> findByEstado(String estado) {
        List<Cita> citas = new ArrayList<>();
        String sql = "SELECT * FROM citas WHERE estado = ? ORDER BY fecha_cita DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, estado);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                citas.add(mapResultSetToCita(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return citas;
    }

    public Cita findById(Long id) {
        String sql = "SELECT * FROM citas WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToCita(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Cita> findByMedicoId(Long medicoId) {
        List<Cita> citas = new ArrayList<>();
        String sql = "SELECT * FROM citas WHERE medico_id = ? ORDER BY fecha_cita DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, medicoId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                citas.add(mapResultSetToCita(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return citas;
    }

    public List<Cita> findByPacienteId(Long pacienteId) {
        List<Cita> citas = new ArrayList<>();
        String sql = "SELECT * FROM citas WHERE paciente_id = ? ORDER BY fecha_cita DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, pacienteId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                citas.add(mapResultSetToCita(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return citas;
    }

    private Cita mapResultSetToCita(ResultSet rs) throws SQLException {
        Cita cita = new Cita();
        cita.setId(rs.getLong("id"));
        cita.setPacienteId(rs.getLong("paciente_id"));
        cita.setPacienteNombre(rs.getString("paciente_nombre"));

        Object medicoId = rs.getObject("medico_id");
        if (medicoId != null) {
            cita.setMedicoId(rs.getLong("medico_id"));
        }

        cita.setMedicoNombre(rs.getString("medico_nombre"));

        Timestamp timestampCita = rs.getTimestamp("fecha_cita");
        if (timestampCita != null) {
            cita.setFechaCita(timestampCita.toLocalDateTime());
        }

        cita.setMotivo(rs.getString("motivo"));
        cita.setEstado(rs.getString("estado"));
        cita.setNotas(rs.getString("notas"));

        Timestamp timestampCreacion = rs.getTimestamp("fecha_creacion");
        if (timestampCreacion != null) {
            cita.setFechaCreacion(timestampCreacion.toLocalDateTime());
        }

        return cita;
    }
}

