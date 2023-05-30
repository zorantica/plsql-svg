CREATE OR REPLACE PACKAGE BODY ZT_SVG AS

--constants
gcShapeTypeLine CONSTANT varchar2(50) := 'LINE';
gcShapeTypeCircle CONSTANT varchar2(50) := 'CIRCLE';
gcShapeTypeEllipse CONSTANT varchar2(50) := 'ELIPSE';
gcShapeTypeRectangle CONSTANT varchar2(50) := 'RECTANGLE';
gcShapeTypePolyline CONSTANT varchar2(50) := 'POLYLINE';
gcShapeTypePath CONSTANT varchar2(50) := 'PATH';
gcShapeTypeText CONSTANT varchar2(50) := 'TEXT';
gcShapeTypeSubText CONSTANT varchar2(50) := 'SUBTEXT';
gcShapeTypeCustom CONSTANT varchar2(50) := 'CUSTOM';
gcShapeTypeImage CONSTANT varchar2(50) := 'IMAGE';
gcShapeTypeGroup CONSTANT varchar2(50) := 'GROUP';
gcShapeTypeGroupEnd CONSTANT varchar2(50) := 'GROUPEND';

gcTagTypeUrlStart CONSTANT varchar2(50) := 'URL_START';
gcTagTypeUrlEnd CONSTANT varchar2(50) := 'URL_END';

gcDefaultStrokePrefix CONSTANT varchar2(128) := 'stroke';
gcDefaultFontPrefix CONSTANT varchar2(128) := 'font';


--strokes and fills
TYPE t_strokes IS TABLE OF zt_svg.r_stroke INDEX BY varchar2(128);

TYPE t_classes IS TABLE OF varchar2(4000) INDEX BY varchar2(255);

TYPE t_fills IS TABLE OF zt_svg.r_fill INDEX BY varchar2(128);

TYPE t_fonts IS TABLE OF zt_svg.r_font INDEX BY varchar2(128);


--shapes
TYPE r_line IS RECORD (
    x1 number,
    y1 number,
    x2 number,
    y2 number
);

TYPE r_circle IS RECORD (
    center_x number,
    center_y number,
    radius number
);

TYPE r_ellipse IS RECORD (
    center_x number,
    center_y number,
    radius_x number,
    radius_y number
);

TYPE r_polyline IS RECORD (
    points zt_svg.t_points,
    close_yn varchar2(1)
);

TYPE r_rectangle IS RECORD (
    x number,
    y number,
    width number,
    height number,
    radius_x number,
    radius_y number
);

TYPE r_text IS RECORD (
    supertext_ref varchar2(128),
    x number,
    y number,
    dx number,
    dy number,
    text varchar2(32000),
    align_h varchar2(20),
    align_v varchar2(20),
    font_reference varchar2(128),
    font zt_svg.r_font
);

TYPE r_path IS RECORD (
    start_x number,
    start_y number,
    path_commands zt_svg.t_path_commands,
    close_yn varchar2(1)
);

TYPE r_image_import IS RECORD (
    x number,
    y number,
    width number,
    height number,
    image_url varchar2(4000),
    image_or_use varchar2(50)
);



TYPE r_shape IS RECORD (
    id varchar2(128),
    shape_type varchar2(50),
    stroke zt_svg.r_stroke,
    stroke_reference varchar2(128),
    fill zt_svg.r_fill,
    class_name varchar2(255),
    style varchar2(32000),
    url zt_svg.r_url,
    transform zt_svg.r_transform,
    custom_attributes varchar2(32000),
    draw_in_defs_yn varchar2(1),
    tooltip varchar2(4000),
    line_data r_line,
    circle_data r_circle,
    ellipse_data r_ellipse,
    polyline_data r_polyline,
    rectangle_data r_rectangle,
    text_data r_text,
    path_data r_path,
    image_import_data r_image_import,
    custom_tag clob
);
TYPE t_shapes IS TABLE OF r_shape;


TYPE r_image IS RECORD (
    viewBoxX number,
    viewBoxY number,
    viewBoxWidth number,
    viewBoxHeight number,
    imageWidth varchar2(100),
    imageHeight varchar2(100),
    custom_attributes varchar2(32000),
    shapes t_shapes,
    strokes t_strokes,
    classes t_classes,
    fonts t_fonts
);

TYPE t_images IS TABLE OF r_image INDEX BY varchar2(128);


--package body level variables
grImages t_images;


--utilities
PROCEDURE p_add (
    p_text IN OUT clob,
    p_text_to_add varchar2,
    p_separator varchar2 default chr(10),
    p_tabs pls_integer default 0
) IS
BEGIN
    p_text := 
        p_text ||
        lpad(' ', (4 * p_tabs), ' ') || 
        p_text_to_add || 
        p_separator
    ;
END p_add;



--strokes
FUNCTION f_get_stroke (
    p_color varchar2 default null,
    p_opacity varchar2 default null,
    p_width number default null,
    p_linecap varchar2 default null,
    p_linejoin varchar2 default null,
    p_dasharray varchar2 default null
) RETURN zt_svg.r_stroke IS

    lrStroke zt_svg.r_stroke;

BEGIN
    lrStroke.color := nvl(p_color, zt_svg.grDefaultStroke.color);
    lrStroke.opacity := nvl(p_opacity, zt_svg.grDefaultStroke.opacity);
    lrStroke.width := nvl(p_width, zt_svg.grDefaultStroke.width);
    lrStroke.linecap := nvl(p_linecap, zt_svg.grDefaultStroke.linecap);
    lrStroke.linejoin := nvl(p_linejoin, zt_svg.grDefaultStroke.linejoin);
    lrStroke.dasharray := nvl(p_dasharray, zt_svg.grDefaultStroke.dasharray);

    RETURN lrStroke;
END f_get_stroke;

PROCEDURE p_create_shared_stroke (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_reference IN OUT varchar2,  --if null is passed -> automatic reference will be created
    p_color varchar2 default null,
    p_opacity varchar2 default null,
    p_width number default null,
    p_linecap varchar2 default null,
    p_linejoin varchar2 default null,
    p_dasharray varchar2 default null
) IS
BEGIN
    --define reference, if not provided
    if p_reference is null then
        p_reference := gcDefaultStrokePrefix || grImages(p_image_reference).strokes.count;
    end if;

    grImages(p_image_reference).strokes(p_reference) := 
        f_get_stroke (
            p_color => p_color,
            p_opacity => p_opacity,
            p_width => p_width,
            p_linecap => p_linecap,
            p_linejoin => p_linejoin,
            p_dasharray => p_dasharray
        )
    ;

END p_create_shared_stroke;


FUNCTION f_get_fill (
    p_color varchar2 default null,
    p_opacity varchar2 default null
) RETURN zt_svg.r_fill IS

    lrFill zt_svg.r_fill;

BEGIN
    lrFill.color := nvl(p_color, zt_svg.grDefaultFill.color);
    lrFill.opacity := nvl(p_opacity, zt_svg.grDefaultFill.opacity);
    
    RETURN lrFill;
END f_get_fill;



FUNCTION f_get_font (
    p_font_family varchar2 default null,
    p_font_style varchar2 default null,
    p_font_weight varchar2 default null,
    p_font_variant varchar2 default null,
    p_font_stretch varchar2 default null,
    p_font_size varchar2 default null,
    p_font_size_adjust varchar2 default null,
    p_kerning varchar2 default null,
    p_letter_spacing varchar2 default null,
    p_word_spacing varchar2 default null,
    p_text_decoration varchar2 default null
) RETURN r_font IS

    lrFont zt_svg.r_font;

