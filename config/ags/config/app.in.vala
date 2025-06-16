class App : Astal.Application {
    public static App instance;

    public override void request (string msg, SocketConnection conn) {
        print(@"$msg\n");
        AstalIO.write_sock.begin(conn, "ok");
    }

    public override void activate() {
	string? home = Environment.get_variable("HOME");

        foreach (var mon in this.monitors){
	    add_window(new Bar(mon, this));
	    // add_window(new Notify(mon));
	}
	apply_css(home+"/.config/ags/"+"style.css");
    }

    public static int main(string[] args) {
	// if (args.length <= 1){
	//     print("usage:  "+"args[0]"+" <csspath>");
	//     return 0;
	// }
	// path = args[1];
        var instance_name = "vala";

        App.instance = new App() {
            instance_name = instance_name
        };

        try {
            App.instance.acquire_socket();
            App.instance.run(null);
        } catch (Error err) {
            print(AstalIO.send_message(instance_name, string.joinv(" ", args)));
        }
	return 1;
    }
}
