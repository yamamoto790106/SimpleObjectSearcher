var gutil = require('gulp-util');
var through2 = require('through2');

module.exports = function() {
  var written = false
  return through2.obj(function(file, enc, callback) {
    var output = new gutil.File(file)
    var transform = function(data, enc, cb) {
      if (!written) {
        this.push(new Buffer("!function(require,define){"));
        written = true;
      }
      this.push(data);
      cb();
    };
    var flush = function(cb) {
      this.push(new Buffer("}()"));
      cb();
    };
    output.contents = file.contents.pipe(through2(transform, flush));
    this.push(output);
    callback();
  });
};
