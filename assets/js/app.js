import "phoenix_html"
const Elm = require('../elm/Main.elm')
console.log(Elm);

let div = document.getElementById('elmDiv');
let base_path = div.getAttribute("data-endpoint")


var app = Elm.Main.embed(div, {endpoint: base_path});
