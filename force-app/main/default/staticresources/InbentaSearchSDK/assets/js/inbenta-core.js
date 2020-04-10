/*
 * Inbenta SDK
 * (c) 2020 Inbenta <https://www.inbenta.com/>
 */
(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? factory() :
  typeof define === 'function' && define.amd ? define(factory) :
  (factory());
}(this, (function () { 'use strict';

  /* --------------------------------------------------
  |                  ImportScript
  |---------------------------------------------------
  |
  | Load script dynamically and instantly trigger a function
  | @param  {object || string}     script    Script attributes
  | @param  {function}             callback  Function to be triggered when the file is completely loaded
  |
  */

  function importScript (script, callback) {
    var dom = document.createElement('script');
    if (callback) { dom.onload = callback; }
    script.type ? dom.type = script.type : dom.type = 'text/javascript';
    if (typeof (script) === 'object') {
      if (script.src) { dom.src = script.src; }
      if (script.integrity) { dom.integrity = script.integrity; }
      if (script.crossorigin) { dom.crossOrigin = script.crossorigin; }
    } else if (typeof (script) === 'string') {
      dom.src = script;
    } else {
      throw new Error('Helper - importScript: script argument passed is not valid');
    }
    document.getElementsByTagName('head')[0].appendChild(dom, document.currentScript);
  }

  /**
   * Get Inbenta SDK script
   * @param   {object}  conf      Script configuration
   * @param   {string}  product   Inbenta SDK product (km / search)
   * @return  {object}            Inbenta SDK Script
   */
  function getSDKScript (conf, product) {
    var script = {};

    // Set script src & type
    script.type = 'text/javascript';
    script.src = 'https://sdk.inbenta.io/' + product + '/' + conf.version + '/inbenta-' + product + '-sdk.js';

    // Set script integrity
    if (conf.integrity) {
      script.integrity = conf.integrity;
      script.crossorigin = 'anonymous';
    }

    return script;
  }

  /* --------------------------------------------------
  |                  BuildHTML
  |---------------------------------------------------
  |
  | This function creates all the HTML elements that Inbenta
  | needs in order to work.
  | @components: object of the sdk components configuration
  |
  */
  function buildHTML (appConfig) {
    var inbentaElements = {};
    var inbentaWrapperDiv = createDiv(document.body, 'inbenta-search-elements-wrapper');
    
    // Create div for the autocompleter component if its active
    if (appConfig.autocompleter && appConfig.autocompleter.length) {
      inbentaElements['autocompleter'] = [];
      var inbentaAutocompletersWrapperDiv = createDiv(inbentaWrapperDiv, 'inbenta-search-autocompleters-wrapper');

      appConfig.autocompleter.forEach(function (autocompleter, index) {
        if (autocompleter.active === true || typeof autocompleter.active === 'undefined') {
          var autocompleterParent = document.createElement('div');
          autocompleterParent.setAttribute('id', 'inbenta-search-autocompleter-parent--' + index);
          autocompleterParent.setAttribute('class', 'inbenta-search-autocompleter-parent');
          autocompleterParent.classList.add('inbenta-search-autocompleter-parent--' + index);
          if (autocompleter.name) { autocompleterParent.classList.add('inbenta-search-autocompleter-parent--' + autocompleter.name); }
          autocompleterParent.setAttribute('style', 'z-index: 9999');
          inbentaAutocompletersWrapperDiv.appendChild(autocompleterParent);

          createDiv(autocompleterParent, 'inbenta-autocompleter');

          inbentaElements['autocompleter'].push(autocompleterParent);
        }
      });
    }
    
    if (appConfig.search && appConfig.search.length) {
      inbentaElements['search'] = [];
      appConfig.search.forEach(function (search, index) {
        if (search.active === true || typeof search.active === 'undefined') {
          // Create wrapper for all the SDK application
          var searchParent = document.createElement('div');
          searchParent.setAttribute('id', 'inbenta-search-results-parent--' + index);
          searchParent.setAttribute('class', 'inbenta-search-results-parent');
          searchParent.classList.add('inbenta-search-results-parent--' + index);
          if (search.name) { searchParent.classList.add('inbenta-search-results-parent--' + search.name); }

          // Create div for the searchBox component
          if (search.components.searchBox && (search.components.searchBox.active === true || typeof search.components.searchBox.active === 'undefined')) {
            createDiv(searchParent, 'inbenta-searchBox');
          }

          // Create wrapper for the SDK header
          var parentHeader = createDiv(searchParent, 'inbenta-search-results-parent__header');

          // Create div for the stats component
          if (search.components.stats && (search.components.stats.active === true || typeof search.components.stats.active === 'undefined')) {
            createDiv(parentHeader, 'inbenta-stats');
          }

          // Create div for the sortBy component if its active
          if (search.components.sortBy && (search.components.sortBy.active === true || typeof search.components.sortBy.active === 'undefined')) {
            createDiv(parentHeader, 'inbenta-sort-by');
          }

          // Create div for the resultsPerPage component if its active
          if (search.components.resultsPerPageSelector && (search.components.resultsPerPageSelector.active === true || typeof search.components.resultsPerPageSelector.active === 'undefined')) {
            createDiv(parentHeader, 'inbenta-results-per-page');
          }

          // Create wrapper for the SDK results and filters
          var parentSearch = createDiv(searchParent, 'inbenta-search-results-parent__body');

          // Create div for the filters component if its active
          if (search.components.filters && (search.components.filters.active === true || typeof search.components.filters.active === 'undefined')) {
            createDiv(parentSearch, 'inbenta-filters');
          }

          // Create wrapper for the SDK results
          var parentResults = createDiv(parentSearch, 'inbenta-search-results-parent__body__main');

          // Create div for the filters component if its active
          if (search.components.tabs && (search.components.tabs.active === true || typeof search.components.tabs.active === 'undefined')) {
            createDiv(parentResults, 'inbenta-tabs');
          }

          // Create div for the pagination component if its active
          if (search.components.paginationTop && (search.components.paginationTop.active === true || typeof search.components.paginationTop.active === 'undefined')) {
            createDiv(parentResults, 'inbenta-pagination-top');
          }
          
          // Create div for the results component, this component can't be deactivated
          createDiv(parentResults, 'inbenta-results');

          // Create div for the noResults component if its active
          if (search.components.noResults && (search.components.noResults.active === true || typeof search.components.noResults.active === 'undefined')) {
            createDiv(parentResults, 'inbenta-no-results');
          }

          // Create div for the pagination component if its active
          if (search.components.paginationBottom && (search.components.paginationBottom.active === true || typeof search.components.paginationBottom.active === 'undefined')) {
            createDiv(parentResults, 'inbenta-pagination-bottom');
          }

          // Create div for the loader component if its active
          if (search.components.loader && (search.components.loader.active === true || typeof search.components.loader.active === 'undefined')) {
            createDiv(searchParent, 'inbenta-loader');
          }

          inbentaElements['search'].push(searchParent);
        }    });
    }

    if (appConfig.deflection && appConfig.deflection.length) {
      inbentaElements['deflection'] = [];
      var inbentaDeflectionsWrapperDiv = createDiv(inbentaWrapperDiv, 'inbenta-search-deflections-wrapper');

      appConfig.deflection.forEach(function (deflection, index) {
        if (deflection.active === true || typeof deflection.active === 'undefined') {
          var parentDeflections = document.createElement('div');
          parentDeflections.setAttribute('id', 'inbenta-search-deflections-parent--' + index);
          parentDeflections.setAttribute('class', 'inbenta-search-deflections-parent');
          parentDeflections.classList.add('inbenta-search-deflections-parent--' + index);
          if (deflection.name) { parentDeflections.classList.add('inbenta-search-deflections-parent--' + deflection.name); }

          // Create div for the instants component if its active
          if (deflection.components.instants && (deflection.components.instants.active === true || typeof deflection.components.instants.active === 'undefined')) {
            createDiv(parentDeflections, 'inbenta-instants');
          }

          // Create div for the lastChance component if its active
          if (deflection.components.lastChance && (deflection.components.lastChance.active === true || typeof deflection.components.lastChance.active === 'undefined')) {
            createDiv(parentDeflections, 'inbenta-last-chance');
          }
          inbentaDeflectionsWrapperDiv.appendChild(parentDeflections);
          inbentaElements['deflection'].push(parentDeflections);
        }
      });
    }
    
    return inbentaElements;
  }

  /* --------------------------------------------------
  |                  createDiv
  |---------------------------------------------------
  |
  | This function creates a div
  | needs in order to work.
  | @parent: parent div
  | @child: child div
  */
  function createDiv (parent, child) {
    var div = document.createElement('div');
    div.setAttribute('id', child);
    div.setAttribute('class', child);
    if (parent) { parent.appendChild(div); }
    return div;
  }

  /**
   * Observe when a group of elements were set or removed from the DOM
   * Executes provided functions on each case.
   *
   * @param {Array of Strings}          elements     Array of CSS Selectors that references the elements which are desired to be observed.
   * @param {Function}                  onloadFn     Function to be launched when all the elements were set on the DOM.
   * @param {Function}                  onunloadFn   Function to be launched when at least one of the elements were deleted from the DOM.
   * @param {String, Array of Strings}  page         URL Path that limits on which Path the onloadFn will be launched.
   * @param {Boolean}                   stop         Defines if the observer will be stoped after the first time the elements were set on the DOM.
   *
   */
  function elementsObserver (elements, onloadFn, onunloadFn, page, stop) {
    if (typeof elements === 'string') { singleElementObserver(elements, onloadFn, onunloadFn, page, stop); }
    else if (Array.isArray(elements) && elements.length > 0 && elements.every(function (i) { return typeof i === "string" })) {
      if (elements.length > 1) { multipleElementsObserver(elements, onloadFn, onunloadFn, page, stop); }
      else if (elements.length === 1) { singleElementObserver(elements[0], onloadFn, onunloadFn, page, stop); }
    }
  }

  function singleElementObserver (element, onloadFn, onunloadFn, page, stop) {
    var observer;
    var lastElement;
    
    function launchFunction () {
      var elementExists = document.querySelector(element);
      if (elementExists && elementExists !== lastElement && checkPath(page)) {
        lastElement = elementExists;
        if (onloadFn) { onloadFn(); }
        if (stop && observer) { observer.disconnect(); }
      } else if (!elementExists || (elementExists && !checkPath(page))) {
        if (onunloadFn && lastElement) { onunloadFn(); }
        lastElement = undefined;
      }
    }
    launchFunction();
    observer = new MutationObserver(launchFunction);
    observer.observe(document, { attributes: false, childList: true, characterData: false, subtree: true });
    if (stop && lastElement) { observer.disconnect(); }
  }

  function multipleElementsObserver (elements, onloadFn, onunloadFn, page, stop) {
    var observer;
    var lastElements = [];
    var loaded = false;

    function checkExist (element, index) {
      var elementExist = document.querySelector(element);
      if (elementExist && elementExist !== lastElements[index]) {
        lastElements[index] = elementExist;
        loaded = false;
        return true;
      } else if (!elementExist) {
        lastElements[index] = undefined;
        return false;
      }
      return true;
    }
    function launchFunction () {
      var allExist = elements.every(checkExist);
      if (allExist && onloadFn && !loaded && checkPath(page)) {
        loaded = true;
        onloadFn();
        if (stop && observer) { observer.disconnect(); }
      } else if ((!allExist && onunloadFn && loaded) || (allExist && onunloadFn && loaded && !checkPath(page))) {
        loaded = false;
        onunloadFn();
      }
    }  
    launchFunction();
    observer = new MutationObserver(launchFunction);
    observer.observe(document, { attributes: false, childList: true, characterData: false, subtree: true });
    if (stop && loaded) { observer.disconnect(); }
  }

  function checkPath (path) {
    if (typeof path === 'string') { return new RegExp("^" + path.split("*").join(".*") + "$").test(window.location.pathname); }
    else if (Array.isArray(path) && path.length > 0 && path.every(function (i) { return typeof i === "string" })) {
      return path.some(function (e) { return new RegExp("^" + e.split("*").join(".*") + "$").test(window.location.pathname); });
    } else { return true; }
  }

  /* --------------------------------------------------
  |                  getParameterFromPath
  |---------------------------------------------------
  |
  | Obtains a parameter from the URL Path
  | @position position of the parameter on the Path
  | @reverse set if is desired to reverse the Path order
  | @return parameter
  */
  function getParameterFromPath (position, reverse) {
    if ( position === void 0 ) position = 0;
    if ( reverse === void 0 ) reverse = true;

    var pathArray = window.location.pathname.split('/');
    if (reverse) { pathArray.reverse(); }
    if (pathArray.length > position) { return decodeURIComponent(pathArray[position]); }
  }

  /* --------------------------------------------------
  |                  commonAncestor
  |---------------------------------------------------
  |
  | Obtains the common ancestor of multiple elements
  | @elements array of CSS Selectors
  | @return common ancestor element
  */
  function commonAncestor (elements) {
    if (!Array.isArray(elements)) { return; }

    var nodes = [];
    elements.forEach(function (e) { nodes.push(elementParents(document.querySelector(e))); });

    for (var i in nodes[0]) {
      var equal = nodes.slice(1).every(function (node) {
        return nodes[0][i] === node[i];
      });
      if (!equal) { return nodes[0][i - 1]; }
    }
  }

  function elementParents (node) {
    var nodes = [];
    for (; node; node = node.parentNode) {
      nodes.unshift(node);
    }
    return nodes
  }

  var commonjsGlobal = typeof window !== 'undefined' ? window : typeof global !== 'undefined' ? global : typeof self !== 'undefined' ? self : {};

  function createCommonjsModule(fn, module) {
  	return module = { exports: {} }, fn(module, module.exports), module.exports;
  }

  var popper_min = createCommonjsModule(function (module, exports) {
  /*
   Copyright (C) Federico Zivolo 2019
   Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).
   */(function(e,t){module.exports=t();})(commonjsGlobal,function(){function e(e){return e&&'[object Function]'==={}.toString.call(e)}function t(e,t){if(1!==e.nodeType){ return[]; }var o=e.ownerDocument.defaultView,n=o.getComputedStyle(e,null);return t?n[t]:n}function o(e){return'HTML'===e.nodeName?e:e.parentNode||e.host}function n(e){if(!e){ return document.body; }switch(e.nodeName){case'HTML':case'BODY':return e.ownerDocument.body;case'#document':return e.body;}var i=t(e),r=i.overflow,p=i.overflowX,s=i.overflowY;return /(auto|scroll|overlay)/.test(r+s+p)?e:n(o(e))}function r(e){return 11===e?pe:10===e?se:pe||se}function p(e){if(!e){ return document.documentElement; }for(var o=r(10)?document.body:null,n=e.offsetParent||null;n===o&&e.nextElementSibling;){ n=(e=e.nextElementSibling).offsetParent; }var i=n&&n.nodeName;return i&&'BODY'!==i&&'HTML'!==i?-1!==['TH','TD','TABLE'].indexOf(n.nodeName)&&'static'===t(n,'position')?p(n):n:e?e.ownerDocument.documentElement:document.documentElement}function s(e){var t=e.nodeName;return'BODY'!==t&&('HTML'===t||p(e.firstElementChild)===e)}function d(e){return null===e.parentNode?e:d(e.parentNode)}function a(e,t){if(!e||!e.nodeType||!t||!t.nodeType){ return document.documentElement; }var o=e.compareDocumentPosition(t)&Node.DOCUMENT_POSITION_FOLLOWING,n=o?e:t,i=o?t:e,r=document.createRange();r.setStart(n,0), r.setEnd(i,0);var l=r.commonAncestorContainer;if(e!==l&&t!==l||n.contains(i)){ return s(l)?l:p(l); }var f=d(e);return f.host?a(f.host,t):a(e,d(t).host)}function l(e){var t=1<arguments.length&&void 0!==arguments[1]?arguments[1]:'top',o='top'===t?'scrollTop':'scrollLeft',n=e.nodeName;if('BODY'===n||'HTML'===n){var i=e.ownerDocument.documentElement,r=e.ownerDocument.scrollingElement||i;return r[o]}return e[o]}function f(e,t){var o=2<arguments.length&&void 0!==arguments[2]&&arguments[2],n=l(t,'top'),i=l(t,'left'),r=o?-1:1;return e.top+=n*r, e.bottom+=n*r, e.left+=i*r, e.right+=i*r, e}function m(e,t){var o='x'===t?'Left':'Top',n='Left'==o?'Right':'Bottom';return parseFloat(e['border'+o+'Width'],10)+parseFloat(e['border'+n+'Width'],10)}function h(e,t,o,n){return ee(t['offset'+e],t['scroll'+e],o['client'+e],o['offset'+e],o['scroll'+e],r(10)?parseInt(o['offset'+e])+parseInt(n['margin'+('Height'===e?'Top':'Left')])+parseInt(n['margin'+('Height'===e?'Bottom':'Right')]):0)}function c(e){var t=e.body,o=e.documentElement,n=r(10)&&getComputedStyle(o);return{height:h('Height',t,o,n),width:h('Width',t,o,n)}}function g(e){return fe({},e,{right:e.left+e.width,bottom:e.top+e.height})}function u(e){var o={};try{if(r(10)){o=e.getBoundingClientRect();var n=l(e,'top'),i=l(e,'left');o.top+=n, o.left+=i, o.bottom+=n, o.right+=i;}else { o=e.getBoundingClientRect(); }}catch(t){}var p={left:o.left,top:o.top,width:o.right-o.left,height:o.bottom-o.top},s='HTML'===e.nodeName?c(e.ownerDocument):{},d=s.width||e.clientWidth||p.right-p.left,a=s.height||e.clientHeight||p.bottom-p.top,f=e.offsetWidth-d,h=e.offsetHeight-a;if(f||h){var u=t(e);f-=m(u,'x'), h-=m(u,'y'), p.width-=f, p.height-=h;}return g(p)}function b(e,o){var i=2<arguments.length&&void 0!==arguments[2]&&arguments[2],p=r(10),s='HTML'===o.nodeName,d=u(e),a=u(o),l=n(e),m=t(o),h=parseFloat(m.borderTopWidth,10),c=parseFloat(m.borderLeftWidth,10);i&&s&&(a.top=ee(a.top,0), a.left=ee(a.left,0));var b=g({top:d.top-a.top-h,left:d.left-a.left-c,width:d.width,height:d.height});if(b.marginTop=0, b.marginLeft=0, !p&&s){var w=parseFloat(m.marginTop,10),y=parseFloat(m.marginLeft,10);b.top-=h-w, b.bottom-=h-w, b.left-=c-y, b.right-=c-y, b.marginTop=w, b.marginLeft=y;}return(p&&!i?o.contains(l):o===l&&'BODY'!==l.nodeName)&&(b=f(b,o)), b}function w(e){var t=1<arguments.length&&void 0!==arguments[1]&&arguments[1],o=e.ownerDocument.documentElement,n=b(e,o),i=ee(o.clientWidth,window.innerWidth||0),r=ee(o.clientHeight,window.innerHeight||0),p=t?0:l(o),s=t?0:l(o,'left'),d={top:p-n.top+n.marginTop,left:s-n.left+n.marginLeft,width:i,height:r};return g(d)}function y(e){var n=e.nodeName;if('BODY'===n||'HTML'===n){ return!1; }if('fixed'===t(e,'position')){ return!0; }var i=o(e);return!!i&&y(i)}function E(e){if(!e||!e.parentElement||r()){ return document.documentElement; }for(var o=e.parentElement;o&&'none'===t(o,'transform');){ o=o.parentElement; }return o||document.documentElement}function v(e,t,i,r){var p=4<arguments.length&&void 0!==arguments[4]&&arguments[4],s={top:0,left:0},d=p?E(e):a(e,t);if('viewport'===r){ s=w(d,p); }else{var l;'scrollParent'===r?(l=n(o(t)), 'BODY'===l.nodeName&&(l=e.ownerDocument.documentElement)):'window'===r?l=e.ownerDocument.documentElement:l=r;var f=b(l,d,p);if('HTML'===l.nodeName&&!y(d)){var m=c(e.ownerDocument),h=m.height,g=m.width;s.top+=f.top-f.marginTop, s.bottom=h+f.top, s.left+=f.left-f.marginLeft, s.right=g+f.left;}else { s=f; }}i=i||0;var u='number'==typeof i;return s.left+=u?i:i.left||0, s.top+=u?i:i.top||0, s.right-=u?i:i.right||0, s.bottom-=u?i:i.bottom||0, s}function x(e){var t=e.width,o=e.height;return t*o}function O(e,t,o,n,i){var r=5<arguments.length&&void 0!==arguments[5]?arguments[5]:0;if(-1===e.indexOf('auto')){ return e; }var p=v(o,n,r,i),s={top:{width:p.width,height:t.top-p.top},right:{width:p.right-t.right,height:p.height},bottom:{width:p.width,height:p.bottom-t.bottom},left:{width:t.left-p.left,height:p.height}},d=Object.keys(s).map(function(e){return fe({key:e},s[e],{area:x(s[e])})}).sort(function(e,t){return t.area-e.area}),a=d.filter(function(e){var t=e.width,n=e.height;return t>=o.clientWidth&&n>=o.clientHeight}),l=0<a.length?a[0].key:d[0].key,f=e.split('-')[1];return l+(f?'-'+f:'')}function L(e,t,o){var n=3<arguments.length&&void 0!==arguments[3]?arguments[3]:null,i=n?E(t):a(t,o);return b(o,i,n)}function S(e){var t=e.ownerDocument.defaultView,o=t.getComputedStyle(e),n=parseFloat(o.marginTop||0)+parseFloat(o.marginBottom||0),i=parseFloat(o.marginLeft||0)+parseFloat(o.marginRight||0),r={width:e.offsetWidth+i,height:e.offsetHeight+n};return r}function T(e){var t={left:'right',right:'left',bottom:'top',top:'bottom'};return e.replace(/left|right|bottom|top/g,function(e){return t[e]})}function D(e,t,o){o=o.split('-')[0];var n=S(e),i={width:n.width,height:n.height},r=-1!==['right','left'].indexOf(o),p=r?'top':'left',s=r?'left':'top',d=r?'height':'width',a=r?'width':'height';return i[p]=t[p]+t[d]/2-n[d]/2, i[s]=o===s?t[s]-n[a]:t[T(s)], i}function C(e,t){return Array.prototype.find?e.find(t):e.filter(t)[0]}function N(e,t,o){if(Array.prototype.findIndex){ return e.findIndex(function(e){return e[t]===o}); }var n=C(e,function(e){return e[t]===o});return e.indexOf(n)}function P(t,o,n){var i=void 0===n?t:t.slice(0,N(t,'name',n));return i.forEach(function(t){t['function']&&console.warn('`modifier.function` is deprecated, use `modifier.fn`!');var n=t['function']||t.fn;t.enabled&&e(n)&&(o.offsets.popper=g(o.offsets.popper), o.offsets.reference=g(o.offsets.reference), o=n(o,t));}), o}function k(){if(!this.state.isDestroyed){var e={instance:this,styles:{},arrowStyles:{},attributes:{},flipped:!1,offsets:{}};e.offsets.reference=L(this.state,this.popper,this.reference,this.options.positionFixed), e.placement=O(this.options.placement,e.offsets.reference,this.popper,this.reference,this.options.modifiers.flip.boundariesElement,this.options.modifiers.flip.padding), e.originalPlacement=e.placement, e.positionFixed=this.options.positionFixed, e.offsets.popper=D(this.popper,e.offsets.reference,e.placement), e.offsets.popper.position=this.options.positionFixed?'fixed':'absolute', e=P(this.modifiers,e), this.state.isCreated?this.options.onUpdate(e):(this.state.isCreated=!0, this.options.onCreate(e));}}function W(e,t){return e.some(function(e){var o=e.name,n=e.enabled;return n&&o===t})}function H(e){for(var t=[!1,'ms','Webkit','Moz','O'],o=e.charAt(0).toUpperCase()+e.slice(1),n=0;n<t.length;n++){var i=t[n],r=i?''+i+o:e;if('undefined'!=typeof document.body.style[r]){ return r }}return null}function B(){return this.state.isDestroyed=!0, W(this.modifiers,'applyStyle')&&(this.popper.removeAttribute('x-placement'), this.popper.style.position='', this.popper.style.top='', this.popper.style.left='', this.popper.style.right='', this.popper.style.bottom='', this.popper.style.willChange='', this.popper.style[H('transform')]=''), this.disableEventListeners(), this.options.removeOnDestroy&&this.popper.parentNode.removeChild(this.popper), this}function A(e){var t=e.ownerDocument;return t?t.defaultView:window}function M(e,t,o,i){var r='BODY'===e.nodeName,p=r?e.ownerDocument.defaultView:e;p.addEventListener(t,o,{passive:!0}), r||M(n(p.parentNode),t,o,i), i.push(p);}function F(e,t,o,i){o.updateBound=i, A(e).addEventListener('resize',o.updateBound,{passive:!0});var r=n(e);return M(r,'scroll',o.updateBound,o.scrollParents), o.scrollElement=r, o.eventsEnabled=!0, o}function I(){this.state.eventsEnabled||(this.state=F(this.reference,this.options,this.state,this.scheduleUpdate));}function R(e,t){return A(e).removeEventListener('resize',t.updateBound), t.scrollParents.forEach(function(e){e.removeEventListener('scroll',t.updateBound);}), t.updateBound=null, t.scrollParents=[], t.scrollElement=null, t.eventsEnabled=!1, t}function U(){this.state.eventsEnabled&&(cancelAnimationFrame(this.scheduleUpdate), this.state=R(this.reference,this.state));}function Y(e){return''!==e&&!isNaN(parseFloat(e))&&isFinite(e)}function j(e,t){Object.keys(t).forEach(function(o){var n='';-1!==['width','height','top','right','bottom','left'].indexOf(o)&&Y(t[o])&&(n='px'), e.style[o]=t[o]+n;});}function V(e,t){Object.keys(t).forEach(function(o){var n=t[o];!1===n?e.removeAttribute(o):e.setAttribute(o,t[o]);});}function q(e,t){var o=e.offsets,n=o.popper,i=o.reference,r=$,p=function(e){return e},s=r(i.width),d=r(n.width),a=-1!==['left','right'].indexOf(e.placement),l=-1!==e.placement.indexOf('-'),f=t?a||l||s%2==d%2?r:Z:p,m=t?r:p;return{left:f(1==s%2&&1==d%2&&!l&&t?n.left-1:n.left),top:m(n.top),bottom:m(n.bottom),right:f(n.right)}}function K(e,t,o){var n=C(e,function(e){var o=e.name;return o===t}),i=!!n&&e.some(function(e){return e.name===o&&e.enabled&&e.order<n.order});if(!i){var r='`'+t+'`';console.warn('`'+o+'`'+' modifier is required by '+r+' modifier in order to work, be sure to include it before '+r+'!');}return i}function z(e){return'end'===e?'start':'start'===e?'end':e}function G(e){var t=1<arguments.length&&void 0!==arguments[1]&&arguments[1],o=ce.indexOf(e),n=ce.slice(o+1).concat(ce.slice(0,o));return t?n.reverse():n}function _(e,t,o,n){var i=e.match(/((?:\-|\+)?\d*\.?\d*)(.*)/),r=+i[1],p=i[2];if(!r){ return e; }if(0===p.indexOf('%')){var s;switch(p){case'%p':s=o;break;case'%':case'%r':default:s=n;}var d=g(s);return d[t]/100*r}if('vh'===p||'vw'===p){var a;return a='vh'===p?ee(document.documentElement.clientHeight,window.innerHeight||0):ee(document.documentElement.clientWidth,window.innerWidth||0), a/100*r}return r}function X(e,t,o,n){var i=[0,0],r=-1!==['right','left'].indexOf(n),p=e.split(/(\+|\-)/).map(function(e){return e.trim()}),s=p.indexOf(C(p,function(e){return-1!==e.search(/,|\s/)}));p[s]&&-1===p[s].indexOf(',')&&console.warn('Offsets separated by white space(s) are deprecated, use a comma (,) instead.');var d=/\s*,\s*|\s+/,a=-1===s?[p]:[p.slice(0,s).concat([p[s].split(d)[0]]),[p[s].split(d)[1]].concat(p.slice(s+1))];return a=a.map(function(e,n){var i=(1===n?!r:r)?'height':'width',p=!1;return e.reduce(function(e,t){return''===e[e.length-1]&&-1!==['+','-'].indexOf(t)?(e[e.length-1]=t, p=!0, e):p?(e[e.length-1]+=t, p=!1, e):e.concat(t)},[]).map(function(e){return _(e,i,t,o)})}), a.forEach(function(e,t){e.forEach(function(o,n){Y(o)&&(i[t]+=o*('-'===e[n-1]?-1:1));});}), i}function J(e,t){var o,n=t.offset,i=e.placement,r=e.offsets,p=r.popper,s=r.reference,d=i.split('-')[0];return o=Y(+n)?[+n,0]:X(n,p,s,d), 'left'===d?(p.top+=o[0], p.left-=o[1]):'right'===d?(p.top+=o[0], p.left+=o[1]):'top'===d?(p.left+=o[0], p.top-=o[1]):'bottom'===d&&(p.left+=o[0], p.top+=o[1]), e.popper=p, e}for(var Q=Math.min,Z=Math.floor,$=Math.round,ee=Math.max,te='undefined'!=typeof window&&'undefined'!=typeof document,oe=['Edge','Trident','Firefox'],ne=0,ie=0;ie<oe.length;ie+=1){ if(te&&0<=navigator.userAgent.indexOf(oe[ie])){ne=1;break} }var i=te&&window.Promise,re=i?function(e){var t=!1;return function(){t||(t=!0, window.Promise.resolve().then(function(){t=!1, e();}));}}:function(e){var t=!1;return function(){t||(t=!0, setTimeout(function(){t=!1, e();},ne));}},pe=te&&!!(window.MSInputMethodContext&&document.documentMode),se=te&&/MSIE 10/.test(navigator.userAgent),de=function(e,t){if(!(e instanceof t)){ throw new TypeError('Cannot call a class as a function') }},ae=function(){function e(e,t){for(var o,n=0;n<t.length;n++){ o=t[n], o.enumerable=o.enumerable||!1, o.configurable=!0, 'value'in o&&(o.writable=!0), Object.defineProperty(e,o.key,o); }}return function(t,o,n){return o&&e(t.prototype,o), n&&e(t,n), t}}(),le=function(e,t,o){return t in e?Object.defineProperty(e,t,{value:o,enumerable:!0,configurable:!0,writable:!0}):e[t]=o, e},fe=Object.assign||function(e){for(var t,o=1;o<arguments.length;o++){ for(var n in t=arguments[o], t){ Object.prototype.hasOwnProperty.call(t,n)&&(e[n]=t[n]); } }return e},me=te&&/Firefox/i.test(navigator.userAgent),he=['auto-start','auto','auto-end','top-start','top','top-end','right-start','right','right-end','bottom-end','bottom','bottom-start','left-end','left','left-start'],ce=he.slice(3),ge={FLIP:'flip',CLOCKWISE:'clockwise',COUNTERCLOCKWISE:'counterclockwise'},ue=function(){function t(o,n){var i=this,r=2<arguments.length&&void 0!==arguments[2]?arguments[2]:{};de(this,t), this.scheduleUpdate=function(){return requestAnimationFrame(i.update)}, this.update=re(this.update.bind(this)), this.options=fe({},t.Defaults,r), this.state={isDestroyed:!1,isCreated:!1,scrollParents:[]}, this.reference=o&&o.jquery?o[0]:o, this.popper=n&&n.jquery?n[0]:n, this.options.modifiers={}, Object.keys(fe({},t.Defaults.modifiers,r.modifiers)).forEach(function(e){i.options.modifiers[e]=fe({},t.Defaults.modifiers[e]||{},r.modifiers?r.modifiers[e]:{});}), this.modifiers=Object.keys(this.options.modifiers).map(function(e){return fe({name:e},i.options.modifiers[e])}).sort(function(e,t){return e.order-t.order}), this.modifiers.forEach(function(t){t.enabled&&e(t.onLoad)&&t.onLoad(i.reference,i.popper,i.options,t,i.state);}), this.update();var p=this.options.eventsEnabled;p&&this.enableEventListeners(), this.state.eventsEnabled=p;}return ae(t,[{key:'update',value:function(){return k.call(this)}},{key:'destroy',value:function(){return B.call(this)}},{key:'enableEventListeners',value:function(){return I.call(this)}},{key:'disableEventListeners',value:function(){return U.call(this)}}]), t}();return ue.Utils=('undefined'==typeof window?commonjsGlobal:window).PopperUtils, ue.placements=he, ue.Defaults={placement:'bottom',positionFixed:!1,eventsEnabled:!0,removeOnDestroy:!1,onCreate:function(){},onUpdate:function(){},modifiers:{shift:{order:100,enabled:!0,fn:function(e){var t=e.placement,o=t.split('-')[0],n=t.split('-')[1];if(n){var i=e.offsets,r=i.reference,p=i.popper,s=-1!==['bottom','top'].indexOf(o),d=s?'left':'top',a=s?'width':'height',l={start:le({},d,r[d]),end:le({},d,r[d]+r[a]-p[a])};e.offsets.popper=fe({},p,l[n]);}return e}},offset:{order:200,enabled:!0,fn:J,offset:0},preventOverflow:{order:300,enabled:!0,fn:function(e,t){var o=t.boundariesElement||p(e.instance.popper);e.instance.reference===o&&(o=p(o));var n=H('transform'),i=e.instance.popper.style,r=i.top,s=i.left,d=i[n];i.top='', i.left='', i[n]='';var a=v(e.instance.popper,e.instance.reference,t.padding,o,e.positionFixed);i.top=r, i.left=s, i[n]=d, t.boundaries=a;var l=t.priority,f=e.offsets.popper,m={primary:function(e){var o=f[e];return f[e]<a[e]&&!t.escapeWithReference&&(o=ee(f[e],a[e])), le({},e,o)},secondary:function(e){var o='right'===e?'left':'top',n=f[o];return f[e]>a[e]&&!t.escapeWithReference&&(n=Q(f[o],a[e]-('right'===e?f.width:f.height))), le({},o,n)}};return l.forEach(function(e){var t=-1===['left','top'].indexOf(e)?'secondary':'primary';f=fe({},f,m[t](e));}), e.offsets.popper=f, e},priority:['left','right','top','bottom'],padding:5,boundariesElement:'scrollParent'},keepTogether:{order:400,enabled:!0,fn:function(e){var t=e.offsets,o=t.popper,n=t.reference,i=e.placement.split('-')[0],r=Z,p=-1!==['top','bottom'].indexOf(i),s=p?'right':'bottom',d=p?'left':'top',a=p?'width':'height';return o[s]<r(n[d])&&(e.offsets.popper[d]=r(n[d])-o[a]), o[d]>r(n[s])&&(e.offsets.popper[d]=r(n[s])), e}},arrow:{order:500,enabled:!0,fn:function(e,o){var n;if(!K(e.instance.modifiers,'arrow','keepTogether')){ return e; }var i=o.element;if('string'==typeof i){if(i=e.instance.popper.querySelector(i), !i){ return e; }}else if(!e.instance.popper.contains(i)){ return console.warn('WARNING: `arrow.element` must be child of its popper element!'), e; }var r=e.placement.split('-')[0],p=e.offsets,s=p.popper,d=p.reference,a=-1!==['left','right'].indexOf(r),l=a?'height':'width',f=a?'Top':'Left',m=f.toLowerCase(),h=a?'left':'top',c=a?'bottom':'right',u=S(i)[l];d[c]-u<s[m]&&(e.offsets.popper[m]-=s[m]-(d[c]-u)), d[m]+u>s[c]&&(e.offsets.popper[m]+=d[m]+u-s[c]), e.offsets.popper=g(e.offsets.popper);var b=d[m]+d[l]/2-u/2,w=t(e.instance.popper),y=parseFloat(w['margin'+f],10),E=parseFloat(w['border'+f+'Width'],10),v=b-e.offsets.popper[m]-y-E;return v=ee(Q(s[l]-u,v),0), e.arrowElement=i, e.offsets.arrow=(n={}, le(n,m,$(v)), le(n,h,''), n), e},element:'[x-arrow]'},flip:{order:600,enabled:!0,fn:function(e,t){if(W(e.instance.modifiers,'inner')){ return e; }if(e.flipped&&e.placement===e.originalPlacement){ return e; }var o=v(e.instance.popper,e.instance.reference,t.padding,t.boundariesElement,e.positionFixed),n=e.placement.split('-')[0],i=T(n),r=e.placement.split('-')[1]||'',p=[];switch(t.behavior){case ge.FLIP:p=[n,i];break;case ge.CLOCKWISE:p=G(n);break;case ge.COUNTERCLOCKWISE:p=G(n,!0);break;default:p=t.behavior;}return p.forEach(function(s,d){if(n!==s||p.length===d+1){ return e; }n=e.placement.split('-')[0], i=T(n);var a=e.offsets.popper,l=e.offsets.reference,f=Z,m='left'===n&&f(a.right)>f(l.left)||'right'===n&&f(a.left)<f(l.right)||'top'===n&&f(a.bottom)>f(l.top)||'bottom'===n&&f(a.top)<f(l.bottom),h=f(a.left)<f(o.left),c=f(a.right)>f(o.right),g=f(a.top)<f(o.top),u=f(a.bottom)>f(o.bottom),b='left'===n&&h||'right'===n&&c||'top'===n&&g||'bottom'===n&&u,w=-1!==['top','bottom'].indexOf(n),y=!!t.flipVariations&&(w&&'start'===r&&h||w&&'end'===r&&c||!w&&'start'===r&&g||!w&&'end'===r&&u);(m||b||y)&&(e.flipped=!0, (m||b)&&(n=p[d+1]), y&&(r=z(r)), e.placement=n+(r?'-'+r:''), e.offsets.popper=fe({},e.offsets.popper,D(e.instance.popper,e.offsets.reference,e.placement)), e=P(e.instance.modifiers,e,'flip'));}), e},behavior:'flip',padding:5,boundariesElement:'viewport'},inner:{order:700,enabled:!1,fn:function(e){var t=e.placement,o=t.split('-')[0],n=e.offsets,i=n.popper,r=n.reference,p=-1!==['left','right'].indexOf(o),s=-1===['top','left'].indexOf(o);return i[p?'left':'top']=r[o]-(s?i[p?'width':'height']:0), e.placement=T(t), e.offsets.popper=g(i), e}},hide:{order:800,enabled:!0,fn:function(e){if(!K(e.instance.modifiers,'hide','preventOverflow')){ return e; }var t=e.offsets.reference,o=C(e.instance.modifiers,function(e){return'preventOverflow'===e.name}).boundaries;if(t.bottom<o.top||t.left>o.right||t.top>o.bottom||t.right<o.left){if(!0===e.hide){ return e; }e.hide=!0, e.attributes['x-out-of-boundaries']='';}else{if(!1===e.hide){ return e; }e.hide=!1, e.attributes['x-out-of-boundaries']=!1;}return e}},computeStyle:{order:850,enabled:!0,fn:function(e,t){var o=t.x,n=t.y,i=e.offsets.popper,r=C(e.instance.modifiers,function(e){return'applyStyle'===e.name}).gpuAcceleration;void 0!==r&&console.warn('WARNING: `gpuAcceleration` option moved to `computeStyle` modifier and will not be supported in future versions of Popper.js!');var s,d,a=void 0===r?t.gpuAcceleration:r,l=p(e.instance.popper),f=u(l),m={position:i.position},h=q(e,2>window.devicePixelRatio||!me),c='bottom'===o?'top':'bottom',g='right'===n?'left':'right',b=H('transform');if(d='bottom'==c?'HTML'===l.nodeName?-l.clientHeight+h.bottom:-f.height+h.bottom:h.top, s='right'==g?'HTML'===l.nodeName?-l.clientWidth+h.right:-f.width+h.right:h.left, a&&b){ m[b]='translate3d('+s+'px, '+d+'px, 0)', m[c]=0, m[g]=0, m.willChange='transform'; }else{var w='bottom'==c?-1:1,y='right'==g?-1:1;m[c]=d*w, m[g]=s*y, m.willChange=c+', '+g;}var E={"x-placement":e.placement};return e.attributes=fe({},E,e.attributes), e.styles=fe({},m,e.styles), e.arrowStyles=fe({},e.offsets.arrow,e.arrowStyles), e},gpuAcceleration:!0,x:'bottom',y:'right'},applyStyle:{order:900,enabled:!0,fn:function(e){return j(e.instance.popper,e.styles), V(e.instance.popper,e.attributes), e.arrowElement&&Object.keys(e.arrowStyles).length&&j(e.arrowElement,e.arrowStyles), e},onLoad:function(e,t,o,n,i){var r=L(i,t,e,o.positionFixed),p=O(o.placement,r,t,e,o.modifiers.flip.boundariesElement,o.modifiers.flip.padding);return t.setAttribute('x-placement',p), j(t,{position:o.positionFixed?'fixed':'absolute'}), o},gpuAcceleration:void 0}}}, ue});

  });

  /* --------------------------------------------------
  |                     initPopup
  |----------------------------------------------------
  |
  | Tranform an element into a Popup attached below a reference element
  | @reference CSS selector that references the element below which the Popup will be positioned
  | @element HTML element that will be transformed to a Popup
  | @return Popper Object
  |
  */

  function initPopup (reference, element) {
    if (!popper_min) { return; }

    var popupRef = document.querySelector(reference);
    var popupEl = element;
    var popupConf = {
      placement: 'bottom-start',
      modifiers: {
        preventOverflow: {
          padding: 0
        }
      },
      onCreate: function () {
        popupEl.style.width = popupRef.offsetWidth + 'px';
      },
      onUpdate: function (data) {
        if (!data.hide) {
          if (popupRef.offsetWidth < 40) { popupEl.style.display = 'none'; }
          else { popupEl.style.display = 'block'; }
          popupEl.style.width = popupRef.offsetWidth + 'px';
          if (popupEl.offsetWidth !== popupRef.offsetWidth) { popupEl.style.width = popupRef.offsetWidth + 'px'; }
        } else {
          popupEl.style.display = 'none';
        }
      },
      removeOnDestroy: false
    };
    var popup = new popper_min(popupRef, popupEl, popupConf);
    return popup;
  }

  /* --------------------------------------------------
  |                     POLYFILLS
  |----------------------------------------------------
  */

  // Create Element.remove() function if not exist
  if (!('remove' in Element.prototype)) {
    Element.prototype.remove = function () {
      if (this.parentNode) {
        this.parentNode.removeChild(this);
      }
    };
  }

  /* --------------------------------------------------
  |                  Core Configuration
  |----------------------------------------------------
  |
  | Custom application development, Please, be carefull
  | if you want to modify this section.
  |
  */

  // Check if conf file exists
  if (typeof window.inbAppSdk === 'undefined') {
    throw new ReferenceError("Inbenta SDK couldn't be started, please contact with support for more information.");
  }

  // Retrieve configuration data
  var app = window.inbAppSdk;

  // Declare global variables
  var inbentaElements, inbentaFunctionalities;

  // Set SDK's Script attributes
  var product = 'search';
  var sdkScript = getSDKScript(app.sdkIntegration, product);

  // Import SDK
  importScript(sdkScript, function () {
    try {
      if (app.dynamicUserType) {
        setUserTypeDynamically();
      } else {
        start();
      }
    } catch (err) {
      throw err
    }
  });

  /* --------------------------------------------------
  |                setUserTypeDynamically
  |----------------------------------------------------
  |
  |        Retrieve the User Type from a function
  |        The function will be executed every 100ms
  |        for 30 seconds or until it have a response.
  |
  */
  function setUserTypeDynamically () {
    var counter = 0;
    var waitUserTypeValue = setInterval(function () {
      var dynamicUserType = app.dynamicUserType();
      if (counter === 300 || (typeof dynamicUserType !== 'undefined' && Number.isInteger(dynamicUserType))) {
        clearInterval(waitUserTypeValue);
        if (Number.isInteger(dynamicUserType)) { app.sdkConfig.userType = dynamicUserType; }
        if (typeof app.sdkConfig.userType === 'undefined' || !Number.isInteger(app.sdkConfig.userType)) { app.sdkConfig.userType = 10000; }
        start();
      }
      counter++;
    }, 100);
  }

  /* --------------------------------------------------
  |                      start
  |----------------------------------------------------
  |
  |                  Start the SDK
  |
  */
  function start () {
    var sdk = window.InbentaSearchSDK.createFromDomainKey(app.sdkAuth.domainKey, app.sdkAuth.publicKey, app.sdkConfig);
    initSDK(sdk, app.appConfig);
  }

  /* --------------------------------------------------
  |                     initSDK
  |----------------------------------------------------
  |
  | Function to initialize the SDK Components & Events
  | @sdk object with the sdk initialized
  | @appConfig object with the sdk components configuration
  |
  */
  function initSDK (sdk, appConfig) {
    inbentaElements = buildHTML(app.appConfig);
    inbentaFunctionalities = { autocompleter: [], search: [], deflection: [] };

    // Init Autocompleter Functionalities
    if (appConfig.autocompleter) {
      appConfig.autocompleter.forEach(function (autocompleterConstructor, index) {
        if (autocompleterConstructor.active === true || typeof autocompleterConstructor.active === 'undefined') {
          inbentaFunctionalities.autocompleter[index] = [];
          initAutocompleterComponents(sdk, autocompleterConstructor, inbentaElements.autocompleter[index], inbentaFunctionalities.autocompleter[index], index);
          initAutocompleterEvents(sdk, autocompleterConstructor, inbentaElements.autocompleter[index], inbentaFunctionalities.autocompleter[index], index);
        }
      });
    }

    // Init Search Functionalities
    if (appConfig.search) {
      appConfig.search.forEach(function (searchConstructor, index) {
        if (searchConstructor.active === true || typeof searchConstructor.active === 'undefined') {
          inbentaFunctionalities.search[index] = [];
          initSearchComponents(sdk, searchConstructor, inbentaElements.search[index], inbentaFunctionalities.search[index], index);
          initSearchEvents(sdk, searchConstructor, inbentaElements.search[index], inbentaFunctionalities.search[index], index);
        }    });
    }

    // Init Deflection Functionalities
    if (appConfig.deflection) {
      appConfig.deflection.forEach(function (deflectionConstructor, index) {
        if (deflectionConstructor.active === true || typeof deflectionConstructor.active === 'undefined') {
          inbentaFunctionalities.deflection[index] = [];
          initDeflectionComponents(sdk, deflectionConstructor, inbentaElements.deflection[index], inbentaFunctionalities.deflection[index], index);
          initDeflectionEvents(sdk, deflectionConstructor, inbentaElements.deflection[index], inbentaFunctionalities.deflection[index], index);
        }
      });
    }
  }

  /* -------------------------------------------------
  |             initAutocompleterComponents
  |---------------------------------------------------
  |
  | Function to initialize the Autocompleter components
  | @sdk object with the sdk initialized
  | @autocompleterConstructor JSON with the Autocompleter configuration
  | @autocompleterElements HTML elements required by the Autocompleter components
  | @autocompleterComponents Array of Autocompleter components
  | @index Index of the current Autocompleter Functionality
  |
  */
  function initAutocompleterComponents (sdk, autocompleterConstructor, autocompleterElements, autocompleterComponents, index) {
    // Init results component, this component is required for the autocompleter to work
    if (typeof autocompleterConstructor.components.results === 'undefined') { autocompleterConstructor.components['results'] = {}; }
    var results = sdk.component('results', document.createElement('div'), autocompleterConstructor.components.results.conf);
    autocompleterComponents.results = results;

    // Init autocompleter component, this component is required for the autocompleter to work
    if (typeof autocompleterConstructor.components.autocompleter === 'undefined') { autocompleterConstructor.components['autocompleter'] = {}; }
    var autocompleter = sdk.component('autocompleter', autocompleterElements.querySelector('#inbenta-autocompleter'), autocompleterConstructor.components.autocompleter.conf);
    results.linkTo(autocompleter);
    autocompleterComponents.autocompleter = autocompleter;
  }

  /* -------------------------------------------------
  |                initSearchComponents
  |---------------------------------------------------
  |
  | Function to initialize the Search components
  | @sdk object with the sdk initialized
  | @searchConstructor JSON with the Search configuration
  | @searchElements HTML elements required by the Search components
  | @searchComponents Array of Search components
  | @index Index of the current Autocompleter Functionality
  |
  */
  function initSearchComponents (sdk, searchConstructor, searchElements, searchComponents, index) {
    // Init results component, this component is required for the search to work
    if (typeof searchConstructor.components.results === 'undefined') { searchConstructor.components['results'] = {}; }
    var results = sdk.component('results', searchElements.querySelector('#inbenta-results'), searchConstructor.components.results.conf);
    searchComponents.results = results;

    // Init searchBox component
    if (searchConstructor.components.searchBox && (searchConstructor.components.searchBox.active === true || typeof searchConstructor.components.searchBox.active === 'undefined')) {
      var searchBox = sdk.component('search-box', searchElements.querySelector('#inbenta-searchBox'), searchConstructor.components.searchBox.conf);
      results.linkTo(searchBox);
      searchComponents.searchBox = searchBox;
    }

    // Init stats component
    if (searchConstructor.components.stats && (searchConstructor.components.stats.active === true || typeof searchConstructor.components.stats.active === 'undefined')) {
      var stats = sdk.component('stats', searchElements.querySelector('#inbenta-stats'), searchConstructor.components.stats.conf);
      results.linkTo(stats);
      searchComponents.stats = stats;
    }

    // Init sortBy component
    if (searchConstructor.components.sortBy && (searchConstructor.components.sortBy.active === true || typeof searchConstructor.components.sortBy.active === 'undefined')) {
      var sortBy = sdk.component('sort-by-selector', searchElements.querySelector('#inbenta-sort-by'), searchConstructor.components.sortBy.conf);
      results.linkTo(sortBy);
      searchComponents.sortBy = sortBy;
    }

    // Init results per page component
    if (searchConstructor.components.resultsPerPageSelector && (searchConstructor.components.resultsPerPageSelector.active === true || typeof searchConstructor.components.resultsPerPageSelector.active === 'undefined')) {
      var resultsPerPageSelector = sdk.component('results-per-page-selector', searchElements.querySelector('#inbenta-results-per-page'), searchConstructor.components.resultsPerPageSelector.conf);
      results.linkTo(resultsPerPageSelector);
      searchComponents.resultsPerPageSelector = resultsPerPageSelector;
    }

    // Init filters component
    if (searchConstructor.components.filters && (searchConstructor.components.filters.active === true || typeof searchConstructor.components.filters.active === 'undefined')) {
      var filters = sdk.component('refinement-lists', searchElements.querySelector('#inbenta-filters'), searchConstructor.components.filters.conf);
      results.linkTo(filters);
      searchComponents.filters = filters;
    }

    // Init tabs component
    if (searchConstructor.components.tabs && (searchConstructor.components.tabs.active === true || typeof searchConstructor.components.tabs.active === 'undefined')) {
      var tabs = sdk.component('refinement-tabs', searchElements.querySelector('#inbenta-tabs'), searchConstructor.components.tabs.conf);
      results.linkTo(tabs);
      searchComponents.tabs = tabs;
    }

    // Init no results component
    if (searchConstructor.components.noResults && (searchConstructor.components.noResults.active === true || typeof searchConstructor.components.noResults.active === 'undefined')) {
      var noResults = sdk.component('no-results', searchElements.querySelector('#inbenta-no-results'), searchConstructor.components.noResults.conf);
      results.linkTo(noResults);
      searchComponents.results = results;
    }

    // Init pagination component
    if (searchConstructor.components.paginationTop && (searchConstructor.components.paginationTop.active === true || typeof searchConstructor.components.paginationTop.active === 'undefined')) {
      var paginationTop = sdk.component('pagination', searchElements.querySelector('#inbenta-pagination-top'), searchConstructor.components.paginationTop.conf);
      results.linkTo(paginationTop);
      searchComponents.paginationTop = paginationTop;
    }

    // Init pagination component
    if (searchConstructor.components.paginationBottom && (searchConstructor.components.paginationBottom.active === true || typeof searchConstructor.components.paginationBottom.active === 'undefined')) {
      var paginationBottom = sdk.component('pagination', searchElements.querySelector('#inbenta-pagination-bottom'), searchConstructor.components.paginationBottom.conf);
      results.linkTo(paginationBottom);
      searchComponents.paginationBottom = paginationBottom;
    }

    // Init loader component
    if (searchConstructor.components.loader && (searchConstructor.components.loader.active === true || typeof searchConstructor.components.loader.active === 'undefined')) {
      var loader = sdk.component('loader', searchElements.querySelector('#inbenta-loader'), searchConstructor.components.loader.conf);
      results.linkTo(loader);
      searchComponents.loader = loader;
    }
  }

  /* -------------------------------------------------
  |             initDeflectionComponents
  |---------------------------------------------------
  |
  | Function to initialize the Deflection Tools components
  | @sdk object with the sdk initialized
  | @deflectionConstructor JSON with the Deflection configuration
  | @deflectionElements HTML elements required by the Deflection components
  | @deflectionComponents Array of Deflection components
  | @index Index of the current Deflection Functionality
  |
  */
  function initDeflectionComponents (sdk, deflectionConstructor, deflectionElements, deflectionComponents, index) {
    // Init instants component
    if (deflectionConstructor.components.instants && (deflectionConstructor.components.instants.active === true || typeof deflectionConstructor.components.instants.active === 'undefined')) {
      var instants = sdk.component('instants', deflectionElements.querySelector('#inbenta-instants'), deflectionConstructor.components.instants.conf);
      deflectionComponents.instants = instants;
    }

    // Init lastChance component
    if (deflectionConstructor.components.lastChance && (deflectionConstructor.components.lastChance.active === true || typeof deflectionConstructor.components.lastChance.active === 'undefined')) {
      var lastChance = sdk.component('last-chance', deflectionElements.querySelector('#inbenta-last-chance'), deflectionConstructor.components.lastChance.conf);
      deflectionComponents.lastChance = lastChance;
    }
  }

  /* --------------------------------------------------
  |                  initAutocompleterEvents
  |---------------------------------------------------
  |
  | Function to initialize the Autocompleter custom events
  | @sdk object with the sdk initialized
  | @autocompleterConstructor JSON with the Autocompleter configuration
  | @autocompleterElements HTML elements required by the Autocompleter components
  | @autocompleterComponents Array of Autocompleter components
  | @index Index of the current Autocompleter Functionality
  |
  */
  function initAutocompleterEvents (sdk, autocompleterConstructor, autocompleterElements, autocompleterComponents, index) {
    var popup;
    var autocompleterComponent = autocompleterComponents.autocompleter;

    // If autocompleter reference element isn't defined, set textField as a reference element.
    if (typeof autocompleterConstructor.elements.reference !== 'string') { autocompleterConstructor.elements.reference = autocompleterConstructor.elements.textField; }
    
    // Function launched when all the Autocompleter required elements are on the DOM
    function autocompleterLoadFn () {
      var textFieldElement = document.querySelector(autocompleterConstructor.elements.textField);
      autocompleterComponent.setInputElement(textFieldElement);

      textFieldElement.autocomplete = 'off';
      // Popper
      if (popup) { popup.destroy(); }
      popup = initPopup(autocompleterConstructor.elements.reference, autocompleterElements);

      if (textFieldElement === document.activeElement) {
        autocompleterComponent.setQuery(textFieldElement.value);
      } else {
        autocompleterComponent.blur();
        autocompleterComponent.setQuery(textFieldElement.value);
        textFieldElement.addEventListener('focus', function () {
          autocompleterComponent.setQuery(textFieldElement.value);
        }, { once: true });
      }
      
      textFieldElement.addEventListener('focus', function () {
        popup.update();
      });
      textFieldElement.addEventListener('blur', function () {
        popup.update();
      });
    }

    // Function launched when any of the the Autocompleter required elements disapears from the DOM
    function autocompleterUnloadFn () {
      popup.destroy();
    }

    // Observe Elements
    elementsObserver([autocompleterConstructor.elements.textField, autocompleterConstructor.elements.reference], autocompleterLoadFn, autocompleterUnloadFn, autocompleterConstructor.page);
  }
  /* --------------------------------------------------
  |                  initSearchEvents
  |---------------------------------------------------
  |
  | Function to initialize the Search custom events
  | @sdk object with the sdk initialized
  | @searchConstructor JSON with the Search configuration
  | @searchElements HTML elements required by the Search components
  | @searchComponents Array of Search components
  | @index Index of the current Autocompleter Functionality
  |
  */
  function initSearchEvents (sdk, searchConstructor, searchElements, searchComponents, index) {
    var resultsComponent = searchComponents.results;

    // Scroll to Search top
    function scrollIntoResults () {
      if (window.scrollY > searchElements.offsetTop) {
        searchElements.scrollIntoView(true, { behavior: 'smooth' });
      }
    }

    // Set query done with SearchBox component on the URL path. Replicate default Salesforce behavior.
    function setQueryOnPath () {
      if (searchComponents.searchBox) {
        var pathQuery = getParameterFromPath(0);
        if (pathQuery !== resultsComponent.searchStore.query) {
          var newPath = window.location.pathname.split('/').slice(0, -1).join('/') + '/' + encodeURIComponent(resultsComponent.searchStore.query) + window.location.search + window.location.hash;
          window.history.pushState(null, '', newPath);
        }
      }
    }

    // Selects query from last component of URL path
    function setQueryFromPath () {
      var pathQuery = getParameterFromPath(0);
      resultsComponent.setQuery(pathQuery);
      
      if (inbentaFunctionalities.autocompleter) {
        inbentaFunctionalities.autocompleter.forEach(function (autocompleterComponents) {
          var autocompleterTarget = autocompleterComponents.autocompleter.input;
          if (autocompleterTarget) {
            autocompleterTarget.value = resultsComponent.searchStore.query;
          }
        });
      }
    }

    // Style fixes
    function fixStyles () {
      // Show sortBy and Results per page selector
      if (resultsComponent.searchStore.hasResults) {
        if (searchElements.querySelector('.inbenta-search-sortby__icon')) { searchElements.querySelector('.inbenta-search-sortby__icon').style.display = 'block'; }
      } else {
        if (searchElements.querySelector('.inbenta-search-sortby__icon')) { searchElements.querySelector('.inbenta-search-sortby__icon').style.display = 'none'; }
      }
    }

    // Hide all Autocompleters when new search done
    function hideAutocompleters () {
      if (searchComponents.searchBox) {
        if (searchComponents.searchBox.$refs.autocompleter) { searchComponents.searchBox.$refs.autocompleter.blur(); }
      }
      
      if (inbentaFunctionalities.autocompleter) {
        inbentaFunctionalities.autocompleter.forEach(function (autocompleterComponents) {
          var autocompleterTarget = autocompleterComponents.autocompleter.input;
          if (autocompleterTarget && searchConstructor.queryFromPath) {
            autocompleterTarget.value = resultsComponent.searchStore.query;
            // Hide autocompleter when a search is done
            autocompleterComponents.autocompleter.blur();
          }
        });
      }
    }

    // Function launched when all Search's required elements are on the DOM
    function searchLoadFn () {
      fixStyles();
      if (searchElements.querySelector('.inbenta-search-box')) { searchElements.querySelector('.inbenta-search-box').style.display = ''; }
      if (searchConstructor.queryFromPath) {
        setQueryFromPath();
      }

      var containerElement = document.querySelector(searchConstructor.elements.container);
      containerElement.innerHTML = '';
      containerElement.appendChild(searchElements);
    }

    // Function launched when any of Search's required elements disapears from the DOM
    function searchUnloadFn () {
      resultsComponent.searchStore.reset();

      // Delete query from searchboxes
      if (inbentaFunctionalities.autocompleter) {
        inbentaFunctionalities.autocompleter.forEach(function (autocompleterComponents) {
          var autocompleterTarget = autocompleterComponents.autocompleter.input;
          if (autocompleterTarget && searchConstructor.queryFromPath) {
            autocompleterTarget.value = '';
          }
        });
      }
    }

    // Execute when Results component shown results
    resultsComponent.searchStore.on('result', function () {
      hideAutocompleters();
      fixStyles();
      scrollIntoResults();
      
      if (searchComponents.searchBox) {
        // Set the query on the SearchBox's component input element value
        searchComponents.searchBox.$el.querySelector('.inbenta-search-input').value = resultsComponent.searchStore.query;
        // If Search Functionality selects the query from the URL path, when the query is done on Searchbox component set it on the URL path
        if (searchConstructor.queryFromPath) { setQueryOnPath(); }
      }
    });

    if (searchConstructor.queryFromPath && searchConstructor.page) {
      if (typeof searchConstructor.page === 'string' && searchConstructor.page.substr(-1) !== '*') { searchConstructor.page += '*'; }
      else if (Array.isArray(searchConstructor.page) && searchConstructor.page.length > 0 && searchConstructor.page.every(function (i) { return typeof i === "string" })) {
        for (var e in searchConstructor.page) {
          if (searchConstructor.page[e].substr(-1) !== '*') { searchConstructor.page[e] = searchConstructor.page[e] + '*'; }
        }    }
    }

    // Observe Element
    elementsObserver(searchConstructor.elements.container, searchLoadFn, searchUnloadFn, searchConstructor.page);
  }
  /* --------------------------------------------------
  |                  initDeflectionEvents
  |---------------------------------------------------
  |
  | Function to initialize the Deflection Tools custom events
  | @sdk object with the sdk initialized
  | @deflectionConstructor JSON with the Deflection configuration
  | @deflectionElements HTML elements required by the Deflection components
  | @deflectionComponents Array of Deflection components
  | @index Index of the current Deflection Functionality
  |
  */
  function initDeflectionEvents (sdk, deflectionConstructor, deflectionElements, deflectionComponents, index) {
    // Return if there isn't initialized any Deflection component
    if (!deflectionComponents.instants && !deflectionComponents.lastChance) { return; }

    // Declare empty variables
    var hasSubmit, lastChanceShowTimeOut, contactSubmitTimeOut, contactTicketTimeOut;

    // Set each Deflection components on a variable
    var instantsComponent = deflectionComponents.instants;
    var lastChanceComponent = deflectionComponents.lastChance;

    // Set Instants Element on a variable
    var instantsElement = deflectionElements.querySelector('.inbenta-search-instants');
   
    // Set Array of Selector of all Deflection's required elements, except the instantsFixedToElement element
    var deflectionRequiredElements = [];
    deflectionRequiredElements = deflectionConstructor.elements.textFields.concat(deflectionConstructor.elements.button + ':not(.inbenta-search-element)');

    // Submit the Form forcing a click on original submit button
    function formSubmit () {
      hasSubmit = true;
      // if (instantsComponent) instantsComponent.shouldShow = false;
      document.querySelector(deflectionConstructor.elements.button + '.inbenta-search-element').style.display = 'none';
      document.querySelector(deflectionConstructor.elements.button + ':not(.inbenta-search-element)').style.display = '';
      document.querySelector(deflectionConstructor.elements.button + ':not(.inbenta-search-element)').click();
    }
    // Log Contact_Ticket data key on Inbenta's Backstage, then submit original form
    function logContactTicket (finalQuery) {
      if (!finalQuery) { finalQuery = getFinalQuery(); }
      // If Contact_Ticket response delays more than 5 seconds, force the form submit
      contactTicketTimeOut = setTimeout(function () {
        formSubmit();
      }, 5000);
      sdk.client.trackEvent('contact_ticket', { query: finalQuery }).then(function () {
        clearTimeout(contactTicketTimeOut);
        formSubmit();
      });
    }
    // Log Contact_Submit data key on Inbenta's Backstage, then log Contact_Ticket data key
    function logContactSubmit () {
      var finalQuery = getFinalQuery();
      contactSubmitTimeOut = setTimeout(function () {
        logContactTicket(finalQuery);
      }, 5000);
      sdk.client.trackEvent('contact_submit', { query: finalQuery }).then(function () {
        clearTimeout(contactSubmitTimeOut);
        logContactTicket(finalQuery);
      });
    }
    // Merge the values of all the Deflection's required form Inputs and Textfields to obtain the complete query done by the user.
    function getFinalQuery () {
      var finalQuery;
      if (lastChanceComponent) {
        // If LastChance component active, get last query
        finalQuery = lastChanceComponent.query;
      } else if (instantsComponent) {
        // If LastChance component isn't active, get values from Instants component linked Inputs or Textfields and join them
        var linksValues = [];
        for (var e in instantsComponent.links) {
          if (instantsComponent.links[e].element.value) { linksValues.push(instantsComponent.links[e].element.value); }
        }
        finalQuery = linksValues.join(" . ");
      }
      return finalQuery;
    }

    // Show LastChance component results
    function lastChanceShow () {
      // If there are Last Chances, show them
      lastChanceComponent.show();

      // LastChance "on result" event don't be triggered if the query the same as the last one. If it isn't, set lastChanceShowTimeOut.
      if (lastChanceComponent.query !== lastChanceComponent.searchStore.lastQuery) {
        // If LastChance results delays more than 5 seconds to show, log Contact_Ticket data key on the Inbenta's Backstage
        lastChanceShowTimeOut = setTimeout(function (e) {
          logContactTicket();
          lastChanceComponent.shouldShow = false;
        }, 5000);
      }
    }
    // Clone the form original submit button and hide it.
    function cloneFormButton () {
      var originalFormButton, inbentaFormButton;

      // Search for other Inbenta's Deflection button and delete it
      if (document.querySelector(deflectionConstructor.elements.button + '.inbenta-search-element')) {
        document.querySelector(deflectionConstructor.elements.button + '.inbenta-search-element').remove();
      }

      // Select original form submit button
      originalFormButton = document.querySelector(deflectionConstructor.elements.button + ':not(.inbenta-search-element)');

      // Clone original form submit button
      inbentaFormButton = originalFormButton.cloneNode(true);
      inbentaFormButton.style.display = '';
      inbentaFormButton.classList.add('inbenta-search-element');

      // Clean clone from undesired attributes
      for (var i = inbentaFormButton.attributes.length - 1; i >= 0; i--) {
        if (inbentaFormButton.attributes[i].name.startsWith('data-aura-')) { inbentaFormButton.removeAttribute(inbentaFormButton.attributes[i].name); }
      }

      // Insert clone before original button and hide the original
      originalFormButton.parentNode.insertBefore(inbentaFormButton, originalFormButton);
      originalFormButton.style.display = 'none';

      // Add click listener to the clone
      inbentaFormButton.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();

        // Check that Inbenta's button isn't clicked before to prevent repeated data keys on Inbenta's Backstage
        if (hasSubmit === false) {
          // Hide Instants if aren't fixed to element
          if (instantsComponent && !deflectionConstructor.elements.instantsFixedToElement) { instantsComponent.shouldShow = false; }

          if (lastChanceComponent) {
            // If LastChance active, show it
            lastChanceShow();
          } else if (instantsComponent) {
            // If LastChance isn't active, log Contact_Submit and Contact_Ticket data keys on Inbenta's Backstage
            logContactSubmit();
          }
        }
      });
    }

    // Reset the Deflection Components
    function resetComponents () {
      if (instantsComponent) { instantsComponent.searchStore.reset(); }
      if (lastChanceComponent) { lastChanceComponent.searchStore.reset(); }
    }

    // Unset all the form Inputs or Textfields from the Deflection Components
    function cleanComponentsReferences () {
      if (instantsComponent) { instantsComponent.unlinkAll(); }
      if (lastChanceComponent) { lastChanceComponent.unlinkAll(); }
    }

    // Link the form Inputs or Textfields to the Deflection Components
    function linkInputs () {
      deflectionConstructor.elements.textFields.forEach(function (textField) {
        var textFieldElement = document.querySelector(textField);
        if (instantsComponent) { instantsComponent.linkToInput(textFieldElement); }
        if (lastChanceComponent) { lastChanceComponent.linkToInput(textFieldElement); }
      });
    }

    function moveToCommonAncestor () {
      commonAncestor(deflectionRequiredElements).appendChild(deflectionElements);
    }

    function moveToInbentaWrapper () {
      // setTimeout due to aesthetic reasons
      setTimeout(function () {
        document.querySelector('.inbenta-search-elements-wrapper>.inbenta-search-deflections-wrapper').appendChild(deflectionElements);
      }, 1);
    }
    
    // Function launched when all the Deflection's required elements, except the instantsFixedToElement element, are on the DOM
    function deflectionLoadFn () {
      hasSubmit = false;

      cleanComponentsReferences();
      linkInputs();
      cloneFormButton();
      moveToCommonAncestor();
    }
    // Function launched when any of the Deflection's required elements, except the instantsFixedToElement element, disapears from the DOM
    function deflectionUnloadFn () {
      clearTimeout(lastChanceShowTimeOut);
      clearTimeout(contactSubmitTimeOut);
      clearTimeout(contactTicketTimeOut);

      resetComponents();
      cleanComponentsReferences();
      moveToInbentaWrapper();
    }
    // Fix Instants component to instantsFixedToElement element. Launched when all the Deflection's required elements, including the instantsFixedToElement element, are on the DOM.
    function fixedInstantsLoadFn () {
      deflectionComponents.instants.$el.classList.add('inbenta-search-instants--static');
      deflectionComponents.instants.$el.querySelector('.inbenta-search-instants__header .header__icon').style.display = 'none';

      var instantsContainer = document.querySelector(deflectionConstructor.elements.instantsFixedToElement);

      instantsContainer.innerHTML = '';
      instantsContainer.appendChild(deflectionElements);

      // Check if the reference element of the Instants have a max height and, if it has it, set it to results div
      var instantsContainerMaxHeight = window.getComputedStyle(instantsContainer, null).getPropertyValue("max-height");
      if (instantsContainerMaxHeight !== 'none') {
        instantsElement.style.display = '';
        instantsContainer.style.overflow = 'hidden';

        // IE 11 doesn't return the header height using the getPropertyValue
        if (window.getComputedStyle(instantsElement.querySelector('.inbenta-search-instants__header'), null).getPropertyValue("height") !== 'auto') {
          instantsElement.querySelector('.inbenta-search-results').style.maxHeight = 'calc(' + instantsContainerMaxHeight + ' - ' + window.getComputedStyle(instantsElement.querySelector('.inbenta-search-instants__header'), null).getPropertyValue("height") + ')';
        } else {
          instantsElement.querySelector('.inbenta-search-results').style.maxHeight = 'calc(' + instantsContainerMaxHeight + ' - 50px)';
        }

        if (!instantsComponent.searchStore.hasResults) { instantsElement.style.display = 'none'; }
        else { instantsElement.style.display = ''; }
      }
    }

    // Unfix Instants component from instantsFixedToElement element. Launched when any of the Deflection's required elements, including the instantsFixedToElement element, disapears from the DOM
    function fixedInstantsUnloadFn () {
      deflectionComponents.instants.$el.classList.remove('inbenta-search-instants--static');
      deflectionComponents.instants.$el.querySelector('.inbenta-search-instants__header .header__icon').style.display = '';
      if (!instantsComponent.searchStore.hasResults) { deflectionComponents.instants.$el.querySelector('.inbenta-search-instants__header .header__icon').click(); }
      // // setTimeout due to aesthetic reasons
      setTimeout(function () {
        if (!document.querySelector('.inbenta-search-deflections-wrapper').contains(deflectionElements)) {
          instantsComponent.shouldShow = false;
          moveToCommonAncestor();
          instantsComponent.shouldShow = true;
        }
      }, 1);
    }

    // Set event listeners if Last Chance component active
    if (lastChanceComponent) {
      // LastChance component shown results
      lastChanceComponent.searchStore.on('result', function () {
        clearTimeout(lastChanceShowTimeOut);
      });
      // LastChance component submit button clicked
      lastChanceComponent.on('submit', function () {
        logContactTicket();
      });
    }
    // Observe when the Deflection's required elements, except the instantsFixedToElement element, appears and disapears from the DOM and launch the required functions
    elementsObserver(deflectionRequiredElements, deflectionLoadFn, deflectionUnloadFn, deflectionConstructor.page);

    // If Instants component has to be static. Observe when the Deflection's required elements, including the instantsFixedToElement element, appears and disapears from the DOM and launch the required functions
    if (instantsComponent && typeof deflectionConstructor.elements.instantsFixedToElement === 'string') {
      var fixedInstantsRequiredElements = deflectionRequiredElements.concat(deflectionConstructor.elements.instantsFixedToElement);
      elementsObserver(fixedInstantsRequiredElements, fixedInstantsLoadFn, fixedInstantsUnloadFn, deflectionConstructor.page);
    }
  }

})));
