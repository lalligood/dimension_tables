USE testdb;

DROP TABLE IF EXISTS mytable;

CREATE TABLE IF NOT EXISTS mytable (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY
    , myname TEXT
    , created TIMESTAMP DEFAULT now()
    , last_modified TIMESTAMP DEFAULT now() ON UPDATE now()
);

INSERT INTO mytable (myname) VALUES ('lance'), ('dawn');

SELECT * FROM testdb.mytable;

UPDATE mytable
    SET myname = 'bella'
WHERE id = 2;

SELECT * FROM testdb.mytable;