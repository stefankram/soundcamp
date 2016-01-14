//
// Created by Stefan Kramreither & Kirkland Landry on 12/3/2015 15:17
//

var express = require('express'),
    mysql = require('mysql'),
    sequence = require('sequence').Sequence;

var db = mysql.createConnection({
    host: '',
    user: '',
    password: '',
    database: 'se3309project'
});

var app = express();

// Set view engine
app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

// Set express added functionality
app.use(require('cookie-parser')());
app.use(require('body-parser').urlencoded({extended: false}));
app.use(require('express-session')({secret: 'session', resave: true, saveUninitialized: true}));
app.use(express.static(__dirname + '/public'));

app.post('/login', function (req, res) {

    var email = req.body.email,
        password = req.body.password;

    db.query(
        "SELECT userId " +
        "FROM User " +
        "WHERE email = '" + email + "' AND passSalt = '" + password + "'",
        function (err, rows) {
            if (!err && rows.length === 1) {
                req.session.userId = rows[0].userId;
            }
            res.redirect('/');
        });
});

app.get('/signup', function (req, res) {
    res.render('signup');
});

app.post('/signup', function (req, res) {

    var firstName = req.body.firstname,
        lastName = req.body.lastname,
        username = req.body.username,
        email = req.body.email,
        passHash = "Hash",
        passSalt = req.body.password,
        description = req.body.description;

    db.query(
        "INSERT INTO User" +
        "(firstName, lastName, username, email, passHash, passSalt, description) " +
        "VALUES " +
        "('" + firstName + "', '" + lastName + "', '" + username + "', '" + email +
        "', '" + passHash + "', '" + passSalt + "', '" + description + "')",
        function (err, rows) {
            if (err) {
                res.redirect('/signup');
            } else {
                res.redirect('/');
            }
        });
});

app.get('/', function (req, res) {

    if (req.session.userId) {

        var seq = sequence.create(),
            IDs = [req.session.userId],
            songs = [];

        seq.then(function (next) {
                db.query(
                    "SELECT userSubscribed " +
                    "FROM Subscription " +
                    "WHERE userSubscriber = " + req.session.userId,
                    function (err, rows) {
                        for (var i = 0; i < rows.length; i++) {
                            IDs.push(rows[i].userSubscribed);
                        }
                        next();
                    });
            })
            .then(function (next) {
                db.query(
                    "SELECT User.username, Song.songId, Song.title, Song.description, Song.image, Song.audio, Song.likes, Song.createdAt " +
                    "FROM Song " +
                    "JOIN User ON User.userId = Song.userId " +
                    "WHERE Song.userId IN (" + IDs.join(",") + ") " +
                    "ORDER BY createdAt DESC",
                    function (err, rows) {
                        for (var i = 0; i < rows.length; i++) {
                            songs.push(rows[i]);
                        }
                        next();
                    });
            })
            .then(function (next) {

                if (songs.length === 0) next();

                for (var i = 0; i < songs.length; i++) {
                    (function (i) {
                        songs[i].comments = [];
                        db.query(
                            "SELECT User.image, User.username, User.userId, SongComment.comment, SongComment.createdAt " +
                            "FROM SongComment " +
                            "JOIN User ON User.userId = SongComment.userId " +
                            "WHERE songId = " + songs[i].songId + " ORDER BY SongComment.createdAt",
                            function (err, rows) {
                                for (var j = 0; j < rows.length; j++) {
                                    songs[i].comments.push(rows[j]);
                                }

                                if (i == songs.length - 1) next();
                            });
                    })(i);
                }
            })
            .then(function () {
                res.render('feed', {
                    songs: songs,
                    userId: req.session.userId
                });
            });
    } else {
        res.render('login');
    }
});

app.post('/like', function (req, res) {

    db.query("INSERT INTO SongLike " +
        "(userId, songId) " +
        "VALUES (" + req.session.userId + ", " + req.body.songId + ")",
        function (err, rows) {});

    res.redirect('/');
});

app.post('/comment', function (req, res) {

    db.query("INSERT INTO SongComment " +
        "(userId, songId, comment) " +
        "VALUES (" + req.session.userId + ", " + req.body.songId + ", '" + req.body.comment + "')",
        function (err, rows) {});

    res.redirect('/');
});

app.post('/delete/comment', function (req, res) {

    var comment = req.body.comment,
        songId = req.body.songId,
        userId = req.session.userId;

    db.query(
        "DELETE FROM SongComment WHERE " +
        "comment = '" + comment + "' AND " +
        "songId = " + songId + " AND " +
        "userId = " + userId,
        function (err, rows) {
            if (err) {
                console.log()
            }
            res.redirect('/');
        });
});

app.get('/search', function (req, res) {
    if (req.session.userId) {
        res.render('search', {
            results: req.session.results
        });
    } else {
        res.redirect('/');
    }
});

app.post('/search', function (req, res) {

    var results = [];

    db.query(
        "(SELECT image, User.username AS header, 'user' AS type, description " +
        "FROM User " +
        "WHERE username LIKE '%" + req.body.search + "%') " +
        "UNION " +
        "(SELECT image, Song.title AS header, 'song' AS type, description " +
        "FROM Song " +
        "WHERE title LIKE '%" + req.body.search + "%')",
        function (err, rows) {
            for (var i = 0; i < rows.length; i++) {
                results.push(rows[i]);
            }
            req.session.results = results;
            res.redirect('/search');
        });
});

app.get('/subscriptions', function (req, res) {
    if (req.session.userId) {

        var subs = [];

        db.query(
            "SELECT image, userId, firstName, lastName, username, description " +
            "FROM Subscription " +
            "JOIN User ON User.userId = Subscription.userSubscribed " +
            "WHERE userSubscriber = " + req.session.userId,
            function (err, rows) {
                for (var i = 0; i < rows.length; i++) {
                    subs.push(rows[i]);
                }
                res.render('subscriptions', {
                    subs: subs
                });
            });
    } else {
        res.redirect('/');
    }
});

app.get('/account', function (req, res) {
    if (req.session.userId) {
        db.query(
            "SELECT firstName, lastName, username, email, description, image " +
            "FROM User " +
            "WHERE userId = " + req.session.userId,
            function (err, rows) {
                res.render('account', {
                    userData: rows[0]
                });
            });
    } else {
        res.redirect('/');
    }
});

app.post('/update/account', function (req, res) {

    var firstName = req.body.firstName,
        lastName = req.body.lastName,
        email = req.body.email,
        username = req.body.username,
        description = req.body.description;

    db.query(
        "UPDATE User SET " +
        "firstName = '" + firstName + "', " +
        "lastName = '" + lastName + "', " +
        "email = '" + email + "', " +
        "username = '" + username + "', " +
        "description = '" + description + "' " +
        "WHERE userId = " + req.session.userId,
        function (err, rows) {
            res.redirect("/account");
        });
});

app.get('/logout', function (req, res) {

    delete req.session.results;
    delete req.session.userId;

    res.redirect('/');
});

app.listen(3000, function () {
    console.log("Listening on port 3000...");
});