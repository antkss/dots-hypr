import Widget from 'resource:///com/github/Aylur/ags/widget.js';
const { Box, Scrollable } = Widget;
import QuickScripts from './tools/quickscripts.js';
import ColorPicker from './tools/colorpicker.js';
import materialpick from './tools/materialswitch.js' 
import notification from './notificationlist.js';

export const toolbox =  Scrollable({
    hscroll: "never",
    vscroll: "automatic",
    child: Box({
        vertical: true,
        className: 'side_chat',
        children: [
		QuickScripts(),
		ColorPicker(),
		materialpick(),
		notification(),
        ]
    })
});
