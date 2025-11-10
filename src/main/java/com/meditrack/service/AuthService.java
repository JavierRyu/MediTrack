package com.meditrack.service;

import com.meditrack.dao.UserDAO;
import com.meditrack.model.Usuario;
import org.mindrot.jbcrypt.BCrypt;

public class AuthService {
    private UserDAO userDAO;

    public AuthService() {
        this.userDAO = new UserDAO();
    }

    /**
     * Registra un nuevo usuario en el sistema
     * @param usuario Usuario a registrar
     * @return true si el registro fue exitoso, false en caso contrario
     */
    public boolean registerUser(Usuario usuario) {
        try {
            // Verificar si el email ya existe
            if (userDAO.emailExists(usuario.getEmail())) {
                return false;
            }

            // Encriptar la contraseña
            String hashedPassword = BCrypt.hashpw(usuario.getPassword(), BCrypt.gensalt());
            usuario.setPassword(hashedPassword);

            // Crear el usuario en la base de datos
            return userDAO.createUser(usuario);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Autentica un usuario con email y contraseña
     * @param email Email del usuario
     * @param password Contraseña del usuario
     * @return Usuario si la autenticación es exitosa, null en caso contrario
     */
    public Usuario authenticateUser(String email, String password) {
        try {
            // Buscar usuario por email
            Usuario usuario = userDAO.findByEmail(email);

            // Verificar si el usuario existe y está activo
            if (usuario == null || !usuario.isActivo()) {
                return null;
            }

            // Verificar la contraseña
            if (BCrypt.checkpw(password, usuario.getPassword())) {
                return usuario;
            }

            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Verifica si un email ya está registrado
     * @param email Email a verificar
     * @return true si el email existe, false en caso contrario
     */
    public boolean emailExists(String email) {
        return userDAO.emailExists(email);
    }

    /**
     * Obtiene un usuario por su ID
     * @param id ID del usuario
     * @return Usuario encontrado o null
     */
    public Usuario getUserById(Long id) {
        return userDAO.findById(id);
    }

    /**
     * Valida los datos de registro
     * @param nombre Nombre del usuario
     * @param apellido Apellido del usuario
     * @param email Email del usuario
     * @param password Contraseña del usuario
     * @return Mensaje de error o null si es válido
     */
    public String validateRegistrationData(String nombre, String apellido, String email, String password) {
        if (nombre == null || nombre.trim().isEmpty()) {
            return "El nombre es obligatorio";
        }
        if (apellido == null || apellido.trim().isEmpty()) {
            return "El apellido es obligatorio";
        }
        if (email == null || email.trim().isEmpty()) {
            return "El email es obligatorio";
        }
        if (!isValidEmail(email)) {
            return "El formato del email no es válido";
        }
        if (password == null || password.length() < 6) {
            return "La contraseña debe tener al menos 6 caracteres";
        }
        if (emailExists(email)) {
            return "El email ya está registrado";
        }
        return null;
    }

    /**
     * Valida el formato del email
     * @param email Email a validar
     * @return true si es válido, false en caso contrario
     */
    private boolean isValidEmail(String email) {
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        return email.matches(emailRegex);
    }
}

