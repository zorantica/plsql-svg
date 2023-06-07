-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
--parking floors

CREATE TABLE parking_floors (
    floor_id varchar2(50) not null primary key,
    name varchar2(500) not null,
    background_image varchar2(1000) not null
);

Insert into PARKING_FLOORS
   (FLOOR_ID, NAME, BACKGROUND_IMAGE)
 Values
   ('BLUE', 'Blue floor', 'svg/parking/FloorBlue.svg');
Insert into PARKING_FLOORS
   (FLOOR_ID, NAME, BACKGROUND_IMAGE)
 Values
   ('RED', 'Red floor', 'svg/parking/FloorRed.svg');
Insert into PARKING_FLOORS
   (FLOOR_ID, NAME, BACKGROUND_IMAGE)
 Values
   ('YELLOW', 'Yellow floor', 'svg/parking/FloorYellow.svg');

COMMIT;


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
--parking lots

CREATE TABLE parking_lots (
    lot_id number not null primary key,
    floor_id varchar2(50) not null,
    occupied_yn varchar2(1) default 'N' not null,
    occupied_by varchar2(4000),
    occupied_plate varchar2(100),
    occupied_until date,
    position_x number,
    position_y number,
    width number,
    height number,
    rotate_angle number,
    lot_type varchar2(1)
);

COMMENT ON COLUMN parking_lots.lot_type IS 'C car or M motorcycle';


CREATE INDEX parking_lots_i01 ON parking_lots(floor_id);

ALTER TABLE PARKING_LOTS
 ADD CONSTRAINT PARKING_LOTS_R01 
  FOREIGN KEY (FLOOR_ID) 
  REFERENCES PARKING_FLOORS (FLOOR_ID)
  ENABLE VALIDATE;
  

