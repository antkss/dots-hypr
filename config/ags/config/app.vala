class App : Gtk.Application {
    // alternative is to rely on GLib.Application.get_default
    static App instance;

    private Bar bar;
    public string? home = Environment.get_variable("HOME");
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

    // this is the method that will be invoked on `app.run()`
    // this is where everything should be initialized and instantiated
    public override int command_line(ApplicationCommandLine command_line) {
        var argv = command_line.get_arguments();

        if (command_line.is_remote) {
            // app is already running we can print to remote
            command_line.print_literal("hello from the main instance\n");

            // for example, we could toggle the visibility of the bar
            if (argv.length >= 3 && argv[1] == "toggle" && argv[2] == "bar") {
                bar.visible = !bar.visible;
            }
        } else {
            // main instance, initialize stuff here
            init_css();
			var display = Gdk.Display.get_default();
			var n = display.get_n_monitors();
			for (int i =0; i < n; i++) {
				var monitor = display.get_monitor(i);
				 add_window((bar = new Bar(monitor, this)));
			}

        }

        return 0;
    }

    private App() {
        application_id = "org.antkss.bar";
        flags = ApplicationFlags.HANDLES_COMMAND_LINE;
    }

    // entry point of our app
    static int main(string[] argv) {
        App.instance = new App();
        Environment.set_prgname("mbar");
        return App.instance.run(argv);
    }
}