BEGIN
    lrFont.font_family := nvl(p_font_family, zt_svg.grDefaultFont.font_family);
    lrFont.font_style := nvl(p_font_style, zt_svg.grDefaultFont.font_style);
    lrFont.font_weight := nvl(p_font_weight, zt_svg.grDefaultFont.font_weight);
    lrFont.font_variant := nvl(p_font_variant, zt_svg.grDefaultFont.font_variant);
    lrFont.font_stretch := nvl(p_font_stretch, zt_svg.grDefaultFont.font_stretch);
    lrFont.font_size := nvl(p_font_size, zt_svg.grDefaultFont.font_size);
    lrFont.font_size_adjust := nvl(p_font_size_adjust, zt_svg.grDefaultFont.font_size_adjust);
    lrFont.kerning := nvl(p_kerning, zt_svg.grDefaultFont.kerning);
    lrFont.letter_spacing := nvl(p_letter_spacing, zt_svg.grDefaultFont.letter_spacing);
    lrFont.word_spacing := nvl(p_word_spacing, zt_svg.grDefaultFont.word_spacing);
    lrFont.text_decoration := nvl(p_text_decoration, zt_svg.grDefaultFont.text_decoration);

    RETURN lrFont;
END f_get_font;

PROCEDURE p_create_shared_font (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_reference IN OUT varchar2,  --if null is passed -> automatic reference will be created and stored in this parameter
    p_font_family varchar2 default null,
    p_font_style varchar2 default null,
    p_font_weight varchar2 default null,
    p_font_variant varchar2 default null,
    p_font_stretch varchar2 default null,
    p_font_size varchar2 default null,
    p_font_size_adjust varchar2 default null,
    p_kerning varchar2 default null,
    p_letter_spacing varchar2 default null,
    p_word_spacing varchar2 default null,
    p_text_decoration varchar2 default null
) IS
BEGIN
    --define reference, if not provided
    if p_reference is null then
        p_reference := gcDefaultFontPrefix || grImages(p_image_reference).fonts.count;
    end if;

    grImages(p_image_reference).fonts(p_reference) := 
        f_get_font (
            p_font_family => p_font_family,
            p_font_style => p_font_style,
            p_font_weight => p_font_weight,
            p_font_variant => p_font_variant,
            p_font_stretch => p_font_stretch,
            p_font_size => p_font_size,
            p_font_size_adjust => p_font_size_adjust,
            p_kerning => p_kerning,
            p_letter_spacing => p_letter_spacing,
            p_word_spacing => p_word_spacing,
            p_text_decoration => p_text_decoration
        )
    ;

END p_create_shared_font;


--classes
PROCEDURE p_create_class (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_class_name varchar2,
    p_class_style varchar2
) IS
BEGIN
    grImages(p_image_reference).classes(p_class_name) := p_class_style;
END p_create_class;



--transform
FUNCTION f_get_transform (
    p_rotate_angle number default null,
    p_rotate_center_x number default null,
    p_rotate_center_y number default null,
    p_translate_x number default null,
    p_translate_y number default null,
    p_skew_x number default null,
    p_skew_y number default null,
    p_scale_x number default null,
    p_scale_y number default null,
    p_origin_x varchar2 default null,
    p_origin_y varchar2 default null
) RETURN r_transform IS

    lrTransform r_transform;

BEGIN
    --rotate
    lrTransform.rotate_angle := p_rotate_angle;
    lrTransform.rotate_center_x := p_rotate_center_x;
    lrTransform.rotate_center_y := p_rotate_center_y;
    
    --translate
    lrTransform.translate_x := p_translate_x;
    lrTransform.translate_y := p_translate_y;

    --skew
    lrTransform.skew_x := p_skew_x;
    lrTransform.skew_y := p_skew_y;

    --scale
    lrTransform.scale_x := p_scale_x;
    lrTransform.scale_y := p_scale_y;
    
    --origin
    lrTransform.origin_x := p_origin_x;
    lrTransform.origin_y := p_origin_y;

    RETURN lrTransform;
END f_get_transform;


--url
FUNCTION f_get_url (
    p_url varchar2,
    p_target varchar2 default null,
    p_custom_attributes varchar2 default null
) RETURN r_url IS

    lrURL r_url;

BEGIN
    lrUrl.url := p_url;
    lrUrl.target := p_target;
    lrUrl.custom_attributes := p_custom_attributes;

    RETURN lrURL;
END f_get_url;



--path commands
FUNCTION f_get_path_command (
    p_command varchar2,
    p_absolute_or_relative varchar2 default gcPathCoordinateAbsolute,
    p_x number default null,
    p_y number default null,
    p_control_point_x1 number default null,
    p_control_point_y1 number default null,
    p_control_point_x2 number default null,
    p_control_point_y2 number default null,
    p_arc_radius_x number default null,
    p_arc_radius_y number default null,
    p_arc_rotation number default null,
    p_arc_large_yn varchar2 default 'N',
    p_arc_sweep_yn varchar2 default 'N'
) RETURN r_path_command IS

    lrPathCommand r_path_command;

BEGIN
    lrPathCommand.command := p_command;
    lrPathCommand.absolute_or_relative := p_absolute_or_relative;
    lrPathCommand.x := p_x;
    lrPathCommand.y := p_y;
    lrPathCommand.control_point_x1 := p_control_point_x1;
    lrPathCommand.control_point_y1 := p_control_point_y1;
    lrPathCommand.control_point_x2 := p_control_point_x2;
    lrPathCommand.control_point_y2 := p_control_point_y2;
    lrPathCommand.arc_radius_x := p_arc_radius_x;
    lrPathCommand.arc_radius_y := p_arc_radius_y;
    lrPathCommand.arc_rotation := p_arc_rotation;
    lrPathCommand.arc_large_yn := p_arc_large_yn;
    lrPathCommand.arc_sweep_yn := p_arc_sweep_yn;
    
    RETURN lrPathCommand;
END f_get_path_command;


PROCEDURE p_add_path_command (
    p_commands IN OUT t_path_commands,
    p_command varchar2,
    p_absolute_or_relative varchar2 default gcPathCoordinateAbsolute,
    p_x number default null,
    p_y number default null,
    p_control_point_x1 number default null,
    p_control_point_y1 number default null,
    p_control_point_x2 number default null,
    p_control_point_y2 number default null,
    p_arc_radius_x number default null,
    p_arc_radius_y number default null,
    p_arc_rotation number default null,
    p_arc_large_yn varchar2 default 'N',
    p_arc_sweep_yn varchar2 default 'N'
) IS

    lnIndex pls_integer;

BEGIN
    p_commands.extend;
    lnIndex := p_commands.count;
    
    p_commands(lnIndex) :=
        f_get_path_command (
            p_command => p_command,
            p_absolute_or_relative => p_absolute_or_relative,
            p_x => p_x,
            p_y => p_y,
            p_control_point_x1 => p_control_point_x1,
            p_control_point_y1 => p_control_point_y1,
            p_control_point_x2 => p_control_point_x2,
            p_control_point_y2 => p_control_point_y2,            
            p_arc_radius_x => p_arc_radius_x,
            p_arc_radius_y => p_arc_radius_y,
            p_arc_rotation => p_arc_rotation,
            p_arc_large_yn => p_arc_large_yn,
            p_arc_sweep_yn => p_arc_sweep_yn
        )
    ;
     
