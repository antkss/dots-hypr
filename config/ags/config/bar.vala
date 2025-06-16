using GLib;
using Posix;
public static string truncate_text(string text, int length) {
    // Truncate if the text is too long
    if(text == null){
      return "";
    }
    if (text.length > length) {
        return text.substring(0, length)+"...";
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
public class Command : Object {
    private string[] command;

    public Command(string[] command) {
        this.command = command;
    }

    public GLib.Pid spawn(
    ) throws Error {
		GLib.Pid async_pid;
		Process.spawn_async_with_pipes(
			null,                  // Working directory (null for current)
			command, // Command and arguments
			null,                  // Environment variables (null for current)
			SpawnFlags.SEARCH_PATH, // Flags: Search for the executable in PATH
			null,                  // Child setup function (no user data needed)
			out async_pid,         // Output: Process ID of the spawned process
			null,      // Input stream for the child
			null,     // Output stream from the child (our input)
			null      // Error stream from the child (our input)
		);
		return async_pid;

    }
	public void kill(GLib.Pid child) {
		Posix.kill(child, Posix.Signal.KILL);
	}
}

class Workspaces : Gtk.Box {
    AstalHyprland.Hyprland hypr = AstalHyprland.get_default();
    // GLib.HashTable<int, string> icons = new GLib.HashTable<int,string>(GLib.direct_hash,GLib.direct_equal);
    public Workspaces() {
	// icons.set(1, ""); 
	// icons.set(2, ""); 
	// icons.set(3, ""); 
	// icons.set(4, ""); 
	// icons.set(5, ""); 
	// icons.set(6, ""); 
	// icons.set(7, ""); 
	// icons.set(8, ""); 
	// icons.set(9,"");
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
	// string icon = icons.lookup(ws.id);
	string icon = ws.id.to_string("%d");
	// if (icon == null){
	//   icon = ws.id.to_string();
	// }
	if (ws.id < 0){
	  icon = "";
	}
        var btn = new Gtk.Button() {
            visible = true,
	    label = icon
        };
	var focused = hypr.focused_workspace == ws;
	if (focused ) {
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
        Astal.widget_set_class_names(this, {"text"});
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
	    Astal.widget_set_class_names(label, {"space"});
            add(label);
            return;
        }

        var player = mpris.players.nth_data(0);
        var label = new Gtk.Label(" - playing - "){ visible = true };
	Astal.widget_set_class_names(label, {"space"});
        player.bind_property("title", label, "label", BindingFlags.SYNC_CREATE, (_, src, ref trgt) => {
            var title = truncate_text(player.title,30);
            trgt.set_string(@"♫ $title");
            return true;
        });
        add(label);
	add(buttonT(">",player));

    }
}

class Traylist: Gtk.Box{
  public Traylist(){
    Astal.widget_set_class_names(this, {"bar"});
  }
}
class TrayWin: Astal.Window{
  // public Traylist tray = new Traylist();
  public TrayWin(Gdk.Monitor monitor){
      Object(
	  anchor: Astal.WindowAnchor.TOP,
	  exclusivity: Astal.Exclusivity.NORMAL,
	  gdkmonitor: monitor,
	  hexpand: false
      );
    // add(new Traylist());
  }
}

class SysTray : Gtk.Box {
    HashTable<string, Gtk.Widget> items = new HashTable<string, Gtk.Widget>(str_hash, str_equal);
    AstalTray.Tray tray = AstalTray.get_default();

    public SysTray() {
        Astal.widget_set_class_names(this, { "SysTray" });
        tray.item_added.connect(add_item);
        tray.item_removed.connect(remove_item);
    }

    void add_item(string id) {
        if (items.contains(id))
            return;

        var item = tray.get_item(id);
        var btn = new Gtk.MenuButton() { use_popover = false, visible = true };
        var icon = new Astal.Icon() { visible = true };

        item.bind_property("tooltip-markup", btn, "tooltip-markup", BindingFlags.SYNC_CREATE);
        item.bind_property("gicon", icon, "gicon", BindingFlags.SYNC_CREATE);
        item.bind_property("menu-model", btn, "menu-model", BindingFlags.SYNC_CREATE);
	Astal.widget_set_class_names(btn, {"button"});
        btn.insert_action_group("dbusmenu", item.action_group);
        item.notify["action-group"].connect(() => {
            btn.insert_action_group("dbusmenu", item.action_group);
        });

        btn.add(icon);
        add(btn);
        items.set(id, btn);
    }

    void remove_item(string id) {
        if (items.contains(id)) {
	    items.lookup(id).destroy();
            items.remove(id);
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
class Notification: Astal.EventBox{
    AstalNotifd.Notifd notifd = AstalNotifd.get_default();
    public Notification(){
	Astal.widget_set_class_names(this, {"bar"});
    }
    public void noti(string lmao,int id){
		var getNoti = notifd.get_notification(id);
		print(getNoti.app_name);
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
    public rightPart(Gdk.Monitor monitor){
        add(new SysTray());
        add(new Wifi());
        add(new AudioSlider());
    }
}

class Utils: Gtk.Box{
  public Utils(Gdk.Monitor monitor, Astal.Application app){
    string? home = Environment.get_variable("HOME");
    var colorswitch = new Gtk.Button(){
	  visible = true,
	  label = ""
    };
	Astal.widget_set_class_names(colorswitch,{"button-inactive","space-right"});
    colorswitch.clicked.connect(()=>{
		Command cmd = new Command({ home+"/.config/ags/scripts/color_generation/switchcolor.sh" });
		GLib.Pid async_pid = -1;
		try {
			async_pid = cmd.spawn();
		} catch (Error e) {
			GLib.stderr.printf("error: %s \n", e.message);
		}
		if (async_pid >= 0) {
			GLib.ChildWatch.add(async_pid, () => {
				app.apply_css(home+"/.config/ags/style.css");
				Astal.widget_set_class_names(colorswitch,{"button-inactive","space-right"});
			});
		}
    });
    var screenshot = new Gtk.Button(){
	  visible = true,
	  label = ""
    };
	Astal.widget_set_class_names(screenshot,{"button-inactive","space-right"});
    screenshot.clicked.connect(()=>{
		Command cmd = new Command({  home+"/.config/ags/scripts/grimblast.sh", "--freeze", "copy", "area" });
		GLib.Pid async_pid = -1;
		try {
			async_pid = cmd.spawn();
			Astal.widget_set_class_names(screenshot,{"button-active", "space-right"});
		} catch (Error e){
            GLib.stderr.printf("Error spawning: %s\n", e.message);
		}
		if (async_pid >= 0) {
			GLib.ChildWatch.add(async_pid, () => {
				Astal.widget_set_class_names(screenshot,{"button-inactive","space-right"});
			});
		}
    });
	Command k = new Command({"killall", "-9", "wlsunset"});
	try {
		k.spawn();
	} catch {};
	var reading = new Gtk.ToggleButton(){
	  visible = true,
	  label = ""
    };
    Astal.widget_set_class_names(reading,{"button-inactive"});
	GLib.stdout.printf("please ensure that no wlsunset is running right now \n");
	GLib.Pid child_pid = -1;
    reading.toggled.connect(()=>{
		Command cmd = new Command({"/usr/bin/wlsunset", "-T", "5000"});
		if (reading.get_active() && child_pid < 0) {
			Astal.widget_set_class_names(reading,{"button-active"});
			GLib.stdout.printf("toggle on \n");
			try {
				child_pid = cmd.spawn();
			} catch (Error e) {
				GLib.stderr.printf("Error spawning: %s\n", e.message);
			}
		} else if (child_pid > 0){
			GLib.stdout.printf("toggle off \n");
			Astal.widget_set_class_names(reading,{"button-inactive"});
			cmd.kill(child_pid);
			child_pid = -1;
		}
    });
    add(colorswitch);
    add(screenshot);
	add(reading);
  }
}
class Right : Gtk.Box {
    public Right(Astal.Application app, Gdk.Monitor monitor) {
        Object(hexpand: true, halign: Gtk.Align.END);
	add(new Panel(new rightPart(monitor)));
        add(new Panel(new Battery()));
	add(new Panel(new Utils(monitor, app)));
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
    public Bar(Gdk.Monitor monitor,Astal.Application app) {
		int width = (int)(monitor.get_geometry().width*(99.0/100.0)-3.0);
        Object(
            anchor: Astal.WindowAnchor.TOP,
            exclusivity: Astal.Exclusivity.EXCLUSIVE,
            gdkmonitor: monitor
        );
		print(@"screen width: $width"+"px \n");
        Astal.widget_set_class_names(this, {"bar"});
		var centerbox = new Astal.CenterBox();
		centerbox.start_widget = new Left();
		centerbox.center_widget = new Center();
		centerbox.end_widget = new Right(app,monitor);
		Astal.widget_set_css(centerbox,@"min-width: $width"+"px;");
		Astal.widget_set_class_names(centerbox,{"bar"});
		add(centerbox);
		show_all();
    }
}
class Overlay : Astal.Overlay {
    public Overlay(Gdk.Monitor monitor) {
		int width = monitor.get_geometry().width;
		int height = monitor.get_geometry().height;
		Astal.widget_set_css(this, @"min-width: $width" + "px;" + @"min-height: $height" + "px;" + "background: #000000;");
		// Astal.widget_set_class_names(this, {"bar"});
	}
}

class Sidebox : Gtk.Box{
    public Sidebox(){
	sync();
    }
    public void sync(){
	Gtk.Scale slider = new Astal.Slider();
	try{
	    File maxBn = File.new_for_path("/sys/class/backlight/intel_backlight/max_brightness");
	    FileInputStream @ise = maxBn.read();
	    DataInputStream maxBn_dis = new DataInputStream (@ise);
	    slider.set_range(0.0,double.parse(maxBn_dis.read_line()));
	    add(slider);
	    slider.show_all();
	    File file = File.new_for_path("/sys/class/backlight/intel_backlight/brightness");
	    FileMonitor monitor = file.monitor(FileMonitorFlags.NONE,null);
	    print("\nmonitoring %s\n",file.get_path());

	    monitor.changed.connect ((src, dest, event) => {
		try {
		    FileInputStream @is = file.read ();
		    DataInputStream dis = new DataInputStream (@is);
		    string line;
						//
		    if ((line = dis.read_line ()) != null) {
				slider.set_value(double.parse(line));
		    }
		} catch (Error e) {
			GLib.stderr.printf("error: %s \n", e.message);
		}


	});

	} catch( Error e){
	    print("%s\n",e.message);
	}

	new MainLoop().run();
    }


}
class SidePanel: Astal.Window{
    public SidePanel(Gdk.Monitor monitor){
        Object(
            anchor: Astal.WindowAnchor.LEFT,
            exclusivity: Astal.Exclusivity.NORMAL,
            gdkmonitor: monitor
        );
		add(new Sidebox());
    }

}
class Notify: Astal.Window{
    public Notify(Gdk.Monitor monitor){
        Object(
            anchor: Astal.WindowAnchor.TOP,
            exclusivity: Astal.Exclusivity.NORMAL,
            gdkmonitor: monitor
        );
		set_visible(true);
		add(new Notification());
    }
}
class BrightnessService: GLib.Object{
    public signal void value_changed (double old_value, double new_value);
    public BrightnessService(){
    }

}
