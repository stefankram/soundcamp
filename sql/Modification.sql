--
-- Created by Stefan Kramreither & Kirkland Landry
--

USE se3309project;

UPDATE Song
SET likes = (SELECT COUNT(1) AS likeCount
             FROM SongLike
             WHERE Song.songId = SongLike.songId);

DELETE FROM Song
WHERE createdAt < DATE_SUB(CURDATE(), INTERVAL 2 YEAR) AND visibility = 0;

INSERT INTO BandMember (userId, bandId) SELECT
                                          User.userId,
                                          BandMember.bandId
                                        FROM User
                                          JOIN BandMember ON BandMember.userId = 101
                                        WHERE User.userId = 50;