CREATE OR REPLACE PACKAGE BODY zt_svg_demo AS


  procedure HtpPrn
  ( pclob clob) is
  v_excel varchar2(32000);
  v_clob clob := pclob;
  begin
      while length(v_clob) > 0 loop
        begin
            if length(v_clob) > 16000 then
                 v_excel:= substr(v_clob,1,16000);
                 htp.prn(v_excel);
                 v_clob:= substr(v_clob,length(v_excel)+1);
            else
                 v_excel := v_clob;
                 htp.prn(v_excel);
                 v_clob:='';
                 v_excel := '';
            end if;
        end;
      end loop;
  end;



PROCEDURE p_lines (
    p_step number
) IS

    lcImage clob;
    lnX number := 50;

BEGIN
    zt_svg.p_new_image (
        p_image_width => '50%',
        p_image_height => 200
    );

    LOOP
        EXIT WHEN lnX > 250;

        zt_svg.p_draw_line (
            p_x1 => lnX,
            p_y1 => 50,
            p_x2 => 250 - lnX,
            p_y2 => 150,
            p_stroke => zt_svg.f_get_stroke (
                p_color => 'rgb(0,0,' || lnX || ')',
                p_width => 2,
                p_dasharray => '3 3'
            )
        );
    
        lnX := lnX + p_step;
    END LOOP;
    
    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
END p_lines;


PROCEDURE p_lines_reuse_stroke (
    p_color varchar2
) IS

    lcImage clob;
    lnX number := 50;
    lnStep number := 10;
    
    lcStrokeRef varchar2(128);

BEGIN
    zt_svg.p_new_image (
        p_image_width => 320,
        p_image_height => 200
    );
    
    zt_svg.p_create_shared_stroke (
        p_reference => lcStrokeRef,
        p_color => p_color
    );

    LOOP
        EXIT WHEN lnX > 250;

        zt_svg.p_draw_line (
            p_x1 => lnX,
            p_id => 'line' || lnX,
            p_y1 => 50,
            p_x2 => 250 - lnX,
            p_y2 => 150,
            p_stroke_ref => lcStrokeRef
        );
    
        lnX := lnX + lnStep;
    END LOOP;
    
    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_lines_reuse_stroke;


PROCEDURE p_lines_style (
    p_style varchar2
) IS

    lcImage clob;
    lnX number := 50;
    lnStep number := 10;
    
    lcStrokeRef varchar2(128);

BEGIN
    zt_svg.p_new_image (
        p_image_width => 320,
        p_image_height => 200
    );
    
    LOOP
        EXIT WHEN lnX > 250;

        zt_svg.p_draw_line (
            p_x1 => lnX,
            p_id => 'line' || lnX,
            p_y1 => 50,
            p_x2 => 250 - lnX,
            p_y2 => 150,
            p_style => p_style
        );
    
        lnX := lnX + lnStep;
    END LOOP;
    
    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_lines_style;



PROCEDURE p_lines_class (
    p_class_name varchar2,
    p_class_style varchar2
) IS

    lcImage clob;
    lnX number := 50;
    lnStep number := 10;
    
BEGIN
    zt_svg.p_new_image (
        p_image_width => 320,
        p_image_height => 200
    );
    
    zt_svg.p_create_class (
        p_class_name => '.' || p_class_name,
        p_class_style => p_class_style
    );
    
    LOOP
        EXIT WHEN lnX > 250;

        zt_svg.p_draw_line (
            p_x1 => lnX,
            p_id => 'line' || lnX,
            p_y1 => 50,
            p_x2 => 250 - lnX,
            p_y2 => 150,
            p_class_name => p_class_name
        );
    
        lnX := lnX + lnStep;
    END LOOP;
    
    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_lines_class;



PROCEDURE p_circles IS

    lcImage clob;

BEGIN
    zt_svg.p_new_image (
        p_image_width => 320,
        p_image_height => 200
    );

    FOR t IN 1 .. 10 LOOP

        zt_svg.p_draw_circle (
            p_center_x => 100 + (t * 10),
            p_center_y => 100,
            p_radius => 50,
            p_fill => zt_svg.f_get_fill (
                p_color => zt_svg.gcStrokeColorRed,
                p_opacity => 0.3
            )
        );
    
    END LOOP;

    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_circles;


