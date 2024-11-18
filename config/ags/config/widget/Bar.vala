
public static string truncate_text(string text, int length) {
    // Truncate if the text is too long
    if (text.length > length) {
        return text.substring(0, length)+"...  ";
    }
    // Pad manually with spaces if the text is too short
    else if (text.length < length) {
        int padding_length = length - text.length;
        // Use StringBuilder to create the padding
        var padding_builder = new GLib.StringBuilder();
        for (int i = 0; i < padding_length; i++) {
            padding_builder.append(" "); // Append a single space as a string
        }
        return text + padding_builder.str;
    }
    return text; // Text is already the desired length
}

class Workspaces : Gtk.Box {
    AstalHyprland.Hyprland hypr = AstalHyprland.get_default();
    public Workspaces() {
        hypr.notify["workspaces"].connect(sync);
        sync();
    }

    void sync() {
        foreach (var child in get_children())
            child.destroy();

        foreach (var ws in hypr.workspaces)
            add(button(ws));
    }

    Gtk.Button button(AstalHyprland.Workspace ws) {
	string num = ws.id.to_string();
	    if(ws.id<0){
		num = "s";
	    }
        var btn = new Gtk.Button() {
            visible = true,
	    label = num
        };
	var focused = hypr.focused_workspace == ws;
	if (focused) {
	    Astal.widget_set_class_names(btn, {"button-active"});
	} else {
	    Astal.widget_set_class_names(btn, {"button"});
	}
        hypr.notify["focused-workspace"].connect(() => {
	    focused = hypr.focused_workspace == ws;
            if (focused) {
                Astal.widget_set_class_names(btn, {"button-active"});
            } else {
                Astal.widget_set_class_names(btn, {"button"});
            }
        });

        // btn.clicked.connect(ws.focus);
        return btn;
    }
}

class FocusedClient : Gtk.Box {
    public FocusedClient() {
        Astal.widget_set_class_names(this, {"Focused"});
        AstalHyprland.get_default().notify["focused-client"].connect(sync);
        sync();
    }

    void sync() {
        foreach (var child in get_children())
            child.destroy();

        var client = AstalHyprland.get_default().focused_client;
        if (client == null)
            return;

        var label = new Gtk.Label(truncate_text(client.title,30)) { visible = true };
	Astal.widget_set_class_names(label,{"text"});
 //        // client.bind_property("title", label, "label", BindingFlags.SYNC_CREATE,()=>{
 //            var title = truncate_text(client.title,10);
	// });
	client.bind_property("title", label, "label", BindingFlags.SYNC_CREATE, (_, src, ref trgt) => {
            var title = truncate_text(client.title,30);
            trgt.set_string(title);
            return true;
        });
        add(label);
    }
}

class Media : Gtk.Box {
    AstalMpris.Mpris mpris = AstalMpris.get_default();

    public Media() {
        Astal.widget_set_class_names(this, {"Media"});
        mpris.notify["players"].connect(sync);
        sync();
    }
    Gtk.Button buttonT(string? icon,AstalMpris.Player player) {
	var btn = new Gtk.Button() {
	    visible = true,
	    label = player.playback_status == 1 ? "": ""
	};

	Astal.widget_set_class_names(btn, {"button-active"});
	btn.clicked.connect(() => {
	    // AstalMpris.PlaybackStatus lmao = player.playback_status;
	    player.play_pause();
	    btn.label = player.playback_status == 0 ? "": "";

	});
	return btn;
    }

    void sync() {
        foreach (var child in get_children())
            child.destroy();

        if (mpris.players.length() == 0) {
	    var label = new Gtk.Label(" ♫ Nothing Playing ") {visible = true };
	    Astal.widget_set_class_names(label, {"text"});
            add(label);
            return;
        }

        var player = mpris.players.nth_data(0);
        var label = new Gtk.Label(" - playing - "){ visible = true };
	Astal.widget_set_class_names(label, {"text"});
        var cover = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0) {
            valign = Gtk.Align.CENTER
        };

        Astal.widget_set_class_names(cover, {"Cover"});
        player.bind_property("title", label, "label", BindingFlags.SYNC_CREATE, (_, src, ref trgt) => {
            var title = truncate_text(player.title,20);
            var artist = player.artist;
            trgt.set_string(@"♫ $artist$title");
            return true;
        });

        var id = player.notify["cover-art"].connect(() => {
            var art = player.cover_art;
            Astal.widget_set_css(cover, @"background-image: url('$art')");
        });
	Astal.widget_set_class_names(label,{"text"});
        add(cover);
        add(label);
	add(buttonT(">",player));
        cover.destroy.connect(() => player.disconnect(id));

    }
}

class SysTray : Gtk.Box {
    HashTable<string, Gtk.Widget> items = new HashTable<string, Gtk.Widget>(str_hash, str_equal);
    AstalTray.Tray tray = AstalTray.get_default();

    public SysTray() {
        tray.item_added.connect(add_item);
        tray.item_removed.connect(remove_item);
    }

