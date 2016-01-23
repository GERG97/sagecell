fix-js         = ./fix-js.py
all-css        = static/all.css
all-js         = static/all.js
all-min-css    = static/all.min.css
all-min-js     = static/all.min.js
colorpicker    = static/colorpicker/js/colorpicker.js
compute_server = static/compute_server.js
threed         = static/3d.js
threed-coffee  = static/3d.coffee
jsmol-path     = static/jsmol
jsmol          = $(jsmol-path)/JSmol.min.nojq.js
jquery         = static/jquery.min.js
jquery-ui      = static/jquery-ui/js/jquery-ui-1.10.2.custom.min.js
tos-default    = templates/tos_default.html
tos            = templates/tos.html
tos-static     = static/tos.html
sagecell       = static/sagecell.js
sagecell-css   = static/sagecell.css
fontawesome-css = static/fontawesome.css
embed-css      = static/sagecell_embed.css
sockjs-client  = static/sockjs.js
codemirror-cat = static/codemirror.js
codemirror-css = submodules/codemirror/lib/codemirror.css
fold-css       = submodules/codemirror/addon/fold/foldgutter.css
cm-dir         = submodules/codemirror/
cm-compress    = bin/compress
codemirror     = lib/codemirror.js
cm-brackets    = addon/edit/matchbrackets.js
cm-foldcode    = addon/fold/foldcode.js
cm-foldgutter  = addon/fold/foldgutter.js
cm-foldbrace   = addon/fold/brace-fold.js
cm-foldxml     = addon/fold/xml-fold.js
cm-foldcomment = addon/fold/comment-fold.js
cm-foldindent  = addon/fold/indent-fold.js
cm-python-mode = mode/python/python.js
cm-xml-mode    = mode/xml/xml.js
cm-html-mode   = mode/htmlmixed/htmlmixed.js
cm-js-mode     = mode/javascript/javascript.js
cm-css-mode    = mode/css/css.js
cm-r-mode      = mode/r/r.js
cm-runmode     = addon/runmode/runmode.js
cm-colorize    = addon/runmode/colorize.js
cm-hint-js     = addon/hint/show-hint.js
cm-hint-css    = submodules/codemirror/addon/hint/show-hint.css
cm-fullscreen-js = addon/display/fullscreen.js
cm-fullscreen-css = submodules/codemirror/addon/display/fullscreen.css
jquery-ui-tp   = submodules/jquery-ui-touch-punch/jquery.ui.touch-punch.min.js
cssmin         = submodules/cssmin/src/cssmin.py
jsmin          = submodules/jsmin/jsmin.c
jsmin-bin      = submodules/jsmin-bin
wrap-js        = static/wrap.js
sage-root     := $(shell [ -n "$$SAGE_ROOT" ] && echo "$$SAGE_ROOT" || sage --root || echo "\$$SAGE_ROOT")
nb-static      = $(sage-root)/local/lib/python/site-packages/notebook/static
nb-namespace   = $(nb-static)/base/js/namespace.js
nb-events      = $(nb-static)/base/js/events.js
nb-utils       = $(nb-static)/base/js/utils.js
nb-comm        = $(nb-static)/services/kernels/comm.js
nb-kernel      = $(nb-static)/services/kernels/kernel.js
jquery-url     = http://code.jquery.com/jquery-2.1.3.min.js
sockjs-url     = https://raw.githubusercontent.com/sockjs/sockjs-client/master/dist/sockjs.js
mpl-js         = static/mpl.js
canvas3d       = $(sage-root)/local/lib/python/site-packages/sagenb-*.egg/sagenb/data/sage/js/canvas3d_lib.js
threejs        = $(sage-root)/local/share/threejs/build/three.js
threejs-control= $(sage-root)/local/share/threejs/examples/js/controls/OrbitControls.js
threejs-detect = $(sage-root)/local/share/threejs/examples/js/Detector.js

all: submodules $(jquery) $(all-min-js) $(all-min-css) $(tos-static) $(embed-css)

.PHONY: submodules $(tos-static)

submodules:
	if git submodule status | grep -q ^[+-]; then git submodule update --init > /dev/null; fi

$(jquery):
	python -c "import urllib; urllib.urlretrieve('$(jquery-url)', '$(jquery)')"