PROCEDURE p_ellipse IS

    lcImage clob;

BEGIN
    zt_svg.p_new_image (
        p_image_width => 320,
        p_image_height => 200
    );

    FOR t IN 1 .. 10 LOOP

        zt_svg.p_draw_ellipse (
            p_center_x => 160,
            p_center_y => 100,
            p_radius_x => 50 + (t * 10),
            p_radius_y => 50 + (t * 3)
        );
    
    END LOOP;

    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_ellipse;


PROCEDURE p_polyline_01 (
    p_close_yn varchar2,
    p_fill_color varchar2
) IS

    lcImage clob;

BEGIN
    zt_svg.p_new_image (
        p_image_width => 320,
        p_image_height => 200
    );

    zt_svg.p_draw_polyline (
        p_points => zt_svg.t_points (
            zt_svg.r_point(x=>10, y=>10),
            zt_svg.r_point(x=>50, y=>50),
            zt_svg.r_point(x=>100, y=>50),
            zt_svg.r_point(x=>100, y=>100),
            zt_svg.r_point(x=>10, y=>100)
        ),
        p_close_yn => p_close_yn,
        p_fill => zt_svg.f_get_fill (
            p_color => p_fill_color
        )
    );

    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );

END p_polyline_01;

PROCEDURE p_polyline_02 IS

    lcImage clob;

BEGIN
    zt_svg.p_new_image (
        p_image_width => 320,
        p_image_height => 200
    );

    zt_svg.p_draw_polyline (
        p_points => zt_svg.t_points (
            zt_svg.r_point(x=>50, y=>10),
            zt_svg.r_point(x=>20, y=>90),
            zt_svg.r_point(x=>90, y=>40),
            zt_svg.r_point(x=>10, y=>40),
            zt_svg.r_point(x=>80, y=>90)
        ),
        p_close_yn => 'Y',
        p_stroke => zt_svg.f_get_stroke (
            p_color => zt_svg.gcStrokeColorRed
        )
    );

    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );

END p_polyline_02;


PROCEDURE p_rectangle_01 (
    p_round_corners number
) IS

    lcImage clob;

BEGIN
    zt_svg.p_new_image (
        p_image_width => 320,
        p_image_height => 200
    );

    zt_svg.p_draw_rectangle (
        p_top_left_x => 10,
        p_top_left_y => 10,
        p_width => 200,
        p_height => 100,
        p_radius_x => p_round_corners,
        p_radius_y => p_round_corners
    );


    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_rectangle_01;


PROCEDURE p_text_01 (
    p_text varchar2,
    p_subtext varchar2
) IS

    lnSuperTextRef pls_integer;
    lcImage clob;

BEGIN
    zt_svg.p_new_image (
        p_image_width => 320,
        p_image_height => 200
    );

    lnSuperTextRef := 
        zt_svg.f_draw_text (
            p_x => 10,
            p_y => 100,
            p_text => p_text,
            p_font => zt_svg.f_get_font (
                p_font_size => 12
            ),
            p_stroke => zt_svg.f_get_stroke (
                p_color => 'none'
            ),
            p_fill => zt_svg.f_get_fill (
                p_color => zt_svg.gcStrokeColorBlack
            )
        );

    zt_svg.p_draw_text (
        p_supertext_ref => lnSuperTextRef,
        p_text => p_subtext,
        p_font => zt_svg.f_get_font (
            p_font_size => 18,
            p_font_weight => 'bold'
        ),
        p_stroke => zt_svg.f_get_stroke (
            p_color => 'none'
        ),
        p_fill => zt_svg.f_get_fill (
            p_color => zt_svg.gcStrokeColorRed
        )
    );


    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_text_01;


PROCEDURE p_url_01 IS

    lcImage clob;

