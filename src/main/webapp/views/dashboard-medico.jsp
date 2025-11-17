<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
            min-height: 100px;
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

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-brand">
            <span>👨‍⚕️</span>
            <span>MediTrack - Panel Médico</span>
        </div>
        <div class="navbar-user">
            <div class="user-info">
                <div class="user-avatar">
                    ${sessionScope.usuarioNombre.substring(0,1).toUpperCase()}
                </div>
                <div class="user-details">
                    <div class="user-name">${sessionScope.usuarioNombre}</div>
                    <div class="user-role">Médico</div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Cerrar Sesión</a>
        </div>
    </nav>

    <div class="container">
        <div class="welcome-card">
            <h1>¡Bienvenido, Dr. ${sessionScope.usuarioNombre}!</h1>
            <p>Gestiona tus pacientes y emite recetas médicas de forma rápida y segura.</p>
        </div>

        <c:if test="${not empty success}">
            <div class="alert alert-success">
                ✓ ${success}
                <c:if test="${not empty recetaId}">
                    <button onclick="descargarReceta(${recetaId})" class="btn-primary" style="margin-left: auto;">
                        Descargar Receta
                    </button>
                </c:if>
            </div>
        </c:if>

        <c:if test="${not empty error}">
            <div class="alert alert-error">
                ✗ ${error}
            </div>
        </c:if>

        <div class="cards-grid">
            <div class="feature-card">
                <div class="feature-icon">📋</div>
                <h3>Emitir Receta</h3>
                <p>Crea recetas médicas digitales para tus pacientes con todos los detalles necesarios.</p>
                <button onclick="abrirModalReceta()" class="btn-primary">Nueva Receta</button>
            </div>

            <div class="feature-card">
                <div class="feature-icon">📊</div>
                <h3>Mis Recetas</h3>
                <p>Consulta el historial de todas las recetas que has emitido.</p>
                <button onclick="alert('Funcionalidad en desarrollo')" class="btn-primary">Ver Historial</button>
            </div>

            <div class="feature-card">
                <div class="feature-icon">👥</div>
                <h3>Mis Pacientes</h3>
                <p>Gestiona la información y el historial de tus pacientes.</p>
                <button onclick="alert('Funcionalidad en desarrollo')" class="btn-primary">Ver Pacientes</button>
            </div>
        </div>
    </div>

    <!-- Modal para crear receta -->
    <div id="modalReceta" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>📋 Emitir Nueva Receta</h2>
                <span class="close" onclick="cerrarModalReceta()">&times;</span>
            </div>
            <form action="${pageContext.request.contextPath}/recetas" method="post">
                <input type="hidden" name="action" value="crear">

                <div class="form-row">
                    <div class="form-group">
                        <label for="pacienteId">ID del Paciente *</label>
                        <input type="number" id="pacienteId" name="pacienteId" required>
                    </div>
                    <div class="form-group">
                        <label for="pacienteNombre">Nombre del Paciente *</label>
                        <input type="text" id="pacienteNombre" name="pacienteNombre" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="diagnostico">Diagnóstico</label>
                    <input type="text" id="diagnostico" name="diagnostico"
                           placeholder="Ej: Gripe común, Hipertensión...">
                </div>

                <div class="form-group">
                    <label for="medicamento">Medicamento *</label>
                    <input type="text" id="medicamento" name="medicamento"
                           placeholder="Ej: Paracetamol 500mg" required>
                </div>

                <div class="form-group">
                    <label for="dosis">Dosis</label>
                    <input type="text" id="dosis" name="dosis"
                           placeholder="Ej: 1 tableta cada 8 horas">
                </div>

                <div class="form-group">
                    <label for="indicaciones">Indicaciones</label>
                    <textarea id="indicaciones" name="indicaciones"
                              placeholder="Indicaciones adicionales para el paciente..."></textarea>
                </div>

                <button type="submit" class="btn-primary" style="width: 100%; padding: 14px;">
                    Emitir Receta
                </button>
            </form>
        </div>
    </div>

    <script>
        function abrirModalReceta() {
            document.getElementById('modalReceta').style.display = 'block';
        }

        function cerrarModalReceta() {
            document.getElementById('modalReceta').style.display = 'none';
        }

        function descargarReceta(recetaId) {
            alert('Descargando receta #' + recetaId + '...\n\nEsta funcionalidad generará un PDF de la receta.');
        }

        window.onclick = function(event) {
            const modal = document.getElementById('modalReceta');
            if (event.target == modal) {
                cerrarModalReceta();
            }
        }
    </script>
</body>
</html>

