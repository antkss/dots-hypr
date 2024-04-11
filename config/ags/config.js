"use strict";
// Import
import Gdk from 'gi://Gdk';
import GLib from 'gi://GLib';
import App from 'resource:///com/github/Aylur/ags/app.js'
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js'
// import  {Recent} from './a.js';
import center from './center/center.js'
// Widgets
import userOptions from './modules/.configuration/user_options.js';
import { Bar, BarCornerTopleft, BarCornerTopright } from './modules/bar/main.js';
import Cheatsheet from './modules/cheatsheet/main.js';
// import DesktopBackground from './modules/desktopbackground/main.js';
// import Dock from './modules/dock/main.js';
import side_utils from './modules/sideleft/utils.js'
import Corner from './modules/screencorners/main.js';
import Indicator from './modules/indicators/main.js';
import Osk from './modules/onscreenkeyboard/main.js';
import Overview from './modules/overview/main.js';
import Session from './modules/session/main.js';
import side_chat from './modules/sideleft/main.js';
// import SideRight from './modules/sideright/main.js';

const COMPILED_STYLE_DIR = `${GLib.get_user_cache_dir()}/ags/user/generated`
const range = (length, start = 1) => Array.from({ length }, (_, i) => i + start);
function forMonitors(widget) {
    const n = Gdk.Display.get_default()?.get_n_monitors() || 1;
    return range(n, 0).map(widget).flat(1);
}
function forMonitorsAsync(widget) {
    const n = Gdk.Display.get_default()?.get_n_monitors() || 1;
    return range(n, 0).forEach((n) => widget().catch(print))
}
// SCSS compilation
Utils.exec(`bash -c 'echo "" > ${App.configDir}/scss/_musicwal.scss'`); // reset music styles
Utils.exec(`bash -c 'echo "" > ${App.configDir}/scss/_musicmaterial.scss'`); // reset music styles
async function applyStyle() {
    Utils.exec(`mkdir -p ${COMPILED_STYLE_DIR}`);
    Utils.exec(`sass ${App.configDir}/scss/main.scss ${COMPILED_STYLE_DIR}/style.css`);
    // App.resetCss();
    App.applyCss(`${COMPILED_STYLE_DIR}/style.css`);
    console.log('[LOG] Styles loaded')
}
applyStyle().catch(print);

const Windows = () => [
    // forMonitors(DesktopBackground),
    // Dock(),
    Overview(),
    forMonitors(Indicator),
    // Cheatsheet(),
	center(0),
    side_chat(),
	side_utils(),
    // SideRight(),
	// Recent(),
    Osk(),
    Session(),
    // forMonitors(Bar),
    // forMonitors(BarCornerTopleft),
    // forMonitors(BarCornerTopright),
    forMonitors((id) => Corner(id, 'top left')),
    forMonitors((id) => Corner(id, 'top right')),
	forMonitors(BarCornerTopleft),
	forMonitors(BarCornerTopright),
    // forMonitors((id) => Corner(id, 'bottom left')),
    // forMonitors((id) => Corner(id, 'bottom right')),
];

// const CLOSE_ANIM_TIME = 150; // Longer than actual anim time to make sure widgets animate fully
// const closeWindowDelays = {}; // For animations
// for(let i = 0; i < (Gdk.Display.get_default()?.get_n_monitors() || 1); i++) {
//     closeWindowDelays[`osk${i}`] = CLOSE_ANIM_TIME;
// }
App.config({
    css: `${COMPILED_STYLE_DIR}/style.css`,
    stackTraceOnError: true,
    windows: Windows().flat(1),
});

// Stuff that don't need to be toggled. And they're async so ugh...
// Bar().catch(print); // Use this to debug the bar. Single monitor only.
// BarCornerTopleft().catch(print); // Use this to debug the bar. Single monitor only.
// BarCornerTopright().catch(print); // Use this to debug the bar. Single monitor only.
// forMonitors(Bar);
forMonitorsAsync(Bar);