BEGIN
    zt_svg.p_new_image (
        p_image_width => 700,
        p_image_height => 600
    );

    zt_svg.p_create_class (
        p_class_name => 'path:hover',
        p_class_style => 'fill-opacity:0.5;'
    );

    zt_svg.p_draw_custom (
        p_custom_tag => '<path style="fill:#231f20;fill-rule:nonzero;stroke:none" d="m 0,0 115.078,-115.078 c 3.844,-3.844 3.844,-10.076 0,-13.921 l -13.679,-13.679 -108.359,108.359 -87.72,-87.719 51.6,-51.6 -20.64,-20.639 -65.279,65.278 c -3.844,3.845 -3.844,10.077 0,13.921 L -13.921,0 C -10.077,3.844 -3.844,3.844 0,0" transform="matrix(1.3333333,0,0,-1.3333333,0,519.38) translate(208.0742,324.3638)"/>',
        p_url => zt_svg.f_get_url('https://right-thing.solutions/', '_blank')
    );

    zt_svg.p_draw_custom (
        p_custom_tag => '<path style="fill:#c9352f;fill-rule:nonzero;stroke:none" d="m 0,0 20.639,-20.64 -80.759,-80.758 c -3.844,-3.845 -10.077,-3.845 -13.921,0 l -29.159,29.158 20.64,20.64 15.48,-15.48 z" transform="matrix(1.3333333,0,0,-1.3333333,0,519.38) translate(268.1938,181.6861)"/>',
        p_url => zt_svg.f_get_url('https://right-thing.solutions/ords/r/app/sl/about-us', '_blank')
    );

    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_url_01;


PROCEDURE p_url_02 IS

    lcImage clob;

BEGIN
    zt_svg.p_new_image (
        p_image_width => 700,
        p_image_height => 600
    );

    zt_svg.p_start_url (
        p_url => zt_svg.f_get_url('https://right-thing.solutions/', '_blank')    
    );

    zt_svg.p_draw_custom (
        p_custom_tag => '<path style="fill:#231f20;fill-rule:nonzero;stroke:none" d="m 0,0 115.078,-115.078 c 3.844,-3.844 3.844,-10.076 0,-13.921 l -13.679,-13.679 -108.359,108.359 -87.72,-87.719 51.6,-51.6 -20.64,-20.639 -65.279,65.278 c -3.844,3.845 -3.844,10.077 0,13.921 L -13.921,0 C -10.077,3.844 -3.844,3.844 0,0" transform="matrix(1.3333333,0,0,-1.3333333,0,519.38) translate(208.0742,324.3638)"/>'
    );

    zt_svg.p_draw_custom (
        p_custom_tag => '<path style="fill:#c9352f;fill-rule:nonzero;stroke:none" d="m 0,0 20.639,-20.64 -80.759,-80.758 c -3.844,-3.845 -10.077,-3.845 -13.921,0 l -29.159,29.158 20.64,20.64 15.48,-15.48 z" transform="matrix(1.3333333,0,0,-1.3333333,0,519.38) translate(268.1938,181.6861)"/>'
    );

    zt_svg.p_finish_url;

    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_url_02;


FUNCTION f_transform_rotate (
    p_angle number
) RETURN varchar2 IS

    lcImage clob;

BEGIN
    zt_svg.p_new_image (
        p_image_width => 700,
        p_image_height => 200
    );

    zt_svg.p_draw_rectangle (
        p_top_left_x => 50,
        p_top_left_y => 50,
        p_width => 100,
        p_height => 100,
        p_stroke => zt_svg.f_get_stroke (
            p_color => 'rgb(200,200,200)'
        )
    );

    zt_svg.p_draw_rectangle (
        p_top_left_x => 50,
        p_top_left_y => 50,
        p_width => 100,
        p_height => 100,
        p_transform => 
            zt_svg.f_get_transform(
                p_rotate_angle => p_angle,
                p_rotate_center_x => 100,
                p_rotate_center_y => 100
            )
    );


    lcImage := zt_svg.f_finish_image;
    
    RETURN lcImage;
    
END f_transform_rotate;


PROCEDURE p_transform_translate (
    p_translate_x number
) IS

    lcImage clob;

BEGIN
    zt_svg.p_new_image (
        p_image_width => 700,
        p_image_height => 200
    );

    zt_svg.p_draw_rectangle (
        p_top_left_x => 10,
        p_top_left_y => 10,
        p_width => 100,
        p_height => 100,
        p_stroke => zt_svg.f_get_stroke (
            p_color => 'rgb(200,200,200)'
        )
    );

    zt_svg.p_draw_rectangle (
        p_top_left_x => 10,
        p_top_left_y => 10,
        p_width => 100,
        p_height => 100,
        p_transform => 
            zt_svg.f_get_transform(
                p_translate_x => p_translate_x,
                p_translate_y => 0
            ) 
    );

    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_transform_translate;


