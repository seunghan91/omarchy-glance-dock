.pragma library

// Shared by every bar instance (one per monitor): only one context menu may
// be open at a time, so opening one closes the menu another bar left open.
// Every other bar is told a menu is open elsewhere (remoteMenuOpen), so it
// can catch a click on its own screen and close that menu, like macOS does.
var owner = null
var docks = []

function notify() {
  for (var i = 0; i < docks.length; i++) {
    try { docks[i].remoteMenuOpen = owner !== null && docks[i] !== owner }
    catch (e) { /* that bar is gone */ }
  }
}

function register(dock) {
  if (docks.indexOf(dock) === -1) docks.push(dock)
  notify()
}

function unregister(dock) {
  var i = docks.indexOf(dock)
  if (i !== -1) docks.splice(i, 1)
  if (owner === dock) owner = null
  notify()
}

function claim(dock) {
  if (owner && owner !== dock) {
    try { owner.closeMenu() } catch (e) { /* that bar is gone */ }
  }
  owner = dock
  notify()
}

function release(dock) {
  if (owner === dock) owner = null
  notify()
}

function closeOwner() {
  if (!owner) return
  try { owner.closeMenu() } catch (e) { owner = null; notify() }
}
