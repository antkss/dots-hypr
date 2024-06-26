import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import options from './options.js';

/** @param {import('types/widgets/box').BoxProps=} props */
export default props => Widget.Box()
    .hook(options.desktop.avatar, box => box.setCss(`
            background-image: url('/home/as/.images/logo.jpg');
        `))
    .on('size-allocate', box => {
        const h = box.get_allocated_height();
        box.set_size_request(Math.ceil(h * 1.1), -1);
    });
