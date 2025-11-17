package com.meditrack.controller;

import com.meditrack.dao.RecetaDAO;
import com.meditrack.model.Receta;
import com.meditrack.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/recetas")
public class RecetaServlet extends HttpServlet {
    private RecetaDAO recetaDAO;

    @Override
    public void init() throws ServletException {
        recetaDAO = new RecetaDAO();
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

        // Solo los médicos pueden crear recetas
        if (!"MEDICO".equals(usuario.getTipoUsuario())) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("crear".equals(action)) {
            crearReceta(request, response, usuario);
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

        if (pacienteIdStr == null || pacienteNombre == null || medicamento == null) {
            request.setAttribute("error", "Faltan datos obligatorios");
            request.getRequestDispatcher("/views/dashboard-medico.jsp").forward(request, response);
            return;
        }

        try {
            Long pacienteId = Long.parseLong(pacienteIdStr);

            Receta receta = new Receta();
            receta.setMedicoId(medico.getId());
            receta.setMedicoNombre(medico.getNombreCompleto());
            receta.setPacienteId(pacienteId);
            receta.setPacienteNombre(pacienteNombre);
            receta.setDiagnostico(diagnostico);
            receta.setMedicamento(medicamento);
            receta.setDosis(dosis);
            receta.setIndicaciones(indicaciones);

            boolean success = recetaDAO.createReceta(receta);

            if (success) {
                request.setAttribute("success", "Receta creada exitosamente");
                request.setAttribute("recetaId", receta.getId());
            } else {
                request.setAttribute("error", "Error al crear la receta");
            }

            request.getRequestDispatcher("/views/dashboard-medico.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID de paciente inválido");
            request.getRequestDispatcher("/views/dashboard-medico.jsp").forward(request, response);
        }
    }
}