    void add_item(string id) {
        if (items.contains(id))
            return;

        var item = tray.get_item(id);

        var menu = item.create_menu();
        var btn = new Astal.Button();
        var icon = new Astal.Icon();
	// Astal.widget_set_css(icon, "background-color: transparent;");

        btn.clicked.connect(() => {
            if (menu != null)
                menu.popup_at_widget(this, Gdk.Gravity.SOUTH, Gdk.Gravity.NORTH, null);
        });

        btn.destroy.connect(() => {
            if (menu != null)
                menu.destroy();
        });

        item.bind_property("tooltip-markup", btn, "tooltip-markup", BindingFlags.SYNC_CREATE);
        item.bind_property("gicon", icon, "g-icon", BindingFlags.SYNC_CREATE);
        btn.add(icon);
	Astal.widget_set_class_names(btn,{"icon"});
        add(btn);
        items.set(id, btn);
        btn.show_all();
    }

    void remove_item(string id) {
        if (items.contains(id)) {
	    items.lookup(id).destroy(); // destroy item first
	    items.remove(id); // remove item from array 
        }


    }
}

class Wifi : Astal.Icon {
    public Wifi() {
        Astal.widget_set_class_names(this, {"Wifi"});
        var wifi = AstalNetwork.get_default().wifi;
        wifi.bind_property("ssid", this, "tooltip-text", BindingFlags.SYNC_CREATE);
        wifi.bind_property("icon-name", this, "icon", BindingFlags.SYNC_CREATE);
    }
}

class AudioSlider : Gtk.Box {
    Astal.Icon icon = new Astal.Icon();
    Astal.Slider slider = new Astal.Slider() { hexpand = true };

    public AudioSlider() {
        add(icon);
        add(slider);
        Astal.widget_set_class_names(this, {"AudioSlider"});
        Astal.widget_set_class_names(icon, {"volumeIcon"});
        Astal.widget_set_css(this, "min-width: 140px");

        var speaker = AstalWp.get_default().audio.default_speaker;
        speaker.bind_property("volume-icon", icon, "icon", BindingFlags.SYNC_CREATE);
        speaker.bind_property("volume", slider, "value", BindingFlags.SYNC_CREATE);
        slider.dragged.connect(() => speaker.volume = slider.value);
    }
}

class Battery : Gtk.Box {
    Astal.Icon icon = new Astal.Icon();
    Astal.Label label = new Astal.Label();

    public Battery() {
        Astal.widget_set_class_names(this, {"Battery"});
        Astal.widget_set_class_names(icon, {"text"});
	Astal.widget_set_class_names(label, {"text"});
        add(icon);
        add(label);
        var bat = AstalBattery.get_default();
        bat.bind_property("is-present", this, "visible", BindingFlags.SYNC_CREATE);
        bat.bind_property("battery-icon-name", icon, "icon", BindingFlags.SYNC_CREATE);
        bat.bind_property("percentage", label, "label", BindingFlags.SYNC_CREATE, (_, src, ref trgt) => {
            var p = Math.floor(src.get_double() * 100);
            trgt.set_string(@"$p%");
            return true;
        });
    }
}

class Time : Astal.Label {
    string format;
    AstalIO.Time interval;

    void sync() {
        label = new DateTime.now_local().format(format);

    }

    public Time(string format = "%H:%M  %A %b %e") {
        this.format = format;
        interval = AstalIO.Time.interval(1000, null);
        interval.now.connect(sync);
        destroy.connect(interval.cancel);
        Astal.widget_set_class_names(this, {"Time"});
    }
}

class Left : Gtk.Box {
    public Left() {
        Object(hexpand: true, halign: Gtk.Align.START);
        add(new Panel(new Media()));
        add(new FocusedClient());

    }
}
class Panel: Gtk.Box {
    public Panel(Gtk.Widget widget){
	Astal.widget_set_class_names(this, {"panel"});
	add(widget);
    }
}
class Center : Gtk.Box {
    public Center() {
        add(new Panel(new Workspaces()));
    }
}
class rightPart: Gtk.Box{
    public rightPart(){
        add(new SysTray());
        add(new Wifi());
        add(new AudioSlider());
    }
}
class Right : Gtk.Box {
    public Right() {
        Object(hexpand: true, halign: Gtk.Align.END);
	add(new Panel(new rightPart()));
        add(new Panel(new Battery()));
        add(new Panel(new Time()));
    }
}
class Circle: Astal.Overlay{
    public Circle(){
	var cir = new Astal.CircularProgress();
	cir.set_visible(true);
	Astal.widget_set_class_names(cir,{"cir"});
	add(cir);
    }
}
class Bar : Astal.Window {
    public Bar(Gdk.Monitor monitor) {
	int width = (int)(monitor.get_geometry().width*(99.0/100.0)-3.0);
        Object(
            anchor: Astal.WindowAnchor.TOP,
            exclusivity: Astal.Exclusivity.EXCLUSIVE,
            gdkmonitor: monitor
        );
	print(@"screen width: $width"+"px");
        Astal.widget_set_class_names(this, {"bar"});
	var centerbox = new Astal.CenterBox();
	centerbox.start_widget = new Left();
	centerbox.center_widget = new Center();
	centerbox.end_widget = new Right();
	Astal.widget_set_css(centerbox,@"min-width: $width"+"px;");
	Astal.widget_set_class_names(centerbox,{"bar"});
        add(centerbox);

        show_all();
    }
}
