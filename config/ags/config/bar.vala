using GLib;
using Posix;
using GtkLayerShell;
using PulseAudio;
public string force_fit(string text, int limit) {
    // 🔵 Get the actual character count (handles UTF-8 correctly)
	if (text == null) 
		return string.nfill(limit, ' ');
    long char_count = text.length;

    if (char_count > limit) {
        // ✂️ TRUNCATE: Cut it at the limit
        // We find the byte offset of the 'limit' character
        long byte_index = text.index_of_nth_char(limit);
        return text.substring(0, (long)byte_index); // Optional: Remove "..." if you want strict cut
    } 
    else {
        // 🧱 PAD: Add spaces to fill the void
        string spaces = string.nfill((long)(limit - char_count), ' ');
        return text + spaces;
    }
}
public class WiggleSeekbar : Gtk.DrawingArea {
    // 📊 State: Just one number (0.0 = Empty, 1.0 = Full)
    public double percent { get; private set; default = 0.0; }

    // 🌊 Visual Settings
    public double amplitude = 3.0;
    public double frequency = 0.4;
    public double phase = 0.0;
	public double width = 2.0;
	public double circle_radius = 4.0;

    // 📡 Signal: Emits the new percentage (0.0 to 1.0) when clicked
    public signal void on_percent_change(double p);
	public bool playing = true;

    public WiggleSeekbar() {
        //this.set_size_request(200, 10);
		this.hexpand = true;
        this.add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.POINTER_MOTION_MASK);

        // Animation Loop
        Timeout.add(16, () => {
			if (this.playing) {
				this.phase += 0.05; 
				this.queue_draw();
			}
            return true;
        });

        this.draw.connect((ctx) => {
            int w = this.get_allocated_width();
            int h = this.get_allocated_height();
            double mid_y = h / 2.0;
            
            // 🟢 DIRECT: Use the percent directly to find the split point
            double split_x = w * this.percent; 

            // Style: Thinner and Lighter
            ctx.set_line_width(this.width);
            ctx.set_line_cap(Cairo.LineCap.ROUND);
			var style_context = this.get_style_context();
			var fg_color = style_context.get_color(style_context.get_state());
            // 1. Unplayed Line
            //ctx.set_source_rgba(0.3, 0.3, 0.3, 0.5);
			ctx.set_source_rgba(fg_color.red, fg_color.green, fg_color.blue, 0.3);
            ctx.move_to(split_x, mid_y);
            ctx.line_to(w, mid_y);
            ctx.stroke();

            // 2. Played Wiggle
            //ctx.set_source_rgba(0.8, 0.6, 1.0, 0.8);
			Gdk.cairo_set_source_rgba(ctx, fg_color);
            ctx.move_to(0, mid_y);
			double end_y = mid_y;
            for (double x = 0; x <= split_x; x++) {
                double y = mid_y + (amplitude * Math.sin((x * frequency) + phase));
                ctx.line_to(x, y);
				end_y = y;
            }
            ctx.stroke();
			ctx.move_to(split_x, end_y);
			circle_here(ctx, this.circle_radius);
            return true;
        });

        // Input
        this.button_press_event.connect((e) => { handle_input(e.x); return true; });
        this.motion_notify_event.connect((e) => {
            if ((e.state & Gdk.ModifierType.BUTTON1_MASK) != 0) handle_input(e.x);
            return true;
        });
    }
	public static void circle_here(Cairo.Context ctx, double radius) {
        double x, y;
        ctx.get_current_point(out x, out y);
        ctx.new_sub_path();
        ctx.arc(x, y, radius, 0, 2 * Math.PI);
        ctx.fill();
        ctx.move_to(x, y);
    }
    // 🟢 SETTER: Call this with 0.5 for 50%, 0.75 for 75%, etc.
    public void set_progress(double p) {
        this.percent = p.clamp(0.0, 1.0);
        this.queue_draw();
    }

    private void handle_input(double mouse_x) {
        int w = this.get_allocated_width();
        
        // Calculate new percentage based on click position
        double new_p = (mouse_x / w).clamp(0.0, 1.0);
        
        // Emit signal so main app knows
        this.on_percent_change(new_p);
        
        // Update visual immediately
        this.set_progress(new_p);
    }
}
public class Command : Object {
    private string[] command;

    public Command(string[] command) {
        this.command = command;
    }

    public GLib.Pid spawn(
    ) throws GLib.Error {
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
	    Astal.widget_set_class_names(btn, {"button_active"});
	} else {
	    Astal.widget_set_class_names(btn, {"button"});
	}
	hypr.notify["focused-workspace"].connect(() => {
	    focused = hypr.focused_workspace == ws;
            if (focused) {
                Astal.widget_set_class_names(btn, {"button_active"});
            } else {
                Astal.widget_set_class_names(btn, {"button"});
            }
        });

        // btn.clicked.connect(ws.focus);
        return btn;
    }
}

