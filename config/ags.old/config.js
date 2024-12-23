"use strict";
// Import
import Gdk from 'gi://Gdk';
import GLib from 'gi://GLib';
import App from 'resource:///com/github/Aylur/ags/app.js'
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js'
// import  {Recent} from './a.js';
// import center from './center/center.js'
// Widgets
import userOptions from './modules/.configuration/user_options.js';
import { Bar } from './modules/bar/main.js';
// import Cheatsheet from './modules/cheatsheet/main.js';
// import DesktopBackground from './modules/desktopbackground/main.js';
// import Dock from './modules/dock/main.js';
// import side_utils from './modules/sideleft/utils.js'
// import Corner from './modules/screencorners/main.js';
import Indicator from './modules/indicators/main.js';
// import Osk from './modules/onscreenkeyboard/main.js';
// import Overview from './modules/overview/main.js';
import Session from './modules/session/main.js';
import side_chat from './modules/sideleft/main.js';
// import SideRight from './modules/sideright/main.js';
// import Lockscreen from './modules/lockscreen/main.js';

// const COMPILED_STYLE_DIR = `${GLib.get_user_cache_dir()}/ags/user/generated`
const range = (length, start = 1) => Array.from({ length }, (_, i) => i + start);
function forMonitors(widget) {
    const n = Gdk.Display.get_default()?.get_n_monitors() || 1;
    return range(n, 0).map(widget).flat(1);
}
const Windows = () => [
	// Lockscreen(),
	// Overview(),
	forMonitors(Indicator),
	side_chat(),
	// side_utils(),
	// Osk(),
	Session(),

];


App.config({
    style: `${App.configDir}/style.css`,
    // stackTraceOnError: true,
    windows: Windows().flat(1),
});

forMonitors(Bar);

