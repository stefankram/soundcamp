--
-- Created by Stefan Kramreither & Kirkland Landry
--

USE se3309project;

-- Create tables
CREATE TABLE User
(
  userId      INT          NOT NULL AUTO_INCREMENT,
  firstName   VARCHAR(255) NOT NULL,
  lastName    VARCHAR(255) NOT NULL,
  username    VARCHAR(255) NOT NULL UNIQUE,
  email       VARCHAR(255) NOT NULL UNIQUE,
  passHash    VARCHAR(255) NOT NULL,
  passSalt    VARCHAR(255) NOT NULL,
  createdAt   TIMESTAMP    NOT NULL,
  image       VARCHAR(255),
  description TEXT,
  PRIMARY KEY (userId)
);

CREATE TABLE Band
(
  bandId      INT          NOT NULL AUTO_INCREMENT,
  bandName    VARCHAR(255) NOT NULL,
  description TEXT,
  image       VARCHAR(255),
  createdAt   TIMESTAMP    NOT NULL,
  PRIMARY KEY (bandId)
);

CREATE TABLE Song
(
  songId      INT          NOT NULL AUTO_INCREMENT,
  userId      INT,
  bandId      INT,
  title       VARCHAR(255) NOT NULL,
  description TEXT,
  image       VARCHAR(255),
  audio       VARCHAR(255) NOT NULL,
  likes       INT          NOT NULL DEFAULT 0,
  visibility  TINYINT(1)   NOT NULL DEFAULT 1,
  createdAt   TIMESTAMP    NOT NULL,
  FOREIGN KEY (userId) REFERENCES User (userId)
    ON DELETE CASCADE,
  FOREIGN KEY (bandId) REFERENCES Band (bandId)
    ON DELETE CASCADE
);

CREATE TABLE SongComment
(
  userId    INT       NOT NULL,
  songId    INT       NOT NULL,
  comment   TEXT      NOT NULL,
  createdAt TIMESTAMP NOT NULL,
  FOREIGN KEY (userId) REFERENCES User (userId)
    ON DELETE CASCADE,
  FOREIGN KEY (songId) REFERENCES Song (songId)
    ON DELETE CASCADE
);

CREATE TABLE SongLike
(
  userId    INT       NOT NULL,
  songId    INT       NOT NULL,
  createdAt TIMESTAMP NOT NULL,
  FOREIGN KEY (userId) REFERENCES User (userId)
    ON DELETE CASCADE,
  FOREIGN KEY (songId) REFERENCES Song (songId)
    ON DELETE CASCADE
);
CREATE UNIQUE INDEX uniqueLike ON SongLike (userId, songId);

CREATE TABLE SongRepost
(
  userId    INT       NOT NULL,
  songId    INT       NOT NULL,
  createdAt TIMESTAMP NOT NULL,
  FOREIGN KEY (userId) REFERENCES User (userId)
    ON DELETE CASCADE,
  FOREIGN KEY (songId) REFERENCES Song (songId)
    ON DELETE CASCADE
);

CREATE TABLE BandMember
(
  userId   INT       NOT NULL,
  bandId   INT       NOT NULL,
  joinedAt TIMESTAMP NOT NULL,
  FOREIGN KEY (userId) REFERENCES User (userId)
    ON DELETE CASCADE,
  FOREIGN KEY (bandId) REFERENCES Band (bandId)
    ON DELETE CASCADE
);

CREATE TABLE Subscription
(
  userSubscriber INT NOT NULL,
  userSubscribed INT NOT NULL,
  FOREIGN KEY (userSubscriber) REFERENCES User (userId)
    ON DELETE CASCADE,
  FOREIGN KEY (userSubscribed) REFERENCES User (userId)
    ON DELETE CASCADE
);