PROCEDURE p_transform_skew (
    p_skew_x number
) IS

    lcImage clob;

BEGIN
    zt_svg.p_new_image (
        p_image_width => 700,
        p_image_height => 200
    );

    zt_svg.p_draw_rectangle (
        p_top_left_x => 100,
        p_top_left_y => 10,
        p_width => 100,
        p_height => 100,
        p_stroke => zt_svg.f_get_stroke (
            p_color => 'rgb(200,200,200)'
        )
    );

    zt_svg.p_draw_rectangle (
        p_top_left_x => 100,
        p_top_left_y => 10,
        p_width => 100,
        p_height => 100,
        p_transform => 
            zt_svg.f_get_transform(
                p_skew_x => p_skew_x
            ) 
    );

    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_transform_skew;


PROCEDURE p_transform_scale (
    p_scale_x number,
    p_scale_y number
) IS

    lcImage clob;

BEGIN
    zt_svg.p_new_image (
        p_image_width => 700,
        p_image_height => 300
    );

    zt_svg.p_draw_rectangle (
        p_top_left_x => 10,
        p_top_left_y => 10,
        p_width => 100,
        p_height => 100,
        p_stroke => zt_svg.f_get_stroke (
            p_color => 'rgb(200,200,200)'
        )
    );

    zt_svg.p_draw_rectangle (
        p_top_left_x => 10,
        p_top_left_y => 10,
        p_width => 100,
        p_height => 100,
        p_transform => 
            zt_svg.f_get_transform(
                p_scale_x => p_scale_x,
                p_scale_y => p_scale_y,
                p_origin_x => 10,
                p_origin_y => 10
            ) 
    );

    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_transform_scale;



PROCEDURE p_path_01 IS

    lcImage clob;
    lrCommands zt_svg.t_path_commands := zt_svg.t_path_commands();

BEGIN
    zt_svg.p_new_image (
        p_image_width => 320,
        p_image_height => 200
    );
    
    --relative coordinates and horizontal/vertical lines
    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdLineHorizontal,
        p_absolute_or_relative => zt_svg.gcPathCoordinateRelative,
        p_x => 100
    );

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdLineVertical,
        p_absolute_or_relative => zt_svg.gcPathCoordinateRelative,
        p_y => 50
    );

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdLineHorizontal,
        p_absolute_or_relative => zt_svg.gcPathCoordinateRelative,
        p_x => -100
    );

    zt_svg.p_draw_path (
        p_start_x => 10,
        p_start_y => 10,
        p_path_commands => lrCommands,
        p_close_path_yn => 'Y'
    );


    --absolute coordinates and ordinary lines
    lrCommands.delete;
    
    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdLine,
        p_x => 300,
        p_y => 10
    );

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdLine,
        p_x => 300,
        p_y => 100
    );

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdLine,
        p_x => 200,
        p_y => 100
    );

    zt_svg.p_draw_path (
        p_start_x => 200,
        p_start_y => 10,
        p_path_commands => lrCommands,
        p_close_path_yn => 'Y'
    );


    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_path_01;



PROCEDURE p_path_02 IS

    lcImage clob;
    lrCommands zt_svg.t_path_commands := zt_svg.t_path_commands();

BEGIN
    zt_svg.p_new_image (
        p_image_width => 320,
        p_image_height => 200
    );
    
    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdLineHorizontal,
        p_absolute_or_relative => zt_svg.gcPathCoordinateRelative,
        p_x => 100
    );

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdBezierQuadratic,
        p_control_point_x1 => 100,
        p_control_point_y1 => 50,
        p_x => 150,
        p_y => 50
    );

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdBezierQuadraticAdd,
        p_x => 250,
        p_y => 100
    );

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdBezierQuadraticAdd,
        p_x => 10,
        p_y => 100
    );

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdBezier,
        p_control_point_x1 => 100,
        p_control_point_y1 => 50,
        p_control_point_x2 => 100,
        p_control_point_y2 => 50,
        p_x => 10,
        p_y => 10
    );


    zt_svg.p_draw_path (
        p_start_x => 10,
        p_start_y => 10,
        p_path_commands => lrCommands,
        p_close_path_yn => 'N'
    );


    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_path_02;



