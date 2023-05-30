CREATE OR REPLACE PACKAGE zt_svg_demo AS

PROCEDURE p_lines (
    p_step number
);

PROCEDURE p_lines_reuse_stroke (
    p_color varchar2
);

PROCEDURE p_lines_style (
    p_style varchar2
);

PROCEDURE p_lines_class (
    p_class_name varchar2,
    p_class_style varchar2
);


PROCEDURE p_circles;

PROCEDURE p_ellipse;


PROCEDURE p_polyline_01 (
    p_close_yn varchar2,
    p_fill_color varchar2
);

PROCEDURE p_polyline_02;


PROCEDURE p_rectangle_01 (
    p_round_corners number
);

PROCEDURE p_text_01 (
    p_text varchar2,
    p_subtext varchar2
);


PROCEDURE p_url_01;

PROCEDURE p_url_02;


FUNCTION f_transform_rotate (
    p_angle number
) RETURN varchar2;


PROCEDURE p_transform_translate (
    p_translate_x number
);


PROCEDURE p_transform_skew (
    p_skew_x number
);

PROCEDURE p_transform_scale (
    p_scale_x number,
    p_scale_y number
);


PROCEDURE p_path_01;

PROCEDURE p_path_02;

PROCEDURE p_path_03;


PROCEDURE p_insert_image (
    p_images_no pls_integer
);

PROCEDURE p_use (
    p_logos_no pls_integer
);

PROCEDURE p_use2;

PROCEDURE p_javascript_01;

PROCEDURE p_javascript_02;


PROCEDURE p_parking_demo (
    p_floor_id varchar2
);

END zt_svg_demo;