DELIMITER //
CREATE TRIGGER InsertBandIdUserIdSong BEFORE INSERT ON Song
FOR EACH ROW BEGIN
  IF (NEW.bandId IS NULL AND NEW.userId IS NULL OR NEW.bandId IS NOT NULL AND NEW.userId IS NOT NULL)
  THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '\'bandId\' and \'userId\' cannot both be null or both be not null';
  END IF;
END//

CREATE TRIGGER UpdateBandIdUserIdSong BEFORE UPDATE ON Song
FOR EACH ROW BEGIN
  IF (NEW.bandId IS NULL AND NEW.userId IS NULL OR NEW.bandId IS NOT NULL AND NEW.userId IS NOT NULL)
  THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '\'bandId\' and \'userId\' cannot both be null or both be not null';
  END IF;
END//

CREATE TRIGGER LikeSong BEFORE INSERT ON SongLike
FOR EACH ROW BEGIN
  UPDATE Song
  SET Song.likes = Song.likes + 1
  WHERE Song.songId = NEW.songId;
END//

CREATE TRIGGER UnlikeSong BEFORE DELETE ON SongLike
FOR EACH ROW BEGIN
  UPDATE Song
  SET Song.likes = Song.likes - 1
  WHERE Song.songId = OLD.songId;
END//
DELIMITER ;

-- Create views
CREATE VIEW UserEmail AS
  SELECT
    userId,
    email
  FROM User;

CREATE VIEW CommentsLikesReposts AS (SELECT
                                       userId,
                                       songId,
                                       'comment' AS type
                                     FROM SongComment)
                                    UNION (SELECT
                                             userId,
                                             songId,
                                             'like' AS type
                                           FROM SongLike)
                                    UNION (SELECT
                                             userId,
                                             songId,
                                             'repost' AS type
                                           FROM SongRepost)
                                    ORDER BY userId;

-- Assignment 4 statements
SELECT userId
FROM User
WHERE email = 'skramrei@uwo.ca' AND passSalt = 'salt9';

INSERT INTO User (firstName, lastName, username, email, passHash, passSalt, description) VALUES
  (
    'Stefan',
    'Kramreither',
    'skramrei',
    'skramrei@uwo.ca',
    'Hash',
    'salt9',
    'I am Stefan!'
  );

SELECT userSubscribed
FROM Subscription
WHERE userSubscriber = 1;

SELECT
  User.username,
  Song.songId,
  Song.title,
  Song.description,
  Song.image,
  Song.audio,
  Song.likes,
  Song.createdAt
FROM Song
  JOIN User ON User.userId = Song.userId
WHERE Song.userId IN (1, 2)
ORDER BY createdAt DESC;

SELECT
  User.image,
  User.username,
  User.userId,
  SongComment.comment,
  SongComment.createdAt
FROM SongComment
  JOIN User ON User.userId = SongComment.userId
WHERE songId = 12
ORDER BY SongComment.createdAt;

INSERT INTO SongLike (userId, songId) VALUES
  (
    1,
    12
  );

INSERT INTO SongComment (userId, songId, comment) VALUES
  (
    1,
    12,
    'I like this song'
  );

DELETE FROM SongComment
WHERE
  comment = 'I like this song' AND
  songId = 12 AND
  userId = 1;

(SELECT
   image,
   User.username AS header,
   'user'        AS type,
   description
 FROM User
 WHERE username LIKE '%bill%')
UNION
(SELECT
   image,
   Song.title AS header,
   'song'     AS type,
   description
 FROM Song
 WHERE title LIKE '%bill%');

SELECT
  image,
  userId,
  firstName,
  lastName,
  username,
  description
FROM Subscription
  JOIN User ON User.userId = Subscription.userSubscribed
WHERE userSubscriber = 1;

SELECT
  firstName,
  lastName,
  username,
  email,
  description,
  image
FROM User
WHERE userId = 1;

UPDATE User
SET
  firstName   = 'Stefan',
  lastName    = 'Kramreither',
  email       = 'skramrei@uwo.ca',
  username    = 'skramrei',
  description = 'I am the student skramrei'
WHERE userId = 1;