PROCEDURE p_path_03 IS

    lcImage clob;
    lrCommands zt_svg.t_path_commands := zt_svg.t_path_commands();

BEGIN
    zt_svg.p_new_image (
        p_image_width => 700,
        p_image_height => 600
    );
    
    --arc 01
    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdArc,
        p_arc_radius_x => 45,
        p_arc_radius_y => 45,
        p_arc_rotation => 0,
        p_x => 125,
        p_y => 125
    );

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdLine,
        p_x => 125,
        p_y => 80
    );

    zt_svg.p_draw_path (
        p_start_x => 80,
        p_start_y => 80,
        p_path_commands => lrCommands,
        p_close_path_yn => 'Y',
        p_fill => zt_svg.f_get_fill (
            p_color => zt_svg.gcStrokeColorRed
        )
    );


    --arc 02
    lrCommands.delete;

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdArc,
        p_arc_radius_x => 45,
        p_arc_radius_y => 45,
        p_arc_rotation => 0,
        p_arc_large_yn => 'Y',
        p_x => 275,
        p_y => 125
    );

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdLine,
        p_x => 275,
        p_y => 80
    );

    zt_svg.p_draw_path (
        p_start_x => 230,
        p_start_y => 80,
        p_path_commands => lrCommands,
        p_close_path_yn => 'Y',
        p_fill => zt_svg.f_get_fill (
            p_color => zt_svg.gcStrokeColorGreen
        )
    );


    --arc 03
    lrCommands.delete;

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdArc,
        p_arc_radius_x => 45,
        p_arc_radius_y => 45,
        p_arc_rotation => 0,
        p_arc_sweep_yn => 'Y',
        p_x => 125,
        p_y => 275
    );

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdLine,
        p_x => 125,
        p_y => 230
    );

    zt_svg.p_draw_path (
        p_start_x => 80,
        p_start_y => 230,
        p_path_commands => lrCommands,
        p_close_path_yn => 'Y',
        p_fill => zt_svg.f_get_fill (
            p_color => zt_svg.gcStrokeColorPurple
        )
    );    


    --arc 04
    lrCommands.delete;

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdArc,
        p_arc_radius_x => 45,
        p_arc_radius_y => 45,
        p_arc_rotation => 0,
        p_arc_large_yn => 'Y',
        p_arc_sweep_yn => 'Y',
        p_x => 275,
        p_y => 275
    );

    zt_svg.p_add_path_command(
        p_commands => lrCommands,
        p_command => zt_svg.gcPathCmdLine,
        p_x => 275,
        p_y => 230
    );

    zt_svg.p_draw_path (
        p_start_x => 230,
        p_start_y => 230,
        p_path_commands => lrCommands,
        p_close_path_yn => 'Y',
        p_fill => zt_svg.f_get_fill (
            p_color => zt_svg.gcStrokeColorBlue
        )
    );    
    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_path_03;


PROCEDURE p_insert_image (
    p_images_no pls_integer
) IS

    lcImage clob;
    lnImageSize number;
    lnX number;
    lnY number;

BEGIN
    zt_svg.p_new_image (
        p_image_width => 700,
        p_image_height => 600
    );
    
    FOR t IN 1 .. p_images_no LOOP
        lnImageSize := trunc(dbms_random.value(50, 100));
        lnX := trunc(dbms_random.value(0, 500));
        lnY := trunc(dbms_random.value(0, 400));
    
        zt_svg.p_insert_image (
            p_x => lnX,
            p_y => lnY,
            p_width => lnImageSize,
            p_height => lnImageSize,
            p_image_url => v('APP_IMAGES') || 'svg/star.svg',
            p_transform => 
                zt_svg.f_get_transform(
                    p_rotate_angle => trunc(dbms_random.value(0, 90)),
                    p_rotate_center_x => lnX + lnImageSize / 2,
                    p_rotate_center_y => lnY + lnImageSize / 2
                )
        );
    END LOOP;
    
    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_insert_image;


PROCEDURE p_use (
    p_logos_no pls_integer
) IS

    lcImage clob;
     lnX number;
    lnY number;

