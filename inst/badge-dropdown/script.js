function toggleBadgeDropdown(summaryId, containerId) {
  var container = document.getElementById(containerId);
  var summary = document.getElementById(summaryId);

  if (container.style.visibility === 'hidden' || container.style.visibility === '') {
    // Record original parent before moving to body
    if (!container._originalParent) {
      container._originalParent = container.parentNode;
    }

    // Position relative to the badge
    var rect = summary.getBoundingClientRect();
    container.style.position = 'absolute';
    // container.style.top = (rect.bottom + 4) + 'px';
    // container.style.left = rect.left + 'px';
    container.style.top = (rect.bottom + window.scrollY + 4) + 'px';
    container.style.left = (rect.left + window.scrollX) + 'px';

    document.body.appendChild(container);

    container.style.visibility = 'visible';
    container.style.opacity = '1';
    container.style.pointerEvents = 'auto';
    $(container).trigger('shown');
    Shiny.bindAll(container);

    // Add click outside handler
    setTimeout(function() {
      function handleClickOutside(event) {
        if (!container.contains(event.target) && !summary.contains(event.target)) {
          container.style.visibility = 'hidden';
          container.style.top = 0;
          container.style.left = 0;
          container.style.opacity = '0';
          container.style.pointerEvents = 'none';
          $(container).trigger('hidden');
          if (container._originalParent) { // Return to original parent
            container._originalParent.appendChild(container);
          }
          document.removeEventListener('click', handleClickOutside);
        }
      }
      document.addEventListener('click', handleClickOutside);
    }, 10);
  } else {
    container.style.visibility = 'hidden';
    container.style.top = 0;
    container.style.left = 0;

    container.style.opacity = '0';
    container.style.pointerEvents = 'none';
    $(container).trigger('hidden');
    if (container._originalParent) { // Return to original parent
      container._originalParent.appendChild(container);
    }
  }
}
