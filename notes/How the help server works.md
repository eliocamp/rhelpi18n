

`127.0.0.1:10463/library/NULL/help/{topic}`  resolves to the help section of that topic. For example, `http://127.0.0.1:10463/library/NULL/help/mean` will redirect to `http://127.0.0.1:10463/library/base/html/mean.html`.

It is aware of loaded packages, so, for instance, `http://127.0.0.1:10463/library/NULL/help/filter` will redirect to `http://127.0.0.1:10463/library/stats/html/filter.html` if no package is loaded, but it will redirect to a disambiguation page if you then load dplyr. This not only means that the help server does a lot of heavy lifting, but that it basically ignores the paths returned by `help()`!