class FocusedClient : Gtk.Box {
	Gtk.Label label = new Gtk.Label("") { visible = true };
    public FocusedClient() {
		AstalHyprland.get_default().notify["focused-client"].connect(sync_clients);
		//AstalHyprland.get_default().notify.connect((sender, param_spec) => {
		//	// 🟢 This prints ANY property that changes on the player
		//	print(@"Property changed: $(param_spec.name)\n");
		//	//print("%s \n", this.main_player.metadata.print(true));
		//});
		Astal.widget_set_class_names(this.label,{"text"});
		this.label.set_xalign(0.0f);
		this.label.set_ellipsize(Pango.EllipsizeMode.END);
		this.label.set_max_width_chars(60);
		add(this.label);
    }

    void sync_clients() {
        var client = AstalHyprland.get_default().focused_client;
        if (client == null)
            return;
		var title = client.title;
		if (title != null) {
			this.label.set_text(title);
		} else {
			this.label.set_text("");
		}

    }
}
public class TrayMenu : Astal.Window {
    public Gtk.Box menu_box;
    private Gtk.Fixed fixed_layout;
	public string? home = Environment.get_variable("HOME");
	public signal void on_space_click();
	public void init_css() {
		try {
			var provider = new Gtk.CssProvider();
			provider.load_from_file(GLib.File.new_for_path(home + "/.config/ags/" + "style.css"));
			Gtk.StyleContext.add_provider_for_screen(
				Gdk.Screen.get_default(),
				provider,
				Gtk.STYLE_PROVIDER_PRIORITY_USER
			);
		} catch {
			print("Can't load css, an error occur !");
		}

    }

	public void add_to_tray(Gtk.Widget widget) {
		this.menu_box.add(widget);
	}
	public void destroy_all_child() {
		foreach (var child in this.menu_box.get_children())
            child.destroy();
	}
	public uint get_child_idx(Gtk.Widget widget) {
		return this.menu_box.get_children().index(widget);
	}
    public TrayMenu(Gdk.Monitor mon) {
        Object(layer: Astal.Layer.OVERLAY, 
			   anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT,
			   keymode: Astal.Keymode.ON_DEMAND
			   );
        
		init_css();
		Astal.widget_set_css(this, "background: transparent;");
		this.key_press_event.connect((event) => {
			switch (event.keyval) {
				case Gdk.Key.Up:
					this.menu_box.child_focus(Gtk.DirectionType.TAB_BACKWARD);
					return true; // "I handled this, stop processing"
				case Gdk.Key.Down:
					this.menu_box.child_focus(Gtk.DirectionType.TAB_FORWARD);
					return true;
				case Gdk.Key.Tab:
					this.menu_box.child_focus(Gtk.DirectionType.TAB_FORWARD);
					return true;
				case Gdk.Key.Return:
				case Gdk.Key.KP_Enter: // Numpad Enter
				case Gdk.Key.space:    // Spacebar (Standard accessibility behavior)
					this.on_space_click();
					
					// 1. Get the currently focused widget
					var focused_widget = this.get_focus();

					// 2. Check if it is actually a Button
					if (focused_widget is Gtk.Button) {
						// 3. Force it to behave as if clicked
						// This runs the code inside your btn.clicked.connect(...)
						var btn = focused_widget as Gtk.Button;
						if (btn != null) {
							btn.clicked();
						}
					}
					return true; // Stop event
				case Gdk.Key.Escape:
					this.hide();
					return true;
				//default:
				//	this.hide();
				//	return true;
			}
			return true;

		});
		//this.notify.connect((a, b)=> {
		//	print(@"name: $(b.name) \n");
		//});
		this.focus_out_event.connect(()=>{
			this.hide();
			return true;
		});

		
		init_css();
		this.button_press_event.connect((e) => {
			// 🛑 1. Filter out Double/Triple Clicks
			// If we don't do this, fast clicks on children bubble up and close us!
			if (e.type == Gdk.EventType.2BUTTON_PRESS || e.type == Gdk.EventType.3BUTTON_PRESS) {
				return true; // "Eat" the event, but do NOT hide
			}

			// 🟢 2. Normal Logic (Single Click on background)
			this.hide();
			return true; 
		});
        // 4. 🟢 HANDLE CLICK OUTSIDE (Clicking the curtain)
        // Events on the window itself = Close
        //this.button_press_event.connect(() => {
        //    this.hide();
        //    return true; // Stop propagation
        //});

        // 5. Layout Container (Fixed allows manual X/Y positioning)
        fixed_layout = new Gtk.Fixed();
        add(fixed_layout);

        // 6. The Actual Menu Box
        menu_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        
        // Style the MENU BOX (Not the window)
        menu_box.get_style_context().add_class("tray-menu"); // Apply your dark CSS here
        
        fixed_layout.put(menu_box, 0, 0);
    }

