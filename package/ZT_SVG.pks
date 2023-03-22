CREATE OR REPLACE PACKAGE ZT_SVG AS
/******************************************************************************
    Author:     Zoran Tica
                The Right Thing Solutions
                https://right-thing.solutions/
    
    PURPOSE:    A package for Scalable Vector Graphics (SVG) images generation 

    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        27/01/2023  Zoran Tica       First version of package.

    ----------------------------------------------------------------------------
    Copyright (C) 2023 - Zoran Tica

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
    ----------------------------------------------------------------------------
*/

--global variables
gcDefaultIndex CONSTANT varchar2(128) := 'image1';


--------------------------  VARIOUS CONSTANTS  --------------------------

--stroke color
gcStrokeColorNone CONSTANT varchar2(50) := 'none';
gcStrokeColorBlack CONSTANT varchar2(50) := 'black';
gcStrokeColorSilver CONSTANT varchar2(50) := 'silver';
gcStrokeColorGray CONSTANT varchar2(50) := 'gray';
gcStrokeColorWhite CONSTANT varchar2(50) := 'white';
gcStrokeColorMaroon CONSTANT varchar2(50) := 'maroon';
gcStrokeColorRed CONSTANT varchar2(50) := 'red';
gcStrokeColorPurple CONSTANT varchar2(50) := 'purple';
gcStrokeColorFuchsia CONSTANT varchar2(50) := 'fuchsia';
gcStrokeColorGreen CONSTANT varchar2(50) := 'green';
gcStrokeColorLime CONSTANT varchar2(50) := 'lime';
gcStrokeColorOlive CONSTANT varchar2(50) := 'olive';
gcStrokeColorYellow CONSTANT varchar2(50) := 'yellow';
gcStrokeColorNavy CONSTANT varchar2(50) := 'navy';
gcStrokeColorBlue CONSTANT varchar2(50) := 'blue';
gcStrokeColorTeal CONSTANT varchar2(50) := 'teal';
gcStrokeColorAqua CONSTANT varchar2(50) := 'aqua';

--stroke line cap
gcStrokeLineCapButt CONSTANT varchar2(50) := 'butt';
gcStrokeLineCapSquare CONSTANT varchar2(50) := 'square';
gcStrokeLineCapRound CONSTANT varchar2(50) := 'round';

--stroke line join
gcStrokeLineJoinMiter CONSTANT varchar2(50) := 'miter';
gcStrokeLineJoinRound CONSTANT varchar2(50) := 'round';
gcStrokeLineJoinBevel CONSTANT varchar2(50) := 'bevel';

--path commands
gcPathCmdLine CONSTANT varchar2(50) := 'L';
gcPathCmdLineHorizontal CONSTANT varchar2(50) := 'H';
gcPathCmdLineVertical CONSTANT varchar2(50) := 'V';
gcPathCmdBezier CONSTANT varchar2(50) := 'C';
gcPathCmdBezierAdd CONSTANT varchar2(50) := 'S';
gcPathCmdBezierQuadratic CONSTANT varchar2(50) := 'Q';
gcPathCmdBezierQuadraticAdd CONSTANT varchar2(50) := 'T';
gcPathCmdArc CONSTANT varchar2(50) := 'A';

--path coordinates
gcPathCoordinateAbsolute CONSTANT varchar2(50) := 'A';
gcPathCoordinateRelative CONSTANT varchar2(50) := 'R';

--image or use element
gcElementImage CONSTANT varchar2(50) := 'image';
gcElementUse CONSTANT varchar2(50) := 'use';


--------------------------  TYPES  --------------------------
TYPE r_point IS RECORD (
    x number,
    y number
);
TYPE t_points IS TABLE OF r_point;

TYPE r_font IS RECORD (
    font_family varchar2(500),
    font_style varchar2(500),
    font_weight varchar2(500),
    font_variant varchar2(500),
    font_stretch varchar2(500),
    font_size varchar2(500),
    font_size_adjust varchar2(500),
    kerning varchar2(500),
    letter_spacing varchar2(500),
    word_spacing varchar2(500),
    text_decoration varchar2(500)
);

