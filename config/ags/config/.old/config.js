#!/usr/bin/ags run
import { App, Astal, Gtk, Gdk,Widget } from "astal/gtk3"

const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
const { IGNORE, TRUE } = Astal.Exclusivity
const { EXCLUSIVE } = Astal.Keymode
const { CENTER } = Gtk.Align
import { exec, readFile, timeout } from "astal"
import Battery from "gi://AstalBattery"
const battery = Battery.get_default()
import Mpris from "gi://AstalMpris"
const spotify = Mpris.Player.new("firefox")
function spoti(){
    if (spotify.available)
	return spotify.title
    return "No media"
}

function left() {
    return <box>
	 <label
	    className="txt-title"
	    label={spoti()}/>
	</box>
}
function Bar(monitor = 0) {
    // const windows = new Astal.Window({
    // })
    // return windows
    return <window 
    exclusivity={EXCLUSIVE}
    className="bar txt-title"
    // keymode={EXCLUSIVE}
    anchor={TOP}
    monitor={monitor}>
	    <centerbox>
		<box>
		</box>    
	    </centerbox>    
    </window>
}
App.apply_css("./style.css")
App.start({
    instanceName: "tmp" + Date.now(),
    gtkTheme: "adw-gtk3-dark",
    main: () => {
	Bar(0);
	
    }
})
