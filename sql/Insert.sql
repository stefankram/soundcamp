--
-- Created by Stefan Kramreither & Kirkland Landry
--



INSERT INTO User (firstName, lastName, username, email, passHash, passSalt, description) VALUES
  (
    'one',
    'two',
    'threeFour',
    'random@email2.com',
    'hash',
    'salt9',
    'the description'
  );

INSERT INTO Subscription (userSubscriber, userSubscribed) VALUES
  (
    (SELECT userId
     FROM User
     WHERE email = 'random@email2.com'),
    (SELECT userId
     FROM User
     WHERE username = 'johncena')
  );

INSERT INTO SongComment (userId, songId, comment) VALUES
  (
    (SELECT userId
     FROM BandMember
     WHERE bandId = (SELECT bandId
                     FROM Song
                     WHERE songId = 1)
     ORDER BY joinedAt DESC
     LIMIT 1),
    1,
    'Good song!'
  );