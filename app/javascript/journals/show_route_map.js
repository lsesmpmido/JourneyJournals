document.addEventListener("DOMContentLoaded", function () {
  const mapElement = document.getElementById("map");
  const locations = JSON.parse(mapElement.getAttribute("data-locations"));

  function initMap() {
    const map = new google.maps.Map(mapElement, {
      zoom: 12,
      center: locations[0] || { lat: 35.681236, lng: 139.767125 },
    });
    const directionsService = new google.maps.DirectionsService();
    let origin = null,
        waypoints = [],
        dest = null;
    let requestIndex = 0;
    let done = 0;
    const resultMap = {};

    for (let i = 0, len = locations.length; i < len; i++) {
      if (origin == null) {
        origin = new google.maps.LatLng(locations[i].lat, locations[i].lng);
      } else if (waypoints.length === 8 || i === len - 1) {
        dest = new google.maps.LatLng(locations[i].lat, locations[i].lng);
        (function (index) {
          const request = {
            origin: origin,
            destination: dest,
            waypoints: waypoints,
            travelMode: google.maps.DirectionsTravelMode.DRIVING,
          };
          console.log(request);
          directionsService.route(request, function (result, status) {
            if (status == google.maps.DirectionsStatus.OK) {
              resultMap[index] = result;
              done++;
            } else {
              console.log(status);
            }
          });
        })(requestIndex);
        requestIndex++;
        origin = new google.maps.LatLng(locations[i].lat, locations[i].lng);
        waypoints = [];
      } else {
        waypoints.push({
          location: new google.maps.LatLng(locations[i].lat, locations[i].lng),
          stopover: true,
        });
      }
    }

    const infoWindow = new google.maps.InfoWindow();
    const mark = function (position, content) {
      const marker = new google.maps.Marker({
        map: map,
        position: position,
      });
      marker.addListener("click", function () {
        infoWindow.setContent(content);
        infoWindow.open(map, marker);
      });
    };

    const sid = setInterval(function () {
      if (done >= requestIndex) {
        clearInterval(sid);
        let path = [];
        let result;
        for (let i = 0, len = requestIndex; i < len; i++) {
          result = resultMap[i];
          const legs = result.routes[0].legs;
          for (let li = 0, llen = legs.length; li < llen; li++) {
            const leg = legs[li];
            const steps = leg.steps;
            const _path = steps
              .map(function (step) {
                return step.path;
              })
              .reduce(function (all, paths) {
                return all.concat(paths);
              });
            path = path.concat(_path);
            mark(leg.start_location, leg.start_address);
          }
        }

        const endLeg = result.routes[0].legs[result.routes[0].legs.length - 1];
        mark(endLeg.end_location, endLeg.end_address);
        new google.maps.Polyline({
          map: map,
          strokeColor: "#2196f3",
          strokeOpacity: 0.8,
          strokeWeight: 6,
          path: path,
        });
      }
    }, 1000);
  }

  google.maps.event.addDomListener(window, "load", initMap);
});
