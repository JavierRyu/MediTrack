package com.meditrack.dao;

import com.meditrack.model.Receta;
import com.meditrack.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RecetaDAO {

    public boolean createReceta(Receta receta) {
        String sql = "INSERT INTO recetas (medico_id, medico_nombre, paciente_id, paciente_nombre, " +
                     "diagnostico, medicamento, dosis, indicaciones, fecha_emision, estado) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setLong(1, receta.getMedicoId());
            stmt.setString(2, receta.getMedicoNombre());
            stmt.setLong(3, receta.getPacienteId());
            stmt.setString(4, receta.getPacienteNombre());
            stmt.setString(5, receta.getDiagnostico());
            stmt.setString(6, receta.getMedicamento());
            stmt.setString(7, receta.getDosis());
            stmt.setString(8, receta.getIndicaciones());
            stmt.setTimestamp(9, Timestamp.valueOf(receta.getFechaEmision()));
            stmt.setString(10, receta.getEstado());

            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    receta.setId(rs.getLong(1));
                }
                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Receta> findByMedicoId(Long medicoId) {
        List<Receta> recetas = new ArrayList<>();
        String sql = "SELECT * FROM recetas WHERE medico_id = ? ORDER BY fecha_emision DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, medicoId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                recetas.add(mapResultSetToReceta(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return recetas;
    }

    public List<Receta> findByPacienteId(Long pacienteId) {
        List<Receta> recetas = new ArrayList<>();
        String sql = "SELECT * FROM recetas WHERE paciente_id = ? ORDER BY fecha_emision DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, pacienteId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                recetas.add(mapResultSetToReceta(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return recetas;
    }

    public Receta findById(Long id) {
        String sql = "SELECT * FROM recetas WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToReceta(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateReceta(Receta receta) {
        String sql = "UPDATE recetas SET diagnostico = ?, medicamento = ?, dosis = ?, " +
                     "indicaciones = ?, estado = ? WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, receta.getDiagnostico());
            stmt.setString(2, receta.getMedicamento());
            stmt.setString(3, receta.getDosis());
            stmt.setString(4, receta.getIndicaciones());
            stmt.setString(5, receta.getEstado());
            stmt.setLong(6, receta.getId());

            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Receta> findByPacienteIdAndMedicoId(Long pacienteId, Long medicoId) {
        List<Receta> recetas = new ArrayList<>();
        String sql = "SELECT * FROM recetas WHERE paciente_id = ? AND medico_id = ? ORDER BY fecha_emision DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, pacienteId);
            stmt.setLong(2, medicoId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                recetas.add(mapResultSetToReceta(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return recetas;
    }

    private Receta mapResultSetToReceta(ResultSet rs) throws SQLException {
        Receta receta = new Receta();
        receta.setId(rs.getLong("id"));
        receta.setMedicoId(rs.getLong("medico_id"));
        receta.setMedicoNombre(rs.getString("medico_nombre"));
        receta.setPacienteId(rs.getLong("paciente_id"));
        receta.setPacienteNombre(rs.getString("paciente_nombre"));
        receta.setDiagnostico(rs.getString("diagnostico"));
        receta.setMedicamento(rs.getString("medicamento"));
        receta.setDosis(rs.getString("dosis"));
        receta.setIndicaciones(rs.getString("indicaciones"));

        Timestamp timestamp = rs.getTimestamp("fecha_emision");
        if (timestamp != null) {
            receta.setFechaEmision(timestamp.toLocalDateTime());
        }

        receta.setEstado(rs.getString("estado"));
        return receta;
    }
}

