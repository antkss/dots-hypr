import Widget from 'resource:///com/github/Aylur/ags/widget.js';
const { Box, Scrollable } = Widget;
import QuickScripts from './tools/quickscripts.js';
import ColorPicker from './tools/colorpicker.js';
import materialpick from './tools/materialswitch.js' 
// import musicControl from './tools/Media.js'
import musicControl from '../indicators/musiccontrols.js'

export default Scrollable({
    hscroll: "never",
    vscroll: "automatic",
    child: Box({
        vertical: true,
        className: 'spacing-v-10',
        children: [
            QuickScripts(),
            ColorPicker(),
	    materialpick(),
	musicControl(),
        ]
    })
});