END p_add_path_command;



--draw shapes
FUNCTION f_new_shape (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_shape_type varchar2,
    p_id varchar2 default null,
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) RETURN pls_integer IS

    lnIndex pls_integer;

BEGIN
    --add new shape
    grImages(p_image_reference).shapes.extend;
    lnIndex := grImages(p_image_reference).shapes.count;

    --shape type
    grImages(p_image_reference).shapes(lnIndex).shape_type := p_shape_type;

    --id
    grImages(p_image_reference).shapes(lnIndex).id := p_id;

    --style
    grImages(p_image_reference).shapes(lnIndex).style := p_style;
    
    --CSS class
    grImages(p_image_reference).shapes(lnIndex).class_name := p_class_name;

    --url
    grImages(p_image_reference).shapes(lnIndex).url := p_url;

    --transform
    grImages(p_image_reference).shapes(lnIndex).transform := p_transform;
    
    --custom attributes
    grImages(p_image_reference).shapes(lnIndex).custom_attributes := p_custom_attributes;
    
    --fill color and opacity
    grImages(p_image_reference).shapes(lnIndex).fill := p_fill;

    --set stroke
    if p_stroke_ref is not null then
        grImages(p_image_reference).shapes(lnIndex).stroke_reference := p_stroke_ref;
    else
        grImages(p_image_reference).shapes(lnIndex).stroke := p_stroke;
    end if;

    --draw in defs
    grImages(p_image_reference).shapes(lnIndex).draw_in_defs_yn := p_draw_in_defs_yn;

    --tooltip
    grImages(p_image_reference).shapes(lnIndex).tooltip := p_tooltip;

    RETURN lnIndex;
END f_new_shape;


PROCEDURE p_start_url (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_url r_url
) IS

    lnIndex pls_integer;

BEGIN
    --add new shape
    lnIndex := f_new_shape (
        p_image_reference => p_image_reference,
        p_shape_type => gcTagTypeUrlStart,
        p_url => p_url
    );
    
END p_start_url;

PROCEDURE p_finish_url (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex
) IS

    lnIndex pls_integer;

BEGIN
    --add new shape
    lnIndex := f_new_shape (
        p_image_reference => p_image_reference,
        p_shape_type => gcTagTypeUrlEnd
    );
END p_finish_url;




FUNCTION f_draw_line (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_x1 number,
    p_y1 number,
    p_x2 number,
    p_y2 number,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) RETURN pls_integer IS

    lnIndex pls_integer;

BEGIN
    --add new shape
    lnIndex := f_new_shape (
        p_image_reference => p_image_reference,
        p_shape_type => gcShapeTypeLine,
        p_id => p_id,
        p_stroke_ref => p_stroke_ref,
        p_stroke => p_stroke,
        p_style => p_style,
        p_class_name => p_class_name,
        p_url => p_url,
        p_transform => p_transform,
        p_custom_attributes => p_custom_attributes,
        p_draw_in_defs_yn => p_draw_in_defs_yn,
        p_tooltip => p_tooltip
    );

    --shape-specific attributes
    grImages(p_image_reference).shapes(lnIndex).line_data.x1 := p_x1;
    grImages(p_image_reference).shapes(lnIndex).line_data.y1 := p_y1;
    grImages(p_image_reference).shapes(lnIndex).line_data.x2 := p_x2;
    grImages(p_image_reference).shapes(lnIndex).line_data.y2 := p_y2;

    
    RETURN lnIndex;
    
END f_draw_line;

PROCEDURE p_draw_line (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_x1 number,
    p_y1 number,
    p_x2 number,
    p_y2 number,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) IS

    lnID pls_integer;

BEGIN
    lnID := f_draw_line (
        p_image_reference,
        p_id,
        p_x1, p_y1, p_x2, p_y2, 
        p_stroke_ref, p_stroke,
        p_style,
        p_class_name,
        p_url,
        p_transform,
        p_custom_attributes,
        p_draw_in_defs_yn,
        p_tooltip
    );
END p_draw_line;



FUNCTION f_draw_circle (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_center_x number,
    p_center_y number,
    p_radius number,
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) RETURN pls_integer IS

    lnIndex pls_integer;

BEGIN
    --add new shape
    lnIndex := f_new_shape (
        p_image_reference => p_image_reference,
        p_shape_type => gcShapeTypeCircle,
        p_id => p_id,
        p_fill => p_fill,
        p_stroke_ref => p_stroke_ref,
        p_stroke => p_stroke,
        p_style => p_style,
        p_class_name => p_class_name,
        p_url => p_url,
        p_transform => p_transform,
        p_custom_attributes => p_custom_attributes,
        p_draw_in_defs_yn => p_draw_in_defs_yn,
        p_tooltip => p_tooltip
    );

    --shape-specific attributes
    grImages(p_image_reference).shapes(lnIndex).circle_data.center_x := p_center_x;
    grImages(p_image_reference).shapes(lnIndex).circle_data.center_y := p_center_y;
    grImages(p_image_reference).shapes(lnIndex).circle_data.radius := p_radius;

    
    RETURN lnIndex;
    
END f_draw_circle;


PROCEDURE p_draw_circle (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_center_x number,
    p_center_y number,
    p_radius number,
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) IS

    lnID pls_integer;

BEGIN
    lnID := f_draw_circle (
        p_image_reference,
        p_id,
        p_center_x, p_center_y, p_radius,
        p_fill,
        p_stroke_ref, p_stroke,
        p_style,
        p_class_name,
        p_url,
        p_transform,
        p_custom_attributes,
        p_draw_in_defs_yn,
        p_tooltip
    );
    
END p_draw_circle;



FUNCTION f_draw_ellipse (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_center_x number,
    p_center_y number,
    p_radius_x number,
    p_radius_y number,
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) RETURN pls_integer IS

    lnIndex pls_integer;

BEGIN
    --add new shape
    lnIndex := f_new_shape (
        p_image_reference => p_image_reference,
        p_shape_type => gcShapeTypeEllipse,
        p_id => p_id,
        p_fill => p_fill,
        p_stroke_ref => p_stroke_ref,
        p_stroke => p_stroke,
        p_style => p_style,
        p_class_name => p_class_name,
        p_url => p_url,
        p_transform => p_transform,
        p_custom_attributes => p_custom_attributes,
        p_draw_in_defs_yn => p_draw_in_defs_yn,
        p_tooltip => p_tooltip
    );

    --shape-specific attributes
    grImages(p_image_reference).shapes(lnIndex).ellipse_data.center_x := p_center_x;
    grImages(p_image_reference).shapes(lnIndex).ellipse_data.center_y := p_center_y;
    grImages(p_image_reference).shapes(lnIndex).ellipse_data.radius_x := p_radius_x;
    grImages(p_image_reference).shapes(lnIndex).ellipse_data.radius_y := p_radius_y;

    
    RETURN lnIndex;
    
END f_draw_ellipse;


PROCEDURE p_draw_ellipse (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_center_x number,
    p_center_y number,
    p_radius_x number,
    p_radius_y number,
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) IS

    lnID pls_integer;

BEGIN
    lnID := f_draw_ellipse (
        p_image_reference,
        p_id,
        p_center_x, p_center_y, p_radius_x, p_radius_y,
        p_fill,
        p_stroke_ref, p_stroke,
        p_style,
        p_class_name,
        p_url,
        p_transform,
        p_custom_attributes,
        p_draw_in_defs_yn,
        p_tooltip
    );
    
