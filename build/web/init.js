// Prevent Flutter from registering a service worker
window.addEventListener('load', function(ev) {
  // Override service worker registration
  navigator.serviceWorker = {
    register: function() {
      return Promise.resolve(null);
    },
    getRegistrations: function() {
      return Promise.resolve([]);
    }
  };

  // Set up Flutter target
  const target = document.getElementById('flutter_target');
  if (target) {
    target.style.width = '100%';
    target.style.height = '100%';
    target.style.display = 'flex';
    target.style.backgroundColor = 'white';
  }
});
