$('#playpause').click(function() {
  if ($('#audio')[0].paused == false) {
      $('#audio')[0].pause();
      $('#playpause').attr("src","../images/RedPlay.png");
  } else {
      $('#audio')[0].play();
      $('#playpause').attr("src","../images/RedPause.png");
  }
});
