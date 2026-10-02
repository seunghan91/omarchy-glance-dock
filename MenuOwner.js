.pragma library

// Shared by every bar instance (one per monitor): only one context menu may
// be open at a time, so opening one closes the menu another bar left open.
var owner = null

function claim(dock) {
  if (owner && owner !== dock) {
    try { owner.closeMenu() } catch (e) { /* that bar is gone */ }
  }
  owner = dock
}

function release(dock) {
  if (owner === dock) owner = null
}
