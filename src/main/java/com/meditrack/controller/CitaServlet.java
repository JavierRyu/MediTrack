package com.meditrack.controller;

import com.meditrack.dao.CitaDAO;
import com.meditrack.model.Cita;
import com.meditrack.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet("/citas")
public class CitaServlet extends HttpServlet {
    private CitaDAO citaDAO;

    @Override
    public void init() throws ServletException {
        citaDAO = new CitaDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Usuario usuario = (Usuario) session.getAttribute("usuario");
        String action = request.getParameter("action");

        if ("modificar".equals(action)) {
            modificarCita(request, response, usuario);
        } else if ("cancelar".equals(action)) {
            cancelarCita(request, response, usuario);
        }
    }

    private void modificarCita(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        // Solo asistentes pueden modificar citas
        if (!"ASISTENTE".equals(usuario.getTipoUsuario())) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
            return;
        }

        String citaIdStr = request.getParameter("citaId");
        String fechaCitaStr = request.getParameter("fechaCita");
        String motivo = request.getParameter("motivo");
        String notas = request.getParameter("notas");

        try {
            Long citaId = Long.parseLong(citaIdStr);
            Cita cita = citaDAO.findById(citaId);

            if (cita != null) {
                if (fechaCitaStr != null && !fechaCitaStr.isEmpty()) {
                    LocalDateTime fechaCita = LocalDateTime.parse(fechaCitaStr,
                                              DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
                    cita.setFechaCita(fechaCita);
                }

                if (motivo != null) cita.setMotivo(motivo);
                if (notas != null) cita.setNotas(notas);

                boolean success = citaDAO.updateCita(cita);

                if (success) {
                    request.setAttribute("success", "Cita modificada exitosamente");
                } else {
                    request.setAttribute("error", "Error al modificar la cita");
                }
            } else {
                request.setAttribute("error", "Cita no encontrada");
            }

            request.getRequestDispatcher("/views/dashboard-asistente.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
            request.getRequestDispatcher("/views/dashboard-asistente.jsp").forward(request, response);
        }
    }

    private void cancelarCita(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        // Solo asistentes pueden cancelar citas
        if (!"ASISTENTE".equals(usuario.getTipoUsuario())) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
            return;
        }

        String citaIdStr = request.getParameter("citaId");

        try {
            Long citaId = Long.parseLong(citaIdStr);
            boolean success = citaDAO.cancelarCita(citaId);

            if (success) {
                request.setAttribute("success", "Cita cancelada exitosamente");
            } else {
                request.setAttribute("error", "Error al cancelar la cita");
            }

            request.getRequestDispatcher("/views/dashboard-asistente.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID de cita inválido");
            request.getRequestDispatcher("/views/dashboard-asistente.jsp").forward(request, response);
        }
    }
}

