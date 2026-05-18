
function router() {
  const route = window.location.hash || "#/";

  const app = document.getElementById("app");

  switch (route) {
    case "#/":
      app.innerHTML = "<h1>Home</h1><p>Welcome to my simple SPA running on IIS.</p>";
      break;

    case "#/about":
      app.innerHTML = "<h1>About</h1><p>This SPA is deployed on an Azure VM inside an ALZ.</p>";
      break;

    case "#/contact":
      app.innerHTML = "<h1>Contact</h1><p>You can put anything here.</p>";
      break;

    default:
      app.innerHTML = "<h1>404</h1><p>Page not found.</p>";
  }
}

window.addEventListener("hashchange", router);
window.addEventListener("load", router);
