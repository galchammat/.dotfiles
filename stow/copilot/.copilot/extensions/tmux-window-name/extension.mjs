/**
 * tmux-window-name
 *
 * Renames the tmux window that hosts the Copilot CLI so it always matches the
 * current Copilot session name. Fires whenever the session title changes:
 *   - a new session is auto-named after the first exchange
 *   - the session is renamed with /rename
 *   - a resumed session's name is (re)applied on start
 *
 * No-op when not running inside tmux.
 */
import { joinSession } from "@github/copilot-sdk/extension";
import { execFile } from "node:child_process";
import { appendFileSync } from "node:fs";

const TMUX = process.env.TMUX;
const PANE = process.env.TMUX_PANE; // e.g. "%3" — identifies our window's pane
const DEBUG = !!process.env.COPILOT_TMUX_TITLE_DEBUG;

function debug(msg) {
  if (!DEBUG) return;
  try {
    appendFileSync(
      new URL("./debug.log", import.meta.url),
      `${new Date().toISOString()} ${msg}\n`,
    );
  } catch {}
}

/** Collapse whitespace/control chars so the name is a clean single line. */
function sanitize(title) {
  return String(title ?? "")
    .replace(/[\r\n\t]+/g, " ")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, 200);
}

let lastName;

function renameTmuxWindow(title) {
  if (!TMUX || !PANE) return; // not inside tmux
  const name = sanitize(title);
  if (!name || name === lastName) return;
  lastName = name;
  // Target the window by our pane id so we rename the right window even when
  // it is not the active one. execFile (no shell) keeps the name literal.
  execFile("tmux", ["rename-window", "-t", PANE, name], (err) => {
    if (err) debug(`rename failed: ${err.message}`);
    else debug(`renamed window to: ${name}`);
  });
}

const session = await joinSession({});

debug(`joined session ${session.sessionId}; TMUX=${!!TMUX} PANE=${PANE}`);

// Live updates: fires on auto-naming, /rename, and any mid-session name change.
session.on("session.title_changed", (event) => {
  debug(`title_changed: ${JSON.stringify(event.data)}`);
  renameTmuxWindow(event.data?.title);
});

// Initial sync: title_changed does NOT fire on resume, so pull the current
// name once on join. Covers startup and resuming an already-named session.
// A brand-new, unnamed session returns null here — we leave the window as-is
// until it gets auto-named (which arrives via title_changed).
if (TMUX && PANE) {
  try {
    const { name } = await session.rpc.name.get();
    debug(`initial name.get: ${JSON.stringify(name)}`);
    if (name) renameTmuxWindow(name);
  } catch (err) {
    debug(`initial name.get failed: ${err?.message ?? err}`);
  }
}
