#!/bin/bash
# ============================================================
# EcoHome Flutter — setup automático para conectar a localhost
# Ejecutar UNA VEZ desde la carpeta flutter-app/
#   chmod +x setup.sh && ./setup.sh
# ============================================================
set -e

cd "$(dirname "$0")"

echo "→ 1. Generando plataformas nativas (android/ios/web)..."
if [ ! -d "android" ]; then
  flutter create .
else
  echo "  android/ ya existe — se salta flutter create"
fi

echo "→ 2. flutter pub get"
flutter pub get

# ──────────────── ANDROID ────────────────
ANDROID_MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$ANDROID_MANIFEST" ]; then
  echo "→ 3. Habilitando cleartext HTTP en AndroidManifest.xml..."
  # Permiso INTERNET (idempotente)
  if ! grep -q "android.permission.INTERNET" "$ANDROID_MANIFEST"; then
    sed -i.bak 's|<application|<uses-permission android:name="android.permission.INTERNET"/>\n    <application|' "$ANDROID_MANIFEST"
  fi
  # usesCleartextTraffic (idempotente)
  if ! grep -q "usesCleartextTraffic" "$ANDROID_MANIFEST"; then
    sed -i.bak 's|<application|<application android:usesCleartextTraffic="true"|' "$ANDROID_MANIFEST"
    # quitar duplicado si quedó <application <application
    sed -i.bak 's|<application <application|<application|' "$ANDROID_MANIFEST"
  fi
  rm -f "${ANDROID_MANIFEST}.bak"
  echo "  OK"
else
  echo "  (no se encontró $ANDROID_MANIFEST — flutter create falló?)"
fi

# ──────────────── iOS ────────────────
IOS_PLIST="ios/Runner/Info.plist"
if [ -f "$IOS_PLIST" ]; then
  echo "→ 4. Habilitando NSAllowsLocalNetworking en Info.plist..."
  if ! grep -q "NSAppTransportSecurity" "$IOS_PLIST"; then
    /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity dict" "$IOS_PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSAllowsArbitraryLoads bool true" "$IOS_PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSAllowsLocalNetworking bool true" "$IOS_PLIST" 2>/dev/null || true
  fi
  echo "  OK"
else
  echo "  (no se encontró $IOS_PLIST — solo aplica si tienes Xcode)"
fi

echo ""
echo "════════════════════════════════════════════════════"
echo " ✅ Listo. Ahora:"
echo "  1. Asegúrate de tener el backend corriendo:"
echo "       cd ../ecohome-backend && npm run dev"
echo "  2. Lanza un emulador (Android Studio / Simulator)"
echo "  3. Corre la app:"
echo "       flutter run"
echo "════════════════════════════════════════════════════"