    public void toggle_at_widget(Gtk.Widget target) {
        if (this.is_visible()) {
            this.hide();
        } else {
            // 1. Calculate Coordinates (Same as before)
            var toplevel = target.get_toplevel();
            if (toplevel.is_toplevel()) {
                int win_x, win_y;
                toplevel.get_window().get_origin(out win_x, out win_y);

                int btn_x, btn_y;
                target.translate_coordinates(toplevel, 0, 0, out btn_x, out btn_y);

                int final_x = win_x + btn_x;
                int final_y = win_y + btn_y;

                // 2. 🟢 MOVE THE BOX (Not the window)
                // We move the box inside the fixed layout
                fixed_layout.move(menu_box, final_x, final_y);

                this.show_all();
                this.present();
            }
        }
    }
}
//Gtk.Button buttonT(AstalMpris.Player player) {
//	var btn = new Gtk.Button() {
//		visible = true,
//		label = player.playback_status == 0 ? "": ""
//	};
//
//	Astal.widget_set_class_names(btn, {"button_active"});
//	btn.clicked.connect(() => {
//
//	});
//	return btn;
//}
class LabelBtn: Gtk.Button {
	public Gtk.Label my_label = new Gtk.Label("");
	public LabelBtn(string? str) {
		Astal.widget_set_class_names(this, { "button_inactive" });
		add(my_label);
	}
}
class BigBtn: Gtk.Button {
	public BigBtn(string ?str="") {
		set_label(str);
		Astal.widget_set_class_names(this, {"button_big"});
	}
}
class ActiveBtn: Gtk.Button {
	public ActiveBtn(string ?str = "") {
		set_label(str);
		set_hexpand(false);
		set_vexpand(false);
		Astal.widget_set_class_names(this, {"button_active_big"});
	}
}
class LabelPanel: Gtk.Label {
	public LabelPanel(string ?str) {
		Astal.widget_set_class_names(this, { "button_panel"});
		set_text(str);
	}
}
class ButtonPanel: Gtk.Button {
	public ButtonPanel(string ?str) {
		set_label(str);
		Astal.widget_set_class_names(this, {"button_panel"});
	}
}
class Media : Gtk.Box {
    AstalMpris.Mpris mpris = AstalMpris.get_default();
	Gtk.Button play_button = new Gtk.Button() { visible = true };
	Gtk.Label play_label = new Gtk.Label("♫ Nothing Playing ♫") { visible = true };
	AstalMpris.Player main_player = null;
	public GLib.List<weak AstalMpris.Player> players = null;
	Gtk.Button menu_btn;
    TrayMenu tray_menu_media; // 1. Define the menu
	//uint chosen_player = 0;
	//public GLib.List <Gtk.Label> menu_tray_labels = null;
    public Media(Gdk.Monitor mon) {
		Astal.widget_set_class_names(this.play_button, { "button_active" });
		Astal.widget_set_class_names(play_label, {"space"});
		play_label.set_ellipsize(Pango.EllipsizeMode.END);
		play_label.set_max_width_chars(45);
		//this.mpris.player_closed.connect(() => {
		//	print("player disappeared ! \n");
		//});
        mpris.notify["players"].connect(sync_players);

		this.play_button.clicked.connect(() => {
			if (this.main_player != null) {
				this.main_player.play_pause();
			}
		});

		//this.mpris.notify.connect((sender, param_spec) => {
		//	// 🟢 This prints ANY property that changes on the player
		//	print(@"Property changed: $(param_spec.name)\n");
		//});
		this.play_button.set_label("");
		tray_menu_media = new TrayMenu(mon);
		this.tray_menu_media.add_to_tray(new LabelPanel("* Nothing here *"));
		this.tray_menu_media.on_space_click.connect((event)=>{
			if (this.main_player != null) {
				this.main_player.play_pause();
			}
		});
        menu_btn = new Gtk.Button();
		Astal.widget_set_class_names(menu_btn, { "button" });
		menu_btn.set_label("↓");
        menu_btn.clicked.connect(() => {
            // Pass the button itself so the menu knows where to appear
            tray_menu_media.toggle_at_widget(menu_btn);
        });
        add(menu_btn);
		add(play_button);
		add(play_label);
    }
	void on_playback_status() {
		if (this.main_player != null) {
			var title = this.main_player.title;
			this.play_label.set_label(@"♫ $title");
			if (this.main_player.playback_status == 0) {
				this.play_button.set_label("");
			} else {
				this.play_button.set_label("");
			}
		}
		//uint idx = 0;
		//foreach(var child in this.tray_menu_media.menu_box.get_children()) {
		//	var label = child.get_data<Gtk.Label>("label");
		//	var player = players.nth_data(idx);
		//	var title = player.title;
		//	label.set_label(@"♫ $title");
		//	idx += 1;
		//}
	}
	void change_players() {
		if (this.main_player != null) {
			//this.main_player.notify.connect((sender, param_spec) => {
			//	// 🟢 This prints ANY property that changes on the player
			//	print(@"Property changed: $(param_spec.name)\n");
			//	//print("%s \n", this.main_player.metadata.print(true));
			//});
			this.main_player.notify["playback-status"].connect(on_playback_status);
			var title = this.main_player.title;
			this.play_label.set_label(@"♫ $title");
			if (this.main_player.playback_status == 0) {
				this.play_button.set_label("");
			} else {
				this.play_button.set_label("");
			}
		}
	}
    void sync_players() {
		print("players changed ! \n");
		this.tray_menu_media.hide();
		this.tray_menu_media.destroy_all_child();
        if (mpris.players.length() < 1) {
			//this.my_tray_menu.add_to_tray(this.play_label);
			this.tray_menu_media.add_to_tray(new LabelBtn("* Nothing here *"));
			this.play_button.set_label("");
			this.play_label.set_label("♫ Nothing Playing ♫");
			this.players = null;
			this.main_player = null;
            return;
        }
		this.players = this.mpris.players.copy();
		if (this.main_player == null || this.players.find(this.main_player) == null) {
			this.main_player = this.players.nth_data(0);
			this.main_player.notify["title"].connect(()=>{
				this.play_label.set_text(@"♫ $(this.main_player.title)");
			});
		} 
		//if (chosen_player >= this.players.length()) {
		//	chosen_player = this.players.length() - 1;
		//}

		//this.menu_tray_labels = null;
		//int i = 0;
		foreach(var player in this.players) {
			//player.notify.connect((a, b)=>{
			//	if (b.name != "position")
			//		print(@"changed: $(b.name) \n");
			//});
			//int box_idx = i;
			var line = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			var music_icon = new Gtk.Button();
			//var title = player.title;
			var label = new Gtk.Label("");
			//var label_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			var prev_btn = new ActiveBtn("󰒮");
			var pause_btn = new ActiveBtn("");
			var next_btn = new ActiveBtn("󰒭");
			var upper_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			var lower_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			//var btn_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			//var ver_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			var control_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			//var padding_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			var seekbar = new WiggleSeekbar();
			if (!tray_menu_media.is_visible()) {
				seekbar.playing = false;
			}
			//Astal.widget_set_css(seekbar, "all: unset; min-width: 200px;");
            // 2. Put the scaled pixbuf into the Image widget
			//icon.set_size_request(100, 100);
			//if (player.cover_art != null) {int limit
			//	icon.set_from_file(player.cover_art);
			//} else {
			//}
			//icon.set_from_icon_name("library-music", Gtk.IconSize.DIALOG);
			//Astal.widget_set_class_names(icon, {"music_icon"});
			//label.set_xalign(0.0f);
			//label.set_ellipsize(Pango.EllipsizeMode.END);
			//label.set_max_width_chars(60);
			label.xalign = 0; 
			label.max_width_chars = 200;
			//label.width_chars = 30;
			label.ellipsize = Pango.EllipsizeMode.END;
			label.set_text(@"♫ $(player.title)");
			Astal.widget_set_class_names(music_icon, { "music_icon" });
			Astal.widget_set_class_names(line, { "music_icon" });
			Astal.widget_set_class_names(label, { "space" });
			Astal.widget_set_class_names(lower_box, { "bar" });
			Astal.widget_set_css(lower_box, "margin: 4px;");
			Astal.widget_set_css(pause_btn, "margin-left: 4px;");
			Astal.widget_set_css(next_btn, "margin-left: 4px;");
			Astal.widget_set_css(prev_btn, "margin-left: 4px;");
			//Astal.widget_set_css(padding_box, "all:unset; min-height: 50px;");
			//Astal.widget_set_css(seekbar, @"all: unset; min-width: 200px;");
			line.set_data<AstalMpris.Player>("player", player);
			//line.set_data<Gtk.Label>("label", label);
			line.can_focus = true;
			prev_btn.can_focus = false;
			pause_btn.can_focus = false;
			next_btn.can_focus = false;
			music_icon.can_focus = false;
			//btn_box.add(label);
			//label_box.add(label);
			upper_box.add(music_icon);
			upper_box.add(label);
			lower_box.add(seekbar);
			lower_box.add(control_box);
			line.add(upper_box);
			line.add(lower_box);
			//line.add(ver_box);
			//btn_box.add(ver_box);
			//ver_box.add(padding_box);
			//ver_box.add(control_box);
			control_box.add(prev_btn);
			control_box.add(pause_btn);
			control_box.add(next_btn);
			seekbar.set_progress(player.position / player.length);

			music_icon.clicked.connect(()=> {
				line.grab_focus();
			});
			seekbar.on_percent_change.connect((position)=> {
				player.position = player.length * position;
			});
			if (player.playback_status != 0) {
				pause_btn.set_label("");
			} else {
				pause_btn.set_label("");
			}
			//player.notify["metadata"].connect(()=> {
			//	print(@"metadata: $(player.metadata.print(true)) \n");
			//});
			player.notify["position"].connect((a, b)=>{
				//print(@"percent: $(player.position / player.length) \n");
				if (player.position >= 0 && player.length > 0) {
					seekbar.set_progress(player.position / player.length);
				} else {
					seekbar.set_progress(0);
				}
				if (tray_menu_media.is_visible()) {
					seekbar.playing = true;
				} else {
					seekbar.playing = false;
				}
			});
			prev_btn.clicked.connect(()=>{
				player.previous();
			});
			pause_btn.clicked.connect(()=>{
				player.play_pause();
			});

			player.notify["playback-status"].connect((a, b)=> {
				seekbar.playing = false;
				if (player.playback_status != 0) {
					pause_btn.set_label("");
				} else {
					pause_btn.set_label("");
				}
			});
			next_btn.clicked.connect(()=>{
				player.next();
			});
			//line.add(label);
			//line.add(pause_btn);

			player.notify["cover-art"].connect(() => {
				Astal.widget_set_css(music_icon, @"background-image: url(\"file://$(player.cover_art)\");background-position: center;");
				//Astal.widget_set_css(music_icon, "background-size: cover;");
			});
			player.notify["title"].connect(()=>{
				label.set_text(@"♫ $(player.title)");
			});
			Astal.widget_set_css(music_icon, @"background-image: url(\"file://$(player.cover_art)\");background-position: center;");
			//Astal.widget_set_css(music_icon, "background-position: center;");
			//Astal.widget_set_css(music_icon, "background-size: cover;");
			//line.event.connect((a, b)=> {
			//	print(@"name: $(a.name) \n");
			//	return true;
			//});
			line.focus_in_event.connect(() => {
				//this.chosen_player = box_idx;
				var candidate = line.get_data<AstalMpris.Player>("player");
				if (this.main_player == candidate) {
					print("same player ! \n");
				} else {
					this.main_player = candidate;
				}
				change_players();
				//Astal.widget_set_class_names(pause_btn, {"button_inactive_big"});
				//Astal.widget_set_class_names(prev_btn, {"button_inactive_big"});
				//Astal.widget_set_class_names(next_btn, {"button_inactive_big"});
				//this.tray_menu_media.toggle_at_widget(this.menu_btn);
				return true;
			});
			//line.focus_out_event.connect(()=> {
			//	Astal.widget_set_class_names(pause_btn, {"button_active_big"});
			//	Astal.widget_set_class_names(prev_btn, {"button_active_big"});
			//	Astal.widget_set_class_names(next_btn, {"button_active_big"});
			//	return true;
			//});
			this.tray_menu_media.add_to_tray(line);
			//this.menu_tray_labels.append(label);
			//i+= 1;
		}

		change_players();

    }
}

