package com.meditrack.controller;

import com.meditrack.dao.RecetaDAO;
import com.meditrack.dao.UserDAO;
import com.meditrack.model.Receta;
import com.meditrack.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/recetas")
public class RecetaServlet extends HttpServlet {
    private RecetaDAO recetaDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        recetaDAO = new RecetaDAO();
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

        if ("listarPorPaciente".equals(action)) {
            listarRecetasPorPaciente(request, response, usuario);
        } else if ("obtener".equals(action)) {
            obtenerReceta(request, response, usuario);
        } else if ("listar".equals(action)) {
            listarRecetas(request, response, usuario);
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

        // Solo los médicos pueden crear/editar recetas
        if (!"MEDICO".equals(usuario.getTipoUsuario())) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("crear".equals(action)) {
            crearReceta(request, response, usuario);
        } else if ("editar".equals(action)) {
            editarReceta(request, response, usuario);
        }
    }

    private void crearReceta(HttpServletRequest request, HttpServletResponse response, Usuario medico)
            throws ServletException, IOException {

        String pacienteIdStr = request.getParameter("pacienteId");
        String pacienteNombre = request.getParameter("pacienteNombre");
        String diagnostico = request.getParameter("diagnostico");
        String medicamento = request.getParameter("medicamento");
        String dosis = request.getParameter("dosis");
        String indicaciones = request.getParameter("indicaciones");

        if (pacienteIdStr == null || medicamento == null || medicamento.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard-medico.jsp?error=datos_faltantes");
            return;
        }

        try {
            Long pacienteId = Long.parseLong(pacienteIdStr);

            // Obtener información del paciente si no se proporcionó el nombre
            if (pacienteNombre == null || pacienteNombre.trim().isEmpty()) {
                Usuario paciente = userDAO.findById(pacienteId);
                if (paciente != null) {
                    pacienteNombre = paciente.getNombre() + " " + paciente.getApellido();
                }
            }

            Receta receta = new Receta();
            receta.setMedicoId(medico.getId());
            receta.setMedicoNombre(medico.getNombre() + " " + medico.getApellido());
            receta.setPacienteId(pacienteId);
            receta.setPacienteNombre(pacienteNombre);
            receta.setDiagnostico(diagnostico);
            receta.setMedicamento(medicamento);
            receta.setDosis(dosis);
            receta.setIndicaciones(indicaciones);

            boolean success = recetaDAO.createReceta(receta);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-medico.jsp?success=receta_creada&pacienteId=" + pacienteId);
            } else {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-medico.jsp?error=error_crear");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard-medico.jsp?error=id_invalido");
        }
    }

    private void editarReceta(HttpServletRequest request, HttpServletResponse response, Usuario medico)
            throws ServletException, IOException {

        String recetaIdStr = request.getParameter("recetaId");
        String diagnostico = request.getParameter("diagnostico");
        String medicamento = request.getParameter("medicamento");
        String dosis = request.getParameter("dosis");
        String indicaciones = request.getParameter("indicaciones");
        String estado = request.getParameter("estado");

        if (recetaIdStr == null || medicamento == null || medicamento.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard-medico.jsp?error=datos_faltantes");
            return;
        }

        try {
            Long recetaId = Long.parseLong(recetaIdStr);
            Receta receta = recetaDAO.findById(recetaId);

            if (receta == null) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-medico.jsp?error=receta_no_encontrada");
                return;
            }

            // Verificar que el médico sea el dueño de la receta
            if (!receta.getMedicoId().equals(medico.getId())) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-medico.jsp?error=sin_permiso");
                return;
            }

            receta.setDiagnostico(diagnostico);
            receta.setMedicamento(medicamento);
            receta.setDosis(dosis);
            receta.setIndicaciones(indicaciones);
            if (estado != null && !estado.trim().isEmpty()) {
                receta.setEstado(estado);
            }

            boolean success = recetaDAO.updateReceta(receta);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-medico.jsp?success=receta_actualizada&pacienteId=" + receta.getPacienteId());
            } else {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-medico.jsp?error=error_actualizar");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard-medico.jsp?error=id_invalido");
        }
    }

    private void listarRecetas(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        List<Receta> recetas;

        if ("MEDICO".equals(usuario.getTipoUsuario())) {
            recetas = recetaDAO.findByMedicoId(usuario.getId());
        } else if ("PACIENTE".equals(usuario.getTipoUsuario())) {
            recetas = recetaDAO.findByPacienteId(usuario.getId());
        } else {
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
            return;
        }

        request.setAttribute("recetas", recetas);
        request.getRequestDispatcher("/views/recetas-lista.jsp").forward(request, response);
    }

    private void listarRecetasPorPaciente(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        String pacienteIdStr = request.getParameter("pacienteId");

        if (pacienteIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard-medico.jsp");
            return;
        }

        try {
            Long pacienteId = Long.parseLong(pacienteIdStr);
            List<Receta> recetas;

            if ("MEDICO".equals(usuario.getTipoUsuario())) {
                recetas = recetaDAO.findByPacienteIdAndMedicoId(pacienteId, usuario.getId());
            } else {
                response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
                return;
            }

            Usuario paciente = userDAO.findById(pacienteId);
            request.setAttribute("paciente", paciente);
            request.setAttribute("recetas", recetas);
            request.getRequestDispatcher("/views/recetas-paciente.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard-medico.jsp?error=id_invalido");
        }
    }

    private void obtenerReceta(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        String recetaIdStr = request.getParameter("id");

        if (recetaIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
            return;
        }

        try {
            Long recetaId = Long.parseLong(recetaIdStr);
            Receta receta = recetaDAO.findById(recetaId);

            if (receta == null) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp?error=receta_no_encontrada");
                return;
            }

            // Verificar permisos
            if ("MEDICO".equals(usuario.getTipoUsuario()) && !receta.getMedicoId().equals(usuario.getId())) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp?error=sin_permiso");
                return;
            } else if ("PACIENTE".equals(usuario.getTipoUsuario()) && !receta.getPacienteId().equals(usuario.getId())) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp?error=sin_permiso");
                return;
            }

            request.setAttribute("receta", receta);
            request.getRequestDispatcher("/views/receta-detalle.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp?error=id_invalido");
        }
    }
}

