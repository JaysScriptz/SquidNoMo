# Hotfix 2

- Added the missing `App:CreateThreeColumnRow` method that prevented Home from building.
- Changed the support QR viewport to a large square area.
- Reduced QR image padding from 12 px to 4 px.
- Enabled pixelated resampling when supported.
- Rebuilt PayPalQR from the original uploaded QR crop rather than a generated QR pattern.
- Made CashAppQR perfectly square without altering its QR modules.