//class Traylist: Gtk.Box{
//  public Traylist(){
//    Astal.widget_set_class_names(this, {"bar"});
//  }
//}
//class TrayWin: Astal.Window{
//  // public Traylist tray = new Traylist();
//  public TrayWin(Gdk.Monitor monitor){
//      Object(
//		  anchor: Astal.WindowAnchor.TOP,
//		  exclusivity: Astal.Exclusivity.NORMAL,
//		  gdkmonitor: monitor,
//		  vexpand: true,
//		  hexpand: false
//      );
//    // add(new Traylist());
//  }
//}

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
        var wifi = AstalNetwork.get_default();
        wifi.wifi.bind_property("ssid", this, "tooltip-text", BindingFlags.SYNC_CREATE);
        wifi.wifi.bind_property("icon-name", this, "icon", BindingFlags.SYNC_CREATE);
    }
}
public string[] get_subfolders(string path) {
    string[] folders = {};
    File dir = File.new_for_path(path);

    try {
        // 🔹 Start enumerating children
        FileEnumerator enumerator = dir.enumerate_children(
            "standard::*", 
            FileQueryInfoFlags.NOFOLLOW_SYMLINKS, 
            null
        );

        FileInfo info;
        while ((info = enumerator.next_file(null)) != null) {
            // 🔸 Check if item is strictly a directory
            if (info.get_file_type() != FileType.REGULAR) {
                // 📥 Add to array
                folders += info.get_name();
            }
        }
    } catch (GLib.Error e) {
		print("Error: %s \n", e.message);
    }

    return folders;
}

