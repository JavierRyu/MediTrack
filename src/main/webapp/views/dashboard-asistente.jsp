<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.meditrack.dao.CitaDAO" %>
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

    // Cargar citas programadas
    CitaDAO citaDAO = new CitaDAO();
    List<Cita> citas = citaDAO.findByEstado("PROGRAMADA");
    request.setAttribute("citas", citas);
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
            display: flex;
            align-items: center;
            gap: 10px;
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

        .user-details {
            text-align: right;
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
            display: inline-block;
            transition: all 0.3s;
            font-weight: 600;
            font-size: 14px;
        }

        .logout-btn:hover {
            background: rgba(255,255,255,0.3);
            transform: translateY(-2px);
        }

        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .welcome-card {
            background: white;
            padding: 35px;
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
            font-size: 15px;
        }

        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }

        .feature-card {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
            transition: all 0.3s;
            border-top: 4px solid #667eea;
        }

        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.2);
        }

        .feature-icon {
            font-size: 48px;
            margin-bottom: 15px;
        }

        .feature-card h3 {
            color: #333;
            margin-bottom: 12px;
            font-size: 20px;
        }

        .feature-card p {
            color: #666;
            margin-bottom: 20px;
            font-size: 14px;
            line-height: 1.6;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            font-size: 14px;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }

        .btn-danger {
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a6f 100%);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            font-size: 13px;
            transition: all 0.3s;
        }

        .btn-danger:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 107, 107, 0.4);
        }

        .btn-secondary {
            background: #6c757d;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            font-size: 13px;
            transition: all 0.3s;
            margin-right: 8px;
        }

        .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
        }

        .citas-section {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }

        .citas-section h2 {
            color: #333;
            margin-bottom: 25px;
            font-size: 24px;
        }

        .cita-item {
            padding: 20px;
            border: 2px solid #f0f0f0;
            border-radius: 10px;
            margin-bottom: 15px;
            transition: all 0.3s;
        }

        .cita-item:hover {
            border-color: #667eea;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.1);
        }

        .cita-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 12px;
        }

        .cita-info h4 {
            color: #333;
            margin-bottom: 5px;
            font-size: 18px;
        }

        .cita-info p {
            color: #666;
            font-size: 14px;
            margin: 3px 0;
        }

        .cita-actions {
            display: flex;
            gap: 8px;
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

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .modal-content {
            background-color: white;
            margin: 5% auto;
            padding: 35px;
            border-radius: 15px;
            width: 90%;
            max-width: 600px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            animation: slideDown 0.3s;
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
        .form-group textarea {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s;
            font-family: inherit;
        }

        .form-group input:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 80px;
        }

        .alert {
            padding: 14px 18px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .empty-state {
            text-align: center;
            padding: 40px;
            color: #999;
        }

        .empty-state-icon {
            font-size: 64px;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-brand">
            <span>👩‍💼</span>
            <span>MediTrack - Panel de Asistente</span>
        </div>
        <div class="navbar-user">
            <div class="user-info">
                <div class="user-avatar">
                    ${sessionScope.usuarioNombre.substring(0,1).toUpperCase()}
                </div>
                <div class="user-details">
                    <div class="user-name">${sessionScope.usuarioNombre}</div>
                    <div class="user-role">Asistente Médico</div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Cerrar Sesión</a>
        </div>
    </nav>

    <div class="container">
        <div class="welcome-card">
            <h1>¡Bienvenido/a, ${sessionScope.usuarioNombre}!</h1>
            <p>Gestiona las citas médicas y coordina la agenda del consultorio.</p>
        </div>

        <c:if test="${not empty success}">
            <div class="alert alert-success">
                ✓ ${success}
            </div>
        </c:if>

        <c:if test="${not empty error}">
            <div class="alert alert-error">
                ✗ ${error}
            </div>
        </c:if>

        <div class="cards-grid">
            <div class="feature-card">
                <div class="feature-icon">📅</div>
                <h3>Gestión de Citas</h3>
                <p>Modifica o cancela las citas programadas según sea necesario.</p>
                <button onclick="scrollToCitas()" class="btn-primary">Ver Citas</button>
            </div>

            <div class="feature-card">
                <div class="feature-icon">📊</div>
                <h3>Calendario</h3>
                <p>Visualiza todas las citas en un calendario mensual.</p>
                <button onclick="alert('Funcionalidad en desarrollo')" class="btn-primary">Ver Calendario</button>
            </div>

            <div class="feature-card">
                <div class="feature-icon">👥</div>
                <h3>Registro de Pacientes</h3>
                <p>Administra la información de contacto de los pacientes.</p>
                <button onclick="alert('Funcionalidad en desarrollo')" class="btn-primary">Ver Pacientes</button>
            </div>
        </div>

        <div class="citas-section" id="citasSection">
            <h2>📅 Citas Programadas</h2>

            <c:choose>
                <c:when test="${empty citas}">
                    <div class="empty-state">
                        <div class="empty-state-icon">📭</div>
                        <p>No hay citas programadas en este momento.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="cita" items="${citas}">
                        <div class="cita-item">
                            <div class="cita-header">
                                <div class="cita-info">
                                    <h4>🤒 ${cita.pacienteNombre}</h4>
                                    <p><strong>Fecha:</strong> ${cita.fechaCita.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))}</p>
                                    <p><strong>Motivo:</strong> ${cita.motivo != null ? cita.motivo : 'No especificado'}</p>
                                    <c:if test="${not empty cita.medicoNombre}">
                                        <p><strong>Médico:</strong> ${cita.medicoNombre}</p>
                                    </c:if>
                                </div>
                                <div class="cita-actions">
                                    <button onclick="abrirModalModificar(${cita.id}, '${cita.pacienteNombre}', '${cita.fechaCita}', '${cita.motivo}')"
                                            class="btn-secondary">Modificar</button>
                                    <button onclick="confirmarCancelar(${cita.id})" class="btn-danger">Cancelar</button>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Modal para modificar cita -->
    <div id="modalModificar" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>📝 Modificar Cita</h2>
                <span class="close" onclick="cerrarModalModificar()">&times;</span>
            </div>
            <form action="${pageContext.request.contextPath}/citas" method="post">
                <input type="hidden" name="action" value="modificar">
                <input type="hidden" id="citaId" name="citaId">

                <div class="form-group">
                    <label>Paciente</label>
                    <input type="text" id="pacienteNombreModal" disabled>
                </div>

                <div class="form-group">
                    <label for="fechaCita">Nueva Fecha y Hora *</label>
                    <input type="datetime-local" id="fechaCita" name="fechaCita" required>
                </div>

                <div class="form-group">
                    <label for="motivo">Motivo</label>
                    <input type="text" id="motivo" name="motivo" placeholder="Motivo de la cita">
                </div>

                <div class="form-group">
                    <label for="notas">Notas</label>
                    <textarea id="notas" name="notas" placeholder="Notas adicionales..."></textarea>
                </div>

                <button type="submit" class="btn-primary" style="width: 100%; padding: 14px;">
                    Guardar Cambios
                </button>
            </form>
        </div>
    </div>

    <script>
        function scrollToCitas() {
            document.getElementById('citasSection').scrollIntoView({ behavior: 'smooth' });
        }

        function abrirModalModificar(id, paciente, fecha, motivo) {
            document.getElementById('citaId').value = id;
            document.getElementById('pacienteNombreModal').value = paciente;
            document.getElementById('motivo').value = motivo || '';
            document.getElementById('modalModificar').style.display = 'block';
        }

        function cerrarModalModificar() {
            document.getElementById('modalModificar').style.display = 'none';
        }

        function confirmarCancelar(citaId) {
            if (confirm('¿Está seguro de que desea cancelar esta cita?')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/citas';

                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'cancelar';

                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'citaId';
                idInput.value = citaId;

                form.appendChild(actionInput);
                form.appendChild(idInput);
                document.body.appendChild(form);
                form.submit();
            }
        }

        window.onclick = function(event) {
            const modal = document.getElementById('modalModificar');
            if (event.target == modal) {
                cerrarModalModificar();
            }
        }
    </script>
</body>
</html>

