// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css"
import "highlight.js/styles/monokai.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import "./socket"


window.onCodeApply = (elem) => {
  const button = elem.parentNode.childNodes[3];
  const code = elem.parentNode.parentNode.childNodes[1].childNodes[0];
  button.setAttribute("phx-value-code", code.innerText);
  elem.parentNode.childNodes[3].click();
};