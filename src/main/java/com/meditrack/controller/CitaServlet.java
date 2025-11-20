package com.meditrack.controller;

import com.meditrack.dao.CitaDAO;
import com.meditrack.dao.UserDAO;
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
import java.util.List;

@WebServlet("/citas")
public class CitaServlet extends HttpServlet {
    private CitaDAO citaDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        citaDAO = new CitaDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Usuario usuario = (Usuario) session.getAttribute("usuario");
        String action = request.getParameter("action");

        if ("listar".equals(action)) {
            listarCitas(request, response, usuario);
        } else if ("obtener".equals(action)) {
            obtenerCita(request, response, usuario);
        }
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

        if ("crear".equals(action)) {
            crearCita(request, response, usuario);
        } else if ("modificar".equals(action)) {
            modificarCita(request, response, usuario);
        } else if ("cancelar".equals(action)) {
            cancelarCita(request, response, usuario);
        }
    }

    private void crearCita(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        // Solo asistentes pueden crear citas
        if (!"ASISTENTE".equals(usuario.getTipoUsuario())) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp?error=sin_permiso");
            return;
        }

        String pacienteIdStr = request.getParameter("pacienteId");
        String medicoIdStr = request.getParameter("medicoId");
        String fechaCitaStr = request.getParameter("fechaCita");
        String motivo = request.getParameter("motivo");
        String notas = request.getParameter("notas");

        if (pacienteIdStr == null || fechaCitaStr == null || motivo == null || motivo.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard-asistente.jsp?error=datos_faltantes");
            return;
        }

        try {
            Long pacienteId = Long.parseLong(pacienteIdStr);
            Long medicoId = medicoIdStr != null && !medicoIdStr.trim().isEmpty() ? Long.parseLong(medicoIdStr) : null;

            Usuario paciente = userDAO.findById(pacienteId);
            if (paciente == null) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-asistente.jsp?error=paciente_no_encontrado");
                return;
            }

            LocalDateTime fechaCita = LocalDateTime.parse(fechaCitaStr, DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));

            Cita cita = new Cita();
            cita.setPacienteId(pacienteId);
            cita.setPacienteNombre(paciente.getNombre() + " " + paciente.getApellido());

            if (medicoId != null) {
                Usuario medico = userDAO.findById(medicoId);
                if (medico != null) {
                    cita.setMedicoId(medicoId);
                    cita.setMedicoNombre(medico.getNombre() + " " + medico.getApellido());
                }
            }

            cita.setFechaCita(fechaCita);
            cita.setMotivo(motivo);
            cita.setNotas(notas);

            boolean success = citaDAO.createCita(cita);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-asistente.jsp?success=cita_creada");
            } else {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-asistente.jsp?error=error_crear");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/dashboard-asistente.jsp?error=error_formato");
        }
    }

    private void modificarCita(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        // Solo asistentes pueden modificar citas
        if (!"ASISTENTE".equals(usuario.getTipoUsuario())) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp?error=sin_permiso");
            return;
        }

        String citaIdStr = request.getParameter("citaId");
        String fechaCitaStr = request.getParameter("fechaCita");
        String motivo = request.getParameter("motivo");
        String notas = request.getParameter("notas");
        String medicoIdStr = request.getParameter("medicoId");
        String estado = request.getParameter("estado");

        if (citaIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard-asistente.jsp?error=datos_faltantes");
            return;
        }

        try {
            Long citaId = Long.parseLong(citaIdStr);
            Cita cita = citaDAO.findById(citaId);

            if (cita == null) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-asistente.jsp?error=cita_no_encontrada");
                return;
            }

            if (fechaCitaStr != null && !fechaCitaStr.isEmpty()) {
                LocalDateTime fechaCita = LocalDateTime.parse(fechaCitaStr, DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
                cita.setFechaCita(fechaCita);
            }

            if (motivo != null && !motivo.trim().isEmpty()) {
                cita.setMotivo(motivo);
            }

            if (notas != null) {
                cita.setNotas(notas);
            }

            if (medicoIdStr != null && !medicoIdStr.trim().isEmpty()) {
                Long medicoId = Long.parseLong(medicoIdStr);
                Usuario medico = userDAO.findById(medicoId);
                if (medico != null) {
                    cita.setMedicoId(medicoId);
                    cita.setMedicoNombre(medico.getNombre() + " " + medico.getApellido());
                }
            }

            if (estado != null && !estado.trim().isEmpty()) {
                cita.setEstado(estado);
            }

            boolean success = citaDAO.updateCita(cita);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-asistente.jsp?success=cita_actualizada");
            } else {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-asistente.jsp?error=error_actualizar");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/dashboard-asistente.jsp?error=error_formato");
        }
    }

    private void cancelarCita(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        // Solo asistentes pueden cancelar citas
        if (!"ASISTENTE".equals(usuario.getTipoUsuario())) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp?error=sin_permiso");
            return;
        }

        String citaIdStr = request.getParameter("citaId");

        if (citaIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard-asistente.jsp?error=datos_faltantes");
            return;
        }

        try {
            Long citaId = Long.parseLong(citaIdStr);
            boolean success = citaDAO.cancelarCita(citaId);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-asistente.jsp?success=cita_cancelada");
            } else {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-asistente.jsp?error=error_cancelar");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard-asistente.jsp?error=id_invalido");
        }
    }

    private void listarCitas(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        List<Cita> citas;

        if ("ASISTENTE".equals(usuario.getTipoUsuario())) {
            String estado = request.getParameter("estado");
            if (estado != null && !estado.isEmpty()) {
                citas = citaDAO.findByEstado(estado);
            } else {
                citas = citaDAO.findAll();
            }
        } else if ("MEDICO".equals(usuario.getTipoUsuario())) {
            citas = citaDAO.findByMedicoId(usuario.getId());
        } else if ("PACIENTE".equals(usuario.getTipoUsuario())) {
            citas = citaDAO.findByPacienteId(usuario.getId());
        } else {
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
            return;
        }

        request.setAttribute("citas", citas);
        request.getRequestDispatcher("/views/citas-lista.jsp").forward(request, response);
    }

    private void obtenerCita(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        String citaIdStr = request.getParameter("id");

        if (citaIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
            return;
        }

        try {
            Long citaId = Long.parseLong(citaIdStr);
            Cita cita = citaDAO.findById(citaId);

            if (cita == null) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp?error=cita_no_encontrada");
                return;
            }

            // Verificar permisos
            boolean tienePermiso = false;
            if ("ASISTENTE".equals(usuario.getTipoUsuario())) {
                tienePermiso = true;
            } else if ("MEDICO".equals(usuario.getTipoUsuario()) && cita.getMedicoId() != null && cita.getMedicoId().equals(usuario.getId())) {
                tienePermiso = true;
            } else if ("PACIENTE".equals(usuario.getTipoUsuario()) && cita.getPacienteId().equals(usuario.getId())) {
                tienePermiso = true;
            }

            if (!tienePermiso) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp?error=sin_permiso");
                return;
            }

            request.setAttribute("cita", cita);
            request.getRequestDispatcher("/views/cita-detalle.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp?error=id_invalido");
        }
    }
}