grDefaultFont r_font := r_font (
    null, -- font_family varchar2(500),
    null, -- font_style varchar2(500),
    null, -- font_weight varchar2(500),
    null, -- font_variant varchar2(500),
    null, -- font_stretch varchar2(500),
    null, -- font_size varchar2(500),
    null, -- font_size_adjust varchar2(500),
    null, -- kerning varchar2(500),
    null, -- letter_spacing varchar2(500),
    null, -- word_spacing varchar2(500),
    null  -- text_decoration varchar2(500)
);

TYPE r_stroke IS RECORD (
    color varchar2(50),
    opacity number,
    width number,
    linecap varchar2(50),
    linejoin varchar2(50),
    dasharray varchar2(1000)
);

grDefaultStroke zt_svg.r_stroke := zt_svg.r_stroke (
    gcStrokeColorBlack,  --color
    null,  --opacity
    null,  --width
    null,  --linecap (check possible values in package definition - stroke line cap)
    null,  --linejoin check possible values in package definition - stroke line join)
    null  --dasharray
);

TYPE r_fill IS RECORD (
    color varchar2(50),
    opacity number
);

grDefaultFill zt_svg.r_fill := zt_svg.r_fill (
    gcStrokeColorNone,  --color
    null  --opacity
);

TYPE r_url IS RECORD (
    url varchar2(4000),
    target varchar2(100),
    custom_attributes varchar2(4000)
);

TYPE r_transform IS RECORD (
    rotate_angle number,
    rotate_center_x number,
    rotate_center_y number,
    translate_x number,
    translate_y number,
    skew_x number, 
    skew_y number,
    scale_x number,
    scale_y number,
    origin_x varchar2(50),
    origin_y varchar2(50)
);


TYPE r_path_command IS RECORD (
    command varchar2(50),
    absolute_or_relative varchar2(1),
    x number,
    y number,
    control_point_x1 number,
    control_point_y1 number,
    control_point_x2 number,
    control_point_y2 number,
    arc_radius_x number,
    arc_radius_y number,
    arc_rotation number,
    arc_large_yn varchar2(1),
    arc_sweep_yn varchar2(1)
);
TYPE t_path_commands IS TABLE OF r_path_command;

--------------------------  PROGRAM LOGIC  --------------------------

--image handling
PROCEDURE p_new_image (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_viewbox_X number default null,
    p_viewbox_Y number default null,
    p_viewbox_width number default null,
    p_viewbox_height number default null,
    p_image_width varchar2 default null,  --number or percentage
    p_image_height varchar2 default null  --number or percentage
);


--strokes and fills
FUNCTION f_get_stroke (
    p_color varchar2 default null,
    p_opacity varchar2 default null,
    p_width number default null,
    p_linecap varchar2 default null,
    p_linejoin varchar2 default null,
    p_dasharray varchar2 default null
) RETURN zt_svg.r_stroke;

PROCEDURE p_create_shared_stroke (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_reference IN OUT varchar2,  --if null is passed -> automatic reference will be created and stored in this parameter
    p_color varchar2 default null,
    p_opacity varchar2 default null,
    p_width number default null,
    p_linecap varchar2 default null,
    p_linejoin varchar2 default null,
    p_dasharray varchar2 default null
);

FUNCTION f_get_fill (
    p_color varchar2 default null,
    p_opacity varchar2 default null
) RETURN zt_svg.r_fill;


--fonts
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
) RETURN r_font;

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
);

--classes
PROCEDURE p_create_class (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_class_name varchar2,
    p_class_style varchar2
);


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
) RETURN r_transform;


--url
FUNCTION f_get_url (
    p_url varchar2,
    p_target varchar2 default null,
    p_custom_attributes varchar2 default null
) RETURN r_url;

PROCEDURE p_start_url (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_url r_url
);

PROCEDURE p_finish_url (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex
);


--path command
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
) RETURN r_path_command;

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
); 



--shapes
FUNCTION f_draw_line (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_x1 number,
    p_y1 number,
    p_x2 number,
    p_y2 number,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null
) RETURN pls_integer;

PROCEDURE p_draw_line (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_x1 number,
    p_y1 number,
    p_x2 number,
    p_y2 number,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null
);



