#!/bin/bash

# 🔧 Script para configurar el alias global 'meypark'
# =================================================

echo "🔧 Configurando alias global 'meypark'..."

# Crear el alias en .bashrc si no existe
if ! grep -q "alias meypark" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# MEYPARK - Alias para lanzar el ecosistema completo" >> ~/.bashrc
    echo "alias meypark='/home/i-d/flutter_projects/mi_nuevo_proyecto/meypark'" >> ~/.bashrc
    echo "✅ Alias 'meypark' agregado a ~/.bashrc"
else
    echo "ℹ️  El alias 'meypark' ya existe en ~/.bashrc"
fi

# Aplicar el alias en la sesión actual
alias meypark='/home/i-d/flutter_proyecto/mi_nuevo_proyecto/meypark'

echo ""
echo "🎉 ¡Configuración completada!"
echo ""
echo "📋 Instrucciones de uso:"
echo "========================"
echo "• Para usar AHORA: meypark"
echo "• Para usar después de reiniciar terminal: meypark"
echo ""
echo "🚀 El comando 'meypark' lanzará:"
echo "  ✅ Flutter Linux App"
echo "  ✅ Backend WebSocket (puerto 3003)"
echo "  ✅ Servidor Facturación (puerto 3002)"
echo "  ✅ Dashboard Web (puerto 8080)"
echo "  ✅ Mock Backend (puerto 8082)"
echo ""
echo "🌐 URLs de acceso:"
echo "  • Dashboard: http://localhost:8080/dashboard.html"
echo "  • Facturación: http://localhost:8080/facturacion.html"
echo "  • Kiosco: http://localhost:8080/kiosco.html"
echo ""
echo "🛑 Para detener todo: ./stop_all.sh"
