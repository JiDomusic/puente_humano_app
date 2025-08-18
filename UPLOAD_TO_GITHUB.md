# 🚀 Subir PuenteHumano a GitHub

## OPCIÓN 1: Crear repositorio desde web

1. **Ve a**: https://github.com/JiDomusic
2. **Clic en "New"** (botón verde)
3. **Repository name**: `puente-humano-app`
4. **Description**: `Un puente humano para que los libros lleguen a donde más se necesitan`
5. **✅ Public**
6. **❌ NO marques** "Add a README file"
7. **Clic en "Create repository"**

Después ejecuta estos comandos:

```bash
cd /home/jido/puente_humano_app

# Ya está configurado, solo subir:
git push -u origin main
```

## OPCIÓN 2: Si prefieres hacerlo manual

1. **Crea el repositorio** en https://github.com/JiDomusic
2. **Copia esta URL** cuando se cree: `https://github.com/JiDomusic/puente-humano-app.git`
3. **Ejecuta**:

```bash
git remote set-url origin https://github.com/JiDomusic/puente-humano-app.git
git push -u origin main
```

## 🔑 Si pide contraseña:

GitHub ya no acepta contraseñas. Necesitas un **Personal Access Token**:

1. Ve a: https://github.com/settings/tokens
2. Clic en "Generate new token (classic)"
3. Scope: `repo` (marcar todas las opciones de repo)
4. Copia el token generado
5. Úsalo como contraseña cuando git te lo pida

## ✅ Resultado final:

Tu proyecto estará en: `https://github.com/JiDomusic/puente-humano-app`

Con:
- 📱 App Flutter completa  
- 🔥 Configuración Supabase
- 📖 Documentación
- 🚀 Listo para usar