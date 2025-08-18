# 🚀 Subir PuenteHumano a GitHub

## PASO 1: Crear repositorio en GitHub

1. Ve a: https://github.com/new
2. Repository name: `puente-humano-app`
3. Description: `Un puente humano para que los libros lleguen a donde más se necesitan`
4. ✅ Public
5. ❌ NO marques "Add a README file"
6. Clic en "Create repository"

## PASO 2: Conectar proyecto local

Reemplaza `TU-USUARIO` con tu nombre de usuario de GitHub:

```bash
cd /home/jido/puente_humano_app

# Conectar con GitHub
git remote add origin https://github.com/TU-USUARIO/puente-humano-app.git

# Cambiar rama a main
git branch -M main

# Subir código
git push -u origin main
```

## PASO 3: Verificar

Después de subir, ve a:
`https://github.com/TU-USUARIO/puente-humano-app`

Deberías ver:
- ✅ Código Flutter completo
- ✅ README.md con instrucciones
- ✅ Schema de Supabase
- ✅ 38 archivos commiteados

## 🔧 Si hay problemas:

### Error de autenticación:
```bash
# Configurar credenciales
git config --global user.name "Tu Nombre"
git config --global user.email "tu-email@gmail.com"
```

### Error de permisos:
- Usar token personal en lugar de contraseña
- Ve a GitHub → Settings → Developer settings → Personal access tokens

## 🎯 Resultado final:

Tu proyecto estará en GitHub con:
- 📱 App Flutter completa
- 🔗 Conexión a Supabase configurada
- 📖 Documentación incluida
- 🚀 Listo para colaborar o deploy