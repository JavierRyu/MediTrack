# ⚡ Guía Rápida de Configuración - MediTrack

## ✅ Buenas Noticias

**¡NO necesitas instalar ni configurar base de datos!**

Este proyecto usa H2 Database (base de datos embebida) que:
- ✅ Se crea automáticamente al ejecutar
- ✅ No requiere instalación
- ✅ No necesita configuración
- ✅ Usuario admin creado automáticamente

---

## Paso 1: Compilar el Proyecto (Opcional)

Ya está compilado ✅, pero si necesitas recompilar:

```bash
mvn clean install
```

---

## Paso 2: Configurar Tomcat en IntelliJ

### En IntelliJ IDEA:
1. **Run → Edit Configurations**
2. Click en **"+"** → **Tomcat Server** → **Local**
3. **Server tab:**
   - Name: `Tomcat - MediTrack`
   - Application Server: Click **Configure...** y selecciona tu Tomcat
   - HTTP port: `8080`
4. **Deployment tab:**
   - Click en **"+"** → **Artifact**
   - Selecciona: `MediTrack:war exploded`
   - Application context: `/MediTrack`
5. Click en **OK**

---

## Paso 3: Ejecutar la Aplicación

1. Click en el botón **Run** (play verde ▶️)
2. Espera que Tomcat inicie
3. Verás en la consola:
   ```
   ✅ Base de datos H2 inicializada correctamente
   ✅ Usuario admin creado: admin@meditrack.com / admin123
   ```
4. Se abrirá automáticamente: `http://localhost:8080/MediTrack/`

---

## Paso 4: Acceder a la Aplicación

**URL:** http://localhost:8080/MediTrack/

### 🔐 Usuario Admin (ya creado automáticamente):
- **Email:** admin@meditrack.com
- **Password:** admin123

### 📝 Crear nuevo usuario:
- Click en "Regístrate aquí"
- Completa el formulario
- Inicia sesión con tu nuevo usuario

---

## 📂 Estructura de URLs

- `/login` - Página de login
- `/register` - Página de registro
- `/views/dashboard.jsp` - Dashboard (requiere login)
- `/logout` - Cerrar sesión

---

## 🗄️ Base de Datos H2

**Información técnica:**
- **Tipo:** H2 Database (Embebida)
- **Ubicación:** `~/meditrack.mv.db` (carpeta de usuario)
- **Usuario:** sa
- **Contraseña:** (vacía)
- **Creación:** Automática al iniciar la aplicación
- **Persistencia:** Los datos se guardan entre ejecuciones

**Datos incluidos:**
- Tabla `usuarios` creada automáticamente
- Usuario admin pre-configurado
- Índice en campo email

---

## 🎯 Resumen Ultra Rápido

1. ✅ Proyecto ya compilado
2. ✅ Configurar Tomcat en IntelliJ (2 minutos)
3. ✅ Click en Run ▶️
4. ✅ Abrir: http://localhost:8080/MediTrack/
5. ✅ Login: admin@meditrack.com / admin123
6. 🎉 **¡Funciona!**

---

## 🐛 Solución de Problemas

### ❌ Error 404: "Not Found"
**Solución:** Verifica que la URL sea exactamente:
```
http://localhost:8080/MediTrack/
```
(Con 'M' y 'T' mayúsculas)

### ❌ "Port 8080 is already in use"
**Solución:** 
- Detén cualquier otra aplicación en el puerto 8080
- O cambia el puerto en la configuración de Tomcat

### ❌ Error al compilar
**Solución:** 
1. Ejecuta: `mvn clean install`
2. En IntelliJ: File → Invalidate Caches → Restart

---

## 💡 Ventajas de H2

- ✅ **Cero configuración** - No necesitas instalar nada
- ✅ **Automático** - Base de datos creada al iniciar
- ✅ **Rápido** - Perfecto para desarrollo
- ✅ **Portátil** - Solo un archivo de datos
- ✅ **Persistente** - Los datos no se pierden

---

**¡Todo listo en menos de 5 minutos! 🚀**


