// CloudFront Function (viewer-request, cloudfront-js-2.0).
// 301s to one canonical URL per page (https://${canonical_host}, trailing slash,
// no index.html%{ if root_language != "" }, no /${root_language}/ prefix%{ endif }), then maps directory URLs to Hugo's index.html.
function handler(event) {
  var r = event.request;
  var host = r.headers.host ? r.headers.host.value.toLowerCase() : "";
  var uri = r.uri;

  // /foo/index.html -> /foo/
  if (uri.endsWith("/index.html")) uri = uri.slice(0, -"index.html".length);

  if (uri.split("/").pop().indexOf(".") === -1) {
    // /foo -> /foo/ so relative links resolve
    if (!uri.endsWith("/")) uri += "/";
%{ if root_language != "" ~}
    // The default language lives at the root; Hugo's /${root_language}/ is only an alias.
    // Files such as /${root_language}/sitemap.xml are real and stay put.
    if (uri.indexOf("/${root_language}/") === 0) uri = uri.slice(${length(root_language) + 1});
%{ endif ~}
  }

  if (host !== "${canonical_host}" || uri !== r.uri) {
    var qs = Object.keys(r.querystring)
      .map(function (k) {
        var v = r.querystring[k];
        return v.value ? k + "=" + v.value : k;
      })
      .join("&");
    return {
      statusCode: 301,
      statusDescription: "Moved Permanently",
      headers: {
        location: { value: "https://${canonical_host}" + uri + (qs ? "?" + qs : "") },
      },
    };
  }

  if (uri.endsWith("/")) r.uri += "index.html";
  return r;
}
