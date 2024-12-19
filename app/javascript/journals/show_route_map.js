document.addEventListener("DOMContentLoaded", function() {
  const mapElement = document.getElementById('map');
  const locations = JSON.parse(mapElement.getAttribute('data-locations'));

  function initMap() {
    const map = new google.maps.Map(mapElement, {
      zoom: 10,
      center: locations[0] || { lat: 35.681236, lng: 139.767125 }
    });

    const directionsService = new google.maps.DirectionsService();
    const directionsRenderer = new google.maps.DirectionsRenderer();

    // MapにdirectionsRendererを設定
    directionsRenderer.setMap(map);

    // waypointsを、locationsが2地点以下の場合は空の配列に設定
    const waypoints = locations.length > 2 ? locations.slice(1, locations.length - 1).map(loc => ({
      location: new google.maps.LatLng(loc.lat, loc.lng),
      stopover: true
    })) : [];

    const request = {
      origin: new google.maps.LatLng(locations[0].lat, locations[0].lng),
      destination: new google.maps.LatLng(locations[locations.length - 1].lat, locations[locations.length - 1].lng),
      waypoints: waypoints,
      optimizeWaypoints: true,
      travelMode: google.maps.TravelMode.DRIVING
    };

    directionsService.route(request, function(result, status) {
      if (status === google.maps.DirectionsStatus.OK) {
        directionsRenderer.setDirections(result);
      } else {
        console.error("Directions request failed due to " + status);
        console.error(result); // 詳細なエラーを表示
      }
    });
  }

  google.maps.event.addDomListener(window, 'load', initMap);
});
