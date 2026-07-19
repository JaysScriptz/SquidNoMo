SquidNoMo Mobile Hotfix 3

Changes:
- Mobile design width increased from 1100 to 1225.
- Mobile safe margins reduced so the app uses nearly the full display.
- Mobile window scaling increased and the topbar enlarged.
- Window can move across the complete viewport, including partially toward edges,
  while always retaining at least 150 visible pixels.
- Added large drag zones to the main topbar and sidebar logo/header.
- Support popup header can drag the complete app window.
- Rebuilt the caution screen as a larger, exactly centered modal.
- Caution text is complete, larger, and placed inside a high-contrast card.
- Acceptance is now a full-width touch row.
- EXIT and CONTINUE buttons are larger.
- Caution header can drag the complete app window.

Runtime note:
The package was structurally verified here. Final visual and touch behavior must still
be tested in the actual Roblox/Delta mobile runtime.
