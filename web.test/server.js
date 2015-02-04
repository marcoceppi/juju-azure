/*Define dependencies.*/

/* Deps for file upload from http://codeforgeek.com/2014/11/file-uploads-using-node-js/ */
/* var express = require("express"); */
var multer  = require('multer');
var connect = require('connect');
/* var app = require('express'); */
var done = false;

/* Deps for file upload from https://gist.github.com/fkowal/3447400 */
var fs = require('fs'),
    port = process.env.npm_package_config_port || 3000,
    express = require('express'),
    http = require('http'),
    app = express(),
    server = http.createServer(app),
    io = require('socket.io').listen(server),
    files = [],
    os = require('os'),
    buf = new Buffer(4096);


/*Run the server. */
server.listen(port);

if (process.argv.length < 3) {
    console.error("Usage: " + __filename + " filename");
    process.exit(1);
}

// server the browser dependencies
app.configure(function () {
    app.use(express.static(__dirname + '/public'));
});

// server socket.io client to the browser
app.get('/socket.io/socket.io.js', function (req, res) {
    res.sendfile(__dirname + '/node_modules/socket.io-client/dist/socket.io.js');
});

// open a route for each file from the command line
app.get('/files/:filename', function (req, res) {
    res.sendfile(__dirname + '/public/index.html');
});

/*Configure the multer.*/
app.use(multer({ dest: './uploads/',
 rename: function (fieldname, filename) {
    return filename+Date.now();
  },
onFileUploadStart: function (file) {
  console.log(file.originalname + ' is starting ...')
},
onFileUploadComplete: function (file) {
  console.log(file.fieldname + ' uploaded to  ' + file.path)
  done=true;
}
}));

// for each file from the command line open an route
process.argv.splice(2).forEach(function (filename) {
    "use strict";
    fs.open(filename, 'r', function (err, fd) {
        if (err) {
            console.error('Unable to open: ' + filename);
            return;
        }
 
        files.push(filename);
        var nsName = '/files/' + (-1 + files.length),
            ns = io.of(nsName)
                .on('connection', function(socket) {
                    socket.emit('files', files);
                });
 
        console.info('Listening on http://' + os.hostname() + ':' + port + nsName + ' ' + filename);
 
        // watch file
        fs.watchFile(filename, function (curr, prev) {
            var len = curr.size - prev.size, position = prev.size;
            if (len > 0) {
                fs.read(fd, buf, 0, len, position,
                    function (err, bytesRead, buffer) {
                        if (err) {
                            console.error(err);
                            return;
                        }
                        var msg = buffer.toString('utf8', 0, bytesRead);
                        ns.emit('message', msg);
                    });
            } else {
                console.log(curr);
            }
        });
    });
});
 
console.info('Listing on http://' + os.hostname() + ':' + port);
 
// on connection broadcast file names the server is tailing
io.sockets
    .on('connection', function (socket) {
        "use strict";
 
        // broadcast opened files
        socket.emit('files', files);
    });

/*Handling routes.*/
app.get('/',function(req,res){
      res.sendfile("index-js.html");
});

app.post('/upload',function(req,res){
  if(done==true){
    console.log(req.files);
    res.end("File uploaded.");
  }
});



/*Run the server.
app.listen(3000,function(){
    console.log("Working on port 3000");
}); */




