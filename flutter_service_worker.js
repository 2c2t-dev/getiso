'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "b3ea3076bd1c62eb776f651da40edb94",
"assets/AssetManifest.bin.json": "22ed4ac8e4ffa2876065220bb868abce",
"assets/AssetManifest.json": "ca92e83f1196152f2e31d47ee43e72eb",
"assets/assets/icons/linux.png": "5d1b5a031ef1e50743548c98823db40c",
"assets/assets/icons/macos.png": "a22b2e7d8200de522e46126db65bb287",
"assets/assets/icons/nas.png": "24de49ad0d0392396a82cc0d75aea499",
"assets/assets/icons/other.png": "be5dd1a961aecd8f7ceb3a5fbf618838",
"assets/assets/icons/router.png": "3eee797c8e43fea43dcee5bd33d301cd",
"assets/assets/icons/windows.png": "eaadf82205690040b1b5db44d20a2017",
"assets/assets/os/linux/almalinux.png": "65d413c4fd3babe24ddcd0d276b7085c",
"assets/assets/os/linux/alpine.png": "b808cb985d450e5b5a1ead59860a732e",
"assets/assets/os/linux/archlinux.png": "b15a81dd9dd39bb3ba9214be1e791c3f",
"assets/assets/os/linux/debian.png": "b712accdfcbc11f682f26c6171b7bf18",
"assets/assets/os/linux/fedora.png": "2d42a3eabe0ddc8a6b056f46027b2ca7",
"assets/assets/os/linux/popos.png": "80a31c9fb05ccd0e253097b8b0168b2e",
"assets/assets/os/linux/rockylinux.png": "33494075d6df2730aac969282ee462b1",
"assets/assets/os/linux/ubuntu.png": "9bc1a35ac54f065c4d082c78f4fb29d9",
"assets/assets/os/linux/zorinos.png": "c87a067229de13f13f85c08a1762730f",
"assets/assets/os/macos/10.1.png": "5c50e1c76dcd52e0678746f1cfcd5e06",
"assets/assets/os/macos/10.10.png": "9f478feede39768c3ab66d1cb9554419",
"assets/assets/os/macos/10.11.png": "94ed1ae1e0b310511d34c2c3f64a5d45",
"assets/assets/os/macos/10.12.png": "d75562d60dcfb11f6f9aef7587b74150",
"assets/assets/os/macos/10.13.png": "6d35b0ce9155a19f3def5965666d909f",
"assets/assets/os/macos/10.14.png": "850b59c606e7be7ea35c217568a121ab",
"assets/assets/os/macos/10.15.png": "0c7165d60af42d064b1110f6d5acb607",
"assets/assets/os/macos/10.2.png": "cc22736421b0a9e2ea5724b86cc7cf9c",
"assets/assets/os/macos/10.3.png": "f41f4529f5c7c1802c222cb17969d4df",
"assets/assets/os/macos/10.4.png": "b46ec161370c92c58b02505f7b03e7c0",
"assets/assets/os/macos/10.5.png": "64031f17830b3b9e2174a8789e5864bd",
"assets/assets/os/macos/10.6.png": "370e137c69ba92ad0c31728e41561963",
"assets/assets/os/macos/10.7.png": "e509d56d157982d78d1b414593490923",
"assets/assets/os/macos/10.8.png": "b3d61962cafff5566dc8ace17339bb1b",
"assets/assets/os/macos/10.9.png": "032bdfe1eb3a07e6d54627e267d7d72c",
"assets/assets/os/macos/11.png": "9bf062f975c607a7a56677caccde6c7d",
"assets/assets/os/macos/12.png": "9c28ba8c6dcde74bbefb13b463b16107",
"assets/assets/os/macos/13.png": "24e837907763b7cc39d84a9c390b625d",
"assets/assets/os/macos/14.png": "6364b2bd265c3252c6de8fe0f702112c",
"assets/assets/os/macos/15.png": "d3fab55ece8718cf0333d2991ae73cbc",
"assets/assets/os/windows/10.png": "a4810e069f641a86a370f19e3fa27e83",
"assets/assets/os/windows/11.png": "eaadf82205690040b1b5db44d20a2017",
"assets/assets/os/windows/2000.png": "fd4219be7138d053d57974ce51aefaa6",
"assets/assets/os/windows/3.1.png": "0cd5ad9a3ab5613f265afab2692dc78d",
"assets/assets/os/windows/7.png": "8fec7d5eeb888a788c56a8cd97b2014e",
"assets/assets/os/windows/8.1.png": "0624fa4facfc95fa380c1d8ebf6c5fed",
"assets/assets/os/windows/8.png": "212299c0cc08dfbbbb9ddc7c088076c2",
"assets/assets/os/windows/95.png": "a4c01d87301b286073ff74f25fc39154",
"assets/assets/os/windows/98.png": "5e3c9efff04045e148440dd1af1482a6",
"assets/assets/os/windows/ME.png": "e1992f9ca5295a4ddf829da6691a290c",
"assets/assets/os/windows/XP.png": "c585ba26ff0d81a60453b9551a795d68",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "8770e05426195f929e098a64d7743681",
"assets/NOTICES": "dbc187d984a8380dfc55799c21ff85a1",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "5056e3e4a63202f2a83389b3ebb14ff9",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "a96ca916fdc5557667990b84eb2e4e44",
"/": "a96ca916fdc5557667990b84eb2e4e44",
"main.dart.js": "93a3eb881912a6f35e12dfdf478c924a",
"manifest.json": "a3bd37898cde048de06f8f14ef254cb8",
"version.json": "23cb079911a56b150d3fc6f608fa244d"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
