--
-- Created by Stefan Kramreither & Kirkland Landry
--

USE se3309project;

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