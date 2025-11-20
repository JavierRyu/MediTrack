<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.meditrack.dao.UserDAO" %>
<%@ page import="com.meditrack.dao.CitaDAO" %>
<%@ page import="com.meditrack.dao.RecetaDAO" %>
<%@ page import="com.meditrack.model.Usuario" %>
<%@ page import="com.meditrack.model.Cita" %>
<%@ page import="com.meditrack.model.Receta" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    if (session.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String tipoUsuario = (String) session.getAttribute("tipoUsuario");
    if (!"MEDICO".equals(tipoUsuario)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Usuario medico = (Usuario) session.getAttribute("usuario");
    UserDAO userDAO = new UserDAO();
    CitaDAO citaDAO = new CitaDAO();
    RecetaDAO recetaDAO = new RecetaDAO();

    List<Usuario> pacientes = userDAO.findByTipoUsuario("PACIENTE");
    List<Cita> citas = citaDAO.findByMedicoId(medico.getId());

    String pacienteIdParam = request.getParameter("pacienteId");
    Usuario pacienteSeleccionado = null;
    List<Receta> recetasPaciente = null;
    List<Cita> citasPaciente = null;

    if (pacienteIdParam != null && !pacienteIdParam.isEmpty()) {
        try {
            Long pacienteId = Long.parseLong(pacienteIdParam);
            pacienteSeleccionado = userDAO.findById(pacienteId);
            recetasPaciente = recetaDAO.findByPacienteIdAndMedicoId(pacienteId, medico.getId());
            citasPaciente = citaDAO.findByPacienteId(pacienteId);
        } catch (NumberFormatException e) {
            // Ignorar
        }
    }

    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Médico - MediTrack</title>
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

        .main-grid {
            display: grid;
            grid-template-columns: 350px 1fr;
            gap: 25px;
        }

        .sidebar {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
            height: fit-content;
        }

        .sidebar h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 20px;
        }

        .paciente-list {
            max-height: 600px;
            overflow-y: auto;
        }

        .paciente-item {
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            margin-bottom: 10px;
            cursor: pointer;
            transition: all 0.3s;
        }

        .paciente-item:hover {
            border-color: #667eea;
            background: #f8f9ff;
        }

        .paciente-item.active {
            border-color: #667eea;
            background: #667eea;
            color: white;
        }

        .paciente-name {
            font-weight: 600;
            margin-bottom: 4px;
        }

        .paciente-email {
            font-size: 13px;
            opacity: 0.8;
        }

        .content-area {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }

        .empty-state-icon {
            font-size: 64px;
            margin-bottom: 20px;
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

        .badge-emitida {
            background: #d4edda;
            color: #155724;
        }

        .badge-utilizada {
            background: #d1ecf1;
            color: #0c5460;
        }

        .badge-vencida {
            background: #f8d7da;
            color: #721c24;
        }

        .badge-activa {
            background: #d4edda;
            color: #155724;
        }

        .badge-cancelada {
            background: #f8d7da;
            color: #721c24;
        }

        .badge-programada {
            background: #cce5ff;
            color: #004085;
        }

        .badge-completada {
            background: #d1ecf1;
            color: #0c5460;
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
                    <%= medico.getNombre().substring(0,1).toUpperCase() %>
                </div>
                <div>
                    <div class="user-name"><%= medico.getNombre() + " " + medico.getApellido() %></div>
                    <div class="user-role">Médico</div>
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
                <% if ("receta_creada".equals(success)) { %>
                    ✅ ¡Receta creada correctamente!
                <% } else if ("receta_actualizada".equals(success)) { %>
                    ✅ ¡Receta actualizada correctamente!
                <% } %>
            </div>
        <% } %>

        <% if (error != null) { %>
            <div class="alert alert-error">
                <% if ("datos_faltantes".equals(error)) { %>
                    ❌ Error: Faltan datos obligatorios
                <% } else if ("error_crear".equals(error)) { %>
                    ❌ Error al crear la receta
                <% } else { %>
                    ❌ Ha ocurrido un error
                <% } %>
            </div>
        <% } %>

        <div class="welcome-card">
            <h1>¡Bienvenido, Dr. <%= medico.getNombre() %>!</h1>
            <p>Gestiona tus pacientes y sus recetas médicas desde aquí</p>
        </div>

        <div class="main-grid">
            <div class="sidebar">
                <h2>📋 Mis Pacientes</h2>
                <div class="paciente-list">
                    <% if (pacientes != null && !pacientes.isEmpty()) {
                        for (Usuario paciente : pacientes) {
                            boolean isActive = pacienteSeleccionado != null &&
                                             paciente.getId().equals(pacienteSeleccionado.getId());
                    %>
                        <div class="paciente-item <%= isActive ? "active" : "" %>"
                             onclick="window.location.href='?pacienteId=<%= paciente.getId() %>'">
                            <div class="paciente-name">
                                <%= paciente.getNombre() + " " + paciente.getApellido() %>
                            </div>
                            <div class="paciente-email"><%= paciente.getEmail() %></div>
                        </div>
                    <% }
                    } else { %>
                        <div class="no-data">No hay pacientes registrados</div>
                    <% } %>
                </div>
            </div>

            <div class="content-area">
                <% if (pacienteSeleccionado != null) { %>
                    <div class="section-header">
                        <h2>👤 <%= pacienteSeleccionado.getNombre() + " " + pacienteSeleccionado.getApellido() %></h2>
                        <button class="btn btn-primary" onclick="abrirModalReceta()">
                            ➕ Nueva Receta
                        </button>
                    </div>

                    <h3 style="margin: 30px 0 15px 0; color: #333;">📝 Recetas Médicas</h3>
                    <% if (recetasPaciente != null && !recetasPaciente.isEmpty()) { %>
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Fecha</th>
                                    <th>Diagnóstico</th>
                                    <th>Medicamento</th>
                                    <th>Dosis</th>
                                    <th>Estado</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Receta receta : recetasPaciente) { %>
                                    <tr>
                                        <td><%= receta.getFechaEmision().format(formatter) %></td>
                                        <td><%= receta.getDiagnostico() != null ? receta.getDiagnostico() : "-" %></td>
                                        <td><%= receta.getMedicamento() %></td>
                                        <td><%= receta.getDosis() != null ? receta.getDosis() : "-" %></td>
                                        <td><span class="badge badge-<%= receta.getEstado().toLowerCase() %>"><%= receta.getEstado() %></span></td>
                                        <td>
                                            <button class="btn btn-edit" style="padding: 6px 12px; font-size: 12px;"
                                                    onclick="editarReceta(<%= receta.getId() %>, '<%= receta.getDiagnostico() != null ? receta.getDiagnostico().replace("'", "\\'") : "" %>', '<%= receta.getMedicamento().replace("'", "\\'") %>', '<%= receta.getDosis() != null ? receta.getDosis().replace("'", "\\'") : "" %>', '<%= receta.getIndicaciones() != null ? receta.getIndicaciones().replace("'", "\\'").replace("\n", "\\n") : "" %>', '<%= receta.getEstado() %>')">
                                                ✏️ Editar
                                            </button>
                                            <a href="<%= request.getContextPath() %>/recetas/descargar-pdf?id=<%= receta.getId() %>"
                                               class="btn" style="padding: 6px 12px; font-size: 12px; background: #28a745; color: white; text-decoration: none; display: inline-block; margin-left: 5px;"
                                               title="Descargar PDF">
                                                📄 PDF
                                            </a>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    <% } else { %>
                        <div class="no-data">No hay recetas para este paciente</div>
                    <% } %>

                    <h3 style="margin: 30px 0 15px 0; color: #333;">📅 Citas Médicas</h3>
                    <% if (citasPaciente != null && !citasPaciente.isEmpty()) { %>
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Fecha</th>
                                    <th>Motivo</th>
                                    <th>Estado</th>
                                    <th>Notas</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Cita cita : citasPaciente) { %>
                                    <tr>
                                        <td><%= cita.getFechaCita().format(formatter) %></td>
                                        <td><%= cita.getMotivo() %></td>
                                        <td><span class="badge badge-<%= cita.getEstado().toLowerCase() %>"><%= cita.getEstado() %></span></td>
                                        <td><%= cita.getNotas() != null ? cita.getNotas() : "-" %></td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    <% } else { %>
                        <div class="no-data">No hay citas para este paciente</div>
                    <% } %>

                <% } else { %>
                    <div class="empty-state">
                        <div class="empty-state-icon">👈</div>
                        <h3>Selecciona un paciente</h3>
                        <p>Selecciona un paciente de la lista para ver sus recetas y citas médicas</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Modal Nueva Receta -->
    <div id="modalReceta" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>📝 Nueva Receta Médica</h2>
                <span class="close" onclick="cerrarModalReceta()">&times;</span>
            </div>
            <form action="<%= request.getContextPath() %>/recetas" method="post">
                <input type="hidden" name="action" value="crear">
                <input type="hidden" name="pacienteId" value="<%= pacienteSeleccionado != null ? pacienteSeleccionado.getId() : "" %>">

                <div class="form-group">
                    <label>Diagnóstico:</label>
                    <textarea name="diagnostico" rows="3" placeholder="Ingrese el diagnóstico"></textarea>
                </div>

                <div class="form-group">
                    <label>Medicamento: *</label>
                    <input type="text" name="medicamento" required placeholder="Nombre del medicamento">
                </div>

                <div class="form-group">
                    <label>Dosis:</label>
                    <input type="text" name="dosis" placeholder="Ej: 500mg cada 8 horas">
                </div>

                <div class="form-group">
                    <label>Indicaciones:</label>
                    <textarea name="indicaciones" rows="4" placeholder="Indicaciones adicionales"></textarea>
                </div>

                <div class="form-actions">
                    <button type="button" class="btn btn-secondary" onclick="cerrarModalReceta()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Guardar Receta</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Editar Receta -->
    <div id="modalEditarReceta" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>✏️ Editar Receta Médica</h2>
                <span class="close" onclick="cerrarModalEditarReceta()">&times;</span>
            </div>
            <form action="<%= request.getContextPath() %>/recetas" method="post">
                <input type="hidden" name="action" value="editar">
                <input type="hidden" name="recetaId" id="editRecetaId">

                <div class="form-group">
                    <label>Diagnóstico:</label>
                    <textarea name="diagnostico" id="editDiagnostico" rows="3"></textarea>
                </div>

                <div class="form-group">
                    <label>Medicamento: *</label>
                    <input type="text" name="medicamento" id="editMedicamento" required>
                </div>

                <div class="form-group">
                    <label>Dosis:</label>
                    <input type="text" name="dosis" id="editDosis">
                </div>

                <div class="form-group">
                    <label>Indicaciones:</label>
                    <textarea name="indicaciones" id="editIndicaciones" rows="4"></textarea>
                </div>

                <div class="form-group">
                    <label>Estado:</label>
                    <select name="estado" id="editEstado">
                        <option value="EMITIDA">EMITIDA</option>
                        <option value="UTILIZADA">UTILIZADA</option>
                        <option value="VENCIDA">VENCIDA</option>
                    </select>
                </div>

                <div class="form-actions">
                    <button type="button" class="btn btn-secondary" onclick="cerrarModalEditarReceta()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Actualizar Receta</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function abrirModalReceta() {
            <% if (pacienteSeleccionado == null) { %>
                alert('Por favor selecciona un paciente primero');
                return;
            <% } %>
            document.getElementById('modalReceta').style.display = 'block';
        }

        function cerrarModalReceta() {
            document.getElementById('modalReceta').style.display = 'none';
        }

        function editarReceta(id, diagnostico, medicamento, dosis, indicaciones, estado) {
            document.getElementById('editRecetaId').value = id;
            document.getElementById('editDiagnostico').value = diagnostico;
            document.getElementById('editMedicamento').value = medicamento;
            document.getElementById('editDosis').value = dosis;
            document.getElementById('editIndicaciones').value = indicaciones;
            document.getElementById('editEstado').value = estado;
            document.getElementById('modalEditarReceta').style.display = 'block';
        }

        function cerrarModalEditarReceta() {
            document.getElementById('modalEditarReceta').style.display = 'none';
        }

        window.onclick = function(event) {
            let modalReceta = document.getElementById('modalReceta');
            let modalEditar = document.getElementById('modalEditarReceta');
            if (event.target == modalReceta) {
                cerrarModalReceta();
            }
            if (event.target == modalEditar) {
                cerrarModalEditarReceta();
            }
        }
    </script>
</body>
</html>

