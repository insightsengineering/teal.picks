function toggleBadgeDropdown(summaryId, containerId) {
  var container = document.getElementById(containerId);
  var summary = document.getElementById(summaryId);

  function hideContainer() {
    container.style.display = 'none';
    $(container).trigger('hidden');
    if (container._originalParent) {
      container._originalParent.appendChild(container);
    }
  }

  if (container.style.display === 'none' || container.style.display === '') {
    // Record original parent before moving to body
    if (!container._originalParent) {
      container._originalParent = container.parentNode;
    }

    // Position relative to the badge
    var rect = summary.getBoundingClientRect();
    container.style.position = 'absolute';
    container.style.top = (rect.bottom + window.scrollY + 4) + 'px';
    container.style.left = (rect.left + window.scrollX) + 'px';

    document.body.appendChild(container);

    container.style.display = 'block';
    $(container).trigger('shown');
    Shiny.bindAll(container);

    // Add click outside handler
    setTimeout(function() {
      function handleClickOutside(event) {
        if (!container.contains(event.target) && !summary.contains(event.target)) {
          container.style.visibility = 'hidden';
          container.style.opacity = '0';
          container.style.pointerEvents = 'none';
          $(container).trigger('hidden');
          document.removeEventListener('click', handleClickOutside);
        }
      }
      document.addEventListener('click', handleClickOutside);
    }, 10);
  } else {
    container.style.visibility = 'hidden';
    container.style.opacity = '0';
    container.style.pointerEvents = 'none';
    $(container).trigger('hidden');
  }
}
