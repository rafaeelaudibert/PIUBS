!function(){"use strict";var e,t,n,r,o,a,i=tinymce.util.Tools.resolve("tinymce.PluginManager"),l=function(e){return function(){return e}},c=function(e){for(var t=[],n=1;n<arguments.length;n++)t[n-1]=arguments[n];for(var r=new Array(arguments.length-1),o=1;o<arguments.length;o++)r[o-1]=arguments[o];return function(){for(var t=[],n=0;n<arguments.length;n++)t[n]=arguments[n];for(var o=new Array(arguments.length),a=0;a<o.length;a++)o[a]=arguments[a];var i=r.concat(o);return e.apply(null,i)}},u=l(!1),s=l(!0),f=u,m=s,d=function(){return p},p=(r={fold:function(e){return e()},is:f,isSome:f,isNone:m,getOr:n=function(e){return e},getOrThunk:t=function(e){return e()},getOrDie:function(e){throw new Error(e||"error: getOrDie called on none.")},getOrNull:function(){return null},getOrUndefined:function(){return undefined},or:n,orThunk:t,map:d,ap:d,each:function(){},bind:d,flatten:d,exists:f,forall:m,filter:d,equals:e=function(e){return e.isNone()},equals_:e,toArray:function(){return[]},toString:l("none()")},Object.freeze&&Object.freeze(r),r),h=function(e){var t=function(){return e},n=function(){return o},r=function(t){return t(e)},o={fold:function(t,n){return n(e)},is:function(t){return e===t},isSome:m,isNone:f,getOr:t,getOrThunk:t,getOrDie:t,getOrNull:t,getOrUndefined:t,or:n,orThunk:n,map:function(t){return h(t(e))},ap:function(t){return t.fold(d,function(t){return h(t(e))})},each:function(t){t(e)},bind:r,flatten:t,exists:r,forall:r,filter:function(t){return t(e)?o:p},equals:function(t){return t.is(e)},equals_:function(t,n){return t.fold(f,function(t){return n(e,t)})},toArray:function(){return[e]},toString:function(){return"some("+e+")"}};return o},y={some:h,none:d,from:function(e){return null===e||e===undefined?p:h(e)}},g=(o="function",function(e){return function(e){if(null===e)return"null";var t=typeof e;return"object"===t&&Array.prototype.isPrototypeOf(e)?"array":"object"===t&&String.prototype.isPrototypeOf(e)?"string":t}(e)===o}),k=(a=Array.prototype.indexOf)===undefined?function(e,t){return x(e,t)}:function(e,t){return a.call(e,t)},v=function(e,t){return-1<k(e,t)},b=function(e,t){for(var n=e.length,r=new Array(n),o=0;o<n;o++){var a=e[o];r[o]=t(a,o,e)}return r},x=function(e,t){for(var n=0,r=e.length;n<r;++n)if(e[n]===t)return n;return-1},w=(Array.prototype.slice,g(Array.from)&&Array.from,tinymce.util.Tools.resolve("tinymce.util.I18n")),A=tinymce.util.Tools.resolve("tinymce.Env"),C=A.mac?"\u2318":"Ctrl",S=A.mac?"Ctrl + Alt":"Shift + Alt",O={shortcuts:[{shortcut:C+" + B",action:"Bold"},{shortcut:C+" + I",action:"Italic"},{shortcut:C+" + U",action:"Underline"},{shortcut:C+" + A",action:"Select all"},{shortcut:C+" + Y or "+C+" + Shift + Z",action:"Redo"},{shortcut:C+" + Z",action:"Undo"},{shortcut:S+" + 1",action:"Header 1"},{shortcut:S+" + 2",action:"Header 2"},{shortcut:S+" + 3",action:"Header 3"},{shortcut:S+" + 4",action:"Header 4"},{shortcut:S+" + 5",action:"Header 5"},{shortcut:S+" + 6",action:"Header 6"},{shortcut:S+" + 7",action:"Paragraph"},{shortcut:S+" + 8",action:"Div"},{shortcut:S+" + 9",action:"Address"},{shortcut:"Alt + F9",action:"Focus to menubar"},{shortcut:"Alt + F10",action:"Focus to toolbar"},{shortcut:"Alt + F11",action:"Focus to element path"},{shortcut:"Ctrl + Shift + P > Ctrl + Shift + P",action:"Focus to contextual toolbar"},{shortcut:C+" + K",action:"Insert link (if link plugin activated)"},{shortcut:C+" + S",action:"Save (if save plugin activated)"},{shortcut:C+" + F",action:"Find (if searchreplace plugin activated)"}]},P=function(){var e=b(O.shortcuts,function(e){return'<tr data-mce-tabstop="1" tabindex="-1" aria-label="Action: '+(t=e).action+", Shortcut: "+t.shortcut.replace(/Ctrl/g,"Control")+'"><td>'+w.translate(e.action)+"</td><td>"+e.shortcut+"</td></tr>";var t}).join("");return{title:"Handy Shortcuts",type:"container",style:"overflow-y: auto; overflow-x: hidden; max-height: 250px",items:[{type:"container",html:'<div><table class="mce-table-striped"><thead><th>'+w.translate("Action")+"</th><th>"+w.translate("Shortcut")+"</th></thead>"+e+"</table></div>"}]}},T=Object.keys,_=[{key:"advlist",name:"Advanced List"},{key:"anchor",name:"Anchor"},{key:"autolink",name:"Autolink"},{key:"autoresize",name:"Autoresize"},{key:"autosave",name:"Autosave"},{key:"bbcode",name:"BBCode"},{key:"charmap",name:"Character Map"},{key:"code",name:"Code"},{key:"codesample",name:"Code Sample"},{key:"colorpicker",name:"Color Picker"},{key:"compat3x",name:"3.x Compatibility"},{key:"contextmenu",name:"Context Menu"},{key:"directionality",name:"Directionality"},{key:"emoticons",name:"Emoticons"},{key:"fullpage",name:"Full Page"},{key:"fullscreen",name:"Full Screen"},{key:"help",name:"Help"},{key:"hr",name:"Horizontal Rule"},{key:"image",name:"Image"},{key:"imagetools",name:"Image Tools"},{key:"importcss",name:"Import CSS"},{key:"insertdatetime",name:"Insert Date/Time"},{key:"legacyoutput",name:"Legacy Output"},{key:"link",name:"Link"},{key:"lists",name:"Lists"},{key:"media",name:"Media"},{key:"nonbreaking",name:"Nonbreaking"},{key:"noneditable",name:"Noneditable"},{key:"pagebreak",name:"Page Break"},{key:"paste",name:"Paste"},{key:"preview",name:"Preview"},{key:"print",name:"Print"},{key:"save",name:"Save"},{key:"searchreplace",name:"Search and Replace"},{key:"spellchecker",name:"Spell Checker"},{key:"tabfocus",name:"Tab Focus"},{key:"table",name:"Table"},{key:"template",name:"Template"},{key:"textcolor",name:"Text Color"},{key:"textpattern",name:"Text Pattern"},{key:"toc",name:"Table of Contents"},{key:"visualblocks",name:"Visual Blocks"},{key:"visualchars",name:"Visual Characters"},{key:"wordcount",name:"Word Count"}],H=c(function(e,t){return e.replace(/\$\{([^{}]*)\}/g,function(e,n){var r,o=t[n];return"string"==(r=typeof o)||"number"===r?o.toString():e})},'<a href="${url}" target="_blank" rel="noopener">${name}</a>'),F=function(e,t){return function(e,t){for(var n=0,r=e.length;n<r;n++){var o=e[n];if(t(o,n,e))return y.some(o)}return y.none()}(_,function(e){return e.key===t}).fold(function(){var n=e.plugins[t].getMetadata;return"function"==typeof n?H(n()):t},function(e){return H({name:e.name,url:"https://www.tinymce.com/docs/plugins/"+e.key})})},M=function(e){var t,n,r,o=(r=T((t=e).plugins),t.settings.forced_plugins===undefined?r:function(e,t){for(var n=[],r=0,o=e.length;r<o;r++){var a=e[r];t(a,r,e)&&n.push(a)}return n}(r,(n=c(v,t.settings.forced_plugins),function(){for(var e=[],t=0;t<arguments.length;t++)e[t]=arguments[t];return!n.apply(null,arguments)}))),a=b(o,function(t){return"<li>"+F(e,t)+"</li>"}),i=a.length,l=a.join("");return"<p><b>"+w.translate(["Plugins installed ({0}):",i])+"</b></p><ul>"+l+"</ul>"},E=function(e){return{title:"Plugins",type:"container",style:"overflow-y: auto; overflow-x: hidden;",layout:"flex",padding:10,spacing:10,items:[(t=e,{type:"container",html:'<div style="overflow-y: auto; overflow-x: hidden; max-height: 230px; height: 230px;" data-mce-tabstop="1" tabindex="-1">'+M(t)+"</div>",flex:1}),{type:"container",html:'<div style="padding: 10px; background: #e3e7f4; height: 100%;" data-mce-tabstop="1" tabindex="-1"><p><b>'+w.translate("Premium plugins:")+'</b></p><ul><li>PowerPaste</li><li>Spell Checker Pro</li><li>Accessibility Checker</li><li>Advanced Code Editor</li><li>Enhanced Media Embed</li><li>Link Checker</li></ul><br /><p style="float: right;"><a href="https://www.tinymce.com/pricing/?utm_campaign=editor_referral&utm_medium=help_dialog&utm_source=tinymce" target="_blank">'+w.translate("Learn more...")+"</a></p></div>",flex:1}]};var t},I=tinymce.util.Tools.resolve("tinymce.EditorManager"),j=function(){var e,t,n='<a href="https://www.tinymce.com/docs/changelog/?utm_campaign=editor_referral&utm_medium=help_dialog&utm_source=tinymce" target="_blank">TinyMCE '+(e=I.majorVersion,t=I.minorVersion,0===e.indexOf("@")?"X.X.X":e+"."+t)+"</a>";return[{type:"label",html:w.translate(["You are using {0}",n])},{type:"spacer",flex:1},{text:"Close",onclick:function(){this.parent().parent().close()}}]},L=function(e,t){return function(){e.windowManager.open({title:"Help",bodyType:"tabpanel",layout:"flex",body:[P(),E(e)],buttons:j(),onPostRender:function(){this.getEl("title").innerHTML='<img src="'+t+'/img/logo.png" alt="TinyMCE Logo" style="display: inline-block; width: 200px; height: 50px">'}})}},B=function(e,t){e.addCommand("mceHelp",L(e,t))},N=function(e,t){e.addButton("help",{icon:"help",onclick:L(e,t)}),e.addMenuItem("help",{text:"Help",icon:"help",context:"help",onclick:L(e,t)})};i.add("help",function(e,t){N(e,t),B(e,t),e.shortcuts.add("Alt+0","Open help dialog","mceHelp")})}();