public class VolumeWatcher : Object {
    private GLibMainLoop loop;
    private Context context;

    // 📣 Signal for UI or other components to listen to
    public signal void volume_changed(double volume_percent, bool muted);

    public VolumeWatcher() {
        // 🔄 Integration with GLib's MainLoop
        this.loop = new GLibMainLoop(null);
        this.context = new Context(loop.get_api(), "VolumeWatcher");

        context.set_state_callback(on_state_changed);
        context.connect(null, Context.Flags.NOFAIL, null);
    }

    private void on_state_changed(Context c) {
        if (c.get_state() == Context.State.READY) {
            // 🔔 Subscribe to Sink events (Volume/Mute changes)
            c.set_subscribe_callback(on_event_received);
            c.subscribe(PulseAudio.Context.SubscriptionMask.SINK, null);
            
            // 🏃 Initial fetch of current volume
            update_volume_info();
        }
    }

    private void on_event_received(Context c, PulseAudio.Context.SubscriptionEventType t, uint32 idx) {
        // 🔍 Filter: Check if the event is a SINK CHANGE
        if ((t & PulseAudio.Context.SubscriptionEventType.FACILITY_MASK) == PulseAudio.Context.SubscriptionEventType.SINK &&
            (t & PulseAudio.Context.SubscriptionEventType.TYPE_MASK) == PulseAudio.Context.SubscriptionEventType.CHANGE) {
            update_volume_info();
        }
    }

