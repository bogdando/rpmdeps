# rpmdeps
Live building the reversed graph of RPM dependencies, by a raw
RPM manifest file, fetched and processed ah-hoc on the host.

TODO: dedup and visualize ``graph`` file with some python magic.
It only builds raw and redundant entries yet, like:

```
$ bash auto_deps.sh http://<URI-to-full-rpm.manifest>
$ grep python3-jinja2 direct[0-9] lv[0-9]
lv0:python3-jinja2
lv1:python3-jinja2.lv1_required_by          	ansible
lv1:python3-jinja2.lv1_required_by          	cloud-init
lv1:python3-jinja2.lv1_required_by          	python3-ipaclient
lv1:platform-python-setuptools.lv1_required_by	python3-jinja2
lv1:python3-markupsafe.lv1_required_by      	python3-jinja2
lv1:python3-babel.lv1_required_by           	python3-jinja2
lv1:python3-jinja2.lv1_required_by          	python3-oslo-middleware
lv2:python3-jinja2.lv2_required_by          	ansible
lv2:python3-jinja2.lv2_required_by          	cloud-init
lv2:python3-jinja2.lv2_required_by          	python3-ipaclient
lv2:python3-babel.lv2_required_by           	python3-jinja2
lv2:python3-jinja2.lv2_required_by          	python3-oslo-middleware
```
Here ``lv0`` contains the leftmost nodes of the dependency graph (RPM names
stripped their versions off). Those are linked to PRMs that require it, if
any. Then ``lv1`` links the latter with its parent RPMs, etc. The generated
entries are not deduplicated and may repeat itself through different
``lv``/``direct`` files. Files `direct*` contain the rightmost graph nodes
(represent top level, or standalone packages).

## build graph file with all entries
(for all items in the given manifest file, contains redundant entries)
```
cat lv0 | while read p; do grep $(echo $p | awk -F'-[[:digit:]]' '{print $1}') lv[1-9]; done | sort -k 2 > graph
```

# count direct installs
(nothing requires a directly installed package, but it may have dependencies)
```
cat direct0 | wc -l
```
E.g. contains 348 entries.

# find direct standalone installs
(nothing requires, has no deps - standalone/disconnected graph nodes)
```
comm -23 direct0 <(cat direct[1-9] | sort -h | sort -u)
```
Or use [difft](https://github.com/Wilfred/difftastic) for a pretty view.
E.g., it contains 241 entries.

Need to go deeper(c)...
```
difft direct1 <(cat direct[2-9] | sort -h | sort -u)
difft direct2 <(cat direct[3-9] | sort -h | sort -u)
...
???
PROFIT?
```

# find top level installs
(the rightmost nodes in the deps graph, excluding standalone ones)
```
cat direct[1-9] | sort -h | sort -u
```
E.g. it contains 108 entries.
