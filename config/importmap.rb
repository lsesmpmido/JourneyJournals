# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# pin_all_from 'app/javascript/images', under: 'images'
pin "images/show_map", to: "images/show_map.js"
pin "images/edit_map", to: "images/edit_map.js"
