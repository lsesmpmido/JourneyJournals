document.addEventListener('DOMContentLoaded', function() {
  let latInput = document.getElementById('latitude');
  let lngInput = document.getElementById('longitude');
  
  function initMap() {
    const defaultLat = latInput.value
    const defaultLng = lngInput.value

    var map = new google.maps.Map(document.getElementById('map'), {
      center: { lat: parseFloat(defaultLat), lng: parseFloat(defaultLng) },
      zoom: 15
    });

    var marker = new google.maps.Marker({
      position: { lat: parseFloat(defaultLat), lng: parseFloat(defaultLng) },
      map: map
    });
  }

  if (window.google && window.google.maps) {
    initMap();
  } else {
    console.error('Google Maps APIが正しく読み込まれていません。');
  }
});
