var tag = document.createElement('script');
tag.src = "https://www.youtube.com/player_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
var player;
function onYouTubePlayerAPIReady() {
  player = new YT.Player('main', {
    height: '100%',
    width: '100%',
    videoId: 'fi6I_NZcRss',
    playerVars: {
      autoplay: 1,
      start: 15,
      end: 500,
      controls: 0,
      disablekb: 1,
      hl: 'en-US',
      loop: 1,
      playlist: '8tfRRwn0RRw',
      modestbranding: 1,
      showinfo: 0,
      autohide: 1,
      color: 'black',
      iv_load_policy: 3,
      theme: 'dark',
      rel: 0
    }
  });
}
