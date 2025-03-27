const gulp = require("gulp");
const replace = require("gulp-replace");
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

function shouldUpdateCSSVersion() {
  const cssHash = crypto
    .createHash("md5")
    .update(fs.readFileSync("styles/global.css"))
    .digest("hex");

  const cachePath = ".cache";
  const cacheFile = path.join(cachePath, "css-hash");

  if (!fs.existsSync(cachePath)) {
    fs.mkdirSync(cachePath);
  }

  if (fs.existsSync(cacheFile)) {
    const oldHash = fs.readFileSync(cacheFile, "utf8");
    if (oldHash === cssHash) {
      console.log("CSS unchanged, skipping version update");
      return false;
    }
  }

  // Only write new hash if CSS actually changed
  fs.writeFileSync(cacheFile, cssHash);
  return true;
}

function updateCSSVersion() {
  if (!shouldUpdateCSSVersion()) {
    return Promise.resolve();
  }

  const timestamp = Math.floor(Date.now() / 1000);
  return gulp
    .src(["**/*.html"])
    .pipe(replace(/(global\.css\?v=)\d+/g, `$1${timestamp}`))
    .pipe(gulp.dest("./"));
}

gulp.task("default", updateCSSVersion);
