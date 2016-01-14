--
-- Created by Stefan Kramreither & Kirkland Landry
--

USE se3309project;

SELECT *
FROM User
WHERE ((userId >= 3 AND userId <= 777) AND username LIKE '%s%');

SELECT
  BandMember.userId,
  Band.bandName
FROM Band
  INNER JOIN BandMember ON (BandMember.userId = 1 AND Band.bandId = 1);

SELECT
  userId,
  COUNT(1) AS bandCount
FROM BandMember
GROUP BY userId
ORDER BY bandCount, userId;

SELECT
  UserInBand.userId,
  UserInBand.firstName,
  UserInBand.lastName,
  Song.songId,
  Song.title
FROM (SELECT *
      FROM User
      WHERE exists(SELECT userId
                   FROM BandMember
                   WHERE User.userId = BandMember.userId)) AS UserInBand LEFT JOIN Song
    ON UserInBand.userId = Song.userId;

(SELECT
   User.userId,
   User.firstName,
   User.lastName,
   UserComment.songId,
   'Comment' AS type
 FROM User
   JOIN (SELECT
           userId,
           songId
         FROM SongComment) AS UserComment ON UserComment.userId = User.userId)
UNION
(SELECT
   User.userId,
   User.firstName,
   User.lastName,
   UserLike.songId,
   'Like' AS type
 FROM User
   JOIN (SELECT
           userId,
           songId
         FROM SongLike) AS UserLike ON UserLike.userId = User.userId);