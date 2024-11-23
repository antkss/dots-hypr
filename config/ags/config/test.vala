#!/usr/bin/env -S vala --pkg gtk+-3.0

int main(string[] args) {
    Gtk.init (ref args);

    /*
     * Create a window
     */
    var window = new Gtk.Window ();
    window.title = "DnD test";
    window.window_position = Gtk.WindowPosition.CENTER;
    window.set_default_size (400, 600);
    window.destroy.connect (Gtk.main_quit);

    /*
     * Add controls
     */
	var grid = new DropGrid ();
    window.add (grid);
    /*
     * Show the window
     */
    window.show_all ();
    Gtk.main ();
    return 0;
}

public class DropGrid : Gtk.Grid {
	static Gtk.TargetEntry[] target_list;
	construct {
		Gtk.TargetEntry string_entry = { "STRING",        0, Target.STRING  };
		Gtk.TargetEntry urilist_entry = { "text/uri-list", 0, Target.URILIST };
		target_list += string_entry;
		target_list += urilist_entry;
	}
	
	public DropGrid () {
		this.orientation = Gtk.Orientation.VERTICAL;
		this.row_homogeneous = false;
		this.row_spacing = 10;
		this.margin = 10;
		
		Gtk.drag_dest_set (this,
						   Gtk.DestDefaults.ALL,
						   target_list,
						   Gdk.DragAction.COPY);


		this.drag_data_received.connect (on_drag_data_received);
	}
	enum Target {
		STRING,
		URILIST
	}

	void on_drag_data_received (Gtk.Widget widget, Gdk.DragContext ctx,
                            int x, int y,
                            Gtk.SelectionData selection_data,
                            uint target_type, uint time) {

		if ((selection_data == null) || !(selection_data.get_length () >= 0)) {
			return;
		}

		switch (target_type) {
		case Target.STRING:
			string data = (string) selection_data.get_data ();
			this.add (new Gtk.Label (data));
			break;
		case Target.URILIST:
			var uris = selection_data.get_uris ();
			for (int i=0; i < uris.length; i++) {
				this.add (new Gtk.Label (uris[i]));
			}
			break;
		}
		this.show_all ();
	}
}
