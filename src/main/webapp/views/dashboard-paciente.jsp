<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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

        .info-box {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            padding: 25px;
            border-radius: 12px;
            border-left: 4px solid #667eea;
            margin-bottom: 25px;
        }

        .info-box h3 {
            color: #333;
            margin-bottom: 10px;
            font-size: 18px;
        }

        .info-box p {
            color: #555;
            font-size: 14px;
            line-height: 1.6;
        }

        .receta-list {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
        }

        .receta-item {
            padding: 20px;
            border: 2px solid #f0f0f0;
            border-radius: 10px;
            margin-bottom: 15px;
            transition: all 0.3s;
        }

        .receta-item:hover {
            border-color: #667eea;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.1);
        }

        .receta-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }

        .receta-title {
            font-weight: 600;
            color: #333;
            font-size: 16px;
        }

        .receta-date {
            color: #888;
            font-size: 13px;
        }

        .receta-content {
            color: #666;
            font-size: 14px;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-brand">
            <span>🤒</span>
            <span>MediTrack - Portal del Paciente</span>
        </div>
        <div class="navbar-user">
            <div class="user-info">
                <div class="user-avatar">
                    ${sessionScope.usuarioNombre.substring(0,1).toUpperCase()}
                </div>
                <div class="user-details">
                    <div class="user-name">${sessionScope.usuarioNombre}</div>
                    <div class="user-role">Paciente</div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Cerrar Sesión</a>
        </div>
    </nav>

    <div class="container">
        <div class="welcome-card">
            <h1>¡Bienvenido/a, ${sessionScope.usuarioNombre}!</h1>
            <p>Accede a tus recetas médicas y gestiona tu información de salud.</p>
        </div>

        <div class="info-box">
            <h3>📋 Tu ID de Paciente</h3>
            <p><strong>ID: ${sessionScope.usuarioId}</strong> - Proporciona este ID a tu médico cuando necesites una receta.</p>
        </div>

        <div class="cards-grid">
            <div class="feature-card">
                <div class="feature-icon">💊</div>
                <h3>Mis Recetas</h3>
                <p>Consulta y descarga todas tus recetas médicas emitidas por tus doctores.</p>
                <button onclick="verRecetas()" class="btn-primary">Ver Recetas</button>
            </div>

            <div class="feature-card">
                <div class="feature-icon">📅</div>
                <h3>Mis Citas</h3>
                <p>Revisa tus próximas citas médicas programadas.</p>
                <button onclick="alert('Funcionalidad en desarrollo')" class="btn-primary">Ver Citas</button>
            </div>

            <div class="feature-card">
                <div class="feature-icon">📊</div>
                <h3>Historial Médico</h3>
                <p>Accede a tu historial médico completo y registros de salud.</p>
                <button onclick="alert('Funcionalidad en desarrollo')" class="btn-primary">Ver Historial</button>
            </div>
        </div>

        <div class="receta-list" id="recetasList" style="display: none;">
            <h2 style="margin-bottom: 20px; color: #333;">📋 Mis Recetas Médicas</h2>
            <div class="receta-item">
                <div class="receta-header">
                    <div class="receta-title">No hay recetas disponibles</div>
                </div>
                <div class="receta-content">
                    <p>Aún no tienes recetas médicas emitidas. Cuando tu médico emita una receta, aparecerá aquí.</p>
                </div>
            </div>
        </div>
    </div>

    <script>
        function verRecetas() {
            const lista = document.getElementById('recetasList');
            if (lista.style.display === 'none') {
                lista.style.display = 'block';
                lista.scrollIntoView({ behavior: 'smooth' });
            } else {
                lista.style.display = 'none';
            }
        }
    </script>
</body>
</html>