END p_draw_ellipse;


FUNCTION f_draw_rectangle (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_top_left_x number,
    p_top_left_y number,
    p_width number,
    p_height number,
    p_radius_x number default null,
    p_radius_y number default null,
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) RETURN pls_integer IS

    lnIndex pls_integer;

BEGIN
    --add new shape
    lnIndex := f_new_shape (
        p_image_reference => p_image_reference,
        p_shape_type => gcShapeTypeRectangle,
        p_id => p_id,
        p_fill => p_fill,
        p_stroke_ref => p_stroke_ref,
        p_stroke => p_stroke,
        p_style => p_style,
        p_class_name => p_class_name,
        p_url => p_url,
        p_transform => p_transform,
        p_custom_attributes => p_custom_attributes,
        p_draw_in_defs_yn => p_draw_in_defs_yn,
        p_tooltip => p_tooltip
    );

    --shape-specific attributes
    grImages(p_image_reference).shapes(lnIndex).rectangle_data.x := p_top_left_x;
    grImages(p_image_reference).shapes(lnIndex).rectangle_data.y := p_top_left_y;
    grImages(p_image_reference).shapes(lnIndex).rectangle_data.width := p_width;
    grImages(p_image_reference).shapes(lnIndex).rectangle_data.height := p_height;
    grImages(p_image_reference).shapes(lnIndex).rectangle_data.radius_x := p_radius_x;
    grImages(p_image_reference).shapes(lnIndex).rectangle_data.radius_y := p_radius_y;

    
    RETURN lnIndex;
    
END f_draw_rectangle;

PROCEDURE p_draw_rectangle (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_top_left_x number,
    p_top_left_y number,
    p_width number,
    p_height number,
    p_radius_x number default null,
    p_radius_y number default null,
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) IS

    lnID pls_integer;

BEGIN
    lnID := f_draw_rectangle (
        p_image_reference,
        p_id,
        p_top_left_x, p_top_left_y, p_width, p_height, p_radius_x, p_radius_y,
        p_fill,
        p_stroke_ref, p_stroke,
        p_style,
        p_class_name,
        p_url,
        p_transform,
        p_custom_attributes,
        p_draw_in_defs_yn,
        p_tooltip
    );
    
END p_draw_rectangle;



FUNCTION f_draw_polyline (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_points zt_svg.t_points,
    p_close_yn varchar2 default 'N',
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) RETURN pls_integer IS

    lnIndex pls_integer;

BEGIN
    --add new shape
    lnIndex := f_new_shape (
        p_image_reference => p_image_reference,
        p_shape_type => gcShapeTypePolyline,
        p_id => p_id,
        p_fill => p_fill,
        p_stroke_ref => p_stroke_ref,
        p_stroke => p_stroke,
        p_style => p_style,
        p_class_name => p_class_name,
        p_url => p_url,
        p_transform => p_transform,
        p_custom_attributes => p_custom_attributes,
        p_draw_in_defs_yn => p_draw_in_defs_yn,
        p_tooltip => p_tooltip
    );

    --shape-specific attributes
    grImages(p_image_reference).shapes(lnIndex).polyline_data.points := p_points;
    grImages(p_image_reference).shapes(lnIndex).polyline_data.close_yn := p_close_yn;
    
    RETURN lnIndex;
    
END f_draw_polyline;


PROCEDURE p_draw_polyline (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_points zt_svg.t_points,
    p_close_yn varchar2 default 'N',
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) IS

    lnID pls_integer;

BEGIN
    lnID := f_draw_polyline (
        p_image_reference,
        p_id,
        p_points, p_close_yn,
        p_fill,
        p_stroke_ref, p_stroke,
        p_style,
        p_class_name,
        p_url,
        p_transform,
        p_custom_attributes,
        p_draw_in_defs_yn,
        p_tooltip
    );
END p_draw_polyline;




FUNCTION f_draw_text (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_supertext_ref pls_integer default null,
    p_id varchar2 default null,
    p_x number default null,
    p_y number default null,
    p_dx number default null,
    p_dy number default null,
    p_text varchar2,
    p_font_ref varchar2 default null,
    p_font r_font default grDefaultFont,
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null,
    p_align_h varchar2 default null,
    p_align_v varchar2 default null
) RETURN pls_integer IS

    lnIndex pls_integer;

BEGIN
    --add new shape
    lnIndex := f_new_shape (
        p_image_reference => p_image_reference,
        p_shape_type => CASE WHEN p_supertext_ref is null THEN gcShapeTypeText ELSE gcShapeTypeSubText END,
        p_id => p_id,
        p_fill => p_fill,
        p_stroke_ref => p_stroke_ref,
        p_stroke => p_stroke,
        p_style => p_style,
        p_class_name => p_class_name,
        p_url => p_url,
        p_transform => p_transform,
        p_custom_attributes => p_custom_attributes,
        p_draw_in_defs_yn => p_draw_in_defs_yn,
        p_tooltip => p_tooltip
    );

    --shape-specific attributes
    grImages(p_image_reference).shapes(lnIndex).text_data.supertext_ref := p_supertext_ref;
    grImages(p_image_reference).shapes(lnIndex).text_data.x := p_x;
    grImages(p_image_reference).shapes(lnIndex).text_data.y := p_y;
    grImages(p_image_reference).shapes(lnIndex).text_data.dx := p_dx;
    grImages(p_image_reference).shapes(lnIndex).text_data.dy := p_dy;
    grImages(p_image_reference).shapes(lnIndex).text_data.text := p_text;
    grImages(p_image_reference).shapes(lnIndex).text_data.font := p_font;
    grImages(p_image_reference).shapes(lnIndex).text_data.font_reference := p_font_ref;
    grImages(p_image_reference).shapes(lnIndex).text_data.align_h := p_align_h;
    grImages(p_image_reference).shapes(lnIndex).text_data.align_v := p_align_v;
    
    RETURN lnIndex;

END f_draw_text;

PROCEDURE p_draw_text (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_supertext_ref pls_integer default null,
    p_id varchar2 default null,
    p_x number default null,
    p_y number default null,
    p_dx number default null,
    p_dy number default null,
    p_text varchar2,
    p_font_ref varchar2 default null,
    p_font r_font default grDefaultFont,
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null,
    p_align_h varchar2 default null,
    p_align_v varchar2 default null
) IS

    lnID pls_integer;

BEGIN
    lnID := f_draw_text (
        p_image_reference,
        p_supertext_ref, 
        p_id,
        p_x, p_y, p_dx, p_dy, p_text,
        p_font_ref, p_font,
        p_fill,
        p_stroke_ref, p_stroke,
        p_style,
        p_class_name,
        p_url,
        p_transform,
        p_custom_attributes,
        p_draw_in_defs_yn,
        p_tooltip,
        p_align_h, p_align_v
    );
END p_draw_text;




FUNCTION f_draw_path (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_start_x number default 0,
    p_start_y number default 0,
    p_path_commands t_path_commands,
    p_close_path_yn varchar2 default 'N',
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) RETURN pls_integer IS

    lnIndex pls_integer;