SET DEFINE OFF;
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_BY, OCCUPIED_PLATE, OCCUPIED_UNTIL, 
    POSITION_X, POSITION_Y, WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (1, 'BLUE', 'Y', 'Zoran Tica', 'GO N3 091', trunc(sysdate) + 3, 
    877, 427, 120, 170, 90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (2, 'BLUE', 'N', 752, 427, 121, 
    170, 90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_BY, OCCUPIED_PLATE, OCCUPIED_UNTIL, 
    POSITION_X, POSITION_Y, WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (3, 'BLUE', 'Y', 'Uros A.', 'KR F5 587', trunc(sysdate) + 12, 
    627, 427, 122, 170, 90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_BY, OCCUPIED_PLATE, OCCUPIED_UNTIL, 
    POSITION_X, POSITION_Y, WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (4, 'BLUE', 'Y', 'MOL Ljubljana', 'LJ F5 568', trunc(sysdate) - 3, 
    502, 427, 122, 170, 90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (5, 'BLUE', 'N', 377, 427, 122, 
    170, 90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_UNTIL, POSITION_X, POSITION_Y, 
    WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (6, 'BLUE', 'Y', trunc(sysdate) + 10, 252, 427, 
    122, 170, 90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (7, 'BLUE', 'N', 877, 54, 120, 
    170, -90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_BY, OCCUPIED_UNTIL, POSITION_X, 
    POSITION_Y, WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (8, 'BLUE', 'Y', 'John Doe', trunc(sysdate) + 6, 752, 
    54, 120, 170, -90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (9, 'BLUE', 'N', 627, 54, 120, 
    170, -90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (10, 'BLUE', 'N', 502, 54, 120, 
    170, -90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_UNTIL, POSITION_X, POSITION_Y, 
    WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (11, 'BLUE', 'Y', trunc(sysdate) - 5, 30, 300, 
    170, 120, 180, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (12, 'BLUE', 'N', 30, 177, 170, 
    120, 180, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_UNTIL, POSITION_X, POSITION_Y, 
    WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (14, 'BLUE', 'Y', trunc(sysdate) + 5, 30, 54, 
    170, 120, 180, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (15, 'RED', 'N', 877, 427, 120, 
    170, 90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (16, 'RED', 'N', 752, 427, 121, 
    170, 90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_BY, OCCUPIED_PLATE, OCCUPIED_UNTIL, 
    POSITION_X, POSITION_Y, WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (17, 'RED', 'Y', 'Jure Z.', 'KR 54 568', trunc(sysdate) + 6, 
    627, 427, 121, 170, 90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_UNTIL, POSITION_X, POSITION_Y, 
    WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (18, 'RED', 'Y', trunc(sysdate) - 2, 502, 427, 
    121, 170, 90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (19, 'RED', 'N', 877, 54, 120, 
    170, -90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_UNTIL, POSITION_X, POSITION_Y, 
    WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (20, 'RED', 'Y', trunc(sysdate) + 9, 752, 54, 
    120, 170, -90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (21, 'RED', 'N', 627, 54, 120, 
    170, -90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (22, 'RED', 'N', 502, 54, 120, 
    170, -90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_BY, OCCUPIED_PLATE, OCCUPIED_UNTIL, 
    POSITION_X, POSITION_Y, WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (23, 'RED', 'Y', 'Daevy Espeel', 'Harley Davidson without plate', trunc(sysdate) + 2, 
    29, 526, 170, 70, 0, 'M');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (24, 'RED', 'N', 29, 450, 170, 
    74, 0, 'M');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_UNTIL, POSITION_X, POSITION_Y, 
    WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (25, 'RED', 'Y', trunc(sysdate) + 12, 29, 375, 
    170, 74, 0, 'M');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_UNTIL, POSITION_X, POSITION_Y, 
    WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (26, 'RED', 'Y', trunc(sysdate) + 8, 29, 300, 
    170, 74, 0, 'M');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (27, 'RED', 'N', 29, 225, 170, 
    74, 0, 'M');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (28, 'RED', 'N', 29, 150, 170, 
    74, 0, 'M');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (29, 'YELLOW', 'N', 28, 425, 71, 
    170, -90, 'M');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_UNTIL, POSITION_X, POSITION_Y, 
    WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (30, 'YELLOW', 'Y', trunc(sysdate) + 5, 28, 55, 
    71, 170, 90, 'M');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_UNTIL, POSITION_X, POSITION_Y, 
    WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (31, 'YELLOW', 'Y', trunc(sysdate) - 2, 101, 425, 
    71, 170, -90, 'M');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (32, 'YELLOW', 'N', 177, 425, 71, 
    170, -90, 'M');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (33, 'YELLOW', 'N', 101, 55, 71, 
    170, 90, 'M');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (34, 'YELLOW', 'N', 177, 55, 71, 
    170, 90, 'M');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (35, 'YELLOW', 'N', 877, 54, 120, 
    170, -90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (36, 'YELLOW', 'N', 752, 54, 120, 
    170, -90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (37, 'YELLOW', 'N', 627, 54, 120, 
    170, -90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_UNTIL, POSITION_X, POSITION_Y, 
    WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (38, 'YELLOW', 'Y', trunc(sysdate) - 5, 502, 54, 
    120, 170, -90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (39, 'YELLOW', 'N', 877, 427, 120, 
    170, 90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, OCCUPIED_PLATE, OCCUPIED_UNTIL, POSITION_X, 
    POSITION_Y, WIDTH, HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (40, 'YELLOW', 'Y', 'LJ MZ 001', trunc(sysdate) + 4, 752, 
    427, 121, 170, 90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (41, 'YELLOW', 'N', 627, 427, 122, 
    170, 90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (42, 'YELLOW', 'N', 502, 427, 122, 
    170, 90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (43, 'YELLOW', 'N', 377, 54, 122, 
    170, -90, 'C');
Insert into PARKING_LOTS
   (LOT_ID, FLOOR_ID, OCCUPIED_YN, POSITION_X, POSITION_Y, WIDTH, 
    HEIGHT, ROTATE_ANGLE, LOT_TYPE)
 Values
   (44, 'YELLOW', 'N', 252, 54, 122, 
    170, -90, 'C');
COMMIT;

