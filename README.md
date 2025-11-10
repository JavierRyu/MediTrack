# MediTrack - Sistema de Gestión Médica

## 📋 Requisitos Previos

- Java JDK 17 o superior
- Apache Tomcat 9.0 o superior
- Maven 3.6 o superior

**¡NO necesitas instalar MySQL!** El proyecto usa H2 Database (base de datos embebida).

## 🚀 Configuración del Proyecto

### 1. Compilar el Proyecto

Abre una terminal en la raíz del proyecto y ejecuta:

```bash
mvn clean install
```

### 2. Desplegar en Tomcat

#### Opción A: Desde IntelliJ IDEA (Recomendado)
1. Configura un servidor Tomcat en Run → Edit Configurations
2. Añade una nueva configuración de Tomcat Server (Local)
3. En el tab "Deployment", añade el artefacto `MediTrack:war exploded`
4. Application context: `/MediTrack`
5. Ejecuta el servidor

#### Opción B: Manual
1. Copia el archivo WAR generado en `target/MediTrack.war`
2. Pégalo en la carpeta `webapps` de tu instalación de Tomcat
3. Inicia Tomcat

### 3. Acceder a la Aplicación

Abre tu navegador y visita:
```
http://localhost:8080/MediTrack/
```

Serás redirigido automáticamente a la página de login.

## 🗄️ Base de Datos

El proyecto usa **H2 Database** (base de datos embebida):
- ✅ **Se crea automáticamente** al iniciar la aplicación
- ✅ **No requiere instalación** ni configuración
- ✅ **Usuario admin creado automáticamente**
- ✅ Archivo de datos: `~/meditrack.mv.db`

Cuando ejecutes la aplicación por primera vez, verás en la consola:
```
✅ Base de datos H2 inicializada correctamente
✅ Usuario admin creado: admin@meditrack.com / admin123
```

## 👤 Usuarios de Prueba

### Usuario Admin (creado automáticamente)
- **Email:** admin@meditrack.com
- **Contraseña:** admin123

## 📁 Estructura del Proyecto

```
MediTrack/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/meditrack/
│   │   │       ├── controller/      # Servlets
│   │   │       ├── dao/             # Data Access Objects
│   │   │       ├── model/           # Modelos de datos
│   │   │       ├── service/         # Lógica de negocio
│   │   │       └── util/            # Utilidades (incluye DB)
│   │   ├── resources/
│   │   └── webapp/
│   │       ├── views/               # Páginas JSP
│   │       ├── WEB-INF/
│   │       └── index.jsp
│   └── test/
└── pom.xml                          # Configuración Maven
```

## 🔐 Funcionalidades Implementadas

### Sistema de Autenticación
- ✅ Registro de usuarios con validación
- ✅ Login con email y contraseña
- ✅ Encriptación de contraseñas con BCrypt
- ✅ Gestión de sesiones
- ✅ Logout seguro

### Validaciones
- ✅ Email único
- ✅ Contraseña mínima de 6 caracteres
- ✅ Validación de formato de email
- ✅ Confirmación de contraseña en registro
- ✅ Campos obligatorios

## 🛠️ Tecnologías Utilizadas

- **Backend:** Java 17, Servlets, JSP
- **Base de Datos:** H2 Database (Embebida)
- **Seguridad:** BCrypt para hash de contraseñas
- **Build Tool:** Maven
- **Servidor:** Apache Tomcat
- **Frontend:** HTML, CSS, JavaScript (JSP)

## 📝 Endpoints Disponibles

- `GET/POST /login` - Página de inicio de sesión
- `GET/POST /register` - Página de registro
- `GET /logout` - Cerrar sesión
- `/views/dashboard.jsp` - Panel de control (requiere autenticación)

## 🐛 Solución de Problemas

### Error 404
- Verifica que Tomcat esté corriendo
- Comprueba la URL: debe ser `/MediTrack/` (con mayúscula inicial)

### Las contraseñas no funcionan
- Verifica que la librería BCrypt esté en el classpath
- Ejecuta `mvn clean install` nuevamente

### La base de datos no se crea
- Verifica que tengas permisos de escritura en tu carpeta de usuario
- Revisa la consola de Tomcat para ver mensajes de error

## 📧 Contacto

Para reportar errores o sugerencias, abre un issue en el repositorio.

## 📄 Licencia

Este proyecto es parte de un sistema educativo de gestión médica.