    private void update_volume_info() {
        context.get_sink_info_list((c, info, eol) => {
            if (info != null) {
                // 🧮 Convert PulseAudio internal scale (0 - 65536) to 0 - 100%
                double vol = (double)info.volume.avg() / PulseAudio.Volume.NORM * 100;
                this.volume_changed(vol, info.mute != 0);
            }
        });
    }

    public void set_volume(double percent) {
        if (context.get_state() != Context.State.READY) return;

        // 🎚️ Prepare volume struct
        CVolume cv = CVolume();
        PulseAudio.Volume v = (PulseAudio.Volume)(percent / 100 * PulseAudio.Volume.NORM);
        cv.set(2, v); // Using 2 channels (Stereo)
        
        context.set_sink_volume_by_index(0, cv, null);
    }

    public void set_mute(bool mute) {
        if (context.get_state() != Context.State.READY) return;
        
        // 🔇 Set mute status (Passing bool directly as per VAPI)
        context.set_sink_mute_by_index(0, mute, null);
    }
}
public class BrightnessWatcher : Object {
    // 🟢 1. Define the Signal (The Callback)
    // We send a double (0.0 to 100.0) so it works easily with Sliders
    public signal void brightness_changed(double percentage);

    private FileMonitor monitor;
    private File file;
    
    // Paths
    private string path_dir = "/sys/class/backlight/";
    private string path_brightness;
    private string path_max;
    public double max_level = 1.0;

    public BrightnessWatcher() {
		var backlight = get_subfolders(path_dir);
		//foreach (var path in backlight) {
		//	print("%s \n", path);
		//}
		if (backlight != null && backlight.length > 0) {
			this.path_brightness = Path.build_filename(path_dir, backlight[0] ,"brightness");
			this.path_max = Path.build_filename(path_dir, backlight[0], "max_brightness");

			// 1. Read Max Brightness first (needed for math)
			read_max_level();

			// 2. Setup Monitor
			this.file = File.new_for_path(path_brightness);
			try {
				this.monitor = file.monitor_file(FileMonitorFlags.NONE, null);
				this.monitor.changed.connect((src, dest, event_type) => {
					if (event_type == FileMonitorEvent.CHANGED || 
						event_type == FileMonitorEvent.CHANGES_DONE_HINT) {
						read_current_level();
					}
				});

				// Initial read
				read_current_level();
			} catch (GLib.Error e) {
				warning("Error monitoring file: %s", e.message);
			}
		} else {
			print("No backlight found !");
		}

    }
	public void set_brightness(double percentage) {
		if (this.path_brightness != null) {
			// 1. Safety Checks (Clamp 0-100)
			if (percentage < 1) percentage = 1;
			if (percentage > 100) percentage = 100;

			// 2. Calculate Raw Integer (e.g., 50% of 96000 = 48000)
			int target_val = (int)((percentage / 100.0) * this.max_level);

			// 3. Write to file
			//try {
			var file = FileStream.open(this.path_brightness, "w");
			if (file != null) {
				file.printf("%d", target_val);
			} else {
				print("Write to %s: %s \n",this.path_brightness ,GLib.strerror(errno));
			}
		} else {
			print("No backlight found !");
		}

    }

    public void read_max_level() {
		if (this.path_max != null) {
			try {
				string content;
				if (FileUtils.get_contents(path_max, out content)) {
					this.max_level = double.parse(content.strip());
				}
			} catch (GLib.Error e) {
				warning("Could not read max_brightness: %s", e.message);
			}
		} else {
			print("No backlight found !");
		}
    }

    public void read_current_level() {
		if (this.path_brightness != null) {
			try {
				string content;
				if (FileUtils.get_contents(path_brightness, out content)) {
					double current = double.parse(content.strip());
					
					// Calculate Percentage
					double percent = (current / this.max_level) * 100.0;

					// 🟢 3. Emit the signal (Trigger the callback)
					brightness_changed(percent);
				}
			} catch (GLib.Error e) {
				warning("Read error: %s", e.message);
			}
		} else {
			print("No backlight found !");
		}
    }
	public double get_brightness() {
		if (this.path_brightness != null) {
			try {
				string content;
				if (FileUtils.get_contents(path_brightness, out content)) {
					double current = double.parse(content.strip());
					double percent = (current / this.max_level) * 100.0;
					return percent;
				}
			} catch (GLib.Error e) {
				warning("Read error: %s", e.message);
			}
		} else {
			print("No backlight found !");
		}

		return 1.0;
	}
}
class BrightSlider : Gtk.Box {
    public Astal.Slider slider = new Astal.Slider() { hexpand = true };
    Gtk.Label icon = new Gtk.Label("󱩏");
	public BrightnessWatcher bright = new BrightnessWatcher();

