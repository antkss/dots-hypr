import Notifd from "gi://AstalNotifd"
import { App } from "astal/gtk3"

const { Gtk, GLib } = imports.gi;
const notifd = Notifd.get_default()

App.start({
    main: () => {
	notifd.connect("notified", (_, id) => {
	const n = notifd.get_notification(id)
	    print(n.summary, n.body)
	})
    }

})
