<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.meditrack.dao.RecetaDAO" %>
<%@ page import="com.meditrack.dao.CitaDAO" %>
<%@ page import="com.meditrack.model.Usuario" %>
<%@ page import="com.meditrack.model.Receta" %>
<%@ page import="com.meditrack.model.Cita" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    if (session.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String tipoUsuario = (String) session.getAttribute("tipoUsuario");
    if (!"PACIENTE".equals(tipoUsuario)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Usuario paciente = (Usuario) session.getAttribute("usuario");
    RecetaDAO recetaDAO = new RecetaDAO();
    CitaDAO citaDAO = new CitaDAO();

    List<Receta> misRecetas = recetaDAO.findByPacienteId(paciente.getId());
    List<Cita> misCitas = citaDAO.findByPacienteId(paciente.getId());

    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Paciente - MediTrack</title>
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
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
            text-align: center;
            border-top: 4px solid #667eea;
        }

        .stat-icon {
            font-size: 48px;
            margin-bottom: 10px;
        }

        .stat-number {
            font-size: 36px;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #666;
            font-size: 14px;
            font-weight: 600;
        }

        .content-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 25px;
        }

        .content-card {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
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
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }

        .table th,
        .table td {
            padding: 15px 12px;
            text-align: left;
            border-bottom: 1px solid #e0e0e0;
        }

        .table th {
            background: #f8f9fa;
            font-weight: 600;
            color: #333;
            font-size: 14px;
        }

        .table tr:hover {
            background: #f8f9ff;
        }

        .table td {
            font-size: 14px;
            color: #555;
        }

        .badge {
            padding: 5px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
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

        .no-data {
            text-align: center;
            padding: 50px 20px;
            color: #999;
        }

        .no-data-icon {
            font-size: 64px;
            margin-bottom: 15px;
            opacity: 0.5;
        }

        .receta-card {
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 15px;
            transition: all 0.3s;
        }

        .receta-card:hover {
            border-color: #667eea;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.15);
        }

        .receta-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 15px;
        }

        .receta-medico {
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }

        .receta-fecha {
            font-size: 13px;
            color: #666;
        }

        .receta-body {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 10px;
        }

        .receta-field {
            margin-bottom: 10px;
        }

        .receta-field:last-child {
            margin-bottom: 0;
        }

        .receta-label {
            font-size: 12px;
            font-weight: 600;
            color: #666;
            text-transform: uppercase;
            margin-bottom: 3px;
        }

        .receta-value {
            font-size: 14px;
            color: #333;
        }

        .cita-card {
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 15px;
            transition: all 0.3s;
        }

        .cita-card:hover {
            border-color: #667eea;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.15);
        }

        .cita-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .cita-fecha {
            font-size: 18px;
            font-weight: 600;
            color: #667eea;
        }

        .cita-body {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }

        .cita-field {
            display: flex;
            flex-direction: column;
        }

        .cita-label {
            font-size: 12px;
            font-weight: 600;
            color: #666;
            text-transform: uppercase;
            margin-bottom: 5px;
        }

        .cita-value {
            font-size: 14px;
            color: #333;
        }

        @media (max-width: 768px) {
            .cita-body {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-brand">🏥 MediTrack</div>
        <div class="navbar-user">
            <div class="user-info">
                <div class="user-avatar">
                    <%= paciente.getNombre().substring(0,1).toUpperCase() %>
                </div>
                <div>
                    <div class="user-name"><%= paciente.getNombre() + " " + paciente.getApellido() %></div>
                    <div class="user-role">Paciente</div>
                </div>
            </div>
            <a href="<%= request.getContextPath() %>/logout" class="logout-btn">Cerrar Sesión</a>
        </div>
    </nav>

    <div class="container">
        <div class="welcome-card">
            <h1>¡Bienvenido/a, <%= paciente.getNombre() %>!</h1>
            <p>Consulta tus citas médicas y recetas</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon">📅</div>
                <div class="stat-number"><%= misCitas != null ? misCitas.size() : 0 %></div>
                <div class="stat-label">Mis Citas</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">💊</div>
                <div class="stat-number"><%= misRecetas != null ? misRecetas.size() : 0 %></div>
                <div class="stat-label">Mis Recetas</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">⏰</div>
                <div class="stat-number">
                    <%= misCitas != null ? misCitas.stream().filter(c -> "PROGRAMADA".equals(c.getEstado())).count() : 0 %>
                </div>
                <div class="stat-label">Citas Próximas</div>
            </div>
        </div>

        <div class="content-grid">
            <!-- Mis Citas Médicas -->
            <div class="content-card">
                <div class="section-header">
                    <h2>📅 Mis Citas Médicas</h2>
                </div>

                <% if (misCitas != null && !misCitas.isEmpty()) {
                    for (Cita cita : misCitas) { %>
                        <div class="cita-card">
                            <div class="cita-header">
                                <div class="cita-fecha">
                                    📆 <%= cita.getFechaCita().format(formatter) %>
                                </div>
                                <span class="badge badge-<%= cita.getEstado().toLowerCase() %>">
                                    <%= cita.getEstado() %>
                                </span>
                            </div>
                            <div class="cita-body">
                                <div class="cita-field">
                                    <div class="cita-label">Médico</div>
                                    <div class="cita-value">
                                        <%= cita.getMedicoNombre() != null ? "Dr. " + cita.getMedicoNombre() : "Sin asignar" %>
                                    </div>
                                </div>
                                <div class="cita-field">
                                    <div class="cita-label">Motivo</div>
                                    <div class="cita-value"><%= cita.getMotivo() %></div>
                                </div>
                                <% if (cita.getNotas() != null && !cita.getNotas().trim().isEmpty()) { %>
                                <div class="cita-field" style="grid-column: 1 / -1;">
                                    <div class="cita-label">Notas</div>
                                    <div class="cita-value"><%= cita.getNotas() %></div>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    <% }
                } else { %>
                    <div class="no-data">
                        <div class="no-data-icon">📅</div>
                        <h3>No tienes citas médicas</h3>
                        <p>Aún no hay citas programadas para ti</p>
                    </div>
                <% } %>
            </div>

            <!-- Mis Recetas -->
            <div class="content-card">
                <div class="section-header">
                    <h2>💊 Mis Recetas Médicas</h2>
                </div>

                <% if (misRecetas != null && !misRecetas.isEmpty()) {
                    for (Receta receta : misRecetas) { %>
                        <div class="receta-card">
                            <div class="receta-header">
                                <div>
                                    <div class="receta-medico">
                                        ⚕️ Dr. <%= receta.getMedicoNombre() %>
                                    </div>
                                    <div class="receta-fecha">
                                        📅 <%= receta.getFechaEmision().format(formatter) %>
                                    </div>
                                </div>
                                <span class="badge badge-<%= receta.getEstado().toLowerCase() %>">
                                    <%= receta.getEstado() %>
                                </span>
                            </div>
                            <div class="receta-body">
                                <% if (receta.getDiagnostico() != null && !receta.getDiagnostico().trim().isEmpty()) { %>
                                <div class="receta-field">
                                    <div class="receta-label">Diagnóstico</div>
                                    <div class="receta-value"><%= receta.getDiagnostico() %></div>
                                </div>
                                <% } %>

                                <div class="receta-field">
                                    <div class="receta-label">💊 Medicamento</div>
                                    <div class="receta-value" style="font-weight: 600; color: #667eea;">
                                        <%= receta.getMedicamento() %>
                                    </div>
                                </div>

                                <% if (receta.getDosis() != null && !receta.getDosis().trim().isEmpty()) { %>
                                <div class="receta-field">
                                    <div class="receta-label">Dosis</div>
                                    <div class="receta-value"><%= receta.getDosis() %></div>
                                </div>
                                <% } %>

                                <% if (receta.getIndicaciones() != null && !receta.getIndicaciones().trim().isEmpty()) { %>
                                <div class="receta-field">
                                    <div class="receta-label">Indicaciones</div>
                                    <div class="receta-value"><%= receta.getIndicaciones() %></div>
                                </div>
                                <% } %>
                            </div>
                            <div class="receta-actions">
                                <a href="<%= request.getContextPath() %>/recetas/descargar-pdf?id=<%= receta.getId() %>"
                                   class="btn-download-pdf"
                                   title="Descargar receta en PDF">
                                    📄 Descargar PDF
                                </a>
                            </div>
                        </div>
                    <% }
                } else { %>
                    <div class="no-data">
                        <div class="no-data-icon">💊</div>
                        <h3>No tienes recetas médicas</h3>
                        <p>Aún no se te han prescrito medicamentos</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>

