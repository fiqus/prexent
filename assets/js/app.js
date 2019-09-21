// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"
import "highlight.js/styles/monokai.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import hljs from "highlight.js";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import "./socket"

function onMutation() {
  document.querySelectorAll("pre code").forEach((block) => {
    if (! block.classList.contains("highlighted")) {
      block.classList.add("highlighted");
      hljs.highlightBlock(block);
    }
  });
}

// Select the nodes that will be observed for mutations
Array.from(document.getElementsByTagName("body")).forEach((body) => {
  // Create an observer instance with a callback function to execute when mutations are observed
  const observer = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      if (mutation.type == "childList") {
        onMutation(mutation);
      }
    }
  });

  // Start observing the target node for configured mutations (which mutations to observe)
  observer.observe(body, {attributes: true, childList: true, subtree: true});
});