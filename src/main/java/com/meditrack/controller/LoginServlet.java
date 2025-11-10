package com.meditrack.controller;

import com.meditrack.model.Usuario;
import com.meditrack.service.AuthService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private AuthService authService;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Si el usuario ya está logueado, redirigir al dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
            return;
        }

        // Mostrar la página de login
        request.getRequestDispatcher("/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener parámetros del formulario
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Validar que no estén vacíos
        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Por favor, complete todos los campos");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        // Intentar autenticar al usuario
        Usuario usuario = authService.authenticateUser(email.trim(), password);

        if (usuario != null) {
            // Login exitoso - crear sesión
            HttpSession session = request.getSession();
            session.setAttribute("usuario", usuario);
            session.setAttribute("usuarioId", usuario.getId());
            session.setAttribute("usuarioNombre", usuario.getNombreCompleto());
            session.setAttribute("usuarioEmail", usuario.getEmail());
            session.setAttribute("usuarioRol", usuario.getRol());

            // Redirigir al dashboard
            response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
        } else {
            // Login fallido
            request.setAttribute("error", "Email o contraseña incorrectos");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
        }
    }
}

