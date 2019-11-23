import hljs from "highlight.js";

function codeHighlight(block) {
  if (!block.classList.contains("highlighted") && !block.classList.contains("nohighlight")) {
    block.classList.add("highlighted");
    hljs.highlightBlock(block);
  }
}

const hooks = {
  "code-highlight": {
    mounted() {
      codeHighlight(this.el);
    },
    updated() {
      codeHighlight(this.el);
    }
  }
};

export default hooks