BEGIN
    --add new shape
    lnIndex := f_new_shape (
        p_image_reference => p_image_reference,
        p_shape_type => gcShapeTypePath,
        p_id => p_id,
        p_fill => p_fill,
        p_stroke_ref => p_stroke_ref,
        p_stroke => p_stroke,
        p_style => p_style,
        p_class_name => p_class_name,
        p_url => p_url,
        p_transform => p_transform,
        p_custom_attributes => p_custom_attributes,
        p_draw_in_defs_yn => p_draw_in_defs_yn,
        p_tooltip => p_tooltip
    );

    --shape-specific attributes
    grImages(p_image_reference).shapes(lnIndex).path_data.start_x := p_start_x;
    grImages(p_image_reference).shapes(lnIndex).path_data.start_y := p_start_y;
    grImages(p_image_reference).shapes(lnIndex).path_data.path_commands := p_path_commands;
    grImages(p_image_reference).shapes(lnIndex).path_data.close_yn := p_close_path_yn;
    
    RETURN lnIndex;

END f_draw_path;

PROCEDURE p_draw_path (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_start_x number default 0,
    p_start_y number default 0,
    p_path_commands t_path_commands,
    p_close_path_yn varchar2 default 'N',
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) IS

    lnID pls_integer;

BEGIN
    lnID := f_draw_path (
        p_image_reference,
        p_id,
        p_start_x, p_start_y,
        p_path_commands,
        p_close_path_yn,
        p_fill,
        p_stroke_ref, p_stroke,
        p_style,
        p_class_name,
        p_url,
        p_transform,
        p_custom_attributes,
        p_draw_in_defs_yn,
        p_tooltip
    );
END p_draw_path;



FUNCTION f_draw_custom (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_custom_tag clob,
    p_url r_url default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) RETURN pls_integer IS

    lnIndex pls_integer;

BEGIN
    --add new shape
    lnIndex := f_new_shape (
        p_image_reference => p_image_reference,
        p_shape_type => gcShapeTypeCustom,
        p_url => p_url,
        p_draw_in_defs_yn => p_draw_in_defs_yn,
        p_tooltip => p_tooltip
    );

    --shape-specific attributes
    grImages(p_image_reference).shapes(lnIndex).custom_tag := p_custom_tag;
    
    RETURN lnIndex;

END f_draw_custom;

PROCEDURE p_draw_custom (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_custom_tag clob,
    p_url r_url default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) IS

    lnID pls_integer;

BEGIN
    lnID := f_draw_custom (
        p_image_reference,
        p_custom_tag,
        p_url,
        p_draw_in_defs_yn,
        p_tooltip
    );
END p_draw_custom;



FUNCTION f_insert_image (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_x number default null,
    p_y number default null,
    p_width number default null,
    p_height number default null,
    p_image_url varchar2,
    p_image_or_use varchar2 default gcElementImage,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_tooltip varchar2 default null
) RETURN pls_integer IS

    lnIndex pls_integer;

BEGIN
    --add new shape
    lnIndex := f_new_shape (
        p_image_reference => p_image_reference,
        p_id => p_id,
        p_shape_type => gcShapeTypeImage,
        p_class_name => p_class_name,
        p_url => p_url,
        p_transform => p_transform,
        p_custom_attributes => p_custom_attributes,
        p_tooltip => p_tooltip
    );

    --shape-specific attributes
    grImages(p_image_reference).shapes(lnIndex).image_import_data.x := p_x;
    grImages(p_image_reference).shapes(lnIndex).image_import_data.y := p_y;
    grImages(p_image_reference).shapes(lnIndex).image_import_data.width := p_width;
    grImages(p_image_reference).shapes(lnIndex).image_import_data.height := p_height;
    grImages(p_image_reference).shapes(lnIndex).image_import_data.image_url := p_image_url;
    grImages(p_image_reference).shapes(lnIndex).image_import_data.image_or_use := p_image_or_use;
    
    RETURN lnIndex;

END f_insert_image;

PROCEDURE p_insert_image (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_x number default null,
    p_y number default null,
    p_width number default null,
    p_height number default null,
    p_image_url varchar2,
    p_image_or_use varchar2 default gcElementImage,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_tooltip varchar2 default null
) IS

    lnID pls_integer;

BEGIN
    lnID := f_insert_image (
        p_image_reference,
        p_id,
        p_x, p_y, p_width, p_height,
        p_image_url,
        p_image_or_use,
        p_class_name,
        p_url,
        p_transform,
        p_custom_attributes,
        p_tooltip
    );
END p_insert_image;



FUNCTION f_draw_group (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) RETURN pls_integer IS

    lnIndex pls_integer;

BEGIN
    --add new shape
    lnIndex := f_new_shape (
        p_image_reference => p_image_reference,
        p_shape_type => gcShapeTypeGroup,
        p_id => p_id,
        p_fill => p_fill,
        p_stroke_ref => p_stroke_ref,
        p_stroke => p_stroke,
        p_style => p_style,
        p_class_name => p_class_name,
        p_url => p_url,
        p_transform => p_transform,
        p_custom_attributes => p_custom_attributes,
        p_draw_in_defs_yn => p_draw_in_defs_yn,
        p_tooltip => p_tooltip
    );

    --shape-specific attributes
    
    RETURN lnIndex;
    
END f_draw_group;



PROCEDURE p_draw_group (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_fill zt_svg.r_fill default null,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default null,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null,
    p_draw_in_defs_yn varchar2 default 'N',
    p_tooltip varchar2 default null
) IS

    lnID pls_integer;

BEGIN
    lnID := f_draw_group (
        p_image_reference,
        p_id,
        p_fill,
        p_stroke_ref, p_stroke,
        p_style,
        p_class_name,
        p_url,
        p_transform,
        p_custom_attributes,
        p_draw_in_defs_yn,
        p_tooltip
    );
END p_draw_group;

PROCEDURE p_draw_group_end (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_draw_in_defs_yn varchar2 default 'N'
) IS

    lnIndex pls_integer;

BEGIN
    --add new shape
    lnIndex := f_new_shape (
        p_image_reference => p_image_reference,
        p_shape_type => gcShapeTypeGroupEnd,
        p_draw_in_defs_yn => p_draw_in_defs_yn
    );
    
END p_draw_group_end;




--image handling
PROCEDURE p_new_image (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_viewbox_X number default null,
    p_viewbox_Y number default null,
    p_viewbox_width number default null,
    p_viewbox_height number default null,
    p_image_width varchar2 default null,
    p_image_height varchar2 default null,
    p_custom_attributes varchar2 default null
) IS
BEGIN
    --clear image
    grImages(p_image_reference) := null;
    
    --initialize collections
    grImages(p_image_reference).shapes := t_shapes();
    grImages(p_image_reference).strokes := t_strokes();
    grImages(p_image_reference).classes := t_classes();
    grImages(p_image_reference).fonts := t_fonts();
    

    --set image attributes
    grImages(p_image_reference).viewBoxX := p_viewbox_x;
    grImages(p_image_reference).viewBoxY := p_viewbox_y;
    grImages(p_image_reference).viewBoxWidth := p_viewbox_width;
    grImages(p_image_reference).viewBoxHeight := p_viewbox_height;
    grImages(p_image_reference).imageWidth := p_image_width;
    grImages(p_image_reference).imageHeight := p_image_height;
    
    --custom attributes
    grImages(p_image_reference).custom_attributes := p_custom_attributes;
    
END p_new_image;



--finish image
PROCEDURE p_add_attr (
    p_text IN OUT varchar2,
    p_attribute varchar2,
    p_value varchar2
) IS
BEGIN
    if p_value is not null then
        p_add(p_text, p_attribute || '="' || p_value || '" ', null);
    end if;
END p_add_attr;


FUNCTION f_shape_stroke (
    p_stroke zt_svg.r_stroke
) RETURN varchar2 IS

    lcStroke varchar2(2000);

