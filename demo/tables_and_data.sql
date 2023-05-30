CREATE TABLE parking_floors (
    floor_id varchar2(50) not null primary key,
    name varchar2(500) not null,
    background_image varchar2(1000) not null
);

INSERT INTO parking_floors (floor_id, name, background_image)
VALUES ('BLUE', 'Blue floor', 'parking/BlueFloor.svg');

INSERT INTO parking_floors (floor_id, name, background_image)
VALUES ('RED', 'Red floor', 'parking/RedFloor.svg');

INSERT INTO parking_floors (floor_id, name, background_image)
VALUES ('YELLOW', 'Yellow floor', 'parking/YellowFloor.svg');


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

ALTER TABLE ZORANDBA.PARKING_LOTS
 ADD CONSTRAINT PARKING_LOTS_R01 
  FOREIGN KEY (FLOOR_ID) 
  REFERENCES ZORANDBA.PARKING_FLOORS (FLOOR_ID)
  ENABLE VALIDATE;
  