FUNCTION f_draw_circle (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_center_x number,
    p_center_y number,
    p_radius number,
    p_fill zt_svg.r_fill default zt_svg.grDefaultFill,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null
) RETURN pls_integer;

PROCEDURE p_draw_circle (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_center_x number,
    p_center_y number,
    p_radius number,
    p_fill zt_svg.r_fill default zt_svg.grDefaultFill,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null,
    p_custom_attributes varchar2 default null
);



FUNCTION f_draw_ellipse (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_center_x number,
    p_center_y number,
    p_radius_x number,
    p_radius_y number,
    p_fill zt_svg.r_fill default zt_svg.grDefaultFill,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null
) RETURN pls_integer;

PROCEDURE p_draw_ellipse (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_center_x number,
    p_center_y number,
    p_radius_x number,
    p_radius_y number,
    p_fill zt_svg.r_fill default zt_svg.grDefaultFill,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null
);


FUNCTION f_draw_rectangle (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_top_left_x number,
    p_top_left_y number,
    p_width number,
    p_height number,
    p_radius_x number default null,
    p_radius_y number default null,
    p_fill zt_svg.r_fill default zt_svg.grDefaultFill,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null
) RETURN pls_integer;

PROCEDURE p_draw_rectangle (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_top_left_x number,
    p_top_left_y number,
    p_width number,
    p_height number,
    p_radius_x number default null,
    p_radius_y number default null,
    p_fill zt_svg.r_fill default zt_svg.grDefaultFill,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null
);


FUNCTION f_draw_polyline (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_points zt_svg.t_points,
    p_close_yn varchar2 default 'N',
    p_fill zt_svg.r_fill default zt_svg.grDefaultFill,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null
) RETURN pls_integer;

PROCEDURE p_draw_polyline (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_points zt_svg.t_points,
    p_close_yn varchar2 default 'N',
    p_fill zt_svg.r_fill default zt_svg.grDefaultFill,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null
);


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
    p_fill zt_svg.r_fill default zt_svg.grDefaultFill,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null
) RETURN pls_integer;

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
    p_fill zt_svg.r_fill default zt_svg.grDefaultFill,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null
);




FUNCTION f_draw_path (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_start_x number default 0,
    p_start_y number default 0,
    p_path_commands t_path_commands,
    p_close_path_yn varchar2 default 'N',
    p_fill zt_svg.r_fill default zt_svg.grDefaultFill,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null
) RETURN pls_integer;

PROCEDURE p_draw_path (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_start_x number default 0,
    p_start_y number default 0,
    p_path_commands t_path_commands,
    p_close_path_yn varchar2 default 'N',
    p_fill zt_svg.r_fill default zt_svg.grDefaultFill,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null
);



FUNCTION f_draw_custom (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_custom_tag clob,
    p_url r_url default null
) RETURN pls_integer;

PROCEDURE p_draw_custom (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_custom_tag clob,
    p_url r_url default null
);



FUNCTION f_insert_image (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_x number default null,
    p_y number default null,
    p_width number default null,
    p_height number default null,
    p_image_url varchar2,
    p_image_or_use varchar2 default gcElementImage,
    p_url r_url default null,
    p_transform r_transform default null
) RETURN pls_integer;

PROCEDURE p_insert_image (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_x number default null,
    p_y number default null,
    p_width number default null,
    p_height number default null,
    p_image_url varchar2,
    p_image_or_use varchar2 default gcElementImage,
    p_url r_url default null,
    p_transform r_transform default null
);


FUNCTION f_draw_group (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_fill zt_svg.r_fill default zt_svg.grDefaultFill,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null
) RETURN pls_integer;

PROCEDURE p_draw_group (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex,
    p_id varchar2 default null,
    p_fill zt_svg.r_fill default zt_svg.grDefaultFill,
    p_stroke_ref varchar2 default null,
    p_stroke r_stroke default zt_svg.grDefaultStroke,
    p_style varchar2 default null,
    p_class_name varchar2 default null,
    p_url r_url default null,
    p_transform r_transform default null
);

PROCEDURE p_draw_group_end (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex
);


--finish image and return HTML 
FUNCTION f_finish_image (
    p_image_reference varchar2 default zt_svg.gcDefaultIndex
) RETURN clob;


END ZT_SVG;
/