BEGIN
    p_add_attr(lcStroke, 'stroke', p_stroke.color);
    p_add_attr(lcStroke, 'stroke-opacity', p_stroke.opacity);
    p_add_attr(lcStroke, 'stroke-width', p_stroke.width);
    p_add_attr(lcStroke, 'stroke-linecap', p_stroke.linecap);
    p_add_attr(lcStroke, 'stroke-linejoin', p_stroke.linejoin);
    p_add_attr(lcStroke, 'stroke-dasharray', p_stroke.dasharray);

    RETURN lcStroke || ' ';
    
END f_shape_stroke;


FUNCTION f_shape_fill (
    p_fill r_fill
) RETURN varchar2 IS

    lcFill varchar2(4000);

BEGIN
    p_add_attr(lcFill, 'fill', p_fill.color);
    p_add_attr(lcFill, 'fill-opacity', p_fill.opacity);
    
    RETURN lcFill || ' ';
    
END f_shape_fill;


FUNCTION f_text_font (
    p_font zt_svg.r_font
) RETURN varchar2 IS

    lcFont varchar2(4000);

BEGIN
    p_add_attr(lcFont, 'font-family', p_font.font_family);
    p_add_attr(lcFont, 'font-style', p_font.font_style);
    p_add_attr(lcFont, 'font-weight', p_font.font_weight);
    p_add_attr(lcFont, 'font-variant', p_font.font_variant);
    p_add_attr(lcFont, 'font-stretch', p_font.font_stretch);
    p_add_attr(lcFont, 'font-size', p_font.font_size);
    p_add_attr(lcFont, 'font-size_adjust', p_font.font_size_adjust);
    p_add_attr(lcFont, 'kerning', p_font.kerning);
    p_add_attr(lcFont, 'letter-spacing', p_font.letter_spacing);
    p_add_attr(lcFont, 'word-spacing', p_font.word_spacing);
    p_add_attr(lcFont, 'text-decoration', p_font.text_decoration);

    RETURN lcFont || ' ';
END f_text_font;


FUNCTION f_get_shape_script (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_shape r_shape,
    p_shape_index pls_integer
) RETURN clob IS

    lcID varchar2(500);
    lcStroke varchar2(4000);
    lcStyle varchar2(4000);
    lcClass varchar2(255);
    lcFill varchar2(4000);
    lcFont varchar2(4000);
    lcTransform varchar2(4000);
    lcCustomAttributes varchar2(32000);
    lcTooltip varchar2(5000);

    lcScript clob;

