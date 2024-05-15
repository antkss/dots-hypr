import Widget from 'resource:///com/github/Aylur/ags/widget.js';
const { Box, Revealer,Window } = Widget;
import toolbox from './toolbox.js';
const widgetContent = Revealer({
	revealChild: true,
	child: toolbox,
});

const tools =  Box({
    // vertical: true,
className:"side_chat",
    vexpand: true,
    hexpand: true,
    children: [
        widgetContent,
    ],

});
export default () => Window({
	// className:"side_utils",
	visible: false,
    // keymode: 'on-demand',
    anchor: ['bottom','top','left'],
    name: 'side_utils',
    layer: 'top',
    child: tools,
});