    public BrightSlider() {
		add(icon);
        add(slider);
        Astal.widget_set_class_names(this, {"AudioSlider"});
        Astal.widget_set_css(this, "min-width: 140px");
		Astal.widget_set_class_names(icon, { "text" });
		bright.brightness_changed.connect((value) => {
			var icon_str = "󱩏";
			if (value >= 100.0) {
				icon_str = "󱩖";
			} else if (value >= 75.0) {
				icon_str = "󱩓";
			} else if (value >= 50.0) {
				icon_str = "󱩑";
			} else if (value >= 25.0) {
				icon_str = "󱩐";
			}  
			icon.set_text(icon_str);
			//print("brightness %f %s\n", value, icon_str);
			slider.value = value;
		});

		//print("%f \n", slider.max);
		slider.max = 100.0f;
		slider.set_value(bright.get_brightness());
        slider.dragged.connect(() => bright.set_brightness(slider.value));
    }
}
class AudioSlider : Gtk.Box {
	Gtk.Label icon = new Gtk.Label("");
    public Astal.Slider slider = new Astal.Slider() { hexpand = true };
	public VolumeWatcher volume = new VolumeWatcher();
    public AudioSlider() {
        add(icon);
        add(slider);
        Astal.widget_set_class_names(this, {"AudioSlider"});
        Astal.widget_set_class_names(icon, {"volumeIcon"});
        Astal.widget_set_css(this, "min-width: 140px");
		slider.max = 100.0f;
		volume.volume_changed.connect((volume_percent, muted) => {
			var icon_str = "";
			if (muted || volume_percent <= 0) {
				icon_str =  "󰝟"; // 󰝟 Speaker Muted
			}

			if (volume_percent >= 70.0) {
				icon_str =  "󰕾"; // 󰕾 Speaker High (3 waves)
			} else if (volume_percent >= 30.0) {
				icon_str =  "󰖀"; // 󰖀 Speaker Medium (2 waves)
			} else {
				icon_str =  "󰕿"; // 󰕿 Speaker Low (1 wave)
			}
			icon.set_text(icon_str + " ");
			slider.value = volume_percent;
		});
        slider.dragged.connect(() => {
			volume.set_volume(slider.value);
		});
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
//class Notification: Astal.EventBox{
//    AstalNotifd.Notifd notifd = AstalNotifd.get_default();
//    public Notification(){
//	Astal.widget_set_class_names(this, {"bar"});
//    }
//    public void noti(string lmao,int id){
//		var getNoti = notifd.get_notification(id);
//		print(getNoti.app_name);
//    }
//
//
//}
class Time : Astal.Label {
    string format;
    uint interval;

    bool sync() {
        label = new DateTime.now_local().format(format);
        return Source.CONTINUE;
    }

    public Time(string format = "%H:%M:%S  %A %b %e") {
        this.format = format;
        interval = Timeout.add(1000, sync, Priority.DEFAULT);
        destroy.connect(() => Source.remove(interval));
        Astal.widget_set_class_names(this, {"Time"});
    }
}


class Left : Gtk.Box {
    public Left(Gdk.Monitor mon) {
        Object(vexpand: true, hexpand: false);
        add(new Panel(new Media(mon)));
        add(new FocusedClient());

    }
}
class Panel: Gtk.Box {
    public Panel(Gtk.Widget widget){
        Object(vexpand: true, hexpand: false);
		Astal.widget_set_class_names(this, {"panel"});
		add(widget);
    }
}
class Center : Gtk.Box {
    public Center() {
        Object(vexpand: true, hexpand: false);
        add(new Panel(new Workspaces()));
    }
}
class rightPart: Gtk.Box{
	public int brightness_value = 0;
	public double audio_value { get; set; default = 0; }
    public rightPart(Gdk.Monitor mon){
		var tray_menu_btn = new LabelBtn("󱩖 ");
		var tray_menu = new TrayMenu(mon);
		var brightness_slider = new BrightSlider();
		var audio_slider = new AudioSlider();
		//var speaker = AstalWp.get_default().audio.default_speaker;
		//speaker.bind_property("volume", this, "audio_value", BindingFlags.SYNC_CREATE);
		tray_menu.add_to_tray(new Panel(audio_slider));
		tray_menu.add_to_tray(new Panel(brightness_slider));
        add(new SysTray());
        add(new Wifi());
		tray_menu_btn.clicked.connect(()=> {
			tray_menu.toggle_at_widget(tray_menu_btn);
		});
		add(tray_menu_btn);
		this.audio_value = (int)audio_slider.slider.value;
		this.brightness_value = (int)brightness_slider.slider.value;
		tray_menu_btn.my_label.set_label(@"$((int)this.brightness_value) 󱩖 $( "%.1f".printf(this.audio_value) )  ");
		brightness_slider.bright.brightness_changed.connect((percent) => {
			this.brightness_value = (int)percent;
			tray_menu_btn.my_label.set_label(@"$((int)this.brightness_value) 󱩖 $((int)this.audio_value)  ");
			//print("brightness: %f \n", percent);
		});
		audio_slider.volume.volume_changed.connect((percent, muted) => {
			this.audio_value = percent;
			tray_menu_btn.my_label.set_label(@"$((int)this.brightness_value) 󱩖 $( "%.1f".printf(this.audio_value) )  ");
		});
    }
}

class Utils: Gtk.Box{
  public Utils(App app){
    var colorswitch = new Gtk.Button(){
	  visible = true,
	  label = ""
    };
	Astal.widget_set_class_names(colorswitch,{"button_inactive","space_right"});
    colorswitch.clicked.connect(()=>{
		Command cmd = new Command({ app.home + "/.config/ags/scripts/color_generation/switchcolor.sh" });
		GLib.Pid async_pid = -1;
		try {
			async_pid = cmd.spawn();
		} catch (GLib.Error e) {
			GLib.stderr.printf("error: %s \n", e.message);
		}
		if (async_pid >= 0) {
			GLib.ChildWatch.add(async_pid, () => {
				app.init_css();
				//app.apply_css(home+"/.config/ags/style.css");
				Astal.widget_set_class_names(colorswitch, {"button_inactive","space_right"});
			});
		}
    });
    var screenshot = new Gtk.Button(){
	  visible = true,
	  label = ""
    };
	Astal.widget_set_class_names(screenshot,{"button_inactive","space_right"});
    screenshot.clicked.connect(()=>{
		Command cmd = new Command({  app.home + "/.config/ags/scripts/grimblast.sh", "--freeze", "copy", "area" });
		GLib.Pid async_pid = -1;
		try {
			async_pid = cmd.spawn();
			Astal.widget_set_class_names(screenshot,{"button_active", "space_right"});
		} catch (GLib.Error e){
            GLib.stderr.printf("Error spawning: %s\n", e.message);
		}
		if (async_pid >= 0) {
			GLib.ChildWatch.add(async_pid, () => {
				Astal.widget_set_class_names(screenshot,{ "button_inactive", "space_right"});
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
    Astal.widget_set_class_names(reading,{"button_inactive"});
	GLib.stdout.printf("please ensure that no wlsunset is running right now \n");
	GLib.Pid child_pid = -1;
    reading.toggled.connect(()=>{
		Command cmd = new Command({"/usr/bin/wlsunset", "-T", "5000"});
		if (reading.get_active() && child_pid < 0) {
			Astal.widget_set_class_names(reading,{"button_active"});
			GLib.stdout.printf("toggle on \n");
			try {
				child_pid = cmd.spawn();
			} catch (GLib.Error e) {
				GLib.stderr.printf("Error spawning: %s\n", e.message);
			}
		} else if (child_pid > 0){
			GLib.stdout.printf("toggle off \n");
			Astal.widget_set_class_names(reading,{"button_inactive"});
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
    public Right(App app, Gdk.Monitor mon) {
        Object(vexpand: true, hexpand: false, halign: Gtk.Align.END);
		//var scroller = new Gtk.ScrolledWindow(null, null);
		//// Only scroll vertically
		////scroller.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.NEVER);
		//scroller.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.NEVER);
		//
		//// 3. Create a Horizontal Box to hold your items
		//var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10) { hexpand = true };
		//scroller.set_size_request(200, 10);
		//scroller.get_style_context().add_class("hidden-scroll");
		////Astal.widget_set_css(scroller, "min-width: 10px;");
		//
		//// 4. Add items (Make sure you have enough to overflow the window!)
		//for (int i = 0; i < 20; i++) {
		//	var btn = new Gtk.Button();
		//	btn.set_label(@"Item $i");
		//	Astal.widget_set_class_names(btn, { "button" });
		//	box.pack_start(btn, false, false, 0); 
		//}
		//scroller.add(box);
		//add(new Panel(scroller));
		add(new Panel(new rightPart(mon)));
        add(new Panel(new Battery()));
		add(new Panel(new Utils(app)));
        add(new Panel(new Time()));
    }
}
class Bar : Astal.Window {
    public Bar(Gdk.Monitor monitor, App app) {
		int width = (int)(monitor.get_geometry().width * (98.7 / 100.0));
        Object(
            anchor: Astal.WindowAnchor.TOP,
            exclusivity: Astal.Exclusivity.EXCLUSIVE,
            gdkmonitor: monitor
        );
		print(@"screen width: $width"+"px \n");
        Astal.widget_set_class_names(this, {"bar"});
		var centerbox = new Astal.CenterBox();
		centerbox.start_widget = new Left(monitor);
		centerbox.center_widget = new Center();
		centerbox.end_widget = new Right(app, monitor);
		Astal.widget_set_css(centerbox,@"min-width: $width"+"px;");
		Astal.widget_set_class_names(centerbox,{"bar"});
		add(centerbox);
		show_all();
    }
}
