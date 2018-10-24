
import "phoenix_html"
const Elm = require('../elm//Main.elm')

let div = document.getElementById('elmDiv');
console.log(div);
let mpage = document.querySelector('.mainpage')
let base_path = mpage.getAttribute("data-endpoint")


if(div) {
  //var app =  Elm.Main.embed(div, {endpoint: base_path});
  var app =  Elm.Main.embed(div);
}
