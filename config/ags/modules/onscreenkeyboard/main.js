import PopupWindow from '../.widgethacks/popupwindow.js';
import OnScreenKeyboard from "./onscreenkeyboard.js";

export default () => PopupWindow({
    anchor: ['bottom'],
    name: 'osk',
    // showClassName: 'osk-show',
    // hideClassName: 'osk-hide',
    child: OnScreenKeyboard(),
});
