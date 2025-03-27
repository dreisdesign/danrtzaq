(function () {
  var btn = document.getElementById("randomButton");

  btn.addEventListener("click", function () {
    randomUrl();
  });

  function randomUrl() {
    var urls = [
        "/stress-is-temporary",
        "/a-better-present-starts-here",
        "/just-be-kind",
        "/when-in-doubt-just-wait",
        "/when-in-doubt-seek-calm",
        "/when-in-doubt-slow-down",
        "/a-better-future-starts-now",
        "/check-less-reduce-stress",
        "/pause-inhale-exhale-resume",
        "/dont-take-youself-too-seriously",
        "/pause-breathe-relax",
        "/embrace-reality",
        "/awareness-of-fear",
        "/see-for-yourself",
        "/be-here-now",
        "/all-thoughts-come-and-go",
        "/loosen-up",
        "/one-thing-at-a-time",
      ],
      max = urls.length,
      min = 0,
      result,
      link;

    result = Math.floor(randomNum(min, max));
    link = urls[result];
    location.href = link;
  }

  function randomNum(min, max) {
    return Math.random() * (max - min) + min;
  }
})();