BEGIN
    --URL wrapper - start
    if p_shape.url.url is not null then
        p_add(lcScript, '<a href="' || p_shape.url.url || '"');
        p_add_attr(lcScript, 'target', p_shape.url.target);

        if p_shape.url.custom_attributes is not null then
            p_add(lcScript, p_shape.url.custom_attributes);
        end if;

        p_add(lcScript, '>');
        
    end if;
    

    --UNIVERSAL ATTRIBUTES (ID, STROKE, STYLE, CLASS, TRANSFORM)
    if p_shape.id is not null then
        lcID := 'id="' || p_shape.id || '" ';
    end if;

    if p_shape.style is not null then
        lcStyle := 'style="' || p_shape.style || '" ';
    end if;

    if p_shape.class_name is not null then
        lcClass := 'class="' || p_shape.class_name || '" ';
    end if;
    
    lcStroke := 
        f_shape_stroke( 
            CASE 
                WHEN p_shape.stroke_reference is not null THEN grImages(p_image_reference).strokes( p_shape.stroke_reference )
                ELSE p_shape.stroke
            END 
        );
        
    lcFill := f_shape_fill(p_shape.fill);


    --transform
    if p_shape.transform.rotate_angle is not null then
        p_add(
            lcTransform, 
            'rotate(' || 
            p_shape.transform.rotate_angle || 
            CASE 
                WHEN p_shape.transform.rotate_center_x is not null AND p_shape.transform.rotate_center_y is not null THEN ',' || p_shape.transform.rotate_center_x || ',' || p_shape.transform.rotate_center_y
                ELSE null
            END ||
            ') ', null);
    end if;

    if p_shape.transform.translate_x is not null then
        p_add(
            lcTransform, 
            'translate(' || 
            p_shape.transform.translate_x || ',' || nvl(p_shape.transform.translate_y, 0) || 
            ') ', null);
    end if;

    if p_shape.transform.skew_x is not null then
        p_add(
            lcTransform, 
            'skewX(' || 
            p_shape.transform.skew_x || 
            ') ', null);
    end if;

    if p_shape.transform.skew_y is not null then
        p_add(
            lcTransform, 
            'skewX(' || 
            p_shape.transform.skew_y || 
            ') ', null);
    end if;

    if p_shape.transform.scale_x is not null then
        p_add(
            lcTransform, 
            'scale(' || 
            p_shape.transform.scale_x || CASE WHEN p_shape.transform.scale_y is not null THEN ',' || p_shape.transform.scale_y ELSE null END || 
            ') ', null);
    end if;

    if lcTransform is not null then
        lcTransform := 'transform="' || lcTransform || '" ';
    end if;

    if p_shape.transform.origin_x is not null then
        p_add(
            lcTransform, 
            'transform-origin="' || 
            p_shape.transform.origin_x || ' ' || p_shape.transform.origin_y || 
            '" ', null);
    end if;
    
    --custom attributes
    lcCustomAttributes := CASE WHEN p_shape.custom_attributes is not null THEN p_shape.custom_attributes || ' ' ELSE null END;


    --tooltip / title
    if p_shape.tooltip is not null then
        lcTooltip := '<title>' || p_shape.tooltip || '</title>';
    end if;

    --shape-specific attributes
    if p_shape.shape_type = gcShapeTypeLine then
        p_add(lcScript, '<line ', null, 1);
        p_add(lcScript, 'x1="' || p_shape.line_data.x1 || '" ', null);
        p_add(lcScript, 'y1="' || p_shape.line_data.y1 || '" ', null);
        p_add(lcScript, 'x2="' || p_shape.line_data.x2 || '" ', null);
        p_add(lcScript, 'y2="' || p_shape.line_data.y2 || '" ', null);

        p_add(lcScript, lcId || lcStyle || lcClass || lcStroke || lcFill || lcTransform || lcCustomAttributes, null);
        
        p_add(lcScript, '>' || lcTooltip || '</line>');

    elsif p_shape.shape_type = gcShapeTypeCircle then
        p_add(lcScript, '<circle ', null, 1);

        p_add(lcScript, 'cx="' || p_shape.circle_data.center_x || '" ', null);
        p_add(lcScript, 'cy="' || p_shape.circle_data.center_y || '" ', null);
        p_add(lcScript, 'r="' || p_shape.circle_data.radius || '" ', null);

        p_add(lcScript, lcId || lcStyle || lcClass || lcStroke || lcFill || lcTransform || lcCustomAttributes, null);
        p_add(lcScript, '>' || lcTooltip || '</circle>');

    elsif p_shape.shape_type = gcShapeTypeEllipse then
        p_add(lcScript, '<ellipse ', null, 1);

        p_add(lcScript, 'cx="' || p_shape.ellipse_data.center_x || '" ', null);
        p_add(lcScript, 'cy="' || p_shape.ellipse_data.center_y || '" ', null);
        p_add(lcScript, 'rx="' || p_shape.ellipse_data.radius_x || '" ', null);
        p_add(lcScript, 'ry="' || p_shape.ellipse_data.radius_y || '" ', null);

        p_add(lcScript, lcId || lcStyle || lcClass || lcStroke || lcFill || lcTransform || lcCustomAttributes, null);
        p_add(lcScript, '>' || lcTooltip || '</ellipse>');

    elsif p_shape.shape_type = gcShapeTypeRectangle then
        p_add(lcScript, '<rect ', null, 1);

        p_add(lcScript, 'x="' || p_shape.rectangle_data.x || '" ', null);
        p_add(lcScript, 'y="' || p_shape.rectangle_data.y || '" ', null);
        p_add(lcScript, 'width="' || p_shape.rectangle_data.width || '" ', null);
        p_add(lcScript, 'height="' || p_shape.rectangle_data.height || '" ', null);
        
        if p_shape.rectangle_data.radius_x is not null then
            p_add(lcScript, 'rx="' || p_shape.rectangle_data.radius_x || '" ', null);
        end if;

        if p_shape.rectangle_data.radius_y is not null then
            p_add(lcScript, 'ry="' || p_shape.rectangle_data.radius_y || '" ', null);
        end if;
        

        p_add(lcScript, lcId || lcStyle || lcClass || lcStroke || lcFill || lcTransform || lcCustomAttributes, null);
        p_add(lcScript, '>' || lcTooltip || '</rect>');

    elsif p_shape.shape_type = gcShapeTypePolyline then
        p_add(lcScript, '<' || CASE WHEN p_shape.polyline_data.close_yn = 'Y' THEN 'polygon' ELSE 'polyline' END || ' ', null, 1);

        p_add(lcScript, 'points="', null);
        
        FOR p IN 1 .. p_shape.polyline_data.points.count LOOP
            p_add(
                lcScript, 
                p_shape.polyline_data.points(p).x || ' ' ||
                p_shape.polyline_data.points(p).y || ', ', 
                null
            );
        END LOOP;
        
        p_add(lcScript, '"', null);

        p_add(lcScript, lcId || lcStyle || lcClass || lcStroke || lcFill || lcTransform || lcCustomAttributes, null);
        
        p_add(lcScript, '>' || lcTooltip || '</'|| CASE WHEN p_shape.polyline_data.close_yn = 'Y' THEN 'polygon' ELSE 'polyline' END || '>');

    elsif p_shape.shape_type in (gcShapeTypeText, gcShapeTypeSubText) then
    
        DECLARE
            FUNCTION f_text_tag RETURN varchar2 IS
            BEGIN
                RETURN CASE p_shape.shape_type WHEN gcShapeTypeText THEN 'text' ELSE 'tspan' END;
            END;
            
        BEGIN
            lcFont := 
                f_text_font ( 
                    CASE 
                        WHEN p_shape.text_data.font_reference is not null THEN grImages(p_image_reference).fonts( p_shape.text_data.font_reference )
                        ELSE p_shape.text_data.font
                    END 
                );

            p_add(lcScript, '<' || f_text_tag || ' ', null, 1);

            p_add_attr(lcScript, 'x', p_shape.text_data.x);
            p_add_attr(lcScript, 'y', p_shape.text_data.y);
            p_add_attr(lcScript, 'dx', p_shape.text_data.dx);
            p_add_attr(lcScript, 'dy', p_shape.text_data.dy);

            p_add_attr(lcScript, 'text-anchor', p_shape.text_data.align_h);
            p_add_attr(lcScript, 'dominant-baseline', p_shape.text_data.align_v);

            p_add(lcScript, lcId || lcStyle || lcClass || lcStroke || lcFill || lcFont || lcTransform || lcCustomAttributes, null);
            p_add(lcScript, '>' || p_shape.text_data.text, null);
            
            --subtext
            FOR st IN 1 .. grImages(p_image_reference).shapes.count LOOP
                if grImages(p_image_reference).shapes(st).text_data.supertext_ref = p_shape_index then
                
                    p_add (
                        lcScript,
                        f_get_shape_script (
                            p_image_reference => p_image_reference,
                            p_shape => grImages(p_image_reference).shapes(st),
                            p_shape_index => st
                        ),
                        null
                    );

                end if;
            END LOOP;
            
            p_add(lcScript, '</' || f_text_tag || '>');
        END;

    elsif p_shape.shape_type = gcShapeTypePath then
        p_add(lcScript, '<path d="', null, 1);
        
        --start point
        p_add(lcScript, 'M' || p_shape.path_data.start_x || ' ' || p_shape.path_data.start_y, ' ');
        
        DECLARE
            
            PROCEDURE p_command_script (
                p_command zt_svg.r_path_command
            ) IS
            BEGIN
                if p_command.command = zt_svg.gcPathCmdLine then
                    p_add(
                        lcScript, 
                            CASE WHEN p_command.absolute_or_relative = zt_svg.gcPathCoordinateAbsolute THEN 'L' ELSE 'l' END || 
                            p_command.x || ' ' || 
                            p_command.y
                            , 
                        ' '
                    );

                elsif p_command.command = zt_svg.gcPathCmdLineHorizontal then
                    p_add(
                        lcScript, 
                            CASE WHEN p_command.absolute_or_relative = zt_svg.gcPathCoordinateAbsolute THEN 'H' ELSE 'h' END || 
                            p_command.x
                            , 
                        ' '
                    );

                elsif p_command.command = zt_svg.gcPathCmdLineVertical then
                    p_add(
                        lcScript, 
                            CASE WHEN p_command.absolute_or_relative = zt_svg.gcPathCoordinateAbsolute THEN 'V' ELSE 'v' END || 
                            p_command.y
                            , 
                        ' '
                    );

                elsif p_command.command = zt_svg.gcPathCmdBezier then
                    p_add(
                        lcScript, 
                            CASE WHEN p_command.absolute_or_relative = zt_svg.gcPathCoordinateAbsolute THEN 'C' ELSE 'c' END || 
                            p_command.control_point_x1 || ' ' || p_command.control_point_y1 || ', ' ||
                            p_command.control_point_x2 || ' ' || p_command.control_point_y2 || ', ' ||
                            p_command.x || ' ' || p_command.y
                            ,
                        ' '
                    );

                elsif p_command.command = zt_svg.gcPathCmdBezierAdd then
                    p_add(
                        lcScript, 
                            CASE WHEN p_command.absolute_or_relative = zt_svg.gcPathCoordinateAbsolute THEN 'S' ELSE 's' END || 
                            p_command.control_point_x2 || ' ' || p_command.control_point_y2 || ', ' ||
                            p_command.x || ' ' || p_command.y
                            ,
                        ' '
                    );

                elsif p_command.command = zt_svg.gcPathCmdBezierQuadratic then
                    p_add(
                        lcScript, 
                            CASE WHEN p_command.absolute_or_relative = zt_svg.gcPathCoordinateAbsolute THEN 'Q' ELSE 'q' END || 
                            p_command.control_point_x1 || ' ' || p_command.control_point_y1 || ', ' ||
                            p_command.x || ' ' || p_command.y
                            ,
                        ' '
                    );

                elsif p_command.command = zt_svg.gcPathCmdBezierQuadraticAdd then
                    p_add(
                        lcScript, 
                            CASE WHEN p_command.absolute_or_relative = zt_svg.gcPathCoordinateAbsolute THEN 'T' ELSE 't' END || 
                            p_command.x || ' ' || p_command.y
                            ,
                        ' '
                    );

                elsif p_command.command = zt_svg.gcPathCmdArc then
                    p_add(
                        lcScript, 
                            CASE WHEN p_command.absolute_or_relative = zt_svg.gcPathCoordinateAbsolute THEN 'A' ELSE 'a' END || 
                            p_command.arc_radius_x || ' ' || p_command.arc_radius_y || ', ' ||
                            p_command.arc_rotation || ', ' || 
                            CASE p_command.arc_large_yn WHEN 'Y' THEN 1 ELSE 0 END || ', ' ||
                            CASE p_command.arc_sweep_yn WHEN 'Y' THEN 1 ELSE 0 END || ', ' ||
                            p_command.x || ' ' || p_command.y
                            ,
                        ' '
                    );
                    
                end if;

            END p_command_script;
        
        BEGIN
            FOR cmd IN 1 .. p_shape.path_data.path_commands.count LOOP
                p_command_script(p_shape.path_data.path_commands(cmd));
            END LOOP;
        END;

        --close path
        if p_shape.path_data.close_yn = 'Y' then
            p_add(lcScript, 'Z', null);
        end if;
        

        p_add(lcScript, '" ' || lcId || lcStyle || lcClass || lcStroke || lcFill || lcTransform || lcCustomAttributes, null);
        p_add(lcScript, '>' || lcTooltip || '</path>');

    elsif p_shape.shape_type = gcShapeTypeCustom then
        p_add(lcScript, p_shape.custom_tag, null, 1);

    elsif p_shape.shape_type = gcShapeTypeImage then

        p_add(lcScript, '<' || p_shape.image_import_data.image_or_use || ' ', null, 1);
        p_add_attr(lcScript, 'x', p_shape.image_import_data.x);
        p_add_attr(lcScript, 'y', p_shape.image_import_data.y);
        p_add_attr(lcScript, 'width', p_shape.image_import_data.width);
        p_add_attr(lcScript, 'height', p_shape.image_import_data.height);
        p_add(lcScript, 'href="' || p_shape.image_import_data.image_url || '" ', null);

        p_add(lcScript, lcId || lcStyle || lcClass || lcStroke || lcFill || lcTransform || lcCustomAttributes, null);
        
        p_add(lcScript, '>' || lcTooltip || '</' || p_shape.image_import_data.image_or_use || '>');

    elsif p_shape.shape_type = gcShapeTypeGroup then

        p_add(lcScript, '<g ', null, 1);
        p_add(lcScript, lcId || lcStyle || lcClass || lcStroke || lcFill || lcTransform || lcCustomAttributes, null);
        p_add(lcScript, '>');

    elsif p_shape.shape_type = gcShapeTypeGroupEnd then

        p_add(lcScript, '</g>');

    end if;

    --URL wrapper - end
    if 
           (p_shape.url.url is not null and p_shape.shape_type <> gcTagTypeUrlStart) 
        or  p_shape.shape_type = gcTagTypeUrlEnd then
        p_add(lcScript, '</a>');
    end if;

    RETURN lcScript;
    
