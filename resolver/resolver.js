var dnsd = require('dnsd');
var exec = require('child_process').exec;
var port = 5354;

dnsd.createServer(function(req, res) {
  var domain = req.question[0].name;

  exec('avahi-resolve -n ' + domain, {
    shell: true,
  }, (err, stdout, stderr) => {

    // We send 0.0.0.0 to indicate a failed resolution
    // if there was any error.
    if (err || ~stderr.indexOf('Failed')) {
      return res.end();
    }

    // Otherwise we use the Avahi resolved ip.
    res.end(stdout.split("\t").pop().trim());
  });
}).listen(port, '127.0.0.1');

console.log('Server running at 127.0.0.1:' + port);
