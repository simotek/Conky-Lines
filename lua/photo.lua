require 'cairo'


function conky_main_photo()

    if conky_window == nil then return end

    local w=conky_window.width
    local h=conky_window.height
    local cs=cairo_xlib_surface_create(conky_window.display,
            conky_window.drawable, conky_window.visual, w, h)
    cr=cairo_create(cs)

    image = cairo_image_surface_create_from_png("/home/simon/Pictures/grav.png");
	cairo_set_source_surface(cr, image, 10, 10);
	cairo_paint(cr);
	cairo_surface_destroy(image);

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
	updates=nil
	updates_gap=nil
end
