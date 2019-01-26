const transferAttributes = (src, dest) => {
    for(let i = 0; i < src.attributes.length; i++) {
        let attr = src.attributes[i];
        dest.setAttribute(attr.name, attr.value);
    }
};

const replaceTag = (el, newTag) => {
  let newEl = document.createElement(newTag);
  transferAttributes(el, newEl);
  newEl.innerHTML = el.innerHTML;
  el.parentNode.replaceChild(newEl, el);
};

const unwrap = (el) => {
  let parent = el.parentNode;
  while (el.firstChild) parent.insertBefore(el.firstChild, el);
  parent.removeChild(el);
};

export const unwrapUndesiredTags = (doc) => {
  doc.querySelectorAll("article, section, aside").forEach(unwrap);
  return doc;
};

export const emptyULToP = (doc) => {
  Array.from(doc.querySelectorAll("ul"))
       .filter((ul) => ul.querySelector(":not(li)") || ul.children.length == 0)
    .forEach(ul => replaceTag(ul, "p"));
  return doc;
};

export const wrapBareInlineTags = (doc) => {
  doc.querySelectorAll("body > :not(p):not(center):not(blockquote):not(article)")
      .forEach(el => replaceTag(el, "p"));
  return doc;
};

export const removeEmptyNodes = (doc) => {
  while(doc.querySelectorAll(":empty").length){
    doc.querySelectorAll(":empty").forEach(el => el.remove());
  };
  return doc;
};

export const isElement = (node) =>
  node.nodeType == 1;

export const isText = (node) =>
  node.nodeType == 3;

export const isBR = (node) =>
  node.tagName == "BR";

export const getLength = (node) =>
  (isElement(node) && !isBR(node) ? node.innerText : node.textContent).length;

export const getAttrsMap = (el) => {
  let nodelist = el.attributes;
  let attrmap = {};
  let i = 0;
  for (; i < nodelist.length; i++) {
    attrmap[nodelist[i].name] = nodelist[i].value;
  }
  return attrmap;
};