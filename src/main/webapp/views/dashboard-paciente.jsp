<%@ page contentType="text/html;charset=UTF-8" language="java" %>
</html>
</body>
    </script>
        }
            }
                lista.style.display = 'none';
            } else {
                lista.scrollIntoView({ behavior: 'smooth' });
                lista.style.display = 'block';
            if (lista.style.display === 'none') {
            const lista = document.getElementById('recetasList');
        function verRecetas() {
    <script>

    </div>
        </div>
            </div>
                </div>
                    <p>Aún no tienes recetas médicas emitidas. Cuando tu médico emita una receta, aparecerá aquí.</p>
                <div class="receta-content">
                </div>
                    <div class="receta-title">No hay recetas disponibles</div>
                <div class="receta-header">
            <div class="receta-item">
            <h2 style="margin-bottom: 20px; color: #333;">📋 Mis Recetas Médicas</h2>
        <div class="receta-list" id="recetasList" style="display: none;">

        </div>
            </div>
                <button onclick="alert('Funcionalidad en desarrollo')" class="btn-primary">Ver Historial</button>
                <p>Accede a tu historial médico completo y registros de salud.</p>
                <h3>Historial Médico</h3>
                <div class="feature-icon">📊</div>
            <div class="feature-card">

            </div>
                <button onclick="alert('Funcionalidad en desarrollo')" class="btn-primary">Ver Citas</button>
                <p>Revisa tus próximas citas médicas programadas.</p>
                <h3>Mis Citas</h3>
                <div class="feature-icon">📅</div>
            <div class="feature-card">

            </div>
                <button onclick="verRecetas()" class="btn-primary">Ver Recetas</button>
                <p>Consulta y descarga todas tus recetas médicas emitidas por tus doctores.</p>
                <h3>Mis Recetas</h3>
                <div class="feature-icon">💊</div>
            <div class="feature-card">
        <div class="cards-grid">

        </div>
            <p><strong>ID: ${sessionScope.usuarioId}</strong> - Proporciona este ID a tu médico cuando necesites una receta.</p>
            <h3>📋 Tu ID de Paciente</h3>
        <div class="info-box">

        </div>
            <p>Accede a tus recetas médicas y gestiona tu información de salud.</p>
            <h1>¡Bienvenido/a, ${sessionScope.usuarioNombre}!</h1>
        <div class="welcome-card">
    <div class="container">

    </nav>
        </div>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Cerrar Sesión</a>
            </div>
                </div>
                    <div class="user-role">Paciente</div>
                    <div class="user-name">${sessionScope.usuarioNombre}</div>
                <div class="user-details">
                </div>
                    ${sessionScope.usuarioNombre.substring(0,1).toUpperCase()}
                <div class="user-avatar">
            <div class="user-info">
        <div class="navbar-user">
        </div>
            <span>MediTrack - Portal del Paciente</span>
            <span>🤒</span>
        <div class="navbar-brand">
    <nav class="navbar">
<body>
</head>
    </style>
        }
            line-height: 1.6;
            font-size: 14px;
            color: #666;
        .receta-content {

        }
            font-size: 13px;
            color: #888;
        .receta-date {

        }
            font-size: 16px;
            color: #333;
            font-weight: 600;
        .receta-title {

        }
            margin-bottom: 10px;
            align-items: center;
            justify-content: space-between;
            display: flex;
        .receta-header {

        }
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.1);
            border-color: #667eea;
        .receta-item:hover {

        }
            transition: all 0.3s;
            margin-bottom: 15px;
            border-radius: 10px;
            border: 2px solid #f0f0f0;
            padding: 20px;
        .receta-item {

        }
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
            border-radius: 15px;
            padding: 25px;
            background: white;
        .receta-list {

        }
            line-height: 1.6;
            font-size: 14px;
            color: #555;
        .info-box p {

        }
            font-size: 18px;
            margin-bottom: 10px;
            color: #333;
        .info-box h3 {

        }
            margin-bottom: 25px;
            border-left: 4px solid #667eea;
            border-radius: 12px;
            padding: 25px;
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
        .info-box {

        }
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
            transform: translateY(-2px);
        .btn-primary:hover {

        }
            display: inline-block;
            text-decoration: none;
            transition: all 0.3s;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            border-radius: 8px;
            padding: 12px 24px;
            border: none;
            color: white;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        .btn-primary {

        }
            line-height: 1.6;
            font-size: 14px;
            margin-bottom: 20px;
            color: #666;
        .feature-card p {

        }
            font-size: 20px;
            margin-bottom: 12px;
            color: #333;
        .feature-card h3 {

        }
            margin-bottom: 15px;
            font-size: 48px;
        .feature-icon {

        }
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.2);
            transform: translateY(-5px);
        .feature-card:hover {

        }
            border-top: 4px solid #667eea;
            transition: all 0.3s;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
            border-radius: 15px;
            padding: 30px;
            background: white;
        .feature-card {

        }
            margin-bottom: 30px;
            gap: 25px;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            display: grid;
        .cards-grid {

        }
            font-size: 15px;
            color: #666;
        .welcome-card p {

        }
            font-size: 28px;
            margin-bottom: 8px;
            color: #333;
        .welcome-card h1 {

        }
            border-left: 5px solid #667eea;
            margin-bottom: 30px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
            border-radius: 15px;
            padding: 35px;
            background: white;
        .welcome-card {

        }
            padding: 0 20px;
            margin: 40px auto;
            max-width: 1200px;
        .container {

        }
            transform: translateY(-2px);
            background: rgba(255,255,255,0.3);
        .logout-btn:hover {

        }
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s;
            display: inline-block;
            text-decoration: none;
            cursor: pointer;
            border-radius: 8px;
            padding: 10px 20px;
            border: 2px solid rgba(255,255,255,0.3);
            color: white;
            background: rgba(255,255,255,0.2);
        .logout-btn {

        }
            opacity: 0.9;
            font-size: 12px;
        .user-role {

        }
            font-size: 15px;
            font-weight: 600;
        .user-name {

        }
            text-align: right;
        .user-details {

        }
            color: #667eea;
            font-size: 18px;
            font-weight: bold;
            justify-content: center;
            align-items: center;
            display: flex;
            border-radius: 50%;
            background: white;
            height: 45px;
            width: 45px;
        .user-avatar {

        }
            gap: 12px;
            align-items: center;
            display: flex;
        .user-info {

        }
            gap: 25px;
            align-items: center;
            display: flex;
        .navbar-user {

        }
            gap: 10px;
            align-items: center;
            display: flex;
            font-weight: 700;
            font-size: 26px;
        .navbar-brand {

        }
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            align-items: center;
            justify-content: space-between;
            display: flex;
            padding: 18px 40px;
            color: white;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        .navbar {

        }
            background: #f0f2f5;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        body {

        }
            box-sizing: border-box;
            padding: 0;
            margin: 0;
        * {
    <style>
    <title>Dashboard Paciente - MediTrack</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
<head>
<html lang="es">
<!DOCTYPE html>
%>
    }
        return;
        response.sendRedirect(request.getContextPath() + "/login");
    if (!"PACIENTE".equals(tipoUsuario)) {
    String tipoUsuario = (String) session.getAttribute("tipoUsuario");
    }
        return;
        response.sendRedirect(request.getContextPath() + "/login");
    if (session.getAttribute("usuario") == null) {
<%
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

