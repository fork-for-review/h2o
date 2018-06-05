import {html} from 'es6-string-html-template';
import {post, rest_delete} from 'lib/requests';
import throttle from 'lodash.throttle';
import Component from 'lib/ui/component'
import delegate from 'delegate';

delegate(document, '.annotate.elide', 'click', e => {
  let annotationId = e.target.dataset.annotationId;
  let elisions = document.querySelectorAll(`.annotate.elided[data-annotation-id="${annotationId}"]`);
  toggleElisionVisibility(annotationId, 'elide', e.target, elisions);
});

export function toggleElisionVisibility(annotationId, annotationType, toggleButton, toggledContentNodes){
  toggleButton.classList.toggle('revealed');
  if (toggleButton.classList.contains('revealed')){
    toggleButton.setAttribute('aria-expanded', 'true');
    toggledContentNodes[toggledContentNodes.length - 1].insertAdjacentHTML('afterend', `<span class="annotate ${annotationType}d revealed sr-only" data-annotation-id="${annotationId}">(end of ${annotationType}d text)</span>`);
  } else {
    toggleButton.setAttribute('aria-expanded', 'false');
    toggledContentNodes[toggledContentNodes.length - 1].remove();
  }
  for (let el of toggledContentNodes) {
    el.classList.toggle('revealed');
    el.parentElement.classList.toggle('revealed');
    el.parentElement.previousElementSibling.classList.toggle('revealed');
  }
}