$(mpl-js):
	python -c "from matplotlib.backends.backend_webagg_core import FigureManagerWebAgg; print FigureManagerWebAgg.get_javascript().encode('utf8')" > $(mpl-js)

$(all-min-js): $(jsmin-bin) $(all-js) $(codemirror-cat)
	cat $(codemirror-cat) > $(all-min-js)
	$(jsmin-bin) < $(all-js) >> $(all-min-js)


$(codemirror-cat): $(cm-dir)/$(cm-compress) $(cm-dir)/$(codemirror) $(cm-dir)/$(cm-python-mode) \
           $(cm-dir)/$(cm-xml-mode) $(cm-dir)/$(cm-html-mode) $(cm-dir)/$(cm-js-mode) \
           $(cm-dir)/$(cm-css-mode) $(cm-dir)/$(cm-r-mode) $(cm-dir)/$(cm-brackets) \
           $(cm-dir)/$(cm-runmode) $(cm-dir)/$(cm-colorize) $(cm-dir)/$(cm-hint-js) \
           $(cm-dir)/$(cm-fullscreen-js) \
           $(cm-dir)/$(cm-foldcode) $(cm-dir)/$(cm-foldgutter) $(cm-dir)/$(cm-foldbrace) \
           $(cm-dir)/$(cm-foldxml) $(cm-dir)/$(cm-foldcomment) $(cm-dir)/$(cm-foldindent)
	cd $(cm-dir); cat $(codemirror) $(cm-brackets) $(cm-python-mode) $(cm-xml-mode) \
	    $(cm-html-mode) $(cm-js-mode) $(cm-css-mode) $(cm-r-mode) \
	    $(cm-runmode) $(cm-colorize) $(cm-hint-js) $(cm-fullscreen-js) \
           $(cm-foldcode) $(cm-foldgutter) $(cm-foldbrace) \
           $(cm-foldxml) $(cm-foldcomment) $(cm-foldindent) \
           > ../../$(codemirror-cat)

$(all-js): $(nb-namespace) $(wrap-js) $(jsmol) $(canvas3d)\
           $(sockjs-client) $(compute_server) $(sagecell)
	cat $(jsmol) $(canvas3d) $(nb-namespace) $(wrap-js) > $(all-js)
	echo ';' >> $(all-js)
	cat $(sockjs-client) $(compute_server) $(sagecell) >> $(all-js)

# not run by default---we keep this for backwards compatibility until people remove the 'make coffee' line in their scripts
coffee: $(threed-coffee)
	coffee -c $(threed-coffee)

$(threed): $(threed-coffee)
	coffee -c $(threed-coffee)

$(wrap-js): $(nb-events) $(nb-utils) $(nb-kernel) $(nb-comm) $(jquery-ui) $(jquery-ui-tp) \
            $(colorpicker) $(threed) $(mpl-js)
	cat $(nb-events) $(nb-utils) $(nb-kernel) $(nb-comm) $(jquery-ui) $(jquery-ui-tp) \
	    $(colorpicker) $(threejs) $(threejs-control) $(threejs-detect) $(threed) $(mpl-js) > $(wrap-js)
	python $(fix-js) $(wrap-js)

$(all-min-css): $(codemirror-css) $(cm-hint-css) $(cm-fullscreen-css) $(sagecell-css) \
                $(fontawesome-css) $(fold-css)
	cat $(codemirror-css) $(cm-hint-css) $(cm-fullscreen-css) $(sagecell-css) \
            $(fontawesome-css) $(fold-css) | python $(cssmin) > $(all-min-css)

$(jsmin-bin):  $(jsmin)
	gcc -o $(jsmin-bin) $(jsmin)

$(jsmol):
	ln -sfn $(sage-root)/local/share/jsmol $(jsmol-path)
	ln -sf $(sage-root)/local/share/jmol/appletweb/SageMenu.mnu static/SageMenu.mnu

$(tos-static): $(tos-default)
	@[ -e $(tos) ] && cp $(tos) $(tos-static) || cp $(tos-default) $(tos-static)

$(sockjs-client):
	python -c "import urllib; urllib.urlretrieve('$(sockjs-url)', '$(sockjs-client)')"

$(embed-css): $(sagecell-css)
	sed -e 's/;/ !important;/g' < $(sagecell-css) > $(embed-css)
