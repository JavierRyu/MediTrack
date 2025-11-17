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

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
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

        // Mostrar la página de registro
        request.getRequestDispatcher("/views/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configurar encoding para caracteres especiales
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Obtener parámetros del formulario
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String tipoUsuario = request.getParameter("tipoUsuario");

        // Debug: Imprimir parámetros recibidos
        System.out.println("=== DEBUG REGISTRO ===");
        System.out.println("Nombre: " + nombre);
        System.out.println("Apellido: " + apellido);
        System.out.println("Email: " + email);
        System.out.println("Tipo Usuario: " + tipoUsuario);
        System.out.println("=====================");

        // Validar que no estén vacíos
        if (nombre == null || nombre.trim().isEmpty() ||
            apellido == null || apellido.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty() ||
            tipoUsuario == null || tipoUsuario.trim().isEmpty()) {

            request.setAttribute("error", "Por favor, complete todos los campos");
            request.setAttribute("nombre", nombre);
            request.setAttribute("apellido", apellido);
            request.setAttribute("email", email);
            request.setAttribute("tipoUsuario", tipoUsuario);
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
            return;
        }

        // Validar que las contraseñas coincidan
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Las contraseñas no coinciden");
            request.setAttribute("nombre", nombre);
            request.setAttribute("apellido", apellido);
            request.setAttribute("email", email);
            request.setAttribute("tipoUsuario", tipoUsuario);
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
            return;
        }

        // Validar datos de registro
        String validationError = authService.validateRegistrationData(
            nombre.trim(), apellido.trim(), email.trim(), password
        );

        if (validationError != null) {
            request.setAttribute("error", validationError);
            request.setAttribute("nombre", nombre);
            request.setAttribute("apellido", apellido);
            request.setAttribute("email", email);
            request.setAttribute("tipoUsuario", tipoUsuario);
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
            return;
        }

        try {
            // Crear nuevo usuario
            Usuario nuevoUsuario = new Usuario(nombre.trim(), apellido.trim(), email.trim(), password);
            nuevoUsuario.setTipoUsuario(tipoUsuario.toUpperCase());

            System.out.println("Intentando registrar usuario: " + nuevoUsuario.getEmail() + " - Tipo: " + nuevoUsuario.getTipoUsuario());

            // Intentar registrar el usuario
            boolean registroExitoso = authService.registerUser(nuevoUsuario);

            if (registroExitoso) {
                // Registro exitoso - redirigir a login con mensaje de éxito
                System.out.println("✅ Usuario registrado exitosamente: " + nuevoUsuario.getEmail());
                request.setAttribute("success", "Registro exitoso. Por favor, inicie sesión.");
                request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            } else {
                // Registro fallido - podría ser email duplicado
                System.err.println("❌ Error al registrar usuario: " + nuevoUsuario.getEmail());

                // Verificar si el email ya existe
                if (authService.emailExists(email.trim())) {
                    request.setAttribute("error", "Este email ya está registrado. Por favor, use otro email o inicie sesión.");
                } else {
                    request.setAttribute("error", "Error al registrar el usuario. Por favor, intente nuevamente.");
                }

                request.setAttribute("nombre", nombre);
                request.setAttribute("apellido", apellido);
                request.setAttribute("email", email);
                request.setAttribute("tipoUsuario", tipoUsuario);
                request.getRequestDispatcher("/views/register.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.err.println("❌ Excepción durante el registro: " + e.getMessage());
            e.printStackTrace();

            request.setAttribute("error", "Error del sistema: " + e.getMessage());
            request.setAttribute("nombre", nombre);
            request.setAttribute("apellido", apellido);
            request.setAttribute("email", email);
            request.setAttribute("tipoUsuario", tipoUsuario);
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
        }
    }
}

