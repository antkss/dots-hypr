import Greet from "gi://AstalGreet"
import { App } from "astal/gtk3"
App.start({
    main: ()=>{
	Greet.login("username", "password", "compositor", (_, res) => {
	    try {
		Greet.login_finish(res)
	    } catch (err) {
		printerr(err)
	    }
	})
    }


})

