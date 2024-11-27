document.addEventListener('DOMContentLoaded', function() {
  let latInput = document.getElementById('latitude');
  let lngInput = document.getElementById('longitude');

  function initMap() {
    const defaultLat = latInput.value || 35.6895;  // デフォルトの緯度（例: 東京）
    const defaultLng = lngInput.value || 139.6917;  // デフォルトの経度（例: 東京）

    var map = new google.maps.Map(document.getElementById('map'), {
      center: { lat: parseFloat(defaultLat), lng: parseFloat(defaultLng) },
      zoom: 15
    });

    var marker = new google.maps.Marker({
      position: { lat: parseFloat(defaultLat), lng: parseFloat(defaultLng) },
      map: map,
      draggable: true
    });

    google.maps.event.addListener(marker, 'dragend', function() {
      const position = marker.getPosition();
      latInput.value = position.lat().toFixed(4);
      lngInput.value = position.lng().toFixed(4);
    });
  }

  if (window.google && window.google.maps) {
    initMap();
  } else {
    console.error('Google Maps APIが正しく読み込まれていません。');
  }
});