BEGIN
    zt_svg.p_new_image (
        p_image_width => 700,
        p_image_height => 600
    );
    
    --draw first logo in a group
    zt_svg.p_draw_group (
        p_id => 'trts_logo',
        p_transform => 
            zt_svg.f_get_transform(
                p_scale_x => 0.3,
                p_scale_y => 0.3
            )
        
    );
    
    zt_svg.p_draw_custom (
        p_custom_tag => '<path style="fill:#231f20;fill-rule:nonzero;stroke:none" d="m 0,0 115.078,-115.078 c 3.844,-3.844 3.844,-10.076 0,-13.921 l -13.679,-13.679 -108.359,108.359 -87.72,-87.719 51.6,-51.6 -20.64,-20.639 -65.279,65.278 c -3.844,3.845 -3.844,10.077 0,13.921 L -13.921,0 C -10.077,3.844 -3.844,3.844 0,0" transform="matrix(1.3333333,0,0,-1.3333333,0,519.38) translate(208.0742,324.3638)"/>'
    );

    zt_svg.p_draw_custom (
        p_custom_tag => '<path style="fill:#c9352f;fill-rule:nonzero;stroke:none" d="m 0,0 20.639,-20.64 -80.759,-80.758 c -3.844,-3.845 -10.077,-3.845 -13.921,0 l -29.159,29.158 20.64,20.64 15.48,-15.48 z" transform="matrix(1.3333333,0,0,-1.3333333,0,519.38) translate(268.1938,181.6861)"/>'
    );

    zt_svg.p_draw_group_end;

    --re-use the logo in instances
    FOR t IN 1 .. p_logos_no LOOP
        lnX := trunc(dbms_random.value(0, 500));
        lnY := trunc(dbms_random.value(0, 400));
    
        zt_svg.p_insert_image (
            p_x => lnX,
            p_y => lnY,
            p_image_url => '#trts_logo',
            p_image_or_use => zt_svg.gcElementUse,
            p_transform => 
                zt_svg.f_get_transform(
                    p_rotate_angle => trunc(dbms_random.value(0, 90)),
                    p_rotate_center_x => lnX,
                    p_rotate_center_y => lnY
                )
        );
    END LOOP;
    
    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_use;


PROCEDURE p_javascript_01 IS

    lcImage clob;
    lcValue varchar2(50);

BEGIN
    zt_svg.p_new_image (
        p_image_width => 700,
        p_image_height => 600
    );

    zt_svg.p_create_class (
        p_class_name => '.myCircle',
        p_class_style => 'fill:pink;'
    );

    zt_svg.p_create_class (
        p_class_name => '.myCircle:hover',
        p_class_style => 'fill-opacity:0.5; cursor:pointer;'
    );

    --circles
    FOR t IN 1 .. 5 LOOP
        lcValue := dbms_random.string('u', 5);
    
        zt_svg.p_draw_circle (
            p_center_x => 100 + (t-1) * 120,
            p_center_y => 100,
            p_radius => 50,
            p_custom_attributes => 'data-id="' || lcValue || '"',
            p_class_name => 'myCircle'
        );

        zt_svg.p_draw_text (
            p_x => 70 + (t-1) * 120,
            p_y => 40,
            p_text => lcValue,
            p_font => zt_svg.f_get_font (
                p_font_size => 18,
                p_font_weight => 'bold'
            ),
            p_stroke => zt_svg.f_get_stroke (
                p_color => 'none'
            ),
            p_fill => zt_svg.f_get_fill (
                p_color => zt_svg.gcStrokeColorBlack
            )
        );

    END LOOP;

    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_javascript_01;


PROCEDURE p_javascript_02 IS

    lcImage clob;
    lcValue varchar2(50);

BEGIN
    zt_svg.p_new_image (
        p_image_width => 700,
        p_image_height => 600
    );

    zt_svg.p_create_class (
        p_class_name => '.oneCircle',
        p_class_style => 'fill:pink;'
    );

    zt_svg.p_create_class (
        p_class_name => '.oneCircle:hover',
        p_class_style => 'fill-opacity:0.5; cursor:pointer;'
    );

    --circles
    zt_svg.p_draw_circle (
        p_center_x => 100,
        p_center_y => 100,
        p_radius => 50,
        p_custom_attributes => 'onclick="myFunction()"',
        p_class_name => 'oneCircle'
    );


    lcImage := zt_svg.f_finish_image;
    
    htpprn( '<pre>' || lcImage || '</pre>' );
    
END p_javascript_02;

END zt_svg_demo;