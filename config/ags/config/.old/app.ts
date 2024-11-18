import Bar from "./Bar"

App.start({
    main() {
        Bar(0)
        Bar(1) // instantiate for each monitor
    },
})
