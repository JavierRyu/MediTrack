<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.meditrack.dao.UserDAO" %>
<%@ page import="com.meditrack.dao.CitaDAO" %>
<%@ page import="com.meditrack.model.Usuario" %>
<%@ page import="com.meditrack.model.Cita" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    if (session.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String tipoUsuario = (String) session.getAttribute("tipoUsuario");
    if (!"ASISTENTE".equals(tipoUsuario)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Usuario asistente = (Usuario) session.getAttribute("usuario");
    UserDAO userDAO = new UserDAO();
    CitaDAO citaDAO = new CitaDAO();

    List<Usuario> pacientes = userDAO.findByTipoUsuario("PACIENTE");
    List<Usuario> medicos = userDAO.findByTipoUsuario("MEDICO");
    List<Cita> todasCitas = citaDAO.findAll();

    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Asistente - MediTrack</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f0f2f5;
        }

        .navbar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 18px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }

        .navbar-brand {
            font-size: 26px;
            font-weight: 700;
        }

        .navbar-user {
            display: flex;
            align-items: center;
            gap: 25px;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .user-avatar {
            width: 45px;
            height: 45px;
            background: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 18px;
            color: #667eea;
        }

        .user-name {
            font-weight: 600;
            font-size: 15px;
        }

        .user-role {
            font-size: 12px;
            opacity: 0.9;
        }

        .logout-btn {
            background: rgba(255,255,255,0.2);
            color: white;
            border: 2px solid rgba(255,255,255,0.3);
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s;
            font-weight: 600;
            font-size: 14px;
        }

        .logout-btn:hover {
            background: rgba(255,255,255,0.3);
        }

        .container {
            max-width: 1400px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            animation: slideIn 0.3s;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .welcome-card {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
            margin-bottom: 30px;
            border-left: 5px solid #667eea;
        }

        .welcome-card h1 {
            color: #333;
            margin-bottom: 8px;
            font-size: 28px;
        }

        .welcome-card p {
            color: #666;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
            text-align: center;
        }

        .stat-icon {
            font-size: 40px;
            margin-bottom: 10px;
        }

        .stat-number {
            font-size: 32px;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #666;
            font-size: 14px;
        }

        .content-card {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
            margin-bottom: 25px;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
        }

        .section-header h2 {
            color: #333;
            font-size: 22px;
        }

        .btn {
            padding: 12px 24px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-weight: 600;
            font-size: 14px;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }

        .btn-secondary {
            background: #6c757d;
            color: white;
        }

        .btn-edit {
            background: #ffc107;
            color: #000;
        }

        .btn-danger {
            background: #dc3545;
            color: white;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }

        .table th,
        .table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #e0e0e0;
        }

        .table th {
            background: #f8f9fa;
            font-weight: 600;
            color: #333;
        }

        .table tr:hover {
            background: #f8f9ff;
        }

        .badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }

        .badge-programada {
            background: #cce5ff;
            color: #004085;
        }

        .badge-completada {
            background: #d1ecf1;
            color: #0c5460;
        }

        .badge-cancelada {
            background: #f8d7da;
            color: #721c24;
        }

        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            animation: fadeIn 0.3s;
        }

        .modal-content {
            background-color: white;
            margin: 3% auto;
            padding: 35px;
            border-radius: 15px;
            width: 90%;
            max-width: 600px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            animation: slideDown 0.3s;
            max-height: 90vh;
            overflow-y: auto;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideDown {
            from {
                transform: translateY(-50px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
        }

        .modal-header h2 {
            color: #333;
            font-size: 24px;
        }

        .close {
            color: #aaa;
            font-size: 32px;
            font-weight: bold;
            cursor: pointer;
            transition: color 0.3s;
            line-height: 1;
        }

        .close:hover {
            color: #333;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 600;
            font-size: 14px;
        }

        .form-group input,
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s;
            font-family: inherit;
        }

        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }

        .form-actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
            margin-top: 25px;
        }

        .action-buttons {
            display: flex;
            gap: 8px;
        }

        .no-data {
            text-align: center;
            padding: 40px;
            color: #999;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-brand">🏥 MediTrack</div>
        <div class="navbar-user">
            <div class="user-info">
                <div class="user-avatar">
                    <%= asistente.getNombre().substring(0,1).toUpperCase() %>
                </div>
                <div>
                    <div class="user-name"><%= asistente.getNombre() + " " + asistente.getApellido() %></div>
                    <div class="user-role">Asistente Médico</div>
                </div>
            </div>
            <a href="<%= request.getContextPath() %>/logout" class="logout-btn">Cerrar Sesión</a>
        </div>
    </nav>

    <div class="container">
        <%
            String success = request.getParameter("success");
            String error = request.getParameter("error");
            if (success != null) {
        %>
            <div class="alert alert-success">
                <% if ("cita_creada".equals(success)) { %>
                    ✅ ¡Cita médica creada correctamente!
                <% } else if ("cita_actualizada".equals(success)) { %>
                    ✅ ¡Cita médica actualizada correctamente!
                <% } else if ("cita_cancelada".equals(success)) { %>
                    ✅ ¡Cita cancelada correctamente!
                <% } %>
            </div>
        <% } %>

        <% if (error != null) { %>
            <div class="alert alert-error">
                <% if ("datos_faltantes".equals(error)) { %>
                    ❌ Error: Faltan datos obligatorios
                <% } else if ("error_crear".equals(error)) { %>
                    ❌ Error al crear la cita
                <% } else { %>
                    ❌ Ha ocurrido un error
                <% } %>
            </div>
        <% } %>

        <div class="welcome-card">
            <h1>¡Bienvenido/a, <%= asistente.getNombre() %>!</h1>
            <p>Gestiona las citas médicas de la clínica</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon">📅</div>
                <div class="stat-number"><%= todasCitas.size() %></div>
                <div class="stat-label">Total Citas</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">👥</div>
                <div class="stat-number"><%= pacientes.size() %></div>
                <div class="stat-label">Pacientes</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">⚕️</div>
                <div class="stat-number"><%= medicos.size() %></div>
                <div class="stat-label">Médicos</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">⏰</div>
                <div class="stat-number">
                    <%= todasCitas.stream().filter(c -> "PROGRAMADA".equals(c.getEstado())).count() %>
                </div>
                <div class="stat-label">Programadas</div>
            </div>
        </div>

        <div class="content-card">
            <div class="section-header">
                <h2>📅 Gestión de Citas Médicas</h2>
                <button class="btn btn-primary" onclick="abrirModalCrearCita()">
                    ➕ Nueva Cita
                </button>
            </div>

            <% if (todasCitas != null && !todasCitas.isEmpty()) { %>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Fecha y Hora</th>
                            <th>Paciente</th>
                            <th>Médico</th>
                            <th>Motivo</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Cita cita : todasCitas) { %>
                            <tr>
                                <td><%= cita.getFechaCita().format(formatter) %></td>
                                <td><%= cita.getPacienteNombre() %></td>
                                <td><%= cita.getMedicoNombre() != null ? cita.getMedicoNombre() : "Sin asignar" %></td>
                                <td><%= cita.getMotivo() %></td>
                                <td><span class="badge badge-<%= cita.getEstado().toLowerCase() %>"><%= cita.getEstado() %></span></td>
                                <td>
                                    <div class="action-buttons">
                                        <button class="btn btn-edit" style="padding: 6px 12px; font-size: 12px;"
                                                onclick="editarCita(<%= cita.getId() %>, '<%= cita.getFechaCita().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")) %>', <%= cita.getPacienteId() %>, <%= cita.getMedicoId() != null ? cita.getMedicoId() : "null" %>, '<%= cita.getMotivo().replace("'", "\\'") %>', '<%= cita.getNotas() != null ? cita.getNotas().replace("'", "\\'").replace("\n", "\\n") : "" %>', '<%= cita.getEstado() %>')">
                                            ✏️ Editar
                                        </button>
                                        <% if ("PROGRAMADA".equals(cita.getEstado())) { %>
                                        <form action="<%= request.getContextPath() %>/citas" method="post" style="display: inline;">
                                            <input type="hidden" name="action" value="cancelar">
                                            <input type="hidden" name="citaId" value="<%= cita.getId() %>">
                                            <button type="submit" class="btn btn-danger" style="padding: 6px 12px; font-size: 12px;"
                                                    onclick="return confirm('¿Está seguro de cancelar esta cita?')">
                                                ❌ Cancelar
                                            </button>
                                        </form>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="no-data">No hay citas registradas</div>
            <% } %>
        </div>
    </div>

    <!-- Modal Crear Cita -->
    <div id="modalCrearCita" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>📅 Nueva Cita Médica</h2>
                <span class="close" onclick="cerrarModalCrearCita()">&times;</span>
            </div>
            <form action="<%= request.getContextPath() %>/citas" method="post">
                <input type="hidden" name="action" value="crear">

                <div class="form-group">
                    <label>Paciente: *</label>
                    <select name="pacienteId" required>
                        <option value="">Seleccione un paciente</option>
                        <% for (Usuario paciente : pacientes) { %>
                            <option value="<%= paciente.getId() %>">
                                <%= paciente.getNombre() + " " + paciente.getApellido() %> - <%= paciente.getEmail() %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label>Médico:</label>
                    <select name="medicoId">
                        <option value="">Sin asignar</option>
                        <% for (Usuario medico : medicos) { %>
                            <option value="<%= medico.getId() %>">
                                Dr. <%= medico.getNombre() + " " + medico.getApellido() %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label>Fecha y Hora: *</label>
                    <input type="datetime-local" name="fechaCita" required>
                </div>

                <div class="form-group">
                    <label>Motivo: *</label>
                    <input type="text" name="motivo" required placeholder="Motivo de la consulta">
                </div>

                <div class="form-group">
                    <label>Notas:</label>
                    <textarea name="notas" rows="4" placeholder="Notas adicionales"></textarea>
                </div>

                <div class="form-actions">
                    <button type="button" class="btn btn-secondary" onclick="cerrarModalCrearCita()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Crear Cita</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Editar Cita -->
    <div id="modalEditarCita" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>✏️ Editar Cita Médica</h2>
                <span class="close" onclick="cerrarModalEditarCita()">&times;</span>
            </div>
            <form action="<%= request.getContextPath() %>/citas" method="post">
                <input type="hidden" name="action" value="modificar">
                <input type="hidden" name="citaId" id="editCitaId">

                <div class="form-group">
                    <label>Paciente: *</label>
                    <select name="pacienteId" id="editPacienteId" disabled>
                        <% for (Usuario paciente : pacientes) { %>
                            <option value="<%= paciente.getId() %>">
                                <%= paciente.getNombre() + " " + paciente.getApellido() %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label>Médico:</label>
                    <select name="medicoId" id="editMedicoId">
                        <option value="">Sin asignar</option>
                        <% for (Usuario medico : medicos) { %>
                            <option value="<%= medico.getId() %>">
                                Dr. <%= medico.getNombre() + " " + medico.getApellido() %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label>Fecha y Hora: *</label>
                    <input type="datetime-local" name="fechaCita" id="editFechaCita" required>
                </div>

                <div class="form-group">
                    <label>Motivo: *</label>
                    <input type="text" name="motivo" id="editMotivo" required>
                </div>

                <div class="form-group">
                    <label>Notas:</label>
                    <textarea name="notas" id="editNotas" rows="4"></textarea>
                </div>

                <div class="form-group">
                    <label>Estado:</label>
                    <select name="estado" id="editEstado">
                        <option value="PROGRAMADA">PROGRAMADA</option>
                        <option value="COMPLETADA">COMPLETADA</option>
                        <option value="CANCELADA">CANCELADA</option>
                    </select>
                </div>

                <div class="form-actions">
                    <button type="button" class="btn btn-secondary" onclick="cerrarModalEditarCita()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Actualizar Cita</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function abrirModalCrearCita() {
            document.getElementById('modalCrearCita').style.display = 'block';
        }

        function cerrarModalCrearCita() {
            document.getElementById('modalCrearCita').style.display = 'none';
        }

        function editarCita(id, fecha, pacienteId, medicoId, motivo, notas, estado) {
            document.getElementById('editCitaId').value = id;
            document.getElementById('editPacienteId').value = pacienteId;
            document.getElementById('editMedicoId').value = medicoId || '';
            document.getElementById('editFechaCita').value = fecha;
            document.getElementById('editMotivo').value = motivo;
            document.getElementById('editNotas').value = notas;
            document.getElementById('editEstado').value = estado;
            document.getElementById('modalEditarCita').style.display = 'block';
        }

        function cerrarModalEditarCita() {
            document.getElementById('modalEditarCita').style.display = 'none';
        }

        window.onclick = function(event) {
            let modalCrear = document.getElementById('modalCrearCita');
            let modalEditar = document.getElementById('modalEditarCita');
            if (event.target == modalCrear) {
                cerrarModalCrearCita();
            }
            if (event.target == modalEditar) {
                cerrarModalEditarCita();
            }
        }
    </script>
</body>
</html>