END f_get_shape_script;



FUNCTION f_finish_image (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex
) RETURN clob IS

    lcImage clob;

    PROCEDURE p_draw_shapes (
        p_draw_in_defs_yn varchar2
    ) IS
    BEGIN
        FOR obj IN 1 .. grImages(p_image_reference).shapes.count LOOP

            if grImages(p_image_reference).shapes(obj).draw_in_defs_yn = p_draw_in_defs_yn then
                p_add (
                    lcImage,
                    f_get_shape_script (
                        p_image_reference => p_image_reference,
                        p_shape => grImages(p_image_reference).shapes(obj),
                        p_shape_index => obj
                    )
                );
            end if;
        
        END LOOP;
    END p_draw_shapes;

BEGIN
    --initialize SVG and dimensions
    p_add(lcImage, '<svg xmlns="http://www.w3.org/2000/svg"', ' ');

    if 
            grImages(p_image_reference).viewBoxX is not null
        and grImages(p_image_reference).viewBoxY is not null
        and grImages(p_image_reference).viewBoxWidth is not null
        and grImages(p_image_reference).viewBoxHeight is not null
        then
            p_add(
                p_text => lcImage, 
                p_text_to_add => 'viewBox="' || 
                    grImages(p_image_reference).viewBoxX || ' ' || 
                    grImages(p_image_reference).viewBoxY || ' ' ||
                    grImages(p_image_reference).viewBoxWidth || ' ' ||
                    grImages(p_image_reference).viewBoxHeight || '"',
                p_tabs => 1
            );
    end if;

    p_add_attr(lcImage, 'width', grImages(p_image_reference).imageWidth);
    p_add_attr(lcImage, 'height', grImages(p_image_reference).imageHeight);
    
    if grImages(p_image_reference).custom_attributes is not null then
        p_add(
            p_text => lcImage, 
            p_text_to_add => grImages(p_image_reference).custom_attributes,
            p_tabs => 1
        );
    end if;

    --default stroke and fill
    p_add(
        p_text => lcImage, 
        p_text_to_add => f_shape_stroke(grDefaultStroke),
        p_separator => ' '
    );

    p_add(
        p_text => lcImage, 
        p_text_to_add => f_shape_fill(grDefaultFill),
        p_separator => ' '
    );

    --close SVG tag
    p_add(lcImage, '>');
    

    p_add(
        p_text => lcImage, 
        p_text_to_add => '<defs>', 
        p_tabs => 1
    );
    
    --add classes
    if grImages(p_image_reference).classes.count > 0 then

        p_add(
            p_text => lcImage, 
            p_text_to_add => '<style type="text/css">', 
            p_tabs => 2
        );
        p_add(
            p_text => lcImage, 
            p_text_to_add => '<![CDATA[', 
            p_tabs => 3
        );


        DECLARE
            lcClassName varchar2(255);
            
        BEGIN
            lcClassName := grImages(p_image_reference).classes.first;
            
            LOOP
                EXIT WHEN lcClassName is null;

                p_add(
                    p_text => lcImage, 
                    p_text_to_add => lcClassName || ' {', 
                    p_tabs => 4
                );

                p_add(
                    p_text => lcImage, 
                    p_text_to_add => grImages(p_image_reference).classes(lcClassName), 
                    p_tabs => 5
                );

                p_add(
                    p_text => lcImage, 
                    p_text_to_add => '}', 
                    p_tabs => 4
                );
                
                lcClassName := grImages(p_image_reference).classes.next(lcClassName);
                
            END LOOP;
            
        END;

        p_add(
            p_text => lcImage, 
            p_text_to_add => ']]>', 
            p_tabs => 3
        );
        p_add(
            p_text => lcImage, 
            p_text_to_add => '</style>', 
            p_tabs => 2
        );

    end if;

    p_draw_shapes(p_draw_in_defs_yn => 'Y');

    p_add(
        p_text => lcImage, 
        p_text_to_add => '</defs>', 
        p_tabs => 1
    );
    

    --draw shapes
    p_draw_shapes(p_draw_in_defs_yn => 'N');
/*
    FOR obj IN 1 .. grImages(p_image_reference).shapes.count LOOP

        p_add (
            lcImage,
            f_get_shape_script (
                p_image_reference => p_image_reference,
                p_shape => grImages(p_image_reference).shapes(obj),
                p_shape_index => obj
            )
        );
    
    END LOOP;
*/

    --close svg
    p_add(lcImage, '</svg>');
    
    --return generated image
    RETURN lcImage;
    
END f_finish_image;

END ZT_SVG;